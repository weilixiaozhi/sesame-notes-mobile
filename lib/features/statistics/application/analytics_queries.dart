import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

import 'statistics_queries.dart';

/// 并发查询的错误顺序与分类、日序列、笔数和共享快照一致。
typedef _AnalyticsQueryErrors = (
  AsyncError?,
  AsyncError?,
  AsyncError?,
  AsyncError?,
);

/// 分类排行保留二级分类的标识、展示快照和区间金额。
typedef AnalyticsSubcategory = ({
  String id,
  CategoryDisplay? category,
  String name,
  double total,
});

/// 一级分类汇总及其二级明细，顺序与分类排行榜一致。
typedef AnalyticsCategoryTotal = ({
  String? id,
  String name,
  CategoryDisplay? category,
  double total,
  List<AnalyticsSubcategory> subCategories,
});

/// 趋势序列通过具体类型区分日刻度和账期月刻度。
sealed class AnalyticsSeries {
  /// 序列由应用查询构造，页面只读取明确的刻度类型。
  const AnalyticsSeries();
}

/// 周、月视图使用连续的每日金额。
final class DailyAnalyticsSeries extends AnalyticsSeries {
  /// 保存仓储补齐空白日期后的每日金额。
  const DailyAnalyticsSeries(this.points);

  final List<({DateTime day, double total})> points;
}

/// 年视图使用按账本月起始日划分的十二个账期。
final class MonthlyAnalyticsSeries extends AnalyticsSeries {
  /// 保存完整年度刻度，当前年份的展示截止位置由页面选择。
  const MonthlyAnalyticsSeries(this.points);

  final List<({DateTime month, double total})> points;
}

/// 一次查询得到的分类、趋势、笔数和总额。
class AnalyticsData {
  /// 所有数据使用同一次请求固定下来的账本与时间范围。
  const AnalyticsData({
    required this.catData,
    required this.series,
    required this.txCount,
    required this.sum,
  });

  final List<AnalyticsCategoryTotal> catData;
  final AnalyticsSeries series;
  final int txCount;
  final double sum;
}

/// 编排统计页只读查询，统一趋势与分类统计的时间边界。
class AnalyticsQueries {
  /// 通过现有统计查询入口读取数据，避免页面依赖仓储和分类映射。
  AnalyticsQueries(this._queries);

  final StatisticsQueries _queries;

  /// 并发读取所选范围，再批量解析一级、二级分类。
  Future<AnalyticsData> load({
    required String ledgerId,
    required String type,
    required AnalyticsPeriod period,
    required int selectedYear,
    required int monthStartDay,
    required DateRange current,
  }) async {
    try {
      // 具名变量保留各查询的静态类型，查询并发执行并共同等待完成。
      final (hierarchy, days, txCount, synthetic) = await (
        _queries.totalsByCategoryWithHierarchy(
          ledgerId: ledgerId,
          type: type,
          start: current.start,
          end: current.end,
        ),
        _queries.totalsByDay(
          ledgerId: ledgerId,
          type: type,
          start: current.start,
          end: current.end,
        ),
        _queries.countByTypeInRange(
          ledgerId: ledgerId,
          type: type,
          start: current.start,
          end: current.end,
        ),
        _queries.sharedSyntheticCategories(ledgerId),
      ).wait;
      final categories = await _aggregateCategories(
        hierarchy,
        synthetic,
        ledgerId: ledgerId,
      );
      return AnalyticsData(
        catData: categories,
        series: period == AnalyticsPeriod.year
            ? _monthlySeries(days, selectedYear, monthStartDay)
            : DailyAnalyticsSeries(days),
        txCount: txCount,
        sum: categories.fold<double>(0, (sum, row) => sum + row.total),
      );
    } catch (error, stackTrace) {
      // 并发查询的包装异常还原到首个原始原因，保留数据库等异常的诊断信息。
      final errors = error is ParallelWaitError<Object?, _AnalyticsQueryErrors>
          ? error.errors
          : null;
      final cause = errors?.$1 ?? errors?.$2 ?? errors?.$3 ?? errors?.$4;
      final failure = cause?.error ?? error;
      final failureStack = cause?.stackTrace ?? stackTrace;
      logger.error(
        'AnalyticsQueries',
        '读取统计失败 period=${period.name} '
            'start=${current.start.toIso8601String()} '
            'end=${current.end.toIso8601String()}',
        failure,
        failureStack,
      );
      Error.throwWithStackTrace(failure, failureStack);
    }
  }

  /// 按账期标签合并已限定范围的每日金额，不将截止日后的交易计入年图。
  MonthlyAnalyticsSeries _monthlySeries(
    List<({DateTime day, double total})> days,
    int year,
    int monthStartDay,
  ) {
    final totals = <int, Decimal>{};
    for (final row in days) {
      final label = labelForDate(row.day, monthStartDay);
      // 用十进制累计每日金额，避免跨日相加引入二进制浮点尾差。
      final amount = Decimal.parse(row.total.toString());
      totals.update(label.month, (sum) => sum + amount, ifAbsent: () => amount);
    }
    return MonthlyAnalyticsSeries([
      for (var month = 1; month <= 12; month++)
        (
          month: DateTime(year, month),
          total: (totals[month] ?? Decimal.zero).toDouble(),
        ),
    ]);
  }

  /// 合并共享分类快照和本地分类，保持未分类与二级分类的现有展示顺序。
  Future<List<AnalyticsCategoryTotal>> _aggregateCategories(
    List<CategoryHierarchyTotal> hierarchy,
    Map<String, CategoryDisplay> synthetic, {
    required String ledgerId,
  }) async {
    final realIds = <String>{};
    for (final row in hierarchy) {
      if (row.id != null && !synthetic.containsKey(row.id)) {
        realIds.add(row.id!);
      }
      final topId = row.parentId ?? row.id;
      if (topId != null && !synthetic.containsKey(topId)) realIds.add(topId);
    }
    // 同一次批量查询解析父子分类，共享账本的分类快照优先。
    final categories = await _queries.categoriesByIds(
      realIds,
      ledgerId: ledgerId,
    );

    /// 空标识表示未分类，其余优先读取共享分类快照。
    CategoryDisplay? categoryOf(String? id) =>
        id == null ? null : (synthetic[id] ?? categories[id]);

    final groups = <String?, AnalyticsCategoryTotal>{};
    for (final row in hierarchy) {
      final topId = row.parentId ?? row.id;
      final group = groups.putIfAbsent(
        topId,
        () => (
          id: topId,
          name: categoryOf(topId)?.name ?? row.name,
          category: categoryOf(topId),
          total: 0.0,
          subCategories: <AnalyticsSubcategory>[],
        ),
      );
      groups[topId] = (
        id: group.id,
        name: group.name,
        category: group.category,
        total: group.total + row.total,
        subCategories: row.parentId == null
            ? group.subCategories
            : [
                ...group.subCategories,
                (
                  id: row.id!,
                  category: categoryOf(row.id),
                  name: categoryOf(row.id)?.name ?? row.name,
                  total: row.total,
                ),
              ],
      );
    }
    return groups.values.toList()
      ..sort((left, right) => right.total.compareTo(left.total));
  }
}

/// 页面只依赖统计编排入口，测试可单独替换统计数据来源。
final analyticsQueriesProvider = Provider<AnalyticsQueries>(
  (ref) => AnalyticsQueries(ref.watch(statisticsQueriesProvider)),
);
