library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';

/// 账本用例编排：UI 与仓储之间的唯一入口。
///
/// 已发布账本查询、持久化和共享操作集中在应用入口，页面只负责交互与提示。

import 'dart:io';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/ledger_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/published_ledger_queries.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
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

/// 账本用例编排。
class LedgerActions {
  LedgerActions(this.ref);

  /// 持有 Ref 是为了与 [DataLifecycleActions] 保持一致的编排入口形态。
  final Ref ref;

  LedgerRepository get _repo => ref.read(ledgerDataAccessProvider);

  /// 固定协作请求发起时的账号与身份代次，令牌轮换不改变此边界。
  ({String? accountId, int generation}) _identity() => (
    accountId: ref.read(currentAccountIdProvider),
    generation: ref.read(authIdentityGenerationProvider),
  );

  /// 服务端回执与本地镜像必须属于同一次账号会话。
  void _requireIdentity(({String? accountId, int generation}) identity) {
    if (!ref.mounted || _identity() != identity) {
      throw StateError('账号已变更，请重新操作');
    }
  }

  /// 仅系统明确无网络时提前拒绝协作操作；服务器暂不可达仍允许用户重试。
  void _requireNetwork() {
    if (ref.read(cloudConnectionProvider.notifier).isNetworkUnavailable) {
      throw const SocketException(cloudNetworkErrorMessage);
    }
  }

  // ==================== 查询 ====================

  /// 按 id 取已发布账本，首次内容尚未落地时不向页面暴露占位。
  Future<LedgerDisplayItem?> getById(String id) async {
    return (await readPublishedLedger(ref.read, id))?.toDisplayItem();
  }

  /// 取使用中或已归档的账本，后台仓储查询仍保留全部账本。
  Future<List<LedgerDisplayItem>> getAll({bool archived = false}) async {
    final rows = await readPublishedLedgers(ref.read, archived: archived);
    return [for (final row in rows) row.toDisplayItem()];
  }

  /// 取指定归档状态的账本并一次性合并列表统计。
  Future<List<LedgerDisplayItem>> getAllWithStats({
    bool archived = false,
  }) async {
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final rows = await readPublishedLedgers(ref.read, archived: archived);
    final stats = await _repo.getAllLedgerStats();
    if (account != ref.read(currentAccountIdProvider) ||
        generation != ref.read(authIdentityGenerationProvider)) {
      return [];
    }
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

  /// 统计尚未折算到本位币的交易笔数。
  Future<int> countUnconvertedForeignTx(String ledgerId) =>
      _repo.countUnconvertedForeignTx(ledgerId);

  // ==================== 用例 ====================

  /// 修改个人归档状态，并让当前选择始终指向使用中的账本。
  Future<void> setArchived(String id, bool archived) async {
    try {
      if (await getById(id) == null) throw StateError('账本暂不可用，请稍后重试');
      await _repo.setLedgerArchived(
        id,
        archived,
        deviceId: ref.read(authSessionProvider)?.deviceId,
      );
      final current = ref.read(currentLedgerIdProvider);
      if (archived && current == id) {
        await selectFirstLedger(ref.read);
      } else if (!archived && current.isEmpty) {
        await selectPublishedLedger(ref.read, id);
      }
      ref.read(ledgerListRefreshProvider.notifier).tick();
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '修改账本归档状态失败: $id', error, stackTrace);
      rethrow;
    }
  }

