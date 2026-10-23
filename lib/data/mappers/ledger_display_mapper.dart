import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';

/// 将 Drift 账本行转换为 UI 可消费的不可变展示模型。
extension LedgerDisplayMapper on LedgerSnapshot {
  /// 将已发布的本地账本快照转换为展示模型，空账本同样是完整数据。
  LedgerDisplayItem toDisplayItem({
    int transactionCount = 0,
    double expenseTotal = 0,
  }) => LedgerDisplayItem(
    id: id,
    name: name,
    currency: currency,
    transactionCount: transactionCount,
    expenseTotal: expenseTotal,
    lastUpdated: updatedAt,
    isShared: memberCount > 1,
    memberCount: memberCount,
    myRole: role,
    monthStartDay: monthStartDay,
    aaEnabled: aaEnabled,
    selfMemberId: selfMemberId,
    storageMode: storageMode,
    archivedAt: archivedAt,
  );
}
