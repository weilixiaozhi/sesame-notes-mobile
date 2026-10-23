import '../helpers/fitness_space_fixture.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/models/fitness.dart' as fitness;
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';

import '../helpers/test_isolation.dart';
import '../helpers/bound_ledger_seed.dart';

/// 测试入口：取容器内 Ref 直接调用认证 401 清理（与生产调用方同形态）。
final _refProvider = Provider<Ref>((ref) => ref);

/// 给云端账本播种全套同步簿记行（待推送变更/游标/冲突/拉取错误）。
Future<void> seedSyncBookkeeping(
  SesameDatabase db, {
  required String ledgerId,
}) async {
  final now = DateTime.now().toUtc();
  await db
      .into(db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: 'ledger',
          entityId: ledgerId,
          ledgerId: d.Value(ledgerId),
          action: 'upsert',
          payload: '{}',
          updatedAt: now,
          mutationId: const Uuid().v4(),
        ),
      );
  await db
      .into(db.syncState)
      .insert(SyncStateCompanion.insert(deviceId: 'device-1'));
  await db
      .into(db.syncConflicts)
      .insert(
        SyncConflictsCompanion.insert(
          id: const Uuid().v4(),
          accountId: d.Value('account-a'),
          ledgerId: d.Value(ledgerId),
          entityType: 'transaction',
          entityId: 'tx-1',
          localPayload: '{}',
          remotePayload: '{}',
          baseRevision: 1,
          remoteRevision: 2,
          localMutationId: const Uuid().v4(),
        ),
      );
  await db
      .into(db.syncPullErrors)
      .insert(
        SyncPullErrorsCompanion.insert(
          changeId: 'change-1',
          accountId: d.Value('account-a'),
          ledgerId: d.Value(ledgerId),
          entityType: 'transaction',
          entityId: 'tx-2',
          action: 'upsert',
          rawChangeJson: '{}',
          firstSeenAt: now,
          lastAttemptAt: now,
        ),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('认证失效只隔离不清库：云端待办保留，记账初始化水位清空', () async {
    const cloudId = 'cloud-auth-fail';
    await seedBoundLedger(db, accountId: null, id: cloudId, name: '云端账本');
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await seedSyncBookkeeping(db, ledgerId: cloudId);
    final downloads = container.read(cloudLedgerDownloadStoreProvider);
    await downloads.markPending('account-a', cloudId);
    await downloads.markPending(
      'account-a',
      'existing',
      hasLocalSnapshot: true,
    );

    await isolateCloudDataOnAuthFailure(container.read(_refProvider));
    expect(await downloads.pending('account-a'), {cloudId, 'existing'});
    expect(await downloads.unpublished('account-a'), {cloudId});

    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '本机行不能删：重新登录直接恢复，未上传的改动也还在',
    );
    expect(await repo.getLedgerById(localId), isNotNull, reason: '本地账本一行不动');
    expect(
      await db.select(db.syncChanges).get(),
      hasLength(1),
      reason: '待推送变更按账号域保留，同账号重登后补推',
    );
    expect(
      (await db.select(db.syncState).getSingle()).serverCursor,
      isNull,
      reason: '清除已失效的初始化状态，重新认证后先恢复记账完整快照',
    );
    expect(
      await db.select(db.syncConflicts).get(),
      hasLength(1),
      reason: '冲突记录保留待用户决策',
    );
    expect(
      await db.select(db.syncPullErrors).get(),
      hasLength(1),
      reason: '拉取错误保留',
    );
    expect(container.read(syncGateProvider), isFalse, reason: '隔离后必须开闸');
  });

  test('闸门已置起时跳过，不重复清理也不提前开闸', () async {
    const cloudId = 'cloud-skip';
    await seedBoundLedger(db, accountId: null, id: cloudId, name: '云端账本');
    container.read(syncGateProvider.notifier).hold();

    await isolateCloudDataOnAuthFailure(container.read(_refProvider));

    expect(container.read(syncGateProvider), isTrue, reason: '他人置闸不得被提前释放');
    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '置闸时由登出协调器负责清理，此处直接跳过',
    );
    container.read(syncGateProvider.notifier).release();
  });

  test('401保留日子未确认请求、冲突及D水位，供同账号重认证后继续', () async {
    final now = DateTime.utc(2026, 9, 7);
    const id = '11111111-1111-4111-8111-111111111111';
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: id,
            name: '未确认本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            serverRevision: const d.Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'day_book',
            entityId: id,
            dayBookId: const d.Value(id),
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: '{"name":"未确认本"}',
            frozenRequest: const d.Value('original-request'),
            updatedAt: now,
            mutationId: 'pending',
          ),
        );
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'conflict',
            dayBookId: const d.Value(id),
            accountId: d.Value('account-a'),
            entityType: 'day_book',
            entityId: id,
            localPayload: '{}',
            remotePayload: '{}',
            baseRevision: 0,
            remoteRevision: 1,
            localMutationId: 'pending',
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device-1',
            accountId: const d.Value('account-a'),
            serverCursor: const d.Value('10'),
            dayEventsCursor: const d.Value('20'),
            memosCursor: const d.Value('30'),
            fitnessCursor: const d.Value('40'),
          ),
        );
    await isolateCloudDataOnAuthFailure(container.read(_refProvider));
    expect((await db.select(db.dayBooks).getSingle()).name, '未确认本');
    expect(
      (await db.select(db.syncChanges).getSingle()).frozenRequest,
      'original-request',
    );
    expect((await db.select(db.syncConflicts).getSingle()).status, 'OPEN');
    final state = await db.select(db.syncState).getSingle();
    expect(state.dayEventsCursor, '20');
    expect(state.memosCursor, '30');
    expect(state.fitnessCursor, '40');
    expect(state.serverCursor, isNull);
  });

  test('认证失效保留健身冻结请求、冲突、缓存及独立水位', () async {
    const account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    final fitnessRepo = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    ));
    final template = await fitnessRepo.saveTemplate(
      fitness.FitnessTemplate(
        exercises: const [
          fitness.FitnessExercise(
            id: '66666666-6666-4666-8666-666666666666',
            exerciseId: '0025',
          ),
        ],
        name: '隔离模板',
      ),
    );
    await db
        .update(db.syncChanges)
        .write(
          const SyncChangesCompanion(frozenRequest: d.Value('frozen-original')),
        );
    final entity = await db.select(db.fitnessEntities).getSingle();
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: const Uuid().v4(),
            accountId: d.Value(account),
            entityType: 'fitness_template',
            entityId: template.id,
            localPayload: entity.payload,
            remotePayload: entity.payload,
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'test',
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'fitness-device',
            accountId: const d.Value(account),
            fitnessCursor: const d.Value('30'),
          ),
        );
    await isolateCloudDataOnAuthFailure(container.read(_refProvider));
    expect(
      (await db.select(db.fitnessEntities).getSingle()).payload,
      entity.payload,
    );
    expect(
      (await db.select(db.syncChanges).getSingle()).frozenRequest,
      'frozen-original',
    );
    expect((await db.select(db.syncConflicts).getSingle()).status, 'OPEN');
    expect((await db.select(db.syncState).getSingle()).fitnessCursor, '30');
  });

  test('隔离过程抛错也恢复闸门（finally 语义）', () async {
    // 关库让水位写入必然失败：异常路径同样不能把闸门永久关死。
    await db.close();

    await isolateCloudDataOnAuthFailure(container.read(_refProvider));

    expect(
      container.read(syncGateProvider),
      isFalse,
      reason: '隔离失败也绝不能让闸门永久关闭',
    );
  });
}
