import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/statistics/application/analytics_queries.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/utils/date/month_range.dart';
import 'package:sesame_notes/utils/date/week_math.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/shared/presentation/analytics_axes.dart';
import 'package:sesame_notes/shared/presentation/analytics_summary.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 账单统计页：底部切换周期，金额、趋势与分类采用独立卡片。
class AnalyticsPage extends ConsumerStatefulWidget {
  /// 业务壳提供导航，统计正文使用统一账期工具栏。
  const AnalyticsPage({super.key, this.embedded = false});

  /// 嵌入业务壳时，底部周期和新增操作由外壳统一排列。
  final bool embedded;

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  /// 页面和外壳读取同一周期，日期选择仍由页面按周期独立保存。
  AnalyticsPeriod get _period => ref.read(ledgerAnalyticsPeriodProvider);
  // 全局仅支出模式，统计页只呈现支出
  final String _type = 'expense';

  // 各父级周期独立记忆的选中子周期，避免切换父级后丢失选择
  late DateTime _selMonth; // 月视图：选中的账期（label month）
  late int _selYear; // 年视图：选中的年份
  late DateTime _selWeekStart; // 周视图：选中的周一（周起点）

  // 缓存统计 Future，避免每次页面重建重复发起查询。
  // 仅在依赖参数变化时重建。
  Future<AnalyticsData>? _dataFuture;
  // 上一次刷新计数与账本 id 快照：用于检测「数据或账本已变更」，
  // 保存/删除/导入/清空/切换账本后必须让缓存 Future 失效，否则 FutureBuilder 始终消费旧数据。
  // 统一数据变更信号（AsyncValue），任一业务表写入都会产生新实例。
  Object? _lastDataSignal;
  String? _lastLedgerId;
  int? _lastMonthStartDay;
  AnalyticsPeriod? _lastPeriod;
  DateTime? _lastToday;
  // 重试 tick：错误态点击重试时 +1，触发 Future 重建。
  int _retryTick = 0;
  // 一键补折算进行中：禁用按钮，防止并发触发多次重算写入。
  bool _recalcBusy = false;

  @override
  void initState() {
    super.initState();
    // 初始默认账期取自全局选中的账期（与首页保持一致）
    _selMonth = ref.read(selectedMonthProvider);
    final now = DateTime.now();
    _selYear = labelForDate(now, ref.read(currentMonthStartDayProvider)).year;
    _selWeekStart = mondayOf(now);
  }

