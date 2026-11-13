import 'dart:async';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/statistics_range_totals.dart';
import 'package:sesame_notes/data/repositories/support/ledger_lookup.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/date/month_range.dart';
import 'package:sesame_notes/utils/date/week_math.dart';

/// 详情页一次订阅所需的本机历史与云端缓存历史。
typedef EditHistoryRows = ({
  List<RecordEditHistorySnapshot> local,
  List<CloudRecordEditHistorySnapshot> cloud,
});

/// 本地统计Repository实现
/// 基于 Drift 数据库实现
class LocalStatisticsRepository {
  final SesameDatabase db;

  LocalStatisticsRepository(this.db);

  /// 一次读取必要字段，同时累计分类、每日金额、笔数和总额。
  Future<StatisticsRangeTotals> totalsForRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final transactions = db.transactions;
      final query = db.selectOnly(transactions)
        ..addColumns([
          transactions.categoryId,
          transactions.happenedAt,
          transactions.nativeAmount,
          transactions.amount,
        ])
        ..where(
          transactions.ledgerId.equals(ledgerId) &
              transactions.txType.equals(type) &
              transactions.deletedAt.isNull() &
              transactions.happenedAt.isBiggerOrEqualValue(start) &
              transactions.happenedAt.isSmallerThanValue(end),
        );
      final rows = await query.get();
      // 分类解析始终以账本的真实账号域或共享镜像为准。
      final categories = await readLedgerCategoryCatalog(
        db,
        ledgerId,
        categoryIds: rows
            .map((row) => row.read(transactions.categoryId))
            .whereType<String>(),
      );
      final categoryTotals = <String?, Decimal>{};
      final dayTotals = <DateTime, Decimal>{};
      var total = Decimal.zero;
      for (final row in rows) {
        final amount =
            Decimal.tryParse(row.read(transactions.nativeAmount)!) ??
            Decimal.tryParse(row.read(transactions.amount)!);
        if (amount == null) continue;
        final category = categories[row.read(transactions.categoryId)];
        final happened = row.read(transactions.happenedAt)!.toLocal();
        final day = DateTime(happened.year, happened.month, happened.day);
        // 每笔金额只解析一次，三个聚合口径共享同一个十进制值。
        categoryTotals.update(
          category?.id,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        dayTotals.update(
          day,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        total += amount;
      }
      final hierarchy = <CategoryHierarchyTotal>[
        for (final entry in categoryTotals.entries)
          (
            id: entry.key,
            name: categories[entry.key]?.name ?? '未分类',
            icon: categories[entry.key]?.icon,
            parentId: categories[entry.key]?.parentId,
            level: categories[entry.key]?.level ?? 1,
            total: entry.value.toDouble(),
          ),
      ]..sort((left, right) => right.total.compareTo(left.total));
      return StatisticsRangeTotals(
        categories: hierarchy,
        days: [
          // 按当地日历推进，夏令时切换不改变每日零点和半开区间。
          for (
            var day = DateTime(start.year, start.month, start.day);
            day.isBefore(end);
            day = DateTime(day.year, day.month, day.day + 1)
          )
            (day: day, total: (dayTotals[day] ?? Decimal.zero).toDouble()),
        ],
        txCount: rows.length,
        total: total.toDouble(),
      );
    } catch (error, stackTrace) {
      logger.error(
        'Statistics',
        '读取区间统计失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 同时订阅本机历史与云端缓存历史，任一表变化都会重新组合并推送。
  ///
  /// 两条 Drift 查询各自首次发射后，仅当两边都已就绪才发布结果，
  /// 避免详情页先闪现半份历史再被第二次发射覆盖。
  Stream<EditHistoryRows> watchEditHistories(String recordId) {
    late final StreamController<EditHistoryRows> controller;
    StreamSubscription<List<RecordEditHistory>>? localSubscription;
    StreamSubscription<List<CloudRecordEditHistory>>? cloudSubscription;
    var local = <RecordEditHistorySnapshot>[];
    var cloud = <CloudRecordEditHistorySnapshot>[];
    var localReady = false;
    var cloudReady = false;

    void publish() {
      if (!localReady || !cloudReady || controller.isClosed) return;
      controller.add((local: local, cloud: cloud));
    }

    controller = StreamController<EditHistoryRows>(
      onListen: () {
        localSubscription =
            (db.select(db.recordEditHistories)
                  ..where((row) => row.recordId.equals(recordId))
                  ..orderBy([
                    (row) => d.OrderingTerm(
                      expression: row.version,
                      mode: d.OrderingMode.desc,
                    ),
                  ]))
                .watch()
                .listen(
                  (rows) {
                    local = rows;
                    localReady = true;
                    publish();
                  },
                  onError: (Object error, StackTrace stack) {
                    if (!controller.isClosed) {
                      controller.addError(error, stack);
                    }
                  },
                );
        cloudSubscription =
            (db.select(db.cloudRecordEditHistories)
                  ..where((row) => row.recordId.equals(recordId))
                  ..orderBy([
                    (row) => d.OrderingTerm(
                      expression: row.version,
                      mode: d.OrderingMode.desc,
                    ),
                  ]))
                .watch()
                .listen(
                  (rows) {
                    cloud = rows;
                    cloudReady = true;
                    publish();
                  },
                  onError: (Object error, StackTrace stack) {
                    if (!controller.isClosed) {
                      controller.addError(error, stack);
                    }
                  },
                );
      },
      onCancel: () async {
        await localSubscription?.cancel();
        await cloudSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// 批量读取每笔交易缓存到的最高版本与行数；空结果表示尚未缓存。
  Future<Map<String, ({int maxVersion, int count})>>
  cloudEditHistoryCacheStates(Iterable<String> recordIds) async {
    final ids = recordIds.toSet().toList(growable: false);
    if (ids.isEmpty) return const {};
    final result = <String, ({int maxVersion, int count})>{};
    const batchSize = 500;
    for (var offset = 0; offset < ids.length; offset += batchSize) {
      final end = (offset + batchSize).clamp(0, ids.length);
      final table = db.cloudRecordEditHistories;
      final maxVersion = table.version.max();
      final count = table.version.count();
      final query = db.selectOnly(table)
        ..addColumns([table.recordId, maxVersion, count])
        ..where(table.recordId.isIn(ids.sublist(offset, end)))
        ..groupBy([table.recordId]);
      for (final row in await query.get()) {
        final recordId = row.read(table.recordId);
        final version = row.read(maxVersion);
        final rowCount = row.read(count);
        if (recordId != null && version != null && rowCount != null) {
          result[recordId] = (maxVersion: version, count: rowCount);
        }
      }
    }
    return result;
  }

  /// 协作者统计使用当前账本的所有者镜像，其他账本返回空镜像目录。
  Future<Map<String, Category>> getSharedSyntheticCategoriesForLedger(
    String ledgerId,
  ) async {
    try {
      final ledger =
          await (db.select(db.ledgers)..where(
                (row) => row.id.equals(ledgerId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (ledger == null || ledger.storageMode != 'cloud') {
        return const {};
      }
      if (categoryScopeForLedger(ledger) == ledger.scopeAccountId) {
        return const {};
      }
      return await readLedgerCategoryCatalog(db, ledgerId);
    } catch (error, stackTrace) {
      logger.error('Statistics', '读取统计账本分类镜像失败', error, stackTrace);
      rethrow;
    }
  }

  /// 趋势只读取日期与金额，按当地日历补齐空白日期。
  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final table = db.transactions;
      final rows =
          await (db.selectOnly(table)
                ..addColumns([
                  table.happenedAt,
                  table.nativeAmount,
                  table.amount,
                ])
                ..where(
                  table.ledgerId.equals(ledgerId) &
                      table.txType.equals(type) &
                      table.deletedAt.isNull() &
                      table.happenedAt.isBiggerOrEqualValue(start) &
                      table.happenedAt.isSmallerThanValue(end),
                ))
              .get();
      final map = <DateTime, Decimal>{};
      for (final row in rows) {
        final dt = row.read(table.happenedAt)!.toLocal();
        final day = DateTime(dt.year, dt.month, dt.day);
        final amount =
            Decimal.tryParse(row.read(table.nativeAmount)!) ??
            Decimal.tryParse(row.read(table.amount)!);
        if (amount != null) {
          map.update(day, (value) => value + amount, ifAbsent: () => amount);
        }
      }
      // 按当地日历推进，跨夏令时时一天可以不是二十四小时。
      return [
        for (
          var day = DateTime(start.year, start.month, start.day);
          day.isBefore(end);
          day = DateTime(day.year, day.month, day.day + 1)
        )
          (day: day, total: (map[day] ?? Decimal.zero).toDouble()),
      ];
    } catch (error, stackTrace) {
      logger.error(
        'Statistics',
        '读取每日支出趋势失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  Future<DateTime?> earliestExpenseDate({required String ledgerId}) async {
    // 取该账本最早一笔支出的 happened_at，本地时区
    final rows =
        await (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.txType.equals('expense') &
                    t.deletedAt.isNull(),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.asc,
                ),
              ])
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    return rows.first.happenedAt.toLocal();
  }

  Future<DateTime?> latestExpenseDate({required String ledgerId}) async {
    // 取该账本最晚一笔支出的 happened_at，本地时区
    final rows =
        await (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.txType.equals('expense') &
                    t.deletedAt.isNull(),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .get();
    if (rows.isEmpty) return null;
    return rows.first.happenedAt.toLocal();
  }

  /// 存在性只读取第一条有效支出的标识，无需统计全部历史账单。
  Future<bool> hasAnyExpenseTx({required String ledgerId}) async {
    try {
      final table = db.transactions;
      final row =
          await (db.selectOnly(table)
                ..addColumns([table.id])
                ..where(
                  table.ledgerId.equals(ledgerId) &
                      table.txType.equals('expense') &
                      table.deletedAt.isNull(),
                )
                ..limit(1))
              .getSingleOrNull();
      return row != null;
    } catch (error, stackTrace) {
      logger.error(
        'Statistics',
        '检查支出记录失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 按半开区间读取有效支出，以十进制快照累计后仅在显示边界转为 double。
  Future<double> totalsInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // 仅读取两个金额快照，长备注和其他交易展示字段不进入汇总结果。
      final table = db.transactions;
      final rows =
          await (db.selectOnly(table)
                ..addColumns([table.nativeAmount, table.amount])
                ..where(
                  table.ledgerId.equals(ledgerId) &
                      table.txType.equals('expense') &
                      table.deletedAt.isNull() &
                      table.happenedAt.isBiggerOrEqualValue(start) &
                      table.happenedAt.isSmallerThanValue(end),
                ))
              .get();
      var total = Decimal.zero;
      for (final row in rows) {
        final amount =
            Decimal.tryParse(row.read(table.nativeAmount)!) ??
            Decimal.tryParse(row.read(table.amount)!);
        if (amount != null) total += amount;
      }
      return total.toDouble();
    } catch (error, stackTrace) {
      logger.error(
        'Statistics',
        '读取区间支出总额失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 月账期只负责确定边界，金额与删除过滤复用统一的区间聚合口径。
  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) async {
    try {
      final sd = await ledgerMonthStartDay(db, ledgerId);
      final range = periodForLabel(month.year, month.month, sd);
      return await totalsInRange(
        ledgerId: ledgerId,
        start: range.start,
        end: range.end,
      );
    } catch (error, stackTrace) {
      logger.error(
        'Statistics',
        '读取月账期汇总失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  Future<double> todayExpense({
    required String ledgerId,
    required DateTime now,
  }) async {
    // 本地时区自然日 [0:00, 次日0:00)，复用 totalsInRange 聚合逻辑。
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day + 1);
    return totalsInRange(ledgerId: ledgerId, start: start, end: end);
  }

  Future<double> weekExpense({
    required String ledgerId,
    required DateTime now,
  }) async {
    // 周一为一周起始(weekday: 1=周一...7=周日)，回退到本周一 0:00，加 7 天为下周一。
    final weekStart = mondayOf(now);
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 7,
    );
    return totalsInRange(ledgerId: ledgerId, start: weekStart, end: weekEnd);
  }
}
