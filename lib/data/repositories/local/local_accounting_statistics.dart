import 'package:sesame_notes/data/db.dart';

import 'local_accounting_context.dart';

/// statistics 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalStatisticsOperations on LocalAccountingContext {
  /// 批量读取统计所需分摊关系，与单笔编辑共用底层交易仓储。
  @override
  Future<Map<String, List<TransactionSplit>>>
  getTransactionSplitsByTransactionIds(Iterable<String> transactionIds) =>
      transactionStore.getTransactionSplitsByTransactionIds(transactionIds);

  /// 提供 totalsByCategoryWithHierarchy 对应的持久化能力。
  @override
  Future<
    List<
      ({
        String? id,
        String name,
        String? icon,
        String? parentId,
        int level,
        double total,
      })
    >
  >
  totalsByCategoryWithHierarchy({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => statisticsStore.totalsByCategoryWithHierarchy(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  /// 提供 totalsByDay 对应的持久化能力。
  @override
  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => statisticsStore.totalsByDay(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  /// 提供 earliestExpenseDate 对应的持久化能力。
  @override
  Future<DateTime?> earliestExpenseDate({required String ledgerId}) =>
      statisticsStore.earliestExpenseDate(ledgerId: ledgerId);

  /// 提供 latestExpenseDate 对应的持久化能力。
  @override
  Future<DateTime?> latestExpenseDate({required String ledgerId}) =>
      statisticsStore.latestExpenseDate(ledgerId: ledgerId);

  /// 提供 hasAnyExpenseTx 对应的持久化能力。
  @override
  Future<bool> hasAnyExpenseTx({required String ledgerId}) =>
      statisticsStore.hasAnyExpenseTx(ledgerId: ledgerId);

  /// 提供 totalsInRange 对应的持久化能力。
  Future<double> totalsInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) =>
      statisticsStore.totalsInRange(ledgerId: ledgerId, start: start, end: end);

  /// 提供 monthlyTotals 对应的持久化能力。
  @override
  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) => statisticsStore.monthlyTotals(ledgerId: ledgerId, month: month);

  /// 提供 todayExpense 对应的持久化能力。
  @override
  Future<double> todayExpense({
    required String ledgerId,
    required DateTime now,
  }) => statisticsStore.todayExpense(ledgerId: ledgerId, now: now);

  /// 提供 weekExpense 对应的持久化能力。
  @override
  Future<double> weekExpense({
    required String ledgerId,
    required DateTime now,
  }) => statisticsStore.weekExpense(ledgerId: ledgerId, now: now);

  /// 提供 getSharedSyntheticCategoriesForLedger 对应的持久化能力。
  @override
  Future<Map<String, Category>> getSharedSyntheticCategoriesForLedger(
    String ledgerId,
  ) => statisticsStore.getSharedSyntheticCategoriesForLedger(ledgerId);
}
