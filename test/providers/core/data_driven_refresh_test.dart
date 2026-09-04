/// 数据驱动刷新契约测试。
///
/// 需求期望：无论从哪条路径写入数据（UI 记账、导入、云端同步、后台任务等），
/// 首页/统计/日历/分类汇总/成员汇总/AA 汇总都必须自动刷新。
/// 本测试直接调用仓储写库，
/// 验证汇总 provider 仅凭“数据库变更信号”即可重算。
library;

import 'dart:async';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/features/statistics/application/calendar_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late String ledgerId;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(
      name: '测试账本',
      storageMode: 'local',
      aaEnabled: true,
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
      ],
    );
    container.read(currentLedgerIdProvider.notifier).set(ledgerId);
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  /// 轮询等待条件成立，消除异步流推送与重算的时序抖动。
  Future<void> waitUntil(
    bool Function() predicate, {
    String reason = '等待数据驱动刷新超时',
    // 全量随机顺序跑批时多个测试文件并发执行，真实时间等待可能被调度挤压；
    // 放宽到 15s 只影响超时判定，不断言内容，避免并行负载下的偶发误报。
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (!predicate()) {
      if (DateTime.now().isAfter(deadline)) {
        fail(reason);
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  test('交易新增、更新、删除后，首页/统计/日历/分类/成员/AA 全部自动重算', () async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final dateKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 先种一个分类，供分类汇总断言使用（未分类交易不会产生分类行）。
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');

    // 保持各汇总 provider 存活，模拟页面持续订阅（autoDispose 下仅 read 会被回收）。
    final subscriptions = <ProviderSubscription<dynamic>>[];
    void keepAlive(ProviderListenable<dynamic> provider) {
      subscriptions.add(container.listen(provider, (_, _) {}));
    }

    keepAlive(monthlyTotalsProvider((ledgerId: ledgerId, month: month)));
    keepAlive(todayExpenseProvider(ledgerId));
    keepAlive(weekExpenseProvider(ledgerId));
    keepAlive(countsForLedgerProvider(ledgerId));
    keepAlive(dailyTotalsByMonthProvider((ledgerId: ledgerId, month: month)));
    keepAlive(transactionsByDateProvider((ledgerId: ledgerId, date: now)));
    keepAlive(memberExpenseStatsProvider(ledgerId));
    keepAlive(aaStatisticsProvider(ledgerId));
    keepAlive(categoriesWithCountProvider);
    addTearDown(() {
      for (final sub in subscriptions) {
        sub.close();
      }
    });

    // 基线：各汇总先加载旧值（0 / 空）。
    await waitUntil(
      () => container
          .read(monthlyTotalsProvider((ledgerId: ledgerId, month: month)))
          .hasValue,
      reason: '月度汇总基线未就绪',
    );
    await waitUntil(
      () => container
          .read(dailyTotalsByMonthProvider((ledgerId: ledgerId, month: month)))
          .hasValue,
      reason: '日历汇总基线未就绪',
    );
    await waitUntil(
      () => container.read(memberExpenseStatsProvider(ledgerId)).hasValue,
      reason: '成员汇总基线未就绪',
    );
    await waitUntil(
      () => container.read(aaStatisticsProvider(ledgerId)).hasValue,
      reason: 'AA 汇总基线未就绪',
    );
    await waitUntil(
      () => container.read(categoriesWithCountProvider).hasValue,
      reason: '分类汇总基线未就绪',
    );

    expect(
      container
          .read(monthlyTotalsProvider((ledgerId: ledgerId, month: month)))
          .value,
      0,
    );
    expect(container.read(countsForLedgerProvider(ledgerId)).value!.txCount, 0);
    expect(
      container
          .read(dailyTotalsByMonthProvider((ledgerId: ledgerId, month: month)))
          .value,
      isEmpty,
    );
    expect(container.read(memberExpenseStatsProvider(ledgerId)).value, isEmpty);
    expect(
      container
          .read(aaStatisticsProvider(ledgerId))
          .value!
          .participants
          .firstWhere(
            (p) => p.participantId == localSelfMemberId(ledgerId, 'local-self'),
          )
          .totalPaid,
      0,
    );

    // 关键步骤：不触发任何手动刷新信号，
    // 直接写库——只有“数据库变更信号”能驱动刷新。
    final transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '12.34',
      categoryId: categoryId,
      happenedAt: now,
      note: '直接写库',
      payerMemberId: localSelfMemberId(ledgerId, 'local-self'),
    );

    // 首页月度汇总与账本笔数自动重算。
    await waitUntil(
      () =>
          (container
                  .read(
                    monthlyTotalsProvider((ledgerId: ledgerId, month: month)),
                  )
                  .value ??
              0) ==
          12.34,
      reason: '月度汇总未跟随直接写库刷新',
    );
    expect(container.read(countsForLedgerProvider(ledgerId)).value!.txCount, 1);
    expect(
      container.read(countsForLedgerProvider(ledgerId)).value!.dayCount,
      1,
    );

    // 日历每日金额自动重算。
    await waitUntil(
      () =>
          container
              .read(
                dailyTotalsByMonthProvider((ledgerId: ledgerId, month: month)),
              )
              .value![dateKey] ==
          12.34,
      reason: '日历每日金额未跟随直接写库刷新',
    );

    // 成员汇总自动重算。
    await waitUntil(
      () => container
          .read(memberExpenseStatsProvider(ledgerId))
          .value!
          .any(
            (s) =>
                s.participantId == localSelfMemberId(ledgerId, 'local-self') &&
                s.txCount == 1,
          ),
      reason: '成员汇总未跟随直接写库刷新',
    );

    // AA 汇总自动重算：实付金额从 0 变为 12.34。
    await waitUntil(
      () =>
          container
              .read(aaStatisticsProvider(ledgerId))
              .value!
              .participants
              .firstWhere(
                (p) =>
                    p.participantId ==
                    localSelfMemberId(ledgerId, 'local-self'),
              )
              .totalPaid ==
          12.34,
      reason: 'AA 汇总未跟随直接写库刷新',
    );

    // 分类汇总流自动重算：交易笔数从 0 变为 1。
    await waitUntil(() {
      final value = container.read(categoriesWithCountProvider).value;
      return value != null &&
          value.any(
            (c) => c.category.id == categoryId && c.transactionCount == 1,
          );
    }, reason: '分类汇总未跟随直接写库刷新');

    // 更新不是“新增”的附带场景：金额变化必须让所有金额派生使用最终快照，
    // 不能只刷新列表而保留旧汇总。
    await repo.updateTransaction(
      id: transactionId,
      type: 'expense',
      amount: '20.00',
      categoryId: categoryId,
      happenedAt: now,
      note: '更新后',
      payerMemberId: localSelfMemberId(ledgerId, 'local-self'),
    );
    await waitUntil(
      () =>
          container
              .read(monthlyTotalsProvider((ledgerId: ledgerId, month: month)))
              .value ==
          20,
      reason: '交易更新后月度汇总仍是旧金额',
    );
    await waitUntil(
      () => container.read(todayExpenseProvider(ledgerId)).value == 20,
      reason: '交易更新后今日汇总仍是旧金额',
    );
    await waitUntil(
      () => container.read(weekExpenseProvider(ledgerId)).value == 20,
      reason: '交易更新后本周汇总仍是旧金额',
    );
    await waitUntil(
      () =>
          container
              .read(
                dailyTotalsByMonthProvider((ledgerId: ledgerId, month: month)),
              )
              .value?[dateKey] ==
          20,
      reason: '交易更新后日历金额仍是旧值',
    );
    await waitUntil(
      () =>
          container
              .read(memberExpenseStatsProvider(ledgerId))
              .value
              ?.single
              .expenseTotal ==
          20,
      reason: '交易更新后成员支出仍是旧值',
    );
    await waitUntil(
      () =>
          container
              .read(aaStatisticsProvider(ledgerId))
              .value
              ?.participants
              .firstWhere(
                (p) =>
                    p.participantId ==
                    localSelfMemberId(ledgerId, 'local-self'),
              )
              .totalPaid ==
          20,
      reason: '交易更新后 AA 实付仍是旧值',
    );
    await waitUntil(
      () =>
          container
              .read(transactionsByDateProvider((ledgerId: ledgerId, date: now)))
              .value
              ?.single
              .t
              .note ==
          '更新后',
      reason: '交易更新后日历明细仍是旧快照',
    );

    // 删除后所有派生必须收敛回空态；这覆盖单删，也为批删/清空最终逐笔复用
    // 同一交易删除入口提供消费端契约。
    await repo.deleteTransaction(transactionId);
    await waitUntil(
      () =>
          container
                  .read(
                    monthlyTotalsProvider((ledgerId: ledgerId, month: month)),
                  )
                  .value ==
              0 &&
          container.read(todayExpenseProvider(ledgerId)).value == 0 &&
          container.read(weekExpenseProvider(ledgerId)).value == 0,
      reason: '交易删除后首页汇总未归零',
    );
    await waitUntil(
      () =>
          container.read(countsForLedgerProvider(ledgerId)).value?.txCount ==
              0 &&
          (container
                  .read(
                    dailyTotalsByMonthProvider((
                      ledgerId: ledgerId,
                      month: month,
                    )),
                  )
                  .value
                  ?.isEmpty ??
              false) &&
          (container
                  .read(
                    transactionsByDateProvider((ledgerId: ledgerId, date: now)),
                  )
                  .value
                  ?.isEmpty ??
              false),
      reason: '交易删除后账本统计或日历仍保留旧记录',
    );
    await waitUntil(
      () =>
          (container
                  .read(memberExpenseStatsProvider(ledgerId))
                  .value
                  ?.isEmpty ??
              false) &&
          container
                  .read(aaStatisticsProvider(ledgerId))
                  .value
                  ?.participants
                  .firstWhere(
                    (p) =>
                        p.participantId ==
                        localSelfMemberId(ledgerId, 'local-self'),
                  )
                  .totalPaid ==
              0,
      reason: '交易删除后成员或 AA 汇总未归零',
    );
    await waitUntil(() {
      final value = container.read(categoriesWithCountProvider).value;
      return value != null &&
          value.any(
            (item) =>
                item.category.id == categoryId && item.transactionCount == 0,
          );
    }, reason: '交易删除后分类笔数未归零');
  });

  test('transaction_splits 独立写入也必须触发统一数据变更信号', () async {
    final transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10.00',
      happenedAt: DateTime.now(),
      aaMode: 2,
    );
    final changed = Completer<void>();
    final subscription = container.listen(dataChangeSignalProvider, (_, next) {
      if (next.value?.any((update) => update.table == 'transaction_splits') ==
              true &&
          !changed.isCompleted) {
        changed.complete();
      }
    });
    addTearDown(subscription.close);

    // 先让 StreamProvider 完成对 Drift tableUpdates 的订阅，
    // 避免把订阅建立前的写入误当成信号丢失。
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await db
        .into(db.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: transactionId,
            memberId: 'member-1',
            amount: '10.00',
          ),
        );

    await expectLater(
      changed.future.timeout(const Duration(seconds: 1)),
      completes,
      reason: 'AA 分摊明细变化必须驱动 AA 统计等派生数据重算',
    );
  });

  test('批量导入与清空账本复用同一信号，所有汇总自动收敛', () async {
    final now = DateTime.now();
    final month = DateTime(now.year, now.month, 1);
    final categoryId = await repo.createCategory(name: '批量分类', kind: 'expense');
    final monthly = monthlyTotalsProvider((ledgerId: ledgerId, month: month));
    final counts = countsForLedgerProvider(ledgerId);
    final categories = container.listen(categoriesWithCountProvider, (_, _) {});
    final monthlySub = container.listen(monthly, (_, _) {});
    final countsSub = container.listen(counts, (_, _) {});
    addTearDown(() {
      categories.close();
      monthlySub.close();
      countsSub.close();
    });
    await container.read(monthly.future);
    await container.read(counts.future);

    TransactionsCompanion item(String id, String amount) =>
        TransactionsCompanion.insert(
          id: id,
          ledgerId: ledgerId,
          txType: 'expense',
          amount: amount,
          categoryId: d.Value(categoryId),
          happenedAt: now,
          currencyCode: 'CNY',
          nativeAmount: amount,
          createdAt: now,
          updatedAt: now,
        );

    await repo.insertTransactionsBatch([
      item('batch-1', '3'),
      item('batch-2', '7'),
    ], recordChanges: false);
    await waitUntil(
      () =>
          container.read(monthly).value == 10 &&
          container.read(counts).value?.txCount == 2,
      reason: '批量插入后首页或账本汇总未刷新',
    );
    await waitUntil(() {
      final value = container.read(categoriesWithCountProvider).value;
      return value?.any(
            (item) =>
                item.category.id == categoryId && item.transactionCount == 2,
          ) ??
          false;
    }, reason: '批量插入后分类汇总未刷新');

    expect(await repo.clearLedgerTransactions(ledgerId), 2);
    await waitUntil(
      () =>
          container.read(monthly).value == 0 &&
          container.read(counts).value?.txCount == 0,
      reason: '清空账本后派生汇总未归零',
    );
  });

  test('分类与账本按 id 缓存随统一数据变更信号刷新', () async {
    final categoryId = await repo.createCategory(name: '旧分类名', kind: 'expense');
    final category = categoryByIdProvider(categoryId);
    final ledger = ledgerByIdProvider(ledgerId);
    final categorySub = container.listen(category, (_, _) {});
    final ledgerSub = container.listen(ledger, (_, _) {});
    addTearDown(() {
      categorySub.close();
      ledgerSub.close();
    });

    expect((await container.read(category.future))?.name, '旧分类名');
    expect((await container.read(ledger.future))?.name, '测试账本');

    await repo.updateCategory(categoryId, name: '新分类名');
    await repo.updateLedger(id: ledgerId, name: '新账本名');

    await waitUntil(
      () =>
          container.read(category).value?.name == '新分类名' &&
          container.read(ledger).value?.name == '新账本名',
      reason: '按 id 缓存未随分类或账本更新失效',
      timeout: const Duration(seconds: 1),
    );
  });

  test('手动数据刷新 tick 通过统一信号使所有消费者失效', () async {
    var builds = 0;
    final consumer = Provider<int>((ref) {
      ref.watch(dataChangeSignalProvider);
      return ++builds;
    });
    final subscription = container.listen(consumer, (_, _) {});
    addTearDown(subscription.close);
    final buildsBeforeRefresh = container.read(consumer);

    container.read(manualDataRefreshProvider.notifier).tick();

    await waitUntil(
      () => builds > buildsBeforeRefresh,
      reason: '手动刷新未通过统一数据信号使消费者失效',
    );
    expect(
      container.read(consumer),
      greaterThan(buildsBeforeRefresh),
      reason: '公共刷新只应 tick 一次，不应在各页面逐个 invalidate',
    );
  });
}
