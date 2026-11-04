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
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async => db.close());

  test('批量统计：多账本一次返回，金额折 nativeAmount 并转元', () async {
    // 账本 1：外币 $12(≈86.4) + 本位币 ¥100，共 2 笔 → 186.4 元
    final l1 = await repo.createLedger(
      storageMode: 'cloud',
      name: 'A',
      currency: 'CNY',
    );
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
    final l2 = await repo.createLedger(
      storageMode: 'cloud',
      name: 'B',
      currency: 'CNY',
    );
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
    final l3 = await repo.createLedger(
      storageMode: 'cloud',
      name: 'C',
      currency: 'CNY',
    );

    final stats = await repo.getLedgerListStats({l1, l2, l3});

    expect(stats.keys, containsAll([l1, l2]));
    expect(stats.containsKey(l3), isFalse, reason: '无交易账本不占位，调用方按 0/0 兜底');
    expect(
      stats[l1]!.expenseTotal,
      closeTo(186.4, 1e-9),
      reason: '账本列表累计本位币折算金额',
    );
    expect(stats[l1]!.transactionCount, 2);
    expect(stats[l2]!.expenseTotal, 80.0);
    expect(stats[l2]!.transactionCount, 3);
  });

  test('账本列表只聚合所选账本，Decimal 累加与换币计数保留口径', () async {
    final l1 = await repo.createLedger(
      storageMode: 'cloud',
      name: 'A',
      currency: 'CNY',
    );
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '0.1',
      happenedAt: DateTime(2026, 7, 5),
    );
    await repo.addTransaction(
      ledgerId: l1,
      type: 'expense',
      amount: '0.2',
      happenedAt: DateTime(2026, 7, 6),
    );
    final l2 = await repo.createLedger(storageMode: 'local', name: '其他账本');
    await repo.addTransaction(
      ledgerId: l2,
      type: 'expense',
      amount: '1000',
      happenedAt: DateTime(2026, 7, 5),
    );

    final batch = await repo.getLedgerListStats({l1});
    expect(batch, {l1: (expenseTotal: 0.3, transactionCount: 2)});
    expect(await repo.countLedgerTransactions(l1), 2);
  });
}
