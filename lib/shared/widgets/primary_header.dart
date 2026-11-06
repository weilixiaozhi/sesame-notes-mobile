import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 标题槽与文字操作共同使用同一组内边距，系统字号改变时保持对齐。
const _headerTextActionPadding = EdgeInsets.symmetric(
  horizontal: AppDimens.p8,
  vertical: AppDimens.p4,
);

/// 统一页面头部；[content] 是标题之外的附加内容。
class PrimaryHeader extends StatelessWidget {
  final String title;

  /// 可编辑标题复用现有返回键和标题行布局。
  final Widget? titleWidget;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;
  final Widget? content;
  final EdgeInsetsGeometry padding;

  /// 标题旁的功能入口使用 HeaderIconAction 等公共操作组件。
  final Widget? titleAction;
  final BoxDecoration? decoration;
  // 隐藏内置标题/副标题行，仅渲染自定义 content。
  final bool showTitleSection;

  /// 页面只提供当前使用的标题、操作和附加内容，基础头部样式统一维护。
  const PrimaryHeader({
    super.key,
    required this.title,
    this.titleWidget,
    this.subtitle,
    this.showBack = false,
    this.actions,
    this.content,
    // 全局头部统一留白：状态栏底到标题的顶部留白为 8，标题行底部留白取消为 0，
    // 左右内缩为 12；所有页面（一级 tab 与二级页）共用此默认值，请勿在调用处覆盖。
    this.padding = const EdgeInsets.only(
      top: AppDimens.p8,
      left: AppDimens.p12,
      right: AppDimens.p12,
      bottom: 0,
    ),
    this.titleAction,
    this.decoration,
    this.showTitleSection = true,
  });

  /// 常规标题和自定义日历头部保留相同文字操作高度，显隐操作时槽位不变。
  static double titleRowMinHeight(BuildContext context) {
    final style = AppTextTokens.body(
      context,
    ).copyWith(fontWeight: FontWeight.w600);
    final painter = TextPainter(
      text: TextSpan(text: '0', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = math.max(
      30.0,
      painter.height + _headerTextActionPadding.vertical,
    );
    painter.dispose();
    return height;
  }

  /// 透明状态栏的图标明暗跟随当前主题，页面与应用根部共用同一解析规则。
  static SystemUiOverlayStyle systemOverlayStyle(BuildContext context) {
    final icons = AppTokens.isDark(context)
        ? Brightness.light
        : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemStatusBarContrastEnforced: false,
      statusBarIconBrightness: icons,
      statusBarBrightness: icons == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );
  }

  /// 标题、返回操作与附加内容共享安全区和主题状态栏。
  @override
  Widget build(BuildContext context) {
    // 标题规格全局统一：字号走 body token，字重 w600，
    // 头部主标题比下方列表内容更克制。
    final titleStyle = AppTextTokens.body(
      context,
    ).copyWith(fontWeight: FontWeight.w600);
    final subStyle = AppTextTokens.label(context);

    // 附加内容沿用同一 padding，调用方无需再次叠加水平留白。

    // 使用 Token 系统

    // 扁平化：header 底色 = 页面底色，与页面融为一体，视觉更简洁。
    // 头部始终与当前皮肤的列表区域 scaffoldBackgroundColor 一致，
    // 因此统一使用页面底色，而不单独分支为 Colors.black。
    final headerBg = Theme.of(context).scaffoldBackgroundColor;

    // 文字和图标颜色（使用 Token）
    final textColor = AppTokens.textPrimary(context);
    final iconColor = AppTokens.iconPrimary(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle(context),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: decoration ?? BoxDecoration(color: headerBg),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitleSection)
                  Padding(
                    padding: padding,
                    // 单行槽位包含文字操作的内边距，副标题等更高内容仍可自然增高。
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: titleRowMinHeight(context),
                      ),
                      child: Row(
                        children: [
                          if (showBack) ...[
                            HeaderIconAction(
                              icon: AppIcons.back,
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).backButtonTooltip,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: AppDimens.p8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: DefaultTextStyle(
                                        style: titleStyle.copyWith(
                                          color: textColor,
                                        ),
                                        textAlign: TextAlign.start,
                                        child:
                                            titleWidget ??
                                            Text(
                                              title,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      ),
                                    ),
                                    if (titleAction != null) ...[
                                      const SizedBox(width: AppDimens.p4),
                                      titleAction!,
                                    ],
                                  ],
                                ),
                                if (subtitle != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          subtitle!,
                                          style: subStyle.copyWith(
                                            color: AppTokens.textSecondary(
                                              context,
                                            ),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          ...?actions,
                        ],
                      ),
                    ),
                  ),
                if (content != null)
                  Padding(
                    padding: padding,
                    child: DefaultTextStyle(
                      style: DefaultTextStyle.of(
                        context,
                      ).style.copyWith(color: textColor),
                      child: IconTheme(
                        data: IconThemeData(color: iconColor),
                        child: content!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 头部图标操作；固定热区避免默认 IconButton 撑高头部，加载时禁用点击。
class HeaderIconAction extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool spinning;

  const HeaderIconAction({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.spinning = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: spinning
          ? const SizedBox(
              width: AppDimens.icon20,
              height: AppDimens.icon20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon, size: AppDimens.icon20),
      tooltip: tooltip,
      onPressed: spinning ? null : onPressed,
      // 热区统一 30x30（图标 20 + 四周 0）：与首行最小高度 30 一致，
      // 含功能键的页面首行行高与纯文字页保持同一高度。
      padding: const EdgeInsets.all(0),
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// 头部文字链功能键：全局统一规格的 text action。
///
/// 头部文字链采用正文大小、w600 字重和主题主色，
/// 紧凑热区，各页面统一调用；分组标题内的次级入口用 [dense] 降一档字号。
class HeaderTextAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  /// 分组标题右侧的次级入口比正文小一档。
  final bool dense;

  const HeaderTextAction({
    super.key,
    required this.label,
    this.onPressed,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: _headerTextActionPadding,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle:
            (dense ? AppTextTokens.label(context) : AppTextTokens.body(context))
                .copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
