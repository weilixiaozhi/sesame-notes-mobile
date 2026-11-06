import 'package:drift/native.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import '../../helpers/test_isolation.dart';

/// 使用真实 SQLite 验证分摊金额写入、替换、清空与批量读取。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
  });

  /// 为每项分摊业务创建独立账本，异常时记录诊断并关闭内存数据库。
  Future<void> withLedger(
    Future<void> Function(LocalRepository repo, String ledgerId) verify,
  ) async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      final repo = LocalRepository(db);
      final ledgerId = await repo.createLedger(
        name: '分摊业务',
        storageMode: 'local',
        localSelfId: 'self',
      );
      await verify(repo, ledgerId);
    } catch (error, stackTrace) {
      logger.error('TransactionSplitTest', '交易分摊持久化验证失败', error, stackTrace);
      rethrow;
    } finally {
      await db.close();
      await logger.clear();
    }
  }

  test('新增交易完整保存每位参与人的指定分摊金额', () async {
    await withLedger((repo, ledger) async {
      final id = await repo.addTransaction(
        ledgerId: ledger,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: const [
          TransactionSplitInput(memberId: 'u1', amount: '60.00'),
          TransactionSplitInput(memberId: 'v1', amount: '40.00'),
        ],
      );
      final rows = await repo.getTransactionSplits(id);
      expect(
        {for (final row in rows) row.memberId: Decimal.parse(row.amount)},
        {'u1': Decimal.parse('60'), 'v1': Decimal.parse('40')},
      );
    });
  });

  test('修改指定分摊时完整替换原参与人和金额', () async {
    await withLedger((repo, ledger) async {
      final id = await repo.addTransaction(
        ledgerId: ledger,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: const [
          TransactionSplitInput(memberId: 'u1', amount: '60.00'),
          TransactionSplitInput(memberId: 'v1', amount: '40.00'),
        ],
      );
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '200',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: const [TransactionSplitInput(memberId: 'u2', amount: '200.00')],
      );
      final rows = await repo.getTransactionSplits(id);
      expect(rows.single.memberId, 'u2');
      expect(Decimal.parse(rows.single.amount), Decimal.parse('200'));
    });
  });

  test('切换为人均分摊时清空原指定分摊关系', () async {
    await withLedger((repo, ledger) async {
      final id = await repo.addTransaction(
        ledgerId: ledger,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 2,
        splits: const [TransactionSplitInput(memberId: 'u1', amount: '100.00')],
      );
      await repo.updateTransaction(
        id: id,
        type: 'expense',
        amount: '100',
        happenedAt: DateTime(2026, 8, 8),
        aaMode: 0,
        splits: const [],
      );
      expect(await repo.getTransactionSplits(id), isEmpty);
      expect((await repo.getTransactionById(id))!.aaMode, 0);
    });
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
