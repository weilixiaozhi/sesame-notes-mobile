import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 启屏预加载的执行体：重新跑一遍启动预加载并等待其完成。
typedef SplashPreloadRunner = Future<void> Function();

/// 启屏预加载的抽象入口（依赖倒置契约）。
///
/// 设计意图：启屏预加载必须跨 feature 聚合（安全初始化、可见币种、月度统计、
/// 周期交易生成……），实现只能放在能依赖 `features/*/application` 的顶层聚合
/// 模块（`lib/providers/app_init_providers.dart`）。而欢迎流程等 UI 侧需要在
/// seed 完成后重跑预加载，若直接 import 聚合模块，目录级依赖图就会出现
/// `features ↔ providers` 回边。
///
/// 因此本文件只声明契约并保持零 feature 依赖，由启动装配层（`main.dart`）把
/// 真实实现注入进来：UI 只认契约，聚合模块只认实现，依赖方向单向。
final splashPreloadRunnerProvider = Provider<SplashPreloadRunner>((ref) {
  throw UnimplementedError(
    'splashPreloadRunnerProvider 必须由启动装配层注入实现'
    '（main.dart 中 override 为 providers/app_init_providers.dart 的实现）',
  );
});
