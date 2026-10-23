import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../helpers/ledger_sync_fixture.dart';
import '../helpers/test_isolation.dart';

/// 三个业务域的本地本上云走同一条归属转换：本子翻云 + 内容补登记 + 归属当前账号。
const testUserId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LedgerSyncFixture sync;
  late ProviderContainer container;
  late DataLifecycleActions actions;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    sync = LedgerSyncFixture(
      db,
      testUserId,
      localSelfId: () => container.read(localSelfIdProvider.future),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        syncServiceProvider.overrideWithValue(sync.service),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
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
    // 迁云提交后会启动后台同步，销毁作用域前先排空串行队列。
    await container
        .read(syncCoordinatorProvider)
        .runAccountTransition(() async {});
    container.dispose();
    await db.close();
  });

  /// 上云后补登记的变更必须全部落在当前账号域并指向同一个本子。
  Future<List<SyncChange>> changesOf(String parentColumn, String bookId) async {
    final changes = await db.select(db.syncChanges).get();
    expect(changes, isNotEmpty);
    for (final change in changes) {
      expect(change.accountId, testUserId);
      expect(change.action, 'upsert');
      switch (parentColumn) {
        case 'day_book_id':
          expect(change.dayBookId, bookId);
        case 'memo_book_id':
          expect(change.memoBookId, bookId);
        case 'fitness_space_id':
          expect(change.fitnessSpaceId, bookId);
      }
    }
    return changes;
  }

  test('移动到云端：纪念日本归属翻云并补登记本子与纪念日', () async {
    const bookId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c1111';
    final repo = container.read(dayRepositoryProvider);
    await repo.createBook(id: bookId, name: '本地纪念日本');
    final now = DateTime.utc(2026, 9, 8);
    await repo.saveEvent(
      DayEvent(
        id: '139207db-90c3-4f59-aec9-3d625d60a661',
        dayBookId: bookId,
        definition: DayEventDefinition(
          name: '生日记录',
          category: DayCategory.birthday,
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          event: OriginalDate.solar(DateOnly(2000, 1, 1)),
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await actions.moveToCloud(const SyncTarget('day_book', bookId));

    final row = await (db.select(
      db.dayBooks,
    )..where((b) => b.id.equals(bookId))).getSingle();
    expect(row.storageMode, 'cloud', reason: '归属必须翻为云端');
    expect(row.scopeAccountId, testUserId, reason: '上云后必须归属当前账号');
    final changes = await changesOf('day_book_id', bookId);
    expect(
      changes.map((c) => c.entityType),
      containsAll(<String>['day_book', 'day_event']),
      reason: '本子与其中内容都要补登记 backfill',
    );
  });

  test('移动到云端：备忘录/帐号密码本归属翻云并补登记本子', () async {
    const bookId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c2222';
    final repo = container.read(memoRepositoryProvider);
    await repo.createBook(id: bookId, name: '本地帐号密码本', type: 'credentials');

    await actions.moveToCloud(const SyncTarget('memo_book', bookId));

    final row = await (db.select(
      db.memoBooks,
    )..where((b) => b.id.equals(bookId))).getSingle();
    expect(row.storageMode, 'cloud', reason: '归属必须翻为云端');
    expect(row.scopeAccountId, testUserId, reason: '上云后必须归属当前账号');
    final changes = await changesOf('memo_book_id', bookId);
    expect(changes.map((c) => c.entityType), contains('memo_book'));
  });

  test('移动到云端：健身空间归属翻云并补登记本子', () async {
    const bookId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c3333';
    final repo = container.read(fitnessSpaceRepositoryProvider);
    await repo.createBook(id: bookId, name: '本地健身空间');

    await actions.moveToCloud(const SyncTarget('fitness_space', bookId));

    final row = await (db.select(
      db.fitnessSpaces,
    )..where((b) => b.id.equals(bookId))).getSingle();
    expect(row.storageMode, 'cloud', reason: '归属必须翻为云端');
    expect(row.scopeAccountId, testUserId, reason: '上云后必须归属当前账号');
    final changes = await changesOf('fitness_space_id', bookId);
    expect(changes.map((c) => c.entityType), contains('fitness_space'));
  });

  test('移动到云端：未登录时拒绝转换且三个业务域的本子零改动', () async {
    const dayBookId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c4444';
    const memoBookId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c5555';
    const spaceId = '0f0d4a3a-1f70-4f1a-9a1f-3b2f6a5c6666';
    final dayRepo = container.read(dayRepositoryProvider);
    final memoRepo = container.read(memoRepositoryProvider);
    final spaceRepo = container.read(fitnessSpaceRepositoryProvider);
    await dayRepo.createBook(id: dayBookId, name: '本地纪念日本');
    await memoRepo.createBook(id: memoBookId, name: '本地备忘录', type: 'normal');
    await spaceRepo.createBook(id: spaceId, name: '本地健身空间');
    await db.delete(db.syncChanges).go();
    container.read(authSessionProvider.notifier).signOut();

    for (final target in [
      const SyncTarget('day_book', dayBookId),
      const SyncTarget('memo_book', memoBookId),
      const SyncTarget('fitness_space', spaceId),
    ]) {
      await expectLater(actions.moveToCloud(target), throwsStateError);
    }

    expect(
      (await (db.select(
        db.dayBooks,
      )..where((b) => b.id.equals(dayBookId))).getSingle()).storageMode,
      'local',
    );
    expect(
      (await (db.select(
        db.memoBooks,
      )..where((b) => b.id.equals(memoBookId))).getSingle()).storageMode,
      'local',
    );
    expect(
      (await (db.select(
        db.fitnessSpaces,
      )..where((b) => b.id.equals(spaceId))).getSingle()).storageMode,
      'local',
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
}
