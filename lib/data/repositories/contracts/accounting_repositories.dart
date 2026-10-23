import 'package:sesame_notes/data/models/transaction_import.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/models/ledger_directory_member.dart';

/// 账号恢复与迁移的最小数据能力，不能通过此接口访问其他仓储操作。
abstract interface class AccountLedgerRepository {
  /// 账号恢复与迁移所需的getAllLedgers能力。
  Future<List<LedgerSnapshot>> getAllLedgers();

  /// 账号恢复与迁移所需的getLedgerById能力。
  Future<LedgerSnapshot?> getLedgerById(String id);

  /// 账号恢复与迁移所需的getPendingLocalMoveForks能力。
  Future<List<LedgerSnapshot>> getPendingLocalMoveForks();

  /// 账号恢复与迁移所需的protectCloudLedgerToLocalFork能力。
  Future<String> protectCloudLedgerToLocalFork({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    String? currentAccountId,
  });

  /// 清除指定账号的本机云账本缓存与关联数据。
  Future<void> purgeAllCloudLedgers({required String accountId});

  /// 账号恢复与迁移所需的refreshMemberDisplayByAccount能力。
  Future<int> refreshMemberDisplayByAccount({
    required String userId,
    required String? displayName,
    required String? avatarUrl,
    required int avatarVersion,
  });
}

/// 官方模板创建、同 ID 恢复或待确认的结果；不能把云端待确认当作可见新增。
enum CanonicalCategoryInsertResult {
  created,
  restored,
  unchanged,
  nameConflict,
  parentUnavailable,
  pendingConfirmation,
  localRestoreRequired,
}

/// 分类写入、事务与关联交易协作端口，纯查询由独立只读接口提供。
abstract interface class CategoryRepository {
  /// 只按官方固定身份添加；恢复本机墓碑必须由用户明确确认。
  Future<CanonicalCategoryInsertResult> insertCanonicalCategory({
    required String id,
    required String name,
    required String kind,
    required int level,
    String? icon,
    int? sortOrder,
    String? parentId,
    bool restoreLocalDeleted = false,
  });

  /// 分类管理与选择所需的createCategory能力。
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int level = 1,
    String? parentId,
    bool recordChanges = true,
    String? ledgerId,
  });

  /// 分类管理与选择所需的createSubCategory能力。
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
    String? ledgerId,
  });

  /// 分类管理与选择所需的deleteCategoriesByIds能力。
  Future<void> deleteCategoriesByIds(List<String> ids);

  /// 分类管理与选择所需的deleteTransactionsByCategoryIds能力。
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds);

  /// 分类管理与选择所需的migrateCategoryTransactions能力。
  Future<int> migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  });

  /// 分类管理与选择所需的promoteSubCategoriesToTopLevel能力。
  Future<int> promoteSubCategoriesToTopLevel(String parentId);

  /// 分类管理与选择所需的runInTransaction能力。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 分类管理与选择所需的updateCategory能力。
  Future<void> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
    String? ledgerId,
  });

  /// 分类管理与选择所需的updateCategorySortOrders能力。
  Future<void> updateCategorySortOrders(
    List<({String id, int sortOrder})> updates,
  );
}

