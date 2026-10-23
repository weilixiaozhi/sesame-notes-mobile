import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_date_field.dart';
import 'package:sesame_notes/shared/widgets/date_wheel_column.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 单端点公农历输入，切换历法保留实际日期。
class DayDateField extends StatelessWidget {
  const DayDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.requiresConfirmation = false,
    this.stacked = false,
    this.isPresent = false,
    this.onPresent,
  });
  final String label;
  final OriginalDate value;
  final ValueChanged<OriginalDate> onChanged;
  final bool enabled;
  final bool requiresConfirmation;
  final bool stacked;
  final bool isPresent;
  final VoidCallback? onPresent;

  /// 日期库及系统弹窗异常保留当前输入并给出可重试提示。
  Future<void> _pick(BuildContext context) async {
    try {
      OriginalDate? result;
      if (value.calendarType == DayCalendarType.solar) {
        // 原始公历字段可作为滚轮初始值；选择确认前不改写损坏投影。
        DateOnly date;
        try {
          date =
              value.solarDate ??
              DateOnly(
                value.originalYear,
                value.originalMonth,
                value.originalDay,
              );
        } on DayDateException {
          // 仅定位修复滚轮的起始位置；取消不改原始值，确认才提交用户选择。
          date = DateOnly.minimum;
        }
        final selected = await showWheelDatePicker(
          context,
          initial: DateTime(date.year, date.month, date.day),
          minDate: DateTime(DayLimits.minYear, 1, 1),
          maxDate: DateTime(DayLimits.maxYear, 12, 31),
          title: label,
          onPresent: onPresent,
          initialPresent: isPresent,
        );
        if (selected != null) {
          result = OriginalDate.solar(DateOnly.fromDateTime(selected));
        }
      } else {
        result = await showAppSheet<OriginalDate>(
          context: context,
          child: _LunarDateSheet(
            initial: value,
            title: label,
            onPresent: onPresent,
            initialPresent: isPresent,
          ),
        );
      }
      if (context.mounted && result != null) onChanged(result);
    } catch (error, stackTrace) {
      logger.error('DayDateField', '选择日期失败', error, stackTrace);
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).dayInvalid);
      }
    }
  }

  /// 起止日期共用循环记账输入行，历法由模块标题处统一控制。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDateField(
      key: ValueKey('day-date-$label'),
      label: label,
      stacked: stacked,
      valueText: isPresent
          ? l10n.dayPresent
          : requiresConfirmation
          ? '${value.originalYear}-${value.originalMonth}-${value.originalDay}'
          : dayDateLabel(l10n, value),
      enabled: enabled,
      onTap: () => _pick(context),
    );
  }
}

/// 日期模块共用历法切换，一次转换全部端点后才提交，避免混用或半更新。
class DayCalendarSwitcher extends StatelessWidget {
  const DayCalendarSwitcher({
    super.key,
    required this.dates,
    required this.onChanged,
    this.enabled = true,
  });
  final List<OriginalDate> dates;
  final ValueChanged<List<OriginalDate>> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IntrinsicWidth(
      child: CapsuleSwitcher<String>(
        compact: true,
        selectedValue: dates.first.calendarType,
        selectedBackgroundColor: AppTokens.primary(context),
        options: [
          CapsuleOption(value: DayCalendarType.solar, label: l10n.daySolar),
          CapsuleOption(value: DayCalendarType.lunar, label: l10n.dayLunar),
        ],
        onChanged: !enabled
            ? null
            : (calendar) {
                if (dates.every((date) => date.calendarType == calendar)) {
                  return;
                }
                try {
                  final converted = dates
                      .map((date) => convertDayCalendar(date, calendar))
                      .toList();
                  onChanged(converted);
                } catch (error, stackTrace) {
                  logger.error('DayDateField', '切换历法失败', error, stackTrace);
                  showToast(context, l10n.dayInvalid);
                }
              },
      ),
    );
  }
}

/// 农历只列出真实存在的月份及日号，范围两端按实际公历日期裁剪。
class _LunarDateSheet extends StatefulWidget {
  const _LunarDateSheet({
    required this.initial,
    required this.title,
    this.onPresent,
    this.initialPresent = false,
  });
  final VoidCallback? onPresent;
  final bool initialPresent;
  final OriginalDate initial;
  final String title;

  @override
  State<_LunarDateSheet> createState() => _LunarDateSheetState();
}

class _LunarDateSheetState extends State<_LunarDateSheet> {
  late int _year;
  late bool _present;
  late int _month;
  late int _day;
  late bool _leap;

