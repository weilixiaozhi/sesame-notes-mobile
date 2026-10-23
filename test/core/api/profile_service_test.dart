import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/infrastructure/account/profile_service.dart';

class _CancellableAdapter implements HttpClientAdapter {
  final started = Completer<void>();
  bool cancelled = false;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    started.complete();
    if (cancelFuture == null) throw StateError('取消信号未传到传输层');
    await cancelFuture;
    cancelled = true;
    throw DioException(requestOptions: options, type: DioExceptionType.cancel);
  }

  @override
  void close({bool force = false}) {}
}

/// 记录请求并返回固定字节响应的 Dio 适配器（头像下载用）。
class _CapturingBytesAdapter implements HttpClientAdapter {
  _CapturingBytesAdapter(this.bytes);

  final List<int> bytes;
  RequestOptions? lastOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['image/jpeg'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 记录请求并在测试内返回固定 JSON 响应的 Dio 适配器。
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.response);

  final Map<String, Object> response;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 使用真实生成客户端解析指定本人资料响应。
ProfileService _serviceWithResponse(Map<String, Object> response) {
  final client = SesameApiClient(basePathOverride: 'http://test.local');
  client.dio.httpClientAdapter = _JsonAdapter(response);
  return ProfileService(client);
}

/// 验证本人资料响应解析、头像地址与请求取消行为。
void main() {
  test('头像请求随调用方取消，不继续等待图片响应', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    final adapter = _CancellableAdapter();
    client.dio.httpClientAdapter = adapter;
    addTearDown(() => client.dio.close(force: true));
    final token = CancelToken();
    final pending = ProfileService(
      client,
    ).downloadAvatar('user', cancelToken: token);
    await adapter.started.future;
    token.cancel();
    expect(await pending, isNull);
    expect(adapter.cancelled, isTrue);
  });

  test('更新昵称响应无需 is_admin 即可读取最新本人资料', () async {
    final service = _serviceWithResponse({
      'user_id': 'user-1',
      'sesame_number': '123456789',
      'display_name': '新昵称',
      'avatar_url': '/api/v1/profile/avatar/user-1?v=2',
      'avatar_version': 2,
      'phone': '+8613800138000',
      'gender': 'UNSPECIFIED',
    });

    final profile = await service.updateDisplayName('新昵称');

    expect(profile.userId, 'user-1');
    expect(profile.displayName, '新昵称');
    expect(profile.sesameNumber, '123456789');
    expect(profile.phone, '+8613800138000');
    expect(
      profile.avatarUrl,
      'http://test.local/api/v1/profile/avatar/user-1?v=2',
    );
  });

  group('ProfileService 头像 URL 归一化', () {
    test('getMe 响应无需 is_admin，头像相对路径拼接 baseUrl', () async {
      final service = _serviceWithResponse({
        'user_id': 'user-1',
        'sesame_number': '123456789',
        'display_name': '芝麻仔000001',
        'avatar_url': '/api/v1/profile/avatar/user-1?v=2',
        'avatar_version': 2,
        'phone': '+8613800138000',
        'gender': 'UNSPECIFIED',
      });

      final profile = await service.getMe();

      expect(
        profile.avatarUrl,
        'http://test.local/api/v1/profile/avatar/user-1?v=2',
      );
      expect(profile.phone, '+8613800138000');
    });

    test('getMe 忽略服务端额外 is_admin，头像绝对 URL 原样保留', () async {
      final service = _serviceWithResponse({
        'user_id': 'user-1',
        'sesame_number': '123456789',
        'display_name': '芝麻仔000001',
        'avatar_url':
            'https://cdn.example.com/api/v1/profile/avatar/user-1?v=1',
        'avatar_version': 1,
        'phone': '+8613800138000',
        'gender': 'UNSPECIFIED',
        'is_admin': true,
      });

      final profile = await service.getMe();

      expect(
        profile.avatarUrl,
        'https://cdn.example.com/api/v1/profile/avatar/user-1?v=1',
      );
    });

    test('uploadAvatar 返回的相对 URL 同样归一化', () async {
      final service = _serviceWithResponse({
        'avatar_url': '/api/v1/profile/avatar/user-1?v=3',
        'avatar_version': 3,
      });

      final result = await service.uploadAvatar(
        contentType: 'image/png',
        bytes: [1, 2, 3],
      );

      expect(result.url, 'http://test.local/api/v1/profile/avatar/user-1?v=3');
    });

    test('downloadAvatar 请求携带 Bearer 认证标记（拦截器据此附带 token）', () async {
      final client = SesameApiClient(basePathOverride: 'http://test.local');
      client.setBearerAuth('bearerAuth', 'token-abc');
      final adapter = _CapturingBytesAdapter([1, 2, 3]);
      client.dio.httpClientAdapter = adapter;
      final service = ProfileService(client);

      final bytes = await service.downloadAvatar('user-1');

      expect(bytes, [1, 2, 3]);
      expect(
        adapter.lastOptions?.headers['Authorization'],
        'Bearer token-abc',
        reason: '手动 Dio 请求必须带 secure 认证标记，否则拦截器不附带 token，服务端返回 401',
      );
    });
  });
}
