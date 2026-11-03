import 'package:drift/drift.dart';

/// 财务域使用正向实体集合，新增其他业务不会被空 ledger_id 误认为全局财务数据。
const accountingSyncEntityTypes = [
  'ledger',
  'ledger_archive',
  'transaction',
  'category',
  'recurring_transaction',
  'exchange_rate_override',
  // 待处理成员队列按原实体标识展示拒收问题，保持账本问题提示完整。
  'virtual_user',
  'member',
];

/// 按实体与账本归属筛选财务变更，账号级财务变更允许没有账本 id。
Expression<bool> accountingSyncScope(
  Expression<String> entityType,
  Expression<String> ledgerId,
  Iterable<String> ledgerIds,
) =>
    entityType.isIn(accountingSyncEntityTypes) &
    (ledgerId.isIn(ledgerIds) | ledgerId.isNull());
