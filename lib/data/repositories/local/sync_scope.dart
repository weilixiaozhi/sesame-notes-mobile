import 'package:drift/drift.dart';

/// 财务域使用正向实体集合，新增其他业务不会被空 ledger_id 误认为全局财务数据。
const accountingSyncEntityTypes = [
  'ledger',
  'ledger_archive',
  'transaction',
  'category',
  'recurring_transaction',
  'exchange_rate_override',
  'virtual_user',
  'member',
];

Expression<bool> accountingSyncScope(
  Expression<String> entityType,
  Expression<String> ledgerId,
  Iterable<String> ledgerIds,
) =>
    entityType.isIn(accountingSyncEntityTypes) &
    (ledgerId.isIn(ledgerIds) | ledgerId.isNull());
