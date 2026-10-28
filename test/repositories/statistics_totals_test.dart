import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 创建测试账本并返回 UUID
  Future<String> seedLedger() {
    return repo.createLedger(name: '测试账本', monthStartDay: 1);
  }

  test('区间统计覆盖全部交易并遵守日期、账本、删除边界', () async {
    final lid = await seedLedger();
    final start = DateTime(2026, 6);
    final end = DateTime(2026, 7);
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '500',
      happenedAt: DateTime(2026, 6, 18),
    );

    // 一笔支出即形成有效区间统计。
    expect(
      await repo.countByTypeInRange(
        ledgerId: lid,
        type: 'expense',
        start: start,
        end: end,
      ),
      1,
    );
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100',
      happenedAt: start,
    );
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '200',
      happenedAt: end,
    );
    final deleted = await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '300',
      happenedAt: DateTime(2026, 6, 20),
    );
    await (db.update(
      db.transactions,
    )..where((row) => row.id.equals(deleted))).write(
      TransactionsCompanion(deletedAt: d.Value(DateTime.utc(2026, 6, 21))),
    );
    final otherLedger = await seedLedger();
    await repo.addTransaction(
      ledgerId: otherLedger,
      type: 'expense',
      amount: '400',
      happenedAt: start,
    );

    expect(
      await repo.countByTypeInRange(
        ledgerId: lid,
        type: 'expense',
        start: start,
        end: end,
      ),
      2,
    );
    final ledgerStats = await repo.getLedgerStats(ledgerId: lid);
    expect(ledgerStats.transactionCount, 3);
    expect(ledgerStats.expenseTotal, 800);
  });

  test('账本总览与区间统计采用一致支出总额', () async {
    final lid = await seedLedger();
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 6, 18),
    );
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '500.00',
      happenedAt: DateTime(2026, 6, 18),
    );

    final stats = await repo.getLedgerStats(ledgerId: lid);

    // 账本总览覆盖全部未删除交易。
    expect(stats.expenseTotal, 600.0);
    expect(stats.transactionCount, 2);
    expect(
      await repo.totalsInRange(
        ledgerId: lid,
        start: DateTime(2026, 6, 1),
        end: DateTime(2026, 7, 1),
      ),
      600.0,
    );
  });
}
