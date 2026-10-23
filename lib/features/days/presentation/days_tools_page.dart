import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_date_field.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_date_field.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 计算工具与未来一年内的节日直接展示，所有计算均在本地完成。
class DaysToolsPage extends ConsumerStatefulWidget {
  const DaysToolsPage({super.key});

  @override
  ConsumerState<DaysToolsPage> createState() => _DaysToolsPageState();
}

class _DaysToolsPageState extends ConsumerState<DaysToolsPage> {
  int _revision = 0;

  /// 下拉重新读取当天与节日，同时销毁旧工具草稿，让日期、天数和结果共同初始化。
  Future<void> _refresh() async {
    FocusScope.of(context).unfocus();
    ref.invalidate(dayTodayProvider);
    setState(() => _revision++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ensureMinimumRefreshDuration(_refresh),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.domainPageInset,
                  AppDimens.p16,
                  AppDimens.domainPageInset,
                  AppDimens.domainBottomClearance,
                ),
                children: [
                  DayDateTool(
                    key: ValueKey('difference-$_revision'),
                    offset: false,
                  ),
                  const SizedBox(height: AppDimens.p12),
                  DayDateTool(key: ValueKey('offset-$_revision'), offset: true),
                  const SizedBox(height: AppDimens.p16),
                  SectionTitle(
                    title: l10n.dayHolidays,
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppDimens.p8),
                  ..._holidays(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 节日按最近日期优先展示，名称与年月日居左，距今天的时长居右。
  List<Widget> _holidays(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(dayTodayProvider);
    final labels = {
      'new_year': l10n.dayNewYear,
      'labour_day': l10n.dayLabour,
      'national_day': l10n.dayNational,
      'spring_festival': l10n.daySpring,
      'lantern_festival': l10n.dayLantern,
      'dragon_boat': l10n.dayDragonBoat,
      'qixi': l10n.dayQixi,
      'mid_autumn': l10n.dayMidAutumn,
      'double_ninth': l10n.dayDoubleNinth,
      'lunar_new_year_eve': l10n.dayNewYearsEve,
      'qingming': l10n.dayQingming,
    };
    try {
      final holidays = const LunarCalendar().upcomingHolidays(today);
      return [
        for (final holiday in holidays)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p8),
            padding: EdgeInsets.zero,
            child: DetailListItem(
              title: labels[holiday.code]!,
              subtitle: DetailListSubtitle(child: Text(holiday.date.iso8601)),
              trailing: DetailListValues(
                value: Text(dayStatus(l10n, today, holiday.date)),
              ),
            ),
          ),
      ];
    } catch (error, stackTrace) {
      logger.error('DayHolidays', '读取未来一年节日失败', error, stackTrace);
      return [AppLoadError(onRetry: () => ref.invalidate(dayTodayProvider))];
    }
  }
}

/// 日期差和前后推算共用输入及结果模块，不写入纪念日记录。
class DayDateTool extends ConsumerStatefulWidget {
  const DayDateTool({super.key, required this.offset});
  final bool offset;
  @override
  ConsumerState<DayDateTool> createState() => _DayDateToolState();
}

class _DayDateToolState extends ConsumerState<DayDateTool> {
  late OriginalDate _start;
  late OriginalDate _end;
  final _days = TextEditingController();
  String? _error;
  int? _difference;
  DaySpan? _span;
  ({DateOnly before, DateOnly after, int count})? _offset;

  @override
  void initState() {
    super.initState();
    _start = OriginalDate.solar(ref.read(dayTodayProvider));
    _end = _start;
  }

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  /// 输入改变后回到可见空态，避免旧结果与新日期或天数混用。
  void _clearResult() {
    _offset = null;
    _difference = null;
    _span = null;
    _error = null;
  }

  /// 日期跨度使用领域日序与年月日计算，零天合法，非法输入和越界保留原值。
  void _calculate() {
    try {
      final start = _start.solarDate!;
      if (widget.offset) {
        _offset = const DayDateRules().offsetDatesFromText(start, _days.text);
      } else {
        final end = _end.solarDate!;
        _difference = start.daysUntil(end);
        _span = start.isAfter(end)
            ? const DayDateRules().span(end, start)
            : const DayDateRules().span(start, end);
      }
      setState(() => _error = null);
    } catch (error, stackTrace) {
      logger.error('DayTool', '计算日期失败', error, stackTrace);
      setState(() {
        _clearResult();
        final l10n = AppLocalizations.of(context);
        _error = error is DayDateException && error.code == 'date_out_of_range'
            ? l10n.dayDateOutOfRange(
                DateOnly.minimum.iso8601,
                DateOnly.maximum.iso8601,
              )
            : l10n.dayInvalid;
      });
    }
  }

