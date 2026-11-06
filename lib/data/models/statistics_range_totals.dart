/// 分类层级汇总保留所属账本解析出的父子关系和展示字段。
typedef CategoryHierarchyTotal = ({
  String? id,
  String name,
  String? icon,
  String? parentId,
  int level,
  double total,
});

/// 同一交易快照产生的分类、每日金额、笔数和总额。
class StatisticsRangeTotals {
  /// 金额在仓储内使用十进制累计，仅在结果边界转换为显示数值。
  const StatisticsRangeTotals({
    required this.categories,
    required this.days,
    required this.txCount,
    required this.total,
  });

  final List<CategoryHierarchyTotal> categories;
  final List<({DateTime day, double total})> days;
  final int txCount;
  final double total;
}
