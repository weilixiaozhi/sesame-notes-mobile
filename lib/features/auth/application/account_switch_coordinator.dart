import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/identity_binding_service.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';

/// 切换/登出时旧账号域存在未同步数据时的处置策略。
enum AccountSwitchPolicy {
  /// 默认阻断：提示用户先同步，或改用 safetyFork 显式保留本地副本
  block,

  /// 显式确认：批量 Safety Fork 旧账号云端账本后允许清理
  safetyFork,
}

/// 预检阻断的业务异常：携带未同步修改的数量与类型，供 UI 展示稳定文案。
class PendingChangesBlockedException implements Exception {
  final int ledgerChangeCount;
  final int userGlobalChangeCount;
  final int openConflictCount;

  const PendingChangesBlockedException({
    required this.ledgerChangeCount,
    required this.userGlobalChangeCount,
    required this.openConflictCount,
  });

  @override
  String toString() =>
      '有尚未同步的云端修改，请同步后再退出（账本级 $ledgerChangeCount、user-global $userGlobalChangeCount、冲突 $openConflictCount）';
}

/// 账号切换协调器：登录/注册候选凭证的唯一提交点。
///
/// 设计意图（两阶段提交）：
/// 1. `AuthService.login/register` 只返回候选会话，不写安全存储；
/// 2. 本协调器完成旧账号域预检/清理后，原子写 ActiveCredential 并 signIn；
/// 3. 登录成功判定只取决于认证响应与本协调器的原子提交，任一失败都不算成功；
/// 4. 提交完成后的 reconnect 不属于认证成败：失败保持已登录并记录日志；
/// 5. 登出/切换先写持久标记，崩溃后启动恢复仍能完成清理与撤销。
class AccountSwitchCoordinator {
  final Ref ref;

  AccountSwitchCoordinator(this.ref);

  /// 提交登录/注册候选凭证（A→B 两阶段提交的 B 提交路径）。
  ///
  /// 顺序：hold sync gate → 停 realtime → PendingCredential(B) →
  /// 预检 A（阻断或批量 Safety Fork）→ purge A → 原子写 ActiveCredential(B) →
  /// signIn B → best-effort 撤销 A → 清 PendingCredential → 后台 reconnect。
  /// 写 B ActiveCredential 之前任一步失败：A 凭证保持不变、B Token best-effort 撤销。
  Future<bool> commitLogin({
    required CandidateSession candidate,
    required Future<void> Function()? onReconnect,
    AccountSwitchPolicy policy = AccountSwitchPolicy.block,
  }) async {
    final store = ref.read(secureAccountStoreProvider);
    final credential = ActiveCredential(
      userId: candidate.session.userId,
      deviceId: candidate.session.deviceId,
      refreshToken: candidate.refreshToken,
    );
    final gate = ref.read(syncGateProvider.notifier);
    gate.hold();
    try {
      // 停 realtime：旧账号的通知与在途同步先退出（gate 已阻止新请求）
      await ref.read(realtimeCoordinatorProvider).stop();
      // 候选凭证先落盘：崩溃后启动恢复能识别「B 已认证但未提交」
      await store.savePending(credential);
      final active = await store.load();
      final sameAccount =
          active != null && active.userId == candidate.session.userId;
      if (active != null && !sameAccount) {
        // A → B：预检 A 的 pending/conflict（阻断或 Safety Fork），再 purge A
        await _ensureAccountDomainClear(active, policy);
        await _purgeAccountDomain(
          userId: active.userId,
          deviceId: active.deviceId,
        );
      }
      // 原子提交 B：先落安全存储，再生效内存会话
      await store.save(credential);
      final cache = ref.read(cloudProfileCacheProvider);
      await cache.write(candidate.profile);
      ref
          .read(accountStateProvider.notifier)
          .signIn(
            session: candidate.session,
            credential: credential,
            profile: candidate.profile,
          );
      // B 已安全提交后才撤销 A 的 Refresh Token（失败写 pending revocation 重试）
      if (active != null && !sameAccount) {
        await _revokeCredentialBestEffort(active);
      }
      await store.clearPending();
    } catch (error, stackTrace) {
      // 提交失败：A 凭证保持不变；B 候选凭证撤销并清除
      logger.error('AccountSwitch', '候选凭证提交失败，登录不成立', error, stackTrace);
      try {
        await _revokeCredentialBestEffort(credential);
        await store.clearPending();
      } catch (cleanupError, cleanupStackTrace) {
        logger.warning(
          'AccountSwitch',
          'B 候选凭证清理失败',
          '$cleanupError\n$cleanupStackTrace',
        );
      }
      return false;
    } finally {
      gate.release();
    }

    // 提交成功后的 reconnect 失败不构成登录失败
    if (onReconnect != null) {
      try {
        await onReconnect();
      } catch (error, stackTrace) {
        logger.warning(
          'AccountSwitch',
          '已登录，云数据将在网络恢复后同步（reconnect 失败）',
          '$error\n$stackTrace',
        );
      }
    }
    return true;
  }

