import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';

import '../../../helpers/test_isolation.dart';

/// 分类用例的串行事务桩，无需网络与同步服务。
class _InlineSync extends Fake implements SyncCoordinator {
  /// 保留用例原事务体及其身份守卫。
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) => action();
}

/// 同 UUID 的账号分类、纯本地目录与原记录身份必须始终独立。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const sameId = '961e3602-ad43-5c82-af2f-4202def6098c';
  final now = DateTime.utc(2026, 10, 11);
  late SesameDatabase db;
  late LocalCategoryRepository accountA;
  late LocalCategoryRepository accountB;

  /// 直接保存具有明确域的历史行，用于验证迁移后允许保留的原始状态。
  Future<void> row(String id, String name, String? scope) async {
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            name: name,
            kind: 'expense',
            level: 1,
            scopeAccountId: d.Value(scope),
            updatedAt: now,
          ),
        );
  }

  /// 模拟尚未拉取所有者元数据的历史云账本，旧角色字段不能替代所有者确认。
  Future<void> unknownLedger(String id) => db
      .into(db.ledgers)
      .insert(
        LedgersCompanion.insert(
          id: id,
          name: '待确认账本',
          storageMode: const d.Value('cloud'),
          scopeAccountId: const d.Value('account-a'),
          updatedAt: now,
        ),
      );

  /// 交易弱引用必须通过账本归属解析相同 UUID 的分类。
  Future<void> transaction(String id, String ledgerId) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          ledgerId: ledgerId,
          txType: 'expense',
          amount: '10',
          happenedAt: now,
          categoryId: const d.Value(sameId),
          currencyCode: 'CNY',
          nativeAmount: '10',
          createdAt: now,
          updatedAt: now,
        ),
      );

  /// 已知固定提示使所有管理入口能表达等待同步的原因。
  final unknownOwner = throwsA(
    isA<StateError>().having(
      (error) => error.message,
      '归属提示',
      categoryOwnerUnconfirmedMessage,
    ),
  );

  /// 失败日志保留用例需求和实际堆栈，区分真实隔离问题与夹具错误。
  void namespaceTest(String name, Future<void> Function() verify) {
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
    accountA = LocalCategoryRepository(
      db,
      accountIdGetter: () => 'account-a',
      trackerGetter: () =>
          ChangeRecorderImpl(db, accountIdGetter: () => 'account-a'),
    );
    accountB = LocalCategoryRepository(
      db,
      accountIdGetter: () => 'account-b',
      trackerGetter: () =>
          ChangeRecorderImpl(db, accountIdGetter: () => 'account-b'),
    );
    await row(sameId, 'A自己的分类', 'account-a');
    await row(sameId, 'B自己的分类', 'account-b');
    await row(sameId, '纯本地分类', null);
  });
  tearDown(() => db.close());

  namespaceTest('同UUID读取与编辑只修改本账号，纯本地及另一账号原行不变', () async {
    expect((await accountA.getAllCategories()).single.name, 'A自己的分类');
    expect((await accountB.getAllCategories()).single.name, 'B自己的分类');
    final before = await db.select(db.categories).get();
    await accountB.updateCategory(sameId, name: 'B修改正文');
    final after = await db.select(db.categories).get();
    for (final scope in ['account-a', null]) {
      expect(
        after.singleWhere((c) => c.scopeAccountId == scope),
        before.singleWhere((c) => c.scopeAccountId == scope),
      );
    }
    expect(
      after.singleWhere((c) => c.scopeAccountId == 'account-b').name,
      'B修改正文',
    );
    final mutation = await db.select(db.syncChanges).getSingle();
    expect(mutation.accountId, 'account-b');
    expect(mutation.entityId, sameId);
  });

  namespaceTest('同名分类字段编辑保持原身份和账单关联', () async {
    const second = '10000000-0000-4000-8000-000000000097';
    const conflict = '10000000-0000-4000-8000-000000000098';
    const ledger = 'own-history';
    await row(second, '  A自己的分类  ', 'account-a');
    await row(conflict, '餐饮', 'account-a');
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledger,
            name: '本人账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            ownerAccountId: const d.Value('account-a'),
            updatedAt: now,
          ),
        );
    await transaction('first-history-transaction', ledger);
    await transaction('second-history-transaction', ledger);
    await (db.update(db.transactions)
          ..where((t) => t.id.equals('second-history-transaction')))
        .write(const TransactionsCompanion(categoryId: d.Value(second)));
    final originalTransactions = await db.select(db.transactions).get();
    final originalIds = (await db.select(db.categories).get())
        .map((c) => (c.id, c.scopeAccountId))
        .toSet();

    await accountA.updateCategory(sameId, icon: 'Utensils');
    await accountA.updateCategory(second, icon: 'Coffee');
    expect((await accountA.getCategoryById(sameId))!.icon, 'Utensils');
    expect((await accountA.getCategoryById(second))!.icon, 'Coffee');
    expect(await accountA.getTransactionCountByCategory(sameId), 1);
    expect(await accountA.getTransactionCountByCategory(second), 1);
    await accountA.updateCategory(second, name: ' 餐饮 ');
    expect((await accountA.getCategoryById(second))!.name, '餐饮');
    expect(
      (await db.select(db.transactions).get()).map(
        (row) => (row.id, row.categoryId),
      ),
      originalTransactions.map((row) => (row.id, row.categoryId)),
    );
    expect(
      (await db.select(db.categories).get())
          .map((c) => (c.id, c.scopeAccountId))
          .toSet(),
      originalIds,
    );
    expect(
      (await db.select(db.syncChanges).get()).map((c) => c.entityId).toSet(),
      {sameId, second},
    );
  });

  namespaceTest('同名子分类提升为一级时保留原身份', () async {
    const parent = '10000000-0000-4000-8000-000000000081';
    const child = '10000000-0000-4000-8000-000000000082';
    await row(parent, '其他分类', 'account-a');
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: child,
            name: '  A自己的分类  ',
            kind: 'expense',
            level: 2,
            parentId: const d.Value(parent),
            scopeAccountId: const d.Value('account-a'),
            updatedAt: now,
          ),
        );
    final original = await db.select(db.categories).get();
    final children = original.where((row) => row.parentId == parent).toList();
    await accountA.promoteSubCategoriesToTopLevel(parent);
    for (final before in children) {
      final after = (await accountA.getCategoryById(before.id))!;
      expect(after.name, before.name);
      expect(after.level, 1);
      expect(after.parentId, isNull);
    }
    expect(
      (await db.select(db.categories).get())
          .map((row) => (row.id, row.scopeAccountId))
          .toSet(),
      original.map((row) => (row.id, row.scopeAccountId)).toSet(),
    );
  });

  namespaceTest('同名兄弟上提后分别保留身份与名称', () async {
    const parent = '10000000-0000-4000-8000-000000000083';
    await row(parent, '历史父分类', 'account-a');
    for (final child in [
      '10000000-0000-4000-8000-000000000084',
      '10000000-0000-4000-8000-000000000085',
    ]) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: child,
              name: '历史同名子分类',
              kind: 'expense',
              level: 2,
              parentId: const d.Value(parent),
              scopeAccountId: const d.Value('account-a'),
              updatedAt: now,
            ),
          );
    }
    final original = await db.select(db.categories).get();
    final children = original.where((row) => row.parentId == parent).toList();
    await accountA.promoteSubCategoriesToTopLevel(parent);
    for (final before in children) {
      final after = (await accountA.getCategoryById(before.id))!;
      expect(after.name, before.name);
      expect(after.level, 1);
      expect(after.parentId, isNull);
    }
    expect(
      (await db.select(db.categories).get())
          .map((row) => (row.id, row.scopeAccountId))
          .toSet(),
      original.map((row) => (row.id, row.scopeAccountId)).toSet(),
    );
  });

  namespaceTest('冻结批量重试不复活历史墓碑也不改写原父身份', () async {
    final templateId = defaultCategoryId(level: 1, key: 'sports');
    const parent = '10000000-0000-4000-8000-000000000086';
    const existingChild = '10000000-0000-4000-8000-000000000087';
    await row(parent, '本地自定义父分类', null);
    for (final item in [(templateId, true), (existingChild, false)]) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: item.$1,
              name: '本地同名子分类',
              kind: 'expense',
              level: 2,
              parentId: const d.Value(parent),
              updatedAt: now,
              deletedAt: d.Value(item.$2 ? now : null),
            ),
          );
    }
    final local = LocalCategoryRepository(
      db,
      accountIdGetter: () => 'account-a',
      categoryScopeId: '',
    );
    expect(
      await local.createCategoryBatch(
        items: [CategoryCreateDraft(id: templateId, name: '运动')],
      ),
      0,
    );
    expect(await local.getCategoryById(templateId), isNull);
    final tombstone =
        await (db.select(db.categories)..where(
              (c) => c.id.equals(templateId) & c.scopeAccountId.equals(''),
            ))
            .getSingle();
    expect(tombstone.parentId, parent);
    expect(tombstone.deletedAt, isNotNull);
    expect((await local.getSubCategories(parent)).map((row) => row.id), [
      existingChild,
    ]);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  namespaceTest('未知Owner相关交易暂停零计数删除迁移，确认本人后沿用原分类ID', () async {
    const ledger = 'unknown-owner';
    const target = '10000000-0000-4000-8000-000000000099';
    await unknownLedger(ledger);
    await transaction('unknown-owner-transaction', ledger);
    await row(target, '本人目标分类', 'account-a');
    final originalCategories = await db.select(db.categories).get();
    final originalTransactions = await db.select(db.transactions).get();
    await expectLater(
      accountA.getTransactionCountByCategory(sameId),
      unknownOwner,
    );
    await expectLater(accountA.getAllCategoryTransactionCounts(), unknownOwner);
    await expectLater(accountA.deleteCategory(sameId), unknownOwner);
    await expectLater(accountA.deleteCategoriesByIds([sameId]), unknownOwner);
    await expectLater(
      accountA.deleteTransactionsByCategoryIds([sameId]),
      unknownOwner,
    );
    await expectLater(
      accountA.migrateCategory(fromCategoryId: sameId, toCategoryId: target),
      unknownOwner,
    );
    await expectLater(
      accountA.migrateCategoryTransactions(
        fromCategoryId: sameId,
        toCategoryId: target,
      ),
      unknownOwner,
    );
    expect(await db.select(db.categories).get(), originalCategories);
    expect(await db.select(db.transactions).get(), originalTransactions);
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(await accountB.getTransactionCountByCategory(sameId), 0);
    final local = LocalCategoryRepository(
      db,
      accountIdGetter: () => 'account-a',
      categoryScopeId: '',
    );
    expect(await local.getTransactionCountByCategory(sameId), 0);
    expect(await accountA.getTransactionCountByCategory(target), 0);

    await (db.update(db.ledgers)..where((l) => l.id.equals(ledger))).write(
      const LedgersCompanion(ownerAccountId: d.Value('account-a')),
    );
    expect(await accountA.getTransactionCountByCategory(sameId), 1);
    expect(
      await accountA.migrateCategory(
        fromCategoryId: sameId,
        toCategoryId: target,
      ),
      1,
    );
    expect((await db.select(db.transactions).getSingle()).categoryId, target);
    expect(await db.select(db.categories).get(), originalCategories);
  });

  namespaceTest('Owner确认他人后本人管理不被共享同UUID引用阻塞且不清理共享记录', () async {
    const ledger = 'confirmed-shared-owner';
    await unknownLedger(ledger);
    await transaction('shared-transaction', ledger);
    await expectLater(accountA.deleteCategory(sameId), unknownOwner);
    await (db.update(db.ledgers)..where((l) => l.id.equals(ledger))).write(
      const LedgersCompanion(ownerAccountId: d.Value('account-b')),
    );
    final sharedTransaction = await db.select(db.transactions).getSingle();
    expect(await accountA.getTransactionCountByCategory(sameId), 0);
    await accountA.deleteCategory(sameId);
    expect(await accountA.getCategoryById(sameId), isNull);
    expect(await db.select(db.transactions).getSingle(), sharedTransaction);
    expect((await accountB.getCategoryById(sameId))!.name, 'B自己的分类');
    expect(
      (await db.select(db.categories).get())
          .singleWhere((c) => c.scopeAccountId == null)
          .name,
      '纯本地分类',
    );
  });

  namespaceTest('未知Owner仅有周期规则引用也不能误判未使用并删除分类', () async {
    const ledger = 'unknown-recurring-owner';
    await unknownLedger(ledger);
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: 'unknown-recurring',
            ledgerId: ledger,
            txType: 'expense',
            amount: '10',
            currencyCode: 'CNY',
            categoryId: const d.Value(sameId),
            frequency: 'monthly',
            startDate: now,
            updatedAt: now,
          ),
        );
    await expectLater(accountA.getAllCategoryTransactionCounts(), unknownOwner);
    await expectLater(accountA.deleteCategoriesByIds([sameId]), unknownOwner);
    expect((await accountA.getCategoryById(sameId))!.name, 'A自己的分类');
    expect(
      (await db.select(db.recurringTransactions).getSingle()).categoryId,
      sameId,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  namespaceTest('未知Owner未确认意图按冻结载荷与周期初始历史保护原分类', () async {
    const ledger = 'unknown-pending-owner';
    await unknownLedger(ledger);
    final mutation = await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'pending-transaction',
            ledgerId: const d.Value(ledger),
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: '{"category_id":null}',
            frozenRequest: d.Value(
              jsonEncode({
                'payload': {'category_id': sameId},
              }),
            ),
            updatedAt: now,
            mutationId: 'pending-mutation',
          ),
        );
    await expectLater(
      accountA.getTransactionCountByCategory(sameId),
      unknownOwner,
    );
    await expectLater(accountA.deleteCategoriesByIds([sameId]), unknownOwner);
    await (db.delete(db.syncChanges)..where((c) => c.id.equals(mutation))).go();
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'recurring_transaction',
            entityId: 'pending-recurring',
            ledgerId: const d.Value(ledger),
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: jsonEncode({
              'category_id': null,
              'initial_state': {
                'occurrences': [
                  {
                    'payload': {'category_id': sameId},
                  },
                ],
              },
            }),
            updatedAt: now,
            mutationId: 'pending-recurring-mutation',
          ),
        );
    await expectLater(accountA.getAllCategoryTransactionCounts(), unknownOwner);
    await expectLater(accountA.deleteCategory(sameId), unknownOwner);
    expect((await accountA.getCategoryById(sameId))!.name, 'A自己的分类');
    expect((await db.select(db.syncChanges).get()).length, 1);
  });

  namespaceTest('只有另一账号存在的自定义父分类不能被当前账号引用或改写', () async {
    const privateId = '10000000-0000-4000-8000-000000000001';
    await row(privateId, 'A私有父分类', 'account-a');
    await expectLater(
      accountB.updateCategory(privateId, name: '错误修改'),
      throwsStateError,
    );
    await expectLater(
      accountB.createSubCategory(
        parentId: privateId,
        name: '错误子分类',
        kind: 'expense',
      ),
      throwsA(isA<CategoryParentUnavailableException>()),
    );
    expect(await accountB.getCategoryById(privateId), isNull);
    expect((await accountA.getCategoryById(privateId))!.name, 'A私有父分类');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  namespaceTest('同名分类在各账号内独立创建且不跨域认领', () async {
    final a = await accountA.createCategory(name: '餐饮', kind: 'expense');
    final b = await accountB.createCategory(name: '餐饮', kind: 'expense');
    final second = await accountB.createCategory(name: ' 餐饮 ', kind: 'expense');
    expect({a, b, second}, hasLength(3));
    expect(
      (await accountB.getAllCategories())
          .where((row) => row.name == '餐饮')
          .map((row) => row.id)
          .toSet(),
      {b, second},
    );
    expect(await accountB.getCategoryById(a), isNull);
  });

  namespaceTest('并发主动创建同名分类为每次操作保留独立ID', () async {
    final results = await Future.wait(
      List.generate(
        8,
        (index) => accountA.createCategory(
          name: index.isEven ? '餐饮' : ' 餐饮 ',
          kind: 'expense',
        ),
      ),
    );
    expect(results.toSet(), hasLength(8));
    expect(
      (await accountA.getAllCategories()).where((row) => row.name == '餐饮'),
      hasLength(8),
    );
  });

  namespaceTest('普通批量身份与同名自定义并存，重放只登记一次原身份', () async {
    const custom = '10000000-0000-4000-8000-000000000002';
    await row(custom, ' 餐饮 ', 'account-a');
    final id = defaultCategoryId(level: 1, key: 'dining');
    for (var i = 0; i < 4; i++) {
      expect(
        await accountA.createCategoryBatch(
          items: [CategoryCreateDraft(id: id, name: '餐饮')],
        ),
        i == 0 ? 1 : 0,
      );
    }
    expect((await accountA.getCategoryById(id))!.name, '餐饮');
    expect((await accountA.getCategoryById(custom))!.name, ' 餐饮 ');
    expect((await db.select(db.syncChanges).get()).map((row) => row.entityId), [
      id,
    ]);
  });

  namespaceTest('新增同名分类不修改已有同名记录', () async {
    await row('10000000-0000-4000-8000-000000000003', '餐饮', 'account-a');
    await row('10000000-0000-4000-8000-000000000004', ' 餐饮 ', 'account-a');
    final before = await db.select(db.categories).get();
    final created = await accountA.createCategory(name: '餐饮', kind: 'expense');
    final after = await db.select(db.categories).get();
    expect(after.where((row) => row.id != created).toList(), before);
    expect((await db.select(db.syncChanges).get()).map((row) => row.entityId), [
      created,
    ]);
  });

  namespaceTest('登录期间本地账本新建分类仍在纯本地域，不借当前账号上云', () async {
    const ledger = '20000000-0000-4000-8000-000000000001';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(id: ledger, name: '本地账本', updatedAt: now),
        );
    final id = await accountB.createCategory(
      name: '本地新分类',
      kind: 'expense',
      ledgerId: ledger,
    );
    expect(await accountB.getCategoryById(id), isNull);
    expect(
      (await accountB.getCategoryById(id, ledgerId: ledger))!.scopeAccountId,
      isNull,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  namespaceTest('分类事务等待期间切号会回滚分类及同步意图', () async {
    String? current = 'account-a';
    final live = LocalCategoryRepository(
      db,
      accountIdGetter: () => current,
      trackerGetter: () =>
          ChangeRecorderImpl(db, accountIdGetter: () => current),
    );
    await expectLater(
      live.runInTransaction(() async {
        await live.updateCategory(sameId, name: '待回滚正文');
        current = 'account-b';
      }),
      throwsStateError,
    );
    expect((await accountA.getCategoryById(sameId))!.name, 'A自己的分类');
    expect((await accountB.getCategoryById(sameId))!.name, 'B自己的分类');
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  namespaceTest('旧Actions切号或同账号重登失效，B新表单不能写A旧props', () async {
    late ProviderContainer container;
    final repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(authSessionProvider)?.userId,
    );
    container = ProviderContainer(
      overrides: [
        categoryDataAccessProvider.overrideWithValue(repo),
        categoryQueriesProvider.overrideWithValue(repo.categoryStore),
        syncCoordinatorProvider.overrideWithValue(_InlineSync()),
      ],
    );
    try {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'a',
              userId: 'account-a',
              deviceId: 'device',
            ),
          );
      final original = container.read(categoryActionsProvider);
      container.read(authSessionProvider.notifier).signOut();
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'a2',
              userId: 'account-a',
              deviceId: 'device',
            ),
          );
      await expectLater(
        original.update(sameId, name: '旧A表单'),
        throwsA(isA<CategorySessionChangedException>()),
      );
      final second = container.read(categoryActionsProvider);
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'b',
              userId: 'account-b',
              deviceId: 'device',
            ),
          );
      await expectLater(
        second.update(sameId, name: '错误B修改'),
        throwsA(isA<CategorySessionChangedException>()),
      );
      final current = container.read(categoryActionsProvider);
      expect(
        () => current.requireCategoryContext(
          const CategoryDisplay(
            id: sameId,
            name: 'A旧props',
            kind: 'expense',
            level: 1,
            sortOrder: 0,
            scopeAccountId: 'account-a',
          ),
        ),
        throwsA(isA<CategoryOwnershipException>()),
      );
      expect((await accountA.getCategoryById(sameId))!.name, 'A自己的分类');
      expect((await accountB.getCategoryById(sameId))!.name, 'B自己的分类');
    } finally {
      container.dispose();
    }
  });

  namespaceTest('登录B的local表单按明确账本编辑本地原ID，共享Editor仍不能修改Owner类别', () async {
    const localLedger = '20000000-0000-4000-8000-000000000011';
    const sharedLedger = '20000000-0000-4000-8000-000000000012';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: localLedger,
            name: '本地副本',
            updatedAt: now,
          ),
        );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: sharedLedger,
            name: '共享账本',
            updatedAt: now,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-b'),
            ownerAccountId: const d.Value('account-a'),
            role: const d.Value('editor'),
          ),
        );
    final repo = LocalRepository(db, accountIdGetter: () => 'account-b');
    final container = ProviderContainer(
      overrides: [
        categoryDataAccessProvider.overrideWithValue(repo),
        categoryQueriesProvider.overrideWithValue(repo.categoryStore),
        ledgerDataAccessProvider.overrideWithValue(repo),
        syncCoordinatorProvider.overrideWithValue(_InlineSync()),
      ],
    );
    try {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'b',
              userId: 'account-b',
              deviceId: 'device',
            ),
          );
      final actions = container.read(categoryActionsProvider);
      const localProps = CategoryDisplay(
        id: sameId,
        name: '纯本地分类',
        kind: 'expense',
        level: 1,
        sortOrder: 0,
      );
      expect(
        () => actions.requireCategoryContext(localProps),
        throwsA(isA<CategoryOwnershipException>()),
      );
      await actions.requireCategoryContextForLedger(
        localProps,
        ledgerId: localLedger,
      );
      await actions.update(sameId, name: '本地独立编辑', ledgerId: localLedger);
      final rows = await db.select(db.categories).get();
      expect(rows.singleWhere((c) => c.scopeAccountId == null).name, '本地独立编辑');
      expect(
        rows.singleWhere((c) => c.scopeAccountId == 'account-a').name,
        'A自己的分类',
      );
      expect(
        rows.singleWhere((c) => c.scopeAccountId == 'account-b').name,
        'B自己的分类',
      );
      expect(await db.select(db.syncChanges).get(), isEmpty);
      const ownerProps = CategoryDisplay(
        id: sameId,
        name: 'Owner自己的分类',
        kind: 'expense',
        level: 1,
        sortOrder: 0,
        scopeAccountId: 'account-a',
      );
      await expectLater(
        actions.requireCategoryContextForLedger(
          ownerProps,
          ledgerId: sharedLedger,
        ),
        throwsA(isA<CategoryOwnershipException>()),
      );
      await expectLater(
        actions.update(sameId, name: '错误共享编辑', ledgerId: sharedLedger),
        throwsStateError,
      );
      expect(await db.select(db.categories).get(), rows);
    } finally {
      container.dispose();
    }
  });
}
