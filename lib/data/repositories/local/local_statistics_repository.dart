import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/statistics_range_totals.dart';
import 'package:sesame_notes/data/repositories/support/ledger_lookup.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/date/month_range.dart';
import 'package:sesame_notes/utils/date/week_math.dart';

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

  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals(type) &
                  t.deletedAt.isNull() &
                  t.happenedAt.isBiggerOrEqualValue(start) &
                  t.happenedAt.isSmallerThanValue(end),
            ))
            .get();
    final map = <DateTime, Decimal>{};
    for (final t in rows) {
      final dt = t.happenedAt.toLocal();
      final day = DateTime(dt.year, dt.month, dt.day);
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        map.update(day, (acc) => acc + v, ifAbsent: () => v);
      }
    }
    // 按当地日历补齐每日零点，跨夏令时时一天可以不是二十四小时。
    final result = <({DateTime day, double total})>[];
    for (
      DateTime d = DateTime(start.year, start.month, start.day);
      d.isBefore(end);
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      result.add((day: d, total: (map[d] ?? Decimal.zero).toDouble()));
    }
    return result;
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

  Future<bool> hasAnyExpenseTx({required String ledgerId}) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM transactions '
          'WHERE ledger_id = ?1 AND tx_type = ?2 '
          'AND deleted_at IS NULL',
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable<String>('expense'),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    final v = row.data['c'];
    if (v is int) return v > 0;
    if (v is BigInt) return v > BigInt.zero;
    if (v is num) return v > 0;
    return false;
  }

  /// 按半开区间读取有效支出，以十进制快照累计后仅在显示边界转为 double。
  Future<double> totalsInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) async {
    // 金额为十进制文本，使用 Decimal 累加以避免 SQL 浮点转换损失精度。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals('expense') &
                  t.deletedAt.isNull() &
                  t.happenedAt.isBiggerOrEqualValue(start) &
                  t.happenedAt.isSmallerThanValue(end),
            ))
            .get();
    var total = Decimal.zero;
    for (final t in rows) {
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) total += v;
    }
    return total.toDouble();
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
