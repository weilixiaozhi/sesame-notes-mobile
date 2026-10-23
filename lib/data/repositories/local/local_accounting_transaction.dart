import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';

import 'local_accounting_context.dart';

/// transaction 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalTransactionOperations on LocalAccountingContext {
  /// 提供 watchRecentTransactions 对应的持久化能力。
  Stream<List<Transaction>> watchRecentTransactions({
    required String ledgerId,
    int limit = 20,
  }) => transactionStore.watchRecentTransactions(
    ledgerId: ledgerId,
    limit: limit,
  );

  /// 提供 watchTransactionsInMonth 对应的持久化能力。
  Stream<List<Transaction>> watchTransactionsInMonth({
    required String ledgerId,
    required DateTime month,
  }) => transactionStore.watchTransactionsInMonth(
    ledgerId: ledgerId,
    month: month,
  );

  /// 提供 watchTransactionsWithCategoryAll 对应的持久化能力。
  @override
  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryAll({String? ledgerId}) =>
      transactionStore.watchTransactionsWithCategoryAll(ledgerId: ledgerId);

  /// 提供 watchExcludedAaTransactions 对应的持久化能力。
  @override
  Stream<List<({Transaction t, Category? category})>>
  watchExcludedAaTransactions(String ledgerId) =>
      transactionStore.watchExcludedAaTransactions(ledgerId);

  /// 提供 watchTransactionsWithCategoryInMonth 对应的持久化能力。
  @override
  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInMonth({
    required String ledgerId,
    required DateTime month,
  }) => transactionStore.watchTransactionsWithCategoryInMonth(
    ledgerId: ledgerId,
    month: month,
  );

  /// 提供 watchTransactionsWithCategoryInYear 对应的持久化能力。
  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInYear({
    required String ledgerId,
    required int year,
  }) => transactionStore.watchTransactionsWithCategoryInYear(
    ledgerId: ledgerId,
    year: year,
  );

  /// 提供 watchTransactionsForCategoryInRange 对应的持久化能力。
  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsForCategoryInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
    String? categoryId,
    required String type,
  }) => transactionStore.watchTransactionsForCategoryInRange(
    ledgerId: ledgerId,
    start: start,
    end: end,
    categoryId: categoryId,
    type: type,
  );

  /// 提供 insertTransactionsBatch 对应的持久化能力。
  Future<int> insertTransactionsBatch(
    List<TransactionsCompanion> items, {
    bool recordChanges = true,
  }) => transactionStore.insertTransactionsBatch(
    items,
    recordChanges: recordChanges,
  );

  /// 提供 deleteTransaction 对应的持久化能力。
  @override
  Future<void> deleteTransaction(String id) =>
      transactionStore.deleteTransaction(id);

  /// 在当前外层事务中逐笔调用交易删除入口，复用其历史清理与云 mutation 契约。
  @override
  Future<int> deleteTransactionRowsByIds(Iterable<String> ids) async {
    final idList = ids.toSet().toList();
    if (idList.isEmpty) return 0;
    final rows = await (db.select(
      db.transactions,
    )..where((t) => t.id.isIn(idList) & t.deletedAt.isNull())).get();
    await ensureCloudChangesCanBeRecorded(rows);
    for (final row in rows) {
      // 单笔入口把快照登记、交易删除和编辑历史清理置于同一 Drift 事务；
      // 外层事务再保证批量操作不会因中途登记失败而只删掉一部分。
      await transactionStore.deleteTransaction(row.id);
    }
    return rows.length;
  }

  /// 提供 getEditHistories 对应的持久化能力。
  @override
  Future<List<RecordEditHistory>> getEditHistories(String recordId) =>
      transactionStore.getEditHistories(recordId);

  /// 提供 appendEditHistory 对应的持久化能力。
  @override
  Future<int> appendEditHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  }) => transactionStore.appendEditHistory(
    recordId: recordId,
    version: version,
    operatorMemberId: operatorMemberId,
    summary: summary,
  );

  /// 提供 getTransactionById 对应的持久化能力。
  @override
  Future<Transaction?> getTransactionById(String id) =>
      transactionStore.getTransactionById(id);

  /// 读取交易的指定分摊行(关系表,aa_mode=2 时落行)。
  @override
  Future<List<TransactionSplit>> getTransactionSplits(String transactionId) =>
      transactionStore.getTransactionSplits(transactionId);

  /// 整批替换交易的指定分摊行(先删后插;null/空列表即清空)。
  Future<void> replaceTransactionSplits(
    String transactionId,
    List<TransactionSplitInput>? splits,
  ) => guard(
    'replaceTransactionSplits transaction=$transactionId',
    () => transactionStore.replaceTransactionSplitsAndRecord(
      transactionId,
      splits,
    ),
  );

  /// 批量插入数据库内部交易输入。
  @override
  Future<List<String>> insertTransactionsBatchWithRelations({
    required List<TransactionsCompanion> transactions,
    bool recordChanges = true,
  }) => transactionStore.insertTransactionsBatchWithRelations(
    transactions: transactions,
    recordChanges: recordChanges,
  );

  /// 提供 insertTransactionCompanion 对应的持久化能力。
  Future<String> insertTransactionCompanion(
    TransactionsCompanion item, {
    bool recordChanges = true,
  }) => transactionStore.insertTransactionCompanion(
    item,
    recordChanges: recordChanges,
  );

  /// 提供 transactionsWithCategoryAll 对应的持久化能力。
  @override
  Future<List<({Transaction t, Category? category})>>
  transactionsWithCategoryAll({String? ledgerId}) => guard(
    'transactionsWithCategoryAll',
    () => transactionStore.transactionsWithCategoryAll(ledgerId: ledgerId),
  );

  /// 提供 getRecentTransactionsWithCategory 对应的持久化能力。
  Future<List<({Transaction t, Category? category})>>
  getRecentTransactionsWithCategory({
    required String ledgerId,
    required int limit,
  }) => transactionStore.getRecentTransactionsWithCategory(
    ledgerId: ledgerId,
    limit: limit,
  );

  /// 提供 countByTypeInRange 对应的持久化能力。
  @override
  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => transactionStore.countByTypeInRange(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  /// 提供 getTransactionsByLedger 对应的持久化能力。
  @override
  Future<List<Transaction>> getTransactionsByLedger(String ledgerId) =>
      transactionStore.getTransactionsByLedger(ledgerId);

  /// 提供 getAaTransactionsByLedger 对应的持久化能力。
  @override
  Future<List<Transaction>> getAaTransactionsByLedger(String ledgerId) =>
      transactionStore.getAaTransactionsByLedger(ledgerId);

  /// 提供 getTransactionsByLedgerInRange 对应的持久化能力。
  Future<List<Transaction>> getTransactionsByLedgerInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) => transactionStore.getTransactionsByLedgerInRange(
    ledgerId: ledgerId,
    start: start,
    end: end,
  );

  /// 提供 getDailyTotalsByMonth 对应的持久化能力。
  @override
  Future<Map<String, double>> getDailyTotalsByMonth({
    required String ledgerId,
    required DateTime month,
  }) =>
      transactionStore.getDailyTotalsByMonth(ledgerId: ledgerId, month: month);

  /// 提供 getTransactionsByDate 对应的持久化能力。
  @override
  Future<List<({Transaction t, Category? category})>> getTransactionsByDate({
    required String ledgerId,
    required DateTime date,
  }) => transactionStore.getTransactionsByDate(ledgerId: ledgerId, date: date);
}
