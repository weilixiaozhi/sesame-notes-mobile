import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 单个 Overlay 上当前活跃的 toast（entry + 自动消失定时器）。
class _ActiveToast {
  _ActiveToast(this.entry, this.timer);

  final OverlayEntry entry;
  final Timer timer;
}

/// 按 Overlay 实例跟踪活跃 toast，避免根 / 嵌套多个 Overlay 互相干扰；
/// 同一 Overlay 上「后到覆盖前到」，不叠加多个全屏 OverlayEntry。
final Map<OverlayState, _ActiveToast> _activeToasts = {};

/// 轻量 Toast（基础 UI 工具）：覆盖层展示，不占据布局，不顶起 FAB
void showToast(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 1),
}) {
  showToastOnOverlay(
    Overlay.of(context, rootOverlay: true),
    message,
    duration: duration,
    isDark: AppTokens.isDark(context),
  );
}

/// 用指定的 OverlayState 直接弹 Toast —— 给没有就近 BuildContext 的全局场景
/// (如 deep-link 处理:`globalNavigatorKey.currentState?.overlay`)。普通页面
/// 请用 [showToast]。注意不能用 navigator 的 context 走 [showToast],因为它在
/// Overlay 之上,`Overlay.of` 找不到祖先 Overlay 会抛 "No Overlay widget found"。
void showToastOnOverlay(
  OverlayState overlay,
  String message, {
  Duration duration = const Duration(seconds: 1),
  bool? isDark,
}) {
  final dark = isDark ?? AppTokens.isDark(overlay.context);

  // 后到覆盖前到：先移除当前 toast 并取消其定时器，避免多条全屏浮层叠加。
  _removeToast(overlay);

  final entry = OverlayEntry(
    builder: (ctx) => Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppDimens.p20),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p12,
                  vertical: AppDimens.p12,
                ),
                decoration: BoxDecoration(
                  color: AppTokens.toastSurface(ctx),
                  borderRadius: BorderRadius.circular(
                    AppTokens.cardRadius(ctx),
                  ),
                  // 暗黑模式下添加白色阴影，提升可见度
                  boxShadow: dark ? AppTokens.toastShadow : null,
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTokens.toastText(ctx)),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  final timer = Timer(duration, () => _removeToast(overlay));
  _activeToasts[overlay] = _ActiveToast(entry, timer);
}

/// 移除已插入的 toast；OverlayEntry.remove 自身兼容 Overlay 已销毁。
void _removeToast(OverlayState overlay) {
  final active = _activeToasts.remove(overlay);
  if (active == null) return;
  active.timer.cancel();
  // mounted 只表示浮层内容已构建；首帧前到期也必须撤销已插入的 entry。
  active.entry.remove();
  active.entry.dispose();
}
