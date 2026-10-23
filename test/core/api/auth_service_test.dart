import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/account/auth_service.dart';
import 'package:sesame_notes/infrastructure/account/device_identity.dart';
import 'package:sesame_notes/infrastructure/account/device_metadata.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/network/request_deadline.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';

/// 提供真实账号凭证队列使用的容器引用。
final _credentialRefProvider = Provider<Ref>((ref) => ref);

/// 验证认证响应解析与待撤销会话的凭据边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('未配置服务器时登录注册不访问设备存储或网络', () async {
    final client = SesameApiClient(basePathOverride: '');
    final requests = <RequestOptions>[];
    final identityStore = _CountingDeviceIdStore();
    client.dio.httpClientAdapter = _CallbackAdapter((request) {
      requests.add(request);
      return _sessionResponse();
    });
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(identityStore),
    );
    for (final authenticate in [service.login, service.register]) {
      await expectLater(
        authenticate(
          countryCode: '+86',
          phone: '13800138000',
          password: 'test-password',
        ),
        throwsA(isA<ServerNotConfiguredException>()),
      );
    }
    const credential = ActiveCredential(
      userId: 'old-user',
      deviceId: 'old-device',
      refreshToken: 'secret',
    );
    await expectLater(
      service.refresh(credential: credential),
      throwsA(isA<ServerNotConfiguredException>()),
    );
    await expectLater(
      service.revokeServerSession(
        credential,
        persistRotatedCredential: (_) async {},
      ),
      throwsA(isA<ServerNotConfiguredException>()),
    );
    expect(identityStore.reads, 0);
    expect(identityStore.writes, 0);
    expect(requests, isEmpty);
  });

  test('登录注册携带可用资料，刷新补当前版本且不发送设备或安装身份', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    final requests = <RequestOptions>[];
    client.dio.httpClientAdapter = _CallbackAdapter((request) {
      requests.add(request);
      return _sessionResponse();
    });
    var version = '1.4.6+24';
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(_FixedDeviceIdStore()),
      metadataReader: DeviceMetadataReader(
        platformReader: () => 'ios',
        appVersionReader: () async => version,
        nativeReader: () async => {
          'device_model': 'system-machine-code',
          'os_version': 'iOS 26.0',
        },
      ),
    );
    await service.login(
      countryCode: '+86',
      phone: '13800138000',
      password: 'test-password',
    );
    await service.register(
      countryCode: '+86',
      phone: '13800138000',
      password: 'test-password',
    );
    for (final request in requests) {
      expect(
        (request.data as Map)['device'],
        containsPair('installation_id', 'fixed-installation-id'),
      );
      expect((request.data as Map)['device'], containsPair('platform', 'ios'));
      expect(
        (request.data as Map)['device'],
        containsPair('app_version', '1.4.6+24'),
      );
      expect(
        (request.data as Map)['device'],
        containsPair('device_model', 'system-machine-code'),
      );
    }
    version = '1.5.0+25';
    await service.refresh(
      credential: const ActiveCredential(
        userId: 'old-user',
        deviceId: 'old-device',
        refreshToken: 'old-refresh',
      ),
    );
    expect(requests.last.data, {
      'refresh_token': 'old-refresh',
      'device': {
        'platform': 'ios',
        'app_version': '1.5.0+25',
        'os_version': 'iOS 26.0',
        'device_model': 'system-machine-code',
      },
    });
  });

  test('设备资料不可读取仍可登录，不伪造型号或版本', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    RequestOptions? request;
    client.dio.httpClientAdapter = _CallbackAdapter((options) {
      request = options;
      return _sessionResponse();
    });
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(_FixedDeviceIdStore()),
      metadataReader: DeviceMetadataReader(
        platformReader: () => 'android',
        appVersionReader: () async => null,
        nativeReader: () async => throw StateError('DEVICE_UNAVAILABLE'),
      ),
    );
    final session = await service.login(
      countryCode: '+86',
      phone: '13800138000',
      password: 'test-password',
    );
    expect(session.session.deviceId, 'old-device');
    final device = (request!.data as Map)['device'] as Map;
    expect(device['platform'], 'android');
    expect(device.containsKey('device_model'), isFalse);
    expect(device.containsKey('os_version'), isFalse);
    expect(device.containsKey('app_version'), isFalse);
  });

  test('安全存储不可写时不能开始刷新轮换，原撤销材料保持有效', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    final requests = <RequestOptions>[];
    client.dio.httpClientAdapter = _CallbackAdapter((options) {
      requests.add(options);
      return options.path.endsWith('/refresh')
          ? _sessionResponse()
          : ResponseBody.fromString('', 204);
    });
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(_FixedDeviceIdStore()),
    );
    await expectLater(
      service.revokeServerSession(
        const ActiveCredential(
          userId: 'old-user',
          deviceId: 'old-device',
          refreshToken: 'old-refresh',
        ),
        persistRotatedCredential: (_) async => throw StateError('安全存储不可写'),
      ),
      throwsA(isA<StateError>()),
    );
    expect(requests, isEmpty, reason: '先确认安全槽可用，再允许服务端轮换');
  });

  test('轮换写瞬时失败且撤销503时再次保存新材料，重启可继续撤销', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    client.dio.httpClientAdapter = _CallbackAdapter(
      (options) => options.path.endsWith('/refresh')
          ? _sessionResponse()
          : ResponseBody.fromString('', 503),
    );
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(_FixedDeviceIdStore()),
    );
    String? secureValue;
    var rotatedWrites = 0;
    await expectLater(
      service.revokeServerSession(
        const ActiveCredential(
          userId: 'old-user',
          deviceId: 'old-device',
          refreshToken: 'old-refresh',
        ),
        persistRotatedCredential: (credential) async {
          if (credential.refreshToken == 'rotated-refresh' &&
              rotatedWrites++ == 0) {
            throw StateError('一次写失败');
          }
          secureValue = credential.encode();
        },
      ),
      throwsA(isA<DioException>()),
    );
    expect(
      ActiveCredential.decode(secureValue!)?.refreshToken,
      'rotated-refresh',
      reason: '新进程应从安全值恢复有效令牌，而不是已轮换失效的旧令牌',
    );
  });

  test('退出已隔离账号时用待撤销会话自身的 Bearer 撤销', () async {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    client.setBearerAuth('bearerAuth', 'current-account-access');
    final requests = <RequestOptions>[];
    client.dio.httpClientAdapter = _CallbackAdapter((options) {
      requests.add(options);
      if (options.path.endsWith('/refresh')) {
        return _sessionResponse();
      }
      return ResponseBody.fromString('', 204);
    });
    final service = AuthService(
      client: client,
      identity: DeviceIdentity(_FixedDeviceIdStore()),
    );
    ActiveCredential? persisted;
    final result = await service.revokeServerSession(
      const ActiveCredential(
        userId: 'old-user',
        deviceId: 'old-device',
        refreshToken: 'old-refresh',
      ),
      persistRotatedCredential: (credential) async {
        expect(
          requests,
          hasLength(credential.refreshToken == 'old-refresh' ? 0 : 1),
          reason: '安全预检先于刷新，新凭证落盘先于撤销',
        );
        persisted = credential;
      },
    );
    expect(
      requests.first.path,
      '/api/v1/auth/refresh',
      reason: '旧账号必须自行恢复临时认证，不能借用当前账号的认证头',
    );
    expect(requests.first.headers['Authorization'], isNull);
    expect(result, SessionRevocationResult.revoked);
    expect(persisted?.refreshToken, 'rotated-refresh');
    expect(requests.last.headers['Authorization'], 'Bearer old-account-access');
    expect(requests.last.data, {'refresh_token': 'rotated-refresh'});
    await AuthApi(client.dio, client.serializers).postAuthLogout(
      postAuthLogoutRequest: PostAuthLogoutRequest(
        (builder) => builder..refreshToken = 'current-account-refresh',
      ),
    );
    expect(
      requests.last.headers['Authorization'],
      'Bearer current-account-access',
    );
  });

  for (final stalledPath in ['/refresh', '/logout']) {
    test('撤销 $stalledPath 持续收包超时会取消传输，保留材料并释放后续认证', () async {
      final client = SesameApiClient(basePathOverride: 'http://test.local');
      client.dio.interceptors.add(
        RequestDeadlineInterceptor(timeout: const Duration(milliseconds: 100)),
      );
      final adapter = _DripRevocationAdapter(stalledPath);
      client.dio.httpClientAdapter = adapter;
      final service = AuthService(
        client: client,
        identity: DeviceIdentity(_FixedDeviceIdStore()),
      );
      final store = SecureAccountStore(
        _MemoryCredentialStore(),
        pendingStore: _MemoryCredentialStore(),
        logoutMarkerStore: _MemoryCredentialStore(),
      );
      final container = ProviderContainer(
        overrides: [
          apiConfigProvider.overrideWithValue(
            const ApiConfig(baseUrl: 'http://test.local'),
          ),
          secureAccountStoreProvider.overrideWithValue(store),
          authServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(() {
        client.dio.close(force: true);
        container.dispose();
      });
      const credential = ActiveCredential(
        userId: 'old-user',
        deviceId: 'old-device',
        refreshToken: 'old-refresh',
      );
      await store.saveLogoutMarker(const LogoutMarker(credential: credential));
      final ref = container.read(_credentialRefProvider);
      final revocation = revokePendingCredential(ref, credential);
      await adapter.entered.future;
      final authentication = runAccountAuthentication(
        ref,
        () => service.login(
          countryCode: '+86',
          phone: '13800138000',
          password: 'test-password',
        ),
      );
      expect(adapter.loginRequests, 0, reason: '撤销仍在途时不能发送同设备的新认证');
      await revocation.timeout(const Duration(seconds: 1));
      final candidate = await authentication.timeout(
        const Duration(seconds: 1),
      );
      expect(candidate.session.userId, 'old-user');
      expect(adapter.loginRequests, 1);
      expect(adapter.aborted, 1, reason: '必须取消底层传输才能释放认证队列');
      expect(adapter.chunks, greaterThan(1));
      expect(
        (await store.loadLogoutMarkers()).single.credential.refreshToken,
        stalledPath == '/refresh' ? 'old-refresh' : 'rotated-refresh',
        reason: '超时不是完成撤销，保留最后一份已知有效材料供后续重试',
      );
      final stoppedAt = adapter.chunks;
      await Future<void>.delayed(const Duration(milliseconds: 35));
      expect(adapter.chunks, stoppedAt, reason: '超时后不能继续生产响应数据');
    });
  }

  for (final response in [
    (401, 'INVALID_REFRESH_TOKEN', true),
    (401, 'UNAUTHORIZED', false),
    (500, 'TOKEN_REFRESH_FAILED', false),
  ]) {
    test('撤销刷新返回 ${response.$1}/${response.$2} 仅明确失效才完成', () async {
      final client = SesameApiClient(basePathOverride: 'http://test.local');
      client.dio.httpClientAdapter = _CallbackAdapter(
        (options) => ResponseBody.fromString(
          jsonEncode({'code': response.$2}),
          response.$1,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );
      final service = AuthService(
        client: client,
        identity: DeviceIdentity(_FixedDeviceIdStore()),
      );
      final future = service.revokeServerSession(
        const ActiveCredential(
          userId: 'old-user',
          deviceId: 'old-device',
          refreshToken: 'old-refresh',
        ),
        persistRotatedCredential: (credential) async => expect(
          credential.refreshToken,
          'old-refresh',
          reason: '刷新失败只能保留原材料，不能写入伪造轮换材料',
        ),
      );
      if (response.$3) {
        expect(await future, SessionRevocationResult.credentialInvalid);
      } else {
        await expectLater(future, throwsA(isA<DioException>()));
      }
    });
  }

  for (final status in [401, 503]) {
    test('撤销返回 $status 时保留已轮换材料并返回未完成', () async {
      final client = SesameApiClient(basePathOverride: 'http://test.local');
      client.dio.httpClientAdapter = _CallbackAdapter(
        (options) => options.path.endsWith('/refresh')
            ? _sessionResponse()
            : ResponseBody.fromString(
                '{"code":"INVALID_REFRESH_TOKEN"}',
                status,
                headers: {
                  Headers.contentTypeHeader: [Headers.jsonContentType],
                },
              ),
      );
      final service = AuthService(
        client: client,
        identity: DeviceIdentity(_FixedDeviceIdStore()),
      );
      ActiveCredential? persisted;
      await expectLater(
        service.revokeServerSession(
          const ActiveCredential(
            userId: 'old-user',
            deviceId: 'old-device',
            refreshToken: 'old-refresh',
          ),
          persistRotatedCredential: (credential) async =>
              persisted = credential,
        ),
        throwsA(isA<DioException>()),
      );
      expect(persisted?.refreshToken, 'rotated-refresh');
    });
  }

  for (final logoutStatus in [204, 503]) {
    test('轮换材料写失败时立即尝试撤销，远端结果 $logoutStatus 不冒充成功', () async {
      final client = SesameApiClient(basePathOverride: 'http://test.local');
      final requests = <RequestOptions>[];
      client.dio.httpClientAdapter = _CallbackAdapter((options) {
        requests.add(options);
        return options.path.endsWith('/refresh')
            ? _sessionResponse()
            : ResponseBody.fromString('', logoutStatus);
      });
      final service = AuthService(
        client: client,
        identity: DeviceIdentity(_FixedDeviceIdStore()),
      );
      final future = service.revokeServerSession(
        const ActiveCredential(
          userId: 'old-user',
          deviceId: 'old-device',
          refreshToken: 'old-refresh',
        ),
        persistRotatedCredential: (credential) async {
          if (credential.refreshToken != 'old-refresh') {
            throw StateError('secret-refresh-token');
          }
        },
      );
      if (logoutStatus == 204) {
        expect(await future, SessionRevocationResult.revoked);
      } else {
        await expectLater(future, throwsA(isA<DioException>()));
      }
      expect(
        requests.last.headers['Authorization'],
        'Bearer old-account-access',
      );
      expect(requests.last.data, {'refresh_token': 'rotated-refresh'});
      final entries = logger.logs.where((entry) => entry.tag == 'AuthLogout');
      expect(entries, isNotEmpty);
      expect(
        entries.map((entry) => entry.toFormattedString()).join(),
        isNot(contains('secret-refresh-token')),
      );
    });
  }

  group('AuthService.login', () {
    test('手机号登录响应无需 is_admin 即可返回候选会话', () async {
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
          'phone': '+8613800138000',
          'gender': 'UNSPECIFIED',
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
      expect(candidate.profile.phone, '+8613800138000');
    });
  });

  group('AuthService.register', () {
    test('注册响应无需 is_admin 即可返回候选会话', () async {
      final service = _serviceWithResponse({
        'access_token': 'registered-access',
        'refresh_token': 'registered-refresh',
        'token_type': 'Bearer',
        'expires_in': 900,
        'device_id': 'registered-device',
        'scopes': ['sync:read'],
        'user': {
          'user_id': 'registered-user',
          'sesame_number': '123456789',
          'display_name': '芝麻仔000001',
          'avatar_url': null,
          'avatar_version': 0,
          'phone': '+8613800138000',
          'gender': 'UNSPECIFIED',
        },
      }, statusCode: 201);

      final candidate = await service.register(
        countryCode: '+86',
        phone: '13800138000',
        password: 'secret123',
      );

      expect(candidate.session.accessToken, 'registered-access');
      expect(candidate.session.userId, 'registered-user');
      expect(candidate.session.deviceId, 'registered-device');
      expect(candidate.refreshToken, 'registered-refresh');
      expect(candidate.profile.sesameNumber, '123456789');
      expect(candidate.profile.phone, '+8613800138000');
    });
  });

  group('AuthService.refresh', () {
    test('刷新响应无需 is_admin 即可轮换并返回新凭证', () async {
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
          'phone': '+8613800138000',
          'gender': 'UNSPECIFIED',
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

/// 使用真实生成客户端反序列化指定认证响应。
AuthService _serviceWithResponse(
  Map<String, Object> response, {
  int statusCode = 200,
}) {
  final client = SesameApiClient(basePathOverride: 'http://test.local');
  client.dio.httpClientAdapter = _JsonAdapter(response, statusCode: statusCode);
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

/// 使用独立内存槽验证真实安全存储对撤销材料的保留。
class _MemoryCredentialStore implements SecureStore {
  String? value;

  /// 返回当前槽位内容。
  @override
  Future<String?> read() async => value;

  /// 原子替换当前槽位内容。
  @override
  Future<void> write(String next) async => value = next;

  /// 清理当前槽位内容。
  @override
  Future<void> delete() async => value = null;
}

/// 持续返回未结束的响应，只有真实取消信号才能释放传输。
class _DripRevocationAdapter implements HttpClientAdapter {
  _DripRevocationAdapter(this.stalledPath);

  final String stalledPath;
  final entered = Completer<void>();
  int aborted = 0;
  int chunks = 0;
  int loginRequests = 0;
  void Function()? _release;

  /// 普通认证立即完成，指定撤销步骤每十毫秒收包以避开空闲超时。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/login')) loginRequests++;
    if (!options.path.endsWith(stalledPath)) return _sessionResponse();
    final body = StreamController<Uint8List>();
    Timer? timer;
    var released = false;

    /// 幂等终止响应生产，清理计时器和响应流。
    void release() {
      if (released) return;
      released = true;
      timer?.cancel();
      unawaited(body.close());
    }

    _release = release;
    unawaited(
      cancelFuture?.then((_) {
        aborted++;
        release();
      }),
    );
    timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      chunks++;
      body.add(Uint8List.fromList([32]));
    });
    entered.complete();
    return ResponseBody(
      body.stream,
      200,
      onClose: release,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  /// 测试结束释放剩余资源，避免失败用例遗留计时器。
  @override
  void close({bool force = false}) => _release?.call();
}

/// 记录请求并在测试内返回固定 JSON 响应的 Dio 适配器。
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter(this.response, {this.statusCode = 200});

  final Map<String, Object> response;
  final int statusCode;

  /// 按接口状态返回 JSON，交由生成客户端执行真实反序列化。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(response),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// 记录设备身份访问，验证缺少账号服务配置不会触发平台存储。
class _CountingDeviceIdStore implements DeviceIdStore {
  int reads = 0;
  int writes = 0;

  /// 返回空身份，若认证提前访问将被计数断言捕获。
  @override
  Future<String?> read() async {
    reads++;
    return null;
  }

  /// 记录新身份写入，不访问平台。
  @override
  Future<void> write(String id) async {
    writes++;
  }
}

/// 由用例提供真实传输响应，并暴露请求用于验证认证边界。
class _CallbackAdapter implements HttpClientAdapter {
  _CallbackAdapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  /// 将请求交给需求断言回调。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  /// 内存适配器没有需要释放的网络连接。
  @override
  void close({bool force = false}) {}
}

/// 返回待撤销旧账号的完整轮换响应，独立于当前账号的登录状态。
ResponseBody _sessionResponse() => ResponseBody.fromString(
  jsonEncode({
    'access_token': 'old-account-access',
    'refresh_token': 'rotated-refresh',
    'token_type': 'Bearer',
    'expires_in': 900,
    'device_id': 'old-device',
    'scopes': ['sync:read'],
    'user': {
      'user_id': 'old-user',
      'sesame_number': '123456789',
      'display_name': '旧账号',
      'avatar_url': null,
      'avatar_version': 0,
      'phone': '+8613800138000',
      'gender': 'UNSPECIFIED',
    },
  }),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);
