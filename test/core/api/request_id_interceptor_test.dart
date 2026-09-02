// Request ID 注入测试（Dio 统一处理 Request ID）。
//
// 需求锚点：
// - 每个请求自动带上 x-request-id 头（UUID v4）；
// - 调用方已显式提供 x-request-id 时不覆盖；
// - 服务端 Fastify 回显 x-request-id（响应头断言）。
library;

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/api/api_interceptors.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('RequestIdInterceptor', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
      dio.interceptors.add(RequestIdInterceptor());
      dio.httpClientAdapter = _CapturingAdapter();
    });

    test('每个请求自动注入 x-request-id 头（UUID v4）', () async {
      final response = await dio.get<Map<String, dynamic>>('/ping');

      // 服务端回显同一 request id（Fastify 标准行为）。
      final echoed = response.headers.value('x-request-id');
      expect(echoed, isNotNull, reason: '请求必须携带 x-request-id 并被回显');
      expect(
        Uuid.isValidUUID(fromString: echoed!),
        isTrue,
        reason: 'x-request-id 必须是合法 UUID v4',
      );
    });

    test('调用方已提供 x-request-id 时不覆盖', () async {
      const custom = 'custom-request-id';
      final response = await dio.get<Map<String, dynamic>>(
        '/ping',
        options: Options(headers: {'x-request-id': custom}),
      );

      expect(
        response.headers.value('x-request-id'),
        custom,
        reason: '调用方显式指定的 request id 必须保留',
      );
    });

    test('每次请求生成不同的 request id', () async {
      final a = await dio.get<Map<String, dynamic>>('/ping');
      final b = await dio.get<Map<String, dynamic>>('/ping');

      expect(
        a.headers.value('x-request-id'),
        isNot(b.headers.value('x-request-id')),
        reason: '每次请求必须使用新 request id（日志关联唯一性）',
      );
    });
  });
}

/// 假适配器：回显请求的 x-request-id 头（模拟 Fastify 响应回显）。
class _CapturingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        'x-request-id': [options.headers['x-request-id']?.toString() ?? ''],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
