import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('AuthService.login', () {
    test('手机号登录返回候选会话', () async {
      final service = _serviceWithResponse({
        'access_token': 'access-token',
        'refresh_token': 'refresh-token',
        'token_type': 'Bearer',
        'expires_in': 900,
        'device_id': 'device-1',
        'scopes': ['sync:read'],
        'user': {
          'user_id': 'user-1',
          'sesame_number': '123456789',
          'display_name': '芝麻仔000001',
          'avatar_url': null,
          'avatar_version': 0,
          'phone_masked': '+86 138****8000',
          'gender': 'UNSPECIFIED',
          'is_admin': false,
        },
      });

      final candidate = await service.login(
        countryCode: '+86',
        phone: '13800138000',
        password: 'secret123',
      );

      expect(candidate.session.accessToken, 'access-token');
      expect(candidate.session.userId, 'user-1');
      expect(candidate.session.deviceId, 'device-1');
      expect(candidate.refreshToken, 'refresh-token');
      expect(candidate.profile.sesameNumber, '123456789');
      expect(candidate.profile.phoneMasked, '+86 138****8000');
    });
  });

  group('AuthService.refresh', () {
    test('按凭证束轮换并返回新凭证', () async {
      final service = _serviceWithResponse({
        'access_token': 'new-access',
        'refresh_token': 'new-refresh',
        'token_type': 'Bearer',
        'expires_in': 900,
        'device_id': 'device-1',
        'scopes': ['sync:read'],
        'user': {
          'user_id': 'user-1',
          'sesame_number': '123456789',
          'display_name': '芝麻仔000001',
          'avatar_url': null,
          'avatar_version': 0,
          'phone_masked': '+86 138****8000',
          'gender': 'UNSPECIFIED',
          'is_admin': false,
        },
      });
      final credential = ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      );

      final result = await service.refresh(credential: credential);

      expect(result.session.accessToken, 'new-access');
      expect(result.session.userId, 'user-1');
      expect(result.refreshToken, 'new-refresh');
    });
  });
}

/// 使用真实生成客户端反序列化指定登录响应。
AuthService _serviceWithResponse(Map<String, Object> response) {
  final client = SesameApiClient(basePathOverride: 'http://test.local');
  client.dio.httpClientAdapter = _JsonAdapter(response);
  return AuthService(
    client: client,
    identity: DeviceIdentity(_FixedDeviceIdStore()),
  );
}

class _FixedDeviceIdStore implements DeviceIdStore {
  @override
  Future<String?> read() async => 'fixed-installation-id';

  @override
  Future<void> write(String id) async {}
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
