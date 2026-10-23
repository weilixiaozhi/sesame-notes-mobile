import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'selectable_card.dart';

/// 内容卡片共用皮肤边框、圆角、纸面和按压反馈。
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showShadow;
  final bool selected;

  /// 语义色卡片可指定底色，圆角、边框和交互仍使用公共卡片样式。
  final Color? color;

  /// 首页视觉摘要使用主卡圆角，结构留白仍由调用方提供。
  final bool hero;
  final bool textured;

  /// 卡片提供自然高度，点击范围覆盖整张卡片。
  const SectionCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.showShadow = true,
    this.selected = false,
    this.color,
    this.hero = false,
    this.textured = true,
    this.padding = const EdgeInsets.all(AppDimens.p12),
    this.margin = const EdgeInsets.symmetric(horizontal: AppDimens.p12),
  });

  /// 背景和内容保留 Material 祖先，确保内部按钮的交互层次正确。
  @override
  Widget build(BuildContext context) {
    final shape = hero
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.heroRadius(context)),
            side: AppTokens.cardBorder(context),
          )
        : selectableCardShape(context);
    final selectedShape = hero && shape is RoundedRectangleBorder
        ? shape.copyWith(
            side: selected
                ? BorderSide(color: AppTokens.primary(context))
                : shape.side,
          )
        : selectableCardShape(context, selected: selected);

    // 阴影由外层容器承载（不设颜色，避免在 ListTile 的 Material 祖先链中引入带背景色的 DecoratedBox），
    // 背景色与圆角交给 Material，保证 ListTile 家族的 ink 波纹与选中背景绘制在 Material 之上不被遮挡。
    return Container(
      margin: margin,
      decoration: ShapeDecoration(
        shape: shape,
        shadows: showShadow ? AppTokens.cardShadow(context) : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        color: color,
        shape: selectedShape,
        child: Ink(
          decoration: BoxDecoration(
            gradient: textured && !hero
                ? AppTokens.cardTexture(
                    context,
                    base: color ?? CardTheme.of(context).color,
                  )
                : null,
          ),
          child: onTap == null && onLongPress == null
              ? Padding(padding: padding, child: child)
              : InkWell(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  customBorder: selectedShape,
                  child: Padding(padding: padding, child: child),
                ),
        ),
      ),
    );
  }
}
