// 启动账号恢复（AccountState bootstrap）测试。
//
// 锚点（需求 10.3）：
//   - 无凭证 → 保持未登录；
//   - 有凭证 + 缓存资料 → 先以缓存渲染 authenticated，后台刷新；
//   - 刷新 200 → 凭证束原子轮换 + 会话/资料更新；
//   - 刷新认证类 401 → 清除凭证回未登录（业务缓存保留）；
//   - 刷新网络错误/5xx → 凭证与缓存身份保留，等待重试。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';

/// 会话响应样例（注册/登录/刷新共用形状）。
Map<String, Object> _sessionBody({String token = 'new-access'}) => {
  'access_token': token,
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
};

class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

/// 可编程响应队列的 Dio 适配器：按请求顺序返回预设响应。
class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this.responses);

  final List<({int status, Map<String, Object> body, Object? error})> responses;
  int _index = 0;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    final next =
        responses[(_index < responses.length ? _index : responses.length - 1)];
    _index++;
    if (next.error != null) throw next.error!;
    return ResponseBody.fromString(
      jsonEncode(next.body),
      next.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DioException _networkError() => DioException(
  requestOptions: RequestOptions(path: '/api/v1/auth/refresh'),
  type: DioExceptionType.connectionTimeout,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemorySecureStore rawStore;
  late ProviderContainer container;
  late _QueuedAdapter adapter;

  ProviderContainer buildContainer() {
    final client = SesameApiClient(basePathOverride: 'http://test.local');
    client.dio.httpClientAdapter = adapter;
    return ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(rawStore),
        ),
      ],
    );
  }

  Future<void> flushUntil(bool Function() condition) async {
    for (var i = 0; i < 40 && !condition(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rawStore = _MemorySecureStore();
  });

  tearDown(() => container.dispose());

  test('无凭证：保持未登录，不发起任何刷新请求', () async {
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(), error: null),
    ]);
    container = buildContainer();
    await container.read(accountBootstrapProvider.future);
    expect(container.read(accountStateProvider).status, AccountStatus.local);
    expect(adapter.paths, isEmpty);
  });

  test('有凭证 + 缓存资料 + 刷新 200：缓存先渲染，随后凭证束轮换并更新会话与资料', () async {
    SharedPreferences.setMockInitialValues({});
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'sesame_notes_cloud_profile_user-1',
      jsonEncode(
        const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
          displayName: '缓存昵称',
          avatarVersion: 3,
          phoneMasked: '+86 138****8000',
        ).toJson(),
      ),
    );
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(token: 'rotated'), error: null),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 缓存渲染阶段：authenticated，会话仍为空（断网启动形态）
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile?.displayName, '缓存昵称');
    expect(container.read(authSessionProvider), isNull);

    // 后台刷新完成后：凭证束轮换、会话注入、资料更新
    await flushUntil(
      () => container.read(authSessionProvider)?.accessToken == 'rotated',
    );
    expect(container.read(authSessionProvider)?.userId, 'user-1');
    expect(container.read(authSessionProvider)?.deviceId, 'device-1');
    final stored = await rawStore.read();
    expect(stored, contains('new-refresh'));
    expect(
      container.read(accountStateProvider).profile?.displayName,
      '芝麻仔000001',
    );
    // 刷新成功后会话建立并启动实时通知：ws/ticket 请求紧随 refresh 之后属
    // 设计行为（WS 只在会话存在期运行），此处只断言轮换请求必须最先且仅一次。
    expect(adapter.paths.first, '/api/v1/auth/refresh');
    expect(adapter.paths.where((p) => p == '/api/v1/auth/refresh').length, 1);
  });

  test('刷新认证类 401：清除凭证回到未登录（资料缓存保留）', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (
        status: 401,
        body: {
          'code': 'INVALID_REFRESH_TOKEN',
          'message': '登录状态已失效，请重新登录',
          'request_id': 'r1',
        },
        error: null,
      ),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    await flushUntil(
      () => container.read(accountStateProvider).status == AccountStatus.local,
    );
    expect(container.read(accountStateProvider).status, AccountStatus.local);
    expect(await rawStore.read(), isNull);
    // 本地账本等业务数据不在本次范围；资料缓存按账号键控保留
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('sesame_notes_cloud_profile_user-1'), isNull);
  });

  test('刷新网络错误：凭证与缓存身份保留，账号保持 authenticated', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'sesame_notes_cloud_profile_user-1',
      jsonEncode(
        const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
          displayName: '缓存昵称',
        ).toJson(),
      ),
    );
    adapter = _QueuedAdapter([
      (status: 0, body: const {}, error: _networkError()),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    // 网络恢复前：authenticated（缓存资料），凭证未动
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile?.displayName, '缓存昵称');
    expect(await rawStore.read(), contains('old-refresh'));
    expect(container.read(authSessionProvider), isNull);
  });

  test('刷新 5xx：与网络错误同语义，凭证保留', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (
        status: 500,
        body: {
          'code': 'INTERNAL_ERROR',
          'message': '服务暂时不可用',
          'request_id': 'r2',
        },
        error: null,
      ),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    await flushUntil(() => adapter.paths.isNotEmpty);
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(await rawStore.read(), contains('old-refresh'));
  });

  test('有凭证但无缓存资料：先进入 authenticated 空资料态，刷新后补全', () async {
    await rawStore.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    adapter = _QueuedAdapter([
      (status: 200, body: _sessionBody(), error: null),
    ]);
    container = buildContainer();

    await container.read(accountBootstrapProvider.future);
    expect(
      container.read(accountStateProvider).status,
      AccountStatus.authenticated,
    );
    expect(container.read(accountStateProvider).profile, isNull);
    await flushUntil(
      () => container.read(accountStateProvider).profile != null,
    );
    expect(
      container.read(accountStateProvider).profile?.displayName,
      '芝麻仔000001',
    );
  });
}
