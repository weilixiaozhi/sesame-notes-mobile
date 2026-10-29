import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/domain/category_detail_summary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalCategoryRepository repo;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
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

  /// 插入一笔交易，currency_code/native_amount 为 NOT NULL，
  /// 未传时用空串表示"未设置"，统计层 tryParse 失败后回退 amount。
  Future<String> insertTx({
    required String ledgerId,
    required String amount,
    String? categoryId,
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
            // 两列是必填 String，夹具以空串覆盖缺失快照的回退行为。
            currencyCode: currencyCode ?? '',
            nativeAmount: nativeAmount ?? '',
            happenedAt: DateTime(2026, 8, 8),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  group('事务与分类身份', () {
    test('createCategory 同父同名也保留独立身份', () async {
      final parent = await repo.createCategory(name: '服装', kind: 'expense');
      final child = await repo.createCategory(
        name: '鞋子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(child, isNotEmpty);

      final sameName = await repo.createCategory(
        name: '鞋子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(sameName, isNot(child));
      expect(
        (await repo.getSubCategories(parent)).map((row) => row.id).toSet(),
        {child, sameName},
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

      // parentId 传空串表示清空父级，并回到一级。
      await repo.updateCategory(child, parentId: '', level: 1);
      final promoted = await repo.getCategoryById(child);
      expect(promoted?.parentId, isNull);
      expect(promoted?.level, 1);
    });

    // 分类被其他设备删除（tombstone）后，过期编辑页里的改名/改图标必须失败：
    // 静默跳过会弹出"已更新"，而改动整条丢失且不登记同步变更。
    test('updateCategory 拒绝已删除或不存在的分类', () async {
      final id = await repo.createCategory(name: '餐饮', kind: 'expense');
      await repo.updateCategory(id, name: '外卖');
      expect((await repo.getCategoryById(id))?.name, '外卖');

      await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(deletedAt: d.Value(DateTime.now().toUtc())),
      );

      await expectLater(
        repo.updateCategory(id, name: '再改'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('无法更新'),
          ),
        ),
      );
      await expectLater(
        repo.updateCategory('missing-category', name: '新建名'),
        throwsStateError,
      );
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
  });

  group('计数与汇总', () {
    test('子分类查询保留空列表、父级归属和存在性判断', () async {
      final parent = await repo.createCategory(name: '父', kind: 'expense');
      expect(await repo.hasSubCategories(parent), isFalse);
      expect(await repo.getSubCategories(parent), isEmpty);

      final child = await repo.createCategory(
        name: '子',
        kind: 'expense',
        parentId: parent,
        level: 2,
      );
      expect(await repo.hasSubCategories(parent), isTrue);
      final children = await repo.getSubCategories(parent);
      expect(children, hasLength(1));
      expect(children.single.id, child);
      expect(children.single.parentId, parent);
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

    test('详情与统计均按本位币汇总全部记录', () async {
      final ledgerId = await createExpenseLedger();
      final catId = await repo.createCategory(name: '餐饮', kind: 'expense');
      await insertTx(
        ledgerId: ledgerId,
        amount: '10.00',
        categoryId: catId,
        currencyCode: 'USD',
        nativeAmount: '72.00',
      );
      await insertTx(ledgerId: ledgerId, amount: '5.00', categoryId: catId);
      await insertTx(ledgerId: ledgerId, amount: '3.00', categoryId: catId);

      final rows = await repo
          .watchTransactionsByCategory(catId, ledgerId: ledgerId)
          .first;
      final summary = summarizeCategoryDetail(
        rows.map((row) => row.toDisplay()).toList(growable: false),
      );
      expect(summary.totalCount, 3);
      expect(summary.totalAmount, 80.0);
      expect(summary.averageAmount, 80 / 3);

      final StatisticsRepository statistics = LocalRepository(db);
      final totals = await statistics.totalsByCategoryWithHierarchy(
        ledgerId: ledgerId,
        type: 'expense',
        start: DateTime(2026, 8, 1),
        end: DateTime(2026, 9, 1),
      );
      expect(totals.single.id, catId);
      expect(totals.single.total, 80.0);
    });

    test('分类详情查询按账本隔离不同本位币，汇总不混算金额', () async {
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

      final cnyRows = await repo
          .watchTransactionsByCategory(catId, ledgerId: cnyLedgerId)
          .first;
      final usdRows = await repo
          .watchTransactionsByCategory(catId, ledgerId: usdLedgerId)
          .first;
      final summary = summarizeCategoryDetail(
        cnyRows.map((row) => row.toDisplay()).toList(growable: false),
      );
      expect(summary.totalCount, 2);
      expect(summary.totalAmount, 80.0);
      expect(summary.averageAmount, 40.0);
      expect(cnyRows.every((tx) => tx.ledgerId == cnyLedgerId), isTrue);
      expect(
        cnyRows.map((tx) => tx.nativeAmount),
        unorderedEquals(['50.00', '30.00']),
      );
      expect(usdRows.single.ledgerId, usdLedgerId);
      final usdSummary = summarizeCategoryDetail(
        usdRows.map((row) => row.toDisplay()).toList(growable: false),
      );
      expect(usdSummary, (
        totalCount: 1,
        totalAmount: 25.0,
        averageAmount: 25.0,
      ));
    });
  });

  group('迁移', () {
    test('二级分类迁移交易（无子分类分支）', () async {
      final ledgerId = await createExpenseLedger();
      final parent = await repo.createCategory(name: '旧父', kind: 'expense');
      final from = await repo.createSubCategory(
        parentId: parent,
        name: '旧子',
        kind: 'expense',
      );
      final to = await repo.createCategory(name: '新父', kind: 'expense');
      await insertTx(ledgerId: ledgerId, amount: '1.00', categoryId: from);

      final result = await repo.migrateCategoryTransactions(
        fromCategoryId: from,
        toCategoryId: to,
      );
      expect(result, 1);

      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.categoryId.equals(to))).getSingle();
      expect(tx.amount, '1.00');
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
    test('getUsableCategories 返回支出分类', () async {
      await repo.createCategory(name: '餐饮', kind: 'expense');

      final usable = await repo.getUsableCategories('expense');
      expect(usable.single.name, '餐饮');
    });

    test('修改为同名后仍按ID编辑原分类', () async {
      final parent = await repo.createCategory(name: '父', kind: 'expense');
      final first = await repo.createSubCategory(
        parentId: parent,
        name: '子',
        kind: 'expense',
      );
      final second = await repo.createSubCategory(
        parentId: parent,
        name: '另一个子',
        kind: 'expense',
      );
      await repo.updateCategory(second, name: '子', icon: 'coffee');
      expect((await repo.getCategoryById(first))!.name, '子');
      expect((await repo.getCategoryById(second))!.icon, 'coffee');
      expect(
        (await repo.getSubCategories(parent)).map((row) => row.id).toSet(),
        {first, second},
      );
    });

    test('filterCategoriesForLedgerPicker 共享 Editor 使用所属账本镜像', () async {
      repo = LocalCategoryRepository(db, accountIdGetter: () => 'viewer');
      await repo.createCategory(name: '本人分类', kind: 'expense');
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'led-picker',
              name: '共享账本',
              role: d.Value('editor'),
              memberCount: d.Value(2),
              storageMode: d.Value('cloud'),
              scopeAccountId: d.Value('viewer'),
              ownerAccountId: d.Value('owner'),
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
      // 镜像分类 id 即 Owner 分类 UUID
      expect(filtered.single.id, 'cat-picker');
    });

    test('共享镜像分类的交易流不要求本地主表存在同 id 分类', () async {
      repo = LocalCategoryRepository(db, accountIdGetter: () => 'viewer');
      final ledgerId = await createExpenseLedger(name: '共享账本');
      await (db.update(
        db.ledgers,
      )..where((ledger) => ledger.id.equals(ledgerId))).write(
        const LedgersCompanion(
          role: d.Value('editor'),
          memberCount: d.Value(2),
          storageMode: d.Value('cloud'),
          scopeAccountId: d.Value('viewer'),
          ownerAccountId: d.Value('owner'),
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