  /// 登出：按登出顺序清理（marker → 预检 → purge → 清缓存 → 删凭证 → 撤销）。
  ///
  /// purge 或 ActiveCredential 删除失败时服务端 logout 尚未调用，
  /// 安全保留 A 并提示重试；撤销失败转入 pending revocation（marker 保留，
  /// 启动恢复重试），本地退出仍然完成。
  Future<void> logout({
    AccountSwitchPolicy policy = AccountSwitchPolicy.block,
  }) async {
    final store = ref.read(secureAccountStoreProvider);
    final state = ref.read(accountStateProvider);
    final profile = state.profile;
    final credential = await store.load();
    if (credential == null) {
      // 无凭证：直接清内存状态（本地身份）
      ref.read(accountStateProvider.notifier).signOut();
      return;
    }
    final gate = ref.read(syncGateProvider.notifier);
    gate.hold();
    try {
      await ref.read(realtimeCoordinatorProvider).stop();
      // pending/conflict 预检：阻断或显式 Safety Fork 后才允许清理
      await _ensureAccountDomainClear(credential, policy);
      // 写登出进行中标记：捕获 A 凭证，崩溃后也能完成撤销收尾
      await store.saveLogoutMarker(LogoutMarker(credential: credential));
      await _purgeAccountDomain(
        userId: credential.userId,
        deviceId: credential.deviceId,
      );
      if (profile != null) {
        await ref.read(cloudProfileCacheProvider).clear(profile.userId);
      }
      await store.clear();
      ref.read(accountStateProvider.notifier).signOut();
      // 本地身份解绑兜底：只清 LOCAL member 的 linked_account_id
      await IdentityBindingService.unbindOnLogout(
        db: ref.read(databaseProvider),
      );
      // 服务端撤销：失败保留 marker 作为 pending revocation，启动恢复重试
      try {
        await ref.read(authServiceProvider).revokeServerSession(credential);
        await store.clearLogoutMarker();
      } catch (error, stackTrace) {
        logger.warning(
          'AccountSwitch',
          '服务端会话撤销失败，标记保留待重试',
          '$error\n$stackTrace',
        );
      }
    } finally {
      gate.release();
    }
  }

