import 'package:sesame_notes/theme/colors.dart';
import 'package:flutter/material.dart';

/// 按压反馈按键：[onDown] 按下触发，[onCancel] 可回滚滑出操作，
/// [onUp] 用于松手后提交或关闭页面。
class PressKey extends StatefulWidget {
  const PressKey({
    super.key,
    required this.child,
    this.onDown,
    this.onUp,
    this.onCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.backgroundColor,
    this.pressedColor,
    this.splashFactory,
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
  final VoidCallback? onLongPressStart;

  /// 常态背景色；null = 透明。
  final Color? backgroundColor;

  /// 按压态背景色；null 时按明暗模式在常态色上叠 18% 黑/白。
  final Color? pressedColor;

  /// 导航入口可使用原生涟漪，其余按键保留即时按压反馈。
  final InteractiveInkFeatureFactory? splashFactory;

  final BorderRadius? borderRadius;

  /// 按压时视觉缩放比例；长条/区域按钮请保持 1.0，避免整条跳动。
  final double scale;

  /// 禁用时无按压态、不触发任何回调。
  final bool enabled;

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

  void _handleDown(TapDownDetails _) {
    if (!widget.enabled) return;
    widget.onDown?.call();
  }

  void _handleUp(TapUpDetails _) {
    if (!widget.enabled) return;
    _setPressed(false);
    widget.onUp?.call();
  }

  void _handleCancel() {
    if (!widget.enabled) return;
    _setPressed(false);
    widget.onCancel?.call();
  }

  void _handleLongPressStart(LongPressStartDetails _) {
    if (!widget.enabled) return;
    widget.onLongPressStart?.call();
  }

  void _handleLongPress() {
    if (!widget.enabled) return;
    widget.onLongPress?.call();
  }

  Color _resolvedPressedColor(BuildContext context) {
    final explicit = widget.pressedColor;
    if (explicit != null) return explicit;
    final base = widget.backgroundColor ?? Colors.transparent;
    return AppTokens.pressedBackground(context, base);
  }

  /// 构建按压反馈，并将长按交给当前交互组件按平台默认时长识别。
  @override
  Widget build(BuildContext context) {
    final color = _pressed
        ? _resolvedPressedColor(context)
        : (widget.backgroundColor ?? Colors.transparent);
    return widget.splashFactory != null
        ? Material(
            color: widget.backgroundColor ?? Colors.transparent,
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              splashFactory: widget.splashFactory,
              onTap: widget.enabled ? widget.onUp : null,
              onTapDown: widget.enabled ? _handleDown : null,
              onTapCancel: widget.enabled ? _handleCancel : null,
              onLongPress: widget.enabled ? widget.onLongPress : null,
              child: widget.child,
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled ? _handleDown : null,
            onTapUp: widget.enabled ? _handleUp : null,
            onTapCancel: widget.enabled ? _handleCancel : null,
            onLongPressStart: widget.enabled && widget.onLongPressStart != null
                ? _handleLongPressStart
                : null,
            onLongPress: widget.enabled && widget.onLongPress != null
                ? _handleLongPress
                : null,
            // Listener 立即更新按压态，避免 sheet 的拖拽手势竞争延迟反馈。
            // 业务回调仍由 GestureDetector 处理。
            child: Listener(
              behavior: HitTestBehavior.deferToChild,
              onPointerDown: widget.enabled ? (_) => _setPressed(true) : null,
              onPointerUp: widget.enabled ? (_) => _setPressed(false) : null,
              onPointerCancel: widget.enabled
                  ? (_) => _setPressed(false)
                  : null,
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
