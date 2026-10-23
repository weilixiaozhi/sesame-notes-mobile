import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
export 'package:sesame_notes/features/days/domain/day_date_rules.dart'
    show dayCategoryOrder;
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/application/day_refresh.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
export 'package:sesame_notes/shared/formatting/day_text.dart'
    show dayCategoryLabel;
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 日期标题按业务含义显示，固定倒数日期代表结束日。
String dayPrimaryDateLabel(
  AppLocalizations l10n,
  String category,
  String? countdownMode,
) => switch (category) {
  DayCategory.birthday => l10n.dayBirthDate,
  DayCategory.countdown when countdownMode == DayCountdownMode.fixedDate =>
    l10n.dayEnd,
  _ => l10n.dayStart,
};

/// 四类图标来自同一个语义令牌系统。
IconData dayCategoryIcon(String category) => switch (category) {
  DayCategory.birthday => AppIcons.dayBirthday,
  DayCategory.anniversary => AppIcons.dayAnniversary,
  DayCategory.countdown => AppIcons.dayCountdown,
  _ => AppIcons.dayStage,
};

/// 节日状态使用自然日差，今天保留明确文案。
String dayStatus(AppLocalizations l10n, DateOnly today, DateOnly? date) {
  if (date == null) return l10n.dayNoNext;
  final days = today.daysUntil(date);
  return switch (days) {
    0 => l10n.dayToday,
    > 0 => l10n.dayRemaining(days),
    _ => l10n.dayElapsed(-days),
  };
}

/// 倒数过期仍保留唯一原目标，生日与纪念日查找下次周年。
DateOnly? dayDisplayTarget(DayEventDefinition definition, DateOnly today) {
  final next = const DayDateRules().nextOccurrence(definition, today);
  if (next != null || definition.category != DayCategory.countdown) {
    return next;
  }
  return definition.event?.solarDate ??
      definition.start!.solarDate!.addDays(definition.intervalDays! - 1);
}

/// 原始日期只显示用户选中的历法，中文农历使用月名和日名。
String dayDateLabel(AppLocalizations l10n, OriginalDate date) {
  if (date.calendarType == DayCalendarType.solar) {
    return DateOnly(
      date.originalYear,
      date.originalMonth,
      date.originalDay,
    ).iso8601;
  }
  final chinese = const LunarCalendar().chineseDateLabel(date);
  if (l10n.localeName.startsWith('zh')) {
    return l10n.localeName == 'zh_TW' ? chinese.replaceAll('闰', '閏') : chinese;
  }
  return '${l10n.dayLunar} ${date.originalYear}-${date.isLeapMonth ? '${l10n.dayLeapMonth} ' : ''}${date.originalMonth}-${date.originalDay}';
}

/// 生日默认显示公历周岁，纪念日按原始历法显示周年，与统计选项无关。
String? dayMilestoneLabel(
  AppLocalizations l10n,
  DayEventDefinition definition,
  DateOnly? target,
) {
  if (target == null) return null;
  final original = definition.event;
  if (original == null) return null;
  if (definition.category == DayCategory.birthday) {
    final birth = original.solarDate!;
    if (target.isBefore(birth)) return null;
    return l10n.dayAgeValue(const DayDateRules().span(birth, target).years);
  }
  if (definition.category == DayCategory.anniversary) {
    if (target.isBefore(original.solarDate!)) return null;
    final date = original.calendarType == DayCalendarType.lunar
        ? const LunarCalendar().fromSolar(target)
        : OriginalDate.solar(target);
    var years = date.originalYear - original.originalYear;
    if (original.calendarType == DayCalendarType.solar) {
      years = const DayDateRules().span(original.solarDate!, target).years;
    } else {
      final anniversary = const LunarCalendar().yearlyDayNumber(
        original,
        date.originalYear,
      );
      final beforeAnniversary = anniversary != null
          ? target.dayNumber < anniversary
          : date.originalMonth <= original.originalMonth;
      if (beforeAnniversary) years--;
    }
    return l10n.dayAnniversaryValue(years);
  }
  return null;
}

