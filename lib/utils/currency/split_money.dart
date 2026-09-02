/// AA 指定分摊金额的币种口径换算工具（纯 Decimal，零依赖）。
///
/// 设计意图：服务端契约要求 sum(splits.amount) == native_amount（本位币口径），
/// 而编辑器输入与存量数据是原币口径；两种口径在数据库/备份/云端快照中并存，
/// 所有读取与换算统一经本工具判别，禁止各层盲乘汇率。
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
  if (fromTotal == Decimal.zero) return value;
  return roundHalfEven(
    (value.toRational() * toTotal.toRational() / fromTotal.toRational())
        .toDecimal(scaleOnInfinitePrecision: 18),
    scale: 10,
  );
}

/// 把分摊金额归一为「账本本位币」口径（服务端契约：sum(splits) == native_amount）。
///
/// 存量与多源数据存在两种口径，用合计匹配判别，绝不盲换算：
/// - 合计 == nativeAmount：已是本位币口径（新写入/云端快照），原样返回；
/// - 合计 == amount：原币口径（旧数据/编辑器输入），按隐含汇率
///   ×native/amount 换算；
/// - 两者都不匹配：脏数据，原样返回，由调用方拒绝或展示降级。
///
/// [remainderIndex] 为承接四舍五入尾差的参与人下标（支出人优先，其次最后
/// 一位参与人），保证换算后 sum(结果) == nativeAmount 精确成立。
List<Decimal> normalizeSplitsToNative({
  required List<Decimal> splits,
  required Decimal amount,
  required Decimal nativeAmount,
  required int remainderIndex,
}) {
  if (splits.isEmpty) return splits;
  final sum = sumOfSplits(splits);
  if (sum == nativeAmount) return List.of(splits);
  if (sum != amount) return List.of(splits);
  final scaled = [
    for (final v in splits) scaleSplitValue(v, amount, nativeAmount),
  ];
  return balanceSplitRemainder(
    scaled,
    total: nativeAmount,
    remainderIndex: _clampRemainderIndex(remainderIndex, scaled.length),
  );
}

/// 把分摊金额归一为「交易原币」口径（详情/编辑页展示用，与编辑器合计
/// 校验 sum == amount 对齐）。
///
/// 判定规则与 [normalizeSplitsToNative] 对称：
/// - 合计 == amount：已是原币口径，原样返回；
/// - 合计 == nativeAmount：本位币口径，按隐含汇率 ×amount/native 逆换算。
List<Decimal> normalizeSplitsToOriginal({
  required List<Decimal> splits,
  required Decimal amount,
  required Decimal nativeAmount,
  required int remainderIndex,
}) {
  if (splits.isEmpty) return splits;
  final sum = sumOfSplits(splits);
  if (sum == amount) return List.of(splits);
  if (sum != nativeAmount) return List.of(splits);
  final scaled = [
    for (final v in splits) scaleSplitValue(v, nativeAmount, amount),
  ];
  return balanceSplitRemainder(
    scaled,
    total: amount,
    remainderIndex: _clampRemainderIndex(remainderIndex, scaled.length),
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

int _clampRemainderIndex(int index, int length) {
  if (length == 0) return 0;
  return index < 0 || index >= length ? length - 1 : index;
}
