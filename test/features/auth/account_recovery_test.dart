import 'dart:async';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_service.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import '../../helpers/bound_ledger_seed.dart';

class _MemorySecureStore implements SecureStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async => value = v;
  @override
  Future<void> delete() async => value = null;
}

class _MockSyncService extends Mock implements SyncService {}

class _MockAuthService extends Mock implements AuthService {}

const userA = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

/// 直接调用撤销入口，与启动恢复和退出后台任务共用实际 Ref。
final _refProvider = Provider<Ref>((ref) => ref);

/// 验证后台恢复按当前身份与服务器配置处理持久待办。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(
      const ActiveCredential(
        userId: userA,
        deviceId: 'device',
        refreshToken: 'fallback',
      ),
    );
  });

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSyncService sync;
  late _MockAuthService auth;
  late ProviderContainer container;
  late String apiBaseUrl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    sync = _MockSyncService();
    auth = _MockAuthService();
    apiBaseUrl = 'https://example.test';
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWith((ref) => ApiConfig(baseUrl: apiBaseUrl)),
        authServiceProvider.overrideWithValue(auth),
        syncServiceProvider.overrideWithValue(sync),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            _MemorySecureStore(),
            pendingStore: _MemorySecureStore(),
            logoutMarkerStore: _MemorySecureStore(),
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 恢复场景拥有有效云会话，远端查询只能处理该账号的源本。
  void signIn() {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'test-token',
            userId: userA,
            deviceId: 'device',
          ),
        );
  }

  /// 准备一个已持久化、等待远端确认的本地副本。
  Future<void> seedPendingMove(String sourceId, String forkId) async {
    try {
      await seedBoundLedger(
        db,
        accountId: userA,
        id: sourceId,
        name: '源云账本',
        syncId: 'sync-$sourceId',
        ownerAccountId: userA,
      );
      await repo.forkCloudLedgerToLocalPendingMove(
        sourceLedgerId: sourceId,
        newLedgerId: forkId,
        localSelfId: 'device-self',
        currentAccountId: userA,
        originSyncId: 'sync-$sourceId',
      );
    } catch (error, stackTrace) {
      fail('恢复夹具准备失败：$error\n$stackTrace');
    }
  }

  test('崩溃恢复：服务端已删除源账本时，重启发布隐藏 Fork 为正式本地账本', () async {
    signIn();
    // 模拟崩溃现场：源云账本行仍在，隐藏 Fork 已建（pending_local_move）
    await seedBoundLedger(
      db,
      accountId: userA,
      id: 'src-1',
      name: '源云账本',
      syncId: 'sync-1',
      ownerAccountId: userA,
    );
    final forkId = 'fork-1';
    await repo.forkCloudLedgerToLocalPendingMove(
      sourceLedgerId: 'src-1',
      newLedgerId: forkId,
      localSelfId: 'device-self',
      currentAccountId: userA,
      originSyncId: 'sync-1',
    );
    // 远端已删除（崩溃前 delete 已 accepted）
    when(
      () => sync.fetchLedgerRemoteStatus('src-1'),
    ).thenAnswer((_) async => (deleted: true));

    await container.read(accountRecoveryProvider.future);

    // 隐藏 Fork 发布：binding 置空、源行清除，账本可正常列出
    final fork = await repo.getLedgerById(forkId);
    expect(fork, isNotNull);
    expect(fork!.bindingStatus, isNull, reason: '发布后隐藏 intent 置空');
    expect(fork.storageMode, 'local');
    expect(await repo.getLedgerById('src-1'), isNull, reason: '旧云缓存整本清除');
    expect(await repo.getAllLedgers(), hasLength(1));
  });

  test('崩溃恢复：云端仍存活时保留隐藏 Fork，等待用户重试', () async {
    signIn();
    await seedBoundLedger(
      db,
      accountId: userA,
      id: 'src-2',
      name: '源云账本',
      syncId: 'sync-2',
      ownerAccountId: userA,
    );
    await repo.forkCloudLedgerToLocalPendingMove(
      sourceLedgerId: 'src-2',
      newLedgerId: 'fork-2',
      localSelfId: 'device-self',
      currentAccountId: userA,
      originSyncId: 'sync-2',
    );
    when(
      () => sync.fetchLedgerRemoteStatus('src-2'),
    ).thenAnswer((_) async => (deleted: false));

    await container.read(accountRecoveryProvider.future);

    expect(await repo.getLedgerById('src-2'), isNotNull, reason: '云端存活则源行保留');
    final fork = await repo.getLedgerById('fork-2');
    expect(fork!.bindingStatus, 'pending_local_move', reason: '保持隐藏 intent');
  });

  test('远端删除回执在途期间来源换绑，不能删除新的时间线', () async {
    signIn();
    await seedPendingMove('rebound-source', 'pending-fork');
    final started = Completer<void>();
    final response = Completer<({bool deleted})>();
    when(() => sync.fetchLedgerRemoteStatus('rebound-source')).thenAnswer((_) {
      started.complete();
      return response.future;
    });
    final recovering = container.read(accountRecoveryProvider.future);
    await started.future;
    await (db.update(db.ledgers)
          ..where((row) => row.id.equals('rebound-source')))
        .write(const LedgersCompanion(syncId: d.Value('new-binding')));
    response.complete((deleted: true));
    await recovering;
    expect((await repo.getLedgerById('rebound-source'))?.syncId, 'new-binding');
    expect(
      (await repo.getLedgerById('pending-fork'))?.bindingStatus,
      'pending_local_move',
    );
  });

  test('未登录恢复不查询云本，源行缺失的本地副本仍能发布', () async {
    const waitingId = '11111111-1111-4111-8111-111111111111';
    const readyId = '22222222-2222-4222-8222-222222222222';
    await seedPendingMove('still-cloud', waitingId);
    await seedPendingMove('removed-cloud', readyId);
    await (db.delete(
      db.ledgers,
    )..where((row) => row.id.equals('removed-cloud'))).go();

    await container.read(accountRecoveryProvider.future);

    verifyZeroInteractions(sync);
    expect(
      (await repo.getLedgerById(waitingId))?.bindingStatus,
      'pending_local_move',
    );
    expect((await repo.getLedgerById(readyId))?.bindingStatus, isNull);
    expect((await repo.getLedgerById(readyId))?.storageMode, 'local');
  });

  test('未配置服务器时保存撤销待办，不发起远端请求', () async {
    apiBaseUrl = '';
    const credential = ActiveCredential(
      userId: userA,
      deviceId: 'device',
      refreshToken: 'pending-refresh',
    );
    final store = container.read(secureAccountStoreProvider);
    await store.saveLogoutMarker(const LogoutMarker(credential: credential));

    await container.read(accountRecoveryProvider.future);

    verifyZeroInteractions(auth);
    verifyZeroInteractions(sync);
    expect(
      (await store.loadLogoutMarkers()).single.credential.encode(),
      credential.encode(),
    );
  });

  test('退出与恢复共用账号设备单飞，轮换后的材料也不重复撤销', () async {
    const credential = ActiveCredential(
      userId: userA,
      deviceId: 'device',
      refreshToken: 'original',
    );
    const rotated = ActiveCredential(
      userId: userA,
      deviceId: 'device',
      refreshToken: 'rotated',
    );
    final store = container.read(secureAccountStoreProvider);
    await store.saveLogoutMarker(const LogoutMarker(credential: credential));
    final entered = Completer<void>();
    final response = Completer<SessionRevocationResult>();
    when(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).thenAnswer((invocation) async {
      final persist =
          invocation.namedArguments[#persistRotatedCredential]
              as Future<void> Function(ActiveCredential);
      await persist(rotated);
      entered.complete();
      return response.future;
    });
    final first = revokePendingCredential(
      container.read(_refProvider),
      credential,
    );
    await entered.future;
    final second = revokePendingCredential(
      container.read(_refProvider),
      rotated,
    );
    final recovery = container.read(accountRecoveryProvider.future);
    try {
      await pumpEventQueue();
      expect(identical(first, second), isTrue);
      expect(
        (await store.loadLogoutMarkers()).single.credential.refreshToken,
        'rotated',
      );
    } finally {
      response.complete(SessionRevocationResult.revoked);
      await Future.wait([first, second, recovery]);
    }
    verify(
      () => auth.revokeServerSession(
        any(),
        persistRotatedCredential: any(named: 'persistRotatedCredential'),
      ),
    ).called(1);
    expect(await store.loadLogoutMarkers(), isEmpty);
  });

  test('同账号同设备已有新会话时，旧撤销材料保留且不发送按设备登出', () async {
    const old = ActiveCredential(
      userId: userA,
      deviceId: 'device',
      refreshToken: 'old',
    );
    const current = ActiveCredential(
      userId: userA,
      deviceId: 'device',
      refreshToken: 'current',
    );
    final store = container.read(secureAccountStoreProvider);
    await store.saveLogoutMarker(const LogoutMarker(credential: old));
    await store.save(current);
    await revokePendingCredential(container.read(_refProvider), old);
    verifyZeroInteractions(auth);
    expect((await store.load())?.refreshToken, 'current');
    expect(
      (await store.loadLogoutMarkers()).single.credential.refreshToken,
      'old',
    );
  });
}
