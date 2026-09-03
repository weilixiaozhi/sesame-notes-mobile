// LocalCategoryRepository 补充测试。
//
// 覆盖分支：作用域判重（parentId 分支）、更新/排序/全名、
// 计数与汇总（含排除统计/多币种快照）、迁移守卫、批量插入、picker 过滤。
//
// 锚点：分类树契约「同一父级作用域内 (name, kind) 唯一、跨父级/跨层级允许
// 同名」；v1 下所有分类 id 均为 UUID，共享账本 Editor 视角的镜像分类
// categoryId 与主表共用同一 id 空间。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalCategoryRepository repo;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalCategoryRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // UUID 主键表 insert 要求调用方提供 id，用自增序号生成确定性的测试 id。
  var ledgerSeq = 0;
  var txSeq = 0;

  /// 创建可指定本位币的支出账本，供跨账本隔离场景复用。
  Future<String> createExpenseLedger({
    String name = '账本',
    String currency = 'CNY',
  }) async {
    final now = DateTime.now().toUtc();
    final id = 'led-${ledgerSeq++}';
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            currency: d.Value(currency),
            updatedAt: now,
          ),
        );
    return id;
  }

  /// 插入一笔交易。v1 下 currency_code/native_amount 为 NOT NULL，
  /// 未传时用空串表示"未设置"，统计层 tryParse 失败后回退 amount。
  Future<String> insertTx({
    required String ledgerId,
    required String amount,
    String? categoryId,
    bool excludeFromStats = false,
    String? currencyCode,
    String? nativeAmount,
  }) async {
    final now = DateTime.now().toUtc();
    final id = 'tx-${txSeq++}';
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: amount,
            categoryId: d.Value(categoryId),
            excludeFromStats: d.Value(excludeFromStats),
            // v1 两列为必填的 String（非 Value 包装）
            currencyCode: currencyCode ?? '',
            nativeAmount: nativeAmount ?? '',
            happenedAt: DateTime(2026, 8, 8),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  group('事务与作用域判重', () {
    test('runInTransaction 透传', () async {
      final id = await repo.runInTransaction(
        () => repo.createCategory(name: '事务分类', kind: 'expense'),
      );
      expect(await repo.getCategoryById(id), isNotNull);
    });

    test('createCategory 指定父级时按父级作用域判重', () async {
      final parent = await repo.createCategory(name: '服装', kind: 'expense');
      final child = await repo.createCategory(
        name: '鞋子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(child, isNotEmpty);

      // 同父级重名抛错
      expect(
        () => repo.createCategory(
          name: '鞋子',
          kind: 'expense',
          parentId: parent,
          level: 2,
        ),
        throwsA(isA<Object>()),
      );
      // 不同父级允许同名
      final otherParent = await repo.createCategory(
        name: '购物',
        kind: 'expense',
      );
      final otherChild = await repo.createCategory(
        name: '鞋子',
        kind: 'expense',
        parentId: otherParent,
        level: 2,
      );
      expect(otherChild, isNot(child));
    });
  });

  group('更新与排序', () {
    test('updateCategory 改名/图标/清空父级/改层级', () async {
      final parent = await repo.createCategory(name: '旧父', kind: 'expense');
      final child = await repo.createCategory(
        name: '旧子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );

      await repo.updateCategory(child, name: '新子', icon: 'shirt');
      final updated = await repo.getCategoryById(child);
      expect(updated?.name, '新子');
      expect(updated?.icon, 'shirt');

      // parentId 传空串 → 清空父级并回到一级（v1 用空串替代旧 -1 哨兵）
      await repo.updateCategory(child, parentId: '', level: 1);
      final promoted = await repo.getCategoryById(child);
      expect(promoted?.parentId, isNull);
      expect(promoted?.level, 1);
    });

    test('updateCategorySortOrders 批量写排序', () async {
      final a = await repo.createCategory(name: 'A', kind: 'expense');
      final b = await repo.createCategory(name: 'B', kind: 'expense');
      await repo.updateCategorySortOrders([
        (id: a, sortOrder: 9),
        (id: b, sortOrder: 1),
      ]);

      final byId = await repo.getCategoriesByIds([a, b]);
      expect(byId[a]?.sortOrder, 9);
      expect(byId[b]?.sortOrder, 1);
    });

    test('getCategoryFullName 一级/子级/父级缺失', () async {
      final parent = await repo.createCategory(name: '餐饮', kind: 'expense');
      final child = await repo.createCategory(
        name: '外卖',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(await repo.getCategoryFullName(parent), '餐饮');
      expect(await repo.getCategoryFullName(child), '餐饮 / 外卖');
      expect(await repo.getCategoryFullName('no-such-id'), '');

      // 父级被删（绕过 fail-loud 直接落库，模拟历史脏数据）后降级返回子级名
      await (db.delete(db.categories)..where((c) => c.id.equals(parent))).go();
      expect(await repo.getCategoryFullName(child), '外卖');
    });
  });

  group('计数与汇总', () {
    test('hasSubCategories / getSubCategoryCount', () async {
      final parent = await repo.createCategory(name: '父', kind: 'expense');
      expect(await repo.hasSubCategories(parent), isFalse);
      expect(await repo.getSubCategoryCount(parent), 0);

      await repo.createCategory(
        name: '子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(await repo.hasSubCategories(parent), isTrue);
      expect(await repo.getSubCategoryCount(parent), 1);
    });

    test('getAllCategoryTransactionCounts 含左连接补零', () async {
      final ledgerId = await createExpenseLedger();
      final emptyCat = await repo.createCategory(name: '空', kind: 'expense');
      final usedCat = await repo.createCategory(name: '有账', kind: 'expense');
      await insertTx(ledgerId: ledgerId, amount: '1.00', categoryId: usedCat);
      await insertTx(ledgerId: ledgerId, amount: '2.00', categoryId: usedCat);

      final counts = await repo.getAllCategoryTransactionCounts();
      expect(counts[usedCat], 2);
      expect(counts[emptyCat], 0);
    });

    test('getCategorySummary 按 native_amount 汇总并排除 excludeFromStats', () async {
      final ledgerId = await createExpenseLedger();
      final catId = await repo.createCategory(name: '餐饮', kind: 'expense');
      await insertTx(
        ledgerId: ledgerId,
        amount: '10.00',
        categoryId: catId,
        currencyCode: 'USD',
        nativeAmount: '72.00',
      );
      await insertTx(
        ledgerId: ledgerId,
        amount: '5.00',
        categoryId: catId,
        excludeFromStats: true,
      );
      await insertTx(ledgerId: ledgerId, amount: '3.00', categoryId: catId);

      final summary = await repo.getCategorySummary(catId, ledgerId: ledgerId);
      expect(summary.totalCount, 3); // 笔数含排除项
      expect(summary.totalAmount, 75.0); // 72 + 3，排除 5
      expect(summary.averageAmount, 37.5);
    });

    test('分类汇总与排序按账本隔离不同本位币', () async {
      final cnyLedgerId = await createExpenseLedger(
        name: '人民币账本',
        currency: 'CNY',
      );
      final usdLedgerId = await createExpenseLedger(
        name: '美元账本',
        currency: 'USD',
      );
      final catId = await repo.createCategory(name: '共用分类', kind: 'expense');

      await insertTx(
        ledgerId: cnyLedgerId,
        amount: '50.00',
        categoryId: catId,
        currencyCode: 'CNY',
        nativeAmount: '50.00',
      );
      await insertTx(
        ledgerId: cnyLedgerId,
        amount: '30.00',
        categoryId: catId,
        currencyCode: 'CNY',
        nativeAmount: '30.00',
      );
      await insertTx(
        ledgerId: usdLedgerId,
        amount: '25.00',
        categoryId: catId,
        currencyCode: 'USD',
        nativeAmount: '25.00',
      );

      final summary = await repo.getCategorySummary(
        catId,
        ledgerId: cnyLedgerId,
      );
      expect(summary.totalCount, 2);
      expect(summary.totalAmount, 80.0);
      expect(summary.averageAmount, 40.0);

      // 金额排序按折算值（nativeAmount）；两笔同位数 decimal 字符串，
      // 字典序与数值序一致（'50.00' > '30.00'）。
      final sorted = await repo.getTransactionsByCategoryWithSort(
        catId,
        ledgerId: cnyLedgerId,
        sortBy: 'amount',
      );
      expect(sorted, hasLength(2));
      expect(sorted.every((tx) => tx.ledgerId == cnyLedgerId), isTrue);
      expect(sorted.map((tx) => tx.nativeAmount), ['50.00', '30.00']);
    });
  });

  group('分类交易查询', () {
    test('getTransactionsByCategoryWithSort 按金额/时间排序', () async {
      final ledgerId = await createExpenseLedger();
      final catId = await repo.createCategory(name: '交通', kind: 'expense');
      await insertTx(
        ledgerId: ledgerId,
        amount: '10.00',
        categoryId: catId,
        currencyCode: 'USD',
        nativeAmount: '20.00',
      );
      await insertTx(
        ledgerId: ledgerId,
        amount: '30.00',
        categoryId: catId,
        currencyCode: 'CNY',
        nativeAmount: '30.00',
      );

      // amount 排序按折算值（USD 快照 20 < CNY 30）；
      // v1 下 native_amount 为 NOT NULL，两笔都显式给快照避免空串参与排序
      final byAmount = await repo.getTransactionsByCategoryWithSort(
        catId,
        ledgerId: ledgerId,
        sortBy: 'amount',
      );
      expect(byAmount.first.amount, '30.00');
      expect(byAmount.last.amount, '10.00');

      final byAmountAsc = await repo.getTransactionsByCategoryWithSort(
        catId,
        ledgerId: ledgerId,
        sortBy: 'amount',
        ascending: true,
      );
      expect(byAmountAsc.first.amount, '10.00');

      final byTime = await repo.getTransactionsByCategoryWithSort(
        catId,
        ledgerId: ledgerId,
      );
      expect(byTime, hasLength(2));
    });
  });

  group('迁移', () {
    test('二级分类迁移交易（无子分类分支）', () async {
      final ledgerId = await createExpenseLedger();
      final from = await repo.createCategory(
        name: '旧子',
        kind: 'expense',
        level: 2,
      );
      final to = await repo.createCategory(name: '新父', kind: 'expense');
      await insertTx(ledgerId: ledgerId, amount: '1.00', categoryId: from);

      final result = await repo.migrateCategoryTransactions(
        fromCategoryId: from,
        toCategoryId: to,
      );
      expect(result.migratedTransactions, 1);
      expect(result.migratedSubCategories, 0);

      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.categoryId.equals(to))).getSingle();
      expect(tx.amount, '1.00');
    });

    test('getCategoryMigrationInfo 目标缺失/相同分类不可迁移', () async {
      final a = await repo.createCategory(name: 'A', kind: 'expense');
      final b = await repo.createCategory(name: 'B', kind: 'expense');

      final noTarget = await repo.getCategoryMigrationInfo(
        fromCategoryId: a,
        toCategoryId: 'no-such-id',
      );
      expect(noTarget.canMigrate, isFalse);

      final same = await repo.getCategoryMigrationInfo(
        fromCategoryId: a,
        toCategoryId: a,
      );
      expect(same.canMigrate, isFalse);

      final ledgerId = await createExpenseLedger();
      await insertTx(ledgerId: ledgerId, amount: '1.00', categoryId: a);
      final ok = await repo.getCategoryMigrationInfo(
        fromCategoryId: a,
        toCategoryId: b,
      );
      expect(ok.canMigrate, isTrue);
    });
  });

  test('batchInsertCategories / insertCategory 落库', () async {
    final now = DateTime.now().toUtc();
    await repo.batchInsertCategories([
      CategoriesCompanion.insert(
        id: 'cat-batch-a',
        name: '批量A',
        kind: 'expense',
        level: 1,
        updatedAt: now,
      ),
      CategoriesCompanion.insert(
        id: 'cat-batch-b',
        name: '批量B',
        kind: 'expense',
        level: 1,
        updatedAt: now,
      ),
    ]);
    final id = await repo.insertCategory(
      CategoriesCompanion.insert(
        id: 'cat-single',
        name: '单个',
        kind: 'expense',
        level: 1,
        updatedAt: now,
      ),
    );
    expect(id, 'cat-single');
    expect(await repo.getAllCategories(), hasLength(3));
  });

  group('picker 过滤', () {
    test('getUsableCategories 按 kind 过滤并复用层级规则', () async {
      await repo.createCategory(name: '餐饮', kind: 'expense');
      await repo.createCategory(name: '工资', kind: 'income');

      final usable = await repo.getUsableCategories('expense');
      expect(usable.single.name, '餐饮');
    });

    test('isCategoryNameDuplicate 支持 excludeId 与父级作用域', () async {
      final parent = await repo.createCategory(name: '父', kind: 'expense');
      final child = await repo.createCategory(
        name: '子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );

      expect(
        await repo.isCategoryNameDuplicate(
          name: '子',
          kind: 'expense',
          parentId: parent,
        ),
        isTrue,
      );
      expect(
        await repo.isCategoryNameDuplicate(
          name: '子',
          kind: 'expense',
          parentId: parent,
          excludeId: child,
        ),
        isFalse,
      );
    });

    test('filterCategoriesForLedgerPicker 共享 Editor 替换为主表', () async {
      await repo.createCategory(name: '本地分类', kind: 'expense');
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'led-picker',
              name: '共享账本',
              role: d.Value('editor'),
              memberCount: d.Value(2),
              storageMode: d.Value('cloud'),
              updatedAt: DateTime(2026, 8, 8),
            ),
          );
      const sharedId = 'led-picker';
      await db
          .into(db.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: 'led-picker',
              categoryId: 'cat-picker',
              name: '共享分类',
              kind: 'expense',
              updatedAt: DateTime(2026, 8, 8),
            ),
          );
      final all = await repo.getAllCategories();
      final filtered = await repo.filterCategoriesForLedgerPicker(
        all,
        ledgerId: sharedId,
      );
      expect(filtered.single.name, '共享分类');
      // 镜像分类 id 即 Owner 分类 UUID，无负数 synthetic id
      expect(filtered.single.id, 'cat-picker');
    });

    test('共享镜像分类的交易流不要求本地主表存在同 id 分类', () async {
      final ledgerId = await createExpenseLedger(name: '共享账本');
      await (db.update(
        db.ledgers,
      )..where((ledger) => ledger.id.equals(ledgerId))).write(
        const LedgersCompanion(
          role: d.Value('editor'),
          memberCount: d.Value(2),
          storageMode: d.Value('cloud'),
        ),
      );
      await db
          .into(db.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: ledgerId,
              categoryId: 'owner-category',
              name: 'Owner 分类',
              kind: 'expense',
              updatedAt: DateTime.utc(2026, 8, 24),
            ),
          );
      await insertTx(
        ledgerId: ledgerId,
        amount: '12',
        categoryId: 'owner-category',
      );

      expect(
        await repo
            .watchTransactionsByCategory('owner-category', ledgerId: ledgerId)
            .first,
        hasLength(1),
        reason: 'Editor 只有共享镜像，本地主表 inner join 不得误删交易',
      );
    });
  });
}
