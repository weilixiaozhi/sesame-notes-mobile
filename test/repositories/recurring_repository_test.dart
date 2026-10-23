import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';

/// 验证周期账单的持久化、启停、生成游标和批量导入。
void main() {
  late SesameDatabase db;
  late LocalRecurringTransactionRepository recurring;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    recurring = LocalRecurringTransactionRepository(db);
  });

  tearDown(() async => db.close());

  // UUID 主键表 insert 要求调用方提供 id，用自增序号生成确定性的测试 id。
  var seq = 0;

  /// 创建账本并返回 UUID
  Future<String> seedLedger(String name) async {
    final now = DateTime.now().toUtc();
    final id = 'led-${seq++}';
    await db
        .into(db.ledgers)
        .insert(LedgersCompanion.insert(id: id, name: name, updatedAt: now));
    return id;
  }

  group('周期账单 repository', () {
    test('增删改查 / 启停 / 已生成日期 / watch', () async {
      final lid = await seedLedger('周期账本');

      final id = await recurring.addRecurringTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        frequency: 'monthly',
        interval: 1,
        dayOfMonth: 15,
        startDate: DateTime(2026, 1, 1),
      );

      var list = await recurring.getRecurringTransactionsByLedger(lid);
      expect(list, hasLength(1));
      expect(list.first.amount, '50.00');
      expect(list.first.enabled, isTrue);

      // 编辑金额与起始日；lastGeneratedDate 保留
      await recurring.updateRecurringTransaction(
        id: id,
        ledgerId: lid,
        type: 'expense',
        amount: '60.00',
        frequency: 'monthly',
        interval: 1,
        dayOfMonth: 20,
        startDate: DateTime(2026, 2, 1),
      );
      list = await recurring.getRecurringTransactionsByLedger(lid);
      expect(list.first.amount, '60.00');
      expect(list.first.dayOfMonth, 20);

      // 游标只能由真实连续发生推进，仓储不能任意前推到没有交易的日期。
      await expectLater(
        recurring.updateLastGeneratedDate(id, DateTime(2026, 6, 15)),
        throwsStateError,
      );
      list = await recurring.getRecurringTransactionsByLedger(lid);
      expect(list.first.lastGeneratedDate, isNull);

      // 停用模板仍可读取，但不能进入启用规则集合。
      await recurring.toggleRecurringTransaction(id, false);
      final enabled = (await recurring.getAllRecurringTransactions()).where(
        (row) => row.ledgerId == lid && row.enabled,
      );
      expect(enabled, isEmpty);
      list = await recurring.getRecurringTransactionsByLedger(lid);
      expect(list.first.enabled, isFalse);

      // watch 流收到更新
      final events = <int>[];
      final sub = recurring.watchAllRecurringTransactions().listen(
        (rows) => events.add(rows.where((row) => row.ledgerId == lid).length),
      );
      await pumpEventQueue();
      await recurring.deleteRecurringTransaction(id);
      await pumpEventQueue();
      expect(events, isNotEmpty);
      expect(events.last, 0);
      await sub.cancel();
    });

    test('batchInsert 批量导入 + watchAll', () async {
      final lid = await seedLedger('批量账本');
      final now = DateTime.now().toUtc();
      await recurring.batchInsertRecurringTransactions([
        RecurringTransactionsCompanion.insert(
          id: 'rec-1',
          ledgerId: lid,
          txType: 'expense',
          amount: '10.00',
          currencyCode: 'CNY',
          frequency: 'weekly',
          interval: const Value(1),
          startDate: DateTime(2026, 1, 1),
          updatedAt: now,
        ),
        RecurringTransactionsCompanion.insert(
          id: 'rec-2',
          ledgerId: lid,
          txType: 'expense',
          amount: '20.00',
          currencyCode: 'CNY',
          frequency: 'weekly',
          interval: const Value(2),
          startDate: DateTime(2026, 1, 1),
          updatedAt: now,
        ),
      ]);
      final all = await recurring.getAllRecurringTransactions();
      expect(all, hasLength(2));
      expect(all.map((r) => r.amount), containsAll(['10.00', '20.00']));

      final watched = await recurring.watchAllRecurringTransactions().first;
      expect(watched, hasLength(2));
    });
  });
}
