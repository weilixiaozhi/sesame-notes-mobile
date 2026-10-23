import 'sync_issue.dart';

/// 同步操作的安全失败事实，原因由本机固定文案构造，不包含请求正文或原始响应。
class SyncOperationFailure implements Exception {
  /// 保留稳定原因码与可定位的实体身份，界面只展示安全文案。
  const SyncOperationFailure({
    required this.code,
    required this.message,
    this.target,
  });

  final String code;
  final String message;
  final SyncTarget? target;

  /// 异常文本只返回安全文案，不把实体身份、请求参数或底层堆栈拼入提示。
  @override
  String toString() => message;
}
