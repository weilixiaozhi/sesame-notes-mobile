import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

import '../../helpers/test_isolation.dart';

/// 本地交易版本按实际提交递增，记账天数按当地日期统计。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('记账天数按当地日期计数，不因首笔时间较晚而少算一天', () async {
    resetGlobalTestState();
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      final repository = LocalRepository(db);
      final ledger = await repository.createLedger(
        name: '日历计数',
        storageMode: 'local',
      );
      final now = DateTime.now();
      await repository.addTransaction(
        ledgerId: ledger,
        type: 'expense',
        amount: '1',
        happenedAt: DateTime(now.year, now.month, now.day - 1, 23, 59, 59),
      );

      expect(
        (await repository.getCountsForLedger(ledgerId: ledger)).dayCount,
        2,
      );
    } finally {
      await db.close();
    }
  });

  test('同一交易的并发编辑按事务顺序递增版本', () async {
    resetGlobalTestState();
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      final repository = LocalRepository(db);
      final ledger = await repository.createLedger(name: '版本检查');
      final id = await repository.addTransaction(
        ledgerId: ledger,
        type: 'expense',
        amount: '1',
        happenedAt: DateTime.utc(2026, 10, 22),
      );

      final versions = await Future.wait([
        repository.updateTransaction(id: id, type: 'expense', amount: '2'),
        repository.updateTransaction(id: id, type: 'expense', amount: '3'),
      ]);

      expect(versions.toSet(), {2, 3});
      expect((await repository.getTransactionById(id))!.version, 3);
    } finally {
      await db.close();
    }
  });
}
