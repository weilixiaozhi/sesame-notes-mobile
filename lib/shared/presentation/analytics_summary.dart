/// 统计页的年序列截断与分类环图聚合，输入输出均保持原金额单位。
library;

import 'package:sesame_notes/shared/widgets/category_donut_chart.dart';

/// 年视图按月序列截断到当前月：未来月份不产生数据点。
///
/// 仅当 [selectedYear] 就是 [currentLabel] 所在账期年时按月份截断；
/// 历史年份整体保留，让图表呈现完整 12 个月的对比。
/// [currentLabel] 由 labelForDate 生成：自定义月起始日时今天可能属于上一个账期月。
List<({DateTime month, double total})> truncateYearSeriesToCurrentMonth({
  required List<({DateTime month, double total})> series,
  required int selectedYear,
  required DateTime currentLabel,
}) {
  if (selectedYear != currentLabel.year) return series;
  return [
    for (final point in series)
      if (point.month.month <= currentLabel.month) point,
  ];
}

/// 分类环图扇区：分类超过 5 个时把其余分类聚合为「其他」。
///
/// [categories] 必须已按金额降序；[total] 为全部支出合计。
/// 只画 Top5 时 fl_chart 会把部分数据拉满整圆形成「假 100%」，因此追加
/// 「其他」扇区让各扇区占比合计恒等于 100%，与下方完整排行榜口径一致。
/// 「其他」占比按剩余分类合计计算，固定排在最后（即使金额大于第 5 名），
/// 剩余合计为 0 时不追加；[total] 为 0 时各扇区占比为 0，不做除法。
List<DonutCategory> buildDonutCategories({
  required List<({String name, double total})> categories,
  required double total,
  required String otherLabel,
}) {
  final restTotal = categories.skip(5).fold<double>(0, (a, c) => a + c.total);
  return [
    for (final category in categories.take(5))
      DonutCategory(
        name: category.name,
        percent: total == 0 ? 0 : category.total / total,
      ),
    if (restTotal > 0)
      DonutCategory(
        name: otherLabel,
        percent: total == 0 ? 0 : restTotal / total,
        isOther: true,
      ),
  ];
}
