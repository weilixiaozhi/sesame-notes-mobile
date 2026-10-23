import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  final day = DateTime.utc(2024, 3, 10);
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(
      name: '周期原子性测试',
      currency: 'CNY',
      storageMode: 'local',
    );
  });
  tearDown(() => db.close());
  Future<RecurringTransaction> add() async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: day,
      endDate: day,
      timeZone: 'America/New_York',
    );
    return (db.select(
      db.recurringTransactions,
    )..where((row) => row.id.equals(id))).getSingle();
  }

  test('同一发生并发只落一笔，并保留时区日界/来源/付款人', () async {
    final rule = await add();
    final ids = await Future.wait([
      for (var i = 0; i < 2; i++)
        repo.generateRecurringTransaction(recurring: rule, happenedAt: day),
    ]);
    expect(ids.toSet(), hasLength(1));
    final row = (await db.select(db.transactions).get()).single;
    expect(row.id, recurringOccurrenceId(ledgerId, rule.id, '2024-03-10'));
    expect(row.occurrenceDate, '2024-03-10');
    expect(row.recurringId, rule.id);
    expect(row.happenedAt.toUtc(), DateTime.utc(2024, 3, 10, 5));
    expect(
      row.payerMemberId,
      (await repo.getLedgerById(ledgerId))!.selfMemberId,
    );
  });
  test('拒绝乱序发生和没有交易的游标前推', () async {
    final rule = await add();
    await expectLater(
      repo.generateRecurringTransaction(
        recurring: rule,
        happenedAt: day.add(const Duration(days: 1)),
      ),
      throwsStateError,
    );
    await expectLater(
      repo.updateLastGeneratedDate(rule.id, day),
      throwsStateError,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
  });
  test('重复发生保留人工修改、清空后墓碑不复活、删规则仍保留来源', () async {
    final rule = await add();
    final id = await repo.generateRecurringTransaction(
      recurring: rule,
      happenedAt: day,
    );
    await repo.updateTransaction(
      id: id,
      type: 'expense',
      amount: '99',
      note: '人工修正',
    );
    await repo.generateRecurringTransaction(recurring: rule, happenedAt: day);
    expect((await repo.getTransactionById(id))!.amount, '99');
    await repo.clearLedgerTransactions(ledgerId);
    await repo.generateRecurringTransaction(recurring: rule, happenedAt: day);
    expect(await repo.getTransactionById(id), isNull);
    expect(
      (await db.select(db.transactions).get()).single.deletedAt,
      isNotNull,
    );
    await repo.deleteRecurringTransaction(rule.id);
    expect(
      (await db.select(db.transactions).get()).single.recurringId,
      rule.id,
    );
  });
  test('游标写入失败时交易与关系全部回滚', () async {
    final rule = await add();
    await db.customStatement(
      "CREATE TRIGGER reject_cursor BEFORE UPDATE OF last_generated_date ON recurring_transactions BEGIN SELECT RAISE(ABORT,'test failure'); END",
    );
    await expectLater(
      repo.generateRecurringTransaction(recurring: rule, happenedAt: day),
      throwsA(anything),
    );
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(
      (await db.select(db.recurringTransactions).get())
          .single
          .lastGeneratedDate,
      isNull,
    );
  });
  test('无效协议拒绝生成且保留原规则，普通离线交易仍可创建删除', () async {
    await add();
    await db
        .update(db.recurringTransactions)
        .write(
          const RecurringTransactionsCompanion(protocolVersion: d.Value(2)),
        );
    await expectLater(
      RecurringTransactionService(repo).generatePendingTransactions(),
      throwsStateError,
    );
    final ordinary = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      happenedAt: day,
    );
    expect((await repo.getTransactionById(ordinary))!.occurrenceDate, isNull);
    await repo.clearLedgerTransactions(ledgerId);
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(
      (await db.select(db.recurringTransactions).get()).single.protocolVersion,
      2,
    );
  });
  test('200条有界补记，下一次继续，无历史遗漏', () async {
    final today = recurringCalendarDate(DateTime.now().toUtc());
    await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '1',
      frequency: 'daily',
      interval: 1,
      startDate: today.subtract(const Duration(days: 202)),
      timeZone: 'UTC',
    );
    final service = RecurringTransactionService(repo);
    expect(await service.generatePendingTransactions(), hasLength(200));
    expect(await service.generatePendingTransactions(), hasLength(3));
    expect(await service.generatePendingTransactions(), isEmpty);
  });
  test('外币缺汇率保留原规则与游标，不静默按1比1入账', () async {
    final rule = await add();
    await repo.updateLedger(id: ledgerId, currency: 'USD');
    await expectLater(
      repo.generateRecurringTransaction(recurring: rule, happenedAt: day),
      throwsStateError,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(
      (await db.select(db.recurringTransactions).get())
          .single
          .lastGeneratedDate,
      isNull,
    );
  });
}
