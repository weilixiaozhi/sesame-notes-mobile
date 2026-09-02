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

  test('addTransaction 写入 excludeFromStats', () async {
    final lid = await seedLedger();
    final id = await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: true,
    );

    final tx = await repo.getTransactionById(id);
    expect(tx, isNotNull);
    expect(tx!.excludeFromStats, true);
  });

  // excludeFromBudget 字段已移除，无对应测试
  test('updateTransaction 仅传 excludeFromStats 不会清空 amount', () async {
    final lid = await seedLedger();
    final id = await repo.addTransaction(
      ledgerId: lid,
      type: 'expense',
      amount: '100.00',
      happenedAt: DateTime(2026, 6, 18),
      excludeFromStats: true,
    );

    await repo.updateTransaction(id: id, type: 'expense', amount: '200.00');

    final tx = await repo.getTransactionById(id);
    expect(tx, isNotNull);
    // excludeFromStats 未传 (null) → 应保持原值 true,不被清空
    expect(tx!.excludeFromStats, true);
    expect(tx.amount, '200.00');
  });
}
