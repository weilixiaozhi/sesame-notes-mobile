import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';

import '../../helpers/test_isolation.dart';

/// 在真实落账后注入模板变更，核验后续补记是否遵守最新业务状态。
class _ChangingRepository extends LocalRepository {
  /// 使用内存数据库隔离账本和模板，保持完整事务实现。
  _ChangingRepository(super.db);

  Future<void> Function(String ruleId)? afterOccurrence;

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

/// 验证补记返回完整明细，并在模板变更后停止原账本的后续落账。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late _ChangingRepository repository;
  late String ledgerId;

  setUp(() async {
    resetGlobalTestState();
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _ChangingRepository(database);
    ledgerId = await repository.createLedger(
      name: '周期补记',
      storageMode: 'local',
    );
  });
  tearDown(() => database.close());

  /// 固定历史三天排期，不受运行日期与本机时区影响。
  Future<String> addRule() async {
    try {
      return await repository.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8.25',
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 3),
        timeZone: 'UTC',
      );
    } catch (error, stackTrace) {
      printOnFailure('创建周期补记模板失败：$error\n$stackTrace');
      rethrow;
    }
  }

  test('显式补记返回每笔生成的交易', () async {
    try {
      await addRule();
      final rows = await RecurringTransactionService(
        repository,
      ).generatePendingTransactions();
      expect(rows, hasLength(3));
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
