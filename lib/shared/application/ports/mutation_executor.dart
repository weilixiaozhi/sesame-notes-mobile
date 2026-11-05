/// 账号转换或恢复期间暂停本机写入，调用方可以保留草稿并稍后重试。
class DataMutationPausedException extends StateError {
  /// 固定提示不包含账号资料、请求载荷或底层异常内容。
  DataMutationPausedException(this.userMessage) : super(userMessage);

  final String userMessage;
}

/// 本机写入的生命周期端口：保护账号切换与恢复，保持离线写入独立于网络队列。
abstract interface class MutationExecutor {
  /// 在当前身份的本机队列中执行一次完整用例，调用方在内部建立数据库事务。
  Future<T> runDataMutation<T>(Future<T> Function() action);
}
