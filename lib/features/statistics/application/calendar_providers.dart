import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
// 精确导入而非 barrel 自引用，避免 providers.dart export 本文件时形成循环依赖
import 'package:sesame_notes/shared/providers/database_signals.dart';

/// 获取指定月份的每日统计
/// 参数: (ledgerId, month)
final dailyTotalsByMonthProvider = FutureProvider.autoDispose
    .family<Map<String, double>, ({String ledgerId, DateTime month})>((
      ref,
      params,
    ) async {
      // 监听统一数据变更信号：任意业务表写入都会触发每日金额重算。
      ref.watch(accountingDataChangeSignalProvider);

      final repo = ref.watch(statisticsDataAccessProvider);
      return repo.getDailyTotalsByMonth(
        ledgerId: params.ledgerId,
        month: params.month,
      );
    });

/// 获取选中日期的交易详情（不含标签/附件字段）
/// 参数: (ledgerId, date)
final transactionsByDateProvider = FutureProvider.autoDispose
    .family<
      List<({TransactionDisplay t, CategoryDisplay? category})>,
      ({String ledgerId, DateTime date})
    >((ref, params) async {
      // 监听统一数据变更信号：任意业务表写入都会触发当日列表重算。
      ref.watch(accountingDataChangeSignalProvider);

      final repo = ref.watch(statisticsDataAccessProvider);
      return (await repo.getTransactionsByDate(
            ledgerId: params.ledgerId,
            date: params.date,
          ))
          .map(
            (row) =>
                (t: row.t.toDisplay(), category: row.category?.toDisplay()),
          )
          .toList(growable: false);
    });

/// 相邻月补位日期也显示金额，三个按月缓存查询共同覆盖可见网格。
final unifiedCalendarTotalsProvider = FutureProvider.autoDispose
    .family<Map<String, double>, ({String ledgerId, DateTime month})>((
      ref,
      query,
    ) async {
      final months = await Future.wait([
        for (final offset in [-1, 0, 1])
          ref.watch(
            dailyTotalsByMonthProvider((
              ledgerId: query.ledgerId,
              month: DateTime(query.month.year, query.month.month + offset),
            )).future,
          ),
      ]);
      return {for (final values in months) ...values};
    });
