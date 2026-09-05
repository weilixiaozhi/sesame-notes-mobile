import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' show Category, Transaction;
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 应用启动编排（顶层聚合模块）。
///
/// 设计意图：启动预加载需要跨 feature 拉取（安全初始化、可见币种、月度统计、
/// 周期交易生成……），若放在 shared/providers 会造成装配层反向依赖
/// features/*/application。这里作为顶层聚合模块，单向依赖各 feature 的
/// application 层与 shared/providers 基础装配。

/// 启屏预加载的实现，供启动装配层注入到 `splashPreloadRunnerProvider`。
///
/// 先 invalidate 再读取：本 provider 在 main() 启动阶段已针对「空数据库」跑过
/// 一遍并缓存了结果，欢迎流程 seed 完成后必须强制重跑，否则读回的是空/陈旧的
/// 预加载结果。
SplashPreloadRunner buildSplashPreloadRunner(Ref ref) => () async {
  ref.invalidate(appSplashInitProvider);
  return ref.read(appSplashInitProvider.future);
};

/// 应用初始化Provider - 管理数据预加载
final appSplashInitProvider = FutureProvider<void>((ref) async {
  const tag = 'Splash';
  logger.info(tag, '开始启屏页预加载');
  final startTime = DateTime.now();
  var stepTime = startTime;

  try {
    // 确保基础providers已初始化
    logger.info(tag, '初始化基础配置...');
    await Future.wait([
      ref.watch(themeModeInitProvider.future),
      ref.watch(appInitProvider.future),
      ref.watch(securityInitProvider.future),
      // 可见币种集合初始化(内部等待当前账本就绪后加载其专属集合,
      // 与此处并行安全)
      ref.watch(visibleCurrenciesInitProvider.future),
    ]);
    logger.info(
      tag,
      '基础配置初始化完成: ${DateTime.now().difference(stepTime).inMilliseconds}ms',
    );
    stepTime = DateTime.now();

    // 获取 repository
    final repo = ref.read(repositoryProvider);

    // 预加载当前账本的关键数据
    final ledgerId = ref.read(currentLedgerIdProvider);
    final now = DateTime.now();
    // 月份周期标签:startDay>1 时今天可能属于「上个标签月」(如 6月5日属 5月周期)
    final ledgerRow = await repo.getLedgerById(ledgerId);
    final startDay = (ledgerRow?.monthStartDay ?? 1).clamp(1, 28);
    final currentMonth = labelForDate(now, startDay);
    ref.read(selectedMonthProvider.notifier).set(currentMonth);

    // 并行预加载：月度统计 + 交易列表（分别计时）
    final monthlyParams = (ledgerId: ledgerId, month: currentMonth);

    // 包装每个任务以记录各自耗时
    Future<T> timed<T>(String name, Future<T> future) async {
      final start = DateTime.now();
      final result = await future;
      logger.info(
        tag,
        '$name: ${DateTime.now().difference(start).inMilliseconds}ms',
      );
      return result;
    }

    // 首屏预加载条数限制（只加载前 N 条，加快启动速度）
    const preloadLimit = 20;

    final results = await Future.wait([
      timed('月度统计', ref.read(monthlyTotalsProvider(monthlyParams).future)),
      // 只查询前 N 条，而非全部
      timed(
        '交易列表(前$preloadLimit条)',
        repo.getRecentTransactionsWithCategory(
          ledgerId: ledgerId,
          limit: preloadLimit,
        ),
      ),
    ]);

    final monthlyResult = results[0] as double;
    final transactionsWithCategory =
        results[1] as List<({Transaction t, Category? category})>;

    ref
        .read(lastMonthlyTotalsProvider(monthlyParams).notifier)
        .set(monthlyResult);
    // 不预加载完整列表，让 Stream 自己加载
    logger.info(
      tag,
      '并行预加载完成: ${DateTime.now().difference(stepTime).inMilliseconds}ms, 首屏${transactionsWithCategory.length}条',
    );

    // 组装完整的交易展示数据
    final fullTransactions = transactionsWithCategory
        .map(
          (item) =>
              (t: item.t.toDisplay(), category: item.category?.toDisplay()),
        )
        .toList(growable: false);

    ref.read(cachedTransactionsProvider.notifier).set(fullTransactions);

    // 账本统计异步加载（不阻塞启动）
    Future.microtask(() async {
      final start = DateTime.now();
      await ref.read(countsForLedgerProvider(ledgerId).future);
      logger.info(
        tag,
        '账本统计(异步): ${DateTime.now().difference(start).inMilliseconds}ms',
      );
    });

    // 周期交易生成放到启动后异步执行：内部是「账本×模板×每笔」的 N+1 查询，
    // 因此不阻塞首屏；写库后的页面更新由数据库监听统一处理。
    unawaited(
      Future.microtask(() async {
        try {
          // 微任务执行时重新解析仓库，避免捕获到启动阶段可能已失效的旧实例。
          final freshRepo = ref.read(repositoryProvider);
          final generatedLedgerIds =
              await RecurringTransactionService.generatePendingTransactionsStatic(
                repository: freshRepo,
                verbose: false,
              );
          if (generatedLedgerIds.isNotEmpty) {
            logger.info(
              tag,
              '周期交易生成完成(启动后异步): ${generatedLedgerIds.length} 本账本',
            );
          }
        } catch (e, stackTrace) {
          logger.error(tag, '周期交易生成失败', e, stackTrace);
        }
      }),
    );
  } catch (e, stackTrace) {
    logger.error(tag, '预加载数据失败', e, stackTrace);
  }

  // 计算数据预加载耗时
  final dataLoadTime = DateTime.now().difference(startTime);
  logger.info(tag, '预加载总耗时: ${dataLoadTime.inMilliseconds}ms，切换到主应用');
  ref.read(appInitStateProvider.notifier).set(AppInitState.ready);
});
