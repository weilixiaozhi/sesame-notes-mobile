/// 本机写入的生命周期端口：保护账号切换与恢复，保持离线写入独立于网络队列。
abstract interface class MutationExecutor {
  /// 在当前身份的本机队列中执行一次完整用例，调用方在内部建立数据库事务。
  Future<T> runDataMutation<T>(Future<T> Function() action);
}
