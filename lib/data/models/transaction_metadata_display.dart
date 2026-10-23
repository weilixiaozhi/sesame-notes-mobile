/// 交易分摊展示模型。
class TransactionSplitDisplay {
  const TransactionSplitDisplay({required this.memberId, required this.amount});

  final String memberId;
  final String amount;
}

/// 交易编辑历史展示模型。
class RecordEditHistoryDisplay {
  const RecordEditHistoryDisplay({
    required this.version,
    this.operatorMemberId,
    required this.summary,
    required this.createdAt,
  });

  final int version;
  final String? operatorMemberId;
  final String summary;
  final DateTime createdAt;
}
