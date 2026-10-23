import 'package:sesame_notes/shared/presentation/analytics_axes.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/utils/date/week_math.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_widgets.dart';
import 'widgets/fitness_body_map.dart';

/// 健身统计沿用真实完成训练和自然周、月、年的查询口径。
class FitnessAnalyticsPage extends ConsumerStatefulWidget {
  /// 嵌入业务壳时，底部周期和新增操作由外壳统一排列。
  const FitnessAnalyticsPage({super.key, this.embedded = false});

  final bool embedded;

  /// 日期和部位筛选随页面保留，周期选择与外壳共享。
  @override
  ConsumerState<FitnessAnalyticsPage> createState() =>
      _FitnessAnalyticsPageState();
}

class _FitnessAnalyticsPageState extends ConsumerState<FitnessAnalyticsPage> {
  /// 页面和外壳读取同一周期，各周期的所选日期由当前页面分别保存。
  AnalyticsPeriod get _period => ref.read(fitnessAnalyticsPeriodProvider);

  AnalyticsPeriod? _lastPeriod;
  final _dates = <AnalyticsPeriod, DateTime>{};
  DateTime get _selectedDate => _dates[_period] ?? DateTime.now();
  DateTimeRange get _range => _naturalRange(_selectedDate, _period.name);
  String? _part;
  bool _retrying = false;

  DateTimeRange _naturalRange(DateTime anchor, String period) {
    final range = fitnessDateRange(anchor, period);
    return DateTimeRange(
      start: DateTime.parse(range.startDate),
      end: DateTime.parse(range.endDate),
    );
  }

  void _selectDate(DateTime date) => setState(() {
    _dates[_period] = date;
    _part = null;
  });

  List<AnalyticsSubTab> _tabs(({DateTime? earliest, DateTime? latest}) bounds) {
    final l = AppLocalizations.of(context);
    final dates = [
      if (bounds.earliest != null) bounds.earliest!,
      if (bounds.latest != null) bounds.latest!,
      DateTime.now(),
      _selectedDate,
    ]..sort();
    return generateSubTabs(
      period: _period,
      earliest: dates.first,
      latest: dates.last,
      now: DateTime.now(),
      selectedDate: _selectedDate,
      monthStartDay: 1,
      monthLabel: (month) => monthLabel(context, month),
      weekNLabel: l.analyticsWeekN,
      thisWeekLabel: l.analyticsThisWeek,
      yearLabel: l.homeYear,
    );
  }