/// 账本与成员管理的最小数据能力，不能通过此接口访问其他仓储操作。
abstract interface class LedgerRepository {
  /// 账本与成员管理所需的addRecurringTransaction能力。
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
  });

  /// 账本与成员管理所需的applyMemberDirectorySnapshot能力。
  Future<void> applyMemberDirectorySnapshot({
    required String ledgerId,
    required List<LedgerDirectoryMember> members,
  });

  /// 账本与成员管理所需的clearLedgerTransactions能力。
  Future<int> clearLedgerTransactions(String ledgerId);

  /// 账本与成员管理所需的countUnconvertedForeignTx能力。
  Future<int> countUnconvertedForeignTx(String ledgerId);

  /// 账本与成员管理所需的createLedger能力。
  Future<String> createLedger({
    required String name,
    String currency = 'CNY',
    String storageMode = 'cloud',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
  });

  /// 账本与成员管理所需的createPlaceholderMember能力。
  Future<String> createPlaceholderMember({
    required String ledgerId,
    required String name,
    String? id,
  });

  /// 账本与成员管理所需的detachFromCloud能力。
  Future<void> detachFromCloud(String id);

  /// 账本与成员管理所需的getAllLedgerStats能力。
  Future<Map<String, ({double expenseTotal, int transactionCount})>>
  getAllLedgerStats();

  /// 账本与成员管理所需的getAllLedgers能力。
  Future<List<LedgerSnapshot>> getAllLedgers();

  /// 账本与成员管理所需的getLedgerById能力。
  Future<LedgerSnapshot?> getLedgerById(String id);

  /// 账本与成员管理所需的getLedgerStats能力。
  Future<({double expenseTotal, int transactionCount})> getLedgerStats({
    required String ledgerId,
    List<TransactionSnapshot>? transactions,
  });

  /// 账本与成员管理所需的purgeLedger能力。
  Future<void> purgeLedger(String id);

  /// 账本与成员管理所需的recalcNativeAmountsForLedger能力。
  Future<int> recalcNativeAmountsForLedger(
    String ledgerId,
    String newBase, {
    required String previousBase,
    bool recordChanges = true,
  });

  /// 账本与成员管理所需的recomputeForeignTxForLedger能力。
  Future<int> recomputeForeignTxForLedger(String ledgerId);

  /// 账本与成员管理所需的requireActiveLedger能力。
  Future<void> requireActiveLedger(String ledgerId);

  /// 账本与成员管理所需的runInTransaction能力。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 账本与成员管理所需的setLedgerArchived能力。
  Future<void> setLedgerArchived(String id, bool archived, {String? deviceId});

  /// 账本与成员管理所需的updateLedger能力。
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  });

  /// 账本与成员管理所需的updateMemberStatus能力。
  Future<void> updateMemberStatus({
    required String ledgerId,
    required String accountId,
    required String status,
  });
}

/// 账单导入导出的最小数据能力，不能通过此接口访问其他仓储操作。
abstract interface class AccountingTransferRepository {
  /// 账单导入导出所需的countPendingSyncChanges能力。
  Future<int> countPendingSyncChanges(String ledgerId);

  /// 账单导入导出所需的createCategory能力。
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int level = 1,
    String? parentId,
    bool recordChanges = true,
    String? ledgerId,
  });

  /// 账单导入导出所需的createSubCategory能力。
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
    String? ledgerId,
  });

  /// 账单导入导出所需的getLatestAutoRates能力。
  Future<List<ExchangeRateSnapshot>> getLatestAutoRates(String base);

  /// 账单导入导出所需的getLedgerById能力。
  Future<LedgerSnapshot?> getLedgerById(String id);

  /// 账单导入导出所需的getMemberById能力。
  Future<LedgerMemberSnapshot?> getMemberById(String id);

  /// 账单导入导出所需的getOverrides能力。
  Future<List<ExchangeRateOverrideSnapshot>> getOverrides(String base);

  /// 账单导入导出所需的getTransactionsByLedger能力。
  Future<List<TransactionSnapshot>> getTransactionsByLedger(String ledgerId);

  /// 账单导入导出所需的importTransactions能力。
  Future<List<String>> importTransactions({
    required List<TransactionImport> transactions,
    bool recordChanges = true,
  });

  /// 账单导入导出所需的recalcNativeAmountsForLedger能力。
  Future<int> recalcNativeAmountsForLedger(
    String ledgerId,
    String newBase, {
    required String previousBase,
    bool recordChanges = true,
  });

  /// 账单导入导出所需的requireActiveLedger能力。
  Future<void> requireActiveLedger(String ledgerId);

  /// 账单导入导出所需的runInTransaction能力。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 账单导入导出所需的transactionsWithCategoryAll能力。
  Future<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  transactionsWithCategoryAll({String? ledgerId});

  /// 账单导入导出所需的updateLedger能力。
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  });

  /// 账单导入导出所需的upsertAutoRates能力。
  Future<void> upsertAutoRates({
    required String base,
    required String rateDate,
    required Map<String, String> rates,
    required String source,
    required DateTime fetchedAt,
  });
}

