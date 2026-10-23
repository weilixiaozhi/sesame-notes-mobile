import 'package:sesame_notes/core/logging/logger_service.dart';

/// 记录应用操作的脱敏错误与堆栈，保留异常类型供展示层映射友好提示。
Future<T> runApplicationAction<T>(
  String area,
  String operation,
  Future<T> Function() action,
) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    logger.error(area, '$operation失败', safeErrorSummary(error), stackTrace);
    rethrow;
  }
}