  @override
  void initState() {
    super.initState();
    _present = widget.onPresent != null && widget.initialPresent;
    _year = widget.initial.originalYear.clamp(
      DayLimits.minLunarYear,
      DayLimits.maxYear,
    );
    _month = widget.initial.originalMonth;
    _day = widget.initial.originalDay;
    _leap = widget.initial.isLeapMonth;
  }

  /// 只转换标签，不改变滚轮索引或真实年月日取值。
  ({String month, String day}) _lunarParts(int month, int day, bool leap) {
    final parts = const LunarCalendar().chineseDateParts(
      OriginalDate(
        calendarType: DayCalendarType.lunar,
        originalYear: _year,
        originalMonth: month,
        originalDay: day,
        isLeapMonth: leap,
      ),
    );
    return (
      month: Localizations.localeOf(context).countryCode == 'TW'
          ? parts.month.replaceAll('闰', '閏')
          : parts.month,
      day: parts.day,
    );
  }

  /// 年月选择变化后同步真实月份列表，不能产生不存在的闰月或小月三十。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final yearChoices = widget.onPresent == null
        ? <int?>[
            for (
              var year = DayLimits.minLunarYear;
              year <= DayLimits.maxYear;
              year++
            )
              year,
          ]
        : dateWheelYearChoices(
            DayLimits.minLunarYear,
            DayLimits.maxYear,
            const LunarCalendar()
                .fromSolar(DateOnly.fromDateTime(DateTime.now()))
                .originalYear,
          );
    final months = const LunarCalendar()
        .months(_year)
        .where(
          (month) =>
              month.firstDayNumber <= DateOnly.maximum.dayNumber &&
              month.firstDayNumber + month.days - 1 >=
                  DateOnly.minimum.dayNumber,
        )
        .toList();
    final month =
        months
            .where(
              (month) => month.month == _month && month.isLeapMonth == _leap,
            )
            .firstOrNull ??
        months.first;
    _month = month.month;
    _leap = month.isLeapMonth;
    final days = [
      for (var day = 1; day <= month.days; day++)
        if (month.firstDayNumber + day - 1 >= DateOnly.minimum.dayNumber &&
            month.firstDayNumber + day - 1 <= DateOnly.maximum.dayNumber)
          day,
    ];
    if (!days.contains(_day)) _day = days.first;
    return SafeArea(
      top: false,
      child: AppSheet(
        title: widget.title,
        contentPadding: const EdgeInsets.only(top: AppDimens.p12),
        footer: AppPrimaryButton(
          label: l10n.commonConfirm,
          onPressed: () {
            if (_present) {
              widget.onPresent!();
              Navigator.pop(context);
              return;
            }
            try {
              final value = OriginalDate(
                calendarType: DayCalendarType.lunar,
                originalYear: _year,
                originalMonth: _month,
                originalDay: _day,
                isLeapMonth: _leap,
              );
              Navigator.pop(
                context,
                value.withSolarDate(const LunarCalendar().toSolar(value)),
              );
            } catch (error, stackTrace) {
              logger.error('DayDateField', '确认农历日期失败', error, stackTrace);
              showToast(context, l10n.dayInvalid);
            }
          },
        ),
        child: Row(
          children: [
            DateWheelColumn(
              initialItem: yearChoices.indexOf(_present ? null : _year),
              labels: [
                for (final year in yearChoices)
                  year == null ? l10n.dayPresent : '$year',
              ],
              onChanged: (index) => setState(() {
                final selected = yearChoices[index];
                _present = selected == null;
                if (selected != null) _year = selected;
              }),
            ),
            if (_present) ...[
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ] else ...[
              DateWheelColumn(
                // 年份变化时按有效月份重建滚动位置，闰月选项由日期库决定。
                key: ValueKey('month-$_year'),
                initialItem: months.indexOf(month),
                labels: [
                  for (final month in months)
                    _lunarParts(month.month, 1, month.isLeapMonth).month,
                ],
                onChanged: (index) => setState(() {
                  _month = months[index].month;
                  _leap = months[index].isLeapMonth;
                }),
              ),
              DateWheelColumn(
                // 月份变化时定位裁剪后的有效日号，取消仍不会写回外层表单。
                key: ValueKey('day-$_year-$_month-$_leap'),
                initialItem: days.indexOf(_day),
                labels: [
                  for (final day in days) _lunarParts(_month, day, _leap).day,
                ],
                onChanged: (index) => setState(() => _day = days[index]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
