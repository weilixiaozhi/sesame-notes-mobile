/// 周期账单展示模型。
class RecurringTransactionDisplay {
  const RecurringTransactionDisplay({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    this.categoryId,
    this.note,
    required this.frequency,
    required this.interval,
    this.dayOfMonth,
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
    required this.enabled,
  });

  final String id;
  final String ledgerId;
  final String txType;
  final String amount;
  final String? categoryId;
  final String? note;
  final String frequency;
  final int interval;
  final int? dayOfMonth;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate;
  final bool enabled;
}
