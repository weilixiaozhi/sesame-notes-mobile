// 401 单飞刷新拦截器测试。
//
// 需求锚点：
// - 并发 401 只触发一次 refresh（单飞）；
// - 刷新成功后原请求用新 token 重放并成功返回；
// - 刷新失败时放行原始 401，不吞错误；
// - 非 401 错误不触发刷新。
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/api/api_interceptors.dart';

void main() {
  group('AuthRefreshInterceptor', () {
    late Dio dio;
    int refreshCalls = 0;
    late Future<String> Function() refresh;

    setUp(() {
      refreshCalls = 0;
      refresh = () async {
        refreshCalls++;
        return 'new-token';
      };
      dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.interceptors.add(AuthRefreshInterceptor(dio: dio, refresh: refresh));
    });

    test('非 401 错误不触发刷新，原样放行', () async {
      dio.httpClientAdapter = _StatusAdapter(500, headers: {});

      await expectLater(
        dio.get<Map<String, dynamic>>('/ping'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            500,
          ),
        ),
      );
      expect(refreshCalls, 0, reason: '非 401 不得触发刷新');
    });

    test('401 触发刷新，重放后成功', () async {
      // 第一次调用 401，重放时成功。
      var calls = 0;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        calls++;
        if (calls == 1) {
          return ResponseBody.fromString(
            '{}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        // 重放请求必须携带新 Bearer token。
        expect(options.headers['Authorization'], 'Bearer new-token');
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final response = await dio.get<Map<String, dynamic>>('/ping');
      expect(response.statusCode, 200, reason: '重放后必须成功');
      expect(refreshCalls, 1, reason: '单飞：只刷新一次');
    });

    test('并发 401 单飞：refresh 只调用一次，全部重放成功', () async {
      var calls = 0;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        calls++;
        // 前两次请求 401（并发），之后都成功。
        if (calls <= 2) {
          return ResponseBody.fromString(
            '{}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final results = await Future.wait([
        dio.get<Map<String, dynamic>>('/a'),
        dio.get<Map<String, dynamic>>('/b'),
      ]);
      expect(results.every((r) => r.statusCode == 200), isTrue);
      expect(refreshCalls, 1, reason: '并发 401 必须单飞：refresh 仅一次');
    });

    test('刷新失败时放行原始 401 错误', () async {
      refresh = () async {
        refreshCalls++;
        throw DioException(
          requestOptions: RequestOptions(path: '/refresh'),
          response: Response(
            requestOptions: RequestOptions(path: '/refresh'),
            statusCode: 400,
          ),
          type: DioExceptionType.badResponse,
        );
      };
      dio.interceptors.clear();
      dio.interceptors.add(AuthRefreshInterceptor(dio: dio, refresh: refresh));
      dio.httpClientAdapter = _StatusAdapter(401, headers: {});

      await expectLater(
        dio.get<Map<String, dynamic>>('/ping'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(refreshCalls, 1, reason: '刷新失败也走单飞路径');
    });

    test('刷新接口自身返回 401 时不递归刷新', () async {
      var calls = 0;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        calls++;
        return ResponseBody.fromString(
          '{}',
          calls == 1 ? 401 : 200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        dio.post<Map<String, dynamic>>('/api/v1/auth/refresh'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(refreshCalls, 0, reason: '刷新接口不得触发自身再次刷新');
      expect(calls, 1, reason: '刷新接口不得被拦截器重放');
    });

    test('重放仍为 401 时不再刷新或重放', () async {
      var calls = 0;
      dio.httpClientAdapter = _CallbackAdapter((options) {
        calls++;
        return ResponseBody.fromString(
          '{}',
          calls <= 2 ? 401 : 200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await expectLater(
        dio.get<Map<String, dynamic>>('/ping'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(refreshCalls, 1, reason: '每个请求最多刷新一次');
      expect(calls, 2, reason: '每个请求最多重放一次');
    });
  });
}

/// 固定状态码适配器。
class _StatusAdapter implements HttpClientAdapter {
  final int statusCode;
  final Map<String, List<String>> headers;

  _StatusAdapter(this.statusCode, {required this.headers});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('{}', statusCode, headers: headers);
  }

  @override
  void close({bool force = false}) {}
}

/// 回调适配器：按调用次数决定行为。
class _CallbackAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) onFetch;

  _CallbackAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return Future.value(onFetch(options));
  }

  @override
  void close({bool force = false}) {}
}