  /// 前后日期同时给出公历、中文农历与星期，天数取计算时的输入快照。
  Widget _offsetDate(BuildContext context, String label, DateOnly date) {
    final l10n = AppLocalizations.of(context);
    final lunar = const LunarCalendar().fromSolar(date);
    final weekday = DateFormat.EEEE(
      l10n.localeName,
    ).format(DateTime(date.year, date.month, date.day));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextTokens.caption(context)),
        const SizedBox(height: AppDimens.p4),
        Text(date.iso8601, style: AppTextTokens.strongTitle(context)),
        Text(
          '${dayDateLabel(l10n, lunar)} · $weekday',
          style: AppTextTokens.dateSecondary(context),
        ),
      ],
    );
  }

  /// 工具与日子编辑复用同一个日期字段及区间排列。
  Widget _startField(AppLocalizations l10n, {bool stacked = false}) =>
      DayDateField(
        label: l10n.dayStart,
        value: _start,
        stacked: stacked,
        onChanged: (value) => setState(() {
          _start = value;
          _clearResult();
        }),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: AppDimens.p8,
                  runSpacing: AppDimens.p4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      widget.offset ? l10n.dayOffset : l10n.dayDifference,
                      style: AppTextTokens.strongTitle(context),
                    ),
                    DayCalendarSwitcher(
                      dates: [_start, if (!widget.offset) _end],
                      onChanged: (dates) => setState(() {
                        _start = dates.first;
                        _end = dates.last;
                        _clearResult();
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              FilledButton(
                onPressed: _calculate,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, AppDimens.p32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                  ),
                  textStyle: AppTextTokens.label(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                child: Text(l10n.dayCalculate),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.p8),
          if (!widget.offset)
            AppDateRangeFields(
              start: _startField(l10n, stacked: true),
              end: DayDateField(
                label: l10n.dayEnd,
                value: _end,
                stacked: true,
                onChanged: (value) => setState(() {
                  _end = value;
                  _clearResult();
                }),
              ),
            )
          else ...[
            _startField(l10n),
            const SizedBox(height: AppDimens.p8),
            TextField(
              controller: _days,
              onChanged: (_) => setState(_clearResult),
              keyboardType: TextInputType.number,
              style: AppTextTokens.input(context),
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                  ),
                  child: Text(
                    '${l10n.dayDays}${l10n.localeName.startsWith('zh') ? '：' : ':'}',
                    style: AppTextTokens.input(context),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(),
                hintText: l10n.dayDaysHint,
              ),
            ),
          ],
          if (_error != null || _difference != null || _offset != null) ...[
            const SizedBox(height: AppDimens.p8),
            SectionCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.all(AppDimens.p12),
              color: AppTokens.surfaceSecondary(context),
              showShadow: false,
              child: Semantics(
                liveRegion: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dayCalculationResult,
                      style: AppTextTokens.body(context),
                    ),
                    const SizedBox(height: AppDimens.p8),
                    if (_error != null)
                      Text(
                        _error!,
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(color: AppTokens.error(context)),
                      )
                    else if (_difference != null) ...[
                      for (final text in [
                        l10n.dayDifferenceFullSpan(
                          _span!.years,
                          _span!.months,
                          _span!.days,
                        ),
                        l10n.dayDifferenceTotalDays(_difference!.abs()),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.p8),
                          child: Text(text, style: AppTextTokens.body(context)),
                        ),
                    ] else if (_offset != null) ...[
                      _offsetDate(
                        context,
                        l10n.dayOffsetBefore(_offset!.count),
                        _offset!.before,
                      ),
                      const SizedBox(height: AppDimens.p12),
                      _offsetDate(
                        context,
                        l10n.dayOffsetAfter(_offset!.count),
                        _offset!.after,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
