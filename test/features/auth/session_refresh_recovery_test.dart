import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../../helpers/realtime_test_stub.dart';
import '../../helpers/bound_ledger_seed.dart';

/// 使用内存凭证覆盖安全存储，避免测试触碰真实账号。
class _MemoryStore implements SecureStore {
  String? value;
  Future<void> Function(String value)? beforeWrite;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async {
    await beforeWrite?.call(value);
    this.value = value;
  }

  @override
  Future<void> delete() async => value = null;
}

class _MockSyncService extends Mock implements SyncService {}

/// 按请求生成响应，允许精确控制刷新与业务请求的交错顺序。
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}

/// 生成实际认证契约所需的完整会话响应。
ResponseBody _response(int status, {bool session = false}) =>
    ResponseBody.fromString(
      jsonEncode(
        session
            ? {
                'access_token': 'new-access',
                'refresh_token': 'new-refresh',
                'token_type': 'Bearer',
                'expires_in': 900,
                'device_id': 'device-1',
                'scopes': ['sync:read'],
                'user': {
                  'user_id': 'user-1',
                  'sesame_number': '123456789',
                  'display_name': '恢复后的昵称',
                  'avatar_url': null,
                  'avatar_version': 0,
                  'phone': '+8613800138000',
                  'gender': 'UNSPECIFIED',
                  'is_admin': false,
                },
              }
            : {'code': 'UNAVAILABLE'},
      ),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

/// 让已经投递的异步响应及错误处理完成，不依赖机器运行速度。
Future<void> _settle() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late SesameDatabase db;
  late LocalRepository repo;
  late _MemoryStore raw;
  late _MemoryStore rawMarkers;
  late _MockSyncService sync;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    raw = _MemoryStore();
    rawMarkers = _MemoryStore();
    await raw.write(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'old-refresh',
      ).encode(),
    );
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    sync = _MockSyncService();
    when(() => sync.refreshCategoryConflicts()).thenAnswer((_) async {});
    when(sync.synchronize).thenAnswer((_) async => 2);
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(raw, logoutMarkerStore: rawMarkers),
        ),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync),
        realtimeNoopOverride,
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  for (final accountRefresh in [false, true]) {
    test('启动断网后${accountRefresh ? '账本列表' : '云账本'}下拉恢复会话并同步，无需重启', () async {
      if (!accountRefresh) {
        await seedBoundLedger(db, accountId: null, id: 'cloud-1', name: '云账本');
      }
      var refreshCalls = 0;
      final firstAttempt = Completer<void>();
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
        options,
      ) {
        expect(options.path, '/api/v1/auth/refresh');
        refreshCalls++;
        if (refreshCalls == 1) {
          firstAttempt.complete();
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          );
        }
        return _response(200, session: true);
      });
      await container.read(accountBootstrapProvider.future);
      // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
      unawaited(container.read(accountStartupRefreshProvider.future));
      await firstAttempt.future;
      await _settle();
      expect(container.read(authSessionProvider), isNull);
      expect(container.read(accountStateProvider).isAuthenticated, isTrue);
      final before = container.read(manualDataRefreshProvider);

      final result = await container
          .read(syncCoordinatorProvider)
          .refreshData(ledgerId: accountRefresh ? null : 'cloud-1');

      expect(result.ok, isTrue);
      expect(result.refreshOutcome, DataRefreshOutcome.cloudSynced);
      expect(refreshCalls, 2);
      expect(container.read(authSessionProvider)?.accessToken, 'new-access');
      expect(
        container.read(accountStateProvider).profile?.displayName,
        '恢复后的昵称',
      );
      expect(container.read(manualDataRefreshProvider), before + 1);
      verifyInOrder([sync.synchronize, sync.refreshCategoryConflicts]);
    });
  }

  test('启动刷新与 HTTP 401 并发时只轮换一次，业务请求等待同一轮提交', () async {
    var refreshCalls = 0;
    final started = Completer<void>();
    final release = Completer<void>();
    final unauthorized = Completer<void>();
    final dio = container.read(apiClientProvider).dio;
    dio.httpClientAdapter = _Adapter((options) async {
      if (options.path == '/api/v1/auth/refresh') {
        refreshCalls++;
        if (!started.isCompleted) started.complete();
        await release.future;
        return _response(200, session: true);
      }
      if (options.headers['Authorization'] == 'Bearer new-access') {
        return _response(200);
      }
      if (!unauthorized.isCompleted) unauthorized.complete();
      return _response(401);
    });
    await container.read(accountBootstrapProvider.future);
    // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    await started.future;
    final request = dio.get<dynamic>('/protected');
    await unauthorized.future;
    await _settle();
    release.complete();
    final result = await request;
    await _settle();

    expect(result.statusCode, 200);
    expect(refreshCalls, 1, reason: '同一旧 Refresh Token 只能轮换一次');
    expect(raw.value, contains('new-refresh'));
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
  });

  for (final status in [400, 403, 429, 500]) {
    test('刷新返回 $status 时保留凭证、会话及云账本，下次请求仍可重试', () async {
      await seedBoundLedger(db, accountId: null, id: 'cloud-1', name: '云账本');
      container
          .read(accountStateProvider.notifier)
          .restorePending(userId: 'user-1');
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'expired',
              userId: 'user-1',
              deviceId: 'device-1',
            ),
          );
      final dio = container.read(apiClientProvider).dio;
      var refreshCalls = 0;
      dio.httpClientAdapter = _Adapter((options) {
        if (options.path == '/api/v1/auth/refresh') refreshCalls++;
        return _response(options.path == '/api/v1/auth/refresh' ? status : 401);
      });

      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      await expectLater(
        dio.get<dynamic>('/protected'),
        throwsA(isA<DioException>()),
      );
      await _settle();

      expect(refreshCalls, 2, reason: '两次请求均应真正尝试刷新，不得提前退出或误登出');
      expect(raw.value, contains('old-refresh'));
      expect(container.read(authSessionProvider)?.accessToken, 'expired');
      expect(container.read(accountStateProvider).isAuthenticated, isTrue);
      expect(await repo.getLedgerById('cloud-1'), isNotNull);
    });
  }

  for (final restore in [false, true]) {
    test('${restore ? '全量恢复' : '退出清理'}期间下拉不得恢复会话或启动同步', () async {
      var refreshCalls = 0;
      container
          .read(accountStateProvider.notifier)
          .restorePending(userId: 'user-1');
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
        options,
      ) {
        refreshCalls++;
        return _response(200, session: true);
      });
      if (restore) {
        container.read(restoreGateProvider.notifier).hold();
      } else {
        container.read(syncGateProvider.notifier).hold();
      }

      final result = await container
          .read(syncCoordinatorProvider)
          .refreshData();

      expect(result.ok, isFalse, reason: '闸门必须保留暂停提示，不能伪报刷新成功');
      expect(refreshCalls, 0);
      verifyNever(sync.synchronize);
    });
  }

  for (final status in [200, 401]) {
    test('退出清理已开始、凭证尚未删除时迟到 $status 不提交或清理账号', () async {
      final started = Completer<void>();
      final release = Completer<void>();
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
        options,
      ) async {
        started.complete();
        await release.future;
        return _response(status, session: status == 200);
      });
      await container.read(accountBootstrapProvider.future);
      // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
      unawaited(container.read(accountStartupRefreshProvider.future));
      await started.future;
      container.read(syncGateProvider.notifier).hold();
      release.complete();
      await _settle();

      expect(raw.value, contains('old-refresh'));
      expect(container.read(authSessionProvider), isNull);
      expect(container.read(accountStateProvider).isAuthenticated, isTrue);
      expect(container.read(accountStateProvider).profile, isNull);
      expect(container.read(syncGateProvider), isTrue);
    });
  }

  for (final status in [200, 401]) {
    test('旧账号刷新迟到 $status 不覆盖或清除已切换的新账号', () async {
      final started = Completer<void>();
      final release = Completer<void>();
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
        options,
      ) async {
        started.complete();
        await release.future;
        return _response(status, session: status == 200);
      });
      await container.read(accountBootstrapProvider.future);
      // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
      unawaited(container.read(accountStartupRefreshProvider.future));
      await started.future;
      const next = ActiveCredential(
        userId: 'user-2',
        deviceId: 'device-2',
        refreshToken: 'other-refresh',
      );
      await container.read(secureAccountStoreProvider).save(next);
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'other-access',
              userId: 'user-2',
              deviceId: 'device-2',
            ),
          );
      release.complete();
      await _settle();

      expect(raw.value, next.encode());
      expect(container.read(authSessionProvider)?.userId, 'user-2');
      expect(container.read(accountStateProvider).isAuthenticated, isTrue);
      final markers = await container
          .read(secureAccountStoreProvider)
          .loadLogoutMarkers();
      expect(
        markers.map((marker) => marker.credential.refreshToken),
        status == 200 ? ['new-refresh'] : isEmpty,
        reason: '已收到的旧账号轮换凭证必须留给撤销，401 不能生成新材料',
      );
    });
  }

  test('取消退出后提交服务器已经轮换的凭证，后续刷新仍能成功', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    var refreshCalls = 0;
    final dio = container.read(apiClientProvider).dio;
    dio.httpClientAdapter = _Adapter((options) async {
      if (options.path == '/api/v1/auth/refresh') {
        refreshCalls++;
        if (refreshCalls == 1) {
          started.complete();
          await release.future;
        } else {
          expect(
            options.data,
            containsPair('refresh_token', 'new-refresh'),
            reason: '退出被取消后必须沿用服务端已经轮换的新凭证',
          );
        }
        return _response(200, session: true);
      }
      return _response(
        options.headers['Authorization'] == 'Bearer new-access' ? 200 : 401,
      );
    });
    await container.read(accountBootstrapProvider.future);
    // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
    unawaited(container.read(accountStartupRefreshProvider.future));
    await started.future;
    final gate = container.read(syncGateProvider.notifier);
    gate.hold();
    release.complete();
    await _settle();
    expect(container.read(authSessionProvider), isNull);

    // 退出预检被未同步数据阻断：原账号保留，清理闸门按 finally 释放。
    gate.release();
    await _settle();
    expect(raw.value, contains('new-refresh'));
    expect(container.read(authSessionProvider)?.accessToken, 'new-access');
    expect((await dio.get<dynamic>('/protected')).statusCode, 200);
    expect(refreshCalls, 2);
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
    expect(rawMarkers.value, isNull, reason: '取消退出后正常提交的轮换凭证不进入撤销待办');
  });

  for (final status in [200, 401]) {
    test('退出完成后释放闸门不会被已到达的 $status 刷新结果重新登录', () async {
      final started = Completer<void>();
      final release = Completer<void>();
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
        options,
      ) async {
        started.complete();
        await release.future;
        return _response(status, session: status == 200);
      });
      await container.read(accountBootstrapProvider.future);
      // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
      unawaited(container.read(accountStartupRefreshProvider.future));
      await started.future;
      final gate = container.read(syncGateProvider.notifier);
      gate.hold();
      release.complete();
      await _settle();
      await container.read(secureAccountStoreProvider).clear();
      container.read(accountStateProvider.notifier).signOut();
      gate.release();
      await _settle();

      expect(raw.value, isNull);
      expect(container.read(authSessionProvider), isNull);
      expect(container.read(accountStateProvider).isAuthenticated, isFalse);
      expect(container.read(accountStateProvider).profile, isNull);
      final markers = await container
          .read(secureAccountStoreProvider)
          .loadLogoutMarkers();
      expect(
        markers.map((marker) => marker.credential.refreshToken),
        status == 200 ? ['new-refresh'] : isEmpty,
        reason: '本地退出已完成，闸门释放后仍须接住服务器已轮换的新材料',
      );
    });
  }

  for (final logout in [false, true]) {
    test('凭证轮换写入迟到不会覆盖后发起的${logout ? '退出删除' : '新账号写入'}', () async {
      final writeStarted = Completer<void>();
      final releaseWrite = Completer<void>();
      raw.beforeWrite = (value) async {
        if (value.contains('new-refresh')) {
          writeStarted.complete();
          await releaseWrite.future;
        }
      };
      container.read(apiClientProvider).dio.httpClientAdapter = _Adapter(
        (options) => _response(200, session: true),
      );
      await container.read(accountBootstrapProvider.future);
      // 必需本地初始化完成后，由就绪生命周期触发会话恢复。
      unawaited(container.read(accountStartupRefreshProvider.future));
      await writeStarted.future;
      final gate = container.read(syncGateProvider.notifier);
      gate.hold();
      const next = ActiveCredential(
        userId: 'user-2',
        deviceId: 'device-2',
        refreshToken: 'other-refresh',
      );
      final store = container.read(secureAccountStoreProvider);
      // 安全存储尚未返回时发起后续账号操作，最终落盘结果必须保留调用顺序。
      final transition = logout ? store.clear() : store.save(next);
      await _settle();
      releaseWrite.complete();
      await transition;
      if (logout) {
        container.read(accountStateProvider.notifier).signOut();
      } else {
        container
            .read(authSessionProvider.notifier)
            .signIn(
              const AuthSession(
                accessToken: 'other-access',
                userId: 'user-2',
                deviceId: 'device-2',
              ),
            );
      }
      gate.release();
      await _settle();

      expect(raw.value, logout ? isNull : next.encode());
      expect(
        container.read(authSessionProvider)?.userId,
        logout ? isNull : 'user-2',
      );
      expect(container.read(accountStateProvider).profile, isNull);
      final markers = await store.loadLogoutMarkers();
      expect(markers.map((marker) => marker.credential.refreshToken), [
        'new-refresh',
      ], reason: '迟到的安全存储写入不能使旧账号唯一有效的撤销材料丢失');
    });
  }

  test('退出已清除旧标记后收到轮换响应，下次启动仍能撤销新会话', () async {
    final started = Completer<void>();
    final release = Completer<void>();
    var firstRefresh = true;
    container.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
      options,
    ) async {
      if (firstRefresh) {
        firstRefresh = false;
        started.complete();
        await release.future;
        return _response(200, session: true);
      }
      // 服务端已经消费旧令牌，显式退出只能确认旧材料失效。
      expect(options.data, containsPair('refresh_token', 'old-refresh'));
      return ResponseBody.fromString(
        '{"code":"INVALID_REFRESH_TOKEN"}',
        401,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
    final refresh = container.read(authSessionProvider.notifier).refresh();
    await started.future;
    await container.read(accountSwitchCoordinatorProvider).logout();
    // 后台撤销确认旧材料失效后，再释放尚未返回的令牌轮换响应。
    await container.read(accountRecoveryProvider.future);
    expect(raw.value, isNull);
    expect(rawMarkers.value, isNull);
    expect(container.read(authSessionProvider), isNull);

    release.complete();
    expect(await refresh, isEmpty);
    expect(raw.value, isNull);
    expect(rawMarkers.value, contains('new-refresh'));
    expect(rawMarkers.value, isNot(contains('old-refresh')));
    expect(container.read(authSessionProvider), isNull);

    final restarted = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            raw,
            pendingStore: _MemoryStore(),
            logoutMarkerStore: rawMarkers,
          ),
        ),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(restarted.dispose);
    final requests = <String>[];
    restarted.read(apiClientProvider).dio.httpClientAdapter = _Adapter((
      options,
    ) {
      requests.add(options.path);
      expect(options.data, containsPair('refresh_token', 'new-refresh'));
      return options.path.endsWith('/refresh')
          ? _response(200, session: true)
          : ResponseBody.fromString('', 204);
    });
    await restarted.read(accountRecoveryProvider.future);
    expect(requests, ['/api/v1/auth/refresh', '/api/v1/auth/logout']);
    expect(rawMarkers.value, isNull);
    expect(raw.value, isNull);
    expect(restarted.read(authSessionProvider), isNull);
  });
}
