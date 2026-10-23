import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/category_icons.dart';
import 'detail_list_item.dart';

/// 按 Lucide 名称解析图标，null、空串或未知名称回退 [lucideFallback]。
IconData resolveCategoryIcon(String? iconName) {
  return lucideIconLibrary[iconName] ?? lucideFallback;
}

/// 分类图标组件
/// 仅支持 Lucide 内置图标（单色可随主题着色），不支持自定义图片。
class CategoryIconWidget extends StatelessWidget {
  final CategoryDisplay? category;

  /// 模板和同步快照可直接提供图标名称，无需构造分类展示对象。
  final String? iconName;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool showBackground;

  /// 外框尺寸可独立于字形设置，分类网格与明细行保留各自的对齐宽度。
  final double? backgroundSize;

  /// 分类可单独绘制，启用背景时使用全局圆角方形样式。
  const CategoryIconWidget({
    super.key,
    this.category,
    this.iconName,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.showBackground = false,
    this.backgroundSize,
  });

  /// 分类前景和背景使用成对主题令牌，显式颜色用于选中等交互状态。
  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTokens.iconCategory(context);

    // 使用 Lucide 图标（IconData 用法与 Material 一致，color 直接着色）
    final iconData = resolveCategoryIcon(category?.icon ?? iconName);

    if (showBackground) {
      return DetailListIcon(
        size: backgroundSize ?? size * 1.5,
        iconSize: size,
        foregroundColor: iconColor,
        backgroundColor:
            backgroundColor ?? AppTokens.surfaceCategoryIcon(context),
        child: Center(
          child: Icon(iconData, size: size, color: iconColor),
        ),
      );
    }

    return Icon(iconData, size: size, color: iconColor);
  }
}
