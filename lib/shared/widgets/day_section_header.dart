import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'format_money.dart';
import 'list_section_header.dart';

/// 日期分组标题组件
/// 全局仅支出模式，只显示当日支出合计
class DaySectionHeader extends StatelessWidget {
  final String dateText; // yyyy-MM-dd
  final double expense;

  /// 账本本位币代码（ISO 4217），用于在日支出汇总前拼上正确的货币符号。
  /// 为 null 时只显示纯数字。
  final String? currencyCode;

  /// 日期与日小计和所属明细行共用水平边距。
  final double horizontalPadding;
  const DaySectionHeader({
    super.key,
    required this.dateText,
    required this.expense,
    this.currencyCode,
    this.horizontalPadding = AppDimens.p12,
  });

  @override
  Widget build(BuildContext context) {
    String getWeekday(String yyyyMMdd) {
      try {
        final dt = DateTime.parse(yyyyMMdd);
        final l10n = AppLocalizations.of(context);
        switch (dt.weekday) {
          case DateTime.monday:
            return l10n.commonWeekdayMonday;
          case DateTime.tuesday:
            return l10n.commonWeekdayTuesday;
          case DateTime.wednesday:
            return l10n.commonWeekdayWednesday;
          case DateTime.thursday:
            return l10n.commonWeekdayThursday;
          case DateTime.friday:
            return l10n.commonWeekdayFriday;
          case DateTime.saturday:
            return l10n.commonWeekdaySaturday;
          case DateTime.sunday:
            return l10n.commonWeekdaySunday;
          default:
            return '';
        }
      } catch (_) {
        return '';
      }
    }

    // 支出小计统一走 formatMoneyWithCurrency，确保货币符号紧贴金额；
    // currencyCode 为 null 时显示无符号纯数字，确保缺少币种信息时仍可展示金额。
    String fmt(double v) =>
        v == 0 ? '' : formatMoneyWithCurrency(v, currencyCode: currencyCode);
    final week = getWeekday(dateText);
    final l10n = AppLocalizations.of(context);
    // 日期、星期与日支出汇总都沿用 ListSectionHeader 的统一样式，
    // 与其他业务域列表分组标题同字号，行内不再各自调小字号。
    return ListSectionHeader(
      horizontalPadding: horizontalPadding,
      title: dateText,
      secondaryTitle: week.isEmpty ? null : week,
      trailing: fmt(expense).isEmpty
          ? null
          : Text('${l10n.homeExpense} ${fmt(expense)}'),
    );
  }
}
