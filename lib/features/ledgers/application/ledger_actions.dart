/// 账本用例编排：UI 与仓储之间的唯一入口。
///
/// 设计意图：账本的增删改、清空、脱离云端与「切本位币」都是带副作用的用例
/// （写库 + 登记云端变更 + 折算重算），过去散落在页面与共享组件里。收敛到本
/// 类后，页面只负责交互与提示；折算重算仍由调用方按原样串联，保证本次重构
/// 是纯搬迁、零行为变化。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/sharing_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 邀请预览展示模型。
class LedgerInvitePreview {
  const LedgerInvitePreview({required this.ledgerName, required this.role});

  final String ledgerName;
  final String role;
}

/// 新建邀请展示模型。
class LedgerInvite {
  const LedgerInvite({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;
}

/// 接受邀请结果：区分首批历史数据是否已同步完成，让 UI 给出准确提示。
class AcceptInviteResult {
  const AcceptInviteResult({required this.historySyncDeferred});

  /// true = 账本已加入但首批历史数据未拉取成功，待联网后由常规同步补齐。
  final bool historySyncDeferred;
}

/// 账本用例编排。
class LedgerActions {
  LedgerActions(this.ref);

  /// 持有 Ref 是为了与 [LedgerStorageActions] 保持一致的编排入口形态。
  final Ref ref;

  LocalRepository get _repo => ref.read(repositoryProvider);

  // ==================== 查询 ====================

  /// 按 id 取账本；已删除返回 null。
  Future<LedgerDisplayItem?> getById(String id) async {
    final row = await _repo.getLedgerById(id);
    return row?.toDisplayItem();
  }

  /// 取全部账本展示项。
  Future<List<LedgerDisplayItem>> getAll() async {
    final rows = await _repo.getAllLedgers();
    return [for (final row in rows) row.toDisplayItem()];
  }

  /// 取全部账本并一次性合并列表统计。
  Future<List<LedgerDisplayItem>> getAllWithStats() async {
    final rows = await _repo.getAllLedgers();
    final stats = await _repo.getAllLedgerStats();
    return [
      for (final row in rows)
        row.toDisplayItem(
          transactionCount: stats[row.id]?.transactionCount ?? 0,
          expenseTotal: stats[row.id]?.expenseTotal ?? 0,
        ),
    ];
  }

  /// 取单个账本统计（交易笔数用于「切本位币是否需重算」的判断）。
  Future<({double expenseTotal, int transactionCount})> getStats({
    required String ledgerId,
  }) => _repo.getLedgerStats(ledgerId: ledgerId);

  /// 取账本交易实际涉及的外币（补折算与预拉汇率用）。
  Future<Set<String>> getForeignCurrencies(String ledgerId) =>
      _repo.getLedgerForeignCurrencies(ledgerId);

  /// 统计尚未折算到本位币的交易笔数。
  Future<int> countUnconvertedForeignTx(String ledgerId) =>
      _repo.countUnconvertedForeignTx(ledgerId);

  // ==================== 用例 ====================

  /// 新建账本，返回新账本 id。
  Future<String> create({
    required String name,
    String currency = 'CNY',
    String storageMode = 'cloud',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
  }) => _repo.createLedger(
    name: name,
    currency: currency,
    storageMode: storageMode,
    aaEnabled: aaEnabled,
    monthStartDay: monthStartDay,
    localSelfId: localSelfId,
  );

  /// 落库已在云端存在的绑定账本，不登记新建变更。
  Future<void> createBound({required String id, required String name}) =>
      _repo.createBoundLedger(id: id, name: name);

  /// 更新账本元信息。
  Future<void> update({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) => _repo.updateLedger(
    id: id,
    name: name,
    currency: currency,
    monthStartDay: monthStartDay,
    aaEnabled: aaEnabled,
    recordChanges: recordChanges,
  );

  /// 更新账本成员的本地状态镜像。
  Future<void> updateMemberStatus({
    required String ledgerId,
    required String accountId,
    required String status,
  }) => _repo.updateMemberStatus(
    ledgerId: ledgerId,
    accountId: accountId,
    status: status,
  );

  /// 查询邀请码预览并转换为页面展示模型。
  Future<LedgerInvitePreview> queryInvite(String code) async {
    try {
      final preview = await ref
          .read(sharingServiceProvider)
          .queryInviteByCode(code);
      return LedgerInvitePreview(
        ledgerName: preview.ledgerName,
        role: preview.role.name,
      );
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '查询邀请失败: $code', error, stackTrace);
      rethrow;
    }
  }

  /// 接受邀请、落本地绑定，并触发首次全量同步。
  ///
  /// 加入不回滚：首批历史数据同步失败只降级为「待同步」状态返回给 UI，
  /// 账本绑定保留，数据由联网后的常规同步补齐。bootstrap 把失败收敛为
  /// error 结果返回（非抛出），因此必须检查返回值而不只依赖 catch。
  Future<AcceptInviteResult> acceptInvite(String code) async {
    try {
      final accepted = await ref
          .read(sharingServiceProvider)
          .acceptInvite(code);
      await createBound(id: accepted.ledgerId, name: accepted.ledgerName);
      try {
        final bootstrapResult = await ref
            .read(syncCoordinatorProvider)
            .bootstrap();
        if (!bootstrapResult.ok) {
          logger.warning(
            'LedgerActions',
            '加入后首批历史数据同步失败，待联网后补齐: ${bootstrapResult.error}',
          );
          return const AcceptInviteResult(historySyncDeferred: true);
        }
      } catch (error, stackTrace) {
        logger.warning(
          'LedgerActions',
          '加入后首批历史数据同步异常，待联网后补齐',
          '$error\n$stackTrace',
        );
        return const AcceptInviteResult(historySyncDeferred: true);
      }
      return const AcceptInviteResult(historySyncDeferred: false);
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '接受邀请失败: $code', error, stackTrace);
      rethrow;
    }
  }

  /// 为账本创建限时邀请。
  Future<LedgerInvite> createInvite({
    required String ledgerId,
    required int expiresInHours,
  }) async {
    try {
      final invite = await ref
          .read(sharingServiceProvider)
          .createInvite(ledgerId: ledgerId, expiresInHours: expiresInHours);
      return LedgerInvite(code: invite.code, expiresAt: invite.expiresAt);
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '创建邀请失败: $ledgerId', error, stackTrace);
      rethrow;
    }
  }

