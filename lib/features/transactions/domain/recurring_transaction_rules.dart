/// 周期账单的输入校验与保存契约：纯函数层，不依赖 UI 与数据库。
library;

import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';

/// 金额编辑允许至多 28 位整数与 10 位小数，空值和末尾小数点仅用于输入中间态。
bool isValidRecurringAmountInput(String text) =>
    RegExp(r'^\d{0,28}(?:\.\d{0,10})?$').hasMatch(text);

/// 保留完整十进制精度，拒绝零、负数、科学计数法和超出契约范围的金额。
String? normalizeRecurringAmount(String text) {
  final value = text.trim();
  if (!RegExp(r'^\d{1,28}(?:\.\d{1,10})?$').hasMatch(value)) return null;
  final decimal = Decimal.tryParse(value);
  if (decimal == null || decimal <= Decimal.zero) return null;
  return decimal.toString();
}

/// 周期日期表示日历日期，UTC 仅作为跨端传输载体，不按设备时区转换。
DateTime recurringDateOnly(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

/// 新建模板默认「每月几号」取开始日期的日。
int defaultRecurringDayOfMonth(DateTime startDate) => startDate.day;

/// 未落库账本的周期配置草稿，完整保留星期、月份和时区。
RecurringTransactionDisplay buildRecurringDraft({
  required String id,
  required String amount,
  required String currencyCode,
  required String categoryId,
  required String? note,
  required String frequency,
  required int interval,
  required int? dayOfMonth,
  int? dayOfWeek,
  int? monthOfYear,
  String timeZone = 'UTC',
  required DateTime startDate,
  required DateTime? endDate,
  required bool enabled,
}) => RecurringTransactionDisplay(
  id: id,
  ledgerId: '',
  txType: 'expense',
  amount: amount,
  currencyCode: currencyCode,
  categoryId: categoryId,
  note: note,
  frequency: frequency,
  interval: interval,
  dayOfMonth: dayOfMonth,
  dayOfWeek: dayOfWeek,
  monthOfYear: monthOfYear,
  timeZone: timeZone,
  startDate: recurringDateOnly(startDate),
  endDate: endDate == null ? null : recurringDateOnly(endDate),
  enabled: enabled,
);
