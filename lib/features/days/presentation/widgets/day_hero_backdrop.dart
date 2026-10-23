import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 最近事件的装饰圆仅提供视觉层次，不参与点击、布局或读屏内容。
class DayHeroBackdrop extends StatelessWidget {
  /// 装饰尺寸随内容高度变化，长文案和系统字号仍由内容自然排版。
  const DayHeroBackdrop({super.key, required this.child});
  final Widget child;

  /// 背景画笔从当前皮肤取色，不缓存主题快照。
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DayOrbitPainter(
      AppTokens.dayHeroLine(context),
      AppTokens.dayHeroDecorationOpacity(context),
    ),
    child: child,
  );
}

/// 用同心轮廓描绘轻量装饰，外层由主卡圆角裁剪。
class _DayOrbitPainter extends CustomPainter {
  /// 颜色和强调度共同决定是否需要重绘。
  const _DayOrbitPainter(this.color, this.opacity);
  final Color color;
  final double opacity;

  /// 装饰位于文字右侧，外圈逐层减淡。
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width + AppDimens.p8, size.height * 0.55);
    final radius = size.height * 0.38;
    final paint = Paint()..style = PaintingStyle.stroke;
    paint
      ..color = color.withValues(alpha: 0.09 * opacity)
      ..strokeWidth = AppDimens.p20;
    canvas.drawCircle(center, radius + AppDimens.p32, paint);
    paint
      ..color = color.withValues(alpha: 0.13 * opacity)
      ..strokeWidth = AppDimens.p20;
    canvas.drawCircle(center, radius + AppDimens.p12, paint);
    paint
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, paint);
  }

  /// 主题色或视觉风格变化时立即重绘装饰。
  @override
  bool shouldRepaint(_DayOrbitPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
