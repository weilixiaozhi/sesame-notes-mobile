import 'dart:async';

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/memo_editor_session_provider.dart';
import '../../../shared/providers/fitness_space_provider.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';

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
  final int fitnessChangeCount;

  const PendingChangesBlockedException({
    required this.ledgerChangeCount,
    required this.userGlobalChangeCount,
    required this.openConflictCount,
    this.fitnessChangeCount = 0,
  });

  @override
  String toString() =>
      '有尚未同步的云端修改，请同步后再退出（账本级 $ledgerChangeCount、user-global $userGlobalChangeCount、健身 $fitnessChangeCount、冲突 $openConflictCount）';
}

/// 账号切换协调器：登录/注册候选凭证的唯一提交点。
///
/// 设计意图（两阶段提交）：
/// 1. `AuthService.login/register` 只返回候选会话，不写安全存储；
/// 2. 本协调器完成旧账号域预检/清理后，原子写 ActiveCredential 并 signIn；
/// 3. 登录成功判定只取决于认证响应与本协调器的原子提交，任一失败都不算成功；
/// 4. 提交完成后的 reconnect 不属于认证成败：失败保持已登录并记录日志；
/// 5. 候选凭证与撤销待办分别持久化；启动恢复重试已隔离账号的服务端撤销。
class AccountSwitchCoordinator {
  final Ref ref;

  /// 已登记的账号过渡数量，连续换号只在最后一个过渡结束后恢复通知。
  int _pendingTransitions = 0;

  AccountSwitchCoordinator(this.ref);