  /// 前台写入时在同一事务内重查归档状态，拦截已打开页面或弹窗的过期操作。
  Future<T> _writeActiveLedger<T>(
    String ledgerId,
    Future<T> Function() write,
  ) async {
    try {
      return await _repo.runInTransaction(() async {
        await _repo.requireActiveLedger(ledgerId);
        return write();
      });
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '修改账本失败: $ledgerId', error, stackTrace);
      rethrow;
    }
  }

  /// 保护本地分支后重新下载账本，页面只处理编排结果。
  Future<SyncRunResult> abandonLocalChanges({required String ledgerId}) =>
      ref.read(syncCoordinatorProvider).abandonLocalChanges(ledgerId: ledgerId);

  /// 保留本地冲突值并由同步编排器安排上传。
  Future<SyncRunResult> resolveConflictKeepLocal(String conflictId) =>
      ref.read(syncCoordinatorProvider).resolveConflictKeepLocal(conflictId);

  /// 采用云端冲突值，等待当前同步和快照操作完成后执行。
  Future<SyncRunResult> resolveConflictAdoptRemote(String conflictId) =>
      ref.read(syncCoordinatorProvider).resolveConflictAdoptRemote(conflictId);

  /// 新建账本，返回新账本 id。
  Future<String> create({
    required String name,
    String currency = 'CNY',
    String? storageMode,
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
    List<String> placeholderNames = const [],
    List<RecurringTransactionDisplay> recurring = const [],
  }) async {
    final String mode = storageMode ?? ref.read(newBookStorageModeProvider);

    /// 创建账本自身并登记其变更，供组合保存共用同一事务。
    Future<String> createLedger() => _repo.createLedger(
      name: name,
      currency: currency,
      storageMode: mode,
      aaEnabled: aaEnabled,
      monthStartDay: monthStartDay,
      localSelfId: localSelfId,
    );
    try {
      if (mode == 'cloud' &&
          !ref.read(cloudCapabilityProvider).canUseCloudBooks) {
        throw StateError('云服务不可用，请创建本地账本');
      }
      if (placeholderNames.isEmpty && recurring.isEmpty) {
        return await createLedger();
      }
      return await _repo.runInTransaction(() async {
        final id = await createLedger();
        for (final memberName in placeholderNames) {
          await _repo.createPlaceholderMember(ledgerId: id, name: memberName);
        }
        // 周期配置随新账本原子保存，任一失败都回滚，重试不留下半成品。
        for (final item in recurring) {
          await _repo.addRecurringTransaction(
            ledgerId: id,
            type: item.txType,
            amount: item.amount,
            currencyCode: item.currencyCode,
            categoryId: item.categoryId,
            note: item.note,
            frequency: item.frequency,
            interval: item.interval,
            dayOfMonth: item.dayOfMonth,
            dayOfWeek: item.dayOfWeek,
            monthOfYear: item.monthOfYear,
            timeZone: item.timeZone,
            startDate: item.startDate,
            endDate: item.endDate,
            enabled: item.enabled,
          );
        }
        return id;
      });
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '创建账本及成员失败', error, stackTrace);
      rethrow;
    }
  }

  /// 更新账本元信息。
  Future<void> update({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) => _writeActiveLedger(
    id,
    () => _repo.updateLedger(
      id: id,
      name: name,
      currency: currency,
      monthStartDay: monthStartDay,
      aaEnabled: aaEnabled,
      recordChanges: recordChanges,
    ),
  );

  /// 保存编辑页的账本元信息：只有真的变化的字段才写库。
  ///
  /// 返回 [saved] = 是否完成保存（false = 账本缺失/不可见/已归档，调用方应保留
  /// 页面）；[changed] = 是否真的写入（无变更时不产生 UPDATE，也不登记多余的
  /// 同步变更与刷新信号）。
  Future<({bool saved, bool changed})> saveEdits({
    required String id,
    required String name,
    required int monthStartDay,
    required bool aaEnabled,
  }) async {
    final data = await getById(id);
    if (data == null || data.isArchived) {
      return (saved: false, changed: false);
    }
    final nameChanged = name != data.name;
    final startDayChanged = monthStartDay != data.monthStartDay;
    final aaChanged = aaEnabled != data.aaEnabled;
    if (!nameChanged && !startDayChanged && !aaChanged) {
      // 无任何变更：视为保存成功，但不落任何字段。
      return (saved: true, changed: false);
    }
    await update(
      id: id,
      name: name,
      monthStartDay: monthStartDay,
      // 未变更时传 null = 不更新(updateLedger 语义)
      aaEnabled: aaChanged ? aaEnabled : null,
    );
    return (saved: true, changed: true);
  }

  /// 查询邀请码预览并转换为页面展示模型。
  Future<LedgerInvitePreview> queryInvite(String code) async {
    try {
      _requireNetwork();
      final preview = await ref
          .read(sharingServiceProvider)
          .queryInviteByCode(code);
      return LedgerInvitePreview(
        ledgerName: preview.ledgerName,
        role: preview.role.name,
      );
    } catch (error, stackTrace) {
      logger.error(
        'LedgerActions',
        '查询邀请失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 接受邀请后只持久登记后台任务，完整快照提交时才发布账本。
  Future<void> acceptInvite(String code) async {
    try {
      _requireNetwork();
      final accountId = ref.read(authSessionProvider)?.userId;
      if (accountId == null) throw StateError('请先登录');
      final generation = ref.read(authIdentityGenerationProvider);
      final accepted = await ref
          .read(sharingServiceProvider)
          .acceptInvite(code);

      /// 服务端回执和任务持久化都必须属于发起时的会话。
      bool sameSession() =>
          ref.mounted &&
          accountId == ref.read(authSessionProvider)?.userId &&
          generation == ref.read(authIdentityGenerationProvider);
      if (!sameSession()) {
        throw StateError('账号已变更，请重新操作');
      }
      final existing = await readPublishedLedger(ref.read, accepted.ledgerId);
      if (!sameSession()) throw StateError('账号已变更，请重新操作');
      final store = ref.read(cloudLedgerDownloadStoreProvider);
      await store.markPending(
        accountId,
        accepted.ledgerId,
        hasLocalSnapshot: existing?.storageMode == 'cloud',
      );
      if (!sameSession()) {
        await store.forget(accountId, accepted.ledgerId);
        throw StateError('账号已变更，请重新操作');
      }
    } catch (error, stackTrace) {
      logger.error(
        'LedgerActions',
        '接受邀请失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 为账本创建限时邀请。
  Future<LedgerInvite> createInvite({
    required String ledgerId,
    required int expiresInHours,
  }) async {
    try {
      _requireNetwork();
      final identity = _identity();
      await _repo.requireActiveLedger(ledgerId);
      _requireIdentity(identity);
      final invite = await ref
          .read(sharingServiceProvider)
          .createInvite(ledgerId: ledgerId, expiresInHours: expiresInHours);
      _requireIdentity(identity);
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
      _requireNetwork();
      final identity = _identity();
      final repository = _repo;
      await _repo.requireActiveLedger(ledgerId);
      _requireIdentity(identity);
      await ref
          .read(sharingServiceProvider)
          .removeLedgerMember(ledgerId: ledgerId, memberId: memberId);
      _requireIdentity(identity);
      await ref
          .read(syncCoordinatorProvider)
          .runDataMutation(
            () => repository.runInTransaction(() async {
              _requireIdentity(identity);
              await repository.updateMemberStatus(
                ledgerId: ledgerId,
                accountId: accountId,
                status: 'REMOVED',
              );
              _requireIdentity(identity);
            }),
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
  }) => _writeActiveLedger(
    ledgerId,
    () => _repo.createPlaceholderMember(ledgerId: ledgerId, name: name, id: id),
  );

  /// 删除使用中或归档的个人账本，本地直接清理，云端登记删除同步。
  Future<void> delete(String id) async {
    try {
      final accountId = ref.read(currentAccountIdProvider);
      await ref
          .read(dataLifecycleProvider)
          .deleteTarget(SyncTarget('ledger', id));
      if (accountId != null) {
        await ref.read(cloudLedgerDownloadStoreProvider).forget(accountId, id);
      }
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('visibleCurrencies.$id');
      } catch (error, stackTrace) {
        logger.warning(
          'LedgerActions',
          '清理账本可见币种偏好失败: $id, $error',
          stackTrace,
        );
      }
    } catch (error, stackTrace) {
      logger.error('LedgerActions', '删除本机账本失败: $id', error, stackTrace);
      rethrow;
    }
  }

  /// 退出并删除共享账本（协作者）：cloud-first 退出（成员置 LEFT）→
  /// 单账本 purge 本地数据 → 刷新账本列表。
  ///
  /// 服务端 404（已退出/已被移除）幂等放行，不阻断本地清理。
  Future<void> leaveSharedLedger(String ledgerId) async {
    final accountId = ref.read(authSessionProvider)?.userId;
    final identity = _identity();
    try {
      _requireNetwork();
      await ref.read(sharingServiceProvider).leaveLedger(ledgerId);
    } catch (error, stackTrace) {
      if (!isLeaveAlreadyGone(error)) {
        logger.error('LedgerActions', '退出账本失败: $ledgerId', error, stackTrace);
        rethrow;
      }
    }
    _requireIdentity(identity);
    final repository = _repo;
    await ref
        .read(syncCoordinatorProvider)
        .runDataMutation(
          () => repository.runInTransaction(() async {
            _requireIdentity(identity);
            await repository.purgeLedger(ledgerId);
            _requireIdentity(identity);
          }),
        );
    if (accountId != null) {
      await ref
          .read(cloudLedgerDownloadStoreProvider)
          .forget(accountId, ledgerId);
    }
    ref.read(ledgerListRefreshProvider.notifier).tick();
  }

  /// 所有者删除与个人云本共用持久删除队列，确认前失败仍可从全局同步处理。
  Future<void> deleteSharedAsOwner(String ledgerId) => delete(ledgerId);

  /// 清空账本交易，云账本逐笔登记 delete mutation。
  Future<int> clearTransactions(String ledgerId) => _writeActiveLedger(
    ledgerId,
    () => _repo.clearLedgerTransactions(ledgerId),
  );

  /// 把云端账本脱离云归属，转回本地账本。
  Future<void> detachFromCloud(String id) =>
      _writeActiveLedger(id, () => _repo.detachFromCloud(id));

  /// 折算补算：只处理尚未折算的交易（一键补折算 / 本地刷新均走此入口）。
  Future<int> recomputeForeignTx(String ledgerId) =>
      _repo.recomputeForeignTxForLedger(ledgerId);

  /// 下拉刷新当前账本：以当前账本为参数走统一刷新入口。
  ///
  /// 页面不自行决定刷新哪个账本；当前账本为空时退化为账号级刷新，
  /// 与账本列表页一致，用于发现其他设备新建或分享的账本。
  Future<SyncRunResult> refreshCurrentLedger() => ref
      .read(syncCoordinatorProvider)
      .refreshData(ledgerId: ref.read(currentLedgerIdProvider));

  /// 本地刷新（下拉刷新 / 云同步降级共用）：
  /// - 在线才刷新汇率，离线直接复用已落库的缓存汇率；
  /// - 无论在线与否都补折算未折算外币交易，保证本地快照口径一致；
  /// - 汇率刷新与补折算失败都不阻断刷新（仅告警）。
  ///
  /// 返回本次补折算笔数，调用方据此决定是否需要立即重查汇总。
  Future<int> refreshLocalData({required String ledgerId}) async {
    if (ref.read(cloudConnectionProvider) != CloudConnectionStatus.offline) {
      await refreshExchangeRates(read: ref.read, force: true);
    }
    return recomputeUnconvertedForeignTx(ledgerId);
  }

  /// 补折算未折算外币交易：存在未折算交易时按已落库汇率重算，返回折算笔数。
  /// 没有未折算交易时不做任何写入；补折算失败不阻断刷新（仅告警），返回 0。
  Future<int> recomputeUnconvertedForeignTx(String ledgerId) async {
    try {
      final unconverted = await countUnconvertedForeignTx(ledgerId);
      if (unconverted <= 0) return 0;
      final recalcCount = await recomputeForeignTx(ledgerId);
      logger.info(
        'LedgerActions',
        '本地刷新补折算: 未折算=$unconverted 补折算=$recalcCount',
      );
      return recalcCount;
    } catch (error, stackTrace) {
      logger.warning('LedgerActions', '本地刷新补折算失败(非致命): $error', stackTrace);
      return 0;
    }
  }

  /// 一键补折算：先刷新各账本本位币的全量汇率，再按最新汇率重算全部交易，
  /// 返回重算笔数。
  ///
  /// 汇率源失败只降级为「用已有缓存汇率重算」，不阻断重算。
  Future<int> recalcForeignTxWithLatestRates(String ledgerId) async {
    await refreshExchangeRates(read: ref.read, force: true);
    return recomputeForeignTx(ledgerId);
  }

  /// 换币与同次表单的名称、账期和分摊开关原子提交，重算失败整笔回滚。
  Future<int> changeCurrency({
    required String ledgerId,
    required String currency,
    String? name,
    int? monthStartDay,
    bool? aaEnabled,
  }) async {
    final identity = _identity();
    try {
      return await ref.read(syncCoordinatorProvider).runDataMutation(() async {
        _requireIdentity(identity);
        final repository = _repo;
        return repository.runInTransaction(() async {
          final ledger = await repository.getLedgerById(ledgerId);
          if (ledger == null) throw StateError('账本暂不可用，请稍后重试');
          await repository.requireActiveLedger(ledgerId);
          _requireIdentity(identity);
          await repository.updateLedger(
            id: ledgerId,
            currency: currency,
            name: name,
            monthStartDay: monthStartDay,
            aaEnabled: aaEnabled,
          );
          final count = ledger.currency.toUpperCase() == currency.toUpperCase()
              ? 0
              : await repository.recalcNativeAmountsForLedger(
                  ledgerId,
                  currency,
                  previousBase: ledger.currency,
                );
          _requireIdentity(identity);
          return count;
        });
      });
    } catch (error, stackTrace) {
      logger.error(
        'LedgerActions',
        '账本换币与表单保存失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}

/// 账本用例编排 provider。
final ledgerActionsProvider = Provider<LedgerActions>(
  (ref) => LedgerActions(ref),
);

/// 当前云账号 id；账本 UI 只消费此应用层身份快照。
final currentLedgerAccountIdProvider = Provider<String?>((ref) {
  return ref.watch(currentAccountIdProvider);
});
