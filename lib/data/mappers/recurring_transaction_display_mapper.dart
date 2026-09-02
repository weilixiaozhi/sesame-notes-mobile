import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';

/// 把 Drift 周期账单行转换为页面展示模型。
extension RecurringTransactionDisplayMapper on RecurringTransaction {
  /// 只复制页面实际使用的字段，避免数据库 schema 向 UI 扩散。
  RecurringTransactionDisplay toDisplay() => RecurringTransactionDisplay(
    id: id,
    ledgerId: ledgerId,
    txType: txType,
    amount: amount,
    categoryId: categoryId,
    note: note,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    startDate: startDate,
    endDate: endDate,
    lastGeneratedDate: lastGeneratedDate,
    enabled: enabled,
  );
}