  /// 提交登录/注册候选凭证（A→B 两阶段提交的 B 提交路径）。
  ///
  /// 顺序：hold sync gate → 停 realtime → PendingCredential(B) →
  /// 预检 A（阻断或批量 Safety Fork）→ purge A → 原子写 ActiveCredential(B) →
  /// signIn B → 清 PendingCredential → 释放本机写屏障 → 后台撤销 A → await reconnect。
  /// 写 B ActiveCredential 前失败不会覆盖 A 凭证；提交后的缓存/会话写入失败
  /// 不在此回滚，只尽力撤销 B Token 并清候选槽。
  Future<bool> commitLogin({
    required CandidateSession candidate,
    required Future<void> Function()? onReconnect,
    AccountSwitchPolicy policy = AccountSwitchPolicy.block,
    bool initializeNewAccount = false,
  }) async {
    final config = ref.read(apiConfigProvider);
    for (final guard in ref.read(memoEditorLeaveGuardsProvider).toList()) {
      if (!await guard()) return false;
    }
    _pendingTransitions++;
    try {
      ref.read(realtimeCoordinatorProvider).setAccountTransitionPending(true);
      final result = await ref
          .read(syncCoordinatorProvider)
          .runAccountTransition(
            () => _commitLogin(
              candidate: candidate,
              policy: policy,
              initializeNewAccount: initializeNewAccount,
              config: config,
            ),
          );
      // 撤销材料已持久化，网络处理必须等账号闸门和本机写屏障全部释放后启动。
      if (result.revocation != null &&
          ref.mounted &&
          identical(ref.read(apiConfigProvider), config)) {
        unawaited(_revokeInBackground(result.revocation!));
      }
      if (!result.committed) return false;
      // 账号提交已离开串行任务，恢复可安全进入同一队列，不会等待自身完成。
      if (onReconnect != null &&
          ref.read(authSessionProvider)?.userId == candidate.session.userId &&
          ref.read(authSessionProvider)?.deviceId ==
              candidate.session.deviceId) {
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
    } finally {
      _pendingTransitions--;
      _reconcileRealtime();
    }
  }

  /// 在同步队列内提交候选账号，闸门只覆盖实际账号域清理与凭证提交。
  Future<({bool committed, ActiveCredential? revocation})> _commitLogin({
    required CandidateSession candidate,
    required AccountSwitchPolicy policy,
    required bool initializeNewAccount,
    required ApiConfig config,
  }) async {
    /// 本次提交固定服务配置，异步等待期间配置变化则停止激活迟到结果。
    void verifyService() {
      if (!ref.mounted || !identical(ref.read(apiConfigProvider), config)) {
        throw StateError('服务配置已变化，请重新登录；本机数据已保留');
      }
    }

    verifyService();
    final store = ref.read(secureAccountStoreProvider);
    final credential = ActiveCredential(
      userId: candidate.session.userId,
      deviceId: candidate.session.deviceId,
      refreshToken: candidate.refreshToken,
    );
    final gate = ref.read(syncGateProvider.notifier);
    ActiveCredential? revocation;
    gate.hold();
    try {
      // 停旧账号通知与重连；gate 阻止新同步轮次，但不取消在途 HTTP 请求。
      await ref.read(realtimeCoordinatorProvider).stop();
      // 将已认证候选写入独立槽位，启动恢复可撤销未提交的候选会话。
      verifyService();
      await store.savePending(credential);
      final active = await store.load();
      verifyService();
      final sameAccount =
          active != null && active.userId == candidate.session.userId;
      if (active != null && !sameAccount) {
        // A → B：预检 A 的 pending/conflict（阻断或 Safety Fork），再 purge A
        await _ensureAccountDomainClear(active, policy);
        await store.saveLogoutMarker(LogoutMarker(credential: active));
        revocation = active;
        await _purgeAccountDomain(
          userId: active.userId,
          deviceId: active.deviceId,
        );
      }
      if (initializeNewAccount) {
        await SeedService.ensureAccountSeed(
          ref.read(databaseProvider),
          credential.userId,
        );
      }
      // 原子提交 B：先落安全存储，再生效内存会话
      verifyService();
      await store.save(credential);
      verifyService();
      final cache = ref.read(cloudProfileCacheProvider);
      await cache.write(candidate.profile);
      verifyService();
      ref
          .read(accountStateProvider.notifier)
          .signIn(session: candidate.session, profile: candidate.profile);
      await store.clearPending();
    } catch (error, stackTrace) {
      // 提交失败：尽力撤销 B 并清候选槽，不回滚已完成的凭证或缓存写入。
      logger.error('AccountSwitch', '候选凭证提交失败，登录不成立', error, stackTrace);
      try {
        if (await _persistRevocation(credential)) {
          revocation = credential;
          await store.clearPending();
        }
      } catch (cleanupError, cleanupStackTrace) {
        logger.warning(
          'AccountSwitch',
          'B 候选凭证清理失败',
          '$cleanupError\n$cleanupStackTrace',
        );
      }
      return (committed: false, revocation: revocation);
    } finally {
      gate.release();
    }

    return (committed: true, revocation: revocation);
  }

  /// 登出：预检 → 写 marker → purge → 清缓存 → 删凭证 → 开闸 → 后台撤销服务端会话。
  ///
  /// purge 或 ActiveCredential 删除失败时服务端 logout 尚未调用，
  /// 保留凭证并提示重试；远端暂时失败保留安全撤销材料，
  /// 本地退出仍然完成，后续启动继续尝试直到收到确定结果。
  Future<void> logout({
    AccountSwitchPolicy policy = AccountSwitchPolicy.block,
  }) async {
    for (final guard in ref.read(memoEditorLeaveGuardsProvider).toList()) {
      if (!await guard()) throw StateError('MEMO_EDIT_IN_PROGRESS');
    }
    final session = ref.read(authSessionProvider);
    _pendingTransitions++;
    try {
      ref.read(realtimeCoordinatorProvider).setAccountTransitionPending(true);
      final credential = await ref
          .read(syncCoordinatorProvider)
          .runAccountTransition(() async {
            final current = ref.read(authSessionProvider);
            if (session?.userId != current?.userId ||
                session?.deviceId != current?.deviceId) {
              throw StateError('账号已变更，请重新操作');
            }
            return _logout(policy: policy);
          });
      if (credential != null) unawaited(_revokeInBackground(credential));
    } catch (error, stackTrace) {
      logger.error('AccountSwitch', '退出账号失败', error, stackTrace);
      rethrow;
    } finally {
      _pendingTransitions--;
      _reconcileRealtime();
    }
  }

  /// 账号队列与本机写屏障结束后，统一按最终有效会话恢复或关闭实时通知。
  void _reconcileRealtime() {
    if (!ref.mounted || _pendingTransitions != 0) return;
    final coordinator = ref.read(realtimeCoordinatorProvider);
    coordinator.setAccountTransitionPending(false);
    // 通知服务处理自己的连接失败，账号操作不等待取票；只恢复最终有效身份。
    unawaited(
      ref.read(authSessionProvider) == null
          ? coordinator.stop()
          : coordinator.start(),
    );
  }

  /// 等待在途操作完成后清理账号，保证迟到快照先完成再统一删除。
  Future<ActiveCredential?> _logout({
    required AccountSwitchPolicy policy,
  }) async {
    final store = ref.read(secureAccountStoreProvider);
    final state = ref.read(accountStateProvider);
    final profile = state.profile;
    final credential = await store.load();
    if (credential == null) {
      // 没有已认证账号时只清理内存会话，持久化账号数据保持隔离。
      ref.read(accountStateProvider.notifier).signOut();
      return null;
    }
    final gate = ref.read(syncGateProvider.notifier);
    gate.hold();
    try {
      await ref.read(realtimeCoordinatorProvider).stop();
      // pending/conflict 预检：阻断或显式 Safety Fork 后才允许清理
      await _ensureAccountDomainClear(credential, policy);
      // 写登出标记，保存启动恢复尝试服务端撤销所需的凭证。
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
      return credential;
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
    final cloudLedgerIds =
        (await (db.select(db.ledgers)..where(
                  (l) =>
                      l.storageMode.equals('cloud') &
                      l.scopeAccountId.equals(credential.userId),
                ))
                .get())
            .map((l) => l.id)
            .toList();
    final pendingChanges =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  (c.accountId.equals(credential.userId) |
                      c.ledgerId.isIn(cloudLedgerIds)) &
                  c.pushedAt.isNull(),
            ))
            .get();
    final ledgerChangeCount = pendingChanges
        .where(
          (c) =>
              c.ledgerId != null || c.dayBookId != null || c.memoBookId != null,
        )
        .length;
    final userGlobalChangeCount = pendingChanges
        .where(
          (c) =>
              c.ledgerId == null &&
              c.dayBookId == null &&
              c.memoBookId == null &&
              !c.entityType.startsWith('fitness_'),
        )
        .length;
    final fitnessPending = pendingChanges
        .where((c) => c.entityType.startsWith('fitness_'))
        .toList();
    // 预检与删除共用已认证账号的云账本范围。
    final openConflicts =
        await (db.select(db.syncConflicts)..where(
              (c) =>
                  (c.ledgerId.isIn(cloudLedgerIds) |
                      c.accountId.equals(credential.userId)) &
                  (c.status.equals('OPEN') |
                      (c.entityType.like('fitness_%') &
                          c.resolvedAt.isNull() &
                          c.localMutationId.like('fitness-recovery:%'))),
            ))
            .get();
    final openConflictCount = openConflicts.length;
    if (ledgerChangeCount == 0 &&
        userGlobalChangeCount == 0 &&
        fitnessPending.isEmpty &&
        openConflictCount == 0) {
      return;
    }
    if (policy == AccountSwitchPolicy.block) {
      throw PendingChangesBlockedException(
        ledgerChangeCount: ledgerChangeCount,
        userGlobalChangeCount: userGlobalChangeCount,
        openConflictCount: openConflictCount,
        fitnessChangeCount: fitnessPending.length,
      );
    }
    // 只有能由当前账号完整保护的账本变更才允许进入退出清理流程。
    _requirePendingLedgerScope(cloudLedgerIds.toSet(), [
      for (final change in pendingChanges)
        if (change.entityType != 'category') change.ledgerId,
      for (final conflict in openConflicts)
        if (conflict.entityType != 'category') conflict.ledgerId,
    ]);
    // safetyFork：批量保护有未同步数据/冲突的云端账本，全部成功才允许清理
    final localSelfId = await ref.read(localSelfIdProvider.future);
    final repo = ref.read(accountDataAccessProvider);
    final operationId = const Uuid().v4();
    await db.transaction(() async {
      final fitnessConflicts = openConflicts
          .where((c) => c.entityType.startsWith('fitness_'))
          .toList();
      if (fitnessPending.isNotEmpty || fitnessConflicts.isNotEmpty) {
        final branch = [
          ...fitnessPending.map((c) => c.mutationId),
          ...fitnessConflicts.map((c) => '${c.id}:${c.remoteRevision}'),
        ]..sort();
        final ids = {
          ...fitnessPending.map((c) => c.fitnessSpaceId),
          ...fitnessConflicts.map((c) => c.fitnessSpaceId),
        }.whereType<String>();
        for (final id in ids) {
          await ref
              .read(fitnessSpaceAccountRepositoryProvider)
              .copyToLocalForAccountExit(
                id,
                'account-exit:fitness:$id:${branch.join(':')}',
              );
        }
      }
      final dayBooks = await (db.select(
        db.dayBooks,
      )..where((b) => b.scopeAccountId.equals(credential.userId))).get();
      for (final book in dayBooks) {
        final pending = pendingChanges
            .where((c) => c.dayBookId == book.id)
            .toList();
        final conflicts = openConflicts
            .where((c) => c.dayBookId == book.id)
            .toList();
        if (pending.isEmpty && conflicts.isEmpty) continue;
        // 来源分支身份稳定；清理失败后重试复用已成功落库的整本副本。
        final branch = [
          for (final c in pending) c.mutationId,
          for (final c in conflicts) '${c.id}:${c.remoteRevision}',
        ].join(':');
        await ref
            .read(dayAccountRepositoryProvider)
            .copyToLocal(
              book.id,
              accountId: credential.userId,
              operationId: 'account-exit:${book.id}:$branch',
            );
      }
      for (final ledgerId in cloudLedgerIds) {
        final hasLocalRisk =
            pendingChanges.any((c) => c.ledgerId == ledgerId) ||
            openConflicts.any((c) => c.ledgerId == ledgerId);
        if (!hasLocalRisk) continue;
        final targetId = safetyForkTargetId(operationId, ledgerId);
        await repo.protectCloudLedgerToLocalFork(
          sourceLedgerId: ledgerId,
          targetLedgerId: targetId,
          localSelfId: localSelfId,
          currentAccountId: credential.userId,
        );
      }
      final memoBooks = await (db.select(
        db.memoBooks,
      )..where((b) => b.scopeAccountId.equals(credential.userId))).get();
      for (final book in memoBooks) {
        final pending = pendingChanges
            .where((c) => c.memoBookId == book.id)
            .toList();
        final conflicts = openConflicts
            .where((c) => c.memoBookId == book.id)
            .toList();
        if (pending.isEmpty && conflicts.isEmpty) continue;
        final branch = [
          ...pending.map((c) => c.mutationId),
          ...conflicts.map((c) => '${c.id}:${c.remoteRevision}'),
        ].join(':');
        await ref
            .read(memoAccountRepositoryProvider)
            .copyToLocalForAccountExit(
              book.id,
              'account-exit:${book.id}:$branch',
            );
      }
      // 分类完整候选及原请求按账号保留；汇率沿原退出清理语义。
      await (db.delete(db.syncChanges)..where(
            (c) =>
                c.accountId.equals(credential.userId) &
                c.ledgerId.isNull() &
                c.dayBookId.isNull() &
                c.memoBookId.isNull() &
                c.entityType.like('fitness_%').not() &
                c.entityType.equals('category').not() &
                c.pushedAt.isNull(),
          ))
          .go();
    });
  }