/// 统计与分摊查询的最小数据能力，不能通过此接口访问其他仓储操作。
abstract interface class StatisticsRepository {
  /// 统计与分摊查询所需的countByTypeInRange能力。
  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  });

  /// 统计与分摊查询所需的createPlaceholderMember能力。
  Future<String> createPlaceholderMember({
    required String ledgerId,
    required String name,
    String? id,
  });

  /// 统计与分摊查询所需的deleteMember能力。
  Future<bool> deleteMember(String id);

  /// 统计与分摊查询所需的earliestExpenseDate能力。
  Future<DateTime?> earliestExpenseDate({required String ledgerId});

  /// 统计与分摊查询所需的getAaTransactionsByLedger能力。
  Future<List<TransactionSnapshot>> getAaTransactionsByLedger(String ledgerId);

  /// 统计与分摊查询所需的getCountsForLedger能力。
  Future<({int dayCount, int txCount})> getCountsForLedger({
    required String ledgerId,
  });

  /// 统计与分摊查询所需的getDailyTotalsByMonth能力。
  Future<Map<String, double>> getDailyTotalsByMonth({
    required String ledgerId,
    required DateTime month,
  });

  /// 统计与分摊查询所需的getEditHistories能力。
  Future<List<RecordEditHistorySnapshot>> getEditHistories(String recordId);

  /// 统计与分摊查询所需的getLedgerById能力。
  Future<LedgerSnapshot?> getLedgerById(String id);

  /// 统计与分摊查询所需的getMembersByLedger能力。
  Future<List<LedgerMemberSnapshot>> getMembersByLedger(String ledgerId);

  /// 统计与分摊查询所需的getSharedSyntheticCategoriesForLedger能力。
  Future<Map<String, CategorySnapshot>> getSharedSyntheticCategoriesForLedger(
    String ledgerId,
  );

  /// 批量读取指定交易的分摊行；无分摊行的交易不出现在结果中。
  Future<Map<String, List<TransactionSplitSnapshot>>>
  getTransactionSplitsByTransactionIds(Iterable<String> transactionIds);

  /// 统计与分摊查询所需的getTransactionsByDate能力。
  Future<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  getTransactionsByDate({required String ledgerId, required DateTime date});

  /// 统计与分摊查询所需的getTransactionsByLedger能力。
  Future<List<TransactionSnapshot>> getTransactionsByLedger(String ledgerId);

  /// 统计与分摊查询所需的hasAnyExpenseTx能力。
  Future<bool> hasAnyExpenseTx({required String ledgerId});

  /// 统计与分摊查询所需的latestExpenseDate能力。
  Future<DateTime?> latestExpenseDate({required String ledgerId});

  /// 统计与分摊查询所需的monthlyTotals能力。
  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  });

  /// 统计与分摊查询所需的renameMember能力。
  Future<void> renameMember({required String id, required String name});

  /// 统计与分摊查询所需的todayExpense能力。
  Future<double> todayExpense({
    required String ledgerId,
    required DateTime now,
  });

  /// 统计与分摊查询所需的totalsByCategoryWithHierarchy能力。
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
  });

  /// 统计与分摊查询所需的totalsByDay能力。
  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  });

  /// 统计与分摊查询所需的watchExcludedAaTransactions能力。
  Stream<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  watchExcludedAaTransactions(String ledgerId);

  /// 统计与分摊查询所需的watchMembersByLedger能力。
  Stream<List<LedgerMemberSnapshot>> watchMembersByLedger(String ledgerId);

  /// 统计与分摊查询所需的watchTransactionsWithCategoryAll能力。
  Stream<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  watchTransactionsWithCategoryAll({String? ledgerId});

  /// 统计与分摊查询所需的weekExpense能力。
  Future<double> weekExpense({required String ledgerId, required DateTime now});
}