/// 首页与详情共用方向和统计单位；倒数日只有唯一目标。
String dayDurationLabel(
  AppLocalizations l10n,
  DayEventDefinition definition,
  DateOnly today,
  DateOnly? target, {
  String? statisticType,
}) {
  final statistic = statisticType ?? definition.statisticType;
  if (definition.category == DayCategory.stage) {
    return l10n.dayTotalDuration(
      _dayDuration(
        l10n,
        statistic,
        definition.start!.solarDate!,
        definition.end?.solarDate ?? today,
      ),
    );
  }
  if (target == null) return l10n.dayNoNext;
  if (definition.category == DayCategory.countdown && target.isBefore(today)) {
    return l10n.dayExpired;
  }
  return dayRelativeDuration(l10n, statistic, today, target);
}

/// 用实际自然年月日跨度表达方向，所有入口均省略零分量。
String dayRelativeDuration(
  AppLocalizations l10n,
  String statistic,
  DateOnly from,
  DateOnly to,
) {
  if (from == to) return l10n.dayToday;
  final duration = _dayDuration(l10n, statistic, from, to);
  return to.isBefore(from)
      ? l10n.dayElapsedDuration(duration)
      : l10n.dayRemainingDuration(duration);
}

/// 时长来自已有自然日差和完整年月跨度，不加入起日或改写领域口径。
String _dayDuration(
  AppLocalizations l10n,
  String statisticType,
  DateOnly from,
  DateOnly to,
) {
  if (statisticType == DayStatisticType.day) {
    return l10n.dayDaysValue(from.daysUntil(to).abs());
  }
  const rules = DayDateRules();
  final span = from.isAfter(to) ? rules.span(to, from) : rules.span(from, to);
  return daySpanLabel(l10n, span);
}

/// 首页和工具共用自然年月日跨度文案，省略为零的单位。
String daySpanLabel(AppLocalizations l10n, DaySpan span) => [
  if (span.years > 0) l10n.dayYearsValue(span.years),
  if (span.months > 0) l10n.dayMonthsValue(span.months),
  if (span.days > 0 || (span.years == 0 && span.months == 0))
    l10n.dayDaysValue(span.days),
].join(l10n.localeName.startsWith('zh') ? '' : ' ');

/// 同一次页面计算逐条隔离错误；不丢弃异常身份，也不缓存跨次派生值。
({List<DayEvent> valid, List<DayEvent> invalid, Map<String, T> values})
dayDisplayEntries<T>(
  Iterable<DayEvent> events,
  T Function(DayEventDefinition) calculate,
) {
  final valid = <DayEvent>[];
  final invalid = <DayEvent>[];
  final values = <String, T>{};
  for (final event in events) {
    try {
      if (event.hasUnreadableDate) {
        throw const DayDateException('unreadable_projection');
      }
      values[event.id] = calculate(event.definition);
      valid.add(event);
    } catch (error, stackTrace) {
      logger.error(
        'DaysDisplay',
        '日子计算失败 ${event.id.substring(0, event.id.length < 8 ? event.id.length : 8)}',
        error is DayDateException ? error.code : error.runtimeType.toString(),
        stackTrace,
      );
      invalid.add(event);
    }
  }
  invalid.sort((a, b) {
    final created = a.createdAt.compareTo(b.createdAt);
    return created == 0 ? a.id.compareTo(b.id) : created;
  });
  return (valid: valid, invalid: invalid, values: values);
}

/// 纪念日明细复用记账图标与左右列，原始起止日期在名称下逐行显示。
class DayEventListItem extends ConsumerWidget {
  /// 日期由页面统一提供，日历可补充阶段起止标记。
  const DayEventListItem({super.key, required this.event, required this.today});

  final DayEvent event;
  final DateOnly today;

