import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_editor_actions.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_date_field.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart'
    show AppEditorHeader;
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/app_date_field.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 纪念日编辑弹层，只有显式保存才写入固定目标本。
class DayEventEditor extends ConsumerStatefulWidget {
  const DayEventEditor({super.key, required this.args, this.analyticsContext});
  final DayEditorArgs args;
  final ProductAnalyticsContext? analyticsContext;

  @override
  ConsumerState<DayEventEditor> createState() => _DayEventEditorState();
}

class _DayEventEditorState extends ConsumerState<DayEventEditor> {
  late final TextEditingController _name;
  late final TextEditingController _interval;
  late final String _id;
  late final DateTime _createdAt;
  late String _category;
  late String _countdown;
  late String _repeat;
  late String _statistic;
  late OriginalDate _event;
  late OriginalDate _start;
  late OriginalDate _end;
  bool _saving = false;
  bool _creationRecorded = false;
  bool _untilPresent = true;
  String? _error;
  final _unconfirmedDates = <String>{};

  /// 表单打开时固定目标身份与记录 ID，保存失败重试不会新增副本。
  @override
  void initState() {
    super.initState();
    final event = widget.args.event;
    final definition = event?.definition;
    final initial = OriginalDate.solar(
      widget.args.initialDate ?? ref.read(dayTodayProvider),
    );
    _id = event?.id ?? const Uuid().v4();
    _createdAt = event?.createdAt ?? DateTime.now().toUtc();
    _name = TextEditingController(text: definition?.name ?? '');
    _interval = TextEditingController(text: '${definition?.intervalDays ?? 1}');
    _category = definition?.category ?? DayCategory.birthday;
    _countdown = definition?.countdownMode ?? DayCountdownMode.fixedDate;
    _repeat = definition?.repeatType ?? DayRepeatType.yearly;
    _statistic = definition?.statisticType == DayStatisticType.day
        ? DayStatisticType.day
        : DayStatisticType.year;
    if (_category == DayCategory.countdown) _repeat = DayRepeatType.none;
    _untilPresent = definition?.end == null;
    _event = definition?.event ?? initial;
    _start = definition?.start ?? initial;
    _end = definition?.end ?? initial;
    if (event != null) {
      try {
        requireReadableDayDates(event);
        if (_category == DayCategory.stage) {
          _end = convertDayCalendar(_end, _start.calendarType);
        }
      } catch (error, stackTrace) {
        logger.error(
          'DayEditor',
          '原始日期需要重新确认',
          error is DayDateException ? error.code : error.runtimeType.toString(),
          stackTrace,
        );
        _unconfirmedDates.addAll(unconfirmedDayDateKeys(event));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _interval.dispose();
    super.dispose();
  }

  /// 模式变化重新建立有效字段组合，避免遗留无效循环或隐藏字段。
  void _changeCategory(String category) {
    setState(() {
      _category = category;
      _countdown = DayCountdownMode.fixedDate;
      _repeat =
          category == DayCategory.birthday ||
              category == DayCategory.anniversary
          ? DayRepeatType.yearly
          : DayRepeatType.none;
      _statistic = category == DayCategory.countdown
          ? DayStatisticType.day
          : DayStatisticType.year;
      final initial = OriginalDate.solar(
        widget.args.initialDate ?? ref.read(dayTodayProvider),
      );
      _event = initial;
      _start = initial;
      _end = initial;
      _untilPresent = true;
      _interval.text = '1';
      _unconfirmedDates.clear();
    });
  }

  /// 固定本、账号和绑定校验通过后，业务定义与云队列在仓储事务落库。
  Future<void> _save() async {
    if (_saving) return;
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: widget.analyticsContext);
    final completed = ref
        .read(productAnalyticsControllerProvider)
        .captureCompletion(pageId: 'days.editor', context: analyticsContext);
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'days.editor',
          action: ProductAction.daysEventSaveClick,
          context: analyticsContext,
        );
    if (_name.text.trim().isEmpty) {
      setState(() => _error = AppLocalizations.of(context).dayNameHint);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(dayActionsProvider)
          .saveEditor(
            args: widget.args,
            unconfirmedDates: _unconfirmedDates,
            draft: (
              category: _category,
              countdown: _countdown,
              repeat: _repeat,
              statistic: _statistic,
              name: _name.text,
              intervalText: _interval.text,
              event: _event,
              start: _start,
              end: _end,
              untilPresent: _untilPresent,
              today: ref.read(dayTodayProvider),
            ),
            eventId: _id,
            createdAt: _createdAt,
          );
      final created = widget.args.event == null && !_creationRecorded;
      if (created) {
        _creationRecorded = true;
      }
      completed(
        created ? ProductAction.daysEventCreated : ProductAction.daysEventSaved,
      );
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop(_id);
      });
    } catch (error, stackTrace) {
      logger.error('DayEditor', '保存日子失败', error, stackTrace);
      if (mounted) {
        setState(
          () => _error = error is DayDateException
              ? l10n.dayInvalid
              : l10n.daySaveFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 选项直接使用分类卡片的选中边框，紧凑排列并保持完整文字。
  Widget _choice(
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> onChanged, {
    String? example,
  }) => AppFormSection(
    title: label,
    compact: true,
    disabled: _saving,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppDimens.p8,
          runSpacing: AppDimens.p8,
          children: [
            for (final entry in choices.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: value == entry.key,
                showCheckmark: false,
                labelStyle: AppTextTokens.chipLabel(context),
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.all(AppDimens.p8),
                onSelected: _saving
                    ? null
                    : (_) {
                        FocusScope.of(context).unfocus();
                        onChanged(entry.key);
                      },
              ),
          ],
        ),
        if (example != null) ...[
          const SizedBox(height: AppDimens.p8),
          Text(
            example,
            style: AppTextTokens.caption(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
        ],
      ],
    ),
  );

  /// 单日期与区间端点复用同一输入，提交后才清除修复标记。
  Widget _startField(
    bool hasStart,
    AppLocalizations l10n, {
    bool stacked = false,
  }) => DayDateField(
    label: dayPrimaryDateLabel(l10n, _category, _countdown),
    value: hasStart ? _start : _event,
    stacked: stacked,
    enabled: !_saving,
    requiresConfirmation: _unconfirmedDates.contains(
      hasStart ? 'start' : 'event',
    ),
    onChanged: (value) => setState(() {
      if (hasStart) {
        _start = value;
      } else {
        _event = value;
      }
      _unconfirmedDates.remove(hasStart ? 'start' : 'event');
    }),
  );

  /// 示例展示选择后的单位和方向，使用固定跨度避免草稿尚未合法时误导。
  String _statisticExample(AppLocalizations l10n) {
    final duration = _statistic == DayStatisticType.day
        ? l10n.dayDaysValue(9496)
        : daySpanLabel(l10n, const DaySpan(26, 5, 20));
    return l10n.dayStatisticExample(
      _category == DayCategory.stage
          ? l10n.dayTotalDuration(duration)
          : _category == DayCategory.countdown
          ? l10n.dayRemainingDuration(duration)
          : l10n.dayElapsedDuration(duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasStart =
        _category == DayCategory.stage ||
        _category == DayCategory.countdown &&
            _countdown == DayCountdownMode.intervalDays;
    return SafeArea(
      top: false,
      child: AppSheet(
        header: AppEditorHeader(
          title: widget.args.event == null ? l10n.dayAdd : l10n.dayEdit,
          onBack: () => context.pop(),
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_unconfirmedDates.isNotEmpty)
              Text(
                l10n.dayRecordInvalid,
                style: AppTextTokens.body(
                  context,
                ).copyWith(color: AppTokens.error(context)),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.p8),
                child: Text(
                  _error!,
                  style: AppTextTokens.body(
                    context,
                  ).copyWith(color: AppTokens.error(context)),
                ),
              ),
            AppPrimaryButton(
              onPressed: _save,
              busy: _saving,
              label: l10n.commonSave,
            ),
          ],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            AppFormSection(
              title: l10n.dayName,
              compact: true,
              child: TextField(
                controller: _name,
                enabled: !_saving,
                style: AppTextTokens.input(context),
                decoration: InputDecoration(hintText: l10n.dayNameHint),
              ),
            ),
            _choice(l10n.dayType, _category, {
              for (final category in dayCategoryOrder)
                category: dayCategoryLabel(l10n, category),
            }, _changeCategory),
            if (_category == DayCategory.countdown)
              _choice(
                l10n.dayCountdown,
                _countdown,
                {
                  DayCountdownMode.fixedDate: l10n.dayFixedDate,
                  DayCountdownMode.intervalDays: l10n.dayIntervalDays,
                },
                (value) => setState(() {
                  _countdown = value;
                  _repeat = DayRepeatType.none;
                  _interval.text = '1';
                  _unconfirmedDates.remove(
                    value == DayCountdownMode.intervalDays ? 'event' : 'start',
                  );
                }),
              ),
            AppFormSection(
              title: dayPrimaryDateLabel(l10n, _category, _countdown),
              compact: true,
              trailing: DayCalendarSwitcher(
                dates: [
                  hasStart ? _start : _event,
                  if (_category == DayCategory.stage) _end,
                ],
                enabled: !_saving && _unconfirmedDates.isEmpty,
                onChanged: (dates) => setState(() {
                  if (hasStart) {
                    _start = dates.first;
                  } else {
                    _event = dates.first;
                  }
                  if (_category == DayCategory.stage) _end = dates.last;
                }),
              ),
              child: _category == DayCategory.stage
                  ? AppDateRangeFields(
                      start: _startField(hasStart, l10n, stacked: true),
                      end: DayDateField(
                        label: l10n.dayEnd,
                        value: _end,
                        stacked: true,
                        isPresent: _untilPresent,
                        onPresent: () => setState(() {
                          _untilPresent = true;
                          _unconfirmedDates.remove('end');
                        }),
                        enabled: !_saving,
                        requiresConfirmation: _unconfirmedDates.contains('end'),
                        onChanged: (value) => setState(() {
                          _end = value;
                          _untilPresent = false;
                          _unconfirmedDates.remove('end');
                        }),
                      ),
                    )
                  : _startField(hasStart, l10n),
            ),
            if (_category == DayCategory.countdown &&
                _countdown == DayCountdownMode.intervalDays)
              AppFormSection(
                title: l10n.dayIntervalDays,
                compact: true,
                child: TextField(
                  controller: _interval,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  style: AppTextTokens.input(context),
                  decoration: InputDecoration(hintText: l10n.dayDaysHint),
                ),
              ),
            if (_category != DayCategory.countdown &&
                _category != DayCategory.stage)
              _choice(l10n.dayRepeat, _repeat, {
                DayRepeatType.yearly: l10n.dayYearly,
              }, (value) => setState(() => _repeat = value)),
            _choice(
              l10n.dayStatistic,
              _statistic,
              {
                DayStatisticType.year: l10n.dayYears,
                DayStatisticType.day: l10n.dayDays,
              },
              (value) => setState(() => _statistic = value),
              example: _statisticExample(l10n),
            ),
          ],
        ),
      ),
    );
  }
}
