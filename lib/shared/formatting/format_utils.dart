/// 格式化工具函数
///
/// 包含各种数据格式化的工具函数
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/date/week_math.dart';

/// 翻译账本名称
///
/// 如果账本名称是 "Default Ledger"，则返回国际化后的名称
/// 否则返回原始名称
String translateLedgerName(BuildContext context, String ledgerName) {
  final l10n = AppLocalizations.of(context);

  // 处理默认账本名称的多种形式
  if (ledgerName == 'Default Ledger' ||
      ledgerName == '默认账本' ||
      ledgerName == 'デフォルト家計簿' ||
      ledgerName == '기본 가계부' ||
      ledgerName == 'Standard-Kontenbuch' ||
      ledgerName == 'Livre par Défaut' ||
      ledgerName == 'Libro Predeterminado' ||
      ledgerName == '預設帳本') {
    return l10n.ledgersDefaultLedgerName;
  }

  return ledgerName;
}

/// 月份标签（不含年份）：首页与统计页共用同一出口，避免两处各写一套补零/语言分支逻辑。
///
/// 设计意图：英文用 `JAN..DEC` 三字母缩写（如 `JUL`），中文/韩文补零为
/// 两位数（如 `01月`），两处永远一致，且英文最终呈现为 `JUL · 2026` 这种样式。
String monthLabel(BuildContext context, int month) {
  // 英文统一用 JAN..DEC 三字母缩写：产品形态要求，与中文「月」、韩文「월」并列展示。
  if (Localizations.localeOf(context).languageCode == 'en') {
    const en = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return en[month - 1];
  }
  // 中文/韩文走 homeMonth 模板并补零为两位数（如 01月）
  return AppLocalizations.of(
    context,
  ).homeMonth(month.toString().padLeft(2, '0'));
}

/// 中文账期按年、月顺序展示；英文保留月份缩写与年份。
String monthYearLabel(BuildContext context, int month, int year) {
  final l10n = AppLocalizations.of(context);
  if (Localizations.localeOf(context).languageCode == 'zh') {
    return '${l10n.homeYear(year)}${l10n.homeMonth(month.toString())}';
  }
  return '${monthLabel(context, month)} · ${l10n.homeYear(year)}';
}

/// 周标题展示实际周一至周日；跨月保留月份，跨年保留双方年份。
String weekRangeLabel(BuildContext context, DateTime selectedDate) {
  final start = mondayOf(selectedDate);
  final end = DateTime(start.year, start.month, start.day + 6);
  final locale = Localizations.localeOf(context);
  final localeName = locale.toString();
  final full = DateFormat.yMMMd(localeName);
  if (start.year != end.year) {
    return '${full.format(start)}–${full.format(end)}';
  }
  if (locale.languageCode == 'zh') {
    final endFormat = start.month == end.month
        ? DateFormat.d(localeName)
        : DateFormat.MMMd(localeName);
    return '${full.format(start)}–${endFormat.format(end)}';
  }
  return '${DateFormat.MMMd(localeName).format(start)} – ${full.format(end)}';
}
