import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'dart:async';
import '../shared/providers/read_provider_future.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/transactions/application/recurring_transaction_service.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/published_ledger_queries.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 应用启动编排（顶层聚合模块）。
///
/// 设计意图：启动预加载需要跨 feature 拉取（安全初始化、可见币种、月度统计、
/// 周期交易生成……），若放在 shared/providers 会造成装配层反向依赖
/// features/*/application。这里作为顶层聚合模块，单向依赖各 feature 的
/// application 层与 shared/providers 基础装配。

/// 首屏只等待本地身份、偏好和数据准备，远端事务由后台生命周期处理。
Future<void> initializeLocalApp(ProviderContainer container) async {
  try {
    container.read(appInitStateProvider.notifier).set(AppInitState.loading);
    // 启动尚未挂载界面，等待期间保持订阅，使依赖变化后的有效版本继续重建。
    await readProviderFutureFromContainer(
      container,
      accountBootstrapProvider.future,
    );
    // 欢迎状态也是必需的本地事实；只有这些读取结束，启屏用例才能发布 ready。
    await readProviderFutureFromContainer(
      container,
      welcomeCheckProvider.future,
    );
    await readProviderFutureFromContainer(
      container,
      appSplashInitProvider.future,
    );
  } catch (error, stackTrace) {
    container.read(appInitStateProvider.notifier).set(AppInitState.failed);
    logger.error('App', '本地启动数据准备失败', safeErrorSummary(error), stackTrace);
    rethrow;
  }
}

/// 显式重试重新读取失败的本地事实，失败由初始化界面持续展示且不泄露底层详情。
Future<void> retryLocalAppInitialization(ProviderContainer container) async {
  if (container.read(appInitStateProvider) == AppInitState.loading) return;
  try {
    container.invalidate(sharedPreferencesProvider);
    container.invalidate(accountBootstrapProvider);
    container.invalidate(welcomeCheckProvider);
    container.invalidate(securityInitProvider);
    container.invalidate(appSplashInitProvider);
    await initializeLocalApp(container);
  } catch (error, stackTrace) {
    logger.error('App', '本地启动重试未完成', safeErrorSummary(error), stackTrace);
  }
}

/// 就绪后由启动生命周期配置主提醒服务，测试可替换系统适配器。
final appReminderMonitorProvider = Provider<ReminderMonitorService>(
  (ref) => ReminderMonitorService(),
);

/// 原生通知初始化与冷启动意图恢复，实际导航仍等待界面和锁屏放行。
final startupNotificationRestoreProvider = Provider<Future<void> Function()>(
  (ref) => () async {
    await NotificationFactory.getInstance().initialize();
    await NotificationFactory.restoreLaunchNotification();
  },
);

