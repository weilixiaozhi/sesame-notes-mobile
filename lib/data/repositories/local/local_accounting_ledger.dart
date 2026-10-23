import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/db.dart';
import 'local_ledger_repository.dart';

import 'local_accounting_context.dart';

/// ledger 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalLedgerOperations on LocalAccountingContext {
  /// 提供 watchLedgers 对应的持久化能力。
  Stream<List<Ledger>> watchLedgers() => ledgerStore.watchLedgers();

  /// 提供 watchLedger 对应的持久化能力。
  Stream<Ledger?> watchLedger(String id) => ledgerStore.watchLedger(id);

  /// 提供 getAllLedgers 对应的持久化能力。
  @override
  Future<List<Ledger>> getAllLedgers() => ledgerStore.getAllLedgers();

  /// 提供 getLedgerById 对应的持久化能力。
  @override
  Future<Ledger?> getLedgerById(String id) => ledgerStore.getLedgerById(id);

  /// 修改本人归档状态，失败时记录详情并由调用方展示错误。
  @override
  Future<void> setLedgerArchived(
    String id,
    bool archived, {
    String? deviceId,
  }) => guard(
    'setLedgerArchived($id, archived=$archived)',
    () => ledgerStore.setLedgerArchived(id, archived, deviceId: deviceId),
  );

  /// 提供 getCountsForLedger 对应的持久化能力。
  @override
  Future<({int dayCount, int txCount})> getCountsForLedger({
    required String ledgerId,
  }) => ledgerStore.getCountsForLedger(ledgerId: ledgerId);

  /// 提供 getLedgerStats 对应的持久化能力。
  @override
  Future<({double expenseTotal, int transactionCount})> getLedgerStats({
    required String ledgerId,
    List<TransactionSnapshot>? transactions,
  }) => ledgerStore.getLedgerStats(
    ledgerId: ledgerId,
    transactions: transactions,
  );

  /// 提供 getAllLedgerStats 对应的持久化能力。
  @override
  Future<Map<String, ({double expenseTotal, int transactionCount})>>
  getAllLedgerStats() => ledgerStore.getAllLedgerStats();

  /// 提供 createLedger 对应的持久化能力。
  @override
  Future<String> createLedger({
    required String name,
    String currency = 'CNY',
    String storageMode = 'cloud',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
  }) => ledgerStore.createLedger(
    name: name,
    currency: currency,
    storageMode: storageMode,
    aaEnabled: aaEnabled,
    monthStartDay: monthStartDay,
    localSelfId: localSelfId,
  );

  /// 确认或更换云同步身份，失败时记录日志并保留原绑定。
  Future<void> updateLedgerSyncId({
    required String id,
    required String syncId,
  }) => guard(
    'updateLedgerSyncId($id)',
    () => ledgerStore.updateLedgerSyncId(id: id, syncId: syncId),
  );

  /// 提供 updateLedgerStorageMode 对应的持久化能力。
  Future<void> updateLedgerStorageMode({
    required String id,
    required String storageMode,
  }) => ledgerStore.updateLedgerStorageMode(id: id, storageMode: storageMode);

  /// 解除云端绑定，失败时记录日志并由原事务保留账本状态。
  @override
  Future<void> detachFromCloud(String id) =>
      guard('detachFromCloud($id)', () => ledgerStore.detachFromCloud(id));

  /// 本地状态保护 Fork（见 [LocalLedgerRepository.protectCloudLedgerToLocalFork]）。
  @override
  Future<String> protectCloudLedgerToLocalFork({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    String? currentAccountId,
  }) => ledgerStore.protectCloudLedgerToLocalFork(
    sourceLedgerId: sourceLedgerId,
    targetLedgerId: targetLedgerId,
    localSelfId: localSelfId,
    currentAccountId: currentAccountId,
  );

  /// 复制云本为可独立编辑的本机本，成员、周期模板与历史一起复制。
  Future<String> copyCloudLedgerToLocal({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String currentAccountId,
    String? originSyncId,
  }) => ledgerStore.copyCloudLedgerToLocal(
    sourceLedgerId: sourceLedgerId,
    newLedgerId: newLedgerId,
    localSelfId: localSelfId,
    currentAccountId: currentAccountId,
    originSyncId: originSyncId,
  );

  /// 云转本地移动的隐藏 Fork（见 [LocalLedgerRepository.forkCloudLedgerToLocalPendingMove]）。
  Future<String> forkCloudLedgerToLocalPendingMove({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String currentAccountId,
    String? originSyncId,
  }) => ledgerStore.forkCloudLedgerToLocalPendingMove(
    sourceLedgerId: sourceLedgerId,
    newLedgerId: newLedgerId,
    localSelfId: localSelfId,
    currentAccountId: currentAccountId,
    originSyncId: originSyncId,
  );

  /// 读取待发布的隐藏 Fork（云转本地 intent 恢复扫描用）。
  @override
  Future<List<Ledger>> getPendingLocalMoveForks() =>
      ledgerStore.getPendingLocalMoveForks();

  /// 提供 copyLedgerData 对应的持久化能力。
  Future<void> copyLedgerData({
    required String sourceLedgerId,
    required String targetLedgerId,
  }) => guard(
    'copyLedgerData',
    () => ledgerStore.copyLedgerData(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: targetLedgerId,
    ),
  );

  /// 更新账本元数据；[recordChanges] 为 false 时不登记同步变更
  /// （恢复导入等数据回填路径用，禁止备份元数据反向推云）。
  @override
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) => ledgerStore.updateLedger(
    id: id,
    name: name,
    currency: currency,
    monthStartDay: monthStartDay,
    aaEnabled: aaEnabled,
    recordChanges: recordChanges,
  );

  /// 删除账本；云账本由子仓储保留 tombstone 与最终 delete mutation。
  Future<void> deleteLedger(String id) =>
      guard('deleteLedger($id)', () => ledgerStore.deleteLedger(id));

  /// 退出登录时清除指定账号的云账本缓存及关联数据。
  @override
  Future<void> purgeAllCloudLedgers({required String accountId}) =>
      ledgerStore.purgeAllCloudLedgers(accountId: accountId);

  /// 单账本 purge：清除一本账本及其全部关联本地数据
  /// （见 [LocalLedgerRepository.purgeLedger]，退出/删除共享账本用）。
  @override
  Future<void> purgeLedger(String id) =>
      guard('purgeLedger($id)', () => ledgerStore.purgeLedger(id));
}
