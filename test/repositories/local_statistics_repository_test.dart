import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/year_analytics.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';

void main() {
  late SesameDatabase db;
  late LocalRepository repo;
  late LocalStatisticsRepository stats;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    stats = LocalStatisticsRepository(db);
  });

  tearDown(() async => db.close());

  /// 创建账本并返回 UUID
  Future<String> seedLedger({int monthStartDay = 1}) {
    return repo.createLedger(
      name: '统计账本',
      monthStartDay: monthStartDay,
      storageMode: 'local',
    );
  }

  /// 创建分类并返回 UUID（parentId 非空时按二级分类创建）
  Future<String> seedCategory(String name, {String? parentId, int level = 1}) {
    return repo.createCategory(
      name: name,
      kind: 'expense',
      parentId: parentId,
      level: level,
    );
  }

  group('分类聚合过滤', () {
    test('按分类聚合并汇总全部未分类记录', () async {
      final lid = await seedLedger();
      final foodId = await seedCategory('餐饮');
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 7, 1);

      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '30.00',
        categoryId: foodId,
        happenedAt: DateTime(2026, 6, 10),
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime(2026, 6, 11),
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '99.99',
        happenedAt: DateTime(2026, 6, 12),
      );

      final rows = await stats.totalsByCategoryWithHierarchy(
        ledgerId: lid,
        type: 'expense',
        start: start,
        end: end,
      );
      expect(rows, hasLength(2));
      expect(rows.firstWhere((r) => r.id == foodId).total, 30.0);
      expect(rows.firstWhere((r) => r.name == '未分类').total, 119.99);
    });
  });

  group('totalsByCategoryWithHierarchy', () {
    test('二级分类带 parentId 与 level', () async {
      final lid = await seedLedger();
      final parentId = await seedCategory('购物');
      final childId = await seedCategory('鞋子', parentId: parentId, level: 2);
      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 7, 1);

      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '50.00',
        categoryId: childId,
        happenedAt: DateTime(2026, 6, 10),
      );

      final rows = await stats.totalsByCategoryWithHierarchy(
        ledgerId: lid,
        type: 'expense',
        start: start,
        end: end,
      );
      final child = rows.firstWhere((r) => r.id == childId);
      expect(child.parentId, parentId);
      expect(child.level, 2);
      expect(child.total, 50.0);
    });

    test('共享账本 Editor：categoryId 指向 Owner 分类 UUID → 镜像分类命中', () async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'shared-ledger-1',
              name: '共享账本',
              role: const Value('editor'),
              memberCount: const Value(2),
              storageMode: const Value('cloud'),
              scopeAccountId: const Value('viewer-account'),
              ownerAccountId: const Value('owner-account'),
              updatedAt: DateTime(2026, 6, 1),
            ),
          );
      final lid = 'shared-ledger-1';
      // Owner 侧共享分类（镜像表）：categoryId 即 Owner 的分类 UUID
      await db
          .into(db.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: 'shared-ledger-1',
              categoryId: 'owner-cat-1',
              name: '主人分类',
              kind: 'expense',
              level: const Value(2),
              parentId: const Value('owner-cat-0'),
              updatedAt: DateTime(2026, 6, 1),
            ),
          );
      // Editor 设备本地没有 Owner 分类行；transactions.category_id 的 FK
      // 会拒绝插入，需临时关闭 FK 以模拟同步 apply 写入路径（与同步层一致）。
      await db.customStatement('PRAGMA foreign_keys = OFF');
      try {
        await repo.addTransaction(
          ledgerId: lid,
          type: 'expense',
          amount: '12.00',
          categoryId: 'owner-cat-1',
          happenedAt: DateTime(2026, 6, 10),
        );
      } finally {
        await db.customStatement('PRAGMA foreign_keys = ON');
      }

      final start = DateTime(2026, 6, 1);
      final end = DateTime(2026, 7, 1);
      final rows = await stats.totalsByCategoryWithHierarchy(
        ledgerId: lid,
        type: 'expense',
        start: start,
        end: end,
      );
      expect(rows, hasLength(1));
      expect(rows.first.name, '主人分类');
      // 聚合 key 即真实 UUID，层级沿用镜像父子链
      expect(rows.first.id, 'owner-cat-1');
      expect(rows.first.parentId, 'owner-cat-0');
      expect(rows.first.total, 12.0);

      // 共享分类查询接口同样命中
      final synthetic = await stats.getSharedSyntheticCategoriesForLedger(lid);
      expect(synthetic['owner-cat-1']?.name, '主人分类');
    });
  });

  group('时间序列聚合', () {
    test('totalsByDay 全区间连续（无数据日补 0）', () async {
      final lid = await seedLedger();
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 6, 10, 12),
      );
      final rows = await stats.totalsByDay(
        ledgerId: lid,
        type: 'expense',
        start: DateTime(2026, 6, 9),
        end: DateTime(2026, 6, 12),
      );
      expect(rows, hasLength(3));
      expect(rows[0].total, 0.0);
      expect(rows[1].total, 10.0);
      expect(rows[2].total, 0.0);
    });

    test('年图按自定义月起始日分账期', () async {
      final lid = await seedLedger(monthStartDay: 15);
      // 6/10 属于 5/15-6/14 账期（5 月标签）
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '30.00',
        happenedAt: DateTime(2026, 6, 10),
      );
      // 6/20 属于 6/15-7/14 账期（6 月标签）
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '40.00',
        happenedAt: DateTime(2026, 6, 20),
      );

      final rows = await loadYearAnalyticsPoints(
        repo,
        ledgerId: lid,
        type: 'expense',
        year: 2026,
      );
      expect(rows, hasLength(12));
      expect(rows[4].total, 30.0, reason: '6/10 归入 5 月账期');
      expect(rows[5].total, 40.0, reason: '6/20 归入 6 月账期');
    });

    test('年图区分跨年交易；空账本所有月份为零', () async {
      final lid = await seedLedger();
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2025, 12, 31),
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime(2026, 1, 1),
      );
      final previousYear = await loadYearAnalyticsPoints(
        repo,
        ledgerId: lid,
        type: 'expense',
        year: 2025,
      );
      final currentYear = await loadYearAnalyticsPoints(
        repo,
        ledgerId: lid,
        type: 'expense',
        year: 2026,
      );
      expect(previousYear.last.total, 10.0);
      expect(previousYear.take(11).every((row) => row.total == 0), isTrue);
      expect(currentYear.first.total, 20.0);
      expect(currentYear.skip(1).every((row) => row.total == 0), isTrue);

      final emptyLid = await seedLedger();
      expect(
        (await loadYearAnalyticsPoints(
          repo,
          ledgerId: emptyLid,
          type: 'expense',
          year: 2026,
        )).every((row) => row.total == 0),
        isTrue,
      );
    });
  });

  group('日期边界与聚合金额', () {
    test('earliest/latest/hasAnyExpense：空库与有数据', () async {
      final lid = await seedLedger();
      expect(await stats.earliestExpenseDate(ledgerId: lid), isNull);
      expect(await stats.latestExpenseDate(ledgerId: lid), isNull);
      expect(await stats.hasAnyExpenseTx(ledgerId: lid), isFalse);

      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '10.00',
        happenedAt: DateTime(2026, 6, 5),
      );
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '20.00',
        happenedAt: DateTime(2026, 6, 20),
      );
      expect(
        await stats.earliestExpenseDate(ledgerId: lid),
        DateTime(2026, 6, 5),
      );
      expect(
        await stats.latestExpenseDate(ledgerId: lid),
        DateTime(2026, 6, 20),
      );
      expect(await stats.hasAnyExpenseTx(ledgerId: lid), isTrue);
    });

    test('totalsInRange / monthlyTotals / today / week / year', () async {
      final lid = await seedLedger();
      // 今日
      final now = DateTime(2026, 7, 8, 15);
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '11.00',
        happenedAt: now,
      );
      // 本周一（7/6 周一）
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '22.00',
        happenedAt: DateTime(2026, 7, 6, 9),
      );
      // 本月初（7/1）
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '33.00',
        happenedAt: DateTime(2026, 7, 1, 9),
      );
      // 去年（2025 年）
      await repo.addTransaction(
        ledgerId: lid,
        type: 'expense',
        amount: '44.00',
        happenedAt: DateTime(2025, 7, 1),
      );

      expect(await stats.todayExpense(ledgerId: lid, now: now), 11.0);
      expect(
        await stats.weekExpense(ledgerId: lid, now: now),
        33.0,
        reason: '本周 = 周一 22 + 今日 11',
      );
      expect(
        await stats.monthlyTotals(ledgerId: lid, month: DateTime(2026, 7)),
        66.0,
      );
      for (final expected in [
        (year: 2026, total: 66.0),
        (year: 2025, total: 44.0),
      ]) {
        final months = await loadYearAnalyticsPoints(
          repo,
          ledgerId: lid,
          type: 'expense',
          year: expected.year,
        );
        expect(
          months.fold<double>(0, (sum, row) => sum + row.total),
          expected.total,
        );
      }
      expect(
        await stats.totalsInRange(
          ledgerId: lid,
          start: DateTime(2026, 1, 1),
          end: DateTime(2027, 1, 1),
        ),
        66.0,
      );
    });
  });
}
