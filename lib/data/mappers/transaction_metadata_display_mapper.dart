import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';

/// 把 Drift 分摊行转换为页面展示模型。
extension TransactionSplitDisplayMapper on TransactionSplitSnapshot {
  /// 只复制页面渲染 AA 分摊所需字段。
  TransactionSplitDisplay toDisplay() =>
      TransactionSplitDisplay(memberId: memberId, amount: amount);
}

/// 把 Drift 编辑历史行转换为页面展示模型。
extension RecordEditHistoryDisplayMapper on RecordEditHistorySnapshot {
  /// 只复制页面渲染编辑记录所需字段。
  RecordEditHistoryDisplay toDisplay() => RecordEditHistoryDisplay(
    version: version,
    operatorMemberId: operatorMemberId,
    summary: summary,
    createdAt: createdAt,
  );
}
