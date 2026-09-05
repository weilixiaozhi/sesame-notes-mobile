import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 选中卡片公共边框。
///
/// 选中态 = 主题色 1px 边框;未选中 = 暗色模式 1px 常规边框(与选中边框
/// 同宽,避免选中时布局跳动)、亮色模式无边框。账本管理 / 备份与云同步 /
/// 备份内容三处选择卡片共用同一口径。
Border? selectableCardBorder(BuildContext context, {required bool selected}) {
  if (selected) {
    return Border.all(color: Theme.of(context).colorScheme.primary, width: 1);
  }
  return AppTokens.isDark(context)
      ? Border.all(color: AppTokens.border(context), width: 1)
      : null;
}

/// 选中卡片右上角勾选角标:20x20 主题色圆角块 + 对勾。
///
/// 组件自身渲染为 [Positioned](top/right 各外移 1px,与边框宽度齐平,
/// 使角标覆盖在边框之上且不凸出卡片),须作为 [Stack] 直接子级、仅选中时挂载。
class SelectableCardCheckBadge extends StatelessWidget {
  const SelectableCardCheckBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      top: -1,
      right: -1,
      child: Container(
        width: 20,
        height: 20,
        // 右上圆角(r12)圆心与卡片外角圆弧圆心重合,角上只露一条弧线。
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(AppDimens.radius12),
            bottomLeft: Radius.circular(AppDimens.radius12),
          ),
        ),
        child: Icon(
          AppIcons.check,
          size: AppDimens.icon12,
          color: scheme.onPrimary,
        ),
      ),
    );
  }
}
