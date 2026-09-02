import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
  });

  tearDown(() async {
    await db.close();
  });

  /// 直接读取底层账本行，用于证明业务查询隐藏但 tombstone 仍持久化。
  Future<Ledger?> rawLedger(String id) => (db.select(
    db.ledgers,
  )..where((ledger) => ledger.id.equals(id))).getSingleOrNull();

  /// 把分类标记为远端同步同款 tombstone，不经过业务删除的物理删路径。
  Future<void> tombstoneCategory(String id) async {
    final now = DateTime.utc(2026, 8, 24, 12);
    await (db.update(
      db.categories,
    )..where((category) => category.id.equals(id))).write(
      CategoriesCompanion(updatedAt: d.Value(now), deletedAt: d.Value(now)),
    );
  }

  /// 把交易标记为同步回放同款 tombstone，验证仓储直连查询不会继续统计。
  Future<void> tombstoneTransaction(String id) async {
    final now = DateTime.utc(2026, 8, 24, 12);
    await (db.update(
      db.transactions,
    )..where((transaction) => transaction.id.equals(id))).write(
      TransactionsCompanion(updatedAt: d.Value(now), deletedAt: d.Value(now)),
    );
  }

  test('云账本 tombstone：底层保留 syncId，但 get/watch/list/current 读模型不可见', () async {
    final activeId = await repo.createLedger(
      name: '可见本地账本',
      storageMode: 'local',
    );
    const deletedId = 'deleted-cloud-ledger';
    await repo.createBoundLedger(
      id: deletedId,
      name: '已删除云账本',
      syncId: 'sync-deleted',
    );
    await (db.update(
      db.ledgers,
    )..where((ledger) => ledger.id.equals(deletedId))).write(
      const LedgersCompanion(bindingStatus: d.Value('pending_local_move')),
    );

    await repo.deleteLedger(deletedId);

    final raw = await rawLedger(deletedId);
    expect(raw?.deletedAt, isNotNull);
    expect(raw?.syncId, 'sync-deleted');
    expect((await repo.getAllLedgers()).map((ledger) => ledger.id), [activeId]);
    expect(await repo.getLedgerById(deletedId), isNull);
    expect(await repo.watchLedger(deletedId).first, isNull);
    expect((await repo.watchLedgers().first).map((ledger) => ledger.id), [
      activeId,
    ]);
    expect(await repo.getPendingLocalMoveForks(), isEmpty);
  });

  test('账本汇总只统计活跃账本，已删云账本保留的交易不回流统计', () async {
    final activeId = await repo.createLedger(
      name: '活跃账本',
      storageMode: 'local',
    );
    const deletedId = 'deleted-cloud-ledger';
    await repo.createBoundLedger(
      id: deletedId,
      name: '已删除云账本',
      syncId: 'sync-deleted',
    );
    await repo.addTransaction(
      ledgerId: activeId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    final deletedTransaction = await repo.addTransaction(
      ledgerId: activeId,
      type: 'expense',
      amount: '77',
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await repo.addTransaction(
      ledgerId: deletedId,
      type: 'expense',
      amount: '99',
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await tombstoneTransaction(deletedTransaction);

    await repo.deleteLedger(deletedId);

    expect(await repo.getCountsForLedger(ledgerId: deletedId), (
      dayCount: 0,
      txCount: 0,
    ));
    expect(await repo.getLedgerStats(ledgerId: deletedId), (
      expenseTotal: 0.0,
      transactionCount: 0,
    ));
    expect((await repo.getCountsForLedger(ledgerId: activeId)).txCount, 1);
    expect(await repo.getLedgerStats(ledgerId: activeId), (
      expenseTotal: 10.0,
      transactionCount: 1,
    ));
    final rawActiveRows = await (db.select(
      db.transactions,
    )..where((transaction) => transaction.ledgerId.equals(activeId))).get();
    expect(
      await repo.getLedgerStats(
        ledgerId: activeId,
        transactions: rawActiveRows,
      ),
      (expenseTotal: 10.0, transactionCount: 1),
    );
    final allStats = await repo.getAllLedgerStats();
    expect(allStats.keys, {activeId});
    expect(allStats[activeId]?.transactionCount, 1);
    expect(allStats[activeId]?.expenseTotal, 10);
  });

  test('分类 tombstone：get/list/tree/picker/watch 均只返回活跃分类', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
    );
    final activeTop = await repo.createCategory(name: '活跃一级', kind: 'expense');
    final activeChild = await repo.createSubCategory(
      parentId: activeTop,
      name: '活跃二级',
      kind: 'expense',
    );
    final deletedTop = await repo.createCategory(name: '已删一级', kind: 'expense');
    final deletedChild = await repo.createSubCategory(
      parentId: activeTop,
      name: '已删二级',
      kind: 'expense',
    );
    await (db.update(
      db.ledgers,
    )..where((ledger) => ledger.id.equals(ledgerId))).write(
      const LedgersCompanion(role: d.Value('editor'), memberCount: d.Value(2)),
    );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: ledgerId,
            categoryId: deletedTop,
            name: '共享镜像中的已删一级',
            kind: 'expense',
            updatedAt: DateTime.utc(2026, 8, 24),
          ),
        );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: ledgerId,
            categoryId: activeTop,
            name: '共享镜像中的活跃一级',
            kind: 'expense',
            updatedAt: DateTime.utc(2026, 8, 24),
          ),
        );
    await tombstoneCategory(deletedTop);
    await tombstoneCategory(deletedChild);

    expect(
      await (db.select(
        db.categories,
      )..where((category) => category.id.equals(deletedTop))).getSingle(),
      isNotNull,
    );
    expect(await repo.getCategoryById(deletedTop), isNull);
    expect((await repo.getCategoriesByIds({activeTop, deletedTop})).keys, {
      activeTop,
    });
    expect((await repo.getAllCategories()).map((category) => category.id), {
      activeTop,
      activeChild,
    });
    expect(
      (await repo.getAllCategoriesIncludingShared()).map(
        (category) => category.id,
      ),
      {activeTop, activeChild},
    );
    expect(
      (await repo.getTopLevelCategories(
        'expense',
      )).map((category) => category.id),
      [activeTop],
    );
    expect(
      (await repo.getSubCategories(activeTop)).map((category) => category.id),
      [activeChild],
    );
    final tree = await repo.getCategoryTree('expense');
    expect(tree.topLevel.map((category) => category.id), [activeTop]);
    expect(tree.children[activeTop]?.map((category) => category.id), [
      activeChild,
    ]);
    expect(
      (await repo.getUsableCategories(
        'expense',
      )).map((category) => category.id),
      [activeChild],
    );
    final rawCategories = await db.select(db.categories).get();
    expect(
      (await repo.filterCategoriesForLedgerPicker(
        rawCategories,
        ledgerId: ledgerId,
        kind: 'expense',
        topLevelOnly: false,
      )).map((category) => category.id),
      [activeTop],
    );
    expect(await repo.watchCategory(deletedTop).first, isNull);
    expect(
      (await repo.watchCategoryWithSubs(activeTop).first).map(
        (category) => category.id,
      ),
      {activeTop, activeChild},
    );
  });

  test('分类汇总与交易列表不读取 tombstone 分类，活跃父类不统计已删子类', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
    );
    final activeTop = await repo.createCategory(name: '活跃一级', kind: 'expense');
    final activeChild = await repo.createSubCategory(
      parentId: activeTop,
      name: '活跃二级',
      kind: 'expense',
    );
    final deletedChild = await repo.createSubCategory(
      parentId: activeTop,
      name: '已删二级',
      kind: 'expense',
    );
    final deletedTop = await repo.createCategory(name: '已删一级', kind: 'expense');
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      categoryId: activeChild,
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    final deletedTransaction = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '66',
      categoryId: activeChild,
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '20',
      categoryId: deletedChild,
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '99',
      categoryId: deletedTop,
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await tombstoneCategory(deletedChild);
    await tombstoneCategory(deletedTop);
    await tombstoneTransaction(deletedTransaction);

    expect(await repo.hasSubCategories(activeTop), isTrue);
    expect(await repo.getSubCategoryCount(activeTop), 1);
    expect(await repo.getTransactionCountByCategory(deletedTop), 0);
    expect(await repo.getTransactionCountByCategory(activeChild), 1);
    expect(await repo.getCategorySummary(deletedTop, ledgerId: ledgerId), (
      totalCount: 0,
      totalAmount: 0.0,
      averageAmount: 0.0,
    ));
    expect(await repo.getCategorySummary(activeChild, ledgerId: ledgerId), (
      totalCount: 1,
      totalAmount: 10.0,
      averageAmount: 10.0,
    ));
    expect(await repo.getTransactionsByCategory(deletedTop), isEmpty);
    expect(await repo.getTransactionsByCategory(activeChild), hasLength(1));
    expect(
      await repo.getTransactionsByCategoryWithSort(
        deletedTop,
        ledgerId: ledgerId,
      ),
      isEmpty,
    );
    expect(
      await repo.getTransactionsByCategoryWithSort(
        activeChild,
        ledgerId: ledgerId,
      ),
      hasLength(1),
    );
    expect(await repo.watchTransactionsByCategory(deletedTop).first, isEmpty);
    expect(
      await repo.watchTransactionsByCategory(activeChild).first,
      hasLength(1),
    );
    expect(
      await repo
          .watchTransactionsByCategory(
            activeTop,
            ledgerId: ledgerId,
            includeSubCategories: true,
          )
          .first,
      hasLength(1),
    );

    final counts = await repo.getAllCategoryTransactionCounts();
    expect(counts.keys, {activeTop, activeChild});
    expect(counts[activeChild], 1);
    final watchedCounts = await repo.watchCategoriesWithCount().first;
    expect(watchedCounts.map((item) => item.category.id), {
      activeTop,
      activeChild,
    });
    final topCount = watchedCounts
        .singleWhere((item) => item.category.id == activeTop)
        .transactionCount;
    expect(topCount, 1);
    expect(await repo.getCategoryFullName(deletedTop), isEmpty);
    expect(
      (await repo.getCategoryMigrationInfo(
        fromCategoryId: activeChild,
        toCategoryId: deletedTop,
      )).canMigrate,
      isFalse,
    );
    expect(
      await repo.isCategoryNameDuplicate(name: '已删一级', kind: 'expense'),
      isFalse,
    );
  });
}
