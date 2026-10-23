import 'package:sesame_notes/shared/widgets/calendar_entry_scope.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 明细列表共用布局：圆形图标、主次文本及右侧数值。
class DetailListItem extends StatelessWidget {
  /// 业务只提供内容和交互，行距、字体及列间距统一维护。
  const DetailListItem({
    super.key,
    this.leading,
    required this.title,
    this.titleWidget,
    required this.subtitle,
    this.trailing,
    this.compact = false,
    this.titleStyle,
    this.minHeight,
    this.onTap,
    this.onLongPress,
    this.horizontalPadding = AppDimens.p12,
  });

  final Widget? leading;
  final String title;

  /// 标题需要业务徽标时提供组合内容，默认仍使用普通单行标题。
  final Widget? titleWidget;
  final Widget subtitle;
  final Widget? trailing;

  /// 轻量条目的右栏最多占剩余空间的一半，避免大字模式挤出屏幕。
  final bool compact;
  final TextStyle? titleStyle;
  final double? minHeight;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 外层已提供页面边距的平铺列表可以独立指定行内水平留白。
  final double horizontalPadding;

  /// 有图标时保留记账数值列宽，无图标时将空间均分给日期与统计两列。
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    onLongPress: onLongPress,
    child: Container(
      constraints: minHeight != null || compact
          ? BoxConstraints(minHeight: minHeight ?? kMinInteractiveDimension)
          : null,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppDimens.listRowVertical,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppDimens.p12),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppDimens.p12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget ??
                      Text(
                        title,
                        style:
                            titleStyle ??
                            (CalendarEntryScope.active(context)
                                    ? AppTextTokens.title(context)
                                    : AppTextTokens.label(context))
                                .copyWith(
                                  color: AppTokens.textPrimary(context),
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  subtitle,
                ],
              ),
            ),
          ),
          if (trailing != null)
            if (compact)
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing!,
                ),
              )
            else if (leading == null)
              Expanded(child: trailing!)
            else
              SizedBox(width: AppDimens.detailTrailingWidth, child: trailing),
        ],
      ),
    ),
  );
}

/// 明细分类与状态使用同一轻量标签，保持正文下的次要层级。
class DetailListTag extends StatelessWidget {
  /// 业务只提供语义色和必要留白，文字与轮廓由同一标签组件绘制。
  const DetailListTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.emphasized = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimens.p8,
      vertical: AppDimens.p4,
    ),
  });

  final String label;
  final Color? backgroundColor, foregroundColor;
  final bool emphasized;
  final EdgeInsetsGeometry padding;

  /// 标签底色、圆角、内边距与文字规格集中维护。
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: backgroundColor ?? AppTokens.divider(context),
      borderRadius: BorderRadius.circular(AppTokens.cardRadius(context)),
    ),
    child: Text(
      label,
      style: AppTextTokens.caption(context).copyWith(
        color: foregroundColor ?? AppTokens.textTertiary(context),
        fontWeight: emphasized ? FontWeight.w600 : null,
      ),
    ),
  );
}

/// 明细分类图标共用皮肤圆角、尺寸与独立点击区域。
class DetailListIcon extends StatelessWidget {
  const DetailListIcon({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.iconSize = AppDimens.icon20,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor, foregroundColor;

  /// 显式尺寸用于分类网格和设置行，默认仍随日历明细作用域调整。
  final double? size;
  final double iconSize;

  /// 图标操作可独立于整行操作，空回调时交由外层明细接收点击。
  @override
  Widget build(BuildContext context) {
    final diameter =
        size ??
        (CalendarEntryScope.active(context)
            ? AppDimens.calendarEntryIconSize
            : AppDimens.p36);
    final radius = BorderRadius.circular(
      AppTokens.categoryIconRadius(context, size: diameter),
    );
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTokens.surfaceSecondary(context),
            borderRadius: radius,
          ),
          child: IconTheme.merge(
            data: IconThemeData(
              size: iconSize,
              color: foregroundColor ?? AppTokens.primary(context),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 明细次要内容统一与主标题的距离、字号和颜色。
class DetailListSubtitle extends StatelessWidget {
  final bool compact;
  const DetailListSubtitle({
    super.key,
    required this.child,
    this.compact = false,
  });

  final Widget child;

  /// 文本和协作信息沿用同一基线，自定义业务强调色可由子组件覆盖。
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: compact ? 0 : AppDimens.p4),
    child: DefaultTextStyle(
      style: AppTextTokens.caption(
        context,
      ).copyWith(color: AppTokens.textSecondary(context)),
      child: child,
    ),
  );
}

/// 右侧主值与补充值共用对齐和字体，金额保留自身币种与支出颜色。
class DetailListValues extends StatelessWidget {
  const DetailListValues({super.key, required this.value, this.secondary});

  final Widget value;
  final Widget? secondary;

  /// 数值列的宽度由明细行统一维护，内容仅按主次层级排列。
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      DefaultTextStyle(
        style: AppTextTokens.label(
          context,
        ).copyWith(color: AppTokens.primary(context)),
        textAlign: TextAlign.right,
        child: value,
      ),
      if (secondary != null)
        DefaultTextStyle(
          style: AppTextTokens.caption(
            context,
          ).copyWith(color: AppTokens.textSecondary(context)),
          textAlign: TextAlign.right,
          child: secondary!,
        ),
    ],
  );
}
