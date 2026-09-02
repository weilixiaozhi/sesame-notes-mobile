import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:sesame_notes/core/api/api_error_mapper.dart';

/// 构造带错误码的 DioException。
DioException _error(int status, String code) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  response: Response(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: status,
    data: {'code': code, 'message': 'x', 'request_id': 'req-1'},
  ),
);

void main() {
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
  });

  group('extractRequestId', () {
    test('从错误响应提取 request_id（日志用）', () {
      expect(extractRequestId(_error(400, 'X')), 'req-1');
      expect(extractRequestId(Exception('x')), isNull);
    });
  });
}
