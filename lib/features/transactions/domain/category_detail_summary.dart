/// 分类详情的金额汇总与日期分组口径：纯函数层，不依赖 UI。
///
/// 设计意图：分类汇总页把一级分类与其二级分类的交易平铺在同一列表里，
/// 「总额/平均」「按日期分组 + 当日小计」必须与该列表口径完全一致，
/// 页面与测试共同使用相同的汇总和分组规则。
library;

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';

/// 单笔交易的汇总金额：优先折本位币金额（nativeAmount），为空时回退原币金额。
///
/// 金额为规范化 decimal 字符串，解析失败兜底 0，避免单条脏数据让整组汇总崩掉。
Decimal categoryDetailAmountOf(TransactionDisplay transaction) {
  final raw = transaction.nativeAmount.isNotEmpty
      ? transaction.nativeAmount
      : transaction.amount;
  return Decimal.tryParse(raw) ?? Decimal.zero;
}

/// 分类详情汇总：总额按 Decimal 累加（避免浮点尾差），平均 = 总额 / 笔数。
///
/// 无交易时总额与平均都为 0（不做除零）。
({int totalCount, double totalAmount, double averageAmount})
summarizeCategoryDetail(List<TransactionDisplay> transactions) {
  final totalCount = transactions.length;
  final totalAmountDecimal = transactions.fold<Decimal>(
    Decimal.zero,
    (sum, transaction) => sum + categoryDetailAmountOf(transaction),
  );
  return (
    totalCount: totalCount,
    totalAmount: totalAmountDecimal.toDouble(),
    averageAmount: totalCount > 0
        ? totalAmountDecimal.toDouble() / totalCount
        : 0.0,
  );
}

/// 某一天的交易分组：日期键 + 当日小计 + 该日交易（保持传入顺序）。
class CategoryDetailDayGroup {
  const CategoryDetailDayGroup({
    required this.dateKey,
    required this.expense,
    required this.transactions,
  });

  /// 本地时区 yyyy-MM-dd，与 [DaySectionHeader] 的日期文案口径一致。
  final String dateKey;

  /// 当日支出小计（Decimal 累加后转 double）。
  final double expense;

  /// 当日全部交易：父子分类交易只要同一天就合并进同一组。
  final List<TransactionDisplay> transactions;
}

/// 按日期分组：同一平铺列表只按日期分组，父子分类交易合并统计。
///
/// [isAmountSort] 为真时保持调用方传入的金额排序，只切日期标题顺序不动
/// 组内顺序；否则日期键按 [timeDesc] 升/降序排列（与时间排序一致）。
List<CategoryDetailDayGroup> groupCategoryDetailByDate(
  List<TransactionDisplay> transactions, {
  required bool isAmountSort,
  required bool timeDesc,
}) {
  final dateFormat = DateFormat('yyyy-MM-dd');
  final dateOrder = <String>[];
  final dateGroups = <String, List<TransactionDisplay>>{};
  for (final transaction in transactions) {
    final dateKey = dateFormat.format(transaction.happenedAt.toLocal());
    if (!dateGroups.containsKey(dateKey)) {
      dateGroups[dateKey] = [];
      dateOrder.add(dateKey);
    }
    dateGroups[dateKey]!.add(transaction);
  }
  if (!isAmountSort) {
    dateOrder.sort(
      timeDesc ? (a, b) => b.compareTo(a) : (a, b) => a.compareTo(b),
    );
  }

  return [
    for (final dateKey in dateOrder)
      CategoryDetailDayGroup(
        dateKey: dateKey,
        // 当日小计同样按 Decimal 累加：父子分类交易在同一天时合并为一个数。
        expense: dateGroups[dateKey]!
            .fold<Decimal>(
              Decimal.zero,
              (sum, transaction) => sum + categoryDetailAmountOf(transaction),
            )
            .toDouble(),
        transactions: dateGroups[dateKey]!,
      ),
  ];
}
