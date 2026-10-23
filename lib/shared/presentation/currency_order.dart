import 'dart:ui' show Locale;

import '../../utils/currency/currencies.dart';

/// 将系统地区转换为排序所需的纯数据，保留繁体中文区域与账本置顶规则。
List<CurrencyInfo> orderCurrenciesForLocale(
  List<CurrencyInfo> source,
  Locale locale, {
  List<String> pinned = const [],
}) => orderCurrencies(
  source,
  languageCode: locale.languageCode,
  countryCode: locale.countryCode ?? '',
  pinned: pinned,
);
