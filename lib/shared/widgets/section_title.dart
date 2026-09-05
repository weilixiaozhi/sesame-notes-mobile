import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 全局统一区块标题组件。
///
/// 视觉规范唯一载体:左侧 3x15 主题色圆角条 + 加粗主题色标题
/// (titleSmall / w800),可选副标题(正文小字 / 次要色)与右侧 [trailing]
/// 内容;[disabled] 时色条与标题整行置灰,与只读内容的禁用色一致。
///
/// 布局约定:色条左缘应与下方内容卡片左缘对齐,各调用方按卡片外边距传入
/// [padding](默认水平 4,对应 Material Card 默认 margin(all: 4) 的页面)。
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool disabled;
  final EdgeInsetsGeometry padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.disabled = false,
    this.padding = const EdgeInsets.symmetric(horizontal: AppDimens.p4),
  });

  @override
  Widget build(BuildContext context) {
    // 主题色与禁用灰共用同一变量,保证色条与文字始终同色。
    final color = disabled
        ? Theme.of(context).disabledColor
        : Theme.of(context).colorScheme.primary;
    final titleRow = Row(
      children: [
        Container(
          width: 3,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.radius4),
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        // Expanded 让标题占满剩余宽度,trailing 恒贴行尾,长标题自行换行不溢出。
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
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