/// 记账、周期与汇率的最小数据能力，不能通过此接口访问其他仓储操作。
abstract interface class TransactionRepository {
  /// 记账、周期与汇率所需的addRecurringTransaction能力。
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
  });

  /// 记账、周期与汇率所需的addTransaction能力。
  Future<String> addTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? categoryId,
    required DateTime happenedAt,
    String? note,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  });

  /// 记账、周期与汇率所需的appendEditHistory能力。
  Future<int> appendEditHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  });

  /// 记账、周期与汇率所需的countForeignCurrencyTx能力。
  Future<int> countForeignCurrencyTx(String ledgerId);

  /// 记账、周期与汇率所需的countUnconvertedForeignTx能力。
  Future<int> countUnconvertedForeignTx(String ledgerId);

  /// 记账、周期与汇率所需的deleteRecurringTransaction能力。
  Future<void> deleteRecurringTransaction(String id);

  /// 记账、周期与汇率所需的deleteTransaction能力。
  Future<void> deleteTransaction(String id);

  /// 记账、周期与汇率所需的generateRecurringTransaction能力。
  Future<String> generateRecurringTransaction({
    required RecurringTransactionSnapshot recurring,
    required DateTime happenedAt,
  });

  /// 记账、周期与汇率所需的getAllLedgers能力。
  Future<List<LedgerSnapshot>> getAllLedgers();

  /// 记账、周期与汇率所需的getAllRecurringTransactions能力。
  Future<List<RecurringTransactionSnapshot>> getAllRecurringTransactions();

  /// 记账、周期与汇率所需的getLastFetchedAt能力。
  Future<DateTime?> getLastFetchedAt(String base);

  /// 记账、周期与汇率所需的getLatestAutoRates能力。
  Future<List<ExchangeRateSnapshot>> getLatestAutoRates(String base);

  /// 记账、周期与汇率所需的getOverrides能力。
  Future<List<ExchangeRateOverrideSnapshot>> getOverrides(String base);

  /// 记账、周期与汇率所需的getRecurringTransactionsByLedger能力。
  Future<List<RecurringTransactionSnapshot>> getRecurringTransactionsByLedger(
    String ledgerId,
  );

  /// 记账、周期与汇率所需的getTransactionById能力。
  Future<TransactionSnapshot?> getTransactionById(String id);

  /// 记账、周期与汇率所需的getTransactionSplits能力。
  Future<List<TransactionSplitSnapshot>> getTransactionSplits(
    String transactionId,
  );

  /// 记账、周期与汇率所需的removeOverride能力。
  Future<void> removeOverride({required String base, required String quote});

  /// 记账、周期与汇率所需的requireActiveLedger能力。
  Future<void> requireActiveLedger(String ledgerId);

  /// 记账、周期与汇率所需的runInTransaction能力。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 记账、周期与汇率所需的setOverride能力。
  Future<void> setOverride({
    required String base,
    required String quote,
    required String rate,
  });

  /// 记账、周期与汇率所需的updateRecurringTransaction能力。
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
  });

  /// 记账、周期与汇率所需的updateTransaction能力。
  Future<int> updateTransaction({
    required String id,
    required String type,
    required String amount,
    String? categoryId,
    String? note,
    DateTime? happenedAt,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  });

  /// 记账、周期与汇率所需的upsertAutoRates能力。
  Future<void> upsertAutoRates({
    required String base,
    required String rateDate,
    required Map<String, String> rates,
    required String source,
    required DateTime fetchedAt,
  });

  /// 记账、周期与汇率所需的watchAllRecurringTransactions能力。
  Stream<List<RecurringTransactionSnapshot>> watchAllRecurringTransactions();

  /// 记账、周期与汇率所需的watchTransactionsWithCategoryInMonth能力。
  Stream<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  watchTransactionsWithCategoryInMonth({
    required String ledgerId,
    required DateTime month,
  });
}
