import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 各业务域列表分组共用的明细标题，统一次要文字和行距。
class ListSectionHeader extends StatelessWidget {
  /// 右侧可承载分组汇总或现有操作入口。
  const ListSectionHeader({
    super.key,
    required this.title,
    this.secondaryTitle,
    this.trailing,
    this.horizontalPadding = AppDimens.p12,
  });

  final String title;
  final String? secondaryTitle;
  final Widget? trailing;

  /// 分组标题与同组明细共用水平边距，外层已留边时可传零。
  final double horizontalPadding;

  /// 标题让出右侧内容宽度，大字号下允许换行。
  ///
  /// 标题、次要标题与右侧汇总统一沿用记账首页日期分组的字号参数
  /// （dateSecondary 的次要色常规字重），各业务域只决定内容。
  @override
  Widget build(BuildContext context) {
    final style = AppTextTokens.dateSecondary(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppDimens.listHeaderVertical,
      ),
      child: DefaultTextStyle(
        style: style,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(child: Text(title, style: style)),
                  if (secondaryTitle != null) ...[
                    const SizedBox(width: AppDimens.p8),
                    Text(secondaryTitle!, style: style),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
