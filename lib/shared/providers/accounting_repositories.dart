import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 账号恢复与迁移的数据端口，复用同一组合仓储与事务上下文。
final accountDataAccessProvider = Provider<AccountLedgerRepository>(
  (ref) => ref.watch(repositoryProvider),
);

/// 纯分类查询直接使用现有分类仓储，与写入协作共用连接和账号来源。
final categoryQueriesProvider = Provider<CategoryQueryRepository>(
  (ref) => ref.watch(repositoryProvider).categoryStore,
);

/// 分类写入和关联交易协作端口，复用同一事务与同步变更登记。
final categoryDataAccessProvider = Provider<CategoryRepository>(
  (ref) => ref.watch(repositoryProvider),
);

/// 账本与成员管理的数据端口，复用同一组合仓储与事务上下文。
final ledgerDataAccessProvider = Provider<LedgerRepository>(
  (ref) => ref.watch(repositoryProvider),
);

/// 账单导入导出的数据端口，复用同一组合仓储与事务上下文。
final transferDataAccessProvider = Provider<AccountingTransferRepository>(
  (ref) => ref.watch(repositoryProvider),
);

/// 统计与分摊查询的数据端口，复用同一组合仓储与事务上下文。
final statisticsDataAccessProvider = Provider<StatisticsRepository>(
  (ref) => ref.watch(repositoryProvider),
);

/// 记账、周期与汇率的数据端口，复用同一组合仓储与事务上下文。
final transactionDataAccessProvider = Provider<TransactionRepository>(
  (ref) => ref.watch(repositoryProvider),
);
