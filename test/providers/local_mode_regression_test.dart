import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/features/memos/application/memo_book_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/app_composition.dart';
import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import '../helpers/realtime_test_stub.dart';

/// 所有安全槽都驻留内存，测试不读取设备凭证。
class _MemoryStore implements SecureStore {
  String? value;
  Future<void> Function()? beforeRead;

  /// 可挂起读取以验证错误响应与配置变更的交错顺序。
  @override
  Future<String?> read() async {
    await beforeRead?.call();
    return value;
  }

  /// 模拟单值原子写入。
  @override
  Future<void> write(String value) async => this.value = value;

  /// 只清理当前测试的内存值。
  @override
  Future<void> delete() async => value = null;
}

/// 捕获全部 HTTP 请求，不打开真实连接。
class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Future<ResponseBody> Function(RequestOptions)? respond;

  /// 使用可控响应验证在途轮换，默认失败使意外请求立即暴露。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? stream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (respond != null) return respond!(options);
    throw StateError('测试禁止意外网络请求');
  }

  /// 模拟传输层没有外部资源。
  @override
  void close({bool force = false}) {}
}

/// 返回符合生成客户端契约的会话，只有模拟传输可以读取。
ResponseBody _sessionResponse() => ResponseBody.fromString(
  jsonEncode({
    'access_token': 'new-access',
    'refresh_token': 'new-refresh',
    'token_type': 'Bearer',
    'expires_in': 900,
    'device_id': 'device',
    'scopes': ['sync:read'],
    'user': {
      'user_id': 'account',
      'sesame_number': '123456789',
      'display_name': '缓存账号',
      'avatar_url': null,
      'avatar_version': 0,
      'phone': '+8613800138000',
      'gender': 'UNSPECIFIED',
      'is_admin': false,
    },
  }),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// 以真实 provider、内存库和模拟传输覆盖本地降级及恢复边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const address = 'https://original.test';
  late ApiConfig config;
  late ProviderContainer container;
  late SesameDatabase db;
  late _MemoryStore raw;
  late SecureAccountStore store;
  final l10n = lookupAppLocalizations(const Locale('zh'));

  /// 配置重建模拟安装更新及运行中切换，不启动任何外部服务。
  void configure(String url) {
    config = ApiConfig(baseUrl: url);
    container.invalidate(apiConfigProvider);
  }

  /// 保存旧格式凭证，仅恢复本机身份而不发出请求。
  Future<void> restoreCachedAccount() async {
    await store.save(
      const ActiveCredential(
        userId: 'account',
        deviceId: 'device',
        refreshToken: 'old-refresh',
      ),
    );
    await container.read(accountBootstrapProvider.future);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    config = const ApiConfig(baseUrl: '');
    raw = _MemoryStore();
    store = SecureAccountStore(
      raw,
      pendingStore: _MemoryStore(),
      logoutMarkerStore: _MemoryStore(),
    );
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        ...applicationOverrides(),
        realtimeNoopOverride,
        apiConfigProvider.overrideWith((_) => config),
        databaseProvider.overrideWithValue(db),
        secureAccountStoreProvider.overrideWithValue(store),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  for (final cached in [false, true]) {
    test('${cached ? '缓存账号重启' : '全新安装'}无服务时不刷新不调度，四域默认本归本地', () async {
      if (cached) await restoreCachedAccount();
      final adapter = _Adapter();
      container.read(apiClientProvider).dio.httpClientAdapter = adapter;
      await container.read(accountStartupRefreshProvider.future);
      expect(await container.read(authSessionProvider.notifier).refresh(), '');
      expect((await container.read(syncCoordinatorProvider).run()).ok, isTrue);
      expect(
        (await container.read(syncCoordinatorProvider).refreshData())
            .refreshOutcome,
        DataRefreshOutcome.localOnly,
      );
      final provisioner = container.read(defaultBookProvisionerProvider);
      for (final mode in AppMode.values) {
        expect(await provisioner.ensureDefault(mode, l10n), isNotNull);
        expect(await provisioner.ensureDefault(mode, l10n), isNull);
      }
      for (final table in [
        'ledgers',
        'day_books',
        'memo_books',
        'fitness_spaces',
      ]) {
        final rows = await db
            .customSelect('SELECT storage_mode, scope_account_id FROM $table')
            .get();
        expect(rows, hasLength(1));
        expect(rows.single.read<String>('storage_mode'), 'local');
        expect(rows.single.readNullable<String>('scope_account_id'), isNull);
      }
      expect(adapter.requests, isEmpty);
      expect((await store.load())?.refreshToken, cached ? 'old-refresh' : null);
      expect(container.read(accountStateProvider).isAuthenticated, cached);
    });
  }

  test('缓存账号无服务可明确创建本地备忘录本并正常改名', () async {
    await restoreCachedAccount();
    final actions = container.read(memoBookActionsProvider('normal'));
    final created = await actions.save(
      id: '11111111-1111-4111-8111-111111111111',
      name: '本机记录',
      accountId: 'account',
      generation: 0,
      storageMode: 'local',
    );
    final renamed = await actions.save(
      id: created.id,
      name: '本机编辑',
      accountId: 'account',
      generation: 0,
      expected: created,
    );
    expect(renamed.name, '本机编辑');
    expect(renamed.storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('下载的云本在清配置后可读可编辑，归属和待同步元数据保留', () async {
    configure(address);
    await restoreCachedAccount();
    final repo = container.read(memoRepositoryProvider);
    final book = await repo.createBook(
      id: '22222222-2222-4222-8222-222222222222',
      name: '已下载的本',
      type: 'normal',
      storageMode: 'cloud',
      accountId: 'account',
    );
    configure('');
    final target = await repo.target(book.id);
    await repo.renameBook(target, '离线编辑');
    final now = DateTime.now().toUtc();
    await repo.saveEntry(
      MemoEntry(
        id: '33333333-3333-4333-8333-333333333333',
        memoBookId: book.id,
        bookType: 'normal',
        title: '离线笔记',
        createdAt: now,
        updatedAt: now,
        bodyJson: '{"ops":[{"insert":"离线正文\\n"}]}',
      ),
      target,
    );
    expect(
      (await repo.getEntries(book.id, accountId: 'account')).single.title,
      '离线笔记',
    );
    final saved = await repo.getBook(book.id, accountId: 'account');
    expect(saved?.name, '离线编辑');
    expect(saved?.storageMode, 'cloud');
    expect(saved?.scopeAccountId, 'account');
    expect(saved?.syncId, book.syncId);
    expect(await db.select(db.syncChanges).get(), isNotEmpty);
    expect(container.read(currentAccountIdProvider), 'account');
  });

  test('同步关闭允许恢复会话但禁止数据传输，重新启用恢复资格', () async {
    configure(address);
    await restoreCachedAccount();
    container.read(accountSyncEnabledProvider.notifier).setEnabled(false);
    final adapter = _Adapter()..respond = (_) async => _sessionResponse();
    container.read(apiClientProvider).dio.httpClientAdapter = adapter;
    expect(
      await container.read(authSessionProvider.notifier).refresh(),
      'new-access',
    );
    expect(container.read(cloudCapabilityProvider).canAuthenticate, isTrue);
    expect(container.read(cloudCapabilityProvider).canSync, isFalse);
    expect(container.read(newBookStorageModeProvider), 'local');
    await container.read(syncCoordinatorProvider).run();
    await expectLater(
      container.read(apiClientProvider).dio.post('/api/v1/sync/push'),
      throwsA(isA<DioException>()),
    );
    expect(adapter.requests.map((request) => request.path), [
      '/api/v1/auth/refresh',
    ]);
    container.read(accountSyncEnabledProvider.notifier).setEnabled(true);
    expect(container.read(cloudCapabilityProvider).canSync, isTrue);
  });

  for (final status in [200, 401]) {
    test('刷新在途清配置后迟到$status不激活会话或清除凭证，可恢复原服务', () async {
      configure(address);
      await restoreCachedAccount();
      final entered = Completer<void>();
      final response = Completer<ResponseBody>();
      final adapter = _Adapter()
        ..respond = (_) {
          entered.complete();
          return response.future;
        };
      final oldClient = container.read(apiClientProvider);
      oldClient.dio.httpClientAdapter = adapter;
      final refreshing = container.read(authSessionProvider.notifier).refresh();
      await entered.future;
      configure('');
      response.complete(
        status == 200 ? _sessionResponse() : ResponseBody.fromString('{}', 401),
      );
      expect(await refreshing, '');
      expect(container.read(authSessionProvider), isNull);
      expect(container.read(currentAccountIdProvider), 'account');
      expect(
        (await store.load())?.refreshToken,
        status == 200 ? 'new-refresh' : 'old-refresh',
      );
      expect(await store.loadLogoutMarkers(), isEmpty);
      await expectLater(
        oldClient.dio.get('/later'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
      configure(address);
      final restoredAdapter = _Adapter()
        ..respond = (_) async => _sessionResponse();
      container.read(apiClientProvider).dio.httpClientAdapter = restoredAdapter;
      expect(
        await container.read(authSessionProvider.notifier).refresh(),
        'new-access',
      );
      expect(container.read(cloudCapabilityProvider).canSync, isTrue);
    });
  }

  test('旧格式凭证在不同配置地址都可恢复同一账号，不按地址判断账号归属', () async {
    await restoreCachedAccount();
    for (final url in [address, 'https://other.test']) {
      configure(url);
      final adapter = _Adapter()..respond = (_) async => _sessionResponse();
      container.read(apiClientProvider).dio.httpClientAdapter = adapter;
      expect(
        await container.read(authSessionProvider.notifier).refresh(),
        'new-access',
      );
      expect(adapter.requests.single.baseUrl, url);
      expect(container.read(currentAccountIdProvider), 'account');
      expect(container.read(newBookStorageModeProvider), 'cloud');
      expect(jsonDecode(raw.value!) as Map, isNot(contains('server_url')));
    }
  });

  test('无服务器请求明确反馈配置缺失，保留缓存账号和凭证', () async {
    await restoreCachedAccount();
    final adapter = _Adapter();
    final client = container.read(apiClientProvider);
    client.dio.httpClientAdapter = adapter;
    try {
      await client.dio.get('/api/v1/users/me');
      fail('空地址必须在传输前拒绝请求');
    } catch (error) {
      expect(mapApiError(error), ApiErrorKind.serverNotConfigured);
      expect(cloudOperationFailure(error).code, 'SERVER_NOT_CONFIGURED');
      expect(cloudOperationErrorMessage(error), '未配置服务器地址，请先配置服务器');
    }
    expect(adapter.requests, isEmpty);
    expect(container.read(currentAccountIdProvider), 'account');
    expect((await store.load())?.refreshToken, 'old-refresh');
    final action = await container
        .read(syncCoordinatorProvider)
        .resolveConflictKeepLocal('unused');
    expect(action.error, '未配置服务器地址，请先配置服务器');
  });

  test('401等待读取凭证时清配置不会清除凭证或本机身份', () async {
    configure(address);
    await restoreCachedAccount();
    final readStarted = Completer<void>();
    final releaseRead = Completer<void>();
    final adapter = _Adapter()
      ..respond = (_) async {
        raw.beforeRead = () async {
          if (!readStarted.isCompleted) readStarted.complete();
          await releaseRead.future;
        };
        return ResponseBody.fromString('{}', 401);
      };
    container.read(apiClientProvider).dio.httpClientAdapter = adapter;
    final refreshing = container.read(authSessionProvider.notifier).refresh();
    await readStarted.future;
    configure('');
    releaseRead.complete();
    expect(await refreshing, '');
    raw.beforeRead = null;
    expect((await store.load())?.refreshToken, 'old-refresh');
    expect(container.read(currentAccountIdProvider), 'account');
  });

  test('旧轮换结束前恢复配置会串行使用新凭证重新恢复', () async {
    configure(address);
    await restoreCachedAccount();
    final entered = Completer<void>();
    final release = Completer<ResponseBody>();
    container.read(apiClientProvider).dio.httpClientAdapter = _Adapter()
      ..respond = (_) {
        entered.complete();
        return release.future;
      };
    final first = container.read(authSessionProvider.notifier).refresh();
    await entered.future;
    configure('');
    configure(address);
    final next = _Adapter()
      ..respond = (request) async {
        expect(request.data, containsPair('refresh_token', 'new-refresh'));
        return _sessionResponse();
      };
    container.read(apiClientProvider).dio.httpClientAdapter = next;
    final recovered = container.read(authSessionProvider.notifier).refresh();
    release.complete(_sessionResponse());
    expect(await first, '');
    expect(await recovered, 'new-access');
    expect(next.requests, hasLength(1));
  });

  test('重新配置地址会重新执行启动恢复，旧账号不需要确认服务器归属', () async {
    await restoreCachedAccount();
    final subscription = container.listen(
      accountStartupRefreshProvider,
      (_, _) {},
    );
    await container.read(accountStartupRefreshProvider.future);
    expect(container.read(authSessionProvider), isNull);
    configure('https://other.test');
    final adapter = _Adapter()..respond = (_) async => _sessionResponse();
    container.read(apiClientProvider).dio.httpClientAdapter = adapter;
    await container.read(accountStartupRefreshProvider.future);
    expect(container.read(cloudCapabilityProvider).canSync, isTrue);
    expect(adapter.requests, hasLength(1));
    expect(adapter.requests.single.baseUrl, 'https://other.test');
    subscription.close();
  });

  test('同服务配置移除后恢复不会沿用旧同步服务的操作范围', () async {
    configure(address);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'access',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    final service = container.read(syncServiceProvider);
    expect(service.runtime.currentAccountIdForCloudOperation('测试'), 'account');
    configure('');
    expect(() => service.runtime.requireAccount('account'), throwsStateError);
    configure(address);
    expect(() => service.runtime.requireAccount('account'), throwsStateError);
    expect(
      container
          .read(syncServiceProvider)
          .runtime
          .currentAccountIdForCloudOperation('测试'),
      'account',
    );
  });

  test('登录候选提交等待读取时切服务不会覆盖账号或激活旧令牌', () async {
    configure(address);
    await restoreCachedAccount();
    final entered = Completer<void>();
    final release = Completer<void>();
    raw.beforeRead = () async {
      if (!entered.isCompleted) entered.complete();
      await release.future;
    };
    final committing = container
        .read(accountSwitchCoordinatorProvider)
        .commitLogin(
          candidate: const CandidateSession(
            session: AuthSession(
              accessToken: 'candidate-access',
              userId: 'account',
              deviceId: 'device',
            ),
            refreshToken: 'candidate-refresh',
            profile: CloudProfile(
              userId: 'account',
              sesameNumber: '123456789',
              displayName: '候选',
            ),
          ),
          onReconnect: null,
        );
    await entered.future;
    configure('https://other.test');
    release.complete();
    expect(await committing, isFalse);
    raw.beforeRead = null;
    expect((await store.load())?.refreshToken, 'old-refresh');
    expect(container.read(authSessionProvider), isNull);
    expect(container.read(currentAccountIdProvider), 'account');
  });

  test('第三方自动备份上传关闭不影响账号认证和增量同步资格', () async {
    SharedPreferences.setMockInitialValues({'auto_sync': false});
    configure(address);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'access',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    expect(container.read(cloudCapabilityProvider).canAuthenticate, isTrue);
    expect(container.read(cloudCapabilityProvider).canSync, isTrue);
    container
        .read(memoDirectoryStatusProvider.notifier)
        .setStatus(BookDirectoryStatus.ready);
    container.read(authSessionProvider.notifier).updateToken('rotated');
    expect(
      container.read(memoDirectoryStatusProvider),
      BookDirectoryStatus.ready,
    );
  });

  test('同一个账号可在不同服务器正常登录，已有云本和待上传数据保持原样', () async {
    await restoreCachedAccount();
    final repo = container.read(memoRepositoryProvider);
    final book = await repo.createBook(
      id: '44444444-4444-4444-8444-444444444444',
      name: '已有云本',
      type: 'normal',
      storageMode: 'cloud',
      accountId: 'account',
    );
    final before = await db.select(db.syncChanges).get();
    for (final url in [address, 'https://other.test']) {
      configure(url);
      final adapter = _Adapter();
      container.read(apiClientProvider).dio.httpClientAdapter = adapter;
      final result = await container
          .read(accountSwitchCoordinatorProvider)
          .commitLogin(
            candidate: const CandidateSession(
              session: AuthSession(
                accessToken: 'candidate-access',
                userId: 'account',
                deviceId: 'device',
              ),
              refreshToken: 'candidate-refresh',
              profile: CloudProfile(
                userId: 'account',
                sesameNumber: '123456789',
                displayName: '同一账号',
              ),
            ),
            onReconnect: null,
          );
      expect(result, isTrue);
      expect((await store.load())?.refreshToken, 'candidate-refresh');
      expect(
        (await repo.getBook(book.id, accountId: 'account'))?.storageMode,
        'cloud',
      );
      expect(await db.select(db.syncChanges).get(), before);
      expect(await db.select(db.memoBooks).get(), hasLength(1));
      expect(adapter.requests, isEmpty);
      expect(await store.loadLogoutMarkers(), isEmpty);
    }
  });
}
