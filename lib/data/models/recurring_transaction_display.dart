/// 周期账单展示模型。
class RecurringTransactionDisplay {
  const RecurringTransactionDisplay({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.currencyCode,
    this.categoryId,
    this.note,
    required this.frequency,
    required this.interval,
    this.dayOfMonth,
    this.dayOfWeek,
    this.monthOfYear,
    this.timeZone = 'UTC',
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
    required this.enabled,
  });

  final String id;
  final String ledgerId;
  final String txType;
  final String amount;
  final String currencyCode;
  final String? categoryId;
  final String? note;
  final String frequency;
  final int interval;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final int? monthOfYear;
  final String timeZone;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate;
  final bool enabled;
}