  /// 明细行显示原始日期摘要，完整内容由共用详情弹层承载。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final l10n = AppLocalizations.of(context);
      final definition = const DayDateRules().validateAndProject(
        event.definition,
      );
      final target = dayDisplayTarget(definition, today);
      final milestone = dayMilestoneLabel(l10n, definition, target ?? today);
      final showTarget =
          target != null &&
          !(definition.repeatType == DayRepeatType.none &&
              definition.event?.solarDate == target &&
              target.isBefore(today));
      return DetailListItem(
        leading: _dayListIcon(context, definition.category),
        title: definition.name,
        subtitle: DetailListSubtitle(
          child: Text(
            [
              for (final date in [
                definition.event,
                definition.start,
                definition.end,
              ])
                if (date != null) dayDateLabel(l10n, date),
              if (definition.category == DayCategory.stage &&
                  definition.end == null)
                l10n.dayPresent,
            ].join(' ~ '),
            style: AppTextTokens.dateSecondary(context),
          ),
        ),
        trailing: DetailListValues(
          value: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppDimens.p4,
            runSpacing: AppDimens.p4,
            children: [
              if (milestone != null)
                Text(
                  milestone,
                  style: AppTextTokens.caption(
                    context,
                  ).copyWith(color: AppTokens.textSecondary(context)),
                ),
              Text(
                dayDurationLabel(
                  l10n,
                  definition,
                  today,
                  target,
                  // 首页剩余时间按实际跨度展示，超过月或年不折算成总天数。
                  statisticType: target != null && target.isAfter(today)
                      ? DayStatisticType.year
                      : null,
                ),
              ),
            ],
          ),
          secondary: showTarget ? Text(target.iso8601) : null,
        ),
        onLongPress: () => deleteDayEvent(context, ref, event),
        onTap: () => openDayEvent(context, ref, event),
      );
    } catch (error, stackTrace) {
      logger.error('DaysDisplay', '生成日子明细失败', error, stackTrace);
      return DayInvalidEventTile(event: event);
    }
  }
}

/// 日子分类使用固定语义色对，三种主题分别提供对应色值。
Widget _dayListIcon(BuildContext context, String category) => DetailListIcon(
  backgroundColor: switch (category) {
    DayCategory.birthday => AppTokens.peachBackground(context),
    DayCategory.anniversary => AppTokens.sageBackground(context),
    DayCategory.stage => AppTokens.purpleBackground(context),
    _ => AppTokens.domainAccentBackground(context),
  },
  foregroundColor: switch (category) {
    DayCategory.birthday => AppTokens.peachForeground(context),
    DayCategory.anniversary => AppTokens.sageForeground(context),
    DayCategory.stage => AppTokens.purpleForeground(context),
    _ => AppTokens.primary(context),
  },
  child: Icon(dayCategoryIcon(category)),
);

/// 异常项保持名称和详情入口，使用户能定位原记录并明确编辑修复。
class DayInvalidEventTile extends ConsumerWidget {
  const DayInvalidEventTile({super.key, required this.event});
  final DayEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) => DetailListItem(
    leading: _dayListIcon(context, event.definition.category),
    title: event.definition.name,
    subtitle: DetailListSubtitle(
      child: Text(AppLocalizations.of(context).dayRecordInvalid),
    ),
    trailing: const SizedBox.shrink(),
    onLongPress: () => deleteDayEvent(context, ref, event),
    onTap: () => openDayEvent(context, ref, event),
  );
}

/// 统计区描述原始开始至今天；倒数与阶段沿用各自的方向语义。
String dayStatisticLabel(
  AppLocalizations l10n,
  DayEventDefinition definition,
  DateOnly today, {
  String? statisticType,
}) {
  final statistic = statisticType ?? definition.statisticType;
  if (definition.category == DayCategory.stage ||
      definition.category == DayCategory.countdown) {
    return dayDurationLabel(
      l10n,
      definition,
      today,
      dayDisplayTarget(definition, today),
      statisticType: statistic,
    );
  }
  return dayRelativeDuration(
    l10n,
    statistic,
    today,
    definition.event!.solarDate!,
  );
}

/// 首页、日历和异常项共用详情入口，点击与访问保留同一随机操作流。
Future<void> openDayEvent(
  BuildContext context,
  WidgetRef ref,
  DayEvent event,
) async {
  try {
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .beginFlow();
    trackProductEntryAction(
      context,
      ref.read,
      fallbackPageId: 'days',
      action: ProductAction.daysEventOpenClick,
      context: analyticsContext,
    );
    await context.pushNamed(
      Routes.dayEventDetail,
      extra: ProductAnalyticsNavigation(
        arguments: (event.dayBookId, event.id),
        context: analyticsContext,
      ),
    );
  } catch (error, stackTrace) {
    logger.error('DayNavigation', '打开日子详情失败', error.runtimeType, stackTrace);
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).dayTargetUnavailable);
    }
  }
}

