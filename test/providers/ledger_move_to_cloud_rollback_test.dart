import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../helpers/ledger_sync_fixture.dart';
import '../helpers/test_isolation.dart';

/// 让 backfill 登记失败的变更登记器：迁云事务中途抛错，用于验证整体回滚。
class _FailingChangeRecorder extends ChangeRecorder {
  _FailingChangeRecorder(this._inner);

  final ChangeRecorder _inner;

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => _inner.recordUserGlobalChange(
    entityType: entityType,
    entityId: entityId,
    action: action,
    payload: payload,
    updatedAt: updatedAt,
  );

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    throw StateError('变更登记失败（测试注入）');
  }

  @override
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes}) =>
      _inner.recordLedgerChanges(changes: changes);

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) => _inner.recordUserGlobalChanges(changes: changes);
}

const testUserId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

/// 迁云失败的原子性：backfill 登记失败必须整体回滚，不留半上云态。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late LedgerSyncFixture sync;
  late ProviderContainer container;
  late DataLifecycleActions actions;

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    sync = LedgerSyncFixture(
      db,
      testUserId,
      localSelfId: () => container.read(localSelfIdProvider.future),
    );
    final recorder = ChangeRecorderImpl(db, accountIdGetter: () => testUserId);
    repo = LocalRepository(
      db,
      accountIdGetter: () => testUserId,
      changeTracker: _FailingChangeRecorder(recorder),
    );
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(sync.service),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'test-token',
            userId: testUserId,
            deviceId: 'device-1',
          ),
        );
    actions = container.read(dataLifecycleProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('迁云 backfill 登记失败：归属、本人引用与变更队列整体回滚', () async {
    final id = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
      localSelfId: 'device-self',
    );
    final localSelfId = localSelfMemberId(id, 'device-self');
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime(2026, 7, 5),
      operatorMemberId: localSelfId,
    );

    await expectLater(
      actions.moveToCloud(SyncTarget('ledger', id)),
      throwsA(isA<StateError>()),
    );

    final row = (await repo.getLedgerById(id))!;
    expect(row.storageMode, 'local', reason: '失败必须整体回滚，不得停在半上云态');
    expect(row.scopeAccountId, isNull, reason: '回滚后不得留下账号域归属');
    expect(row.selfMemberId, localSelfId, reason: '本人成员引用保持原值');
    expect(
      (await repo.getMemberById(localSelfId))!.memberType,
      'LOCAL',
      reason: '本人成员不得被中途替换为 REGISTERED',
    );
    expect(
      (await repo.getTransactionById(txId))!.createdByMemberId,
      localSelfId,
      reason: '交易作者引用不得被中途重写',
    );
    expect(
      await db.select(db.syncChanges).get(),
      isEmpty,
      reason: '失败事务不得留下任何待推送变更',
    );
    expect(await db.select(db.ledgerMembers).get(), hasLength(1));
  });
}