  /// 周序号和年份统一取所在周一，跨年日期与子周期列表使用相同标识。
  String get _selectedTabId => switch (_period) {
    AnalyticsPeriod.month =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}',
    AnalyticsPeriod.year => '${_selectedDate.year}',
    AnalyticsPeriod.week =>
      '${mondayOf(_selectedDate).year}-W${weekNumber(mondayOf(_selectedDate))}',
  };

  /// 周/月视图横轴刻度：区间内每一天。
  List<DateTime> get _rangeDays => [
    for (
      var day = _range.start;
      !day.isAfter(_range.end);
      day = DateTime(day.year, day.month, day.day + 1)
    )
      day,
  ];

  /// 选中周期是否就是当前周期，决定折线图是否高亮今天。
  bool get _isCurrentRange =>
      _range.start == _naturalRange(DateTime.now(), _period.name).start;

  /// 当前空间尚未确认时不请求另一份统计快照，也不把无空间解释为云下载未完成。
  @override
  Widget build(BuildContext context) {
    final period = ref.watch(fitnessAnalyticsPeriodProvider);
    // 外壳与独立页面都可更换周期，查询新范围时同步清空旧范围的部位筛选。
    if (_lastPeriod != period) {
      _lastPeriod = period;
      _part = null;
    }
    final range = (
      start: _range.start,
      until: DateTime(_range.end.year, _range.end.month, _range.end.day + 1),
      calendar: false,
    );
    final space = ref.watch(currentFitnessSpaceProvider);
    final available =
        !space.isLoading && !space.hasError && space.value != null;
    final workouts = available
        ? ref.watch(fitnessWorkoutsInRangeProvider(range))
        : const AsyncData<List<FitnessWorkout>>([]);
    final bounds = available
        ? ref.watch(fitnessWorkoutBoundsProvider).value ??
              (earliest: null, latest: null)
        : (earliest: null, latest: null);
    final catalog = available
        ? ref.watch(fitnessCatalogProvider)
        : const AsyncData<List<FitnessExerciseDefinition>>([]);
    final sync = available
        ? ref.watch(fitnessSyncStatusProvider)
        : const AsyncData(FitnessSyncStatus(isComplete: false));
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AppAnalyticsPeriodHeader(
                period: period,
                selectedDate: _selectedDate,
                isCurrent: _isCurrentRange,
                hasData: bounds.earliest != null,
                tabs: _tabs(bounds),
                selectedTabId: _selectedTabId,
                onDateChanged: _selectDate,
                onTabChanged: (tab) => _selectDate(tab.start),
                onCurrent: () => _selectDate(DateTime.now()),
              ),
              Expanded(
                child: _dataContent(space, workouts, catalog, sync, range),
              ),
            ],
          ),
          if (!widget.embedded)
            Positioned(
              left: AppDimens.domainPageInset,
              bottom: AppDimens.p16,
              child: SafeArea(
                top: false,
                child: AppAnalyticsPeriodSwitcher(
                  period: period,
                  onChanged: _changePeriod,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 先区分目录状态，再保留完整性与冲突保护；只有真正的云端缺失提示下载。
  Widget _dataContent(
    AsyncValue<FitnessSpace?> space,
    AsyncValue<List<FitnessWorkout>> workouts,
    AsyncValue<List<FitnessExerciseDefinition>> catalog,
    AsyncValue<FitnessSyncStatus> sync,
    FitnessWorkoutRange range,
  ) {
    final l = AppLocalizations.of(context);
    if (_retrying || space.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (space.hasError) {
      logger.error(
        'FitnessAnalytics',
        '读取当前训练空间失败',
        space.error,
        space.stackTrace,
      );
      return AppLoadError(
        message: l.fitnessLoadFailed,
        onRetry: () => _retry(range, refreshDirectory: true),
      );
    }
    final book = space.value;
    if (book == null) {
      return AppEmpty(icon: AppIcons.fitness, text: l.fitnessNoSpaces);
    }
    if (workouts.isLoading || catalog.isLoading || sync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (workouts.hasError || catalog.hasError || sync.hasError) {
      for (final state in [workouts, catalog, sync]) {
        if (state.hasError) {
          logger.error(
            'FitnessAnalytics',
            '读取健身统计失败',
            state.error,
            state.stackTrace,
          );
        }
      }
      return AppLoadError(
        message: l.fitnessLoadFailed,
        onRetry: () => _retry(range),
      );
    }
    final status = sync.requireValue;
    if (!status.isComplete || book.isStale || !book.isComplete) {
      final cloudDownload =
          book.isCloud && (!book.isComplete || book.isStale || status.isStale);
      if (cloudDownload) {
        return AppStatusBanner(
          icon: AppIcons.cloudDownload,
          message: l.fitnessIncomplete,
          onTap: _openSyncCenter,
        );
      }
      if (status.conflicts.any((conflict) => conflict.isOtherRunningWorkout)) {
        return AppStatusBanner(
          icon: AppIcons.warning,
          message: l.fitnessConflicts,
          onTap: _openSyncCenter,
        );
      }
      // 本机异常仍阻止不完整报表，但不声称本地资源需要云端下载。
      return AppLoadError(
        message: l.fitnessLoadFailed,
        onRetry: () => _retry(range),
      );
    }
    try {
      return _content(workouts.requireValue, {
        for (final def in catalog.requireValue) def.id: def,
      });
    } catch (error, stackTrace) {
      logger.error('FitnessAnalytics', '健身统计数据无效', error, stackTrace);
      return AppLoadError(
        message: l.fitnessLoadFailed,
        onRetry: () => _retry(range),
      );
    }
  }

  /// 目录失败重试沿既有同步协调器刷新，其他读取失败只重新加载当前查询。
  Future<void> _retry(
    FitnessWorkoutRange range, {
    bool refreshDirectory = false,
  }) async {
    if (_retrying) return;
    final account = ref.read(currentAccountIdProvider);
    setState(() => _retrying = true);
    try {
      if (refreshDirectory && account != null) {
        final result = await ref.read(syncCoordinatorProvider).refreshData();
        if (!result.ok) {
          throw StateError(result.error ?? 'FITNESS_DIRECTORY_REFRESH_FAILED');
        }
      }
      if (!mounted || ref.read(currentAccountIdProvider) != account) return;
      if (refreshDirectory) {
        ref.invalidate(fitnessSpacesProvider);
        ref.invalidate(currentFitnessSpaceIdProvider);
      }
      ref.invalidate(fitnessWorkoutsInRangeProvider(range));
      ref.invalidate(fitnessWorkoutBoundsProvider);
      ref.invalidate(fitnessPreferencesProvider);
      ref.invalidate(fitnessCatalogProvider);
      ref.invalidate(fitnessSyncStatusProvider);
    } catch (error, stackTrace) {
      logger.error('FitnessAnalytics', '重新加载健身统计失败', error, stackTrace);
      if (mounted && ref.read(currentAccountIdProvider) == account) {
        showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  /// 同步中心保留原下载与冲突处理入口，导航失败使用健身统一反馈。
  Future<void> _openSyncCenter() => fitnessRun(context, () async {
    await context.pushNamed(Routes.syncCenter);
  });

  /// 提交周期选择，异常保留当前状态并记录完整错误信息。
  void _changePeriod(AnalyticsPeriod period) {
    try {
      ref.read(fitnessAnalyticsPeriodProvider.notifier).set(period);
    } catch (error, stackTrace) {
      logger.error(
        'FitnessAnalytics',
        '切换健身统计周期失败 period=${period.name}',
        error,
        stackTrace,
      );
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  Widget _section(
    String title,
    List<Widget> children, {
    bool anatomy = false,
  }) => SectionCard(
    padding: EdgeInsets.all(anatomy ? AppDimens.p20 : AppDimens.p12),
    margin: const EdgeInsets.only(bottom: AppDimens.p12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: title, padding: EdgeInsets.zero),
        const SizedBox(height: AppDimens.p12),
        ...children,
      ],
    ),
  );

  Widget _content(
    List<FitnessWorkout> all,
    Map<String, FitnessExerciseDefinition> catalog,
  ) {
    final l = AppLocalizations.of(context);
    final taxonomies = ref.watch(fitnessTaxonomiesProvider);
    final stats = fitnessStatistics(
      all,
      startDate: fitnessDate(_range.start),
      endDate: fitnessDate(_range.end),
      catalog: catalog,
    );
    // 点击人体区域后，只显示该区域实际贡献的分类训练量，分类标识不与解剖区域混用。
    final partVolumes = _part == null
        ? stats.bodyPartVolumeKg
        : stats.anatomyCategoryVolumeKg[_part] ?? {};
    final parts = {...fitnessAnatomyBodyParts, ...partVolumes.keys};
    final yearly = _period == AnalyticsPeriod.year;
    // 横轴刻度时间点：年视图固定 1..12 月，周/月视图为区间内每一天。
    final points = yearly
        ? [
            for (var month = 1; month <= 12; month++)
              DateTime(_selectedDate.year, month),
          ]
        : _rangeDays;
    final dates = [for (final point in points) fitnessDate(point)];
    final axes = buildAnalyticsAxes(
      context: context,
      period: _period,
      points: points,
      isCurrent: _isCurrentRange,
      highlightDate: DateTime.now(),
      dayUnitLabel: l.dayDay,
      monthUnitLabel: l.analyticsMonth,
    );
    // 数据和坐标统一使用小时；年视图按归档月份合并，周月保留每日记录。
    final durationSeries = fitnessDurationSeries(
      stats.durationByDate,
      dates: dates,
      monthly: yearly,
    );
    final number = NumberFormat('#,##0.##', l.localeName);
    final summary = <String, String>{
      l.fitnessTrainingDays: '${stats.trainingDays}',
      l.fitnessTrainingTime: fitnessDuration(stats.totalDuration.inSeconds),
      l.fitnessVolume: '${number.format(stats.volumeKg.toDouble())} kg',
    };
    return ListView(
      key: const PageStorageKey('fitness-analytics-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p12,
        AppDimens.domainPageInset,
        AppDimens.domainBottomClearance,
      ),
      children: [
        _section(l.tabAnalytics, [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in summary.entries)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        entry.key,
                        textAlign: TextAlign.center,
                        style: AppTextTokens.label(context),
                      ),
                      Text(
                        entry.value,
                        textAlign: TextAlign.center,
                        style: AppTextTokens.strongTitle(context),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ]),
        _section(l.fitnessTrainingBodyParts, [
          FitnessBodyMap(
            trainedMuscles: stats.trainedMuscles,
            bodyPartVolumeKg: {
              for (final entry in stats.anatomyVolumeKg.entries)
                entry.key: entry.value.toDouble(),
            },
            selectedPart: _part,
            onSelected: (part) =>
                setState(() => _part = _part == part ? null : part),
          ),
          const SizedBox(height: AppDimens.p12),
          CardTheme(
            data: CardTheme.of(
              context,
            ).copyWith(color: AppTokens.surfaceSecondary(context)),
            child: LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: AppDimens.p8,
                runSpacing: AppDimens.p8,
                children: [
                  for (final part in parts)
                    if (partVolumes.containsKey(part))
                      SizedBox(
                        width: (constraints.maxWidth - AppDimens.p8 * 3) / 4,
                        child: SectionCard(
                          key: ValueKey('fitness-part-volume:$part'),
                          padding: const EdgeInsets.all(AppDimens.p8),
                          margin: EdgeInsets.zero,
                          showShadow: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fitnessCatalogLabel(
                                  l,
                                  part,
                                  taxonomies: taxonomies,
                                ),
                                style: AppTextTokens.label(context),
                              ),
                              const SizedBox(height: AppDimens.p4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${number.format(partVolumes[part]?.toDouble() ?? 0)} kg',
                                  style: AppTextTokens.strongTitle(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ], anatomy: true),
        _section(l.fitnessTrainingDuration, [
          SizedBox(
            height: AppChartTokens.trendHeight,
            child: AnalyticsLineChart(
              key: ValueKey('duration:${_range.start}:${_range.end}'),
              values: durationSeries,
              // 刻度文案、触摸提示与高亮口径与记账统计完全一致
              xLabels: axes.xLabels,
              tooltipLabels: axes.tooltipLabels,
              highlightIndex: axes.highlightIndex,
              xUnitLabel: axes.unitLabel,
              yValueFormatter: (value) => l.fitnessDurationHours(
                NumberFormat('0.##', l.localeName).format(value),
              ),
              valueFormatter: (value) =>
                  fitnessDuration((value * Duration.secondsPerHour).round()),
            ),
          ),
        ]),
      ],
    );
  }
}
