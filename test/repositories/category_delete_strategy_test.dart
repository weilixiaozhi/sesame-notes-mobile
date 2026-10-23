import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';

/// 验证分类提升排序、批量级联删除和同名目标子类的迁移边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置偏好、平台和通知单例，避免日志存储与全局状态产生顺序依赖。
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalCategoryRepository repo;

  /// 每个测试前创建内存数据库 + 仓储实例
  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalCategoryRepository(db);
  });

  /// 每个测试后关闭数据库
  tearDown(() async {
    await db.close();
  });

  // UUID 主键表 insert 要求调用方提供 id，用自增序号生成确定性的测试 id。
  var seq = 0;

  /// 创建一个一级分类，返回其 id
  Future<String> createTopCategory(String name, {int sortOrder = 0}) async {
    return await repo.createCategory(
      name: name,
      kind: 'expense',
      icon: 'utensils',
      sortOrder: sortOrder,
    );
  }

  /// 在指定父分类下创建一个二级分类，返回其 id
  Future<String> createSubCategory(String parentId, String name) async {
    return await repo.createSubCategory(
      parentId: parentId,
      name: name,
      kind: 'expense',
      icon: 'utensils',
    );
  }

  /// 在指定账本下、指定分类创建一条交易记录，返回其 id
  Future<String> createTransaction(String ledgerId, String? categoryId) async {
    const amount = '100.00';
    final now = DateTime.now().toUtc();
    final id = 'tx-${seq++}';
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: amount,
            categoryId: drift.Value(categoryId),
            happenedAt: DateTime(2026, 8, 1),
            currencyCode: 'CNY',
            nativeAmount: amount,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  /// 创建一个账本，返回其 id
  Future<String> createLedger() async {
    final now = DateTime.now().toUtc();
    final id = 'led-${seq++}';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(id: id, name: 'Test Ledger', updatedAt: now),
        );
    return id;
  }

  group('promoteSubCategoriesToTopLevel — 提升子分类为一级', () {
    test('提升后的子分类 sortOrder 排在已有分类之后', () async {
      // 已有两个一级分类 sortOrder=0, 1
      await createTopCategory('交通', sortOrder: 0);
      await createTopCategory('购物', sortOrder: 1);
      final parentId = await createTopCategory('餐饮', sortOrder: 2);
      await createSubCategory(parentId, '早餐');

      await repo.promoteSubCategoriesToTopLevel(parentId);

      final topLevel = await repo.getTopLevelCategories('expense');
      final promotedCat = topLevel.firstWhere((c) => c.name == '早餐');
      // 提升 sortOrder 应 >= max(已有 sortOrder) = 2
      expect(
        promotedCat.sortOrder,
        greaterThanOrEqualTo(2),
        reason: '提升后的分类 sortOrder 应排在已有分类之后',
      );
    });
  });

  group('策略 A：删除分类和分类下的所有数据（含二级）', () {
    test('删除多个一级分类及其子分类', () async {
      final ledgerId = await createLedger();
      final cat1 = await createTopCategory('餐饮');
      final sub1 = await createSubCategory(cat1, '早餐');
      final cat2 = await createTopCategory('交通');
      final sub2 = await createSubCategory(cat2, '地铁');

      await createTransaction(ledgerId, cat1);
      await createTransaction(ledgerId, sub1);
      await createTransaction(ledgerId, cat2);
      await createTransaction(ledgerId, sub2);

      final allIds = [cat1, sub1, cat2, sub2];
      await repo.deleteTransactionsByCategoryIds(allIds);
      await repo.deleteCategoriesByIds([cat1, cat2]);

      // 验证所有分类都被删除（deleteCategoriesByIds 会连带删除子分类）
      expect(await repo.getCategoryById(cat1), isNull);
      expect(await repo.getCategoryById(sub1), isNull);
      expect(await repo.getCategoryById(cat2), isNull);
      expect(await repo.getCategoryById(sub2), isNull);
    });
  });

  group('策略 B：删除分类及其子分类并迁移所有数据到其他分类', () {
    test('目标分类已有同名子分类时数据仍统一迁往目标分类（不合并子分类）', () async {
      final ledgerId = await createLedger();
      final sourceCat = await createTopCategory('旧分类');
      await createSubCategory(sourceCat, '同名子分类');
      final targetCat = await createTopCategory('新分类');
      final existingSub = await createSubCategory(targetCat, '同名子分类');

      // 在源子分类和目标子分类下各创建 1 条交易
      final sourceSubs = await repo.getSubCategories(sourceCat);
      final sourceSubId = sourceSubs.first.id;
      await createTransaction(ledgerId, sourceSubId);
      await createTransaction(ledgerId, existingSub);

      final result = await repo.migrateCategoryTransactions(
        fromCategoryId: sourceCat,
        toCategoryId: targetCat,
      );

      // 源子分类的交易直接改挂目标分类，不参与同名子分类合并
      expect(result, 1, reason: '应迁移源子分类的 1 条交易到目标分类');
      expect(
        await repo.getTransactionCountByCategory(targetCat),
        1,
        reason: '目标分类应有源子分类迁来的 1 条交易',
      );
      expect(
        await repo.getTransactionCountByCategory(existingSub),
        1,
        reason: '目标同名子分类保持原有 1 条交易，不参与合并',
      );
      expect(
        await repo.getTransactionCountByCategory(sourceSubId),
        0,
        reason: '源子分类的交易应已迁出',
      );
    });
  });
}
