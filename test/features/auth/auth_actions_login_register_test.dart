import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/infrastructure/account/auth_service.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';

import '../../helpers/realtime_test_stub.dart';
import '../../helpers/test_isolation.dart';

class _MockAuthService extends Mock implements AuthService {}

/// 保留真实账号提交，只替代同步网络操作。
class _MockSyncCoordinator extends Mock implements SyncCoordinator {
  @override
  Future<T> runAccountTransition<T>(Future<T> Function() action) async =>
      await action();
}

class _MemorySecureStore implements SecureStore {
  String? value;
  Future<void> Function()? beforeWrite;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async {
    await beforeWrite?.call();
    value = v;
  }

  @override
  Future<void> delete() async => value = null;
}

/// 测试后台撤销与真实认证用例在同一容器内竞争。
final _refProvider = Provider<Ref>((ref) => ref);

void main() {
  // 偏好缓存通过测试平台通道读写。
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(
      const ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'fallback',
      ),
    );
  });

  late ProviderContainer container;
  late _MockAuthService auth;
  late _MockSyncCoordinator sync;
  late SesameDatabase db;
  late _MemorySecureStore activeStore;

  setUp(() async {
    resetGlobalTestState();
    auth = _MockAuthService();
    sync = _MockSyncCoordinator();
    activeStore = _MemorySecureStore();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        authServiceProvider.overrideWithValue(auth),
        syncCoordinatorProvider.overrideWithValue(sync),
        databaseProvider.overrideWithValue(db),
        realtimeNoopOverride,
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            activeStore,
            pendingStore: _MemorySecureStore(),
            logoutMarkerStore: _MemorySecureStore(),
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(
          CloudProfileCache(await SharedPreferences.getInstance()),
        ),
      ],
    );
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: 'local-memo',
            name: '本地本',
            type: 'normal',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 登录成功：候选会话 + 重连成功。
  void stubLoginSuccess() {
    when(
      () => auth.login(
        countryCode: '+86',
        phone: '13800138000',
        password: 'secret123',
      ),
    ).thenAnswer(
      (_) async => CandidateSession(
        session: const AuthSession(
          accessToken: 'access-token',
          userId: 'user-1',
          deviceId: 'device-1',
        ),
        refreshToken: 'refresh-1',
        profile: const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
        ),
      ),
    );
    when(() => sync.reconnect()).thenAnswer(
      (_) async => const ReconnectReport(refreshed: [], stale: [], gone: []),
    );
  }

  test('登录成功：以 +86 调用认证服务并原子提交会话、凭证与登录态', () async {
    stubLoginSuccess();

    final ok = await container
        .read(authActionsProvider)
        .login(countryCode: '+86', phone: '13800138000', password: 'secret123');

    expect(ok, isTrue);
    verify(
      () => auth.login(
        countryCode: '+86',
        phone: '13800138000',
        password: 'secret123',
      ),
    ).called(1);
    // 协调器原子提交：会话注入 + refreshToken 落盘 + authenticated
    final session = container.read(authSessionProvider);
    expect(session?.accessToken, 'access-token');
    expect(session?.deviceId, 'device-1');
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
    expect((await db.select(db.memoBooks).getSingle()).storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      (await container.read(secureAccountStoreProvider).load())?.refreshToken,
      'refresh-1',
    );
    // 提交成功后才触发一次重连
    verify(() => sync.reconnect()).called(1);
  });

  test('登录失败：不建立会话、凭证不落盘，也不触发重连', () async {
    when(
      () => auth.login(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenThrow(Exception('bad credentials'));

    await expectLater(
      container
          .read(authActionsProvider)
          .login(
            countryCode: '+86',
            phone: '13800138000',
            password: 'secret123',
          ),
      throwsA(isA<Exception>()),
    );

    expect(container.read(authSessionProvider), isNull);
    expect(container.read(accountStateProvider).isAuthenticated, isFalse);
    expect(await container.read(secureAccountStoreProvider).load(), isNull);
    verifyNever(() => sync.reconnect());
  });

  test('注册成功：以 +86 调用认证服务并经协调器提交候选凭证', () async {
    when(
      () => auth.register(
        countryCode: '+86',
        phone: '13800138000',
        password: 'pass-1',
      ),
    ).thenAnswer(
      (_) async => CandidateSession(
        session: const AuthSession(
          accessToken: 't',
          userId: 'user-1',
          deviceId: 'd',
        ),
        refreshToken: 'rt',
        profile: const CloudProfile(userId: 'user-1'),
      ),
    );
    when(() => sync.reconnect()).thenAnswer(
      (_) async => const ReconnectReport(refreshed: [], stale: [], gone: []),
    );

    final ok = await container
        .read(authActionsProvider)
        .register(countryCode: '+86', phone: '13800138000', password: 'pass-1');

    expect(ok, isTrue);
    verify(
      () => auth.register(
        countryCode: '+86',
        phone: '13800138000',
        password: 'pass-1',
      ),
    ).called(1);
    expect(container.read(authSessionProvider)?.userId, 'user-1');
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
    expect((await db.select(db.memoBooks).getSingle()).storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      (await container.read(secureAccountStoreProvider).load())?.refreshToken,
      'rt',
    );
  });

  for (final register in [false, true]) {
    for (final revocationFails in [false, true]) {
      test(
        '${register ? '注册' : '登录'}等待在途撤销结束，${revocationFails ? '撤销失败保留材料' : '撤销成功'}后才发新认证',
        () async {
          stubLoginSuccess();
          when(
            () => auth.register(
              countryCode: '+86',
              phone: '13800138000',
              password: 'secret123',
            ),
          ).thenAnswer(
            (_) async => const CandidateSession(
              session: AuthSession(
                accessToken: 'new',
                userId: 'user-1',
                deviceId: 'device-1',
              ),
              refreshToken: 'new-refresh',
              profile: CloudProfile(userId: 'user-1'),
            ),
          );
          const credential = ActiveCredential(
            userId: 'user-1',
            deviceId: 'device-1',
            refreshToken: 'old',
          );
          final store = container.read(secureAccountStoreProvider);
          await store.saveLogoutMarker(
            const LogoutMarker(credential: credential),
          );
          final entered = Completer<void>();
          final response = Completer<SessionRevocationResult>();
          when(
            () => auth.revokeServerSession(
              any(),
              persistRotatedCredential: any(named: 'persistRotatedCredential'),
            ),
          ).thenAnswer((_) {
            entered.complete();
            return response.future;
          });
          final revocation = revokePendingCredential(
            container.read(_refProvider),
            credential,
          );
          await entered.future;
          final actions = container.read(authActionsProvider);
          final authentication = register
              ? actions.register(
                  countryCode: '+86',
                  phone: '13800138000',
                  password: 'secret123',
                )
              : actions.login(
                  countryCode: '+86',
                  phone: '13800138000',
                  password: 'secret123',
                );
          try {
            await pumpEventQueue();
            verifyNever(
              () => auth.login(
                countryCode: any(named: 'countryCode'),
                phone: any(named: 'phone'),
                password: any(named: 'password'),
              ),
            );
            verifyNever(
              () => auth.register(
                countryCode: any(named: 'countryCode'),
                phone: any(named: 'phone'),
                password: any(named: 'password'),
              ),
            );
            expect(container.read(authSessionProvider), isNull);
            // 等待仅作用于认证，普通本机数据仍能立即读写。
            await db.customStatement(
              "UPDATE memo_books SET name='等待认证时仍可编辑' WHERE id='local-memo'",
            );
            expect(
              (await db.select(db.memoBooks).getSingle()).name,
              '等待认证时仍可编辑',
            );
          } finally {
            if (revocationFails) {
              response.completeError(StateError('撤销请求已失败'));
            } else {
              response.complete(SessionRevocationResult.revoked);
            }
            await revocation;
          }
          expect(await authentication, isTrue);
          expect(container.read(authSessionProvider)?.userId, 'user-1');
          await container.read(accountRecoveryProvider.future);
          verify(
            () => auth.revokeServerSession(
              any(),
              persistRotatedCredential: any(named: 'persistRotatedCredential'),
            ),
          ).called(1);
          expect(
            await store.loadLogoutMarkers(),
            revocationFails ? hasLength(1) : isEmpty,
          );
        },
      );
    }
  }

  test('候选凭证提交期间恢复等待，不能清除或撤销正在提交的新会话', () async {
    stubLoginSuccess();
    final entered = Completer<void>();
    final release = Completer<void>();
    activeStore.beforeWrite = () {
      entered.complete();
      return release.future;
    };
    final store = container.read(secureAccountStoreProvider);
    final login = container
        .read(authActionsProvider)
        .login(countryCode: '+86', phone: '13800138000', password: 'secret123');
    await entered.future;
    final recovery = container.read(accountRecoveryProvider.future);
    try {
      await pumpEventQueue();
      expect((await store.loadPending())?.refreshToken, 'refresh-1');
      expect(await store.loadLogoutMarkers(), isEmpty);
    } finally {
      activeStore.beforeWrite = null;
      release.complete();
      expect(await login, isTrue);
      await recovery;
    }
    verifyNever(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    );
    expect((await store.load())?.refreshToken, 'refresh-1');
    expect(await store.loadPending(), isNull);
    expect(await store.loadLogoutMarkers(), isEmpty);
  });

  test('服务器缺失在等待撤销之前立即返回专用错误', () async {
    when(
      auth.ensureServerConfigured,
    ).thenThrow(const ServerNotConfiguredException());
    final entered = Completer<void>();
    final response = Completer<SessionRevocationResult>();
    const credential = ActiveCredential(
      userId: 'old-user',
      deviceId: 'old-device',
      refreshToken: 'old',
    );
    final store = container.read(secureAccountStoreProvider);
    await store.saveLogoutMarker(const LogoutMarker(credential: credential));
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((_) {
      entered.complete();
      return response.future;
    });
    final revocation = revokePendingCredential(
      container.read(_refProvider),
      credential,
    );
    await entered.future;
    try {
      await expectLater(
        container
            .read(authActionsProvider)
            .login(
              countryCode: '+86',
              phone: '13800138000',
              password: 'secret123',
            ),
        throwsA(isA<ServerNotConfiguredException>()),
      );
      expect(response.isCompleted, isFalse);
    } finally {
      response.complete(SessionRevocationResult.revoked);
      await revocation;
    }
  });
}
