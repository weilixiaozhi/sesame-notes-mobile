import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  /// 创建测试账本并返回 UUID
  Future<String> seedLedger() {
    return repo.createLedger(name: '测试账本', monthStartDay: 1);
  }

  /// 收支统计:excludeFromStats=true 的交易应被排除;余额口径不动。
  test('totalsInRange 排除 excludeFromStats=true 的交易', () async {
    final lid = await seedLedger();
    // 正常支出 100
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: false,
    );
    // 不计入支出统计的支出 500
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '500.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: true,
    );

    // totalsInRange 只返回支出金额（double），不返回 (income, expense) 元组
    final expense = await repo.totalsInRange(
      ledgerId: lid,
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 7, 1),
    );

    // 只算入正常的 100,排除被标记的 500
    expect(expense, 100.0);
  });

  /// 反向断言:被排除的交易仍计入余额/净值口径。
  /// getLedgerStats 的 balance 是余额路径,不应被 excludeFromStats 过滤。
  test('getLedgerStats 余额仍包含 excludeFromStats=true 的交易', () async {
    final lid = await seedLedger();
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: false,
    );
    await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '500.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: true,
    );

    final stats = await repo.getLedgerStats(ledgerId: lid);

    // 支出总额 = 100 + 500 = 600,被排除的 500 仍计入支出
    expect(stats.expenseTotal, 600.0);
    expect(stats.transactionCount, 2);
  });
}