  /// 当前选中账期的时间范围；当前周期截断到今天，历史周期取完整区间。
  ({DateTime start, DateTime end, bool isCurrent}) _currentRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sd = ref.read(currentMonthStartDayProvider);
    switch (_period) {
      case AnalyticsPeriod.week:
        // 周视图始终展示完整 7 天，使图表轴稳定（含未来天=0）
        final start = _selWeekStart;
        final isCurrent = start == mondayOf(now);
        return (
          start: start,
          end: DateTime(start.year, start.month, start.day + 7),
          isCurrent: isCurrent,
        );
      case AnalyticsPeriod.year:
        final range = yearRangeFor(_selYear, sd);
        final isCurrent = !now.isBefore(range.start) && now.isBefore(range.end);
        final end = isCurrent
            ? DateTime(today.year, today.month, today.day + 1)
            : range.end;
        return (start: range.start, end: end, isCurrent: isCurrent);
      case AnalyticsPeriod.month:
        final range = periodForLabel(_selMonth.year, _selMonth.month, sd);
        final nowLabel = labelForDate(now, sd);
        final isCurrent =
            _selMonth.year == nowLabel.year &&
            _selMonth.month == nowLabel.month;
        final end = isCurrent
            ? DateTime(today.year, today.month, today.day + 1)
            : range.end;
        return (start: range.start, end: end, isCurrent: isCurrent);
    }
  }

  /// 一键回到当前周期（本周/本月/今年）。
  /// 当用户在非当前周期浏览时，点击头部「回到本周/月/年」文字链调用此方法。
  void _jumpToCurrentPeriod() {
    final now = DateTime.now();
    final sd = ref.read(currentMonthStartDayProvider);
    setState(() {
      switch (_period) {
        case AnalyticsPeriod.week:
          _selWeekStart = mondayOf(now);
        case AnalyticsPeriod.month:
          final nowLabel = labelForDate(now, sd);
          _selMonth = DateTime(nowLabel.year, nowLabel.month, 1);
        case AnalyticsPeriod.year:
          _selYear = labelForDate(now, sd).year;
      }
      _dataFuture = null;
    });
  }

  /// 固定本次选择后交由统计应用层取数，页面只持有展示所需的结果。
  Future<AnalyticsData> _loadData() {
    final current = _currentRange();
    return ref
        .read(analyticsQueriesProvider)
        .load(
          ledgerId: ref.read(currentLedgerIdProvider),
          type: _type,
          period: _period,
          selectedYear: _selYear,
          monthStartDay: ref.read(currentMonthStartDayProvider),
          current: (start: current.start, end: current.end),
        );
  }

  DateTime get _selectedDate => switch (_period) {
    AnalyticsPeriod.week => _selWeekStart,
    AnalyticsPeriod.month => _selMonth,
    AnalyticsPeriod.year => DateTime(_selYear),
  };

  /// 日期入口、子周期和趋势横滑共用选择入口，统一刷新查询缓存。
  void _selectDate(DateTime date) => setState(() {
    switch (_period) {
      case AnalyticsPeriod.week:
        _selWeekStart = mondayOf(date);
      case AnalyticsPeriod.month:
        _selMonth = DateTime(date.year, date.month);
      case AnalyticsPeriod.year:
        _selYear = date.year;
    }
    _dataFuture = null;
  });

  /// 按当前维度移动一个完整周期，月账期使用标签月避免自定义起始日偏移。
  void _movePeriod(int direction) {
    try {
      final date = _selectedDate;
      _selectDate(switch (_period) {
        AnalyticsPeriod.week => DateTime(
          date.year,
          date.month,
          date.day + direction * 7,
        ),
        AnalyticsPeriod.month => DateTime(date.year, date.month + direction),
        AnalyticsPeriod.year => DateTime(date.year + direction),
      });
    } catch (error, stackTrace) {
      logger.error('Analytics', '切换统计周期失败', error, stackTrace);
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }

  /// 构建数据范围内的子周期，同时保留正在浏览的无记录周期。
  List<AnalyticsSubTab> _buildSubTabs() {
    final range = ref.read(analyticsDataRangeProvider).value;
    final l10n = AppLocalizations.of(context);
    return generateSubTabs(
      period: _period,
      earliest: range?.earliest,
      latest: range?.latest,
      now: DateTime.now(),
      selectedDate: _selectedDate,
      monthStartDay: ref.read(currentMonthStartDayProvider),
      // 复用共享月份标签（与首页日期组件完全一致，补零为两位数如 01月）
      monthLabel: (m) => monthLabel(context, m),
      weekNLabel: (n) => l10n.analyticsWeekN(n),
      thisWeekLabel: l10n.analyticsThisWeek,
      // 年子 Tab 复用 homeYear，与顶部账期表头（2026年）口径一致，避免裸数字
      yearLabel: (y) => l10n.homeYear(y),
    );
  }

  /// 当前选中子 Tab 的 id（用于高亮 + 滚动定位）
  String _currentSubTabId() {
    switch (_period) {
      case AnalyticsPeriod.month:
        return '${_selMonth.year}-${_selMonth.month.toString().padLeft(2, '0')}';
      case AnalyticsPeriod.year:
        return '$_selYear';
      case AnalyticsPeriod.week:
        return '${_selWeekStart.year}-W${weekNumber(_selWeekStart)}';
    }
  }

  /// 子周期起点与标签同属一个月份或年份，可直接同步到日期选择状态。
  void _onSubTabTap(AnalyticsSubTab tab) => _selectDate(tab.start);

  /// 确保 Future 缓存：仅在依赖参数变化时重建。
  void _ensureFuture() {
    if (_dataFuture != null) return;
    _dataFuture = _loadData();
  }

  /// 下拉刷新当前账本；存储模式与云同步细节统一由同步编排器判断。
  Future<void> _refreshData() async {
    final l10n = AppLocalizations.of(context);
    try {
      // 最小展示 1 秒：本地账本瞬时重查也会让指示器完整转一圈再收起。
      final result = await ensureMinimumRefreshDuration(
        // 刷新哪个账本由 application 层统一入口决定，页面不自行拼参数。
        () => ref.read(ledgerActionsProvider).refreshCurrentLedger(),
      );
      if (!mounted || result.ok) return;
      logger.warning('Analytics', '下拉刷新云端数据失败: ${result.error}');
      showToast(
        context,
        result.error ?? l10n.commonOperationFailed,
        duration: const Duration(milliseconds: 1500),
      );
    } catch (e, st) {
      logger.error('Analytics', '下拉刷新失败', e, st);
      if (!mounted) return;
      showToast(
        context,
        cloudOperationErrorMessage(e, fallback: l10n.commonOperationFailed),
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  /// 周期、账本或数据变化时更新统计查询，并保留各周期的日期选择。
  @override
  Widget build(BuildContext context) {
    // 监听统一数据变更信号，交易增删改/导入/清空/同步后重新统计
    final dataSignal = ref.watch(dataChangeSignalProvider);
    // 同时监听当前账本：切换账本后统计页必须整体重算，否则仍显示旧账本数据
    final ledgerId = ref.watch(currentLedgerIdProvider);
    final monthStartDay = ref.watch(currentMonthStartDayProvider);
    final period = ref.watch(ledgerAnalyticsPeriodProvider);
    final today = ref.watch(localTodayProvider);
    // 账本、账期设置或数据版本变化时重新查询，避免沿用旧范围的统计结果。
    if (dataSignal != _lastDataSignal ||
        ledgerId != _lastLedgerId ||
        monthStartDay != _lastMonthStartDay ||
        period != _lastPeriod ||
        today != _lastToday) {
      _lastDataSignal = dataSignal;
      _lastLedgerId = ledgerId;
      _lastMonthStartDay = monthStartDay;
      _lastPeriod = period;
      _lastToday = today;
      _dataFuture = null;
    }
    final primary = Theme.of(context).colorScheme.primary;

    // 全局空数据判定：无任何支出交易时 Header 禁用点击
    final hasAnyDataAsync = ref.watch(analyticsHasAnyExpenseProvider);
    final hasAnyData = hasAnyDataAsync.value ?? false;
    // watch 数据范围 provider：resolve 后触发重建，让子 Tab 按真实范围生成
    ref.watch(analyticsDataRangeProvider);

    // 判断当前选中的周期是否为「本周/本月/今年」；
    // 非当前周期时在头部显示「回到本周/月/年」文字链。
    final bool isCurrentPeriod = _currentRange().isCurrent;

    // 全局空数据（无任何支出交易）：直接渲染完整空页面，不进入加载态。
    // 默认周期始终保持「月」，不强制切周——用户可自由切换父级周期。
    final bool globalEmpty = hasAnyDataAsync.hasValue && !hasAnyData;

    // 仅非全局空数据时才构建并缓存数据 Future；空数据态无需拉取数据，避免切换父Tab闪屏。
    if (!globalEmpty) {
      _ensureFuture();
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 首行：全局统一头部组件（账期标题可点击拉起周期选择）。
              // 全局空数据时禁用点击 + 隐藏下拉箭头：
              // onTitleTap 为 null 即纯文本无热区，与 IgnorePointer 禁用态外观一致。
              AppAnalyticsPeriodHeader(
                period: _period,
                selectedDate: _selectedDate,
                isCurrent: isCurrentPeriod,
                hasData: hasAnyData,
                tabs: _buildSubTabs(),
                selectedTabId: _currentSubTabId(),
                onDateChanged: _selectDate,
                onTabChanged: _onSubTabTap,
                onCurrent: _jumpToCurrentPeriod,
              ),
              _buildRecalcForeignBanner(context),
              _buildConvertedFootnote(context),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  // 全局空数据：直接渲染完整空页面，周期选择仍可操作。
                  // 不进入加载态，切换父级周期也不会闪屏。
                  child: globalEmpty
                      ? _buildEmpty(primary)
                      : FutureBuilder<AnalyticsData>(
                          key: ValueKey(
                            '$ledgerId-$monthStartDay-$_period-$_selMonth-$_selYear-$_selWeekStart-$_type-$_retryTick',
                          ),
                          future: _dataFuture,
                          builder: (context, snapshot) {
                            // 错误态：显示重试 UI
                            if (snapshot.hasError) {
                              return _buildError();
                            }
                            // 加载态：骨架屏近似最终布局
                            if (!snapshot.hasData) {
                              return _buildSkeleton();
                            }
                            final data = snapshot.data!;
                            // 空态判定：以交易笔数为准
                            if (data.txCount == 0) {
                              return _buildEmpty(primary);
                            }
                            return _buildContent(data, primary);
                          },
                        ),
                ),
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
                  onChanged: ref
                      .read(ledgerAnalyticsPeriodProvider.notifier)
                      .set,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 加载态骨架屏：近似最终布局，避免 CircularProgressIndicator 的突兀感。
  Widget _buildSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p8,
        AppDimens.domainPageInset,
        AppDimens.domainBottomClearance,
      ),
      children: [
        SkeletonBar(height: 18, width: 100),
        const SizedBox(height: AppDimens.p12),
        SkeletonBar(height: AppDimens.p40, widthFactor: 0.5),
        const SizedBox(height: AppDimens.p12),
        SkeletonBar(height: AppChartTokens.ledgerTrendHeight, widthFactor: 1),
        const SizedBox(height: AppDimens.p20),
        SkeletonBar(height: 18, width: 80),
        const SizedBox(height: AppDimens.p12),
        SkeletonBar(height: 200, widthFactor: 1),
        const SizedBox(height: AppDimens.p12),
        for (var i = 0; i < 4; i++) const SkeletonListTile(),
      ],
    );
  }

  /// 加载失败共用错误反馈，重试时重新创建统计查询。
  Widget _buildError() => AppLoadError(
    onRetry: () => setState(() {
      _retryTick++;
      _dataFuture = null;
    }),
  );

  /// 图表主体内容（有数据 / 空数据共用）：支出趋势模块 + 分类排行模块。
  /// 空数据态保留趋势与分类容器，金额、币种和分类详情沿用原始统计结果。
  Widget _buildMainContent({
    required List<DonutCategory> donutData,
    required List<AnalyticsCategoryTotal> catData,
    required List<double> values,
    required AnalyticsAxes axes,
    required double sum,
    required Color primary,
  }) {
    final l10n = AppLocalizations.of(context);
    final cur = _currentRange();
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p8,
        AppDimens.domainPageInset,
        AppDimens.domainPageInset,
      ),
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.analyticsTotalExpenseLabel,
                style: AppTextTokens.label(context),
              ),
              const SizedBox(height: AppDimens.p4),
              Align(
                alignment: Alignment.centerLeft,
                child: AmountText(
                  value: sum,
                  signed: false,
                  showCurrency: true,
                  scaleDown: true,
                  style: AppTextTokens.display3(context),
                ),
              ),
              const SizedBox(height: AppDimens.p12),
              SizedBox(
                height: AppChartTokens.ledgerTrendHeight,
                child: AnalyticsLineChart(
                  values: values,
                  xLabels: axes.xLabels,
                  tooltipLabels: axes.tooltipLabels,
                  currencyCode: ref.watch(currentLedgerCurrencyProvider),
                  highlightIndex: axes.highlightIndex,
                  xUnitLabel: axes.unitLabel,
                  onPeriodSwipe: _movePeriod,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.p20),
        Text(
          l10n.analyticsCategoryLabel,
          style: AppTextTokens.strongTitle(context),
        ),
        const SizedBox(height: AppDimens.p12),
        SectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryDonutChart(data: donutData, sum: sum),
              const SizedBox(height: AppDimens.p8),
              for (final item in catData)
                CategoryRankRow(
                  categoryId: item.id,
                  category: item.category,
                  name: item.name,
                  value: item.total,
                  percent: sum == 0 ? 0 : item.total / sum,
                  color: primary,
                  onCategoryTap: (categoryId, categoryName) =>
                      _openCategoryDetail(categoryId, categoryName, cur),
                  subCategories: item.subCategories,
                ),
              if (catData.isEmpty) ..._buildCategorySkeleton(),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.domainBottomClearance),
      ],
    );
  }

  /// 打开分类详情页（导航放在 page 层以保持 pages → widgets 单向依赖；
  /// 周期标签在这里按统计范围重新生成后透传）。
  Future<void> _openCategoryDetail(
    String categoryId,
    String categoryName,
    ({DateTime start, DateTime end, bool isCurrent}) cur,
  ) async {
    final scope = _period.name;
    final selMonth = _period == AnalyticsPeriod.week
        ? _selWeekStart
        : _selMonth;

    // 生成周期标签
    String? periodLabel;
    if (scope != 'all') {
      periodLabel = switch (scope) {
        // 年视图直接使用 _selYear，避免沿用月视图残留的 _selMonth 造成标签错位。
        'year' => '$_selYear',
        // 周视图：用选中周一展示该周区间（周一 ~ 周日）
        'week' => () {
          final end = DateTime(selMonth.year, selMonth.month, selMonth.day + 6);
          return '${selMonth.month}/${selMonth.day}~${end.month}/${end.day}';
        }(),
        _ => '${selMonth.year}.${selMonth.month.toString().padLeft(2, '0')}',
      };
    }

    try {
      await context.pushNamed(
        Routes.categoryDetail,
        queryParameters: {'ledgerId': ref.read(currentLedgerIdProvider)},
        extra: (
          categoryId,
          categoryName,
          scope != 'all' ? cur.start : null,
          scope != 'all' ? cur.end : null,
          periodLabel,
        ),
      );
    } catch (error, stackTrace) {
      logger.error('AnalyticsPage', '打开分类明细失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 分类占位保留固定行数，图标与文字骨架复用全局明细行。
  List<Widget> _buildCategorySkeleton() => List.generate(
    4,
    (_) => const SkeletonListTile(
      iconSize: AppDimens.icon28,
      padding: EdgeInsets.only(bottom: AppDimens.p8),
    ),
  );

  /// 有数据的主体内容
  Widget _buildContent(AnalyticsData data, Color primary) {
    final l10n = AppLocalizations.of(context);
    final cur = _currentRange();
    // 根据序列的具体类型读取刻度，年视图始终保留十二个月的坐标轴。
    final sd = ref.read(currentMonthStartDayProvider);
    final (values, axisPoints) = switch (data.series) {
      DailyAnalyticsSeries(:final points) => (
        [for (final point in points) point.total],
        [for (final point in points) point.day],
      ),
      MonthlyAnalyticsSeries(:final points) => (
        [
          for (final point in truncateYearSeriesToCurrentMonth(
            series: points,
            selectedYear: _selYear,
            currentLabel: labelForDate(DateTime.now(), sd),
          ))
            point.total,
        ],
        [for (var month = 1; month <= 12; month++) DateTime(_selYear, month)],
      ),
    };
    final now = DateTime.now();
    final axes = buildAnalyticsAxes(
      context: context,
      period: _period,
      points: axisPoints,
      isCurrent: cur.isCurrent,
      // 年视图按账期标签月对齐今天：自定义月起始日时今天属于上一个标签月
      highlightDate: _period == AnalyticsPeriod.year
          ? labelForDate(now, sd)
          : now,
      dayUnitLabel: l10n.dayDay,
      monthUnitLabel: l10n.analyticsMonth,
    );

    final donutData = buildDonutCategories(
      categories: [
        for (final c in data.catData)
          (name: CategoryUtils.getDisplayName(c.name, context), total: c.total),
      ],
      total: data.sum,
      otherLabel: l10n.commonOther,
    );

    return _buildMainContent(
      donutData: donutData,
      catData: data.catData,
      values: values,
      axes: axes,
      sum: data.sum,
      primary: primary,
    );
  }

  /// 空数据态保留日期导航、趋势刻度和分类容器，底部周期选择始终可用。
  /// 趋势图为空、环图居中显示零，分类列表只保留占位。
  Widget _buildEmpty(Color primary) {
    return _buildMainContent(
      donutData: const [],
      catData: const [],
      values: const [],
      // 空数据态没有刻度，也不显示周期单位
      axes: (
        xLabels: const <String>[],
        tooltipLabels: const <String>[],
        highlightIndex: null,
        unitLabel: null,
      ),
      sum: 0,
      primary: primary,
    );
  }

  /// 外币补折算横幅：账本存在未折算外币交易时提示，并可一键补折算
  Widget _buildRecalcForeignBanner(BuildContext context) {
    final count = ref.watch(ledgerUnconvertedForeignTxCountProvider).value ?? 0;
    if (count <= 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p4,
        AppDimens.domainPageInset,
        0,
      ),
      child: AppStatusBanner(
        inset: true,
        icon: AppIcons.currencyExchange,
        message: l10n.recalcForeignTxBanner,
        action: TextButton(
          onPressed: _recalcBusy ? null : () => _runRecalcForeignTx(count),
          child: Text(l10n.recalcForeignTxAction),
        ),
      ),
    );
  }

  /// 折算脚注：账本存在外币交易（含已折算）时，提示统计数字已折本位币
  Widget _buildConvertedFootnote(BuildContext context) {
    final count = ref.watch(ledgerForeignTxCountProvider).value ?? 0;
    if (count <= 0) return const SizedBox.shrink();
    final base = ref.watch(currentLedgerCurrencyProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p4,
        AppDimens.domainPageInset,
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context).statsConvertedFootnote(base),
          style: AppTextTokens.caption(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
      ),
    );
  }

  /// 一键补折算：先刷新本位币汇率组，再按最新汇率重算账本内所有外币交易。
  ///
  /// 折算期间置 _recalcBusy 禁用按钮，避免并发触发多次重算写入；
  /// 失败时弹友好提示并记日志，异常不冒泡到框架层。
  Future<void> _runRecalcForeignTx(int count) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.recalcForeignTxAction,
      message: l10n.recalcSyncCountHint(count),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _recalcBusy = true);
    try {
      // 汇率组刷新与重算的编排统一由 application 层承载。
      final n = await ref
          .read(ledgerActionsProvider)
          .recalcForeignTxWithLatestRates(ref.read(currentLedgerIdProvider));
      if (!mounted) return;
      showToast(context, l10n.recalcForeignTxDone(n));
      // 汇总/统计刷新由统一数据变更信号自动驱动（重算即写库）。
    } catch (e, st) {
      logger.error('AnalyticsPage', '一键补折算失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _recalcBusy = false);
      }
    }
  }
}
