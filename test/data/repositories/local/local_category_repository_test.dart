import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';

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

  group('支出分类名称判重', () {
    test('同 kind 重名抛 DuplicateNameException', () async {
      await repo.createCategory(name: '红包', kind: 'expense');
      expect(
        () => repo.createCategory(name: '红包', kind: 'expense'),
        throwsA(isA<DuplicateNameException>()),
      );
    });

    test('upsertCategory 复用同名支出分类', () async {
      final a = await repo.upsertCategory(name: '红包', kind: 'expense');
      final aAgain = await repo.upsertCategory(name: '红包', kind: 'expense');
      expect(aAgain.id, a.id);
      expect(aAgain.created, isFalse);
    });

    test('createSubCategory 同父级下重名抛 DuplicateNameException', () async {
      final p = await repo.createCategory(name: '餐饮', kind: 'expense');
      await repo.createSubCategory(parentId: p, name: '午餐', kind: 'expense');
      expect(
        () => repo.createSubCategory(parentId: p, name: '午餐', kind: 'expense'),
        throwsA(isA<DuplicateNameException>()),
      );
    });
  });

  group('分类作用域唯一(跨父级/跨层级允许同名)', () {
    test('跨父级同名二级分类可共存(购物>鞋子 + 服装>鞋子)', () async {
      final pShopping = await repo.createCategory(name: '购物', kind: 'expense');
      final pClothing = await repo.createCategory(name: '服装', kind: 'expense');
      final shoesA = await repo.createSubCategory(
        parentId: pShopping,
        name: '鞋子',
        kind: 'expense',
      );
      final shoesB = await repo.createSubCategory(
        parentId: pClothing,
        name: '鞋子',
        kind: 'expense',
      );
      expect(shoesA, isNot(shoesB));
    });

    test('一级与二级允许同名(「服装」父分类 vs「购物>服装」子分类)', () async {
      final pShopping = await repo.createCategory(name: '购物', kind: 'expense');
      await repo.createSubCategory(
        parentId: pShopping,
        name: '服装',
        kind: 'expense',
      );
      // 已存在「购物>服装」二级分类时,仍可创建同名一级分类
      final l1 = await repo.createCategory(name: '服装', kind: 'expense');
      expect(l1, isNotEmpty);
    });

    test('isCategoryNameDuplicate 按作用域判重', () async {
      final pShopping = await repo.createCategory(name: '购物', kind: 'expense');
      final pClothing = await repo.createCategory(name: '服装', kind: 'expense');
      await repo.createSubCategory(
        parentId: pShopping,
        name: '鞋子',
        kind: 'expense',
      );
      // 同父级作用域 → 重复
      expect(
        await repo.categoryStore.isCategoryNameDuplicate(
          name: '鞋子',
          kind: 'expense',
          parentId: pShopping,
        ),
        isTrue,
      );
      // 另一个父级作用域 → 不算重复
      expect(
        await repo.categoryStore.isCategoryNameDuplicate(
          name: '鞋子',
          kind: 'expense',
          parentId: pClothing,
        ),
        isFalse,
      );
      // 根作用域(一级分类之间) → 与二级「鞋子」不冲突
      expect(
        await repo.categoryStore.isCategoryNameDuplicate(
          name: '鞋子',
          kind: 'expense',
        ),
        isFalse,
      );
    });

    test('upsertCategory 遇不同父级同名子类报告冲突，不合并或新增同名类别', () async {
      final pShopping = await repo.createCategory(name: '购物', kind: 'expense');
      final pClothing = await repo.createCategory(name: '服装', kind: 'expense');
      // 固定身份用于确认不同父级的原分类均完整保留。
      final now = DateTime.now().toUtc();
      final shoesA = 'cat-shoes-a';
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: shoesA,
              name: '鞋子',
              kind: 'expense',
              level: 2,
              parentId: Value(pShopping),
              updatedAt: now,
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat-shoes-b',
              name: '鞋子',
              kind: 'expense',
              level: 2,
              parentId: Value(pClothing),
              updatedAt: now,
            ),
          );
      final before = await db.select(db.categories).get();
      await expectLater(
        repo.upsertCategory(name: '鞋子', kind: 'expense'),
        throwsStateError,
      );
      expect(await db.select(db.categories).get(), before);
      expect(
        (await repo.categoryStore.getSubCategories(pShopping)).single.id,
        shoesA,
      );
      expect(
        (await repo.categoryStore.getSubCategories(pClothing)).single.id,
        'cat-shoes-b',
      );
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
