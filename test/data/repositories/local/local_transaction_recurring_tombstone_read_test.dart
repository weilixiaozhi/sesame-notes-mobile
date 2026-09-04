import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late String categoryId;
  late String activeAaId;
  late String deletedAaId;
  late String activeExcludedId;
  late String deletedExcludedId;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(name: '活跃读模型账本');
    categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final happenedAt = DateTime(2026, 8, 21, 10);
    activeAaId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      categoryId: categoryId,
      happenedAt: happenedAt,
      aaMode: 0,
    );
    deletedAaId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '90',
      categoryId: categoryId,
      happenedAt: happenedAt,
      aaMode: 0,
    );
    activeExcludedId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '20',
      categoryId: categoryId,
      happenedAt: happenedAt,
      aaMode: 1,
    );
    deletedExcludedId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '80',
      categoryId: categoryId,
      happenedAt: happenedAt,
      aaMode: 1,
    );
    await _tombstoneTransactions(db, [deletedAaId, deletedExcludedId]);
  });

  tearDown(() async {
    await db.close();
  });

  /// 只保留列表中的交易 id，避免测试与排序实现耦合。
  Set<String> ids(Iterable<Transaction> rows) =>
      rows.map((row) => row.id).toSet();

  /// 只保留 join 读模型中的交易 id。
  Set<String> joinedIds(Iterable<({Transaction t, Category? category})> rows) =>
      rows.map((row) => row.t.id).toSet();

  test('首页与交易列表 watch 统一隐藏 transaction tombstone', () async {
    final expected = {activeAaId, activeExcludedId};

    expect(
      ids(await repo.watchRecentTransactions(ledgerId: ledgerId).first),
      expected,
    );
    expect(
      ids(
        await repo
            .watchTransactionsInMonth(
              ledgerId: ledgerId,
              month: DateTime(2026, 8),
            )
            .first,
      ),
      expected,
    );
    expect(
      joinedIds(
        await repo.watchTransactionsWithCategoryAll(ledgerId: ledgerId).first,
      ),
      expected,
    );
    expect(
      joinedIds(
        await repo
            .watchTransactionsWithCategoryInMonth(
              ledgerId: ledgerId,
              month: DateTime(2026, 8),
            )
            .first,
      ),
      expected,
    );
    expect(
      joinedIds(
        await repo
            .watchTransactionsWithCategoryInYear(ledgerId: ledgerId, year: 2026)
            .first,
      ),
      expected,
    );
  });

  test('统计、日历、分类、AA 与账本汇总交易查询统一隐藏 tombstone', () async {
    final expected = {activeAaId, activeExcludedId};
    final start = DateTime(2026, 8, 1);
    final end = DateTime(2026, 9, 1);

    expect(
      joinedIds(
        await repo
            .watchTransactionsForCategoryInRange(
              ledgerId: ledgerId,
              start: start,
              end: end,
              categoryId: categoryId,
              type: 'expense',
            )
            .first,
      ),
      expected,
    );
    expect(
      joinedIds(await repo.transactionsWithCategoryAll(ledgerId: ledgerId)),
      expected,
    );
    expect(
      joinedIds(
        await repo.getRecentTransactionsWithCategory(
          ledgerId: ledgerId,
          limit: 20,
        ),
      ),
      expected,
    );
    expect(
      await repo.countByTypeInRange(
        ledgerId: ledgerId,
        type: 'expense',
        start: start,
        end: end,
      ),
      2,
    );
    expect(ids(await repo.getTransactionsByLedger(ledgerId)), expected);
    expect(
      ids(
        await repo.getTransactionsByLedgerInRange(
          ledgerId: ledgerId,
          start: start,
          end: end,
        ),
      ),
      expected,
    );
    expect(ids(await repo.getAaTransactionsByLedger(ledgerId)), {activeAaId});
    expect(joinedIds(await repo.watchExcludedAaTransactions(ledgerId).first), {
      activeExcludedId,
    });
    expect(
      await repo.getDailyTotalsByMonth(
        ledgerId: ledgerId,
        month: DateTime(2026, 8),
      ),
      {'2026-08-21': 30.0},
    );
    expect(
      joinedIds(
        await repo.getTransactionsByDate(
          ledgerId: ledgerId,
          date: DateTime(2026, 8, 21),
        ),
      ),
      expected,
    );
  });

  test('业务单条读隐藏 tombstone', () async {
    expect(await repo.getTransactionById(deletedAaId), isNull);
  });

  test('周期模板 get/watch 列表统一隐藏 recurring tombstone', () async {
    final activeEnabledId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: DateTime(2026, 8, 21),
    );
    final activeDisabledId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '20',
      frequency: 'daily',
      interval: 1,
      startDate: DateTime(2026, 8, 21),
      enabled: false,
    );
    final deletedEnabledId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '90',
      frequency: 'daily',
      interval: 1,
      startDate: DateTime(2026, 8, 21),
    );
    await (db.update(
      db.recurringTransactions,
    )..where((row) => row.id.equals(deletedEnabledId))).write(
      RecurringTransactionsCompanion(
        deletedAt: d.Value(DateTime.utc(2026, 8, 22)),
      ),
    );
    final activeIds = {activeEnabledId, activeDisabledId};

    expect(
      (await repo.getAllRecurringTransactions()).map((row) => row.id).toSet(),
      activeIds,
    );
    expect(
      (await repo.getRecurringTransactionsByLedger(
        ledgerId,
      )).map((row) => row.id).toSet(),
      activeIds,
    );
    expect(
      (await repo.getEnabledRecurringTransactions(
        ledgerId,
      )).map((row) => row.id).toSet(),
      {activeEnabledId},
    );
    expect(
      (await repo.watchAllRecurringTransactions().first)
          .map((row) => row.id)
          .toSet(),
      activeIds,
    );
    expect(
      (await repo.watchRecurringTransactionsByLedger(ledgerId).first)
          .map((row) => row.id)
          .toSet(),
      activeIds,
    );
  });
}

/// 模拟 sync pull 落本地 tombstone，保留原始行供同步冲突与 revision 判定。
Future<void> _tombstoneTransactions(
  SesameDatabase db,
  Iterable<String> transactionIds,
) async {
  await (db.update(
    db.transactions,
  )..where((row) => row.id.isIn(transactionIds.toList()))).write(
    TransactionsCompanion(deletedAt: d.Value(DateTime.utc(2026, 8, 22))),
  );
}
