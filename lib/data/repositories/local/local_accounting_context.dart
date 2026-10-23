import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/contracts/currency_rate_repository.dart';
import 'package:sesame_notes/data/services/transaction_currency_recalculator.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'local_ledger_repository.dart';
import 'local_transaction_repository.dart';
import 'local_category_repository.dart';
import 'local_statistics_repository.dart';
import 'local_recurring_transaction_repository.dart';
import 'local_exchange_rate_repository.dart';
import 'local_member_repository.dart';

/// 所有本地记账能力共享连接、事务、账号和变更登记，不持有界面状态。
abstract class LocalAccountingContext
    implements
        CurrencyRateRepository,
        AccountLedgerRepository,
        CategoryRepository,
        LedgerRepository,
        AccountingTransferRepository,
        StatisticsRepository,
        TransactionRepository {
  /// 底层数据库实例
  final SesameDatabase db;

  /// 可选的变更追踪器（供子仓储写路径登记同步变更）。
  ChangeRecorder? changeTracker;

  /// 当前云账号 userId（null = 未登录本地域），用于同步实体账号域与
  /// 确定性主键，确保账号切换时可完整清理当前账号数据。
  final String? Function()? accountIdGetter;

  /// 币种折算复用同一交易仓储及汇率上下文。
  late final currencyService = TransactionCurrencyRecalculator(
    db,
    transactionStore,
    this,
  );

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalLedgerRepository ledgerStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalTransactionRepository transactionStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalCategoryRepository categoryStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalStatisticsRepository statisticsStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalRecurringTransactionRepository recurringStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalExchangeRateRepository exchangeRateStore;

  /// 共享同一连接、账号和变更登记依赖。
  late final LocalLedgerMemberRepository memberStore;

  /// 在同一 Drift 事务内执行一组必须原子提交的仓储操作。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      db.transaction(action);

  /// 初始化当前账号的持久化上下文。
  LocalAccountingContext(this.db, {this.changeTracker, this.accountIdGetter}) {
    ledgerStore = LocalLedgerRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    transactionStore = LocalTransactionRepository(
      db,
      trackerGetter: () => changeTracker,
    );
    categoryStore = LocalCategoryRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    statisticsStore = LocalStatisticsRepository(db);
    recurringStore = LocalRecurringTransactionRepository(
      db,
      trackerGetter: () => changeTracker,
    );
    exchangeRateStore = LocalExchangeRateRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    memberStore = LocalLedgerMemberRepository(
      db,
      trackerGetter: () => changeTracker,
    );
  }

  /// 最外层委托统一守卫：捕获并记录仓储异常后原样上抛。
  Future<T> guard<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, st) {
      logger.error('LocalRepository', '$operation 失败', e, st);
      rethrow;
    }
  }

  /// 跨能力协作所需的 deleteTransactionRowsByIds 端口。
  Future<int> deleteTransactionRowsByIds(Iterable<String> ids);

  /// 跨能力协作所需的 ensureCloudChangesCanBeRecorded 端口。
  Future<void> ensureCloudChangesCanBeRecorded(Iterable<Transaction> rows);

  /// 跨能力协作所需的 addTransaction 端口。
  @override
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

  /// 跨能力协作所需的 getLedgerById 端口。
  @override
  Future<Ledger?> getLedgerById(String id);

  /// 跨能力协作所需的 insertTransactionsBatchWithRelations 端口。
  Future<List<String>> insertTransactionsBatchWithRelations({
    required List<TransactionsCompanion> transactions,
    bool recordChanges = true,
  });

  /// 跨能力协作所需的 ledgerBaseCurrency 端口。
  @override
  Future<String> ledgerBaseCurrency(String ledgerId);

  /// 跨能力协作所需的 updateLastGeneratedDate 端口。
  Future<void> updateLastGeneratedDate(String id, DateTime date);
}
