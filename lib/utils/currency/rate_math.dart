/// 多币种折算与汇率展示的纯计算规则，不读取外部数据。
/// 方向约定:EffectiveRate.rate = 「1 quote = rate base」(decimal 字符串)。
/// 红线:汇率缺失就是缺失,绝不静默回落 1.0。
library;

import 'package:sesame_notes/utils/currency/decimal_money.dart';

class EffectiveRate {
  final String rate;
  final bool manual;
  final String? rateDate; // 自动来源的数据日期;手动为 null
  const EffectiveRate({
    required this.rate,
    required this.manual,
    this.rateDate,
  });
}

/// 输入及其倒数必须为有限正数，才能用于汇率换向。
bool isInvertibleRate(num rate) =>
    rate.isFinite && rate > 0 && (1 / rate).isFinite;

/// 汇率展示占位符：汇率缺失或非法时统一显示该字符，不展示 0/1 的伪汇率。
const String kRatePlaceholder = '—';

/// 汇率输入校验：必须是可解析的有限正数，否则禁止落库。
///
/// 覆盖编辑器无法拦截的粘贴/程序回填路径：'0'、'NaN'、'Infinity'、
/// '-Infinity'、'1e999'（double 溢出为 Infinity）都必须拒绝。
bool isValidRateInput(String raw) {
  final value = double.tryParse(raw.trim());
  return value != null && value.isFinite && value > 0;
}

/// 汇率展示口径：6 位有效数字；无法解析的原始字符串原样返回。
String formatRate6(String rate) {
  final value = double.tryParse(rate);
  if (value == null) return rate;
  return value.toStringAsPrecision(6);
}

/// 反向参考文案「1 base ≈ ? quote」：有效汇率取 6 位有效数字倒数，
/// 无效（含缓存里的 Infinity / NaN / 1e999 / 5e-324 这类倒数溢出值）显示占位符。
String formatInverseRateHint(String rawRate) {
  final parsed = double.tryParse(rawRate.trim());
  return (parsed != null && isInvertibleRate(parsed))
      ? (1 / parsed).toStringAsPrecision(6)
      : kRatePlaceholder;
}

/// 倒数:输入「1 base = x quote」,输出「1 quote = ? base」字符串(12 位有效数字)。
String invertRate(num oneBaseEqualsXQuote) {
  if (!isInvertibleRate(oneBaseEqualsXQuote)) {
    throw ArgumentError.value(
      oneBaseEqualsXQuote,
      'oneBaseEqualsXQuote',
      '汇率及其倒数必须为有限正数',
    );
  }
  return (1 / oneBaseEqualsXQuote).toStringAsPrecision(12);
}

/// 合成有效汇率:手动 > 最新自动;两边都没有的 quote 不出现在结果里。
Map<String, EffectiveRate> mergeEffectiveRates({
  required List<({String quote, String rate, String rateDate})> autoRates,
  required List<({String quote, String rate})> overrides,
}) {
  final result = <String, EffectiveRate>{};
  for (final a in autoRates) {
    result[a.quote.toUpperCase()] = EffectiveRate(
      rate: a.rate,
      manual: false,
      rateDate: a.rateDate,
    );
  }
  for (final o in overrides) {
    result[o.quote.toUpperCase()] = EffectiveRate(rate: o.rate, manual: true);
  }
  return result;
}

/// 交易级多币种折算（规范化 Decimal 字符串版）：
/// native = amount × rate，round-half-even 到 10 位小数后规范化。
/// 交易币种 == 本位币 → 直接 amount（rate 1，不查表）；
/// 缺失 / 非法 / 非正 rate → 返回 null（绝不静默按 1.0 入账）。
String? computeNativeAmountDecimal({
  required String amount,
  required String txCurrency,
  required String ledgerBase,
  required Map<String, EffectiveRate> rates,
}) {
  if (txCurrency.toUpperCase() == ledgerBase.toUpperCase()) return amount;
  final er = rates[txCurrency.toUpperCase()];
  if (er == null) return null;
  return multiplyDecimalStrings(amount, er.rate, scale: 10);
}
