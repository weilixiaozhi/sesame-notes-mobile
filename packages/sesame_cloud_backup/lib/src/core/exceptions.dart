/// 云同步异常基类。
///
/// [originalError] 保留原始异常，便于日志排查；上层可按类型区分失败阶段。
class CloudSyncException implements Exception {
  final String message;
  final dynamic originalError;

  CloudSyncException(this.message, [this.originalError]);

  /// 普通日志只输出业务提示，原始异常通过字段读取，避免暴露底层请求中的凭据。
  @override
  String toString() => 'CloudSyncException: $message';
}

/// 用户未登录时抛出。
class CloudNotAuthenticatedException extends CloudSyncException {
  CloudNotAuthenticatedException([String? message])
      : super(message ?? 'User not authenticated');
}

/// 云服务配置无效时抛出。
class CloudConfigurationException extends CloudSyncException {
  CloudConfigurationException(super.message, [super.originalError]);
}

/// 存储操作失败时抛出。
class CloudStorageException extends CloudSyncException {
  /// HTTP 状态码（可选），供调用方区分资源缺失、权限不足与服务端故障。
  final int? statusCode;

  /// 原始失败位置独立于友好文案保存，不依赖异常字符串传递诊断信息。
  final StackTrace? originalStackTrace;

  /// 内层操作已经写过诊断时，外层不会重复记录同一次失败。
  final bool diagnosticsReported;

  CloudStorageException(super.message, [super.originalError, this.statusCode])
      : originalStackTrace = null,
        diagnosticsReported = false;

  /// 构造保留底层原因及失败位置的存储异常。
  CloudStorageException.withDiagnostics(
    String message, {
    required Object originalError,
    required this.originalStackTrace,
    this.statusCode,
    this.diagnosticsReported = false,
  }) : super(message, originalError);

  /// UI 或普通日志只能得到固定文案与状态码，凭据及响应正文不参与格式化。
  @override
  String toString() =>
      'CloudStorageException: $message${statusCode == null ? '' : ' (HTTP $statusCode)'}';
}

/// 认证操作失败时抛出。
class CloudAuthException extends CloudSyncException {
  /// 服务端结构化错误码（如 Supabase 的 `invalid_credentials`），
  /// 供上层按语义映射文案；非结构化来源为 null。
  final String? code;

  CloudAuthException(super.message, [super.originalError, this.code]);
}

/// 条件创建发现同名对象；调用方须换用独立路径，不得覆盖已有备份。
class CloudFileAlreadyExistsException implements Exception {
  /// 保留单独的冲突类型，供备份用例选择新的远程路径。
  const CloudFileAlreadyExistsException();
}
