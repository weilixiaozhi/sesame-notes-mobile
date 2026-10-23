import 'package:flutter_test/flutter_test.dart';
import '../../../helpers/year_analytics.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const accountId = 'month-start-statistics-account';
  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db, accountIdGetter: () => accountId);
  });

  tearDown(() async {
    try {
      await db.close();
    } finally {
      await logger.clear();
    }
  });

  /// 用当前测试账号创建完整归属的云账本，统计查询使用同一个账号域。
  Future<String> seedLedger({int monthStartDay = 1}) async {
    try {
      final id = await repo.createLedger(
        name: '测试账本',
        monthStartDay: monthStartDay,
      );
      final ledger = await repo.getLedgerById(id);
      expect(ledger, isNotNull);
      expect(ledger!.scopeAccountId, accountId);
      expect(ledger.ownerAccountId, accountId);
      return id;
    } catch (error, stackTrace) {
      logger.error('MonthStartStatsTest', '创建账期统计测试账本失败', error, stackTrace);
      rethrow;
    }
  }

  /// 在账本下添加一笔交易（金额为规范化 decimal 字符串）
  Future<void> addTx(String lid, String type, String amount, DateTime at) =>
      repo.addTransaction(
        ledgerId: lid,
        type: type,
        amount: amount,
        happenedAt: at,
      );

  test('创建与修改账本保留29至31日', () async {
    final lid = await seedLedger(monthStartDay: 31);
    expect((await repo.getLedgerById(lid))!.monthStartDay, 31);
    for (final day in [29, 30, 31]) {
      await repo.updateLedger(id: lid, monthStartDay: day);
      expect((await repo.getLedgerById(lid))!.monthStartDay, day);
    }
  });

  test('当前账本起始日Provider保留31，供统计与交易列表使用', () async {
    final lid = await seedLedger(monthStartDay: 31);
    final ledger = await repo.getLedgerById(lid);
    final container = ProviderContainer(
      overrides: [
        currentLedgerProvider.overrideWith((ref) => Stream.value(ledger)),
      ],
    );
    addTearDown(container.dispose);
    await readProviderFutureFromContainer(
      container,
      currentLedgerProvider.future,
    );
    expect(container.read(currentMonthStartDayProvider), 31);
  });

  for (final scenario in [
    (
      year: 2026,
      month: 1,
      start: DateTime(2026, 1, 31),
      end: DateTime(2026, 2, 28),
    ),
    (
      year: 2028,
      month: 2,
      start: DateTime(2028, 2, 29),
      end: DateTime(2028, 3, 31),
    ),
    (
      year: 2026,
      month: 4,
      start: DateTime(2026, 4, 30),
      end: DateTime(2026, 5, 31),
    ),
  ]) {
    test('31日账期 ${scenario.year}-${scenario.month} 的统计和交易使用相同半开边界', () async {
      final lid = await seedLedger(monthStartDay: 31);
      await addTx(
        lid,
        'expense',
        '10.00',
        scenario.start.subtract(const Duration(seconds: 1)),
      );
      await addTx(lid, 'expense', '20.00', scenario.start);
      await addTx(
        lid,
        'expense',
        '40.00',
        scenario.end.subtract(const Duration(seconds: 1)),
      );
      await addTx(lid, 'expense', '80.00', scenario.end);
      final month = DateTime(scenario.year, scenario.month);

      expect(await repo.monthlyTotals(ledgerId: lid, month: month), 60);
      final transactions = await repo
          .watchTransactionsInMonth(ledgerId: lid, month: month)
          .first;
      expect(transactions.map((row) => row.amount), ['40.00', '20.00']);
      final joined = await repo
          .watchTransactionsWithCategoryInMonth(ledgerId: lid, month: month)
          .first;
      expect(joined.map((row) => row.t.amount), ['40.00', '20.00']);
      final months = await loadYearAnalyticsPoints(
        repo,
        ledgerId: lid,
        type: 'expense',
        year: scenario.year,
      );
      expect(
        months.firstWhere((row) => row.month.month == scenario.month).total,
        60,
      );
    });
  }

  test('31日年度统计从1月31日起，并包含次年1月30日', () async {
    final lid = await seedLedger(monthStartDay: 31);
    await addTx(lid, 'expense', '10.00', DateTime(2026, 1, 30, 23, 59, 59));
    await addTx(lid, 'expense', '20.00', DateTime(2026, 1, 31));
    await addTx(lid, 'expense', '40.00', DateTime(2027, 1, 30, 23, 59, 59));
    await addTx(lid, 'expense', '80.00', DateTime(2027, 1, 31));
    for (final expected in [
      (year: 2025, total: 10.0),
      (year: 2026, total: 60.0),
      (year: 2027, total: 80.0),
    ]) {
      final months = await loadYearAnalyticsPoints(
        repo,
        ledgerId: lid,
        type: 'expense',
        year: expected.year,
      );
      expect(
        months.fold<double>(0, (sum, row) => sum + row.total),
        expected.total,
      );
    }
  });

  test('monthlyTotals 按起始日聚合: 6月标签 = [6.15, 7.15)', () async {
    final lid = await seedLedger(monthStartDay: 15);
    await addTx(lid, 'expense', '10.00', DateTime(2026, 6, 14, 23, 59)); // 5月周期
    await addTx(lid, 'expense', '20.00', DateTime(2026, 6, 15)); // 6月周期
    await addTx(lid, 'expense', '40.00', DateTime(2026, 7, 14, 23, 59)); // 6月周期
    await addTx(lid, 'expense', '80.00', DateTime(2026, 7, 15)); // 7月周期

    final expense = await repo.monthlyTotals(
      ledgerId: lid,
      month: DateTime(2026, 6, 1),
    );
    expect(expense, 60); // 20 + 40
  });

  test('monthlyTotals 起始日=1 退化为自然月(回归红线)', () async {
    final lid = await seedLedger();
    await addTx(lid, 'expense', '10.00', DateTime(2026, 6, 1));
    await addTx(lid, 'expense', '20.00', DateTime(2026, 6, 30, 23, 59));
    await addTx(lid, 'expense', '40.00', DateTime(2026, 7, 1));
    final expense = await repo.monthlyTotals(
      ledgerId: lid,
      month: DateTime(2026, 6, 1),
    );
    expect(expense, 30);
  });

  test('年图十二账期按周期标签归位', () async {
    final lid = await seedLedger(monthStartDay: 10);
    await addTx(lid, 'expense', '30.00', DateTime(2027, 1, 5)); // 2026-12 标签
    await addTx(
      lid,
      'expense',
      '99.00',
      DateTime(2026, 1, 9),
    ); // 2025-12 标签 → 范围外
    await addTx(lid, 'expense', '7.00', DateTime(2026, 1, 10)); // 2026-01 标签

    final rows = await loadYearAnalyticsPoints(
      repo,
      ledgerId: lid,
      type: 'expense',
      year: 2026,
    );
    expect(rows.length, 12);
    expect(rows.firstWhere((r) => r.month.month == 1).total, 7);
    expect(rows.firstWhere((r) => r.month.month == 12).total, 30);
    expect(rows.fold<double>(0, (s, r) => s + r.total), 37);
  });

  test('年度月桶累计包含次年起始日前的交易，并排除本年起始日前交易', () async {
    final lid = await seedLedger(monthStartDay: 10);
    await addTx(lid, 'expense', '30.00', DateTime(2027, 1, 5));
    await addTx(lid, 'expense', '99.00', DateTime(2026, 1, 9));
    final months = await loadYearAnalyticsPoints(
      repo,
      ledgerId: lid,
      type: 'expense',
      year: 2026,
    );
    expect(months.fold<double>(0, (sum, row) => sum + row.total), 30);
  });

  test('watchTransactionsInMonth 按周期过滤', () async {
    final lid = await seedLedger(monthStartDay: 15);
    await addTx(lid, 'expense', '10.00', DateTime(2026, 6, 14)); // 5月周期
    await addTx(lid, 'expense', '20.00', DateTime(2026, 6, 20)); // 6月周期
    final txs = await repo
        .watchTransactionsInMonth(ledgerId: lid, month: DateTime(2026, 6, 1))
        .first;
    expect(txs.length, 1);
    expect(txs.single.amount, '20.00');
  });

  test('getDailyTotalsByMonth 半开区间包含 23:59:59.500', () async {
    final lid = await seedLedger();
    await addTx(lid, 'expense', '10.00', DateTime(2026, 8, 5, 23, 59, 59, 500));

    final totals = await repo.getDailyTotalsByMonth(
      ledgerId: lid,
      month: DateTime(2026, 8, 1),
    );
    expect(totals['2026-08-05'], 10.0);
  });

  test('getTransactionsByDate 包含毫秒边界交易', () async {
    final lid = await seedLedger();
    await addTx(lid, 'expense', '10.00', DateTime(2026, 8, 5, 23, 59, 59, 500));

    final txs = await repo.getTransactionsByDate(
      ledgerId: lid,
      date: DateTime(2026, 8, 5),
    );
    expect(txs, hasLength(1));
  });

  // 账本被 tombstone 后行仍在：统计必须继续用它自己的周期归桶，不能因为
  // 删除就换口径（读取账本行本身不该加 deletedAt 过滤，否则口径会悄悄退化
  // 成自然月）。
  test('账本被 tombstone 后统计仍按该账本周期归桶', () async {
    final lid = await seedLedger(monthStartDay: 15);
    await addTx(lid, 'expense', '10.00', DateTime(2026, 6, 14, 23, 59)); // 5月周期
    await addTx(lid, 'expense', '20.00', DateTime(2026, 6, 20)); // 6月周期
    await (db.update(db.ledgers)..where((row) => row.id.equals(lid))).write(
      LedgersCompanion(deletedAt: d.Value(DateTime.utc(2026, 6, 21))),
    );

    expect(
      await repo.monthlyTotals(ledgerId: lid, month: DateTime(2026, 6, 1)),
      20,
    );
  });

  // 账本物理清理后没有可归桶数据，按自然月降级并记录诊断。
  test('账本行不存在时统计按自然月降级并留下诊断', () async {
    await logger.clear();

    expect(
      await repo.monthlyTotals(
        ledgerId: 'missing',
        month: DateTime(2026, 6, 1),
      ),
      0,
    );
    expect(
      (await loadYearAnalyticsPoints(
        repo,
        ledgerId: 'missing',
        type: 'expense',
        year: 2026,
      )).every((row) => row.total == 0),
      isTrue,
    );
    expect(
      logger.logs
          .where((entry) => entry.tag == 'LedgerLookup')
          .map((entry) => entry.message),
      anyElement(contains('账本行不存在，每月起始日按自然月降级')),
    );

    await logger.clear();
  });
}
