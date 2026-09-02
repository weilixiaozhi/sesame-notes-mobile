import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';

import '../../helpers/test_isolation.dart';

class _ThrowingChangeRecorder implements ChangeRecorder {
  Never _fail() => throw StateError('同步变更登记失败');

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async => _fail();

  @override
  Future<void> recordLedgerChanges({
    required List<SyncChangeRecord> changes,
  }) async => _fail();

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async => _fail();

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) async => _fail();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String cloudLedgerId;
  late String localLedgerId;

  setUp(() {
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    cloudLedgerId = await repo.createLedger(name: '云账本', storageMode: 'cloud');
    localLedgerId = await repo.createLedger(name: '本地账本', storageMode: 'local');
  });

  tearDown(() async {
    await db.close();
  });

  /// 清除准备数据产生的同步队列，保证断言只观察当前操作。
  Future<void> resetChanges() => db.delete(db.syncChanges).go();

  /// 返回指定实体类型的待同步变更。
  Future<List<SyncChange>> changesOf(String entityType) async {
    final rows = await db.select(db.syncChanges).get();
    return rows.where((row) => row.entityType == entityType).toList();
  }

  /// 创建测试交易；云交易模拟已同步 revision，删除应按 UPDATE/DELETE 语义登记。
  Future<String> addTransaction({
    required String ledgerId,
    required String categoryId,
    required String amount,
  }) async {
    final id = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: amount,
      categoryId: categoryId,
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    if (ledgerId == cloudLedgerId) {
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        const TransactionsCompanion(serverRevision: d.Value(7)),
      );
    }
    return id;
  }

  test('按分类批量删除：只为云账本逐笔登记 transaction delete', () async {
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final cloudA = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '10',
    );
    final cloudB = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '20',
    );
    final local = await addTransaction(
      ledgerId: localLedgerId,
      categoryId: categoryId,
      amount: '30',
    );
    await resetChanges();

    expect(await repo.deleteTransactionsByCategoryIds([categoryId]), 3);

    expect(await db.select(db.transactions).get(), isEmpty);
    final changes = await changesOf('transaction');
    expect(changes.map((row) => row.entityId).toSet(), {cloudA, cloudB});
    expect(changes.every((row) => row.action == 'delete'), isTrue);
    expect(changes.every((row) => row.ledgerId == cloudLedgerId), isTrue);
    expect(changes.every((row) => row.baseRevision == 7), isTrue);
    expect(changes.any((row) => row.entityId == local), isFalse);
  });

  test('分类迁移：只为实际改分类的云交易登记最新 upsert 快照', () async {
    final source = await repo.createCategory(name: '旧分类', kind: 'expense');
    final sourceChild = await repo.createSubCategory(
      parentId: source,
      name: '早餐',
      kind: 'expense',
    );
    final untouchedChild = await repo.createSubCategory(
      parentId: source,
      name: '午餐',
      kind: 'expense',
    );
    final target = await repo.createCategory(name: '新分类', kind: 'expense');
    final targetChild = await repo.createSubCategory(
      parentId: target,
      name: '早餐',
      kind: 'expense',
    );

    final cloudDirect = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: source,
      amount: '10',
    );
    final cloudMergedChild = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: sourceChild,
      amount: '20',
    );
    final cloudUnchangedChild = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: untouchedChild,
      amount: '30',
    );
    final localDirect = await addTransaction(
      ledgerId: localLedgerId,
      categoryId: source,
      amount: '40',
    );
    await resetChanges();

    final result = await repo.migrateCategoryTransactions(
      fromCategoryId: source,
      toCategoryId: target,
    );

    expect(result.migratedTransactions, 3);
    final rows = {
      for (final row in await db.select(db.transactions).get()) row.id: row,
    };
    expect(rows[cloudDirect]?.categoryId, target);
    expect(rows[cloudMergedChild]?.categoryId, targetChild);
    expect(rows[cloudUnchangedChild]?.categoryId, untouchedChild);
    expect(rows[localDirect]?.categoryId, target);

    final changes = await changesOf('transaction');
    expect(changes.map((row) => row.entityId).toSet(), {
      cloudDirect,
      cloudMergedChild,
    });
    expect(changes.every((row) => row.action == 'upsert'), isTrue);
    expect(changes.any((row) => row.entityId == cloudUnchangedChild), isFalse);
    expect(changes.any((row) => row.entityId == localDirect), isFalse);
    final categories = {
      for (final row in changes)
        row.entityId:
            (jsonDecode(row.payload) as Map<String, dynamic>)['category_id'],
    };
    expect(categories, {cloudDirect: target, cloudMergedChild: targetChild});
  });

  test('分类批量删除登记失败时，整批交易删除原子回滚', () async {
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final first = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '10',
    );
    final second = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '20',
    );
    await resetChanges();
    repo.changeTracker = _ThrowingChangeRecorder();

    await expectLater(
      repo.deleteTransactionsByCategoryIds([categoryId]),
      throwsA(isA<StateError>()),
    );

    expect(
      (await db.select(db.transactions).get()).map((row) => row.id).toSet(),
      {first, second},
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('清空账本：云账本登记逐笔 delete，本地账本不进入同步队列', () async {
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final cloudA = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '10',
    );
    final cloudB = await addTransaction(
      ledgerId: cloudLedgerId,
      categoryId: categoryId,
      amount: '20',
    );
    await addTransaction(
      ledgerId: localLedgerId,
      categoryId: categoryId,
      amount: '30',
    );
    await resetChanges();

    expect(await repo.clearLedgerTransactions(cloudLedgerId), 2);
    expect(await repo.clearLedgerTransactions(localLedgerId), 1);

    final changes = await changesOf('transaction');
    expect(changes.map((row) => row.entityId).toSet(), {cloudA, cloudB});
    expect(changes.every((row) => row.action == 'delete'), isTrue);
    expect(changes.every((row) => row.ledgerId == cloudLedgerId), isTrue);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('删除已绑定云账本：保留同步身份 tombstone，并只登记最终 ledger delete', () async {
    const boundLedgerId = 'ledger-bound';
    await repo.createBoundLedger(
      id: boundLedgerId,
      name: '已绑定云账本',
      syncId: 'sync-bound',
    );
    await repo.addTransaction(
      ledgerId: boundLedgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 24),
    );
    await resetChanges();

    await repo.deleteLedger(boundLedgerId);

    final row = await (db.select(
      db.ledgers,
    )..where((ledger) => ledger.id.equals(boundLedgerId))).getSingle();
    expect(row.deletedAt, isNotNull, reason: '云账本必须保留 tombstone，避免 pull 复活');
    expect(row.syncId, 'sync-bound', reason: 'push ledger delete 仍需携带同步身份');

    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(1));
    expect(changes.single.entityType, 'ledger');
    expect(changes.single.entityId, boundLedgerId);
    expect(changes.single.ledgerId, boundLedgerId);
    expect(changes.single.action, 'delete');
    final payload = jsonDecode(changes.single.payload) as Map<String, dynamic>;
    expect(payload['deleted_at'], isNotNull);
  });

  test('删除本地账本：物理删除且不登记任何云变更', () async {
    await resetChanges();

    await repo.deleteLedger(localLedgerId);

    final row = await (db.select(
      db.ledgers,
    )..where((ledger) => ledger.id.equals(localLedgerId))).getSingleOrNull();
    expect(row, isNull);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
}
