/// 交易分摊展示模型。
class TransactionSplitDisplay {
  const TransactionSplitDisplay({required this.memberId, required this.amount});

  final String memberId;
  final String amount;
}

/// 交易编辑历史展示模型。
///
/// 本地历史直接使用已生成的 [summary]；云端历史保留原始 [changes]，
/// 展示时再按当前语言描述，切换语言不需要重新请求服务端。
class RecordEditHistoryDisplay {
  const RecordEditHistoryDisplay({
    required this.version,
    this.operatorMemberId,
    this.operatorDisplayName,
    this.summary,
    this.changes,
    required this.isCloud,
    required this.createdAt,
  });

  final int version;
  final String? operatorMemberId;
  final String? operatorDisplayName;
  final String? summary;
  final Object? changes;
  final bool isCloud;
  final DateTime createdAt;
}
