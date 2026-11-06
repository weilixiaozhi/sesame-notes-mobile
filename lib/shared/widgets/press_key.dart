import 'package:sesame_notes/theme/colors.dart';
import 'package:flutter/material.dart';

/// 按压反馈按键：[onDown] 按下触发，[onCancel] 可回滚滑出操作，
/// [onUp] 用于松手后提交或关闭页面。
class PressKey extends StatefulWidget {
  /// 按键统一维护按压反馈，业务只提供各手势阶段的动作。
  const PressKey({
    super.key,
    required this.child,
    this.onDown,
    this.onUp,
    this.onCancel,
    this.onLongPress,
    this.backgroundColor,
    this.borderRadius,
    this.scale = 1.0,
    this.enabled = true,
  });

  final Widget child;

  /// 按下瞬间回调（用于即时提交）。
  final VoidCallback? onDown;

  /// 松手回调（用于需要确认后才提交的操作）。
  final VoidCallback? onUp;

  /// 手势取消/滑出按键范围回调（用于回滚 [onDown] 的即时提交）。
  final VoidCallback? onCancel;

  final VoidCallback? onLongPress;

  /// 常态背景色；null = 透明。
  final Color? backgroundColor;

  final BorderRadius? borderRadius;

  /// 按压时视觉缩放比例；长条/区域按钮请保持 1.0，避免整条跳动。
  final double scale;

  /// 禁用时无按压态、不触发任何回调。
  final bool enabled;

  /// 每个键位独立保存按下状态，随组件释放。
  @override
  State<PressKey> createState() => _PressKeyState();
}

class _PressKeyState extends State<PressKey> {
  bool _pressed = false;

  /// 统一切换按压态，避免重复 setState。
  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    setState(() => _pressed = value);
  }

  /// 手势识别为按下时提交即时操作，禁用状态不派发动作。
  void _handleDown(TapDownDetails _) {
    if (!widget.enabled) return;
    widget.onDown?.call();
  }

  /// 松手先恢复外观，再执行提交或关闭动作。
  void _handleUp(TapUpDetails _) {
    if (!widget.enabled) return;
    _setPressed(false);
    widget.onUp?.call();
  }

  /// 滑出或手势竞争取消时恢复外观，并交由业务回滚即时操作。
  void _handleCancel() {
    if (!widget.enabled) return;
    _setPressed(false);
    widget.onCancel?.call();
  }

  /// 长按到达平台阈值后执行清空等业务动作。
  void _handleLongPress() {
    if (!widget.enabled) return;
    widget.onLongPress?.call();
  }

  /// 构建按压反馈，并将长按交给当前交互组件按平台默认时长识别。
  @override
  Widget build(BuildContext context) {
    final base = widget.backgroundColor ?? Colors.transparent;
    final color = _pressed ? AppTokens.pressedBackground(context, base) : base;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.enabled ? _handleDown : null,
      onTapUp: widget.enabled ? _handleUp : null,
      onTapCancel: widget.enabled ? _handleCancel : null,
      onLongPress: widget.enabled && widget.onLongPress != null
          ? _handleLongPress
          : null,
      // Listener 立即更新按压态，避免 sheet 的拖拽手势竞争延迟反馈。
      // 业务回调仍由 GestureDetector 处理。
      child: Listener(
        behavior: HitTestBehavior.deferToChild,
        onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
        onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
        onPointerCancel: widget.enabled ? (_) => _setPressed(false) : null,
        child: AnimatedScale(
          scale: _pressed ? widget.scale : 1.0,
          duration: const Duration(milliseconds: 70),
          curve: Curves.easeOut,
          child: Material(
            color: color,
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
