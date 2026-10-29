import 'package:flutter/material.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'category_icon.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 分类与管理入口共用的图标/标签格；手势确认后才选择，横滑不会提前改变分类。
class CategoryGridTile extends StatelessWidget {
  /// 图标由调用方提供，管理入口无需构造业务分类对象。
  const CategoryGridTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor,
    this.selected = false,
    this.expanded,
    this.tooltip,
  });

  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Color? labelColor;
  final bool selected;
  final bool? expanded;
  final String? tooltip;

  /// 省略的长名称通过提示和读屏保留完整含义，禁用入口仍可查看权限说明。
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    selected: selected,
    expanded: expanded,
    child: Tooltip(
      message: tooltip ?? label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radius44),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: AppDimens.p4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.label(context).copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: labelColor ?? AppTokens.textPrimary(context),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 分类网格共用图标及子项标识，资源模板可直接提供图标名称。
class CategoryGridIcon extends StatelessWidget {
  final CategoryDisplay? category;
  final String? iconName;
  final bool selected;
  final bool isSubCategory;
  final bool hasChildren;

  /// 用户分类与模板节点共用图标绘制，不需要互相转换数据身份。
  const CategoryGridIcon({
    super.key,
    this.category,
    this.iconName,
    this.selected = false,
    this.isSubCategory = false,
    this.hasChildren = false,
  });

  /// 子项标记叠加在图标边缘，不改变图标或名称占位。
  @override
  Widget build(BuildContext context) {
    final iconSize = isSubCategory ? AppDimens.p36 : AppDimens.icon40;
    final iconBg = selected
        ? AppTokens.buttonPrimary(context)
        : AppTokens.surfaceCategoryIcon(context);
    final iconColor = selected
        ? AppTokens.buttonPrimaryText(context)
        : AppTokens.iconCategory(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CategoryIconWidget(
          category: category,
          iconName: iconName,
          size: isSubCategory ? AppDimens.icon18 : AppDimens.icon20,
          color: iconColor,
          showBackground: true,
          backgroundSize: iconSize,
          backgroundColor: iconBg,
        ),
        if (hasChildren && !isSubCategory)
          Positioned(
            right: -AppDimens.p4,
            bottom: -AppDimens.selectionBadgeGap,
            child: Container(
              width: AppDimens.icon16,
              height: AppDimens.icon16,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTokens.surface(context),
                  width: AppDimens.selectionIndicatorWidth,
                ),
              ),
              child: Center(
                child: Icon(
                  AppIcons.moreVertical,
                  size: AppDimens.categoryBadgeIconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 分类图标和名称；父分类含子项时显示省略号标识。
class CategoryGridItem extends StatelessWidget {
  /// 父项、子项共用点击和选择语义，展开状态由分类区维护。
  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onTap,
    this.selected = false,
    this.isSubCategory = false,
    this.hasChildren = false,
    this.expanded = false,
    this.tooltip,
  });

  final CategoryDisplay category;
  final VoidCallback onTap;
  final bool selected;
  final bool isSubCategory;
  final bool hasChildren;
  final bool expanded;
  final String? tooltip;

  /// 选中的父项与子项分别高亮，父项角标和展开语义始终对应同一树节点。
  @override
  Widget build(BuildContext context) {
    final labelColor = selected
        ? AppTokens.primary(context)
        : isSubCategory
        ? AppTokens.textSecondary(context)
        : AppTokens.textPrimary(context);
    return CategoryGridTile(
      label: CategoryUtils.getDisplayName(category.name, context),
      tooltip: tooltip,
      onTap: onTap,
      selected: selected,
      expanded: hasChildren ? expanded : null,
      labelColor: labelColor,
      icon: CategoryGridIcon(
        category: category,
        selected: selected,
        isSubCategory: isSubCategory,
        hasChildren: hasChildren,
      ),
    );
  }
}