  /// 检查待保护账本均属于目标账号的数据域，无法确认时保留原请求和冲突。
  void _requirePendingLedgerScope(
    Set<String> cloudLedgerIds,
    Iterable<String?> references,
  ) {
    try {
      if (references.whereType<String>().any(
        (id) => !cloudLedgerIds.contains(id),
      )) {
        throw StateError('待同步账本的账号归属不完整，原数据未清理，请先处理同步数据');
      }
    } catch (error, stackTrace) {
      logger.error('AccountSwitch', '待保护账本归属校验失败', error, stackTrace);
      rethrow;
    }
  }

  /// 持久化撤销材料，返回是否已安全接管候选槽，账号清理期间不等待网络。
  Future<bool> _persistRevocation(ActiveCredential credential) async {
    try {
      await ref
          .read(secureAccountStoreProvider)
          .saveLogoutMarker(LogoutMarker(credential: credential));
      return true;
    } catch (error, stackTrace) {
      logger.error(
        'AccountSwitch',
        '服务端撤销待办保存失败',
        error.runtimeType,
        stackTrace,
      );
      return false;
    }
  }

  /// 本地账号切换结束后静默撤销旧会话；失败保留安全材料供启动恢复继续处理。
  Future<void> _revokeInBackground(ActiveCredential credential) async {
    try {
      if (!ref.mounted) return;
      await revokePendingCredential(ref, credential);
    } catch (error, stackTrace) {
      logger.error(
        'AccountSwitch',
        '服务端会话撤销尚未完成，已保留安全材料',
        error.runtimeType,
        stackTrace,
      );
    }
  }

