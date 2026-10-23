import '../core/exceptions.dart';
import 'logger.dart';

/// 各后端统一抛出友好存储错误，同时保留原因、状态码与首次失败堆栈。
Never throwCloudStorageFailure({
  required String provider,
  required String operation,
  required String message,
  required Object error,
  required StackTrace stackTrace,
  CloudSyncLogger? logger,
  int? statusCode,
}) {
  final previous = error is CloudStorageException ? error : null;
  final originalStack = previous?.originalStackTrace ?? stackTrace;
  if (previous?.diagnosticsReported == true) {
    Error.throwWithStackTrace(previous!, originalStack);
  }
  final cause = previous?.originalError ?? error;
  final status = statusCode ?? previous?.statusCode;
  var reported = false;
  if (logger != null) {
    try {
      // 不格式化底层异常：SDK 异常字符串可能包含 URL、认证头及响应正文。
      logger.error(
        '$provider $operation失败: ${cause.runtimeType}'
        '${status == null ? '' : ' HTTP=$status'}\n$originalStack',
      );
      reported = true;
    } catch (_) {
      // 日志接收器失败不能覆盖需要交给调用方处理的原始传输故障。
    }
  }
  Error.throwWithStackTrace(
    CloudStorageException.withDiagnostics(
      message,
      originalError: cause,
      originalStackTrace: originalStack,
      statusCode: status,
      diagnosticsReported: reported,
    ),
    originalStack,
  );
}
