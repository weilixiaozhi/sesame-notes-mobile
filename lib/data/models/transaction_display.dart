/// 页面使用的不可变交易展示模型。
class TransactionDisplay {
  const TransactionDisplay({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.happenedAt,
    this.note,
    this.categoryId,
    required this.excludeFromStats,
    required this.currencyCode,
    required this.nativeAmount,
    this.recurringId,
    this.createdByMemberId,
    this.lastEditedByMemberId,
    this.payerMemberId,
    this.aaMode,
    required this.version,
    this.serverRevision,
    this.lastEditedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ledgerId;
  final String txType;
  final String amount;
  final DateTime happenedAt;
  final String? note;
  final String? categoryId;
  final bool excludeFromStats;
  final String currencyCode;
  final String nativeAmount;
  final String? recurringId;
  final String? createdByMemberId;
  final String? lastEditedByMemberId;
  final String? payerMemberId;
  final int? aaMode;
  final int version;
  final int? serverRevision;
  final DateTime? lastEditedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
