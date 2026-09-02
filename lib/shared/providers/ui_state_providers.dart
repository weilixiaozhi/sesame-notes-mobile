// UI 状态叶子模块：底部导航、月选择、应用初始化状态与欢迎页闸门。
//
// 设计意图：启动编排（appSplashInitProvider 等跨 feature 聚合）在顶层
// providers 模块（lib/providers/app_init_providers.dart），本文件保持
// 零 feature 依赖。欢迎页闸门只依赖 SharedPreferences，与其余 UI 状态同处
// 叶子层，使 presentation 不必反向依赖顶层聚合模块（否则目录级依赖图会出现
// features ↔ providers 回边）。
export 'package:sesame_notes/shared/providers/refresh_ticks.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

// 底部导航索引（0: 明细, 3: 我的；1/2 为占位）
final bottomTabIndexProvider = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 0),
);

// 首页滚动到顶部触发器（每次改变值时触发滚动）
final homeScrollToTopProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

// Currently selected month (first day), default to now
final selectedMonthProvider =
    NotifierProvider<SimpleStateNotifier<DateTime>, DateTime>(() {
      return SimpleStateNotifier((ref) {
        final now = DateTime.now();
        return DateTime(now.year, now.month, 1);
      });
    });

// 应用初始化状态
enum AppInitState {
  splash, // 显示启屏页
  loading, // 正在初始化
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
