import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';

/// 只记录真实统计入口收到的自然日期，测试不会依赖执行机器的时区或日期。
class _Statistics extends Fake implements StatisticsRepository {
  final dailyDates = <DateTime>[];
  final weeklyDates = <DateTime>[];

  /// 用日期值区分每日查询，数据库通知保持静止。
  @override
  Future<double> todayExpense({
    required String ledgerId,
    required DateTime now,
  }) async {
    dailyDates.add(now);
    return now.day.toDouble();
  }

  /// 周日跨到周一时必须重新请求本周统计。
  @override
  Future<double> weekExpense({
    required String ledgerId,
    required DateTime now,
  }) async {
    weeklyDates.add(now);
    return now.weekday.toDouble();
  }
}

/// 午夜日期推进无需写入任何业务数据，也要更新首页今日与本周金额。
void main() {
  test('当地日期跨到下一周时，今日与本周汇总主动重查', () async {
    var today = DateTime(2026, 10, 25);
    final repository = _Statistics();
    final container = ProviderContainer(
      overrides: [
        statisticsDataAccessProvider.overrideWithValue(repository),
        accountingDataChangeSignalProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
        localTodayProvider.overrideWithBuild((ref, notifier) => today),
      ],
    );
    final daily = container.listen(todayExpenseProvider('ledger'), (_, _) {});
    final weekly = container.listen(weekExpenseProvider('ledger'), (_, _) {});
    try {
      expect(await container.read(todayExpenseProvider('ledger').future), 25);
      expect(await container.read(weekExpenseProvider('ledger').future), 7);
      today = DateTime(2026, 10, 26);
      container.invalidate(localTodayProvider);
      expect(await container.read(todayExpenseProvider('ledger').future), 26);
      expect(await container.read(weekExpenseProvider('ledger').future), 1);
      expect(repository.dailyDates, [DateTime(2026, 10, 25), today]);
      expect(repository.weeklyDates, [DateTime(2026, 10, 25), today]);
    } finally {
      daily.close();
      weekly.close();
      container.dispose();
    }
  });
}
