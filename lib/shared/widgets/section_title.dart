import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 带主题色色条的区块标题；[padding] 用于对齐下方内容卡片。
class SectionTitle extends StatelessWidget {
  final String title;
  final TextStyle? textStyle;
  final Color? accentColor;
  final String? subtitle;

  /// 紧邻标题的辅助内容，与行尾操作区分开布局。
  final Widget? titleTrailing;
  final Widget? trailing;
  final bool disabled;
  final EdgeInsetsGeometry padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.textStyle,
    this.accentColor,
    this.subtitle,
    this.titleTrailing,
    this.trailing,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimens.p4),
  });

  /// 构建统一标题，将邻接辅助内容与行尾操作分别布局。
  @override
  Widget build(BuildContext context) {
    // 默认标题与色条同色；强调标题可单独指定文字样式。
    final color = disabled
        ? Theme.of(context).disabledColor
        : accentColor ?? Theme.of(context).colorScheme.primary;
    final titleText = Text(
      title,
      style:
          (textStyle ??
                  Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))
              ?.copyWith(color: color),
    );
    final titleRow = Row(
      children: [
        Container(
          width: AppDimens.sectionAccentWidth,
          height: AppDimens.sectionAccentHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radius4),
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        // Expanded 让标题占满剩余宽度,trailing 恒贴行尾,长标题自行换行不溢出。
        Expanded(
          child: titleTrailing == null
              ? titleText
              : Row(
                  children: [
                    Flexible(child: titleText),
                    const SizedBox(width: AppDimens.p8),
                    titleTrailing!,
                  ],
                ),
        ),
        ?trailing,
      ],
    );

    // 无副标题时直接返回单行标题。
    if (subtitle == null) {
      return Padding(padding: padding, child: titleRow);
    }
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleRow,
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.p4),
            child: Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTokens.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
