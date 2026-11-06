import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';

import '../../helpers/test_isolation.dart';

/// 统计生产仓储的查询入口，实际排期和发生写入仍由数据库完成。
class _CountingRepository extends LocalRepository {
  /// 使用内存数据库隔离账本和模板，保持完整事务实现。
  _CountingRepository(super.db);

  int directoryReads = 0;
  int directoryRows = 0;
  int ruleReads = 0;
  int transactionReads = 0;
  Future<void> Function(String ruleId)? afterOccurrence;

  /// 每次读取整个账本目录均计入，确保补记笔数不会放大目录查询。
  @override
  Future<List<RecurringTransaction>> getRecurringTransactionsByLedger(
    String ledgerId,
  ) async {
    try {
      directoryReads++;
      final rows = await super.getRecurringTransactionsByLedger(ledgerId);
      directoryRows += rows.length;
      return rows;
    } catch (error, stackTrace) {
      printOnFailure('周期目录读取失败：$error\n$stackTrace');
      rethrow;
    }
  }

  /// 连续发生只回读对应模板，所属账本和删除状态由真实查询核验。
  @override
  Future<RecurringTransaction?> getRecurringTransactionById(
    String id, {
    required String ledgerId,
  }) async {
    try {
      ruleReads++;
      return await super.getRecurringTransactionById(id, ledgerId: ledgerId);
    } catch (error, stackTrace) {
      printOnFailure('单模板回读失败：$error\n$stackTrace');
      rethrow;
    }
  }

  /// 后台入口只需要账本集合，显式入口才读取返回交易明细。
  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      transactionReads++;
      return await super.getTransactionById(id);
    } catch (error, stackTrace) {
      printOnFailure('交易明细回读失败：$error\n$stackTrace');
      rethrow;
    }
  }

  /// 在已提交的发生与下一次模板回读之间模拟用户操作。
  @override
  Future<String> generateRecurringTransaction({
    required RecurringTransactionSnapshot recurring,
    required DateTime happenedAt,
  }) async {
    try {
      final id = await super.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: happenedAt,
      );
      final change = afterOccurrence;
      afterOccurrence = null;
      await change?.call(recurring.id);
      return id;
    } catch (error, stackTrace) {
      printOnFailure('受控周期发生失败：$error\n$stackTrace');
      rethrow;
    }
  }
}

/// 验证读放大被消除，同时保留明细返回和模板变更后的停止语义。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late _CountingRepository repository;
  late String ledgerId;

  setUp(() async {
    resetGlobalTestState();
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _CountingRepository(database);
    ledgerId = await repository.createLedger(
      name: '周期补记',
      storageMode: 'local',
    );
  });
  tearDown(() => database.close());

  /// 固定历史三天排期，不受运行日期与本机时区影响。
  Future<String> addRule({bool enabled = true}) =>
      repository.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8.25',
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 3),
        timeZone: 'UTC',
        enabled: enabled,
      );

  test('后台补记仅扫描一次模板目录，不回读无用的交易快照', () async {
    try {
      for (var i = 0; i < 20; i++) {
        await addRule(enabled: false);
      }
      final active = await addRule();
      final changed =
          await RecurringTransactionService.generatePendingTransactionsStatic(
            repository: repository,
          );
      expect(changed, {ledgerId});
      expect(repository.directoryReads, 1);
      expect(repository.directoryRows, 21);
      expect(repository.ruleReads, 3);
      expect(repository.transactionReads, 0);
      final rows = await database.select(database.transactions).get();
      expect(rows, hasLength(3));
      expect(rows.every((row) => row.recurringId == active), isTrue);
      expect(
        await RecurringTransactionService.generatePendingTransactionsStatic(
          repository: repository,
        ),
        isEmpty,
      );
      expect(await database.select(database.transactions).get(), hasLength(3));
    } catch (error, stackTrace) {
      printOnFailure('周期后台查询数量回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('显式补记仍返回每笔交易，只回读对应模板进度', () async {
    try {
      await addRule();
      final rows = await RecurringTransactionService(
        repository,
      ).generatePendingTransactions();
      expect(rows, hasLength(3));
      expect(repository.directoryReads, 1);
      expect(repository.ruleReads, 3);
      expect(repository.transactionReads, 3);
    } catch (error, stackTrace) {
      printOnFailure('周期明细返回回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  for (final operation in ['disabled', 'deleted', 'moved']) {
    test('发生提交后模板$operation时停止原账本的后续补记', () async {
      try {
        final id = await addRule();
        final other = await repository.createLedger(
          name: '其他账本',
          storageMode: 'local',
        );
        expect(
          await repository.getRecurringTransactionById(id, ledgerId: other),
          isNull,
        );
        repository.afterOccurrence = (ruleId) async {
          await (database.update(
            database.recurringTransactions,
          )..where((row) => row.id.equals(ruleId))).write(switch (operation) {
            'disabled' => const RecurringTransactionsCompanion(
              enabled: Value(false),
            ),
            'deleted' => RecurringTransactionsCompanion(
              deletedAt: Value(DateTime.utc(2026)),
            ),
            _ => RecurringTransactionsCompanion(ledgerId: Value(other)),
          });
        };
        final ledger = (await repository.getLedgerById(ledgerId))!;
        final changed =
            await RecurringTransactionService.generatePendingTransactionsStatic(
              repository: repository,
              ledgers: [ledger],
            );
        expect(changed, {ledgerId});
        expect(
          await database.select(database.transactions).get(),
          hasLength(1),
        );
      } catch (error, stackTrace) {
        printOnFailure('周期模板变更停止回归失败：$error\n$stackTrace');
        rethrow;
      }
    });
  }
}
