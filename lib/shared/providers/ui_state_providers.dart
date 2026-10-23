// UI 状态叶子模块：底部导航、月选择、应用初始化状态与欢迎页闸门。
//
// 设计意图：启动编排（appSplashInitProvider 等跨 feature 聚合）在顶层
// providers 模块（lib/providers/app_init_providers.dart），本文件保持
// 零 feature 依赖。欢迎页闸门只依赖 SharedPreferences，与其余 UI 状态同处
// 叶子层，使 presentation 不必反向依赖顶层聚合模块（否则目录级依赖图会出现
// features ↔ providers 回边）。
export 'package:sesame_notes/shared/providers/refresh_ticks.dart'
    show ledgerListRefreshProvider;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/data/models/app_mode.dart';

/// 冷启动进入记账，运行期间由四域底栏直接选择当前业务。
final currentModeProvider =
    NotifierProvider<SimpleStateNotifier<AppMode>, AppMode>(
      () => SimpleStateNotifier((ref) => AppMode.bookkeeping),
    );

/// 当前内容位置：0 业务首页，1 业务统计或工具，2 日历，3 我的，4 健身计划或账号密码。
final bottomTabIndexProvider = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 0),
);

// 当前选中月份(每月第一天),默认当月
final selectedMonthProvider =
    NotifierProvider<SimpleStateNotifier<DateTime>, DateTime>(() {
      return SimpleStateNotifier((ref) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      });
    });

/// 应用初始化门槛；必需状态未完成或失败时不开放业务入口。
enum AppInitState {
  splash, // 显示启屏页
  loading, // 正在初始化
  failed, // 必需初始化失败，等待用户重试
  ready, // 初始化完成，显示主应用
}

// 应用初始化状态Provider
final appInitStateProvider =
    NotifierProvider<SimpleStateNotifier<AppInitState>, AppInitState>(
      () => SimpleStateNotifier((ref) => AppInitState.splash),
    );

/// 是否应该显示欢迎页面的Provider
final shouldShowWelcomeProvider =
    NotifierProvider<SimpleStateNotifier<bool>, bool>(
      () => SimpleStateNotifier((ref) => false),
    );

/// 初始化检查是否需要显示欢迎页面
final welcomeCheckProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final welcomeShown = prefs.getBool('welcome_shown') ?? false;
  if (!welcomeShown) {
    logger.info('WelcomeCheck', '👋 首次启动，需要展示欢迎页面');
    ref.read(shouldShowWelcomeProvider.notifier).set(true);
    return true;
  }
  return false;
});
