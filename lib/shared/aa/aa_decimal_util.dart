/// AA 分摊 Decimal 工具。
///
/// 设计意图:分摊算法 + 支出人兜底余数依赖 Decimal 全程计算,
/// 避免浮点误差(如 10.00 / 3 = 3.333... 在 double 下累计失真)。
/// 本工具集中封装 Decimal 入口转换 + 人均分摊 + 余数兜底逻辑,
/// 服务层 [AaStatisticsService] 与 UI 层(AaEditPage 合计校验)共用。
library;

import 'package:decimal/decimal.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';

/// Decimal → double(仅在最终展示模型调用)。
double toDouble(Decimal d) {
  return double.parse(d.toString());
}

/// 人均分摊:每人应摊 = floor(实付 × 100 / n) / 100。
///
/// 返回每人应摊金额列表(顺序与参与人列表对齐),以及"支出人实付差"
/// (实付 - sum(每人应摊))归支出人,保证 sum(应摊) == 实付。
///
/// [payerIndex] 支出人在参与人列表中的下标;为 null 或越界时归第 0 个
/// (兜底,正常调用方都会传有效下标)。
///
/// 例:3 人 10.00 → [3.33, 3.33, 3.34](支出人取最后位,余数 0.01 归支出人)。
List<Decimal> splitEvenly({
  required Decimal total,
  required int participantCount,
  int? payerIndex,
}) {
  if (participantCount <= 0) {
    throw ArgumentError.value(
      participantCount,
      'participantCount',
      '参与人数必须 > 0',
    );
  }
  // 转为"分"为单位(int)计算,避免 Decimal 除法精度问题。
  // 仅基础份额取整；原 total 保留全部小数精度，整数域使用 BigInt 避免大额溢出。
  final totalCents = (total * Decimal.fromInt(100)).toBigInt();
  final perPersonCents = totalCents ~/ BigInt.from(participantCount);

  // 每人基础应摊(分 → Decimal)
  // Decimal / Decimal 返回 Rational,需 .toDecimal() 转回 Decimal。
  final perPerson = (Decimal.fromBigInt(perPersonCents) / Decimal.fromInt(100))
      .toDecimal();
  final splits = List<Decimal>.filled(participantCount, perPerson);

  // 余数(分)归支出人,保证 sum(应摊) == 实付。
  final idx =
      (payerIndex == null || payerIndex < 0 || payerIndex >= participantCount)
      ? 0
      : payerIndex;
  // 基础份额仍按分计算，完整 Decimal 尾差统一归支出人，不能先丢掉分以下精度。
  return balanceSplitRemainder(splits, total: total, remainderIndex: idx);
}

/// 校验指定分摊金额合计与实付精确相等。
///
/// 返回 true 表示校验通过。
bool validateSplitsTotal({
  required Decimal total,
  required List<Decimal> splits,
}) {
  var sum = Decimal.zero;
  for (final v in splits) {
    sum = sum + v;
  }
  return sum == total;
}
