import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_week_strip.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_hero_backdrop.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_hero_duration.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_pull_to_refresh.dart';
import 'package:sesame_notes/shared/widgets/list_section_header.dart';
import 'package:sesame_notes/shared/widgets/skeleton.dart'
    show DetailListSkeleton;
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 当前日子本正文：最近事件、选日导航与按分类排列的完整明细。
class DaysHomePage extends ConsumerStatefulWidget {
  const DaysHomePage({super.key});

  @override
  ConsumerState<DaysHomePage> createState() => _DaysHomePageState();
}

class _DaysHomePageState extends ConsumerState<DaysHomePage> {
  DateOnly? _selectedDate;

  /// 选日仅改变当前首页的倒计时基准，完整分类列表保持可见。
  void _selectDate(DateTime date) {
    try {
      setState(() => _selectedDate = DateOnly.fromDateTime(date));
    } catch (error, stackTrace) {
      logger.error('DaysHome', '切换日子日期失败', error, stackTrace);
      showToast(context, AppLocalizations.of(context).dayTargetUnavailable);
    }
  }

  Widget _empty(BuildContext context) => ScrollableEmpty(
    child: AppEmpty(text: AppLocalizations.of(context).dayEventsEmpty),
  );

  /// 加载、空本及错误状态始终保留本入口，列表单独承担滚动。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final book = ref.watch(currentDayBookProvider);
    final events = book.value == null
        ? const AsyncData<List<DayEvent>>([])
        : ref.watch(dayEventsProvider(book.value!.id));
    final today = ref.watch(dayTodayProvider);
    final referenceDate = _selectedDate ?? today;
    final display = dayDisplayEntries(
      events.value ?? const <DayEvent>[],
      (definition) =>
          const DayDateRules().nextOccurrence(definition, referenceDate),
    );
    DayEvent? recent;
    List<DayEvent> sorted = [];
    var calculationFailed = false;
    try {
      const rules = DayDateRules();
      if (book.value != null) {
        recent = rules.recentEvent(
          display.valid,
          referenceDate,
          dayBookId: book.value!.id,
          calculatedNext: display.values,
        );
        sorted = rules.sortEvents(
          display.valid,
          referenceDate,
          dayBookId: book.value!.id,
          calculatedNext: display.values,
        );
      }
    } catch (error, stackTrace) {
      logger.error('DaysHome', '计算日子列表失败', error, stackTrace);
      recent = null;
      calculationFailed = true;
    }
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          Expanded(
            child: AppPullToRefresh(
              key: ValueKey(ref.watch(currentDayBookIdProvider).value),
              refreshingText: l10n.dayHomeSyncing,
              onRefresh: () => refreshDays(
                context,
                ref,
                book: book.value,
                showErrorToast: false,
              ),
              child: calculationFailed
                  ? AppLoadError(
                      scrollable: true,
                      onRetry: () => refreshDays(context, ref),
                    )
                  : book.when(
                      skipLoadingOnReload: true,
                      loading: () => const DetailListSkeleton(),
                      error: (_, _) => AppLoadError(
                        scrollable: true,
                        onRetry: () => refreshDays(context, ref),
                      ),
                      data: (book) => book == null
                          ? _empty(context)
                          : events.when(
                              skipLoadingOnReload: true,
                              loading: () => const DetailListSkeleton(),
                              error: (_, _) => AppLoadError(
                                scrollable: true,
                                onRetry: () =>
                                    ref.invalidate(dayEventsProvider(book.id)),
                              ),
                              data: (_) => _events(
                                context,
                                book,
                                sorted,
                                display.invalid,
                                referenceDate,
                                today,
                                recent,
                              ),
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// 最近事件沿用领域选取结果与时间口径，点击卡片进入该记录详情。
  Widget _eventHero(BuildContext context, DayEvent? recent, DateOnly today) {
    final l10n = AppLocalizations.of(context);
    final definition = recent?.definition;
    final target = definition == null
        ? null
        : dayDisplayTarget(definition, today);
    final duration = definition == null
        ? l10n.dayEventsEmpty
        : dayDurationLabel(l10n, definition, today, target);
    return CardTheme(
      data: CardTheme.of(
        context,
      ).copyWith(color: AppTokens.dayHeroBackground(context)),
      child: SectionCard(
        key: const Key('days-event-hero'),
        hero: true,
        margin: const EdgeInsets.only(bottom: AppDimens.p20),
        padding: const EdgeInsets.all(AppDimens.p20),
        onTap: recent == null ? null : () => _openEvent(recent),
        child: DayHeroBackdrop(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    definition == null
                        ? AppIcons.dayAnniversary
                        : dayCategoryIcon(definition.category),
                    size: AppDimens.icon16,
                  ),
                  const SizedBox(width: AppDimens.p8),
                  Expanded(
                    child: Text(
                      l10n.dayUpcomingTitle,
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.dayHeroMuted(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.p20),
              Text(
                definition?.name ?? '—',
                style: AppTextTokens.display1(
                  context,
                ).copyWith(color: AppTokens.dayHeroText(context)),
              ),
              const SizedBox(height: AppDimens.p12),
              DayHeroDuration(
                label: duration,
                relativeDays:
                    target != null &&
                        definition?.category != DayCategory.stage &&
                        duration ==
                            dayRelativeDuration(
                              l10n,
                              DayStatisticType.day,
                              today,
                              target,
                            )
                    ? today.daysUntil(target)
                    : null,
              ),
              if (target != null) ...[
                const SizedBox(height: AppDimens.p16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        target.iso8601,
                        style: AppTextTokens.dateSecondary(
                          context,
                        ).copyWith(color: AppTokens.dayHeroMuted(context)),
                      ),
                    ),
                    const Icon(AppIcons.chevronRight, size: AppDimens.icon20),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 导航失败保留当前日子列表，并给出可重试的反馈。
  Future<void> _openEvent(DayEvent event) async {
    try {
      await openDayEvent(context, ref, event);
    } catch (error, stackTrace) {
      logger.error('DaysHome', '打开最近日子失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).dayTargetUnavailable);
      }
    }
  }

  /// 分类头和明细行复用记账布局，按需创建可见行。
  Widget _events(
    BuildContext context,
    DayBook book,
    List<DayEvent> sorted,
    List<DayEvent> invalid,
    DateOnly today,
    DateOnly actualToday,
    DayEvent? recent,
  ) {
    final l10n = AppLocalizations.of(context);
    if (sorted.isEmpty && invalid.isEmpty) return _empty(context);
    final rows = <WidgetBuilder>[
      (_) => _eventHero(context, recent, today),
      (_) => DayWeekStrip(
        today: actualToday,
        selectedDay: today,
        events: [...sorted, ...invalid],
        onDateSelected: _selectDate,
      ),
      for (final category in dayCategoryOrder) ...[
        if (sorted.any((event) => event.definition.category == category))
          (_) => ListSectionHeader(
            title: dayCategoryLabel(l10n, category),
            horizontalPadding: 0,
          ),
        for (final event in sorted.where(
          (event) => event.definition.category == category,
        ))
          (_) => SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            padding: EdgeInsets.zero,
            child: DayEventListItem(event: event, today: today),
          ),
      ],
      for (final event in invalid) (_) => DayInvalidEventTile(event: event),
    ];
    return ListView.builder(
      key: PageStorageKey('days-home-${book.id}'),
      physics: AppPullToRefresh.physics,
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p16,
        AppDimens.domainPageInset,
        AppDimens.domainBottomClearance,
      ),
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index](context),
    );
  }
}
