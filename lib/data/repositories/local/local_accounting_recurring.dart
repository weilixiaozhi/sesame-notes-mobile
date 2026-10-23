import 'package:sesame_notes/data/db.dart';

import 'local_accounting_context.dart';

/// recurring 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalRecurringOperations on LocalAccountingContext {
  /// 提供 getAllRecurringTransactions 对应的持久化能力。
  @override
  Future<List<RecurringTransaction>> getAllRecurringTransactions() =>
      recurringStore.getAllRecurringTransactions();

  /// 提供 getRecurringTransactionsByLedger 对应的持久化能力。
  @override
  Future<List<RecurringTransaction>> getRecurringTransactionsByLedger(
    String ledgerId,
  ) => recurringStore.getRecurringTransactionsByLedger(ledgerId);

  /// 提供 addRecurringTransaction 对应的持久化能力。
  @override
  Future<String> addRecurringTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    String? timeZone,
    required DateTime startDate,
    DateTime? endDate,
    bool enabled = true,
  }) => recurringStore.addRecurringTransaction(
    ledgerId: ledgerId,
    type: type,
    amount: amount,
    currencyCode: currencyCode,
    categoryId: categoryId,
    note: note,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    dayOfWeek: dayOfWeek,
    monthOfYear: monthOfYear,
    timeZone: timeZone,
    startDate: startDate,
    endDate: endDate,
    enabled: enabled,
  );

  /// 提供 updateRecurringTransaction 对应的持久化能力。
  @override
  Future<void> updateRecurringTransaction({
    required String id,
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    String? timeZone,
    required DateTime startDate,
    DateTime? endDate,
    bool? enabled,
    bool clearLastGeneratedDate = false,
  }) => recurringStore.updateRecurringTransaction(
    id: id,
    ledgerId: ledgerId,
    type: type,
    amount: amount,
    currencyCode: currencyCode,
    categoryId: categoryId,
    note: note,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    dayOfWeek: dayOfWeek,
    monthOfYear: monthOfYear,
    timeZone: timeZone,
    startDate: startDate,
    endDate: endDate,
    enabled: enabled,
    clearLastGeneratedDate: clearLastGeneratedDate,
  );

  /// 提供 deleteRecurringTransaction 对应的持久化能力。
  @override
  Future<void> deleteRecurringTransaction(String id) =>
      recurringStore.deleteRecurringTransaction(id);

  /// 提供 toggleRecurringTransaction 对应的持久化能力。
  Future<void> toggleRecurringTransaction(String id, bool enabled) =>
      recurringStore.toggleRecurringTransaction(id, enabled);

  /// 提供 updateLastGeneratedDate 对应的持久化能力。
  @override
  Future<void> updateLastGeneratedDate(String id, DateTime date) => guard(
    'updateLastGeneratedDate recurring=$id',
    () => recurringStore.updateLastGeneratedDate(id, date),
  );

  /// 提供 watchAllRecurringTransactions 对应的持久化能力。
  @override
  Stream<List<RecurringTransaction>> watchAllRecurringTransactions() =>
      recurringStore.watchAllRecurringTransactions();

  /// 批量导入周期模板；恢复回填可关闭反向同步变更登记。
  Future<void> batchInsertRecurringTransactions(
    List<RecurringTransactionsCompanion> items, {
    bool recordChanges = true,
  }) => recurringStore.batchInsertRecurringTransactions(
    items,
    recordChanges: recordChanges,
  );
}
