/// 分摊落库与同步统一为账本本位币；编辑和展示边界显式换算交易原币。
library;

import 'package:decimal/decimal.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';

/// 分摊金额合计。
Decimal sumOfSplits(List<Decimal> splits) {
  var sum = Decimal.zero;
  for (final v in splits) {
    sum = sum + v;
  }
  return sum;
}

/// 单个分摊值按比例缩放并四舍五入到中间精度。
///
/// 用 Rational 中间运算避免先除后乘的精度损失；scale 10 与数据库
/// native_amount 精度对齐，最终由调用方做尾差补齐。
Decimal scaleSplitValue(Decimal value, Decimal fromTotal, Decimal toTotal) {
  if (fromTotal <= Decimal.zero) throw const FormatException('分摊来源金额必须大于零');
  return roundHalfEven(
    (value.toRational() * toTotal.toRational() / fromTotal.toRational())
        .toDecimal(scaleOnInfinitePrecision: 18),
    scale: 10,
  );
}

/// 按调用方明确的来源、目标金额换算，输入不匹配时拒绝猜测币种口径。
List<Decimal> convertSplits({
  required List<Decimal> splits,
  required Decimal fromTotal,
  required Decimal toTotal,
  required int remainderIndex,
}) {
  if (splits.isEmpty) return splits;
  if (fromTotal <= Decimal.zero ||
      toTotal < Decimal.zero ||
      splits.any((value) => value < Decimal.zero) ||
      sumOfSplits(splits) != fromTotal) {
    throw const FormatException('分摊合计与来源金额不一致');
  }
  return balanceSplitRemainder(
    [for (final value in splits) scaleSplitValue(value, fromTotal, toTotal)],
    total: toTotal,
    remainderIndex: remainderIndex,
  );
}

/// 修正分摊尾差：把 sum(值) 与 [total] 的差全部记到 [remainderIndex]，
/// 使换算后的合计精确等于 [total]。
List<Decimal> balanceSplitRemainder(
  List<Decimal> values, {
  required Decimal total,
  required int remainderIndex,
}) {
  final out = List<Decimal>.of(values);
  if (out.isEmpty) return out;
  final idx = _clampRemainderIndex(remainderIndex, out.length);
  var sum = Decimal.zero;
  for (final v in out) {
    sum = sum + v;
  }
  out[idx] = out[idx] + (total - sum);
  return out;
}

/// 非空分摊列表的非法尾差索引统一回落到最后一项。
int _clampRemainderIndex(int index, int length) {
  return index < 0 || index >= length ? length - 1 : index;
}
