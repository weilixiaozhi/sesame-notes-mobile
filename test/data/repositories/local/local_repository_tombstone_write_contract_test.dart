import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

import '../../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
      currency: 'CNY',
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// 新建一笔测试交易；可指定分类与多币种快照。
  Future<String> addTransaction({
    String? categoryId,
    String amount = '10',
    String currencyCode = 'CNY',
    String? nativeAmount,
  }) => repo.addTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: amount,
    categoryId: categoryId,
    happenedAt: DateTime.utc(2026, 8, 24),
    currencyCode: currencyCode,
    nativeAmount: nativeAmount ?? amount,
  );

  /// 把交易标记为同步回放同款 tombstone，并返回固定删除时刻。
  Future<DateTime> tombstone(String id) async {
    final deletedAt = DateTime.utc(2026, 8, 25, 12);
    await (db.update(
      db.transactions,
    )..where((transaction) => transaction.id.equals(id))).write(
      TransactionsCompanion(
        updatedAt: d.Value(deletedAt),
        deletedAt: d.Value(deletedAt),
      ),
    );
    return deletedAt;
  }

  /// 读取包含 tombstone 的底层交易行，绕开业务活跃读模型。
  Future<Transaction?> rawTransaction(String id) => (db.select(
    db.transactions,
  )..where((transaction) => transaction.id.equals(id))).getSingleOrNull();

  /// 只返回交易实体的待推送变更。
  Future<List<SyncChange>> transactionChanges() async {
    final rows = await db.select(db.syncChanges).get();
    return rows.where((row) => row.entityType == 'transaction').toList();
  }

  test('清空账本只删除活跃交易，不重复处理或计数 tombstone', () async {
    final activeId = await addTransaction();
    final deletedId = await addTransaction(amount: '99');
    final deletedAt = await tombstone(deletedId);
    await db.delete(db.syncChanges).go();

    expect(await repo.clearLedgerTransactions(ledgerId), 1);

    expect(await rawTransaction(activeId), isNull);
    final deleted = await rawTransaction(deletedId);
    expect(deleted?.deletedAt?.isAtSameMomentAs(deletedAt), isTrue);
    final changes = await transactionChanges();
    expect(changes.map((row) => row.entityId), [activeId]);
    expect(changes.single.action, 'delete');
  });

  test('按分类删除只删除活跃交易，不重复处理或计数 tombstone', () async {
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final activeId = await addTransaction(categoryId: categoryId);
    final deletedId = await addTransaction(
      categoryId: categoryId,
      amount: '99',
    );
    final deletedAt = await tombstone(deletedId);
    await db.delete(db.syncChanges).go();

    expect(await repo.deleteTransactionsByCategoryIds([categoryId]), 1);

    expect(await rawTransaction(activeId), isNull);
    expect(
      (await rawTransaction(deletedId))?.deletedAt?.isAtSameMomentAs(deletedAt),
      isTrue,
    );
    final changes = await transactionChanges();
    expect(changes.map((row) => row.entityId), [activeId]);
    expect(changes.single.action, 'delete');
  });

  test('外币计数、未折算计数与币种集合统一排除 tombstone', () async {
    await addTransaction(amount: '14', currencyCode: 'USD', nativeAmount: '14');
    await addTransaction(
      amount: '1000',
      currencyCode: 'JPY',
      nativeAmount: '50',
    );
    final deletedId = await addTransaction(
      amount: '9',
      currencyCode: 'EUR',
      nativeAmount: '9',
    );
    await tombstone(deletedId);

    expect(await repo.countUnconvertedForeignTx(ledgerId), 1);
    expect(await repo.countForeignCurrencyTx(ledgerId), 2);
    expect(await repo.getLedgerForeignCurrencies(ledgerId), {'USD', 'JPY'});
    expect(await repo.getUsedCurrencies(), {'USD', 'JPY'});
  });

  test('外币重算只更新并登记活跃交易，tombstone 快照保持不变', () async {
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-08-24',
      rates: {'USD': '0.14'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 8, 24),
    );
    final activeId = await addTransaction(
      amount: '14',
      currencyCode: 'USD',
      nativeAmount: '14',
    );
    final deletedId = await addTransaction(
      amount: '28',
      currencyCode: 'USD',
      nativeAmount: '28',
    );
    final deletedAt = await tombstone(deletedId);
    await db.delete(db.syncChanges).go();

    expect(await repo.recomputeForeignTxForLedger(ledgerId), 1);

    expect((await rawTransaction(activeId))?.nativeAmount, isNot('14'));
    final deleted = await rawTransaction(deletedId);
    expect(deleted?.nativeAmount, '28');
    expect(deleted?.updatedAt.isAtSameMomentAs(deletedAt), isTrue);
    expect((await transactionChanges()).map((row) => row.entityId), [activeId]);
  });

  test('直属分类迁移只移动并登记活跃交易，tombstone 分类引用不变', () async {
    final sourceId = await repo.createCategory(name: '旧分类', kind: 'expense');
    final targetId = await repo.createCategory(name: '新分类', kind: 'expense');
    final activeId = await addTransaction(categoryId: sourceId);
    final deletedId = await addTransaction(categoryId: sourceId, amount: '99');
    await tombstone(deletedId);
    await db.delete(db.syncChanges).go();

    expect(
      await repo.migrateCategory(
        fromCategoryId: sourceId,
        toCategoryId: targetId,
      ),
      1,
    );

    expect((await rawTransaction(activeId))?.categoryId, targetId);
    expect((await rawTransaction(deletedId))?.categoryId, sourceId);
    expect((await transactionChanges()).map((row) => row.entityId), [activeId]);
  });

  test('分类树迁移只移动并登记活跃交易，tombstone 分类引用不变', () async {
    final sourceParent = await repo.createCategory(
      name: '旧一级',
      kind: 'expense',
    );
    final targetParent = await repo.createCategory(
      name: '新一级',
      kind: 'expense',
    );
    final sourceId = await repo.createSubCategory(
      parentId: sourceParent,
      name: '旧二级',
      kind: 'expense',
    );
    final targetId = await repo.createSubCategory(
      parentId: targetParent,
      name: '新二级',
      kind: 'expense',
    );
    final activeId = await addTransaction(categoryId: sourceId);
    final deletedId = await addTransaction(categoryId: sourceId, amount: '99');
    await tombstone(deletedId);
    await db.delete(db.syncChanges).go();

    final result = await repo.migrateCategoryTransactions(
      fromCategoryId: sourceId,
      toCategoryId: targetId,
    );

    expect(result.migratedTransactions, 1);
    expect((await rawTransaction(activeId))?.categoryId, targetId);
    expect((await rawTransaction(deletedId))?.categoryId, sourceId);
    expect((await transactionChanges()).map((row) => row.entityId), [activeId]);
  });
}
