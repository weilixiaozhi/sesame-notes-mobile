import 'package:flutter/material.dart';

import 'package:sesame_notes/utils/currency/currencies.dart';

/// 币种展示行，例如 CNY (¥)。
/// [flexible] 使用省略号，需父级提供有界宽度；否则裁剪溢出文本。
Widget currencyFlagLabel(
  String currencyCode, {
  TextStyle? textStyle,
  bool flexible = false,
}) {
  final code = currencyCode.toUpperCase();
  // 拼装「ISO + (符号)」两段，符号用半角括号包裹以与 ISO 区分。
  final label = '$code (${getCurrencySymbol(currencyCode)})';
  return Text(
    label,
    style: textStyle,
    maxLines: 1,
    overflow: flexible ? TextOverflow.ellipsis : TextOverflow.clip,
  );
}

/// 币种符号列固定宽度，使不同长度符号后的名称对齐。
const double kCurrencySymbolColumnWidth = 56;

/// 左对齐的币种符号列；长符号单行缩放显示，名称列的起点保持一致。
Widget currencySymbolColumn(String currencyCode, {TextStyle? style}) {
  return SizedBox(
    width: kCurrencySymbolColumnWidth,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        getCurrencySymbol(currencyCode),
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    ),
  );
}
