import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 真实写入 + 调用轨迹的仓储：写路径照常落到内存库，仅额外记录调用顺序。
class _RecordingRepo extends LocalRepository {
  _RecordingRepo(super.db);

  /// 调用轨迹：按发生顺序记录「方法名(参数)」，用于断言调用序与「未发生」。
  final List<String> calls = [];

  /// 分步失败注入开关，用于验证失败后的回滚与中止。
  bool failDeleteTransactions = false;
  bool failPromote = false;
  bool failMigrate = false;

  @override
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds) {
    calls.add('deleteTransactionsByCategoryIds(${categoryIds.join(",")})');
    if (failDeleteTransactions) return Future.error(Exception('db down'));
    return super.deleteTransactionsByCategoryIds(categoryIds);
  }

  @override
  Future<int> promoteSubCategoriesToTopLevel(String parentId) {
    calls.add('promoteSubCategoriesToTopLevel($parentId)');
    if (failPromote) return Future.error(Exception('db down'));
    return super.promoteSubCategoriesToTopLevel(parentId);
  }

  @override
  Future<void> deleteCategoriesByIds(List<String> ids) {
    calls.add('deleteCategoriesByIds(${ids.join(",")})');
    return super.deleteCategoriesByIds(ids);
  }

  @override
  Future<int> migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) {
    calls.add('migrateCategoryTransactions($fromCategoryId->$toCategoryId)');
    if (failMigrate) return Future.error(Exception('db down'));
    return super.migrateCategoryTransactions(
      fromCategoryId: fromCategoryId,
      toCategoryId: toCategoryId,
    );
  }
}

