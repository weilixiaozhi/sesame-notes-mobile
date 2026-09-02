/// 账本列表批量统计接口（getAllLedgerStats）单元测试。
///
/// 锁定行为：
/// - 单条聚合 SQL 一次返回全部账本的 COUNT + SUM，与逐本 getLedgerStats 口径一致；
/// - 金额按 COALESCE(native_amount, amount) 折本位币，输出单位统一为"元"；
/// - 没有交易的账本不出现在返回 Map 中（调用方按 0/0 兜底）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  test('批量统计：多账本一次返回，金额折 nativeAmount 并转元', () async {
    // 账本 1：外币 $12(≈86.4) + 本位币 ¥100，共 2 笔 → 186.4 元
    final l1 = await repo.createLedger(name: 'A', currency: 'CNY');
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '12.00',
      happenedAt: DateTime(2026, 7, 5),
      currencyCode: 'USD',
      nativeAmount: '86.4',
    );
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 7, 6),
    );

    // 账本 2：3 笔，合计 80 元
    final l2 = await repo.createLedger(name: 'B', currency: 'CNY');
    await repo.addTransaction(
      ledgerId: l2,
      type: 'expense',
      amount: '30.00',
      happenedAt: DateTime(2026, 7, 5),
    );
    await repo.addTransaction(
      ledgerId: l2,
      type: 'expense',
      amount: '50.00',
      happenedAt: DateTime(2026, 7, 6),
    );
    await repo.addTransaction(
      ledgerId: l2,
      type: 'expense',
      amount: '0',
      happenedAt: DateTime(2026, 7, 7),
    );

    // 账本 3：无交易，不应出现在批量结果中
    final l3 = await repo.createLedger(name: 'C', currency: 'CNY');

    final stats = await repo.getAllLedgerStats();

    expect(stats.keys, containsAll([l1, l2]));
    expect(stats.containsKey(l3), isFalse, reason: '无交易账本不占位，调用方按 0/0 兜底');
    expect(
      stats[l1]!.expenseTotal,
      closeTo(186.4, 1e-9),
      reason: '批量口径与 getLedgerStats 一致：折 nativeAmount 后转元',
    );
    expect(stats[l1]!.transactionCount, 2);
    expect(stats[l2]!.expenseTotal, 80.0);
    expect(stats[l2]!.transactionCount, 3);
  });

  test('批量统计与逐本 getLedgerStats 结果一致（回归锁）', () async {
    final l1 = await repo.createLedger(name: 'A', currency: 'CNY');
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '12.34',
      happenedAt: DateTime(2026, 7, 5),
    );
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '87.66',
      happenedAt: DateTime(2026, 7, 6),
    );

    final batch = await repo.getAllLedgerStats();
    final single = await repo.getLedgerStats(ledgerId: l1);

    expect(batch[l1]!.expenseTotal, single.expenseTotal);
    expect(batch[l1]!.transactionCount, single.transactionCount);
  });
}
