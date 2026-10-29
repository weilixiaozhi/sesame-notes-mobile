import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('分类名称与实体身份独立', () {
    test('同名同图标一级分类每次创建独立身份', () async {
      final first = await repo.createCategory(
        name: '红包',
        kind: 'expense',
        icon: 'gift',
      );
      final second = await repo.createCategory(
        name: '红包',
        kind: 'expense',
        icon: 'gift',
      );
      expect(first, isNot(second));
      expect(
        (await repo.categoryStore.getAllCategories())
            .map((row) => row.id)
            .toSet(),
        {first, second},
      );
    });
    test('同父同名子分类分别保留，不合并引用', () async {
      final parent = await repo.createCategory(name: '餐饮', kind: 'expense');
      final first = await repo.createSubCategory(
        parentId: parent,
        name: '午餐',
        kind: 'expense',
      );
      final second = await repo.createSubCategory(
        parentId: parent,
        name: '午餐',
        kind: 'expense',
      );
      expect(first, isNot(second));
      expect(
        (await repo.categoryStore.getSubCategories(
          parent,
        )).map((row) => row.id).toSet(),
        {first, second},
      );
    });
    test('跨父与跨层同名始终绑定明确的父ID', () async {
      final first = await repo.createCategory(name: '购物', kind: 'expense');
      final second = await repo.createCategory(name: '购物', kind: 'expense');
      final childA = await repo.createSubCategory(
        parentId: first,
        name: '鞋子',
        kind: 'expense',
      );
      final childB = await repo.createSubCategory(
        parentId: second,
        name: '鞋子',
        kind: 'expense',
      );
      final top = await repo.createCategory(name: '鞋子', kind: 'expense');
      expect({childA, childB, top}, hasLength(3));
      expect(
        (await repo.categoryStore.getSubCategories(first)).single.id,
        childA,
      );
      expect(
        (await repo.categoryStore.getSubCategories(second)).single.id,
        childB,
      );
      expect((await repo.categoryStore.getCategoryById(top))!.parentId, isNull);
    });
  });

  group('deleteCategory fail-loud', () {
    test('有子分类时拒绝直接删除并保留分类', () async {
      final parent = await repo.createCategory(name: '父类', kind: 'expense');
      await repo.createSubCategory(
        parentId: parent,
        name: '子类',
        kind: 'expense',
      );

      await expectLater(
        repo.deleteCategory(parent),
        throwsA(isA<StateError>()),
      );
      expect(await repo.categoryStore.getCategoryById(parent), isNotNull);
    });

    test('有交易时拒绝直接删除并保留分类与交易', () async {
      final ledgerId = await repo.createLedger(
        name: '删分类',
        storageMode: 'local',
      );
      final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 8, 5),
        categoryId: categoryId,
      );

      await expectLater(
        repo.deleteCategory(categoryId),
        throwsA(isA<StateError>()),
      );
      expect(await repo.categoryStore.getCategoryById(categoryId), isNotNull);
      expect(
        await repo.categoryStore.watchTransactionsByCategory(categoryId).first,
        hasLength(1),
      );
    });

    test('空分类可直接删除', () async {
      final categoryId = await repo.createCategory(name: '空类', kind: 'expense');
      await repo.deleteCategory(categoryId);
      expect(await repo.categoryStore.getCategoryById(categoryId), isNull);
    });
  });

  group('watchCategoryWithSubs / watchCategoriesWithCount', () {
    test('watchCategoryWithSubs 返回父+子分类且 id 均为 UUID', () async {
      final parent = await repo.createCategory(name: '父类', kind: 'expense');
      await repo.createSubCategory(
        parentId: parent,
        name: '子类',
        kind: 'expense',
      );

      final cats = await repo.categoryStore.watchCategoryWithSubs(parent).first;

      expect(cats, hasLength(2));
      // 父子分类都来自主表，并具有非空身份。
      expect(cats.every((c) => c.id.isNotEmpty), isTrue);
    });

    test('watchCategoriesWithCount 返回含子分类的总笔数', () async {
      final ledgerId = await repo.createLedger(
        name: '统计',
        storageMode: 'local',
      );
      final parent = await repo.createCategory(name: '父类', kind: 'expense');
      final child = await repo.createSubCategory(
        parentId: parent,
        name: '子类',
        kind: 'expense',
      );
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 8, 5),
        categoryId: parent,
      );
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime(2026, 8, 5),
        categoryId: child,
      );

      final rows = await repo.categoryStore.watchCategoriesWithCount().first;
      final parentRow = rows.firstWhere((r) => r.category.id == parent);
      final childRow = rows.firstWhere((r) => r.category.id == child);

      expect(parentRow.transactionCount, 2);
      expect(childRow.transactionCount, 1);
    });

    test('watchCategoriesWithCount 仅返回支出分类并保留未使用分类', () async {
      final ledgerId = await repo.createLedger(
        name: '仅支出账本',
        storageMode: 'local',
      );
      final used = await repo.createCategory(name: '餐饮', kind: 'expense');
      final unused = await repo.createCategory(name: '购物', kind: 'expense');
      await repo.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 8, 5),
        categoryId: used,
      );

      final rows = await repo.categoryStore.watchCategoriesWithCount().first;

      expect(
        {for (final row in rows) row.category.id: row.transactionCount},
        {used: 1, unused: 0},
      );
    });
  });
}
