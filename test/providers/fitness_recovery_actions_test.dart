import '../helpers/fitness_space_fixture.dart';
import '../helpers/fitness_running_fixture.dart';
import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_recovery_actions_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late FitnessRepository repo;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    repo = (await createFitnessTestRepository(db));
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> branch(
    String canonical, {
    String? target,
    String name = '备份版本',
  }) async {
    final local = await (db.select(
      db.fitnessEntities,
    )..where((e) => e.id.equals(canonical))).getSingle();
    final id = 'branch-$name';
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: id,
            // 本机空间的恢复分支没有账号归属，必须保持未归属状态
            accountId: Value(local.scopeAccountId),
            entityType: local.entityType,
            entityId: canonical,
            fitnessSpaceId: Value(local.fitnessSpaceId),
            localPayload: local.payload,
            remotePayload: jsonEncode({
              'fitness_recovery': true,
              'id': target ?? canonical,
              'name': name,
              'payload': {
                ...jsonDecode(local.payload) as Map<String, dynamic>,
                'name': name,
              },
              'deleted_at': null,
              'source': {'kind': 'frozen', 'operation_id': id},
            }),
            baseRevision: 0,
            remoteRevision: 2,
            localMutationId: 'fitness-recovery:$id',
            status: const Value('RESOLVED_REMOTE'),
          ),
        );
    return id;
  }

  test('本机多恢复版本可见，明确选择一个只更新该分支且不创建旧outbox', () async {
    final workout = await runningWorkoutFixture(repo, name: '最新输入');
    final first = await branch(workout.id);
    final second = await branch(workout.id, name: '另一版本');
    final status = await container.read(fitnessSyncStatusProvider.future);
    expect(status.isComplete, isTrue);
    expect(status.conflicts, hasLength(2));
    expect(status.conflicts.every((c) => c.isRecovery), isTrue);
    await container.read(fitnessRecoveryActionsProvider).adoptBranch(first);
    expect((await repo.getWorkout(workout.id))!.name, '备份版本');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(
      (await (db.select(
        db.syncConflicts,
      )..where((c) => c.id.equals(second))).getSingle()).resolvedAt,
      isNull,
    );
    await container.read(fitnessRecoveryActionsProvider).keepLocal(second);
    expect((await repo.getWorkout(workout.id))!.name, '备份版本');
    await expectLater(
      container.read(fitnessRecoveryActionsProvider).adoptBranch(first),
      throwsA(isA<StateError>()),
    );
  });

  test('已注册云端采用历史分支保留创建身份、冻结请求并登记新后继', () async {
    const account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    container
        .read(accountStateProvider.notifier)
        .restoreFromCache(
          const CloudProfile(
            userId: account,
            sesameNumber: '123456789',
            displayName: '用户',
          ),
        );
    final cloud = (await createFitnessTestRepository(
      db,
      accountIdGetter: () => account,
      clock: () => DateTime.utc(2026, 9, 12),
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    ));
    final workout = await runningWorkoutFixture(cloud, name: '最新输入');
    final original = await db.select(db.fitnessEntities).getSingle();
    final id = await branch(workout.id);
    final conflict = await db.select(db.syncConflicts).getSingle();
    final recovered =
        jsonDecode(conflict.remotePayload) as Map<String, dynamic>;
    (recovered['payload'] as Map)['created_at'] = '2020-01-01T00:00:00.000Z';
    (recovered['payload'] as Map)['updated_at'] = '2020-01-01T00:00:00.000Z';
    await db
        .update(db.syncConflicts)
        .write(
          SyncConflictsCompanion(
            accountId: const Value(account),
            remotePayload: Value(jsonEncode(recovered)),
          ),
        );
    await db
        .update(db.syncChanges)
        .write(
          const SyncChangesCompanion(frozenRequest: Value('original-frozen')),
        );
    await container.read(fitnessRecoveryActionsProvider).adoptBranch(id);
    final adopted = await db.select(db.fitnessEntities).getSingle();
    expect(adopted.createdAt, original.createdAt);
    expect(adopted.updatedAt.isAfter(original.updatedAt), isTrue);
    expect(
      jsonDecode(adopted.payload)['run_segments'],
      jsonDecode(original.payload)['run_segments'],
    );
    final pending = await db.select(db.syncChanges).get();
    expect(pending, hasLength(2));
    expect(
      pending.where((c) => c.frozenRequest == 'original-frozen'),
      hasLength(1),
    );
    expect(
      jsonDecode(
        pending.singleWhere((c) => c.frozenRequest == null).payload,
      )['name'],
      '备份版本',
    );
  });

  test('采用第二场运行分支失败整笔回滚，登录后仍可处理本地空间分支', () async {
    final workout = await runningWorkoutFixture(repo, name: '本机运行');
    final id = await branch(
      workout.id,
      target: '33333333-3333-4333-8333-333333333333',
    );
    await expectLater(
      container.read(fitnessRecoveryActionsProvider).adoptBranch(id),
      throwsA(anything),
    );
    expect((await db.select(db.fitnessEntities).get()).length, 1);
    expect((await db.select(db.syncConflicts).getSingle()).resolvedAt, isNull);
    container
        .read(accountStateProvider.notifier)
        .restoreFromCache(
          const CloudProfile(
            userId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
            sesameNumber: '123456789',
            displayName: '用户',
          ),
        );
    await container.read(fitnessRecoveryActionsProvider).keepLocal(id);
    expect(
      (await db.select(db.syncConflicts).getSingle()).resolvedAt,
      isNotNull,
    );
  });
}
