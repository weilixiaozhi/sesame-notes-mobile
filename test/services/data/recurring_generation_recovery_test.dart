import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';

import '../../helpers/test_isolation.dart';

/// 只注入指定模板的基础设施异常，其他操作使用真实数据库。
class _FailingRecurringRepository extends LocalRepository {
  /// 复用完整本地交易与游标事务。
  _FailingRecurringRepository(super.db);

  String? failedRuleId;
  String? failedReadRuleId;
  String? failedCursorReadRuleId;
  String? _failedReadTransactionId;
  final attemptedRules = <String>[];

  /// 未知基础设施错误必须中止扫描，不能被误认作模板业务失败。
  @override
  Future<String> generateRecurringTransaction({
    required RecurringTransactionSnapshot recurring,
    required DateTime happenedAt,
  }) async {
    try {
      attemptedRules.add(recurring.id);
      if (recurring.id == failedRuleId) throw StateError('数据库连接已关闭');
      final id = await super.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: happenedAt,
      );
      if (recurring.id == failedReadRuleId) _failedReadTransactionId = id;
      return id;
    } catch (error, stackTrace) {
      printOnFailure('受控周期生成失败：$error\n$stackTrace');
      rethrow;
    }
  }

  /// 生成事务结束后才注入回读错误，不能把尚未提交误当成已完成。
  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      if (id == _failedReadTransactionId) {
        throw StateError('提交后的交易快照暂时不可读');
      }
      return await super.getTransactionById(id);
    } catch (error, stackTrace) {
      printOnFailure('受控提交后回读失败：$error\n$stackTrace');
      rethrow;
    }
  }

  /// 规则游标是继续补记所需的事实，提交后的读取失败必须停止本轮扫描。
  @override
  Future<RecurringTransaction?> getRecurringTransactionById(
    String id, {
    required String ledgerId,
  }) async {
    try {
      if (id == failedCursorReadRuleId) {
        throw StateError('提交后的周期游标暂时不可读');
      }
      return await super.getRecurringTransactionById(id, ledgerId: ledgerId);
    } catch (error, stackTrace) {
      printOnFailure('受控提交后游标回读失败：$error\n$stackTrace');
      rethrow;
    }
  }
}

/// 单模板可恢复错误只保留该模板的游标，不影响独立模板或已成功结果。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _FailingRecurringRepository repository;
  late String ledgerId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _FailingRecurringRepository(db);
    ledgerId = await repository.createLedger(
      name: '周期失败隔离',
      currency: 'CNY',
      storageMode: 'local',
    );
  });

  tearDown(() => db.close());

  /// 每个模板只补一个固定历史发生，避免依赖设备时区和当前时间。
  Future<String> addRule({String currency = 'CNY'}) =>
      repository.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8',
        currencyCode: currency,
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 1),
        timeZone: 'UTC',
      );

  test('缺汇率模板前后的独立模板都生成，成功集合与失败游标保持真实', () async {
    final first = await addRule();
    final missingRate = await addRule(currency: 'USD');
    final last = await addRule();
    final generated =
        await RecurringTransactionService.generatePendingTransactionsStatic(
          repository: repository,
        );
    expect(generated, {ledgerId});
    final rows = await db.select(db.transactions).get();
    expect(rows.map((row) => row.recurringId).toSet(), {first, last});
    final rules = await db.select(db.recurringTransactions).get();
    expect(
      rules.singleWhere((rule) => rule.id == missingRate).lastGeneratedDate,
      isNull,
    );
    await RecurringTransactionService.generatePendingTransactionsStatic(
      repository: repository,
    );
    expect(await db.select(db.transactions).get(), hasLength(2));
  });

  test('基础设施错误终止后续扫描，仍返回此前真实完成的账本集合', () async {
    final first = await addRule();
    final failed = await addRule();
    final last = await addRule();
    repository.failedRuleId = failed;
    final generated =
        await RecurringTransactionService.generatePendingTransactionsStatic(
          repository: repository,
        );
    expect(generated, {ledgerId});
    expect(repository.attemptedRules, [first, failed]);
    expect(repository.attemptedRules, isNot(contains(last)));
    final rows = await db.select(db.transactions).get();
    expect(rows.single.recurringId, first);
    final rules = await db.select(db.recurringTransactions).get();
    expect(
      rules
          .where((rule) => rule.id != first)
          .every((rule) => rule.lastGeneratedDate == null),
      isTrue,
    );
  });

  test('不支持的模板协议只阻断该模板，独立模板仍可生成', () async {
    final unsupported = await addRule();
    final valid = await addRule();
    await (db.update(db.recurringTransactions)
          ..where((rule) => rule.id.equals(unsupported)))
        .write(const RecurringTransactionsCompanion(protocolVersion: Value(2)));
    final generated =
        await RecurringTransactionService.generatePendingTransactionsStatic(
          repository: repository,
        );
    expect(generated, {ledgerId});
    final transactions = await db.select(db.transactions).get();
    expect(transactions.single.recurringId, valid);
    final rules = await db.select(db.recurringTransactions).get();
    expect(
      rules.singleWhere((rule) => rule.id == unsupported).lastGeneratedDate,
      isNull,
    );
  });

  test('首笔提交后游标回读失败仍保留已完成账本集合，后续发生不执行', () async {
    final committed = await addRule();
    final pending = await addRule();
    repository.failedCursorReadRuleId = committed;
    final generated =
        await RecurringTransactionService.generatePendingTransactionsStatic(
          repository: repository,
        );
    expect(generated, {ledgerId});
    expect(repository.attemptedRules, [committed]);
    final transactions = await db.select(db.transactions).get();
    expect(transactions.single.recurringId, committed);
    final rules = await db.select(db.recurringTransactions).get();
    expect(
      rules.singleWhere((rule) => rule.id == committed).lastGeneratedDate,
      isNotNull,
    );
    expect(
      rules.singleWhere((rule) => rule.id == pending).lastGeneratedDate,
      isNull,
    );
    expect(
      await RecurringTransactionService(
        repository,
      ).generatePendingTransactions(),
      hasLength(1),
      reason: '后续扫描从已提交游标继续，不重放已完成发生',
    );
  });

  test('显式扫描的提交后回读异常仍向调用方传播', () async {
    repository.failedReadRuleId = await addRule();
    await expectLater(
      RecurringTransactionService(repository).generatePendingTransactions(),
      throwsStateError,
    );
    expect(await db.select(db.transactions).get(), hasLength(1));
    final rule = await db.select(db.recurringTransactions).getSingle();
    expect(rule.lastGeneratedDate, isNotNull);
  });
}
