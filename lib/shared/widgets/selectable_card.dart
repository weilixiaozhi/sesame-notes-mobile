import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 卡片表面与选中角标使用同一层级的主题几何。
ShapeBorder selectableCardShape(
  BuildContext context, {
  bool selected = false,
  BorderSide? unselectedBorder,
}) {
  final shape =
      CardTheme.of(context).shape ??
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.cardRadius(context)),
        side: AppTokens.cardBorder(context),
      );
  return shape is OutlinedBorder
      ? shape.copyWith(
          side: selected
              ? BorderSide(color: AppTokens.primary(context))
              : unselectedBorder ?? shape.side,
        )
      : shape;
}

/// 选中卡片右上角角标：26×26 斜切角标，完整选中为对勾、部分选中为短横线。
///
/// 组件自身渲染为 [Positioned](top/right 各外移 1px,与边框宽度齐平,
/// 使角标覆盖在边框之上且不凸出卡片),须作为 [Stack] 直接子级、仅选中时挂载。
class SelectableCardCheckBadge extends StatelessWidget {
  /// 是否使用可操作的主题色；禁用态使用主题禁用灰。
  final bool enabled;

  /// 是否仅覆盖卡片内的部分条目。
  final bool partial;

  /// 创建贴合卡片右上圆角的选中标记。
  const SelectableCardCheckBadge({
    super.key,
    this.enabled = true,
    this.partial = false,
  });

  /// 沿卡片外缘绘制角标，斜线左下留给卡片内容。
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = AppTokens.textOnPrimary(context);
    final shape = selectableCardShape(context);
    return Positioned(
      top: -1,
      right: -1,
      // 角标仅作装饰，点击交给下方卡片的手势组件。
      child: IgnorePointer(
        child: ClipPath(
          clipper: _SelectableCardCornerClipper(
            shape is RoundedRectangleBorder
                ? shape.borderRadius
                      .resolve(Directionality.of(context))
                      .topRight
                : Radius.zero,
          ),
          child: ColoredBox(
            color: enabled ? theme.colorScheme.primary : theme.disabledColor,
            child: SizedBox.square(
              dimension: AppDimens.selectionBadgeSize,
              child: Padding(
                // 对勾向右上光学居中，与斜边和外圆角均保留间隙。
                padding: const EdgeInsets.only(
                  top: AppDimens.p3,
                  right: AppDimens.p3,
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: partial
                      ? SizedBox.square(
                          dimension: AppDimens.icon12,
                          child: Center(
                            child: Container(
                              width: AppDimens.p8,
                              height: AppDimens.selectionBadgeGap,
                              decoration: BoxDecoration(
                                color: foreground,
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radius4,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          AppIcons.check,
                          size: AppDimens.icon12,
                          color: foreground,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 裁出右上圆角与 45° 斜边，外弧与卡片圆角重合。
class _SelectableCardCornerClipper extends CustomClipper<Path> {
  const _SelectableCardCornerClipper(this.corner);
  final Radius corner;

  /// 从顶边沿右上圆弧走到右边，再沿对角线闭合。
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width - corner.x.clamp(0, size.width), 0)
    ..arcToPoint(
      Offset(size.width, corner.y.clamp(0, size.height)),
      radius: corner,
    )
    ..lineTo(size.width, size.height)
    ..close();

  /// 裁剪规则不随组件状态变化，尺寸变化由框架触发重新裁剪。
  @override
  bool shouldReclip(_SelectableCardCornerClipper oldClipper) =>
      oldClipper.corner != corner;
}
