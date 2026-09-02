/// 规范化 Decimal 金额工具。
///
/// 客户端 Drift 与 API 必须使用同一金额表示：规范化 Decimal 字符串。
/// 规则：
/// - 只允许十进制普通写法，无前导零/尾零/指数/千分位/空白；
/// - 零固定为 "0"；小数不得以 0 结尾；禁止 "-0"；
/// - 交易金额 ≤28 位整数 + ≤10 位小数（正数）；汇率 ≤20 位整数 + ≤18 位小数；
/// - 中间精度 ≥18 位小数，最终金额 round-half-even 舍入后移除末尾零。
library;

import 'package:decimal/decimal.dart';

/// 解析规范化 decimal 字符串；非法返回 null。
Decimal? parseDecimal(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  return Decimal.tryParse(raw);
}

/// round-half-even 舍入到 [scale] 位小数。
///
/// decimal 3.x 只有 half-up（`round`），契约要求 round-half-even
/// （财务惯例：恰好 .5 时舍入到偶数位），此处手工实现：
/// 移位到整数域 → 取绝对值 → 截断 → 分数恰为 0.5 时看整数部分奇偶。
Decimal roundHalfEven(Decimal value, {int scale = 10}) {
  // scale=0 同样走 half-even（不能回退到 half-up 的 round()）。
  final shifted = value.shift(scale);
  final sign = shifted.sign;
  final absShifted = shifted.abs();
  final truncated = absShifted.truncate();
  final frac = absShifted - truncated;
  final half = Decimal.parse('0.5');
  final up = frac > half || (frac == half && !truncated.toBigInt().isEven);
  final rounded = (up ? truncated + Decimal.one : truncated);
  final result = rounded.shift(-scale);
  return sign < 0 ? -result : result;
}

/// 把 [Decimal] 输出为规范化字符串。
String normalizeDecimal(Decimal value, {int scale = 10}) {
  var rounded = roundHalfEven(value, scale: scale);
  var text = rounded.toString();
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }
  if (text == '-0' || text == '-0.') text = '0';
  return text;
}

/// 金额乘法并规范舍入：native = amount × rate，round-half-even 到 [scale] 位。
///
/// 任一侧解析失败或 rate ≤ 0 时返回 null（缺失即缺失，绝不静默按 1.0 折算）。
String? multiplyDecimalStrings(String amount, String rate, {int scale = 10}) {
  final a = Decimal.tryParse(amount);
  final r = Decimal.tryParse(rate);
  if (a == null || r == null || r <= Decimal.zero) return null;
  return normalizeDecimal(a * r, scale: scale);
}

/// 校验字符串是否为规范化 decimal（写入/同步边界使用，非法即失败）。
bool isNormalizedDecimal(
  String raw, {
  int intDigits = 28,
  int fracDigits = 10,
}) {
  final d = Decimal.tryParse(raw);
  if (d == null) return false;
  final text = normalizeDecimal(d, scale: fracDigits);
  // 规范化往返一致才算合法（拒绝 "01"、"1.20"、"1e3"、"-0" 等非规范写法）。
  if (text != raw) return false;
  final parts = raw.split('.');
  final intPart = parts[0];
  if (intPart.startsWith('-')) {
    if (intPart.length - 1 > intDigits) return false;
  } else {
    if (intPart.length > intDigits) return false;
  }
  if (parts.length > 1 && parts[1].length > fracDigits) return false;
  return true;
}
