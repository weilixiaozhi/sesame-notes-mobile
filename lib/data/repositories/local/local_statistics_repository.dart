import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
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

  /// 汇总一本账本真实分类域的金额及层级，不按跨账号的裸分类 ID 拼接主表。
  Future<
    List<
      ({
        String? id,
        String name,
        String? icon,
        String? parentId,
        int level,
        double total,
      })
    >
  >
  totalsByCategoryWithHierarchy({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final q = (db.select(db.transactions)
      ..where(
        (t) =>
            t.ledgerId.equals(ledgerId) &
            t.txType.equals(type) &
            t.deletedAt.isNull() &
            t.happenedAt.isBiggerOrEqualValue(start) &
            t.happenedAt.isSmallerThanValue(end),
      ));

    final rows = await q.get();
    final categories = await readLedgerCategoryCatalog(
      db,
      ledgerId,
      categoryIds: rows.map((row) => row.categoryId).whereType<String>(),
    );
    final map = <String?, Decimal>{};
    final categoryInfo =
        <String?, ({String name, String? icon, String? parentId, int level})>{};

    for (final t in rows) {
      final c = categories[t.categoryId];
      String? id = c?.id;

      if (c != null) {
        categoryInfo[id] = (
          name: c.name,
          icon: c.icon,
          parentId: c.parentId,
          level: c.level,
        );
      } else {
        categoryInfo[id] = (name: '未分类', icon: null, parentId: null, level: 1);
      }

      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        map.update(id, (acc) => acc + v, ifAbsent: () => v);
      }
    }

    final list = map.entries.map((e) {
      final info = categoryInfo[e.key]!;
      return (
        id: e.key,
        name: info.name,
        icon: info.icon,
        parentId: info.parentId,
        level: info.level,
        total: e.value.toDouble(),
      );
    }).toList()..sort((a, b) => b.total.compareTo(a.total));

    return list;
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

  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) async {
    final sd = await ledgerMonthStartDay(db, ledgerId);
    final range = periodForLabel(month.year, month.month, sd);
    // 金额为十进制文本，使用 Decimal 累加以避免 SQL 浮点转换损失精度。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals('expense') &
                  t.deletedAt.isNull() &
                  t.happenedAt.isBiggerOrEqualValue(range.start) &
                  t.happenedAt.isSmallerThanValue(range.end),
            ))
            .get();
    var total = Decimal.zero;
    for (final t in rows) {
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) total += v;
    }
    return total.toDouble();
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
