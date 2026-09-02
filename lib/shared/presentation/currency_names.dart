/// 币种显示名的本地化出口（唯一需要 l10n 上下文的币种格式化）。
///
/// 设计意图：[utils/currency/currencies.dart] 只保留 code / 英文名 / 符号等
/// 纯数值与 key 转换；本地化名覆盖依赖 [AppLocalizations]，属展示层职责，
/// 因此搬到这里——utils 由此保持纯 Dart 叶子，纯逻辑复用与单测不再需要
/// Flutter / l10n 上下文。
library;

import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';

/// 获取本地化的货币信息列表。
///
/// 名称优先用本地化覆盖（主流币种，见 [_buildNameMap]），
/// 长尾币种回退英文名（[currencyEnglishName]）。
List<CurrencyInfo> getCurrencies(BuildContext context) {
  final overrides = _buildNameMap(context);
  return kCurrencyCodes
      .map(
        (code) =>
            CurrencyInfo(code, overrides[code] ?? currencyEnglishName(code)),
      )
      .toList();
}

/// 「名称 (CODE)」形态的完整展示文案。
String displayCurrency(String code, BuildContext context) {
  final name = getCurrencyName(code, context);
  return '$name ($code)';
}

/// 获取指定货币代码的本地化名称（无本地化覆盖时回退英文名，再回退 code）。
String getCurrencyName(String code, BuildContext context) {
  final overrides = _buildNameMap(context);
  final upper = code.toUpperCase();
  return overrides[upper] ?? currencyEnglishName(upper);
}

