import 'dart:async';
import 'dart:io';

import 'package:built_value/serializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';

/// 构造带错误码的 DioException。
DioException _error(int status, String code) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: {'code': code, 'message': 'x', 'request_id': 'req-1'},
  ),
);

/// 构造响应体无法解析出业务错误码的 DioException（如反代返回的 HTML）。
DioException _errorBody(int status, Object body) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: body,
  ),
);

void main() {
  test('未配置账号服务与断网、凭据错误使用独立语义', () {
    expect(
      mapApiError(const ServerNotConfiguredException()),
      ApiErrorKind.serverNotConfigured,
    );
    expect(mapApiError(const SocketException('offline')), ApiErrorKind.network);
    expect(
      mapApiError(_error(401, 'INVALID_CREDENTIALS')),
      ApiErrorKind.invalidCredentials,
    );
  });
  test('云操作错误区分断网、权限、服务端和本地保存失败，不泄露内部异常', () {
    expect(
      cloudOperationErrorMessage(
        DioException(
          requestOptions: RequestOptions(path: '/invite'),
          type: DioExceptionType.connectionError,
        ),
      ),
      '网络连接出现问题，请之后再尝试',
    );
    expect(
      cloudOperationErrorMessage(_error(401, 'TOKEN_EXPIRED')),
      '登录状态已失效，请重新登录',
    );
    expect(
      cloudOperationErrorMessage(_error(403, 'FORBIDDEN')),
      '当前账号没有此操作权限，请确认账号或权限后再试',
    );
    expect(
      cloudOperationErrorMessage(_error(503, 'UNAVAILABLE')),
      '服务暂时不可用，请稍后重试',
    );
    expect(
      cloudOperationErrorMessage(
        _errorBody(412, ''),
        fallback: '本地修改仍保留，请重新下载',
      ),
      '本地修改仍保留，请重新下载',
    );
    expect(
      cloudOperationErrorMessage(
        StateError('SELECT secret'),
        fallback: '保存失败，未保存',
      ),
      '保存失败，未保存',
    );
  });
  group('安全同步操作失败', () {
    const target = SyncTarget('category', 'category-id');
    final deserialization = DeserializationError(
      {'password': 'PRIVATE_BODY_VALUE'},
      const FullType(String),
      StateError('PRIVATE_BODY_VALUE'),
    );
    final scenarios = <(Object, String)>[
      (const SocketException('PRIVATE_BODY_VALUE'), 'NETWORK_UNAVAILABLE'),
      (TimeoutException('PRIVATE_BODY_VALUE'), 'NETWORK_UNAVAILABLE'),
      (
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.connectionError,
          message: 'PRIVATE_BODY_VALUE',
        ),
        'NETWORK_UNAVAILABLE',
      ),
      (_error(401, 'UNTRUSTED_SERVER_CODE'), 'AUTH_REQUIRED'),
      (_error(403, 'UNTRUSTED_SERVER_CODE'), 'PERMISSION_DENIED'),
      (
        _errorBody(503, {'message': 'PRIVATE_BODY_VALUE'}),
        'CLOUD_SERVICE_UNAVAILABLE',
      ),
      (const FormatException('PRIVATE_BODY_VALUE'), 'SYNC_DATA_UNREADABLE'),
      (deserialization, 'SYNC_DATA_UNREADABLE'),
      (
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          error: deserialization,
        ),
        'SYNC_DATA_UNREADABLE',
      ),
      (
        DioException(
          requestOptions: RequestOptions(path: '/x'),
          type: DioExceptionType.cancel,
          error: 'PRIVATE_BODY_VALUE',
        ),
        'SYNC_OPERATION_CANCELLED',
      ),
      (StateError('PRIVATE_BODY_VALUE'), 'SYNC_OPERATION_FAILED'),
      (Exception('PRIVATE_BODY_VALUE'), 'SYNC_OPERATION_FAILED'),
      (
        _errorBody(400, {'message': 'PRIVATE_BODY_VALUE'}),
        'SYNC_OPERATION_FAILED',
      ),
    ];
    for (final (error, code) in scenarios) {
      test('$code ${error.runtimeType} 保留原因码与目标，不显示底层原文', () {
        final failure = cloudOperationFailure(error, target: target);
        expect(failure.code, code);
        expect(failure.target, target);
        expect(failure.toString(), failure.message);
        expect(failure.message, isNot(contains('PRIVATE_BODY_VALUE')));
        expect(failure.message, isNot(contains('UNTRUSTED_SERVER_CODE')));
        expect(failure.message, isNot(contains('category-id')));
      });
    }
    test('已有安全错误原样保留，补目标不覆盖既有实体身份', () {
      const identified = SyncOperationFailure(
        code: 'CLOUD_OWNERSHIP_MISSING',
        message: '请重新同步账本',
        target: target,
      );
      expect(
        identical(
          cloudOperationFailure(
            identified,
            target: const SyncTarget('ledger', 'different'),
          ),
          identified,
        ),
        isTrue,
      );
      const unidentified = SyncOperationFailure(
        code: 'CLOUD_OWNERSHIP_MISSING',
        message: '请重新同步账本',
      );
      expect(
        identical(cloudOperationFailure(unidentified), unidentified),
        isTrue,
      );
      final completed = cloudOperationFailure(unidentified, target: target);
      expect(
        (completed.code, completed.message, completed.target),
        (unidentified.code, unidentified.message, target),
      );
      expect(cloudOperationErrorMessage(identified), identified.message);
    });
    test('默认同步提示与非同步兼容提示分开，未知异常只使用调用方固定文案', () {
      final raw = StateError('PRIVATE_BODY_VALUE');
      expect(cloudOperationFailure(raw).message, '同步未完成，数据已保存在本机，请重试');
      expect(cloudOperationErrorMessage(raw), '操作失败，请稍后重试');
      expect(cloudOperationErrorMessage(raw, fallback: '本地保存尚未完成'), '本地保存尚未完成');
    });
  });
  group('mapApiError 稳定语义映射', () {
    test('凭据错误/已注册/当前密码错误/限流/刷新失效分别映射', () {
      expect(
        mapApiError(_error(401, 'INVALID_CREDENTIALS')),
        ApiErrorKind.invalidCredentials,
      );
      expect(
        mapApiError(_error(409, 'PHONE_ALREADY_REGISTERED')),
        ApiErrorKind.phoneAlreadyRegistered,
      );
      expect(
        mapApiError(_error(400, 'CURRENT_PASSWORD_INVALID')),
        ApiErrorKind.currentPasswordInvalid,
      );
      expect(
        mapApiError(_error(429, 'RATE_LIMITED')),
        ApiErrorKind.rateLimited,
      );
      expect(
        mapApiError(_error(401, 'INVALID_REFRESH_TOKEN')),
        ApiErrorKind.invalidRefreshToken,
      );
      expect(
        mapApiError(_error(409, 'ALREADY_LEDGER_OWNER')),
        ApiErrorKind.alreadyLedgerOwner,
      );
    });

    test('连接错误/超时 → network；5xx → server；其他 → other', () {
      expect(
        mapApiError(
          DioException(
            requestOptions: RequestOptions(path: '/x'),
            type: DioExceptionType.connectionTimeout,
          ),
        ),
        ApiErrorKind.network,
      );
      expect(mapApiError(_error(500, 'REGISTER_FAILED')), ApiErrorKind.server);
      expect(mapApiError(Exception('x')), ApiErrorKind.other);
      expect(mapApiError(_error(400, 'UNKNOWN_CODE')), ApiErrorKind.other);
    });

    test('404/响应体解析不出错误码的 4xx → server（明确文案而非兜底）', () {
      // 后端未部署时反代返回 HTML 404，不能落进 other 的兜底文案
      expect(
        mapApiError(_errorBody(404, '<html>404 Not Found</html>')),
        ApiErrorKind.server,
      );
      expect(
        mapApiError(_errorBody(400, 'gateway plain text')),
        ApiErrorKind.server,
      );
    });
  });
}
