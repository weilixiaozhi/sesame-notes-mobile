import 'package:dio/dio.dart';

/// 统一的 API 错误语义：页面只消费稳定文案，不接触 Dio 原文或服务端堆栈。
enum ApiErrorKind {
  invalidCredentials,
  phoneAlreadyRegistered,
  currentPasswordInvalid,
  phoneInvalid,
  passwordInvalid,
  displayNameInvalid,
  genderInvalid,
  rateLimited,
  invalidRefreshToken,
  network,
  server,
  other,
}

/// 把 Dio/OpenAPI 错误映射为稳定 UI 语义。
///
/// 设计意图：错误映射不得根据手机号是否存在改变登录文案；
/// 日志记录 request_id，UI 不展示服务端堆栈或 Dio 原文。
ApiErrorKind mapApiError(Object error) {
  if (error is DioException) {
    // 传输层失败（断网/超时/连接拒绝）与 5xx 归为可重试类别
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiErrorKind.network;
    }
    final status = error.response?.statusCode;
    if (status != null && status >= 500) return ApiErrorKind.server;
    final code = _extractCode(error);
    switch (code) {
      case 'INVALID_CREDENTIALS':
        return ApiErrorKind.invalidCredentials;
      case 'PHONE_ALREADY_REGISTERED':
        return ApiErrorKind.phoneAlreadyRegistered;
      case 'CURRENT_PASSWORD_INVALID':
        return ApiErrorKind.currentPasswordInvalid;
      case 'PHONE_INVALID':
        return ApiErrorKind.phoneInvalid;
      case 'PASSWORD_INVALID':
        return ApiErrorKind.passwordInvalid;
      case 'DISPLAY_NAME_INVALID':
        return ApiErrorKind.displayNameInvalid;
      case 'GENDER_INVALID':
        return ApiErrorKind.genderInvalid;
      case 'RATE_LIMITED':
        return ApiErrorKind.rateLimited;
      case 'INVALID_REFRESH_TOKEN':
      case 'REFRESH_TOKEN_REQUIRED':
        return ApiErrorKind.invalidRefreshToken;
    }
  }
  return ApiErrorKind.other;
}

/// 从错误响应中提取稳定错误码；解析失败返回空串。
String _extractCode(DioException error) {
  try {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['code'] is String) {
      return data['code'] as String;
    }
  } catch (_) {}
  return '';
}

/// 提取错误响应的 request_id（日志用）。
String? extractRequestId(Object error) {
  if (error is! DioException) return null;
  try {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['request_id'] is String) {
      return data['request_id'] as String;
    }
  } catch (_) {}
  return null;
}
