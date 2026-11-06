import 'package:flutter/material.dart';

/// 全局统一动画时长：页面转场与 bottom sheet 上滑动画共用。
///
/// 设计意图：所有全局动画时长收敛到这一处，避免各调用点各自写死时长导致
/// 观感不一致；如需整体调整动画速度，只需修改此常量一处即可全局生效。
const Duration kAppTransitionDuration = Duration(milliseconds: 200);

/// 与页面转场同速的 bottom sheet 动画样式。
final AnimationStyle kSheetAnimationStyle = AnimationStyle(
  duration: kAppTransitionDuration,
  reverseDuration: kAppTransitionDuration,
  curve: Curves.linear,
  reverseCurve: Curves.linear,
);

/// 使用主题转场和 [kAppTransitionDuration] 的页面路由。
PageRoute<T> appPageRoute<T>({required WidgetBuilder builder}) =>
    _AppPageRoute<T>(builder: builder);

/// go_router 页面描述，复用 [appPageRoute] 的转场及 opaque 语义。
class AppRouterPage<T> extends Page<T> {
  /// 保留页面身份和内容，转场由统一路由实现处理。
  const AppRouterPage({
    super.key,
    required this.child,
    super.name,
    super.arguments,
  });

  /// 页面内容。
  final Widget child;

  /// 页面描述作为路由设置传入，保留名称及导航身份。
  @override
  Route<T> createRoute(BuildContext context) =>
      _AppPageRoute<T>(builder: (_) => child, settings: this);
}

/// 按 [kAppTransitionDuration] 统一进入和退出时长。
class _AppPageRoute<T> extends MaterialPageRoute<T> {
  /// 页面状态保留和非全屏对话行为沿用 MaterialPageRoute 的默认值。
  _AppPageRoute({required super.builder, super.settings});

  /// 页面进入与弹层共用动画时长。
  @override
  Duration get transitionDuration => kAppTransitionDuration;

  /// 退出使用同一时长，保持导航节奏一致。
  @override
  Duration get reverseTransitionDuration => kAppTransitionDuration;
}
