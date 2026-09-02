// statistics_providers 统计 provider 测试。
//
// 需求锚点：
//   1. countsForLedger / monthlyTotals / todayExpense / weekExpense 经 repository 取数，
//      并把最近一次成功值写入 last* 缓存；
//   2. analyticsHasAnyExpense：无账本 false；有账本查库；
//   3. analyticsDataRange：无账本 (null,null)；有账本查最早/最晚。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  db.Ledger ledger() => db.Ledger(
    id: 'led-1',
    name: 'L',
    currency: 'CNY',
    monthStartDay: 1,
    aaEnabled: false,
    role: 'owner',
    memberCount: 1,
    storageMode: 'local',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  ProviderContainer container({db.Ledger? current}) => ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(repo),
      currentLedgerProvider.overrideWith(
        (ref) => Stream<db.Ledger?>.value(current),
      ),
    ],
  );

  test('countsForLedger / monthlyTotals 写入 last 缓存', () async {
    when(
      () => repo.getCountsForLedger(ledgerId: 'led-1'),
    ).thenAnswer((_) async => (dayCount: 5, txCount: 9));
    when(
      () => repo.monthlyTotals(ledgerId: 'led-1', month: DateTime(2026, 7, 1)),
    ).thenAnswer((_) async => 123.5);

    final c = container(current: ledger());
    addTearDown(c.dispose);
    final params = (ledgerId: 'led-1', month: DateTime(2026, 7, 1));

    final counts = await readProviderFutureFromContainer(
      c,
      countsForLedgerProvider('led-1').future,
    );
    expect(counts.dayCount, 5);
    expect(counts.txCount, 9);

    final total = await readProviderFutureFromContainer(
      c,
      monthlyTotalsProvider(params).future,
    );
    expect(total, 123.5);
    expect(c.read(lastMonthlyTotalsProvider(params)), 123.5);
  });

  test('todayExpense / weekExpense 写入 last 缓存', () async {
    when(
      () => repo.todayExpense(
        ledgerId: 'led-1',
        now: any(named: 'now'),
      ),
    ).thenAnswer((_) async => 10.0);
    when(
      () => repo.weekExpense(
        ledgerId: 'led-1',
        now: any(named: 'now'),
      ),
    ).thenAnswer((_) async => 20.0);

    final c = container(current: ledger());
    addTearDown(c.dispose);

    expect(
      await readProviderFutureFromContainer(
        c,
        todayExpenseProvider('led-1').future,
      ),
      10.0,
    );
    expect(c.read(lastTodayExpenseProvider('led-1')), 10.0);
    expect(
      await readProviderFutureFromContainer(
        c,
        weekExpenseProvider('led-1').future,
      ),
      20.0,
    );
    expect(c.read(lastWeekExpenseProvider('led-1')), 20.0);
  });

  test('analyticsHasAnyExpense / analyticsDataRange：无账本归 0/null', () async {
    final c = container();
    addTearDown(c.dispose);

    expect(
      await readProviderFutureFromContainer(
        c,
        analyticsHasAnyExpenseProvider.future,
      ),
      isFalse,
    );
    final range = await readProviderFutureFromContainer(
      c,
      analyticsDataRangeProvider.future,
    );
    expect(range.earliest, isNull);
    expect(range.latest, isNull);
  });

  test('analyticsHasAnyExpense / analyticsDataRange：有账本查库', () async {
    when(
      () => repo.hasAnyExpenseTx(ledgerId: 'led-1'),
    ).thenAnswer((_) async => true);
    when(
      () => repo.earliestExpenseDate(ledgerId: 'led-1'),
    ).thenAnswer((_) async => DateTime(2026, 1, 1));
    when(
      () => repo.latestExpenseDate(ledgerId: 'led-1'),
    ).thenAnswer((_) async => DateTime(2026, 7, 1));

    final c = container(current: ledger());
    addTearDown(c.dispose);

    expect(
      await readProviderFutureFromContainer(
        c,
        analyticsHasAnyExpenseProvider.future,
      ),
      isTrue,
    );
    final range = await readProviderFutureFromContainer(
      c,
      analyticsDataRangeProvider.future,
    );
    expect(range.earliest, DateTime(2026, 1, 1));
    expect(range.latest, DateTime(2026, 7, 1));
  });
}
