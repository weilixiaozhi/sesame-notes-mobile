import 'action_error_boundary.dart';

/// 查询结果只交给发起时的账号和会话，迟到读取不能进入新会话的界面。
Future<T> readAccountSnapshot<T>({
  required String area,
  required String? accountId,
  required String? Function() currentAccountId,
  required int Function() currentGeneration,
  required Future<T> Function() read,
}) => runApplicationAction(area, '读取业务快照', () async {
  final generation = currentGeneration();

  /// 异步读取前后使用同一身份，账号切换与同账号重新登录都使结果失效。
  void verify() {
    if (currentAccountId() != accountId || currentGeneration() != generation) {
      throw StateError('QUERY_SESSION_CHANGED');
    }
  }

  verify();
  final result = await read();
  verify();
  return result;
});
