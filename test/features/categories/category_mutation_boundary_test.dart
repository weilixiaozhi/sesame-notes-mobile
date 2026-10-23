import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

/// 保留真实数据库事务，只省略联网同步。
class _InlineSync extends Fake implements SyncCoordinator {
  /// 用例通过真实 Actions 的会话与仓储事务边界执行。
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) => action();
}

/// 选择器快照与最新树之间的变化不能造成迁移目标或新记录被删除。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const source = '10000000-0000-4000-8000-000000000001';
  const target = '10000000-0000-4000-8000-000000000002';
  const child = '10000000-0000-4000-8000-000000000003';
  const secondSource = '10000000-0000-4000-8000-000000000004';
  final now = DateTime.utc(2026, 10, 11);
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late CategoryActions actions;

  /// 合成分类直接保留指定原 UUID 与精确账号域。
  Future<void> category(String id, String name, {String? parent}) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          name: name,
          kind: 'expense',
          level: parent == null ? 1 : 2,
          parentId: d.Value(parent),
          scopeAccountId: const d.Value('account-a'),
          updatedAt: now,
        ),
      );

  /// 云账本内的分类弱引用使用该账本的真实所有者目录。
  Future<void> transaction(String id, String categoryId) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          ledgerId: 'own-ledger',
          txType: 'expense',
          amount: '10',
          happenedAt: now,
          categoryId: d.Value(categoryId),
          currencyCode: 'CNY',
          nativeAmount: '10',
          createdAt: now,
          updatedAt: now,
        ),
      );

  /// 失败诊断保留用例需求和堆栈，运行只涉及合成内存数据。
  void boundaryTest(String name, Future<void> Function() verify) {
    test(name, () async {
      try {
        await verify();
      } catch (error, stack) {
        debugPrint('$name：$error\n$stack');
        rethrow;
      }
    });
  }

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => 'account-a',
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account-a'),
    );
    container = ProviderContainer(
      overrides: [
        categoryDataAccessProvider.overrideWithValue(repo),
        categoryQueriesProvider.overrideWithValue(repo.categoryStore),
        syncCoordinatorProvider.overrideWithValue(_InlineSync()),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'a',
            userId: 'account-a',
            deviceId: 'device',
          ),
        );
    actions = container.read(categoryActionsProvider);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'own-ledger',
            name: '本人云账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            ownerAccountId: const d.Value('account-a'),
            updatedAt: now,
          ),
        );
    await category(source, '来源分类');
    await category(target, '目标分类');
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  boundaryTest('自己迁移到自己在仓储和真实Actions均被拒绝，原记录身份保持', () async {
    await transaction('source-transaction', source);
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    await expectLater(
      repo.migrateCategory(fromCategoryId: source, toCategoryId: source),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    await expectLater(
      repo.migrateCategoryTransactions(
        fromCategoryId: source,
        toCategoryId: source,
      ),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    await expectLater(
      actions.migrateAndDelete([source], source),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  for (final deleted in [false, true]) {
    boundaryTest(
      '迁移目标${deleted ? '为墓碑' : '缺失'}时真实Actions保留源数据和既有同步意图',
      () async {
        await transaction('source-transaction', source);
        if (deleted) {
          await (db.update(db.categories)
                ..where((row) => row.id.equals(target)))
              .write(CategoriesCompanion(deletedAt: d.Value(now)));
        }
        await repo.updateCategory(source, icon: 'Coffee');
        final categories = await db.select(db.categories).get();
        final transactions = await db.select(db.transactions).get();
        final pending = await db.select(db.syncChanges).get();
        expect(pending, isNotEmpty);

        await expectLater(
          actions.migrateAndDelete([
            source,
          ], deleted ? target : 'missing-target'),
          throwsStateError,
        );

        expect(await db.select(db.categories).get(), categories);
        expect(await db.select(db.transactions).get(), transactions);
        expect(await db.select(db.syncChanges).get(), pending);
      },
    );
  }

  boundaryTest('未知Owner账本仍引用源分类时真实Actions拒绝迁移，保留全部交易和同步意图', () async {
    await transaction('own-source-transaction', source);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'unknown-owner-ledger',
            name: '归属待确认账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            updatedAt: now,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'unknown-owner-transaction',
            ledgerId: 'unknown-owner-ledger',
            txType: 'expense',
            amount: '20',
            categoryId: const d.Value(source),
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '20',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await repo.updateCategory(target, icon: 'Coffee');
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final pending = await db.select(db.syncChanges).get();
    expect(pending, isNotEmpty);

    await expectLater(
      actions.migrateAndDelete([source], target),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          categoryOwnerUnconfirmedMessage,
        ),
      ),
    );

    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), pending);
  });

  boundaryTest('迁移目标属于来源当前子树时整次拒绝，不能把目标一并删除', () async {
    await category(child, '来源子分类', parent: source);
    await transaction('source-transaction', source);
    await transaction('child-transaction', child);
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    await expectLater(
      actions.migrateAndDelete([source], child),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  boundaryTest('选择器打开后目标重挂到来源之下，以最新树拒绝迁移并保留既有队列', () async {
    expect((await actions.getById(target))!.parentId, isNull);
    await transaction('source-transaction', source);
    await transaction('target-transaction', target);
    await repo.updateCategory(target, parentId: source, level: 2);
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final pending = await db.select(db.syncChanges).get();
    await expectLater(
      actions.migrateAndDelete([source], target),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), pending);
  });

  boundaryTest('批量来源集合包含目标时拒绝全部迁移，不部分移动记录', () async {
    await transaction('source-transaction', source);
    await transaction('target-transaction', target);
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    await expectLater(
      actions.migrateAndDelete([source, target], target),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  boundaryTest('批量后续来源发现目标已在其子树时，前序交易与同步意图全部回滚', () async {
    await category(secondSource, '另一来源');
    await repo.updateCategory(target, parentId: secondSource, level: 2);
    await transaction('source-transaction', source);
    await transaction('second-source-transaction', secondSource);
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final pending = await db.select(db.syncChanges).get();
    await expectLater(
      actions.migrateAndDelete([source, secondSource], target),
      throwsA(isA<CategoryMigrationTargetException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), pending);
  });

  boundaryTest('删除确认后来源新增子分类时不扩大授权，原分类记录与队列全部保留', () async {
    await category(child, '已确认子分类', parent: source);
    final confirmedChildren = (await actions.getSubCategories(
      source,
    )).map((c) => c.id).toList();
    await category(secondSource, '后来新增子分类', parent: source);
    await transaction('source-transaction', source);
    await transaction('child-transaction', child);
    await transaction('new-child-transaction', secondSource);
    await repo.updateCategory(target, icon: 'Coffee');
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final pending = await db.select(db.syncChanges).get();
    await expectLater(
      actions.deleteCascade([source], subCategoryIds: confirmedChildren),
      throwsA(isA<CategoryReviewChangedException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), pending);
  });

  boundaryTest('清空未使用的零计数快照过期后，最新子级新增交易使全部删除回滚', () async {
    await category(child, '来源子分类', parent: source);
    expect(
      (await repo.categoryStore.getAllCategoryTransactionCounts()).values,
      everyElement(0),
    );
    await transaction('later-child-transaction', child);
    await repo.updateCategory(target, icon: 'Coffee');
    final categories = await db.select(db.categories).get();
    final transactions = await db.select(db.transactions).get();
    final pending = await db.select(db.syncChanges).get();
    await expectLater(
      actions.delete([source, target]),
      throwsA(isA<CategoryReviewChangedException>()),
    );
    expect(await db.select(db.categories).get(), categories);
    expect(await db.select(db.transactions).get(), transactions);
    expect(await db.select(db.syncChanges).get(), pending);
  });
}
