import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart' show isSameDay;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart'
    show CategoryDisplay, TransactionDisplay;
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_home_cards.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/memo_detail_sheet.dart';
import 'package:sesame_notes/features/memos/presentation/widgets/memo_entry_tile.dart';
import 'package:sesame_notes/features/statistics/application/calendar_providers.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_edit_utils.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/calendar_entry_scope.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';

/// 跨业务日历共用月份、选中日和展示组件，各业务保留各自的数据权限与日期规则。
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key, this.onBack});

  /// 共享日历标题行的返回入口由业务壳恢复原业务和页签。
  final VoidCallback? onBack;
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _month;
  int _memoLimit = 50;
  int _transactionLimit = 50;

  /// 初始月份跟随共用日期状态，跨业务入口只保留一个页面实例。
  @override
  void initState() {
    super.initState();
    final date = ref.read(calendarSelectedDateProvider);
    _month = DateTime(date.year, date.month);
  }

  /// 选日同时更新月份与明细分页，点击相邻月日期不会查询错误月份。
  void _select(DateTime date, {bool userSelected = false}) {
    if (userSelected) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: 'calendar',
            action: ProductAction.calendarDaySelect,
          );
    }
    ref
        .read(calendarSelectedDateProvider.notifier)
        .set(DateUtils.dateOnly(date));
    setState(() {
      _month = DateTime(date.year, date.month);
      _memoLimit = _transactionLimit = 50;
    });
  }

  /// 刷新动作分别捕获错误，任何业务失败都不阻断其他已加载内容。
  Future<void> _refresh() => ensureMinimumRefreshDuration(() async {
    final l = AppLocalizations.of(context);
    for (final action in <Future<void> Function()>[
      () async {
        final result = await ref.read(syncCoordinatorProvider).refreshData();
        if (!result.ok) {
          throw StateError(result.error ?? l.commonOperationFailed);
        }
      },
      if (ref.read(currentFitnessSpaceIdProvider).value != null)
        () => ref.read(fitnessActionsProvider).refreshLocalSnapshot(),
    ]) {
      try {
        await action();
      } catch (error, stack) {
        logger.error('UnifiedCalendar', '刷新业务数据失败', error, stack);
        if (mounted) showToast(context, l.commonOperationFailed);
      }
      if (!mounted) return;
    }
    ref.invalidate(unifiedMemoCountsProvider);
    ref.invalidate(memoEntriesProvider);
    ref.invalidate(dayEventsProvider);
  });

  /// 本子未就绪、加载失败和空本保持不同状态，避免切本时闪现其他本的记录。
  AsyncValue<Map<DateTime, int>> _counts(AsyncValue<MemoBook?> book) =>
      book.when(
        data: (book) => book == null
            ? const AsyncData({})
            : !book.isComplete || book.isStale
            ? const AsyncData({})
            : ref.watch(
                unifiedMemoCountsProvider((bookId: book.id, month: _month)),
              ),
        error: (error, stack) => AsyncError(error, stack),
        loading: () => const AsyncLoading(),
      );

  /// 多取一条确定是否显示继续加载，数量标记独立查询所以不会被分页截断。
  AsyncValue<List<MemoEntry>> _memos(
    AsyncValue<MemoBook?> book,
    DateTime date,
  ) => book.when(
    data: (book) => book == null
        ? const AsyncData([])
        : !book.isComplete || book.isStale
        ? const AsyncData([])
        : ref.watch(
            memoEntriesProvider((
              bookId: book.id,
              date: date,
              limit: _memoLimit + 1,
            )),
          ),
    error: (error, stack) => AsyncError(error, stack),
    loading: () => const AsyncLoading(),
  );

  /// 月历始终可操作，明细按业务分段加载与重试，正常数据不受其他业务错误影响。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = ref.watch(calendarSelectedDateProvider);
    final ledgerId = ref.watch(currentLedgerIdProvider);
    final ledger = ref.watch(currentLedgerDisplayProvider).asData?.value;
    // 符号与统计必须来自同一本账本，切本加载期间不沿用上一本的币种。
    final currencySymbol = ledger?.id == ledgerId
        ? getCurrencySymbol(ledger!.currency)
        : null;
    final totals = ref.watch(
      unifiedCalendarTotalsProvider((ledgerId: ledgerId, month: _month)),
    );
    final transactions = ref.watch(
      transactionsByDateProvider((ledgerId: ledgerId, date: selected)),
    );
    final days = ref.watch(calendarDayEventsProvider(_month));
    final normalBook = ref.watch(currentMemoBookProvider);
    final credentialBook = ref.watch(currentCredentialBookProvider);
    final noteCounts = _counts(normalBook);
    final credentialCounts = _counts(credentialBook);
    final notes = _memos(normalBook, selected);
    final credentials = _memos(credentialBook, selected);
    final grid = calendarGridRange(_month);
    final workoutRange = (start: grid.start, until: grid.until, calendar: true);
    final workouts = ref.watch(fitnessWorkoutsInRangeProvider(workoutRange));
    final plans = ref.watch(fitnessCalendarPlansProvider);
    final byDate = <String, List<FitnessWorkout>>{};
    for (final workout in workouts.asData?.value ?? <FitnessWorkout>[]) {
      // 安排日和完成归档日均保留，同日通过集合去重。
      for (final date in {
        workout.scheduledDate,
        if (workout.status == 'completed') fitnessWorkoutDate(workout),
      }) {
        byDate.putIfAbsent(date, () => []).add(workout);
      }
    }
    final rests = <String, List<FitnessRestDay>>{};
    for (final rest in fitnessCalendarRestDays(plans.asData?.value ?? [])) {
      rests.putIfAbsent(rest.date, () => []).add(rest);
    }
    final dateKey = fitnessDate(selected);
    final today = ref.watch(dayTodayProvider);
    final currentDay = DateTime(today.year, today.month, today.day);
    final children = <Widget>[
      if ([
        normalBook.asData?.value,
        credentialBook.asData?.value,
      ].any((book) => book != null && (!book.isComplete || book.isStale)))
        Padding(
          padding: const EdgeInsets.all(AppDimens.p12),
          child: Text(l.memoDownloadRequired),
        ),
      _status(
        totals,
        l.tabHome,
        () => ref.invalidate(dailyTotalsByMonthProvider),
      ),
      _status(
        noteCounts,
        l.calendarNote,
        () => ref.invalidate(unifiedMemoCountsProvider),
      ),
      _status(
        credentialCounts,
        l.calendarCredential,
        () => ref.invalidate(unifiedMemoCountsProvider),
      ),
      _status(
        transactions,
        l.tabHome,
        () => ref.invalidate(transactionsByDateProvider),
      ),
      for (final row in (transactions.asData?.value ?? []).take(
        _transactionLimit,
      ))
        _transaction(row),
      if ((transactions.asData?.value.length ?? 0) > _transactionLimit)
        TextButton(
          onPressed: () => setState(() => _transactionLimit += 50),
          child: Text(l.fitnessViewAll),
        ),
      _status(
        days,
        l.calendarAnniversary,
        () => ref.invalidate(dayEventsProvider),
      ),
      for (final event in days.asData?.value.byDate[dateKey] ?? [])
        _card(DayEventListItem(event: event, today: today)),
      for (final event in days.asData?.value.invalid ?? [])
        _card(DayInvalidEventTile(event: event)),
      _status(notes, l.calendarNote, () => ref.invalidate(memoEntriesProvider)),
      for (final note in (notes.asData?.value ?? []).take(_memoLimit))
        _memo(note),
      _status(
        credentials,
        l.calendarCredential,
        () => ref.invalidate(memoEntriesProvider),
      ),
      for (final note in (credentials.asData?.value ?? []).take(_memoLimit))
        _memo(note),
      if ((notes.asData?.value.length ?? 0) > _memoLimit ||
          (credentials.asData?.value.length ?? 0) > _memoLimit)
        TextButton(
          onPressed: () => setState(() => _memoLimit += 50),
          child: Text(l.fitnessViewAll),
        ),
      _status(
        workouts,
        l.calendarTraining,
        () => ref.invalidate(fitnessWorkoutsInRangeProvider),
      ),
      _status(
        plans,
        l.calendarPlan,
        () => ref.invalidate(fitnessCalendarPlansProvider),
      ),
      for (final workout in byDate[dateKey] ?? <FitnessWorkout>[])
        FitnessHomeWorkoutCard(key: ValueKey(workout.id), workout: workout),
      for (final rest in rests[dateKey] ?? <FitnessRestDay>[])
        FitnessRestDayCard(planName: rest.sourcePlanName),
    ];
    final loaded = [
      transactions,
      days,
      notes,
      credentials,
      workouts,
      plans,
    ].every((state) => state.hasValue && !state.hasError);
    final empty =
        (transactions.asData?.value.isEmpty ?? true) &&
        (days.asData?.value.byDate[dateKey]?.isEmpty ?? true) &&
        (days.asData?.value.invalid.isEmpty ?? true) &&
        (notes.asData?.value.isEmpty ?? true) &&
        (credentials.asData?.value.isEmpty ?? true) &&
        (byDate[dateKey]?.isEmpty ?? true) &&
        (rests[dateKey]?.isEmpty ?? true);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          AppCalendarHeader(
            title: l.tabCalendar,
            selectedDay: selected,
            focusedDay: _month,
            currentDay: currentDay,
            onToday: () => _select(currentDay),
            onBack: widget.onBack,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CalendarEntryScope(
                child: ListView(
                  key: const PageStorageKey('unified-calendar'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.p12,
                    AppDimens.p8,
                    AppDimens.p12,
                    AppDimens.domainBottomClearance,
                  ),
                  children: [
                    SectionCard(
                      margin: EdgeInsets.zero,
                      child: AppCalendar<Object>(
                        firstDay: DateTime(1900),
                        lastDay: DateTime(2200, 12, 31),
                        focusedDay: _month,
                        currentDay: currentDay,
                        adaptiveRows: true,
                        selectedDayPredicate: (date) =>
                            isSameDay(date, selected),
                        onDaySelected: (date, _) =>
                            _select(date, userSelected: true),
                        onPageChanged: _select,
                        dayMarkerBuilder: (context, date, outside) {
                          final key = fitnessDate(date);
                          final day = DateUtils.dateOnly(date);
                          final amount = totals.asData?.value[key];
                          final labels = <String>[
                            for (final event
                                in days.asData?.value.byDate[key] ?? [])
                              event.definition.name,
                            if ((noteCounts.asData?.value[day] ?? 0) > 0)
                              '${l.calendarNote} ${noteCounts.asData!.value[day]}',
                            if ((credentialCounts.asData?.value[day] ?? 0) > 0)
                              '${l.calendarCredential} ${credentialCounts.asData!.value[day]}',
                            for (final workout
                                in byDate[key] ?? <FitnessWorkout>[])
                              workout.name,
                            for (final _ in rests[key] ?? <FitnessRestDay>[])
                              l.fitnessRestDay,
                          ];
                          // 无支出的日期也保留金额行，让同一周的首条业务标签对齐。
                          return AppCalendarDayMarkers(
                            amountText:
                                amount != null &&
                                    amount > 0 &&
                                    currencySymbol != null
                                ? '-$currencySymbol${formatChartValueLabel(amount)}'
                                : null,
                            labels: labels,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimens.p12),
                    AppCalendarDateSectionHeader(date: selected),
                    if (loaded && empty) _card(const AppCalendarEmptyDay()),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 同款外壳只承载没有自带卡片的明细，避免嵌套卡片叠加内边距。
  Widget _card(Widget child) => SectionCard(
    margin: const EdgeInsets.only(bottom: AppDimens.p8),
    padding: EdgeInsets.zero,
    child: child,
  );

  /// 交易继续使用原编辑入口，币种、备注和协作字段由现有组件解释。
  Widget _transaction(
    ({TransactionDisplay t, CategoryDisplay? category}) row,
  ) => _card(
    TransactionListItem(
      ledgerId: row.t.ledgerId,
      category: row.category,
      title: row.t.note ?? '',
      categoryName:
          row.category?.name ??
          AppLocalizations.of(context).commonUncategorized,
      amount: row.t.amount,
      currencyCode: row.t.currencyCode,
      nativeAmount: row.t.nativeAmount,
      happenedAt: row.t.happenedAt,
      onTap: () => TransactionEditUtils.editTransaction(context, ref, row.t),
    ),
  );

  /// 打开备忘录时由既有动作重新验证目标本和账号，列表摘要不当作完整正文。
  Widget _memo(MemoEntry entry) => _card(
    MemoEntryTile(
      entry: entry,
      onTap: () => openMemoEntry(context, ref, entry),
    ),
  );

  /// 业务错误包含业务名称与重试，日志记录堆栈但不输出笔记正文或密码。
  Widget _status<T>(AsyncValue<T> state, String label, VoidCallback retry) {
    if (state.hasError) {
      logger.error(
        'UnifiedCalendar',
        '加载业务失败 $label',
        state.error,
        state.stackTrace,
      );
      return AppLoadError(
        message:
            '$label · ${AppLocalizations.of(context).commonOperationFailed}',
        onRetry: retry,
      );
    }
    if (state.isLoading && !state.hasValue) {
      return const AppCalendarEntriesSkeleton();
    }
    return const SizedBox.shrink();
  }
}
