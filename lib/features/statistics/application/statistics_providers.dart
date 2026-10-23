import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';

/// 记账统计与外壳周期入口共享选择，切换业务页签时保留当前周期。
final ledgerAnalyticsPeriodProvider =
    NotifierProvider<SimpleStateNotifier<AnalyticsPeriod>, AnalyticsPeriod>(
      () => SimpleStateNotifier((ref) => AnalyticsPeriod.month),
    );

// 统计：某账本的记账天数与总笔数
final countsForLedgerProvider = FutureProvider.family
    .autoDispose<({int dayCount, int txCount}), String>((ref, ledgerId) async {
      final repo = ref.watch(statisticsDataAccessProvider);
      // 依赖统一数据变更信号触发刷新（任何业务表写入都会自动重算）。
      ref.watch(accountingDataChangeSignalProvider);
      final link = ref.keepAlive();
      try {
        return await repo.getCountsForLedger(ledgerId: ledgerId);
      } finally {
        link.close();
      }
    }, retry: (_, _) => null);

// 统计：月度支出汇总最近值（避免 loading 闪烁），全局仅支出模式
final lastMonthlyTotalsProvider = NotifierProvider.autoDispose
    .family<
      SimpleStateNotifier<double?>,
      double?,
      ({String ledgerId, DateTime month})
    >((params) => SimpleStateNotifier((ref) => null));

// 统计：月度支出汇总（全局仅支出模式，只返回支出金额）
final monthlyTotalsProvider = FutureProvider.family
    .autoDispose<double, ({String ledgerId, DateTime month})>((
      ref,
      params,
    ) async {
      final repo = ref.watch(statisticsDataAccessProvider);
      // 依赖统一数据变更信号触发刷新。
      ref.watch(accountingDataChangeSignalProvider);
      final link = ref.keepAlive();
      try {
        final res = await repo.monthlyTotals(
          ledgerId: params.ledgerId,
          month: params.month,
        );
        // 全局仅支出模式, repo 直接返回 double
        final expense = res;
        // 写入最近一次成功值，供 UI 在刷新期间显示旧值
        if (ref.mounted) {
          ref.read(lastMonthlyTotalsProvider(params).notifier).set(expense);
        }
        return expense;
      } finally {
        link.close();
      }
    }, retry: (_, _) => null);

// 统计：今日支出最近值（避免 loading 闪烁）
final lastTodayExpenseProvider = NotifierProvider.autoDispose
    .family<SimpleStateNotifier<double?>, double?, String>(
      (ledgerId) => SimpleStateNotifier((ref) => null),
    );

// 统计：今日支出（本地时区自然日，全局仅支出模式）
// 当地日期变化时重新计算，页面跨夜停留也不会沿用昨天的金额。
// 首页「本月支出汇总卡」的「今日」列。
final todayExpenseProvider = FutureProvider.family.autoDispose<double, String>((
  ref,
  ledgerId,
) async {
  final repo = ref.watch(statisticsDataAccessProvider);
  final today = ref.watch(localTodayProvider);
  // 依赖统一数据变更信号触发刷新（与 monthlyTotals 同一信号源）。
  ref.watch(accountingDataChangeSignalProvider);
  final link = ref.keepAlive();
  try {
    final expense = await repo.todayExpense(ledgerId: ledgerId, now: today);
    if (ref.mounted) {
      ref.read(lastTodayExpenseProvider(ledgerId).notifier).set(expense);
    }
    return expense;
  } finally {
    link.close();
  }
}, retry: (_, _) => null);

// 统计：本周支出最近值（避免 loading 闪烁）
final lastWeekExpenseProvider = NotifierProvider.autoDispose
    .family<SimpleStateNotifier<double?>, double?, String>(
      (ledgerId) => SimpleStateNotifier((ref) => null),
    );

// 统计：本周支出（周一为起始的自然周，全局仅支出模式）
// 首页「本月支出汇总卡」的「本周」列。
final weekExpenseProvider = FutureProvider.family.autoDispose<double, String>((
  ref,
  ledgerId,
) async {
  final repo = ref.watch(statisticsDataAccessProvider);
  final today = ref.watch(localTodayProvider);
  ref.watch(accountingDataChangeSignalProvider);
  final link = ref.keepAlive();
  try {
    final expense = await repo.weekExpense(ledgerId: ledgerId, now: today);
    if (ref.mounted) {
      ref.read(lastWeekExpenseProvider(ledgerId).notifier).set(expense);
    }
    return expense;
  } finally {
    link.close();
  }
}, retry: (_, _) => null);

// ---------- 统计页（AnalyticsPage）专用 provider ----------

/// 统计页：当前账本是否有任意支出交易（区分全局空数据 vs 局部空数据）。
/// watch 统一数据变更信号，确保任意写库路径（同步/导入等）后重判。
final analyticsHasAnyExpenseProvider = FutureProvider<bool>((ref) async {
  ref.watch(accountingDataChangeSignalProvider);
  final ledger = ref.watch(currentLedgerProvider).value;
  if (ledger == null) return false;
  final repo = ref.watch(statisticsDataAccessProvider);
  return repo.hasAnyExpenseTx(ledgerId: ledger.id);
});

/// 统计页：当前账本支出交易的最早/最晚时间（本地时区），用于子 Tab 按真实
/// 数据范围生成。无数据返回 (null, null)。
final analyticsDataRangeProvider =
    FutureProvider<({DateTime? earliest, DateTime? latest})>((ref) async {
      ref.watch(accountingDataChangeSignalProvider);
      final ledger = ref.watch(currentLedgerProvider).value;
      if (ledger == null) return (earliest: null, latest: null);
      final repo = ref.watch(statisticsDataAccessProvider);
      final results = await Future.wait<dynamic>([
        repo.earliestExpenseDate(ledgerId: ledger.id),
        repo.latestExpenseDate(ledgerId: ledger.id),
      ]);
      return (
        earliest: results[0] as DateTime?,
        latest: results[1] as DateTime?,
      );
    });
