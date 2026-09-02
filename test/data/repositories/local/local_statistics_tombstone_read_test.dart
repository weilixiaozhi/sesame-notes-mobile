/// 统计读模型 tombstone 契约测试。
///
/// 云端删除会保留带 deleted_at 的本地行用于同步修订链；所有用户可见统计
/// 必须只聚合活跃交易，不能让已删除账单重新出现在首页、统计或日历。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('全部统计查询统一忽略 transaction tombstone', () async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LocalRepository(db);
    final now = DateTime.now();
    final ledgerId = await repo.createLedger(
      name: '统计账本',
      storageMode: 'local',
    );
    final transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '99.99',
      happenedAt: now,
    );
    await (db.update(db.transactions)
          ..where((row) => row.id.equals(transactionId)))
        .write(TransactionsCompanion(deletedAt: d.Value(now.toUtc())));
    final start = DateTime(now.year - 1, 1, 1);
    final end = DateTime(now.year + 1, 1, 1);

    expect(
      await repo.totalsByCategory(
        ledgerId: ledgerId,
        type: 'expense',
        start: start,
        end: end,
      ),
      isEmpty,
    );
    expect(
      await repo.totalsByCategoryWithHierarchy(
        ledgerId: ledgerId,
        type: 'expense',
        start: start,
        end: end,
      ),
      isEmpty,
    );
    expect(
      (await repo.totalsByDay(
        ledgerId: ledgerId,
        type: 'expense',
        start: start,
        end: end,
      )).every((item) => item.total == 0),
      isTrue,
    );
    expect(
      (await repo.totalsByMonth(
        ledgerId: ledgerId,
        type: 'expense',
        year: now.year,
      )).every((item) => item.total == 0),
      isTrue,
    );
    expect(
      await repo.totalsByYearSeries(ledgerId: ledgerId, type: 'expense'),
      isEmpty,
    );
    expect(await repo.earliestExpenseDate(ledgerId: ledgerId), isNull);
    expect(await repo.latestExpenseDate(ledgerId: ledgerId), isNull);
    expect(await repo.hasAnyExpenseTx(ledgerId: ledgerId), isFalse);
    expect(
      await repo.totalsInRange(ledgerId: ledgerId, start: start, end: end),
      0,
    );
    expect(
      await repo.monthlyTotals(
        ledgerId: ledgerId,
        month: DateTime(now.year, now.month, 1),
      ),
      0,
    );
    expect(await repo.todayExpense(ledgerId: ledgerId, now: now), 0);
    expect(await repo.weekExpense(ledgerId: ledgerId, now: now), 0);
    expect(await repo.yearlyTotals(ledgerId: ledgerId, year: now.year), 0);
  });

  test('分类 tombstone 不在统计中复活，关联交易归入未分类', () async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = LocalRepository(db);
    final now = DateTime.utc(2026, 8, 24);
    final ledgerId = await repo.createLedger(
      name: '分类删除账本',
      storageMode: 'local',
    );
    final categoryId = await repo.createCategory(
      name: '已删除分类',
      kind: 'expense',
    );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: ledgerId,
            categoryId: categoryId,
            name: '遗留共享镜像',
            kind: 'expense',
            updatedAt: now,
          ),
        );
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      categoryId: categoryId,
      happenedAt: now,
    );
    await (db.update(db.categories)..where((row) => row.id.equals(categoryId)))
        .write(CategoriesCompanion(deletedAt: d.Value(now)));

    final rows = await repo.totalsByCategory(
      ledgerId: ledgerId,
      type: 'expense',
      start: now.subtract(const Duration(days: 1)),
      end: now.add(const Duration(days: 1)),
    );
    final hierarchy = await repo.totalsByCategoryWithHierarchy(
      ledgerId: ledgerId,
      type: 'expense',
      start: now.subtract(const Duration(days: 1)),
      end: now.add(const Duration(days: 1)),
    );

    expect(rows.single, (id: null, name: '未分类', icon: null, total: 10.0));
    expect(hierarchy.single.id, isNull);
    expect(hierarchy.single.name, '未分类');
    expect(hierarchy.single.total, 10);
  });
}