/// 仅在首次 ready 后开启后台启动任务，欢迎页重跑预加载不会重复注册或刷新会话。
final appStartupLifecycleProvider = Provider<void>((ref) {
  ReminderMonitorService? monitor;
  ref.onDispose(() => monitor?.clearTexts());
  _afterFirstFrame(() async {
    if (!ref.mounted || ref.read(appInitStateProvider) != AppInitState.ready) {
      return;
    }
    // 网络刷新使用独立 Future，不阻塞本地提醒恢复或就绪界面的交互。
    unawaited(ref.read(accountStartupRefreshProvider.future));
    try {
      monitor = ref.read(appReminderMonitorProvider);
      monitor!.configureTexts(
        textsProvider: () {
          final locale =
              ref.read(languageProvider) ??
              WidgetsBinding.instance.platformDispatcher.locale;
          final l10n = lookupAppLocalizations(locale);
          return (title: l10n.reminderTitle, body: l10n.reminderBody);
        },
      );
    } catch (error, stackTrace) {
      logger.error('App', '提醒文案配置失败', safeErrorSummary(error), stackTrace);
    }
    try {
      await ref.read(startupNotificationRestoreProvider)();
    } catch (error, stackTrace) {
      logger.error(
        'App',
        '通知初始化未完成，稍后可重试',
        safeErrorSummary(error),
        stackTrace,
      );
    }
    if (!ref.mounted) return;
    try {
      await monitor?.restoreReminder();
    } catch (error, stackTrace) {
      logger.error(
        'App',
        '提醒恢复失败，返回前台时会重试',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  });
});

/// 常驻会话装配：账号状态负责身份事实，实时协调器负责连接启停与重连。
final appSessionLifecycleProvider = Provider<void>((ref) {
  ref.read(accountStateProvider);
  ref.watch(realtimeCoordinatorProvider);
  ref.watch(accountStartupRefreshProvider);
  ref.listen(cloudCapabilityProvider.select((value) => value.canSync), (
    previous,
    next,
  ) async {
    try {
      final coordinator = ref.read(realtimeCoordinatorProvider);
      if (!next) {
        await coordinator.stop();
      } else {
        await coordinator.start();
      }
    } catch (error, stackTrace) {
      logger.error('AppSession', '实时通知暂不可用，请稍后重试', error, stackTrace);
    }
  }, fireImmediately: true);
});

/// 首帧后静默收尾账号事务，会话恢复时补查属于当前账号的云本。
final accountRecoveryLifecycleProvider = Provider<void>((ref) {
  var firstFrameReady = false;
  var previous = Future<void>.value();

  /// 串行消费恢复请求，避免同一份待撤销凭证被并发轮换。
  Future<void> recover() {
    previous = previous.then((_) async {
      if (!ref.mounted) return;
      try {
        // 每轮重新读取持久待办，已完成的撤销和本地发布不会重复执行。
        ref.invalidate(accountRecoveryProvider);
        await ref.read(accountRecoveryProvider.future);
      } catch (error, stackTrace) {
        logger.error(
          'AccountRecovery',
          '后台账号恢复未完成，保留待办供后续重试',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    });
    return previous;
  }

  ref.listen(authSessionProvider.select((session) => session?.userId), (
    previousAccount,
    nextAccount,
  ) {
    if (firstFrameReady &&
        nextAccount != null &&
        nextAccount != previousAccount) {
      unawaited(recover());
    }
  });
  _afterFirstFrame(() async {
    if (!ref.mounted) return;
    firstFrameReady = true;
    await recover();
  });
});

/// 当前本选择跟随应用生命周期，登录路由覆盖首页时也持续响应目录变化。
final currentBookSelectionLifecycleProvider = Provider<void>((ref) {
  // 在路由之上持有选择和展示依赖，让空本到位、账号切换与删除回落及时收敛。
  // 页面恢复时只读取已更新的当前本，避免暂停依赖在路由构建中同步重算。
  ref.watch(currentLedgerPersistProvider);
  ref.watch(currentLedgerDisplayProvider);
  ref.watch(currentDayBookProvider);
  ref.watch(currentMemoBookProvider);
  ref.watch(currentCredentialBookProvider);
  ref.watch(currentFitnessSpaceProvider);
});

/// 启屏预加载的实现，供启动装配层注入到 `splashPreloadRunnerProvider`。
///
/// 先 invalidate 再读取：本 provider 在 main() 启动阶段已针对「空数据库」跑过
/// 一遍并缓存了结果，欢迎流程 seed 完成后必须强制重跑，否则读回的是空/陈旧的
/// 预加载结果。
SplashPreloadRunner buildSplashPreloadRunner(Ref ref) => () async {
  ref.invalidate(appSplashInitProvider);
  return ref.read(appSplashInitProvider.future);
};

/// 把重型后台预加载排到首帧之后。
///
/// 直接起微任务会在首帧渲染前抢占主线程，把启动图停留时间拖长；
/// 这些预加载的展示结果由数据库监听驱动，晚一帧执行不影响正确性。
void _afterFirstFrame(Future<void> Function() task) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(task());
  });
}

/// 安全初始化是必需门槛，统计与外观预加载失败只影响首屏缓存。
final appSplashInitProvider = FutureProvider<void>((ref) async {
  const tag = 'Splash';
  logger.info(tag, '开始启屏页预加载');
  final startTime = DateTime.now();
  var stepTime = startTime;

  try {
    await ref.watch(securityInitProvider.future);
  } catch (error, stackTrace) {
    if (ref.mounted) {
      ref.read(appInitStateProvider.notifier).set(AppInitState.failed);
    }
    logger.error(tag, '安全初始化未完成，业务入口保持关闭', safeErrorSummary(error), stackTrace);
    rethrow;
  }

  try {
    // 确保基础providers已初始化
    logger.info(tag, '初始化基础配置...');
    await Future.wait([
      ref.watch(themeModeInitProvider.future),
      ref.watch(themePresetInitProvider.future),
      ref.watch(appInitProvider.future),
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
    final startDay = (ledgerRow?.monthStartDay ?? 1).clamp(1, 31);
    final currentMonth = labelForDate(now, startDay);
    ref.read(selectedMonthProvider.notifier).set(currentMonth);

    // 预加载月度统计；当前页面的交易列表由按月 Stream 查询。
    final monthlyParams = (ledgerId: ledgerId, month: currentMonth);
    final monthlyResult = await readProviderFutureFromRef(
      ref,
      monthlyTotalsProvider(monthlyParams).future,
    );

    ref
        .read(lastMonthlyTotalsProvider(monthlyParams).notifier)
        .set(monthlyResult);
    logger.info(
      tag,
      '月度统计预加载完成: ${DateTime.now().difference(stepTime).inMilliseconds}ms',
    );

    // 账本统计异步加载（不阻塞启动）
    _afterFirstFrame(() async {
      try {
        final start = DateTime.now();
        if (!ref.mounted) return;
        await readProviderFutureFromRef(
          ref,
          countsForLedgerProvider(ledgerId).future,
        );
        logger.info(
          tag,
          '账本统计(异步): ${DateTime.now().difference(start).inMilliseconds}ms',
        );
      } catch (error, stackTrace) {
        logger.error(tag, '账本统计预加载未完成', safeErrorSummary(error), stackTrace);
      }
    });

    // 周期交易生成放到启动后异步执行：内部是「账本×模板×每笔」的 N+1 查询，
    // 因此不阻塞首屏；写库后的页面更新由数据库监听统一处理。
    _afterFirstFrame(() async {
      try {
        // 任务开始时重新解析仓库，避免捕获到启动阶段可能已失效的旧实例。
        final freshRepo = ref.read(repositoryProvider);
        // 只扫描当前账号已发布的账本；归档账本仍按模板正常生成。
        final ledgers = await readPublishedLedgers(ref.read, archived: null);
        final generatedLedgerIds =
            await RecurringTransactionService.generatePendingTransactionsStatic(
              repository: freshRepo,
              ledgers: ledgers,
            );
        if (generatedLedgerIds.isNotEmpty) {
          logger.info(tag, '周期交易生成完成(启动后异步): ${generatedLedgerIds.length} 本账本');
        }
      } catch (e, stackTrace) {
        logger.error(tag, '周期交易生成失败', e, stackTrace);
      }
    });
  } catch (e, stackTrace) {
    logger.error(tag, '预加载数据失败', e, stackTrace);
  }

  // 计算数据预加载耗时
  final dataLoadTime = DateTime.now().difference(startTime);
  logger.info(tag, '预加载总耗时: ${dataLoadTime.inMilliseconds}ms，切换到主应用');
  if (ref.mounted) {
    ref.read(appInitStateProvider.notifier).set(AppInitState.ready);
  }
});
