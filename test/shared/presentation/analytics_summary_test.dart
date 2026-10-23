import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/presentation/analytics_summary.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

void main() {
  group('分类环图 Top5 + 其他聚合', () {
    /// 6 个分类（金额降序），合计 2050。
    List<({String name, double total})> sixCategories() => [
      (name: '餐饮', total: 600),
      (name: '交通', total: 500),
      (name: '购物', total: 400),
      (name: '娱乐', total: 300),
      (name: '医疗', total: 200),
      (name: '教育', total: 50),
    ];

    test('超过 5 个分类：Top5 原序保留，其余聚合为「其他」且固定排最后', () {
      final donut = buildDonutCategories(
        categories: sixCategories(),
        total: 2050,
        otherLabel: '其他',
      );

      expect(donut.map((e) => e.name).toList(), [
        '餐饮',
        '交通',
        '购物',
        '娱乐',
        '医疗',
        '其他',
      ]);
      expect(donut.first.percent, closeTo(600 / 2050, 1e-9));
      expect(donut.last.isOther, isTrue, reason: '「其他」扇区使用中性灰样式');
      expect(
        donut.last.percent,
        closeTo(50 / 2050, 1e-9),
        reason: '「其他」占比按剩余分类合计计算（50/2050≈2.4%），不是被丢弃',
      );
      expect(
        donut.fold<double>(0, (sum, e) => sum + e.percent),
        closeTo(1, 1e-9),
        reason: '各扇区占比合计必须恒等于 100%，避免只画 Top5 形成「假 100%」',
      );
    });

    test('恰好 5 个分类：不追加「其他」扇区', () {
      final donut = buildDonutCategories(
        categories: sixCategories().take(5).toList(),
        total: 2000,
        otherLabel: '其他',
      );

      expect(donut, hasLength(5));
      expect(donut.any((e) => e.isOther), isFalse);
    });

    test('剩余分类合计为 0：不追加 0% 的「其他」扇区', () {
      final donut = buildDonutCategories(
        categories: [...sixCategories().take(5), (name: '教育', total: 0.0)],
        total: 2000,
        otherLabel: '其他',
      );

      expect(donut, hasLength(5));
      expect(donut.any((e) => e.isOther), isFalse);
    });

    test('总支出为 0：占比为 0，不做除法', () {
      final donut = buildDonutCategories(
        categories: [(name: '餐饮', total: 0.0)],
        total: 0,
        otherLabel: '其他',
      );

      expect(donut, hasLength(1));
      expect(donut.single.percent, 0);
    });
  });

  group('年视图按月序列截断', () {
    List<({DateTime month, double total})> yearSeries(int year) => [
      for (var month = 1; month <= 12; month++)
        (month: DateTime(year, month, 1), total: 100.0 * month),
    ];

    test('当前年：只保留到今天所在月份，未来月份不产生数据点', () {
      final series = truncateYearSeriesToCurrentMonth(
        series: yearSeries(2026),
        selectedYear: 2026,
        currentLabel: DateTime(2026, 7, 1),
      );

      expect(series, hasLength(7));
      expect(series.last.month.month, 7);
      expect(series.map((e) => e.total).toList(), [
        100,
        200,
        300,
        400,
        500,
        600,
        700,
      ]);
    });

    test('历史年：保留完整 12 个月', () {
      final series = truncateYearSeriesToCurrentMonth(
        series: yearSeries(2025),
        selectedYear: 2025,
        currentLabel: DateTime(2026, 7, 1),
      );

      expect(series, hasLength(12));
    });

    test('自定义月起始日：按账期标签月截断（今天可能属于上一个账期月）', () {
      // 8 月 5 日、月起始日 10 → 今天仍属于「7 月」账期，年视图截断到 7 月。
      final label = labelForDate(DateTime(2026, 8, 5), 10);
      final series = truncateYearSeriesToCurrentMonth(
        series: yearSeries(2026),
        selectedYear: 2026,
        currentLabel: label,
      );

      expect(label.month, 7);
      expect(series, hasLength(7));
    });
  });
}
