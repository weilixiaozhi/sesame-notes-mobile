import 'package:sesame_notes/core/logging/logger_service.dart';

import '../../db.dart';

/// 读取账本行，**不过滤 tombstone**。
///
/// 已删除账本的历史数据仍按原口径可读：统计归桶与外币折算都要用它的本位币与
/// 每月起始日，过滤掉会让这些读取退化成"猜默认值"。行确实不存在时返回 null，
/// 由调用方按自身边界决定失败还是降级。
Future<Ledger?> findLedgerRow(SesameDatabase db, String ledgerId) => (db.select(
  db.ledgers,
)..where((row) => row.id.equals(ledgerId))).getSingleOrNull();

/// 读取账本的每月起始日（1–31）。
///
/// - 行存在（含 tombstone）：用该行周期；云端事件可能带入越界值，读取处统一
///   收敛到 1–31（当月无该日期取月末由展示层处理）；
/// - 行确实不存在：账本已被物理清理（外键级联同时清掉其交易），没有可归桶的
///   数据，按自然月降级并留痕——统计层对不存在的账本一贯返回空/0，不让整块
///   汇总因一次过期读取而失败。
Future<int> ledgerMonthStartDay(SesameDatabase db, String ledgerId) async {
  final row = await findLedgerRow(db, ledgerId);
  if (row == null) {
    logger.warning('LedgerLookup', '账本行不存在，每月起始日按自然月降级', ledgerId);
    return 1;
  }
  return row.monthStartDay.clamp(1, 31);
}
