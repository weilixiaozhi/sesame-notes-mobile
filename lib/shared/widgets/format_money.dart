import 'package:intl/intl.dart';

import 'package:sesame_notes/utils/currency/currencies.dart';

// 金额格式：最多保留 N 位小数，移除多余 0 和末尾小数点，添加千分位
String formatMoneyCompact(
  double v, {
  int maxDecimals = 2,
  bool signed = false,
}) {
  // 千分位分组 + 去尾零由 intl NumberFormat 原生完成（固定 en_US 分组符）。
  final pattern = maxDecimals > 0 ? '#,##0.${'#' * maxDecimals}' : '#,##0';
  final numberText = NumberFormat(pattern, 'en_US').format(v.abs());
  final sign = signed ? (v < 0 ? '-' : '+') : (v < 0 ? '-' : '');
  return '$sign$numberText';
}

/// 金额和币种符号，例如 `- ¥ 72`；数字取绝对值，避免重复负号。
/// 空币种仅显示数字；[decimals] 为最大小数位并去尾零。
/// [signed] 为 true 时正数显式输出 `+`。
String formatMoneyWithCurrency(
  double value, {
  String? currencyCode,
  int decimals = 2,
  bool signed = false,
}) {
  final numberText = formatMoneyCompact(value.abs(), maxDecimals: decimals);
  final sign = value < 0 ? '-' : (signed ? '+' : '');
  if (currencyCode != null && currencyCode.isNotEmpty) {
    // 全局统一口径：币种符号与金额之间保留一个空格（¥ 72），负号也带空格
    // （- ¥ 72），让「符号 / 币种 / 数字」三段清晰分隔。数字恒按绝对值格式化，
    // 符号由外层 sign 控制，避免叠加成双负号。
    final symbol = getCurrencySymbol(currencyCode.toUpperCase());
    final signPart = sign.isNotEmpty ? '$sign ' : '';
    return '$signPart$symbol $numberText';
  }
  return '$sign$numberText';
}