  /// 单事务清理当前账号域：云账本（级联子表）、账号域分类/汇率、
  /// 该账号 mutation 队列与当前设备 sync_state。
  ///
  /// 本地副本只保留自己的目录；未确认分类及其父链按原账号隔离保留。
  Future<void> _purgeAccountDomain({
    required String userId,
    required String deviceId,
  }) async {
    final db = ref.read(databaseProvider);
    try {
      await db.transaction(() async {
        // 必须在删除账本前保存目标 id；账本删除后再查询会得到空集，遗留的
        // 冲突与拉取错误会污染下一账号的同步状态。
        // 清理只覆盖已认证账号；其他账号保留待重新认证。
        final cloudLedgerIds =
            (await (db.select(db.ledgers)..where(
                      (l) =>
                          l.storageMode.equals('cloud') &
                          l.scopeAccountId.equals(userId),
                    ))
                    .get())
                .map((ledger) => ledger.id)
                .toList();
        // 在实际删除事务内复核未确认账本引用，避免预检后新增的变更被跳过保护。
        // 分类候选按账号保留，不参与这里的账本级删除范围。
        final changes = db.syncChanges;
        final pendingReferences =
            await (db.selectOnly(changes)
                  ..addColumns([changes.ledgerId])
                  ..where(
                    changes.accountId.equals(userId) &
                        changes.entityType.equals('category').not() &
                        changes.pushedAt.isNull() &
                        changes.ledgerId.isNotNull(),
                  ))
                .get();
        final conflicts = db.syncConflicts;
        final conflictReferences =
            await (db.selectOnly(conflicts)
                  ..addColumns([conflicts.ledgerId])
                  ..where(
                    conflicts.accountId.equals(userId) &
                        conflicts.entityType.equals('category').not() &
                        conflicts.ledgerId.isNotNull() &
                        (conflicts.status.equals('OPEN') |
                            (conflicts.entityType.like('fitness_%') &
                                conflicts.resolvedAt.isNull() &
                                conflicts.localMutationId.like(
                                  'fitness-recovery:%',
                                ))),
                  ))
                .get();
        _requirePendingLedgerScope(cloudLedgerIds.toSet(), [
          for (final row in pendingReferences) row.read(changes.ledgerId),
          for (final row in conflictReferences) row.read(conflicts.ledgerId),
        ]);
        // 云账本整本删除（交易/编辑历史/成员/共享分类镜像/待推送变更级联）
        await ref
            .read(accountDataAccessProvider)
            .purgeAllCloudLedgers(accountId: userId);
        // 仅处理退出账号自己的目录，不根据其他账号或本地相同 UUID 推断分类归属。
        final accountCats = await (db.select(
          db.categories,
        )..where((c) => categoryScopePredicate(c, userId))).get();
        if (accountCats.isNotEmpty) {
          final localLedgers =
              await (db.select(db.ledgers)..where(
                    (l) =>
                        l.storageMode.equals('local') &
                        l.scopeAccountId.isNull(),
                  ))
                  .get();
          final localLedgerIds = localLedgers.map((l) => l.id).toSet();
          final ownOriginIds = localLedgers
              .where((l) => l.originAccountId == userId)
              .map((l) => l.id)
              .toSet();
          final localTxRows =
              await (db.select(db.transactions)..where(
                    (t) =>
                        t.categoryId.isNotNull() &
                        t.ledgerId.isIn(localLedgerIds),
                  ))
                  .get();
          final localRecRows =
              await (db.select(db.recurringTransactions)..where(
                    (r) =>
                        r.categoryId.isNotNull() &
                        r.ledgerId.isIn(localLedgerIds),
                  ))
                  .get();
          final referencedIds = <String>{
            for (final t in localTxRows)
              if (ownOriginIds.contains(t.ledgerId)) t.categoryId!,
            for (final r in localRecRows)
              if (ownOriginIds.contains(r.ledgerId)) r.categoryId!,
          };
          final localIds =
              (await (db.select(
                    db.categories,
                  )..where((c) => categoryScopePredicate(c, null))).get())
                  .map((c) => c.id)
                  .toSet();
          final ownIds = accountCats.map((c) => c.id).toSet();
          final toCopy = referencedIds
              .difference(localIds)
              .intersection(ownIds);
          if (toCopy.isNotEmpty) {
            await cloneCategoryReferences(
              source: db,
              target: db,
              categoryIds: toCopy,
              sourceAccountId: userId,
              targetAccountId: null,
            );
          }
          final pendingCategories =
              await (db.select(db.syncChanges)..where(
                    (c) =>
                        c.accountId.equals(userId) &
                        c.entityType.equals('category') &
                        c.pushedAt.isNull(),
                  ))
                  .get();
          final conflicts =
              await (db.select(db.syncConflicts)..where(
                    (c) =>
                        c.accountId.equals(userId) &
                        c.entityType.equals('category') &
                        c.status.equals('OPEN'),
                  ))
                  .get();
          // 未确认分类父链继续留在自己的账号域，重新认证时能按原身份展示和确认。
          final parentById = {for (final c in accountCats) c.id: c.parentId};
          final keepIds = {
            ...pendingCategories.map((c) => c.entityId),
            ...conflicts.map((c) => c.entityId),
          };
          final stack = keepIds.toList();
          while (stack.isNotEmpty) {
            final parentId = parentById[stack.removeLast()];
            if (parentId != null && keepIds.add(parentId)) {
              stack.add(parentId);
            }
          }
          await (db.delete(db.categories)..where(
                (c) =>
                    categoryScopePredicate(c, userId) &
                    (keepIds.isEmpty
                        ? const d.Constant(true)
                        : c.id.isNotIn(keepIds)),
              ))
              .go();
        }
        await (db.delete(
          db.exchangeRateOverrides,
        )..where((r) => r.scopeAccountId.equals(userId))).go();
        // 分类未确认请求保留完整原 payload，不允许重登时从其他账号的行重建。
        await (db.delete(db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(userId) &
                  (c.entityType.equals('category').not() |
                      c.pushedAt.isNotNull()),
            ))
            .go();
        await (db.delete(db.syncState)..where(
              (s) => s.deviceId.equals(deviceId) & s.accountId.equals(userId),
            ))
            .go();
        await (db.delete(db.syncConflicts)..where(
              (c) =>
                  c.accountId.equals(userId) &
                  c.entityType.equals('category').not(),
            ))
            .go();
        await (db.delete(
          db.syncPullErrors,
        )..where((c) => c.accountId.equals(userId))).go();
        await (db.delete(
          db.dayBooks,
        )..where((b) => b.scopeAccountId.equals(userId))).go();
        await (db.delete(
          db.memoBooks,
        )..where((b) => b.scopeAccountId.equals(userId))).go();
        await (db.delete(
          db.fitnessSpaces,
        )..where((s) => s.scopeAccountId.equals(userId))).go();
        if (cloudLedgerIds.isEmpty) return;
        await (db.delete(
          db.syncConflicts,
        )..where((c) => c.ledgerId.isIn(cloudLedgerIds))).go();
        await (db.delete(
          db.syncPullErrors,
        )..where((c) => c.ledgerId.isIn(cloudLedgerIds))).go();
      });
      await ref.read(cloudLedgerDownloadStoreProvider).forgetAccount(userId);
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
