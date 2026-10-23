import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';

class _MockRepo extends Mock implements LocalRepository {}

/// 本组规则固定为 UTC，夹具使用该时区的今天以排除设备时区影响。
DateTime _today() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day);
}

/// 构造协议 1 模板；所有排期日期都以 UTC 承载纯日期。
RecurringTransactionSnapshot recurringRow({
  String id = '1',
  String ledgerId = '1',
  String amount = '10.00',
  String frequency = 'daily',
  int interval = 1,
  int? dayOfMonth,
  int? dayOfWeek,
  int? monthOfYear,
  DateTime? startDate,
  DateTime? endDate,
  DateTime? lastGeneratedDate,
  bool enabled = true,
}) {
  return RecurringTransactionSnapshot(
    id: id,
    ledgerId: ledgerId,
    txType: 'expense',
    amount: amount,
    currencyCode: 'CNY',
    protocolVersion: 1,
    timeZone: 'UTC',
    categoryId: null,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    dayOfWeek: dayOfWeek,
    monthOfYear: monthOfYear,
    startDate: startDate ?? DateTime.utc(2025, 1, 1),
    endDate: endDate,
    lastGeneratedDate: lastGeneratedDate,
    enabled: enabled,
    createdAt: DateTime.utc(2025, 1, 1),
    updatedAt: DateTime.utc(2025, 1, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;

  // 仓库已禁止凭空推进游标。此处仅注入内存库历史快照，模拟同步前已生成的进度。
  Future<void> seedHistoricalCursor(String id, DateTime date) async {
    await (db.update(
      db.recurringTransactions,
    )..where((row) => row.id.equals(id))).write(
      RecurringTransactionsCompanion(lastGeneratedDate: d.Value(date)),
    );
  }

  setUp(() async {
    // LoggerService(被周期服务调用)内部走 SharedPreferences,单测需提供 mock,
    // 否则 logger.info 触发 MissingPluginException 让测试在完成后异步失败。
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(
      name: 'test',
      currency: 'CNY',
      storageMode: 'local',
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('账本换币或模板跨币种账本后，生成交易仍按模板原币种折算', () async {
    await repo.upsertAutoRates(
      base: 'USD',
      rateDate: '2026-08-18',
      rates: const {'CNY': '0.14'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 8, 18),
    );

    // 场景一：账本本位币从 CNY 改成 USD，模板金额仍是创建时的 CNY。
    final switchedId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '100.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 18,
      timeZone: 'UTC',
      startDate: DateTime.utc(2026, 8, 1),
    );
    await repo.updateLedger(id: ledgerId, currency: 'USD');
    final switched = (await repo.getAllRecurringTransactions()).singleWhere(
      (r) => r.id == switchedId,
    );
    final switchedTxId = await repo.generateRecurringTransaction(
      recurring: switched,
      happenedAt: DateTime.utc(2026, 8, 18),
    );
    final switchedTx = await repo.getTransactionById(switchedTxId);
    expect(switched.currencyCode, 'CNY');
    expect(switchedTx?.currencyCode, 'CNY');
    expect(switchedTx?.nativeAmount, '14');

    // 场景二：把 CNY 模板移到 USD 账本，未显式改币种时必须保留 CNY。
    // 服务端禁止同一 UUID 跨账本 upsert（ENTITY_SCOPE_CONFLICT），
    // 移动必须删除旧实体并以新 UUID 在目标账本重建，否则云同步会被永久拒绝。
    final sourceLedgerId = await repo.createLedger(
      name: 'source-cny',
      currency: 'CNY',
      storageMode: 'local',
    );
    final targetLedgerId = await repo.createLedger(
      name: 'target-usd',
      currency: 'USD',
      storageMode: 'local',
    );
    final movedId = await repo.addRecurringTransaction(
      ledgerId: sourceLedgerId,
      type: 'expense',
      amount: '200.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 18,
      timeZone: 'UTC',
      startDate: DateTime.utc(2026, 8, 1),
    );
    await repo.updateRecurringTransaction(
      id: movedId,
      ledgerId: targetLedgerId,
      type: 'expense',
      amount: '200.00',
      frequency: 'monthly',
      interval: 1,
      dayOfMonth: 18,
      timeZone: 'UTC',
      startDate: DateTime.utc(2026, 8, 1),
    );
    // 跨账本移动后旧 UUID 必须消失，模板以新 UUID 归属目标账本。
    expect(
      (await repo.getAllRecurringTransactions()).any((r) => r.id == movedId),
      isFalse,
      reason: '跨账本移动后旧 UUID 必须消失（服务端禁止同 UUID 跨账本）',
    );
    final moved = (await repo.getRecurringTransactionsByLedger(
      targetLedgerId,
    )).singleWhere((r) => r.id != movedId);
    expect(moved.currencyCode, 'CNY');
    final movedTxId = await repo.generateRecurringTransaction(
      recurring: moved,
      happenedAt: DateTime.utc(2026, 8, 18),
    );
    final movedTx = await repo.getTransactionById(movedTxId);
    expect(movedTx?.ledgerId, targetLedgerId);
    expect(movedTx?.currencyCode, 'CNY');
    expect(movedTx?.nativeAmount, '28');
  });

  group('calculateNextDate 频率与边界', () {
    final service = RecurringTransactionService(_MockRepo());

    test('weekly：按开始日期和星期锚点每周推进，未到期返回 null', () {
      final due = service.calculateNextDate(
        recurringRow(
          frequency: 'weekly',
          startDate: DateTime.utc(2026, 1, 1),
          dayOfWeek: DateTime.thursday,
          lastGeneratedDate: DateTime.utc(2026, 1, 1),
        ),
        now: DateTime.utc(2026, 1, 9),
      );
      expect(due, DateTime.utc(2026, 1, 8), reason: '上周四后应在周四生成');

      final notDue = service.calculateNextDate(
        recurringRow(
          frequency: 'weekly',
          startDate: DateTime.utc(2026, 1, 1),
          dayOfWeek: DateTime.thursday,
          lastGeneratedDate: DateTime.utc(2026, 1, 1),
        ),
        now: DateTime.utc(2026, 1, 7),
      );
      expect(notDue, isNull, reason: '尚未到下个周期日不生成');
    });

    test('weekly：interval=2 推 14 天', () {
      final due = service.calculateNextDate(
        recurringRow(
          frequency: 'weekly',
          interval: 2,
          startDate: DateTime.utc(2026, 1, 1),
          dayOfWeek: DateTime.thursday,
          lastGeneratedDate: DateTime.utc(2026, 1, 1),
        ),
        now: DateTime.utc(2026, 1, 20),
      );
      expect(due, DateTime.utc(2026, 1, 15));
    });

    test('monthly：上次生成后按目标日推进；interval=2 推两个月', () {
      final due = service.calculateNextDate(
        recurringRow(
          frequency: 'monthly',
          interval: 2,
          dayOfMonth: 20,
          lastGeneratedDate: DateTime.utc(2026, 1, 20),
        ),
        now: DateTime.utc(2026, 3, 20),
      );
      expect(due, DateTime.utc(2026, 3, 20), reason: '每 2 个月 → 1/20 后为 3/20');
    });

    test('monthly：目标日不存在时夹到月末（2月无 31 日 → 2/28）', () {
      final due = service.calculateNextDate(
        recurringRow(
          frequency: 'monthly',
          dayOfMonth: 31,
          lastGeneratedDate: DateTime.utc(2026, 1, 31),
        ),
        now: DateTime.utc(2026, 3, 1),
      );
      expect(due, DateTime.utc(2026, 2, 28), reason: '2026 非闰年，2 月夹到 28 日');
    });

    test('yearly：按年推进；闰年 2/29 夹到平年 2/28', () {
      final due = service.calculateNextDate(
        recurringRow(
          frequency: 'yearly',
          dayOfMonth: 5,
          monthOfYear: 5,
          lastGeneratedDate: DateTime.utc(2025, 5, 5),
        ),
        now: DateTime.utc(2026, 5, 5),
      );
      expect(due, DateTime.utc(2026, 5, 5));

      final leapClamped = service.calculateNextDate(
        recurringRow(
          frequency: 'yearly',
          dayOfMonth: 29,
          monthOfYear: 2,
          startDate: DateTime.utc(2024, 1, 1),
          lastGeneratedDate: DateTime.utc(2024, 2, 29),
        ),
        now: DateTime.utc(2025, 3, 1),
      );
      expect(
        leapClamped,
        DateTime.utc(2025, 2, 28),
        reason: '平年无 2/29，夹到 2/28',
      );
    });

    test('已过结束日期仍补齐历史；下个周期日超过结束日期才跳过', () {
      final expired = service.calculateNextDate(
        recurringRow(
          endDate: DateTime.utc(2026, 1, 1),
          lastGeneratedDate: DateTime.utc(2025, 12, 1),
        ),
        now: DateTime.utc(2026, 1, 2),
      );
      expect(expired, DateTime.utc(2025, 12, 2));

      final overEnd = service.calculateNextDate(
        recurringRow(
          endDate: DateTime.utc(2026, 1, 1),
          lastGeneratedDate: DateTime.utc(2026, 1, 1),
        ),
        now: DateTime.utc(2026, 1, 1, 22),
      );
      expect(overEnd, isNull, reason: '下一个周期日 1/2 已晚于结束日期 1/1');
    });
  });

  group('generatePendingTransactionsStatic 静态入口', () {
    test('无待生成时返回空集合', () async {
      final result =
          await RecurringTransactionService.generatePendingTransactionsStatic(
            repository: repo,
          );
      expect(result, isEmpty);
    });

    test('有生成时返回涉及账本 ID 集合', () async {
      await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        frequency: 'daily',
        interval: 1,
        startDate: _today(),
        timeZone: 'UTC',
      );
      final result =
          await RecurringTransactionService.generatePendingTransactionsStatic(
            repository: repo,
          );
      expect(result, {ledgerId});
    });

    test('repository 抛错时吞掉异常并返回空集合', () async {
      final broken = _MockRepo();
      when(() => broken.getAllLedgers()).thenThrow(Exception('db down'));
      final result =
          await RecurringTransactionService.generatePendingTransactionsStatic(
            repository: broken,
          );
      expect(result, isEmpty, reason: '启动扫描不允许把异常抛到上层');
    });
  });

  group('generatePendingTransactions 扫描行为', () {
    test('扫描已读出模板后归档，实际生成事务照常落账并推进日期', () async {
      await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10',
        frequency: 'daily',
        interval: 1,
        startDate: _today(),
        timeZone: 'UTC',
      );
      final recurring = (await repo.getRecurringTransactionsByLedger(
        ledgerId,
      )).single;
      await repo.setLedgerArchived(ledgerId, true);
      final happenedAt = _today();
      final transactionId = await repo.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: happenedAt,
      );
      expect(await repo.getTransactionById(transactionId), isNotNull);
      expect(
        (await repo.getLedgerStats(ledgerId: ledgerId)).transactionCount,
        1,
      );
      expect(
        (await repo.getRecurringTransactionsByLedger(
          ledgerId,
        )).single.lastGeneratedDate?.toUtc(),
        happenedAt,
      );
    });

    test('归档账本照常生成到期账目，恢复后不重复生成', () async {
      final today = _today();
      final lastGenerated = today.subtract(const Duration(days: 4));
      final recurringId = await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10',
        frequency: 'daily',
        interval: 1,
        startDate: lastGenerated,
      );
      await seedHistoricalCursor(recurringId, lastGenerated);
      await repo.setLedgerArchived(ledgerId, true);
      final service = RecurringTransactionService(repo);
      final generated = await service.generatePendingTransactions();
      expect(generated.map((transaction) => transaction.happenedAt.toUtc()), [
        today.subtract(const Duration(days: 3)),
        today.subtract(const Duration(days: 2)),
        today.subtract(const Duration(days: 1)),
        today,
      ]);
      final recurring = (await repo.getRecurringTransactionsByLedger(
        ledgerId,
      )).single;
      expect(recurring.enabled, isTrue);
      expect(recurring.lastGeneratedDate?.toUtc(), today);

      await repo.setLedgerArchived(ledgerId, false);
      expect(await service.generatePendingTransactions(), isEmpty);
    });

    test('归档期间未扫描，恢复后沿原周期补记而不跳过归档期间', () async {
      final today = _today();
      final lastGenerated = today.subtract(const Duration(days: 6));
      final recurringId = await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10',
        frequency: 'daily',
        interval: 2,
        startDate: lastGenerated,
      );
      await seedHistoricalCursor(recurringId, lastGenerated);
      await repo.setLedgerArchived(ledgerId, true);
      await repo.setLedgerArchived(ledgerId, false);
      final generated = await RecurringTransactionService(
        repo,
      ).generatePendingTransactions();
      expect(generated.map((transaction) => transaction.happenedAt.toUtc()), [
        today.subtract(const Duration(days: 4)),
        today.subtract(const Duration(days: 2)),
        today,
      ]);
    });

    test('禁用模板不生成', () async {
      await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        frequency: 'daily',
        interval: 1,
        startDate: _today(),
        timeZone: 'UTC',
        enabled: false,
      );
      final generated = await RecurringTransactionService(
        repo,
      ).generatePendingTransactions();
      expect(generated, isEmpty);
    });

    test('多账本分别生成', () async {
      final secondLedgerId = await repo.createLedger(
        name: 'test2',
        currency: 'CNY',
        storageMode: 'local',
      );
      await repo.addRecurringTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '10.00',
        frequency: 'daily',
        interval: 1,
        startDate: _today(),
        timeZone: 'UTC',
      );
      await repo.addRecurringTransaction(
        ledgerId: secondLedgerId,
        type: 'expense',
        amount: '20.00',
        frequency: 'daily',
        interval: 1,
        startDate: _today(),
        timeZone: 'UTC',
      );
      final generated = await RecurringTransactionService(
        repo,
      ).generatePendingTransactions();
      expect(generated, hasLength(2));
      expect(generated.map((t) => t.ledgerId).toSet(), {
        ledgerId,
        secondLedgerId,
      });
    });
  });

  // 断言某 DateTime 是规则时区的今天（此处 UTC 零点）。
  void expectIsToday(DateTime d) {
    final now = _today();
    expect(d.toUtc().year, now.year);
    expect(d.toUtc().month, now.month);
    expect(d.toUtc().day, now.day);
  }

  test('协议1历史开始日期30天前且从未生成，从开始日连续补齐到今天', () async {
    // 跨端统一协议从开始日补齐每个到期发生。
    final start = _today().subtract(const Duration(days: 30));
    await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: start,
      timeZone: 'UTC',
    );

    final service = RecurringTransactionService(repo);
    final generated = await service.generatePendingTransactions();

    expect(generated, hasLength(31));
    expect(generated.map((row) => row.happenedAt.toUtc()), [
      for (var day = 0; day <= 30; day++) start.add(Duration(days: day)),
    ]);
    expectIsToday(generated.last.happenedAt);
    expect(await service.generatePendingTransactions(), isEmpty);
  });

  test('协议1开始日期为昨天且从未生成，补齐昨天和今天两笔', () async {
    final yesterday = _today().subtract(const Duration(days: 1));
    await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: yesterday,
      timeZone: 'UTC',
    );

    final service = RecurringTransactionService(repo);
    final generated = await service.generatePendingTransactions();

    expect(generated, hasLength(2));
    expect(generated.first.happenedAt.toUtc(), yesterday);
    expectIsToday(generated.last.happenedAt);
  });

  test('已生成过(lastGeneratedDate=昨天)→ 正常补出今天一笔', () async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: _today().subtract(const Duration(days: 30)),
      timeZone: 'UTC',
    );
    final yesterday = _today().subtract(const Duration(days: 1));
    await seedHistoricalCursor(id, yesterday);

    final service = RecurringTransactionService(repo);
    final generated = await service.generatePendingTransactions();

    // 昨天 → 今天一笔(daily);明天还没到,停在这。
    expect(generated, hasLength(1));
    expectIsToday(generated.first.happenedAt);
  });

  test('今天已生成过(lastGeneratedDate=今天)→ 不重复生成', () async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: _today().subtract(const Duration(days: 30)),
      timeZone: 'UTC',
    );
    final today = _today();
    await seedHistoricalCursor(id, today);

    final service = RecurringTransactionService(repo);
    final generated = await service.generatePendingTransactions();

    expect(generated, isEmpty); // 今天已生成,明天才下一笔
  });

  test('开始日期在未来(明天)→ 今天不生成', () async {
    await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: _today().add(const Duration(days: 1)),
      timeZone: 'UTC',
    );

    final service = RecurringTransactionService(repo);
    final generated = await service.generatePendingTransactions();

    expect(generated, isEmpty); // 未来开始,首笔在明天
  });

  test('编辑周期模板保留生成进度，协议1禁止显式清空已有进度', () async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      frequency: 'daily',
      interval: 1,
      startDate: _today().subtract(const Duration(days: 30)),
      timeZone: 'UTC',
    );
    final yesterday = _today().subtract(const Duration(days: 1));
    await seedHistoricalCursor(id, yesterday);

    // 普通编辑不传 clearLastGeneratedDate:锚点必须保留,否则下次扫描会重生成。
    await repo.updateRecurringTransaction(
      id: id,
      ledgerId: ledgerId,
      type: 'expense',
      amount: '12.00',
      frequency: 'daily',
      interval: 1,
      startDate: _today().subtract(const Duration(days: 30)),
    );
    var row = await (db.select(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.lastGeneratedDate?.toUtc(), yesterday);

    // 已发生日期是跨端去重进度，编辑入口不得清空后重新生成历史。
    await expectLater(
      repo.updateRecurringTransaction(
        id: id,
        ledgerId: ledgerId,
        type: 'expense',
        amount: '12.00',
        frequency: 'daily',
        interval: 1,
        startDate: _today().subtract(const Duration(days: 30)),
        clearLastGeneratedDate: true,
      ),
      throwsStateError,
    );
    row = await (db.select(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).getSingle();
    expect(row.lastGeneratedDate?.toUtc(), yesterday);
    expect(row.amount, '12.00');
  });
}
