import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 本地统计Repository实现
/// 基于 Drift 数据库实现
class LocalStatisticsRepository {
  final SesameDatabase db;

  LocalStatisticsRepository(this.db);

  Future<List<({String? id, String name, String? icon, double total})>>
  totalsByCategory({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final q =
        (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals(type) &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
                  t.happenedAt.isBiggerOrEqualValue(start) &
                  t.happenedAt.isSmallerThanValue(end),
            ))
            .join([
              d.leftOuterJoin(
                db.categories,
                db.categories.id.equalsExp(db.transactions.categoryId) &
                    db.categories.deletedAt.isNull(),
              ),
            ]);
    final rows = await q.get();
    final shared = await _loadSharedCategoriesForLedger(ledgerId);
    final map = <String?, Decimal>{};
    final names = <String?, String>{};
    final icons = <String?, String?>{};
    for (final r in rows) {
      final t = r.readTable(db.transactions);
      final c = r.readTableOrNull(db.categories);
      String? id = c?.id;
      String name = c?.name ?? '未分类';
      String? icon = c?.icon;
      // Editor 视角的交易 categoryId 指向 Owner 的分类 UUID，主表 join 不到，
      // 用 SharedLedgerCategories 镜像（按 categoryId）兜底。
      if (c == null && t.categoryId != null) {
        final s = shared[t.categoryId];
        if (s != null) {
          id = s.categoryId;
          name = s.name;
          icon = s.icon;
        }
      }
      names[id] = name;
      icons[id] = icon;
      // 金额是规范化 decimal 字符串，中间累加必须 Decimal 保持精度，
      // 不做整数分换算；返回 double 仅为兼容既有展示接口。
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        map.update(id, (acc) => acc + v, ifAbsent: () => v);
      }
    }
    final list =
        map.entries
            .map(
              (e) => (
                id: e.key,
                name: names[e.key] ?? '未分类',
                icon: icons[e.key],
                total: e.value.toDouble(),
              ),
            )
            .toList()
          ..sort((a, b) => b.total.compareTo(a.total));
    return list;
  }

  /// 加载当前账本的 SharedLedger 分类镜像（by category UUID）。
  /// 单人账本无镜像行返回空 map，共享账本返回 Owner user-global 分类的镜像。
  Future<Map<String, SharedLedgerCategory>> _loadSharedCategoriesForLedger(
    String ledgerId,
  ) async {
    final rows = await (db.select(
      db.sharedLedgerCategories,
    )..where((t) => t.ledgerId.equals(ledgerId))).get();
    // 本地明确存在 tombstone 时不能再由遗留共享镜像复活同一分类。
    final tombstonedIds =
        (await (db.select(
              db.categories,
            )..where((category) => category.deletedAt.isNotNull())).get())
            .map((category) => category.id)
            .toSet();
    return {
      for (final r in rows)
        if (!tombstonedIds.contains(r.categoryId)) r.categoryId: r,
    };
  }

  /// 共享账本镜像分类转 Category（镜像分类 id 即 Owner 分类 UUID）。
  /// 单人账本返回空 map。
  Future<Map<String, Category>> getSharedSyntheticCategoriesForLedger(
    String ledgerId,
  ) async {
    final shared = await _loadSharedCategoriesForLedger(ledgerId);
    if (shared.isEmpty) return const {};
    return {
      for (final s in shared.values)
        s.categoryId: Category(
          id: s.categoryId,
          name: s.name,
          kind: s.kind,
          icon: s.icon,
          sortOrder: s.sortOrder,
          // 镜像内的父子链沿用真实 UUID，与主表 Categories 同属一个 id 空间。
          parentId: s.parentId,
          level: s.level,
          updatedAt: s.updatedAt,
        ),
    };
  }

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
    final q =
        (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals(type) &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
                  t.happenedAt.isBiggerOrEqualValue(start) &
                  t.happenedAt.isSmallerThanValue(end),
            ))
            .join([
              d.leftOuterJoin(
                db.categories,
                db.categories.id.equalsExp(db.transactions.categoryId) &
                    db.categories.deletedAt.isNull(),
              ),
            ]);

    final rows = await q.get();
    final shared = await _loadSharedCategoriesForLedger(ledgerId);
    final map = <String?, Decimal>{};
    final categoryInfo =
        <String?, ({String name, String? icon, String? parentId, int level})>{};

    for (final r in rows) {
      final t = r.readTable(db.transactions);
      final c = r.readTableOrNull(db.categories);
      String? id = c?.id;

      if (c != null) {
        categoryInfo[id] = (
          name: c.name,
          icon: c.icon,
          parentId: c.parentId,
          level: c.level,
        );
      } else if (t.categoryId != null && shared[t.categoryId] != null) {
        // Editor 写入的交易 categoryId 指向 Owner 的分类 UUID，主表 join 不到，
        // 用 SharedLedger* 镜像兜底；聚合 key 即真实 UUID，层级沿用镜像父子链。
        final s = shared[t.categoryId]!;
        id = s.categoryId;
        categoryInfo[id] = (
          name: s.name,
          icon: s.icon,
          parentId: s.parentId,
          level: s.level,
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
                  t.excludeFromStats.equals(false) &
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
    // 补齐区间内每一天，保证折线图横轴连续（无交易的日子补 0）。
    final result = <({DateTime day, double total})>[];
    for (
      DateTime d = DateTime(start.year, start.month, start.day);
      d.isBefore(end);
      d = d.add(const Duration(days: 1))
    ) {
      result.add((day: d, total: (map[d] ?? Decimal.zero).toDouble()));
    }
    return result;
  }

  Future<List<({DateTime month, double total})>> totalsByMonth({
    required String ledgerId,
    required String type,
    required int year,
  }) async {
    final sd = await _monthStartDayOf(ledgerId);
    final yr = yearRangeFor(year, sd);
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals(type) &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
                  t.happenedAt.isBiggerOrEqualValue(yr.start) &
                  t.happenedAt.isSmallerThanValue(yr.end),
            ))
            .get();
    final map = <int, Decimal>{};
    for (final t in rows) {
      // 年范围 [当年1月周期起点, 次年1月周期起点) 内的标签必属 year，直接取 month
      final label = labelForDate(t.happenedAt.toLocal(), sd);
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        map.update(label.month, (acc) => acc + v, ifAbsent: () => v);
      }
    }
    final result = <({DateTime month, double total})>[];
    for (int m = 1; m <= 12; m++) {
      result.add((
        month: DateTime(year, m, 1),
        total: (map[m] ?? Decimal.zero).toDouble(),
      ));
    }
    return result;
  }

  Future<List<({int year, double total})>> totalsByYearSeries({
    required String ledgerId,
    required String type,
  }) async {
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals(type) &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false),
            ))
            .get();
    if (rows.isEmpty) return const [];
    final sd = await _monthStartDayOf(ledgerId);
    final map = <int, Decimal>{};
    int minYear = 9999, maxYear = 0;
    for (final t in rows) {
      final y = labelForDate(t.happenedAt.toLocal(), sd).year;
      if (y < minYear) minYear = y;
      if (y > maxYear) maxYear = y;
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        map.update(y, (acc) => acc + v, ifAbsent: () => v);
      }
    }
    final out = <({int year, double total})>[];
    for (int y = minYear; y <= maxYear; y++) {
      out.add((year: y, total: (map[y] ?? Decimal.zero).toDouble()));
    }
    return out;
  }

  Future<DateTime?> earliestExpenseDate({required String ledgerId}) async {
    // 取该账本最早一笔支出（未排除统计）的 happened_at，本地时区
    final rows =
        await (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.txType.equals('expense') &
                    t.deletedAt.isNull() &
                    t.excludeFromStats.equals(false),
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
    // 取该账本最晚一笔支出（未排除统计）的 happened_at，本地时区
    final rows =
        await (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.txType.equals('expense') &
                    t.deletedAt.isNull() &
                    t.excludeFromStats.equals(false),
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
          'AND deleted_at IS NULL AND exclude_from_stats = 0',
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
    // 金额为 TEXT 列，SQL SUM 无法聚合 → 读取行后 Dart 层 Decimal 累加。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals('expense') &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
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

  /// 读取账本的自定义每月起始日(1-28);账本缺失或查询异常时按 1(自然月)降级
  /// —— watch 流经 Stream.fromFuture 包裹,这里抛错会让流永久进 error 态。
  Future<int> _monthStartDayOf(String ledgerId) async {
    try {
      final row = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
      return (row?.monthStartDay ?? 1).clamp(1, 28);
    } catch (_) {
      return 1;
    }
  }

  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) async {
    final sd = await _monthStartDayOf(ledgerId);
    final range = periodForLabel(month.year, month.month, sd);
    // 金额为 TEXT 列，SQL SUM 无法聚合 → 读取行后 Dart 层 Decimal 累加。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals('expense') &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
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
    final end = start.add(const Duration(days: 1));
    return totalsInRange(ledgerId: ledgerId, start: start, end: end);
  }

  Future<double> weekExpense({
    required String ledgerId,
    required DateTime now,
  }) async {
    // 周一为一周起始(weekday: 1=周一...7=周日)，回退到本周一 0:00，加 7 天为下周一。
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return totalsInRange(ledgerId: ledgerId, start: weekStart, end: weekEnd);
  }

  Future<double> yearlyTotals({
    required String ledgerId,
    required int year,
  }) async {
    final sd = await _monthStartDayOf(ledgerId);
    final range = yearRangeFor(year, sd);
    // 金额为 TEXT 列，SQL SUM 无法聚合 → 读取行后 Dart 层 Decimal 累加。
    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.txType.equals('expense') &
                  t.deletedAt.isNull() &
                  t.excludeFromStats.equals(false) &
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
}
