import 'package:sesame_notes/features/fitness/application/fitness_space_queries.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:flutter/material.dart';
import '../../../core/clock/local_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/app_expandable_calendar.dart';
import 'package:sesame_notes/shared/widgets/list_section_header.dart';
import 'package:sesame_notes/shared/widgets/app_pull_to_refresh.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../application/fitness_providers.dart';
import '../domain/fitness_statistics.dart';
import 'widgets/fitness_home_cards.dart';
import 'widgets/fitness_widgets.dart';

/// 训练首页以真实日程和选中日期的训练为主体。
class FitnessHomePage extends ConsumerStatefulWidget {
  const FitnessHomePage({super.key});
  @override
  ConsumerState<FitnessHomePage> createState() => _FitnessHomePageState();
}

class _FitnessHomePageState extends ConsumerState<FitnessHomePage> {
  DateTime _selected = DateUtils.dateOnly(DateTime.now());
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final range = _pageRange(0);
    // 相邻两页提前订阅，翻页区间数据保持就绪，训练区块布局稳定。
    ref.watch(fitnessWorkoutsInRangeProvider(_pageRange(-1)));
    ref.watch(fitnessWorkoutsInRangeProvider(_pageRange(1)));
    final workouts = ref.watch(fitnessWorkoutsInRangeProvider(range));
    final calendarPlans = ref.watch(fitnessCalendarPlansProvider);
    final now = ref.watch(localTodayProvider);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: AppPullToRefresh(
              key: ValueKey(ref.watch(currentFitnessSpaceIdProvider).value),
              refreshingText: l.fitnessHomeSyncing,
              onRefresh: _refresh,
              child: CustomScrollView(
                key: const PageStorageKey('fitness-home-scroll'),
                physics: AppPullToRefresh.physics,
                slivers: [
                  // 日期导航常驻，异步切换日期范围时不销毁正在翻页的日历。
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.domainPageInset,
                      AppDimens.p16,
                      AppDimens.domainPageInset,
                      AppDimens.p8,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: SectionCard(
                        margin: EdgeInsets.zero,
                        child: _week(
                          workouts.value ?? [],
                          calendarPlans.value ?? [],
                          now,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ListSectionHeader(
                      title: l.fitnessSelectedTraining,
                      horizontalPadding: AppDimens.domainPageInset,
                      trailing: Flexible(
                        child: Text(
                          DateFormat.MMMEd(l.localeName).format(_selected),
                        ),
                      ),
                    ),
                  ),
                  workouts.when(
                    loading: () =>
                        const SliverToBoxAdapter(child: SizedBox.shrink()),
                    error: (_, _) => SliverToBoxAdapter(
                      child: AppLoadError(
                        message: l.fitnessLoadFailed,
                        onRetry: () => ref.invalidate(
                          fitnessWorkoutsInRangeProvider(range),
                        ),
                      ),
                    ),
                    data: (all) => _training(
                      fitnessWorkoutsOnDate(
                        all,
                        fitnessDate(_selected),
                        now: now,
                      ),
                      fitnessCalendarRestDays(calendarPlans.value ?? [])
                          .where((day) => day.date == fitnessDate(_selected))
                          .toList(),
                      calendarPlans,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: const SizedBox(
                      height: AppDimens.domainBottomClearance,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 日历整页取数：区间固定为选中月份的整月并在两端各补一周，
  /// 周历可见的一周、月历整屏以及展开收起前后的切换都落在同一区间内。
  /// [step] 是相对当前页的偏移，0 为当前页，±1 为前后一页。
  FitnessWorkoutRange _pageRange(int step) => (
    start: DateTime(_selected.year, _selected.month + step, 1 - 7),
    until: DateTime(_selected.year, _selected.month + step + 1, 1 + 7),
    calendar: true,
  );

  /// 本机刷新只重读日程和列表，当前登录身份存在时才处理云空间同步。
  Future<String?> _refresh() async {
    final l = AppLocalizations.of(context);
    final repo = ref.read(fitnessActionsProvider);
    final target = repo.target;
    final cloud =
        ref.read(currentAccountIdProvider) != null &&
        (ref.read(currentFitnessSpaceProvider).value?.isCloud ?? true);

    /// 异步结果只交还给发起刷新时的训练空间。
    bool current() =>
        mounted && ref.read(fitnessActionsProvider).target == target;
    var outcome = DataRefreshOutcome.localOnly;
    if (cloud) {
      outcome = DataRefreshOutcome.failed;
      try {
        outcome = (await ref.read(syncCoordinatorProvider).refreshData())
            .refreshOutcome;
      } catch (error, stackTrace) {
        logger.error('FitnessHome', '云端刷新失败，继续读取本地日程', error, stackTrace);
      }
    }
    if (!current()) return null;
    try {
      await ref
          .read(fitnessSpaceQueriesProvider)
          .getBooks(accountId: repo.target.accountId);
      if (target.bookId.isNotEmpty) {
        await repo.refreshLocalSnapshot();
      }
      if (!current()) return null;
      ref.invalidate(fitnessWorkoutsInRangeProvider);
      ref.invalidate(fitnessPlansProvider);
      ref.invalidate(fitnessCalendarPlansProvider);
      ref.invalidate(fitnessTemplatesProvider);
      return switch (outcome) {
        DataRefreshOutcome.localOnly => l.fitnessPullLocalSuccess,
        DataRefreshOutcome.cloudSynced => l.fitnessPullCloudSuccess,
        DataRefreshOutcome.failed => l.fitnessPullCloudFailedButLocalOk,
      };
    } catch (error, stackTrace) {
      logger.error('FitnessHome', '读取本地健身日程失败', error, stackTrace);
      if (!current()) return null;
      return l.fitnessLoadFailed;
    }
  }

  /// 所选日的训练和业务休息共用列表，目录未完成时保留加载与错误状态。
  Widget _training(
    List<FitnessWorkout> workouts,
    List<FitnessRestDay> rests,
    AsyncValue<List<FitnessPlan>> calendarPlans,
  ) {
    final l = AppLocalizations.of(context);
    if (workouts.isEmpty && !calendarPlans.hasValue) {
      return SliverToBoxAdapter(
        child: calendarPlans.hasError
            ? AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessCalendarPlansProvider),
              )
            : const SizedBox.shrink(),
      );
    }
    final entries = <Widget>[
      for (final workout in workouts)
        FitnessHomeWorkoutCard(key: ValueKey(workout.id), workout: workout),
      for (final rest in rests)
        FitnessRestDayCard(planName: rest.sourcePlanName),
    ];
    // 空状态与训练列表共享页面边距，使日期卡片、标题和训练卡片沿同一边线排列。
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.domainPageInset,
      ),
      sliver: entries.isEmpty
          ? SliverToBoxAdapter(
              child: SectionCard(
                margin: const EdgeInsets.only(bottom: AppDimens.p8),
                padding: EdgeInsets.zero,
                child: AppEmpty(
                  icon: AppIcons.fitness,
                  text: l.fitnessNoSelectedTraining,
                ),
              ),
            )
          : SliverList.builder(
              itemCount: entries.length,
              itemBuilder: (_, i) => entries[i],
            ),
    );
  }

  /// 训练与休息标签按可见日期投影，周月导航由共享组件承载。
  Widget _week(
    List<FitnessWorkout> all,
    List<FitnessPlan> plans,
    DateTime now,
  ) {
    final l = AppLocalizations.of(context);
    final start = DateTime(
      _selected.year,
      _selected.month,
      _selected.day - _selected.weekday + 1,
    );
    final rests = fitnessCalendarRestDays(plans).map((r) => r.date).toSet();
    final labels = <String, List<String>>{};
    final labelStart = _expanded
        ? DateTime(_selected.year, _selected.month, 1 - 7)
        : start;
    final labelEnd = _expanded
        ? DateTime(_selected.year, _selected.month + 1, 1 + 7)
        : DateTime(start.year, start.month, start.day + 7);
    for (
      var date = labelStart;
      date.isBefore(labelEnd);
      date = DateTime(date.year, date.month, date.day + 1)
    ) {
      final key = fitnessDate(date);
      labels[key] = [
        ...{
          for (final w in fitnessWorkoutsOnDate(all, key, now: now))
            switch (w.status) {
              'completed' || 'in_progress' => fitnessWorkoutStatus(l, w),
              _ => l.fitnessCalendarPlanned,
            },
        },
        if (rests.contains(key)) l.fitnessCalendarRest,
      ];
    }
    final maxLabels = labels.values.fold(
      0,
      (n, values) => values.length > n ? values.length : n,
    );
    return AppExpandableCalendar<FitnessWorkout>(
      firstDay: DateTime(1900),
      lastDay: DateTime(2200, 12, 31),
      selectedDay: _selected,
      currentDay: now,
      expanded: _expanded,
      onToggleExpanded: () => setState(() => _expanded = !_expanded),
      onDateSelected: (date) => setState(() => _selected = date),
      maxLabels: maxLabels,
      rangeToggleKey: const ValueKey('fitness-calendar-range-toggle'),
      rangeTextKey: const ValueKey('fitness-calendar-range-text'),
      dayMarkerBuilder: (context, date, _) {
        final names = labels[fitnessDate(date)] ?? [];
        return names.isEmpty ? null : AppCalendarLabels(labels: names);
      },
    );
  }
}