/// 数据写入闸门：测试直接执行事务体，不启动网络依赖。
class _InlineSync extends Fake implements SyncCoordinator {
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) => action();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.SesameDatabase database;
  late _RecordingRepo repo;
  late ProviderContainer container;
  late CategoryActions actions;

  setUp(() async {
    resetGlobalTestState();
    database = db.SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = _RecordingRepo(database);
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        syncCoordinatorProvider.overrideWithValue(_InlineSync()),
      ],
    );
    actions = container.read(categoryActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  var seq = 0;

  /// 创建一个一级分类，返回其 id。
  Future<String> createTop(String name, {int sortOrder = 0}) =>
      repo.createCategory(
        name: name,
        kind: 'expense',
        icon: 'utensils',
        sortOrder: sortOrder,
      );

  /// 在指定父分类下创建二级分类，返回其 id。
  Future<String> createSub(String parentId, String name, {int sortOrder = 0}) =>
      repo.createSubCategory(
        parentId: parentId,
        name: name,
        kind: 'expense',
        icon: 'utensils',
        sortOrder: sortOrder,
      );

  /// 创建一个账本，返回其 id。
  Future<String> createLedger() async {
    final now = DateTime.now().toUtc();
    final id = 'led-${seq++}';
    await database
        .into(database.ledgers)
        .insert(
          db.LedgersCompanion.insert(id: id, name: '测试账本', updatedAt: now),
        );
    return id;
  }

  /// 在指定账本、指定分类下创建一条交易。
  Future<void> createTransaction(String ledgerId, String categoryId) async {
    final now = DateTime.now().toUtc();
    await database
        .into(database.transactions)
        .insert(
          db.TransactionsCompanion.insert(
            id: 'tx-${seq++}',
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '100.00',
            categoryId: drift.Value(categoryId),
            happenedAt: DateTime(2026, 8, 1),
            currencyCode: 'CNY',
            nativeAmount: '100.00',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  group('策略 A：删除分类及其下全部数据（含二级）', () {
    test('先删除父子分类交易再删除选中父分类', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装');
      final dining = await createTop('餐饮');
      await createTransaction(ledgerId, shopping);
      await createTransaction(ledgerId, clothing);
      await createTransaction(ledgerId, clothing);
      await createTransaction(ledgerId, dining);
      repo.calls.clear();

      await actions.deleteCascade([shopping], subCategoryIds: [clothing]);

      expect(repo.calls, [
        'deleteTransactionsByCategoryIds($shopping,$clothing)',
        'deleteCategoriesByIds($shopping)',
      ], reason: '先清空父分类及其子分类的交易，再删除父分类');
      expect(await repo.categoryStore.getCategoryById(shopping), isNull);
      expect(
        await repo.categoryStore.getCategoryById(clothing),
        isNull,
        reason: '子分类随父级联删除',
      );
      expect(
        await repo.categoryStore.getTransactionCountByCategory(dining),
        1,
        reason: '其他分类不受影响',
      );
    });

    test('删除失败即中止且无部分落库', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装');
      await createTransaction(ledgerId, shopping);
      await createTransaction(ledgerId, clothing);
      repo.calls.clear();
      repo.failDeleteTransactions = true;

      await expectLater(
        actions.deleteCascade([shopping], subCategoryIds: [clothing]),
        throwsA(isA<Exception>()),
        reason: '失败向上抛出，由页面提示删除失败',
      );

      expect(repo.calls, [
        'deleteTransactionsByCategoryIds($shopping,$clothing)',
      ], reason: '首步失败即停止后续删除');
      expect(await repo.categoryStore.getCategoryById(shopping), isNotNull);
      expect(await repo.categoryStore.getCategoryById(clothing), isNotNull);
      expect(
        await repo.categoryStore.getTransactionCountByCategory(shopping),
        1,
        reason: '失败的整体回滚：交易未部分删除',
      );
    });
  });

  group('策略 C：删除分类但保留二级（二级变一级）', () {
    test('只清理父分类交易并提升子分类，最后删除父分类', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装');
      await createTransaction(ledgerId, shopping);
      await createTransaction(ledgerId, clothing);
      await createTransaction(ledgerId, clothing);
      repo.calls.clear();

      await actions.deletePromotingChildren([shopping]);

      expect(repo.calls, [
        'deleteTransactionsByCategoryIds($shopping)',
        'promoteSubCategoriesToTopLevel($shopping)',
        'deleteCategoriesByIds($shopping)',
      ], reason: '只清父分类交易 → 提升子分类 → 删除父分类');
      expect(await repo.categoryStore.getCategoryById(shopping), isNull);
      final promoted = await repo.categoryStore.getCategoryById(clothing);
      expect(promoted, isNotNull, reason: '子分类保留');
      expect(promoted!.level, 1);
      expect(promoted.parentId, isNull);
      expect(
        await repo.categoryStore.getTransactionCountByCategory(clothing),
        2,
        reason: '子分类交易保留',
      );
    });

    test('提升失败时整体回滚，父分类与其交易都保留', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装');
      await createTransaction(ledgerId, shopping);
      await createTransaction(ledgerId, clothing);
      repo.calls.clear();
      repo.failPromote = true;

      await expectLater(
        actions.deletePromotingChildren([shopping]),
        throwsA(isA<Exception>()),
      );

      expect(repo.calls, [
        'deleteTransactionsByCategoryIds($shopping)',
        'promoteSubCategoriesToTopLevel($shopping)',
      ], reason: '提升失败即中止，不再删除分类');
      expect(await repo.categoryStore.getCategoryById(shopping), isNotNull);
      expect(
        await repo.categoryStore.getTransactionCountByCategory(shopping),
        1,
        reason: '事务回滚：已删的父分类交易被恢复',
      );
      expect(
        await repo.categoryStore.getTransactionCountByCategory(clothing),
        1,
      );
    });
  });

  group('策略 B：迁移全部数据后删除', () {
    test('先迁移整棵树的数据再删除选中分类', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装');
      final dining = await createTop('餐饮');
      await createTransaction(ledgerId, shopping);
      await createTransaction(ledgerId, clothing);
      await createTransaction(ledgerId, clothing);
      repo.calls.clear();

      await actions.migrateAndDelete([shopping], dining);

      expect(repo.calls, [
        'migrateCategoryTransactions($shopping->$dining)',
        'deleteCategoriesByIds($shopping)',
      ], reason: '父分类一次调用即迁移整棵树，子分类不重复迁移');
      expect(await repo.categoryStore.getCategoryById(shopping), isNull);
      expect(
        await repo.categoryStore.getCategoryById(clothing),
        isNull,
        reason: '源子分类随父级联删除',
      );
      expect(
        await repo.categoryStore.getTransactionCountByCategory(dining),
        3,
        reason: '父 + 子共 3 笔全部迁到目标分类',
      );
      expect(
        await repo.categoryStore.getTransactionCountByCategory(shopping),
        0,
      );
    });

    test('迁移失败时不删除分类，源数据保持不变', () async {
      final ledgerId = await createLedger();
      final shopping = await createTop('购物');
      final dining = await createTop('餐饮');
      await createTransaction(ledgerId, shopping);
      repo.calls.clear();
      repo.failMigrate = true;

      await expectLater(
        actions.migrateAndDelete([shopping], dining),
        throwsA(isA<Exception>()),
      );

      expect(repo.calls, ['migrateCategoryTransactions($shopping->$dining)']);
      expect(await repo.categoryStore.getCategoryById(shopping), isNotNull);
      expect(
        await repo.categoryStore.getTransactionCountByCategory(shopping),
        1,
      );
      expect(await repo.categoryStore.getTransactionCountByCategory(dining), 0);
    });
  });

  group('清理未使用分类', () {
    test('只删除传入的零交易分类', () async {
      final dining = await createTop('餐饮');
      final idle = await createTop('休闲');
      repo.calls.clear();

      await actions.delete([idle]);

      expect(repo.calls, ['deleteCategoriesByIds($idle)']);
      expect(await repo.categoryStore.getCategoryById(idle), isNull);
      expect(await repo.categoryStore.getCategoryById(dining), isNotNull);
    });
  });

  group('拖拽排序', () {
    test('按 updates 批量写回 sortOrder 并持久化新顺序', () async {
      final shopping = await createTop('购物');
      final clothing = await createSub(shopping, '服装', sortOrder: 0);
      final shoes = await createSub(shopping, '鞋帽', sortOrder: 1);
      repo.calls.clear();

      await actions.reorder([
        (id: shoes, sortOrder: 0),
        (id: clothing, sortOrder: 1),
      ]);

      final subs = await repo.categoryStore.getSubCategories(shopping);
      expect(subs.map((c) => c.id), [
        shoes,
        clothing,
      ], reason: '新顺序写回后按 sortOrder 读出');
    });
  });

  group('新建 / 编辑分类参数契约', () {
    test('新建一级分类：name/kind/icon 原样落库，无父级', () async {
      final id = await actions.create(
        name: '新分类',
        kind: 'expense',
        icon: 'utensils',
      );

      final row = await repo.categoryStore.getCategoryById(id);
      expect(row!.name, '新分类');
      expect(row.kind, 'expense');
      expect(row.icon, 'utensils');
      expect(row.level, 1);
      expect(row.parentId, isNull);
    });

    test('新建二级分类：挂到指定父分类下', () async {
      final parent = await createTop('餐饮');

      final id = await actions.createSub(
        parentId: parent,
        name: '早餐',
        kind: 'expense',
        icon: 'category',
      );

      final row = await repo.categoryStore.getCategoryById(id);
      expect(row!.name, '早餐');
      expect(row.kind, 'expense');
      expect(row.icon, 'category');
      expect(row.level, 2);
      expect(row.parentId, parent);
    });

    test('编辑一级分类：更新名称与图标，父级保持一级', () async {
      final target = await createTop('旧名');

      await actions.update(
        target,
        name: '新名字',
        icon: 'category',
        parentId: null,
        level: 1,
      );

      final row = await repo.categoryStore.getCategoryById(target);
      expect(row!.name, '新名字');
      expect(row.icon, 'category');
      expect(row.level, 1);
      expect(row.parentId, isNull);
    });

    test('编辑二级分类：父级传空串即降为一级', () async {
      final parent = await createTop('餐饮');
      final child = await createSub(parent, '早餐');

      await actions.update(
        child,
        name: '早餐',
        icon: 'utensils',
        parentId: '',
        level: 1,
      );

      final row = await repo.categoryStore.getCategoryById(child);
      expect(row!.parentId, isNull, reason: '空串是清空父分类的仓储契约');
      expect(row.level, 1);
    });
  });

  group('重名判重阻止写入', () {
    test('一级分类判重命中时写入被拒绝且不新增记录', () async {
      await createTop('餐饮');
      expect(
        await actions.isNameDuplicate(name: '餐饮', kind: 'expense'),
        isTrue,
      );

      await expectLater(
        actions.create(name: '餐饮', kind: 'expense', icon: 'category'),
        throwsA(isA<DuplicateNameException>()),
      );

      final topLevel = await repo.categoryStore.getTopLevelCategories(
        'expense',
      );
      expect(
        topLevel.where((c) => c.name == '餐饮'),
        hasLength(1),
        reason: '重名分类不得写入第二条',
      );
    });

    test('二级分类只在同一父级作用域内判重', () async {
      final parentA = await createTop('父分类1');
      final parentB = await createTop('父分类2');
      await createSub(parentA, '鞋子');

      expect(
        await actions.isNameDuplicate(
          name: '鞋子',
          kind: 'expense',
          parentId: parentA,
        ),
        isTrue,
      );
      expect(
        await actions.isNameDuplicate(
          name: '鞋子',
          kind: 'expense',
          parentId: parentB,
        ),
        isFalse,
        reason: '跨父级允许同名',
      );

      await expectLater(
        actions.createSub(
          parentId: parentA,
          name: '鞋子',
          kind: 'expense',
          icon: 'category',
        ),
        throwsA(isA<DuplicateNameException>()),
      );
      final id = await actions.createSub(
        parentId: parentB,
        name: '鞋子',
        kind: 'expense',
        icon: 'category',
      );

      expect((await repo.categoryStore.getCategoryById(id))!.parentId, parentB);
      expect(
        await repo.categoryStore.getSubCategories(parentA),
        hasLength(1),
        reason: '同父重名不得写入',
      );
    });

    test('编辑自身名称不判重（excludeId 排除自身）', () async {
      final target = await createTop('餐饮');

      expect(
        await actions.isNameDuplicate(
          name: '餐饮',
          kind: 'expense',
          excludeId: target,
        ),
        isFalse,
        reason: '编辑保存时不应把自己判成重名',
      );
    });
  });
}
