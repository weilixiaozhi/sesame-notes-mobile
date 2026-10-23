/// AA 指定分摊输入(契约 TransactionSplit 的本地表达)。
/// 参与人统一引用成员 id(member_id);amount 为规范化 Decimal 字符串。
/// 同步载荷直接使用 member_id，与服务端成员单轨契约一致。
class TransactionSplitInput {
  final String memberId;
  final String amount;

  /// 保存参与人和已规范化的金额字符串。
  const TransactionSplitInput({required this.memberId, required this.amount});
}