/// l10n 本地化名称覆盖映射（仅主流币种；长尾币种用英文名兜底，无需在此登记）。
Map<String, String> _buildNameMap(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  // 全部币种走 arb（三语）；缺翻译由 l10n template（en）兜底为英文。
  return {
    'CNY': l10n.currencyCNY,
    'JPY': l10n.currencyJPY,
    'KRW': l10n.currencyKRW,
    'HKD': l10n.currencyHKD,
    'TWD': l10n.currencyTWD,
    'MOP': l10n.currencyMOP,
    'MNT': l10n.currencyMNT,
    'KPW': l10n.currencyKPW,
    'SGD': l10n.currencySGD,
    'MYR': l10n.currencyMYR,
    'THB': l10n.currencyTHB,
    'IDR': l10n.currencyIDR,
    'PHP': l10n.currencyPHP,
    'VND': l10n.currencyVND,
    'MMK': l10n.currencyMMK,
    'KHR': l10n.currencyKHR,
    'LAK': l10n.currencyLAK,
    'BND': l10n.currencyBND,
    'INR': l10n.currencyINR,
    'PKR': l10n.currencyPKR,
    'BDT': l10n.currencyBDT,
    'LKR': l10n.currencyLKR,
    'NPR': l10n.currencyNPR,
    'BTN': l10n.currencyBTN,
    'MVR': l10n.currencyMVR,
    'AFN': l10n.currencyAFN,
    'KZT': l10n.currencyKZT,
    'UZS': l10n.currencyUZS,
    'TJS': l10n.currencyTJS,
    'TMT': l10n.currencyTMT,
    'KGS': l10n.currencyKGS,
    'AED': l10n.currencyAED,
    'SAR': l10n.currencySAR,
    'ILS': l10n.currencyILS,
    'TRY': l10n.currencyTRY,
    'QAR': l10n.currencyQAR,
    'KWD': l10n.currencyKWD,
    'BHD': l10n.currencyBHD,
    'OMR': l10n.currencyOMR,
    'JOD': l10n.currencyJOD,
    'LBP': l10n.currencyLBP,
    'IQD': l10n.currencyIQD,
    'IRR': l10n.currencyIRR,
    'YER': l10n.currencyYER,
    'SYP': l10n.currencySYP,
    'GEL': l10n.currencyGEL,
    'AMD': l10n.currencyAMD,
    'AZN': l10n.currencyAZN,
    'EUR': l10n.currencyEUR,
    'GBP': l10n.currencyGBP,
    'CHF': l10n.currencyCHF,
    'SEK': l10n.currencySEK,
    'NOK': l10n.currencyNOK,
    'DKK': l10n.currencyDKK,
    'PLN': l10n.currencyPLN,
    'CZK': l10n.currencyCZK,
    'HUF': l10n.currencyHUF,
    'RUB': l10n.currencyRUB,
    'BYN': l10n.currencyBYN,
    'UAH': l10n.currencyUAH,
    'RON': l10n.currencyRON,
    'BGN': l10n.currencyBGN,
    'RSD': l10n.currencyRSD,
    'ISK': l10n.currencyISK,
    'MDL': l10n.currencyMDL,
    'ALL': l10n.currencyALL,
    'MKD': l10n.currencyMKD,
    'BAM': l10n.currencyBAM,
    'GIP': l10n.currencyGIP,
    'USD': l10n.currencyUSD,
    'CAD': l10n.currencyCAD,
    'MXN': l10n.currencyMXN,
    'GTQ': l10n.currencyGTQ,
    'HNL': l10n.currencyHNL,
    'NIO': l10n.currencyNIO,
    'CRC': l10n.currencyCRC,
    'PAB': l10n.currencyPAB,
    'DOP': l10n.currencyDOP,
    'CUP': l10n.currencyCUP,
    'JMD': l10n.currencyJMD,
    'TTD': l10n.currencyTTD,
    'BSD': l10n.currencyBSD,
    'BBD': l10n.currencyBBD,
    'BZD': l10n.currencyBZD,
    'HTG': l10n.currencyHTG,
    'KYD': l10n.currencyKYD,
    'AWG': l10n.currencyAWG,
    'BMD': l10n.currencyBMD,
    'BRL': l10n.currencyBRL,
    'ARS': l10n.currencyARS,
    'CLP': l10n.currencyCLP,
    'COP': l10n.currencyCOP,
    'PEN': l10n.currencyPEN,
    'UYU': l10n.currencyUYU,
    'PYG': l10n.currencyPYG,
    'BOB': l10n.currencyBOB,
    'VES': l10n.currencyVES,
    'GYD': l10n.currencyGYD,
    'SRD': l10n.currencySRD,
    'AUD': l10n.currencyAUD,
    'NZD': l10n.currencyNZD,
    'FJD': l10n.currencyFJD,
    'PGK': l10n.currencyPGK,
    'SBD': l10n.currencySBD,
    'TOP': l10n.currencyTOP,
    'VUV': l10n.currencyVUV,
    'WST': l10n.currencyWST,
    'ZAR': l10n.currencyZAR,
    'EGP': l10n.currencyEGP,
    'NGN': l10n.currencyNGN,
    'KES': l10n.currencyKES,
    'GHS': l10n.currencyGHS,
    'MAD': l10n.currencyMAD,
    'DZD': l10n.currencyDZD,
    'TND': l10n.currencyTND,
    'LYD': l10n.currencyLYD,
    'ETB': l10n.currencyETB,
    'UGX': l10n.currencyUGX,
    'TZS': l10n.currencyTZS,
    'RWF': l10n.currencyRWF,
    'MUR': l10n.currencyMUR,
    'BWP': l10n.currencyBWP,
    'NAD': l10n.currencyNAD,
    'ZMW': l10n.currencyZMW,
    'MWK': l10n.currencyMWK,
    'MZN': l10n.currencyMZN,
    'AOA': l10n.currencyAOA,
    'CDF': l10n.currencyCDF,
    'GMD': l10n.currencyGMD,
    'GNF': l10n.currencyGNF,
    'LRD': l10n.currencyLRD,
    'SLE': l10n.currencySLE,
    'SDG': l10n.currencySDG,
    'SSP': l10n.currencySSP,
    'SOS': l10n.currencySOS,
    'DJF': l10n.currencyDJF,
    'ERN': l10n.currencyERN,
    'BIF': l10n.currencyBIF,
    'CVE': l10n.currencyCVE,
    'STN': l10n.currencySTN,
    'SCR': l10n.currencySCR,
    'KMF': l10n.currencyKMF,
    'LSL': l10n.currencyLSL,
    'SZL': l10n.currencySZL,
    'MGA': l10n.currencyMGA,
    'MRU': l10n.currencyMRU,
  };
}
