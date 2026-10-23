import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:built_value/serializer.dart' show DeserializationError;
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/core/network/network_messages.dart';

export 'package:sesame_notes/core/network/network_messages.dart'
    show cloudNetworkErrorMessage;

/// 将网络、认证与读取失败转换为安全事实，既有明确原因和实体身份保持原样。
SyncOperationFailure cloudOperationFailure(
  Object error, {
  String fallback = '同步未完成，数据已保存在本机，请重试',
  SyncTarget? target,
}) {
  try {
    if (error is SyncOperationFailure) {
      if (error.target != null || target == null) return error;
      return SyncOperationFailure(
        code: error.code,
        message: error.message,
        target: target,
      );
    }
    if (mapApiError(error) == ApiErrorKind.serverNotConfigured) {
      return SyncOperationFailure(
        code: 'SERVER_NOT_CONFIGURED',
        message: '未配置服务器地址，请先配置服务器',
        target: target,
      );
    }
    if (mapApiError(error) == ApiErrorKind.network) {
      return SyncOperationFailure(
        code: 'NETWORK_UNAVAILABLE',
        message: cloudNetworkErrorMessage,
        target: target,
      );
    }
    if (error is DioException) {
      if (error.response?.statusCode == 401) {
        return SyncOperationFailure(
          code: 'AUTH_REQUIRED',
          message: '登录状态已失效，请重新登录',
          target: target,
        );
      }
      if (error.response?.statusCode == 403) {
        return SyncOperationFailure(
          code: 'PERMISSION_DENIED',
          message: '当前账号没有此操作权限，请确认账号或权限后再试',
          target: target,
        );
      }
      if ((error.response?.statusCode ?? 0) >= 500) {
        return SyncOperationFailure(
          code: 'CLOUD_SERVICE_UNAVAILABLE',
          message: '服务暂时不可用，请稍后重试',
          target: target,
        );
      }
      if (error.type == DioExceptionType.cancel) {
        return SyncOperationFailure(
          code: 'SYNC_OPERATION_CANCELLED',
          message: '操作已取消，需要时可重新尝试',
          target: target,
        );
      }
    }
    // SDK 可把解码错误包装进 Dio.error，外层 HTTP 200 也不能被误报成成功。
    final underlying = error is DioException ? error.error : error;
    if (underlying is FormatException || underlying is DeserializationError) {
      return SyncOperationFailure(
        code: 'SYNC_DATA_UNREADABLE',
        message: '同步数据无法读取，请检查记录后重新同步',
        target: target,
      );
    }
    return SyncOperationFailure(
      code: 'SYNC_OPERATION_FAILED',
      message: fallback,
      target: target,
    );
  } catch (_) {
    // 错误提示自身也必须安全失败，异常原文、响应正文和认证信息不能成为界面文案。
    return SyncOperationFailure(
      code: 'SYNC_OPERATION_FAILED',
      message: fallback,
      target: target,
    );
  }
}

/// 按实际错误展示安全文案，本地异常只能使用调用方给出的操作说明。
String cloudOperationErrorMessage(
  Object error, {
  String fallback = '操作失败，请稍后重试',
}) => cloudOperationFailure(error, fallback: fallback).message;

/// 统一的 API 错误语义：页面只消费稳定文案，不接触 Dio 原文或服务端堆栈。
enum ApiErrorKind {
  serverNotConfigured,
  invalidCredentials,
  phoneAlreadyRegistered,
  currentPasswordInvalid,
  phoneInvalid,
  passwordInvalid,
  displayNameInvalid,
  genderInvalid,
  rateLimited,
  invalidRefreshToken,
  alreadyLedgerOwner,
  network,
  server,
  other,
}

/// 把 Dio/OpenAPI 错误映射为稳定 UI 语义。
///
/// 设计意图：错误映射不得根据手机号是否存在改变登录文案；
/// 日志记录 request_id，UI 不展示服务端堆栈或 Dio 原文。
ApiErrorKind mapApiError(Object error) {
  if (error is ServerNotConfiguredException ||
      (error is DioException && error.error is ServerNotConfiguredException)) {
    return ApiErrorKind.serverNotConfigured;
  }
  if (error is SocketException || error is TimeoutException) {
    return ApiErrorKind.network;
  }
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
    // 4xx 但响应体解析不出业务错误码（如反代 HTML 404、网关纯文本）：
    // 服务端有响应但语义不可识别，归为服务端异常而不是 other 的兜底文案
    if (code.isEmpty && status != null && status >= 400) {
      return ApiErrorKind.server;
    }
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
      case 'ALREADY_LEDGER_OWNER':
        return ApiErrorKind.alreadyLedgerOwner;
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
