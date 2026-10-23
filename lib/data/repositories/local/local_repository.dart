import 'local_accounting_context.dart';
import 'local_accounting_ledger.dart';
import 'local_accounting_category.dart';
import 'local_accounting_transaction.dart';
import 'local_accounting_statistics.dart';
import 'local_accounting_recurring.dart';
import 'local_accounting_currency.dart';
import 'local_accounting_member.dart';
import 'local_accounting_maintenance.dart';

/// 本地记账能力的装配入口，各实现共用一个数据库连接和变更登记器。
class LocalRepository extends LocalAccountingContext
    with
        LocalLedgerOperations,
        LocalCategoryOperations,
        LocalTransactionOperations,
        LocalStatisticsOperations,
        LocalRecurringOperations,
        LocalCurrencyOperations,
        LocalMemberOperations,
        LocalMaintenanceOperations {
  /// 注入账号身份与变更登记能力，事务由共用上下文管理。
  LocalRepository(super.db, {super.changeTracker, super.accountIdGetter});
}
