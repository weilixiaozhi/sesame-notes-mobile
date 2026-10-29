import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/category_grid_item.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 模板与所属分类候选共用列宽，大字号按可读卡宽减少列数。
int compactCategoryColumns(BuildContext context, double width) {
  final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
  final minimum = AppDimens.p40 * 2 * scale.clamp(1.0, 2.0);
  return ((width + AppDimens.p8) / (minimum + AppDimens.p8)).floor().clamp(
    2,
    5,
  );
}

/// 同一网格全部使用相同高度与文字基线，系统字号放大时整体增长。
double compactCategoryTileHeight(BuildContext context) {
  final painter = TextPainter(
    text: TextSpan(text: '分类', style: AppTextTokens.label(context)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  );
  try {
    painter.layout();
    return math.max(
      AppDimens.p40 * 2,
      AppDimens.icon40 + AppDimens.p4 + painter.height + AppDimens.p16,
    );
  } finally {
    painter.dispose();
  }
}

/// 模板与所属分类候选直接复用记账网格的图标与名称选择反馈。
class CompactCategoryTile extends StatelessWidget {
  final String name;
  final String? iconName;
  final bool selected;
  final bool enabled;
  final bool hasChildren;
  final bool expanded;
  final VoidCallback onTap;

  /// 所属关系仅控制子项提示，选中和点击意图由调用方维护。
  const CompactCategoryTile({
    super.key,
    required this.name,
    required this.iconName,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.hasChildren = false,
    this.expanded = false,
  });

  /// 子项标识只改变图标边缘，具有子项和没有子项的卡片共用布局。
  @override
  Widget build(BuildContext context) => CategoryGridTile(
    label: name,
    onTap: enabled ? onTap : null,
    selected: selected,
    expanded: hasChildren ? expanded : null,
    labelColor: selected
        ? AppTokens.primary(context)
        : AppTokens.textPrimary(context),
    icon: CategoryGridIcon(
      iconName: iconName,
      selected: selected,
      hasChildren: hasChildren,
    ),
  );
}
