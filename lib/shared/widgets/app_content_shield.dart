import 'package:flutter/widgets.dart';

/// 应用锁与后台隐私屏共用的业务内容隔离。
///
/// 隐藏时业务内容同时退出焦点、辅助语义与指针目标，读屏软件和点击都拿不到；
/// 子树始终保留在 Widget 树中，因此解锁后草稿、滚动位置和页面状态原样恢复。
class AppContentShield extends StatelessWidget {
  const AppContentShield({
    super.key,
    required this.hidden,
    required this.child,
  });

  /// 是否隐藏业务内容。
  final bool hidden;

  /// 始终保留在树中的业务内容。
  final Widget child;

  @override
  Widget build(BuildContext context) => ExcludeFocus(
    excluding: hidden,
    child: ExcludeSemantics(
      excluding: hidden,
      child: AbsorbPointer(absorbing: hidden, child: child),
    ),
  );
}
