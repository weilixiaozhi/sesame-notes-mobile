import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('生产 API 客户端认证装配', () {
    test('登录后受保护请求携带 Bearer，登出后立即移除', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final client = container.read(apiClientProvider);
      final adapter = _RecordingAdapter();
      client.dio.httpClientAdapter = adapter;

      expect(client.dio.options.baseUrl, 'https://api.9100300.xyz');
      expect(client.dio.options.connectTimeout, const Duration(seconds: 5));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 3));

      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'access-token',
              userId: 'u',
              deviceId: 'd',
            ),
          );
      await _getProtected(client);
      expect(adapter.authorizationHeaders.single, 'Bearer access-token');

      container.read(authSessionProvider.notifier).signOut();
      await _getProtected(client);
      expect(adapter.authorizationHeaders.last, isNull);
    });

    test('认证类刷新失败会清除凭证束、内存会话与 Bearer', () async {
      final rawStore = _MemorySecureStore()
        ..value = ActiveCredential(
          userId: 'u',
          deviceId: 'd',
          refreshToken: 'refresh-token',
        ).encode();
      final accountStore = SecureAccountStore(rawStore);
      final failingService = _FailingAuthService();
      final container = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(failingService),
          secureAccountStoreProvider.overrideWithValue(accountStore),
        ],
      );
      addTearDown(container.dispose);
      final client = container.read(apiClientProvider);
      final adapter = _RecordingAdapter(statusCode: 401);
      client.dio.httpClientAdapter = adapter;
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'expired-token',
              userId: 'u',
              deviceId: 'd',
            ),
          );

      await expectLater(
        _getProtected(client),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(failingService.refreshCalls, 1, reason: '401 必须进入一次刷新流程');
      expect(await accountStore.load(), isNull, reason: '认证类 401 必须清除凭证束');
      expect(container.read(authSessionProvider), isNull);

      adapter.statusCode = 200;
      await _getProtected(client);
      expect(adapter.authorizationHeaders.last, isNull);
    });
  });
}

/// 发起一个带生成客户端安全元数据的受保护请求。
Future<void> _getProtected(SesameApiClient client) async {
  await client.dio.get<void>(
    '/protected',
    options: Options(
      extra: {
        'secure': [
          {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
        ],
      },
    ),
  );
}

/// 记录实际离开 Dio 拦截器链时的 Authorization 请求头。
class _RecordingAdapter implements HttpClientAdapter {
  final List<String?> authorizationHeaders = [];
  int statusCode;

  _RecordingAdapter({this.statusCode = 200});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    authorizationHeaders.add(options.headers['Authorization'] as String?);
    return ResponseBody.fromString('{}', statusCode);
  }

  @override
  void close({bool force = false}) {}
}

/// 内存安全存储桩，验证刷新失败后的凭证清理。
class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<void> delete() async => value = null;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async => value = token;
}

/// 固定抛错的认证服务，模拟 Refresh Token 已失效。
class _FailingAuthService extends AuthService {
  int refreshCalls = 0;

  _FailingAuthService()
    : super(
        client: SesameApiClient(),
        identity: DeviceIdentity(_MemoryDeviceIdStore()),
      );

  @override
  Future<({AuthSession session, String refreshToken, CloudProfile profile})>
  refresh({required ActiveCredential credential}) {
    refreshCalls++;
    // 模拟服务端明确认证 401（INVALID_REFRESH_TOKEN）
    return Future<
      ({AuthSession session, String refreshToken, CloudProfile profile})
    >.error(
      DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
          statusCode: 401,
        ),
      ),
    );
  }
}

/// 认证失败测试不读取设备标识，此桩仅满足依赖构造。
class _MemoryDeviceIdStore implements DeviceIdStore {
  @override
  Future<String?> read() async => null;

  @override
  Future<void> write(String id) async {}
}
