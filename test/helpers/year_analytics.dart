import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/ledger_lookup.dart';
import 'package:sesame_notes/features/statistics/application/analytics_queries.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 使用真实统计页查询链读取年度趋势，数据库与分类端口共用当前测试仓储。
Future<List<({DateTime month, double total})>> loadYearAnalyticsPoints(
  LocalRepository repository, {
  required String ledgerId,
  required String type,
  required int year,
}) async {
  final container = ProviderContainer(
    overrides: [
      statisticsDataAccessProvider.overrideWithValue(repository),
      categoryQueriesProvider.overrideWithValue(repository.categoryStore),
    ],
  );
  try {
    // 账期元数据与历史读取使用同一生产入口；归桶由真实 AnalyticsQueries 完成。
    final startDay = await ledgerMonthStartDay(repository.db, ledgerId);
    final data = await container
        .read(analyticsQueriesProvider)
        .load(
          ledgerId: ledgerId,
          type: type,
          period: AnalyticsPeriod.year,
          selectedYear: year,
          monthStartDay: startDay,
          current: yearRangeFor(year, startDay),
        );
    return (data.series as MonthlyAnalyticsSeries).points;
  } catch (error, stackTrace) {
    logger.error('YearAnalyticsTest', '年度统计查询验证失败', error, stackTrace);
    rethrow;
  } finally {
    container.dispose();
  }
}