/// 首页长按和详情删除共用固定目标确认、会话复核及失败重试。
Future<bool> deleteDayEvent(
  BuildContext context,
  WidgetRef ref,
  DayEvent event,
) async {
  final l10n = AppLocalizations.of(context);
  final sourcePage = productAnalyticsEntryPage(
    context,
    ref.read,
    fallbackPageId: 'days',
  );
  final parentContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  try {
    final actions = ref.read(dayActionsProvider);
    final target = await actions.target(event.dayBookId);
    if (!context.mounted) return false;
    return await AppDialog.confirmAsync(
      context,
      title: l10n.commonDelete,
      message: l10n.dayDeleteEvent(event.definition.name),
      onConfirm: () async {
        final analyticsContext = ref
            .read(productAnalyticsControllerProvider)
            .captureContext(parent: parentContext);
        await actions.deleteEvent(event, target);
        if (context.mounted) {
          ref
              .read(productAnalyticsControllerProvider)
              .trackAction(
                pageId: sourcePage,
                action: ProductAction.daysEventDeleted,
                context: analyticsContext,
              );
        }
      },
      errorMessage: (_) => l10n.daySaveFailed,
    );
  } catch (error, stackTrace) {
    logger.error('DayDelete', '删除日子失败，保留原记录', error, stackTrace);
    if (context.mounted) showToast(context, l10n.daySaveFailed);
    return false;
  }
}

/// 无本新增先完成明确建本，再固定目标继续打开编辑器。
Future<void> openDayEditor(
  BuildContext context,
  WidgetRef ref, {
  DateOnly? initialDate,
  DayEvent? event,
  DayBook? book,
}) async {
  final l10n = AppLocalizations.of(context);
  try {
    final router = GoRouter.maybeOf(context);
    final parent = event == null || router == null
        ? null
        : productAnalyticsRouteContext(router, ref.read);
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: parent, newFlow: parent?.flowId == null);
    if (event == null) {
      trackProductEntryAction(
        context,
        ref.read,
        fallbackPageId: 'days',
        action: ProductAction.daysEventCreateClick,
        context: analyticsContext,
      );
    }
    var id = await ref.read(currentDayBookIdProvider.future);
    var target =
        book ??
        (id == null
            ? null
            : await ref
                  .read(dayActionsProvider)
                  .getBook(id, accountId: ref.read(currentAccountIdProvider)));
    // 没有任何本子时由首条记录顺带创建默认本子；已有本子只是当前未选中时
    // 保持既有"先建本再记录"入口。
    if (target == null) {
      final created = await ref
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.days, l10n);
      if (created == null) {
        if (!context.mounted) return;
        await context.pushNamed(Routes.dayBookEdit);
        id = await ref.read(currentDayBookIdProvider.future);
      } else {
        id = created;
      }
      target = id == null
          ? null
          : await ref
                .read(dayActionsProvider)
                .getBook(id, accountId: ref.read(currentAccountIdProvider));
    }
    if (!context.mounted || target == null) return;
    final args = await ref
        .read(dayActionsProvider)
        .prepareEditor(target, event: event, initialDate: initialDate);
    if (!context.mounted) return;
    await context.pushNamed(
      Routes.dayEventEdit,
      extra: ProductAnalyticsNavigation(
        arguments: args,
        context: analyticsContext,
      ),
    );
  } catch (error, stackTrace) {
    logger.error('DayEditor', '打开目标日子编辑器失败', error, stackTrace);
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).dayTargetUnavailable);
    }
  }
}

/// 页面侧刷新入口：编排在 application 层，这里只负责展示刷新结果。
Future<String?> refreshDays(
  BuildContext context,
  WidgetRef ref, {
  DayBook? book,
  bool showErrorToast = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final outcome = await ref.read(dayRefreshProvider).run(book: book);
  // 页面已卸载或结果过期（账号变化）时不发布任何提示。
  if (!context.mounted || outcome == null) return null;
  if (showErrorToast && dayRefreshFailed(outcome)) {
    showToast(context, l10n.commonOperationFailed);
  }
  return dayRefreshMessage(l10n, outcome);
}
