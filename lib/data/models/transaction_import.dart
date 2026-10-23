/// 导入交易的完整业务输入，数据库默认值由仓储适配，不暴露 Drift Companion。
class TransactionImport {
  /// 固定导入身份、金额和时间，写入时保持整批事务语义。
  const TransactionImport({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.happenedAt,
    required this.currencyCode,
    required this.nativeAmount,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.note,
    this.payerMemberId = '',
    this.createdByMemberId,
    this.lastEditedByMemberId,
  });

  final String id, ledgerId, txType, amount, currencyCode, nativeAmount;
  final DateTime happenedAt, createdAt, updatedAt;
  final String? categoryId, note, createdByMemberId, lastEditedByMemberId;
  final String payerMemberId;
}
