import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 菜单项类型
enum AppMenuItemType {
  /// 普通操作项
  action,

  /// 提示信息（禁用状态）
  tip,

  /// 分隔线
  divider,
}

/// 菜单项配置
class AppMenuItem {
  final String? value;
  final String? label;
  final AppMenuItemType type;
  final bool isDanger;

  /// 自定义文字颜色（优先级最高，覆盖 isDanger 的红色），
  /// 用于区分不同危险等级的动作（如警示级用黄色、破坏级用红色）
  final Color? color;

  /// 创建指定类型的菜单项配置。
  const AppMenuItem._({
    this.value,
    this.label,
    required this.type,
    this.isDanger = false,
    this.color,
  });

  /// 创建普通操作项
  const AppMenuItem.action({
    required String value,
    required String label,
    bool isDanger = false,
    Color? color,
  }) : this._(
         value: value,
         label: label,
         type: AppMenuItemType.action,
         isDanger: isDanger,
         color: color,
       );

  /// 创建提示信息
  const AppMenuItem.tip({required String label})
    : this._(label: label, type: AppMenuItemType.tip);

  /// 创建分隔线
  const AppMenuItem.divider() : this._(type: AppMenuItemType.divider);
}

/// 美化的弹出菜单组件
///
/// 视觉规范：
/// - 菜单紧贴触发按钮下沿，纵向间距 4px
/// - 弹窗宽度固定 150px（覆盖屏幕右侧近 1/3 宽度，比省略号宽得多）
/// - 每行高度 56px、行间用 0.5px 浅灰横线分隔（"虚线"观感实际为细实线）
/// - 圆角 8px、轻阴影
class AppPopupMenu extends StatelessWidget {
  /// 菜单项列表
  final List<AppMenuItem> items;

  /// 选中回调
  final ValueChanged<String>? onSelected;

  /// 主题色（用于图标背景）
  final Color? primaryColor;

  /// 自定义图标
  final Widget? icon;

  /// 菜单相对触发按钮的偏移。
  ///
  /// 默认 (-15, 50) 是针对「右上角省略号」场景的视觉调校；换到其它位置 /
  /// 字号 / 无障碍缩放下应显式传入适配值，不假设触发图标恒在右上角。
  final Offset menuOffset;

  /// 提示文字
  final String? tooltip;

  /// 菜单宽度：固定值让弹窗比省略号宽得多
  static const double _menuWidth = 150;

  /// 每行高度：56px
  static const double _rowHeight = 56;

  /// 创建弹出菜单。
  const AppPopupMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.primaryColor,
    this.icon,
    this.menuOffset = const Offset(-15, 50),
    this.tooltip,
  });

  /// 构建弹出菜单。
  @override
  Widget build(BuildContext context) {
    final isDark = AppTokens.isDark(context);

    // 设计要点：
    // 1) menuOffset 允许调用方按触发按钮位置调校弹窗；
    // 2) shape 8px 圆角、elevation 阴影；
    // 3) 单项宽度由 SizedBox(width: _menuWidth) 撑出，
    //    PopupMenuButton 会以最大子项宽度决定弹窗宽度。
    return PopupMenuButton<String>(
      icon:
          icon ??
          Icon(AppIcons.moreVertical, color: AppTokens.textPrimary(context)),
      tooltip: tooltip,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius8),
      ),
      color: AppTokens.surface(context),
      elevation: isDark ? 8 : 4,
      offset: menuOffset,
      onSelected: onSelected,
      itemBuilder: (context) {
        final List<PopupMenuEntry<String>> entries = [];
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          // 仅操作项参与底部细线分隔；最后一项不画线，避免与弹窗底缘冲突。
          final isLastAction =
              item.type == AppMenuItemType.action && !_hasActionAfter(items, i);
          switch (item.type) {
            case AppMenuItemType.action:
              entries.add(
                _buildActionItem(context, item, showBottomLine: !isLastAction),
              );
              break;
            case AppMenuItemType.tip:
              entries.add(_buildTipItem(context, item));
              break;
            case AppMenuItemType.divider:
              entries.add(const PopupMenuDivider(height: 1));
              break;
          }
        }
        return entries;
      },
    );
  }

  /// 判断 [startIndex] 之后是否还有操作项，决定是否需要底部细线。
  bool _hasActionAfter(List<AppMenuItem> list, int startIndex) {
    for (var i = startIndex + 1; i < list.length; i++) {
      if (list[i].type == AppMenuItemType.action) return true;
    }
    return false;
  }

  /// 构建可点击的操作项，并按需绘制底部分隔线。
  PopupMenuItem<String> _buildActionItem(
    BuildContext context,
    AppMenuItem item, {
    bool showBottomLine = true,
  }) {
    // 实现细节：
    // - padding 设为 zero，把水平 16px 内边距挪到 SizedBox 外层 Container，
    //   让底部细线能贯通至弹窗左右缘，避免被 padding 截断出现"线被截断"的瑕疵；
    // - 0.5px 浅灰细线模拟"虚线"观感；
    // - height 56 + 居中竖直摆放。
    return PopupMenuItem<String>(
      value: item.value,
      height: _rowHeight,
      padding: EdgeInsets.zero,
      child: Container(
        width: _menuWidth,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          border: showBottomLine
              ? Border(
                  bottom: BorderSide(
                    color: AppTokens.divider(context),
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Text(
          item.label ?? '',
          style: AppTextTokens.title(context).copyWith(
            // 自定义颜色优先，其次使用危险红色，最后使用主题文字色。
            color:
                item.color ??
                (item.isDanger
                    ? AppTokens.error(context)
                    : AppTokens.textPrimary(context)),
          ),
        ),
      ),
    );
  }

  /// 构建不可点击的提示项。
  PopupMenuItem<String> _buildTipItem(BuildContext context, AppMenuItem item) {
    // 提示项只展示辅助文字，并与操作项保持相同的水平内边距。
    return PopupMenuItem<String>(
      value: 'tip',
      enabled: false,
      height: 40,
      padding: EdgeInsets.zero,
      child: Container(
        width: _menuWidth,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
        alignment: Alignment.centerLeft,
        child: Text(
          item.label ?? '',
          style: AppTextTokens.label(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
      ),
    );
  }
}
