import '../helpers/fitness_space_fixture.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/models/fitness.dart' as fitness;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/auth/application/local_book_migration.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const dayId = '11111111-1111-4111-8111-111111111111';
  const memoId = '22222222-2222-4222-8222-222222222222';
  const entryId = '33333333-3333-4333-8333-333333333333';
  late SesameDatabase db;
  late ProviderContainer container;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });
  void offlineLogin() => container
      .read(accountStateProvider.notifier)
      .restoreFromCache(
        const CloudProfile(
          userId: account,
          sesameNumber: '123456789',
          displayName: '本人',
        ),
      );
  Future<void> seedMemo() async {
    final repo = container.read(memoRepositoryProvider);
    await repo.createBook(id: memoId, name: '备忘录', type: 'credentials');
    await repo.saveEntry(
      MemoEntry(
        id: entryId,
        memoBookId: memoId,
        bookType: 'credentials',
        title: '原始内容',
        bodyJson: encodeMemoFields(const [
          MemoField(label: '账号', value: ' 账号 '),
          MemoField(label: '密码', value: ' 密码😀 '),
        ]),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
      await repo.target(memoId),
    );
  }

  test('健身迁移整批回滚后按固定名单重试，偏好保持空间ID并迁移恢复分支', () async {
    final local = (await createFitnessTestRepository(db));
    await local.saveTemplate(
      fitness.FitnessTemplate(
        id: entryId,
        exercises: const [
          fitness.FitnessExercise(
            id: '66666666-6666-4666-8666-666666666666',
            exerciseId: '0025',
          ),
        ],
        name: '隔离模板',
      ),
    );
    await local.savePreferences(const fitness.FitnessPreferences());
    final preference = await (db.select(
      db.fitnessEntities,
    )..where((e) => e.entityType.equals('fitness_preferences'))).getSingle();
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: memoId,
            accountId: d.Value(account),
            entityType: 'fitness_preferences',
            entityId: preference.id,
            fitnessSpaceId: d.Value(local.spaceId),
            localPayload: preference.payload,
            remotePayload: jsonEncode({
              'fitness_recovery': true,
              'id': preference.id,
              'payload': jsonDecode(preference.payload),
              'deleted_at': null,
              'source': {'kind': 'pending', 'operation_id': 'test'},
            }),
            baseRevision: 0,
            remoteRevision: 0,
            localMutationId: 'fitness-recovery:test',
          ),
        );
    final migration = container.read(localBookMigrationProvider);
    offlineLogin();
    final plan = await migration.preview();
    await db.customStatement(
      "CREATE TRIGGER fail_fitness_migration BEFORE INSERT ON sync_changes WHEN NEW.entity_type = 'fitness_template' BEGIN SELECT RAISE(ABORT, 'fail'); END",
    );
    await expectLater(migration.migrate(plan), throwsA(anything));
    expect(
      (await db.select(db.fitnessEntities).get()).every(
        (e) => e.scopeAccountId == null,
      ),
      isTrue,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    final laterSpace = await createFitnessTestRepository(
      db,
      spaceId: '55555555-5555-4555-8555-555555555555',
    );
    await laterSpace.saveTemplate(
      fitness.FitnessTemplate(
        id: dayId,
        exercises: const [
          fitness.FitnessExercise(
            id: '66666666-6666-4666-8666-666666666666',
            exerciseId: '0025',
          ),
        ],
        name: '隔离模板',
      ),
    );
    await db.customStatement('DROP TRIGGER fail_fitness_migration');
    await migration.migrate(plan);
    final all = await db.select(db.fitnessEntities).get();
    expect(all.singleWhere((e) => e.id == entryId).scopeAccountId, account);
    expect(all.singleWhere((e) => e.id == dayId).scopeAccountId, isNull);
    expect(
      all.singleWhere((e) => e.entityType == 'fitness_preferences').id,
      local.spaceId,
    );
    final branch = await db.select(db.syncConflicts).getSingle();
    expect(branch.accountId, account);
    expect(branch.entityId, local.spaceId);
    expect(jsonDecode(branch.remotePayload)['id'], local.spaceId);
    expect((await db.select(db.syncChanges).get()).length, 3);
    await migration.migrate(plan);
    expect((await db.select(db.syncChanges).get()).length, 3);
  });

  test('确认后整批移动全部业务域，保留身份和内容，不动其他账号云本，重试不搬新本', () async {
    final repo = container.read(repositoryProvider);
    final ledger = await repo.createLedger(name: '账本', storageMode: 'local');
    await repo.setLedgerArchived(ledger, true);
    await container
        .read(dayRepositoryProvider)
        .createBook(id: dayId, name: '纪念日');
    await seedMemo();
    final fitnessRepo = await createFitnessTestRepository(db);
    const normalMemoId = '77777777-7777-4777-8777-777777777777';
    await container
        .read(memoRepositoryProvider)
        .createBook(id: normalMemoId, name: '普通备忘录', type: 'normal');
    await db
        .into(db.memoBooks)
        .insert(
          MemoBooksCompanion.insert(
            id: '44444444-4444-4444-8444-444444444444',
            name: '其他账号',
            type: 'normal',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('other'),
            serverRevision: const d.Value(0),
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );
    final migration = container.read(localBookMigrationProvider);
    offlineLogin();
    final plan = await migration.preview();
    expect(plan.count, 5);
    await migration.migrate(plan);
    expect(
      (await container
              .read(fitnessSpaceRepositoryProvider)
              .getBook(fitnessRepo.spaceId, accountId: account))!
          .isCloud,
      isTrue,
    );
    expect(
      (await container
              .read(memoRepositoryProvider)
              .getBook(normalMemoId, accountId: account))!
          .isCloud,
      isTrue,
    );
    expect((await repo.getLedgerById(ledger))!.storageMode, 'cloud');
    expect(
      (await container
              .read(dayRepositoryProvider)
              .getBook(dayId, accountId: account))!
          .isCloud,
      isTrue,
    );
    final memos = container.read(memoRepositoryProvider);
    expect((await memos.getBook(memoId, accountId: account))!.isCloud, isTrue);
    expect(
      (await memos.getEntries(
        memoId,
        accountId: account,
      )).single.fields[1].value,
      ' 密码😀 ',
    );
    final changes = await db.select(db.syncChanges).get();
    expect(
      changes.map((c) => c.entityType).toSet(),
      containsAll([
        'ledger',
        'ledger_archive',
        'day_book',
        'memo_book',
        'memo_entry',
      ]),
    );
    expect(
      changes.every((c) => c.accountId == account && c.pushedAt == null),
      isTrue,
    );
    expect(
      (await db.select(db.memoBooks).get())
          .singleWhere((b) => b.name == '其他账号')
          .scopeAccountId,
      'other',
    );
    final local = await repo.createLedger(
      name: '后来留本机',
      storageMode: 'local',
      localSelfId: 'self',
    );
    await migration.migrate(plan);
    expect((await repo.getLedgerById(local))!.storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), hasLength(changes.length));
  });

  test('普通登录不自动搬迁本机本子', () async {
    await seedMemo();
    offlineLogin();
    await container.read(localBookMigrationProvider).preview();
    expect(
      (await container.read(memoRepositoryProvider).getBook(memoId))!.isCloud,
      isFalse,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('弹窗拒绝不写归属或队列，同一次登录不重复询问，重新登录再次检查', () async {
    await seedMemo();
    offlineLogin();
    final migration = container.read(localBookMigrationProvider);
    expect((await migration.previewForPrompt())!.count, 1);
    expect(await migration.previewForPrompt(), isNull);
    expect((await db.select(db.memoBooks).getSingle()).storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
    container.read(authSessionProvider.notifier).signOut();
    offlineLogin();
    expect((await migration.previewForPrompt())!.count, 1);
  });

  test('确认前退出或换号拒绝旧计划，即使重新登录同一账号也不能沿用', () async {
    await seedMemo();
    offlineLogin();
    final migration = container.read(localBookMigrationProvider);
    final plan = await migration.preview();
    container.read(authSessionProvider.notifier).signOut();
    offlineLogin();
    await expectLater(migration.migrate(plan), throwsStateError);
    expect((await db.select(db.memoBooks).getSingle()).storageMode, 'local');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('空确认名单不创建本子或上云队列', () async {
    final migration = container.read(localBookMigrationProvider);
    offlineLogin();
    final plan = await migration.preview();
    await migration.migrate(plan);
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await db.select(db.dayBooks).get(), isEmpty);
    expect(await db.select(db.memoBooks).get(), isEmpty);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('中途失败整批回滚，重试只迁移已确认名单中的本', () async {
    final repo = container.read(repositoryProvider);
    final broken = await repo.createLedger(
      name: '缺少本人',
      storageMode: 'local',
      localSelfId: 'self',
    );
    await db.customStatement(
      "CREATE TRIGGER fail_migration BEFORE UPDATE OF storage_mode ON ledgers BEGIN SELECT RAISE(ABORT, 'migration failed'); END",
    );
    await seedMemo();
    final migration = container.read(localBookMigrationProvider);
    offlineLogin();
    final plan = await migration.preview();
    await expectLater(migration.migrate(plan), throwsA(isA<Exception>()));
    expect(
      (await container.read(memoRepositoryProvider).getBook(memoId))!.isCloud,
      isFalse,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(plan.targets, hasLength(2));
    await db.customStatement('DROP TRIGGER fail_migration');
    await migration.migrate(plan);
    expect((await repo.getLedgerById(broken))!.storageMode, 'cloud');
  });

  test('离线备忘录移云保留原ID，保护拷贝另建父子ID', () async {
    await seedMemo();
    offlineLogin();
    final repo = container.read(memoRepositoryProvider);
    await repo.moveToCloud(await repo.target(memoId));
    final copy = await repo.copyToLocalForAccountExit(
      memoId,
      'registration-copy',
    );
    expect(copy, isNot(memoId));
    expect((await repo.getEntries(copy)).single.id, isNot(entryId));
    expect((await repo.getEntries(copy)).single.fields[1].value, ' 密码😀 ');
    expect(await repo.getBook(memoId, accountId: account), isNotNull);
  });
}