  /// 预检旧账号域的 pending/conflict；block 策略直接阻断，
  /// safetyFork 策略先批量 Fork 云端账本（外层单事务，失败整批回滚）。
  Future<void> _ensureAccountDomainClear(
    ActiveCredential credential,
    AccountSwitchPolicy policy,
  ) async {
    final db = ref.read(databaseProvider);
    final pendingChanges =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(credential.userId) & c.pushedAt.isNull(),
            ))
            .get();
    final ledgerChangeCount = pendingChanges
        .where((c) => c.ledgerId != null)
        .length;
    final userGlobalChangeCount = pendingChanges
        .where((c) => c.ledgerId == null)
        .length;
    final cloudLedgerIds =
        (await (db.select(
              db.ledgers,
            )..where((l) => l.scopeAccountId.equals(credential.userId))).get())
            .map((l) => l.id)
            .toList();
    final openConflictCount = cloudLedgerIds.isEmpty
        ? 0
        : (await (db.select(db.syncConflicts)..where(
                    (c) =>
                        c.ledgerId.isIn(cloudLedgerIds) &
                        c.status.equals('OPEN'),
                  ))
                  .get())
              .length;
    if (ledgerChangeCount == 0 &&
        userGlobalChangeCount == 0 &&
        openConflictCount == 0) {
      return;
    }
    if (policy == AccountSwitchPolicy.block) {
      throw PendingChangesBlockedException(
        ledgerChangeCount: ledgerChangeCount,
        userGlobalChangeCount: userGlobalChangeCount,
        openConflictCount: openConflictCount,
      );
    }
    // safetyFork：批量保护有未同步数据/冲突的云端账本，全部成功才允许清理
    final localSelfId = await ref.read(localSelfIdProvider.future);
    final repo = ref.read(repositoryProvider);
    final operationId = const Uuid().v4();
    await db.transaction(() async {
      for (final ledgerId in cloudLedgerIds) {
        final hasLocalRisk =
            pendingChanges.any((c) => c.ledgerId == ledgerId) ||
            openConflictCount > 0;
        if (!hasLocalRisk) continue;
        final targetId = safetyForkTargetId(operationId, ledgerId);
        await repo.protectCloudLedgerToLocalFork(
          sourceLedgerId: ledgerId,
          targetLedgerId: targetId,
          localSelfId: localSelfId,
          currentAccountId: credential.userId,
        );
      }
      // user-global pending（分类/汇率）无账本可 Fork：显式放弃
      await (db.delete(db.syncChanges)..where(
            (c) =>
                c.accountId.equals(credential.userId) &
                c.ledgerId.isNull() &
                c.pushedAt.isNull(),
          ))
          .go();
    });
  }

  /// best-effort 撤销凭证对应的服务端会话；失败只记录日志，不影响主流程。
  Future<void> _revokeCredentialBestEffort(ActiveCredential credential) async {
    try {
      await ref.read(authServiceProvider).revokeServerSession(credential);
    } catch (error, stackTrace) {
      logger.warning('AccountSwitch', '旧账号会话撤销失败（可重试）', '$error\n$stackTrace');
    }
  }

  /// 单事务清理当前账号域：云账本（级联子表）、账号域分类/汇率、
  /// 该账号 mutation 队列与当前设备 sync_state；null scope 本地数据一律保留。
  Future<void> _purgeAccountDomain({
    required String userId,
    required String deviceId,
  }) async {
    final db = ref.read(databaseProvider);
    try {
      await db.transaction(() async {
        // 必须在删除账本前保存目标 id；账本删除后再查询会得到空集，遗留的
        // 冲突与拉取错误会污染下一账号的同步状态。
        final cloudLedgerIds =
            (await (db.select(
                  db.ledgers,
                )..where((l) => l.scopeAccountId.equals(userId))).get())
                .map((ledger) => ledger.id)
                .toList();
        // 云账本整本删除（交易/成员/分摊等经外键级联）
        await (db.delete(
          db.ledgers,
        )..where((l) => l.scopeAccountId.equals(userId))).go();
        // 账号域 user-global 数据：分类与手工汇率各账号一份
        await (db.delete(
          db.categories,
        )..where((c) => c.scopeAccountId.equals(userId))).go();
        await (db.delete(
          db.exchangeRateOverrides,
        )..where((r) => r.scopeAccountId.equals(userId))).go();
        // 该账号的 mutation 队列与同步状态（A 重登从 cursor 0 全量恢复）
        await (db.delete(
          db.syncChanges,
        )..where((c) => c.accountId.equals(userId))).go();
        await (db.delete(
          db.syncState,
        )..where((s) => s.deviceId.equals(deviceId))).go();
        if (cloudLedgerIds.isEmpty) return;
        await (db.delete(
          db.syncConflicts,
        )..where((c) => c.ledgerId.isIn(cloudLedgerIds))).go();
        await (db.delete(
          db.syncPullErrors,
        )..where((c) => c.ledgerId.isIn(cloudLedgerIds))).go();
      });
    } catch (error, stackTrace) {
      logger.error('AccountSwitch', '清理账号数据域失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 批量 Safety Fork 的确定性目标 id：同 (operation_id, source_id) 恒等，
/// 重试不会生成重复本地副本。
String safetyForkTargetId(String operationId, String sourceLedgerId) =>
    uuidV5(operationId, 'safety-fork:$sourceLedgerId');

/// 账号切换协调器装配。
final accountSwitchCoordinatorProvider = Provider<AccountSwitchCoordinator>(
  (ref) => AccountSwitchCoordinator(ref),
);
