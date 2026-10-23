import 'package:flutter/material.dart';

/// 全局统一动画时长：页面转场与 bottom sheet 上滑动画共用。
///
/// 设计意图：所有全局动画时长收敛到这一处，避免各调用点各自写死时长导致
/// 观感不一致；如需整体调整动画速度，只需修改此常量一处即可全局生效。
const Duration kAppTransitionDuration = Duration(milliseconds: 200);

/// AA 退场时长须与 [kSheetAnimationStyle] 同步，避免同时收起时重叠拖影。
const Duration kAaPageSlideDuration = Duration(milliseconds: 200);

/// 与页面转场同速的 bottom sheet 动画样式。
final AnimationStyle kSheetAnimationStyle = AnimationStyle(
  duration: kAppTransitionDuration,
  reverseDuration: kAppTransitionDuration,
  curve: Curves.linear,
  reverseCurve: Curves.linear,
);

/// 使用主题转场和 [kAppTransitionDuration] 的页面路由。
PageRoute<T> appPageRoute<T>({
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool maintainState = true,
  bool fullscreenDialog = false,
}) {
  return _AppPageRoute<T>(
    builder: builder,
    settings: settings,
    maintainState: maintainState,
    fullscreenDialog: fullscreenDialog,
  );
}

/// go_router 页面描述，复用 [appPageRoute] 的转场及 opaque 语义。
class AppRouterPage<T> extends Page<T> {
  const AppRouterPage({
    super.key,
    required this.child,
    this.maintainState = true,
    super.name,
    super.arguments,
  });

  /// 页面内容。
  final Widget child;

  /// 是否在栈中保留下层页面状态（默认与 MaterialPage 一致）。
  final bool maintainState;

  @override
  Route<T> createRoute(BuildContext context) => _AppPageRoute<T>(
    builder: (_) => child,
    settings: this,
    maintainState: maintainState,
  );
}

/// 按 [kAppTransitionDuration] 统一进入和退出时长。
class _AppPageRoute<T> extends MaterialPageRoute<T> {
  _AppPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Duration get transitionDuration => kAppTransitionDuration;

  @override
  Duration get reverseTransitionDuration => kAppTransitionDuration;
}

/// AA 页进入时右滑，退出时与下层记账 sheet 同向下滑，避免重叠拖影。
Widget aaPageTransitionBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  // 进入：从右向左滑入（与全局页面转场一致）；退场反向时下滑移出。
  // 用一个 Tween 同时描述"右入/下出"两个阶段：正向动画为右滑入，
  // 反向（value 从 1→0）时偏移量从 (0,0) 滑向 (0,1)，即向下收起。
  final slideTween = Tween<Offset>(
    begin: const Offset(1, 0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.linear));
  // 退场阶段：从原位向下滑出，与 sheet 收起方向一致。
  // reverse 动画值从 1→0，经 ReverseAnimation 反转为 0→1 驱动下滑，
  // 保证退场起始帧处于原位 (0,0)，避免从屏外跳回造成闪动。
  final exitTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(0, 1),
  ).chain(CurveTween(curve: Curves.linear));
  final isExiting = animation.status == AnimationStatus.reverse;
  return SlideTransition(
    position: isExiting
        ? exitTween.animate(ReverseAnimation(animation))
        : slideTween.animate(animation),
    child: child,
  );
}
