import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_isolation.dart';

/// 真实 SQLite 与 outbox 检查人工编辑毫秒，时钟注入只替代墙上时间。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late LocalRecurringTransactionRepository recurring;
  late String ledgerId;
  final instant = DateTime.utc(2024, 1, 1, 12, 0, 0, 456);
  final day = DateTime.utc(2024, 1, 1);

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final tracker = ChangeRecorderImpl(db, accountIdGetter: () => 'account');
    repo = LocalRepository(
      db,
      changeTracker: tracker,
      accountIdGetter: () => 'account',
    );
    recurring = LocalRecurringTransactionRepository(
      db,
      trackerGetter: () => tracker,
      clock: () => instant,
    );
    ledgerId = await repo.createLedger(name: '精确周期时钟', storageMode: 'cloud');
    await db.delete(db.syncChanges).go();
  });
  tearDown(() => db.close());

  Future<String> add({String? categoryId}) => recurring.addRecurringTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '10',
    categoryId: categoryId,
    frequency: 'daily',
    interval: 1,
    startDate: day,
  );

  Future<void> edit(String id, {String? targetLedger, String note = '人工编辑'}) =>
      recurring.updateRecurringTransaction(
        id: id,
        ledgerId: targetLedger ?? ledgerId,
        type: 'expense',
        amount: '20',
        frequency: 'daily',
        interval: 1,
        startDate: day,
        note: note,
      );

  Future<List<SyncChange>> pending(String id) =>
      (db.select(db.syncChanges)
            ..where(
              (row) =>
                  row.entityId.equals(id) & row.accountId.equals('account'),
            )
            ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
          .get();

  /// 编辑顺序读取唯一队列 UTC 毫秒时间，正文只保留实体快照。
  DateTime preciseTime(SyncChange row) => row.updatedAt.toUtc();

  test('新建规则在 SQLite 和待同步请求中保留同一毫秒时间', () async {
    final id = await add();
    final row = await (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(id))).getSingle();
    expect(row.updatedAt.toUtc(), instant);
    expect(preciseTime((await pending(id)).single), instant);
  });

  test('同一墙上毫秒连续编辑、启停、删除仅逐毫秒推进', () async {
    final id = await add();
    await edit(id);
    await edit(id, note: '第二次修改');
    await recurring.toggleRecurringTransaction(id, false);
    await recurring.deleteRecurringTransaction(id);
    final changes = await pending(id);
    expect(changes, hasLength(5));
    expect(changes.map(preciseTime).toList(), [
      for (var index = 0; index < 5; index++)
        instant.add(Duration(milliseconds: index)),
    ]);
    expect((jsonDecode(changes[3].payload) as Map)['enabled'], false);
    expect(changes.last.action, 'delete');
  });

  test('未知结果冻结请求的原精确时间参与比较且原字节不被改写', () async {
    final id = await add();
    final original = (await pending(id)).single;
    final frozenTime = instant.add(const Duration(milliseconds: 444));
    final frozen = jsonEncode({
      'mutation_id': original.mutationId,
      'entity_type': original.entityType,
      'entity_id': original.entityId,
      'ledger_id': original.ledgerId,
      'day_book_id': original.dayBookId,
      'memo_book_id': original.memoBookId,
      'fitness_space_id': original.fitnessSpaceId,
      'base_revision': original.baseRevision,
      'action': original.action,
      'updated_at': frozenTime.toIso8601String(),
      'payload': jsonDecode(original.payload),
    });
    await (db.update(
      db.syncChanges,
    )..where((row) => row.id.equals(original.id))).write(
      SyncChangesCompanion(
        updatedAt: d.Value(frozenTime),
        frozenRequest: d.Value(frozen),
      ),
    );
    final frozenOriginal = (await pending(id)).single;
    await edit(id);
    final changes = await pending(id);
    expect(changes, hasLength(2));
    expect(changes.first, frozenOriginal);
    expect(changes.first.frozenRequest, frozen);
    expect(changes.first.payload, original.payload);
    expect(changes.first.mutationId, original.mutationId);
    expect(changes.first.updatedAt, frozenTime);
    expect(
      preciseTime(changes.last),
      frozenTime.add(const Duration(milliseconds: 1)),
    );
  });

  test('另一账号同实体的未来 pending 不能抬高当前账号人工时钟', () async {
    final id = await add();
    final foreign = instant.add(const Duration(days: 1));
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'recurring_transaction',
            entityId: id,
            accountId: const d.Value('other-account'),
            ledgerId: d.Value(ledgerId),
            action: 'upsert',
            payload: jsonEncode({'updated_at': foreign.toIso8601String()}),
            updatedAt: foreign,
            mutationId: const Uuid().v4(),
          ),
        );
    await edit(id);
    expect(
      preciseTime((await pending(id)).last),
      instant.add(const Duration(milliseconds: 1)),
    );
  });

  test('清除活规则分类引用保留毫秒，删除规则不产生复活同步', () async {
    final category = await repo.createCategory(name: '历史分类', kind: 'expense');
    final active = await add(categoryId: category);
    final removed = await add(categoryId: category);
    await recurring.deleteRecurringTransaction(removed);
    final beforeRemoved = await pending(removed);
    await recurring.clearCategoryReferences([
      category,
    ], categoryScope: 'account');
    final activeChanges = await pending(active);
    expect(
      preciseTime(activeChanges.last),
      instant.add(const Duration(milliseconds: 1)),
    );
    expect(
      (jsonDecode(activeChanges.last.payload) as Map)['category_id'],
      null,
    );
    expect(await pending(removed), beforeRemoved);
  });

  test('未发生规则跨本移动的删除与新建同样携带精确人工时间', () async {
    final id = await add();
    final target = await repo.createLedger(name: '目标账本', storageMode: 'cloud');
    await edit(id, targetLedger: target);
    final sourceChanges = await pending(id);
    expect(sourceChanges.last.action, 'delete');
    expect(
      preciseTime(sourceChanges.last),
      instant.add(const Duration(milliseconds: 1)),
    );
    final moved = (await recurring.getRecurringTransactionsByLedger(
      target,
    )).single;
    expect(moved.id, isNot(id));
    expect(
      preciseTime((await pending(moved.id)).single),
      instant.add(const Duration(milliseconds: 1)),
    );
  });

  test('发生游标推进不改元数据时钟也不增加整条规则同步', () async {
    final id = await add();
    final before = (await pending(id)).single;
    final stored = (await recurring.getRecurringTransactionsByLedger(
      ledgerId,
    )).single.updatedAt;
    final txId = recurringOccurrenceId(ledgerId, id, '2024-01-01');
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: txId,
            ledgerId: ledgerId,
            txType: 'expense',
            amount: '10',
            currencyCode: 'CNY',
            nativeAmount: '10',
            happenedAt: day,
            recurringId: d.Value(id),
            occurrenceDate: const d.Value('2024-01-01'),
            createdAt: instant,
            updatedAt: instant,
          ),
        );
    await recurring.updateLastGeneratedDate(id, day);
    final updated = (await recurring.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    expect(updated.lastGeneratedDate?.toUtc(), day);
    expect(updated.updatedAt, stored);
    final after = (await pending(id)).single;
    expect(after.payload, before.payload);
    expect(after.mutationId, before.mutationId);
  });

  test('批量远端回填不使用人工时钟或登记反向变更', () async {
    final sourceTime = DateTime.utc(2020, 1, 1);
    const id = '10000000-0000-4000-8000-000000000001';
    await recurring.batchInsertRecurringTransactions([
      RecurringTransactionsCompanion.insert(
        id: id,
        ledgerId: ledgerId,
        txType: 'expense',
        amount: '2',
        currencyCode: 'CNY',
        frequency: 'daily',
        startDate: day,
        updatedAt: sourceTime,
      ),
    ], recordChanges: false);
    final row = (await recurring.getRecurringTransactionsByLedger(
      ledgerId,
    )).single;
    expect(row.updatedAt.toUtc(), sourceTime);
    expect(await pending(id), isEmpty);
  });
}