  /// 移除协作者并同步本地成员镜像状态。
  Future<void> removeMember({
    required String ledgerId,
    required String memberId,
    required String accountId,
  }) async {
    try {
      await ref
          .read(sharingServiceProvider)
          .removeLedgerMember(ledgerId: ledgerId, memberId: memberId);
      await updateMemberStatus(
        ledgerId: ledgerId,
        accountId: accountId,
        status: 'REMOVED',
      );
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '移除成员失败: $memberId', error, stackTrace);
      rethrow;
    }
  }

  /// 新建虚拟用户（账本内 AA 参与人占位成员），返回新成员 id。
  Future<String> createPlaceholderMember({
    required String ledgerId,
    required String name,
    String? id,
  }) => _repo.createPlaceholderMember(ledgerId: ledgerId, name: name, id: id);

  /// 删除账本（本地直接删行，云上记录随后续同步清理）。
  Future<void> delete(String id) => _repo.deleteLedger(id);

  /// 退出并删除共享账本（协作者）：cloud-first 退出（成员置 LEFT）→
  /// 单账本 purge 本地数据 → 刷新账本列表。
  ///
  /// 服务端 404（已退出/已被移除）幂等放行，不阻断本地清理。
  Future<void> leaveSharedLedger(String ledgerId) async {
    try {
      await ref.read(sharingServiceProvider).leaveLedger(ledgerId);
    } catch (error) {
      if (!isLeaveAlreadyGone(error)) rethrow;
    }
    await _repo.purgeLedger(ledgerId);
    ref.read(ledgerListRefreshProvider.notifier).tick();
  }

  /// 全局删除共享账本（所有者）：cloud-first 删除（服务端 tombstone 账本、
  /// 级联撤销邀请并广播 delete change）→ 单账本 purge 本地数据 → 刷新列表。
  Future<void> deleteSharedAsOwner(String ledgerId) async {
    await ref.read(sharingServiceProvider).deleteSharedLedgerAsOwner(ledgerId);
    await _repo.purgeLedger(ledgerId);
    ref.read(ledgerListRefreshProvider.notifier).tick();
  }

  /// 清空账本交易，云账本逐笔登记 delete mutation。
  Future<int> clearTransactions(String ledgerId) =>
      _repo.clearLedgerTransactions(ledgerId);

  /// 把云端账本脱离云归属，转回本地账本。
  Future<void> detachFromCloud(String id) => _repo.detachFromCloud(id);

  /// 折算补算：只处理尚未折算的交易（一键补折算 / 本地刷新均走此入口）。
  Future<int> recomputeForeignTx(String ledgerId) =>
      _repo.recomputeForeignTxForLedger(ledgerId);

  /// 在单事务内执行 [action]（切本位币用它保证元数据与快照重算同提交）。
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _repo.runInTransaction(action);

  /// 全量重算账本的本位币折算快照，返回重算笔数。
  Future<int> recalcNativeAmounts(
    String ledgerId,
    String newBase, {
    required String previousBase,
  }) => _repo.recalcNativeAmountsForLedger(
    ledgerId,
    newBase,
    previousBase: previousBase,
  );
}

/// 账本用例编排 provider。
final ledgerActionsProvider = Provider<LedgerActions>(
  (ref) => LedgerActions(ref),
);

/// 当前云账号 id；账本 UI 只消费此应用层身份快照。
final currentLedgerAccountIdProvider = Provider<String?>((ref) {
  return ref.watch(authSessionProvider)?.userId;
});
