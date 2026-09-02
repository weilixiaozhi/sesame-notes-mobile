import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';

class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin; // 新增 margin 参数

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.p12),
    this.margin = const EdgeInsets.symmetric(horizontal: AppDimens.p12), // 默认值
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTokens.isDark(context);
    final borderWidth = AppTokens.cardOuterBorderWidth(context);
    final borderColor = AppTokens.cardOuterBorderColor(context);

    // 阴影由外层容器承载（不设颜色，避免在 ListTile 的 Material 祖先链中引入带背景色的 DecoratedBox），
    // 背景色与圆角交给 Material，保证 ListTile 家族的 ink 波纹与选中背景绘制在 Material 之上不被遮挡。
    return Container(
      margin: margin, // 使用传入的 margin
      decoration: BoxDecoration(
        boxShadow: isDark ? null : AppShadows.card, // 暗黑模式：无阴影，亮色模式：有阴影
      ),
      child: Material(
        color: AppTokens.surface(context), // ⭐ 使用 Token
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          side: borderWidth > 0
              ? BorderSide(
                  color: borderColor, // ⭐ 使用卡片边框 Token
                  width: borderWidth,
                )
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
