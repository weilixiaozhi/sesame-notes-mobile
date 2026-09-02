// 启动恢复收尾测试：pending_local_move 隐藏 Fork 在服务端已删除源账本时发布。
//
// 锚点（13.3）：服务端删除成功而本地发布失败（崩溃）后，重启仍能发布完整 Fork。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSyncService sync;
  late _MockAuthService auth;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    sync = _MockSyncService();
    auth = _MockAuthService();
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
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

  test('崩溃恢复：服务端已删除源账本时，重启发布隐藏 Fork 为正式本地账本', () async {
    // 模拟崩溃现场：源云账本行仍在，隐藏 Fork 已建（pending_local_move）
    await repo.createBoundLedger(id: 'src-1', name: '源云账本', syncId: 'sync-1');
    await (db.update(db.ledgers)..where((l) => l.id.equals('src-1'))).write(
      LedgersCompanion(scopeAccountId: d.Value(userA)),
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
    await repo.createBoundLedger(id: 'src-2', name: '源云账本', syncId: 'sync-2');
    await (db.update(db.ledgers)..where((l) => l.id.equals('src-2'))).write(
      LedgersCompanion(scopeAccountId: d.Value(userA)),
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
}
