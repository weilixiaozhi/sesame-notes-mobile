import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import '../../helpers/test_isolation.dart';

/// 使用真实 SQLite 验证大批次、重复标识、空输入与结果分组。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
  });
  test('超过千个交易标识仍能分批读取，不重复或混入未请求交易', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(db);
    try {
      final ledger = await repo.createLedger(
        name: '批量读取',
        storageMode: 'local',
        localSelfId: 'self',
      );
      final now = DateTime(2026);
      await db.batch((batch) {
        batch.insertAll(db.transactions, [
          for (var i = 0; i < 1002; i++)
            TransactionsCompanion.insert(
              id: 'tx-$i',
              ledgerId: ledger,
              txType: 'expense',
              amount: '1',
              currencyCode: 'CNY',
              nativeAmount: '1',
              happenedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
        ]);
        batch.insertAll(db.transactionSplits, [
          for (var i = 0; i < 1002; i++)
            TransactionSplitsCompanion.insert(
              transactionId: 'tx-$i',
              memberId: 'member',
              amount: '1',
            ),
        ]);
      });
      final rows = await repo.getTransactionSplitsByTransactionIds([
        for (var i = 0; i < 1001; i++) 'tx-$i',
        'tx-0',
        'missing',
      ]);
      expect(rows, hasLength(1001));
      expect(rows.containsKey('tx-1001'), isFalse);
      expect(rows.containsKey('missing'), isFalse);
      for (final entry in rows.entries) {
        expect(entry.value, hasLength(1));
        expect(entry.value.single.transactionId, entry.key);
        expect(entry.value.single.amount, '1');
      }
      expect(await repo.getTransactionSplitsByTransactionIds([]), isEmpty);
    } finally {
      await db.close();
      await logger.clear();
    }
  });
}
