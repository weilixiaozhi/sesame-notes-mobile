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
  final String? subtitle;
  final AppMenuItemType type;
  final bool isDanger;
  final IconData? icon;

  /// 自定义文字颜色（优先级最高，覆盖 isDanger 的红色），
  /// 用于区分不同危险等级的动作（如警示级用黄色、破坏级用红色）
  final Color? color;

  const AppMenuItem._({
    this.value,
    this.label,
    this.subtitle,
    required this.type,
    this.isDanger = false,
    this.icon,
    this.color,
  });

  const AppMenuItem.action({
    required String value,
    required String label,
    String? subtitle,
    bool isDanger = false,
    IconData? icon,
    Color? color,
  }) : this._(
         value: value,
         label: label,
         subtitle: subtitle,
         type: AppMenuItemType.action,
         isDanger: isDanger,
         icon: icon,
         color: color,
       );

  const AppMenuItem.tip({required String label})
    : this._(label: label, type: AppMenuItemType.tip);

  const AppMenuItem.divider() : this._(type: AppMenuItemType.divider);
}

/// 美化的弹出菜单组件
///
/// 视觉规范：
/// - 菜单紧贴触发按钮下沿，纵向间距 4px
/// - 竖向省略号 20px，触达区域与页面头部一致为 30×30px
/// - 弹窗宽度固定 200px
/// - 每行至少 56px，长文案自然增高；行间用 0.5px 浅灰横线分隔
/// - 圆角使用当前皮肤的卡片令牌，并保留轻阴影
class AppPopupMenu extends StatelessWidget {
  /// 菜单项列表
  final List<AppMenuItem> items;

  /// 选中回调
  final ValueChanged<String>? onSelected;

  /// 提示文字
  final String? tooltip;

  /// 自定义触发区域；未提供时显示页面头部的省略号。
  final Widget? child;

  /// 暂停操作时同时禁用菜单触发。
  final bool enabled;

  /// 菜单宽度：固定值让弹窗比省略号宽得多
  static const double menuWidth = 200;

  /// 菜单浮层按亮暗模式提供对应阴影层级。
  static double menuElevation(BuildContext context) =>
      AppTokens.isDark(context) ? 8 : 4;

  /// 每行最小高度：56px
  static const double _rowHeight = 56;

  const AppPopupMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.tooltip,
    this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // 菜单锚定按钮下沿，触发图标与返回按钮共用尺寸和颜色规范。
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: menuWidth),
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.cardRadius(context)),
        side: AppTokens.cardBorder(context),
      ),
      color: AppTokens.surface(context),
      elevation: menuElevation(context),
      offset: const Offset(0, AppDimens.p4),
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
      child:
          child ??
          SizedBox.square(
            dimension: AppDimens.menuIconBoxSize,
            child: Icon(
              AppIcons.moreVertical,
              size: AppDimens.icon20,
              color: enabled
                  ? AppTokens.iconPrimary(context)
                  : AppTokens.textDisabled(context),
            ),
          ),
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
    // - 最小高度 56，长名称与放大字体按实际文本高度展开。
    return PopupMenuItem<String>(
      value: item.value,
      height: _rowHeight,
      padding: EdgeInsets.zero,
      child: Container(
        width: menuWidth,
        constraints: const BoxConstraints(minHeight: _rowHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
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
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: AppDimens.icon20),
              const SizedBox(width: AppDimens.p12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
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
                  if (item.subtitle != null) ...[
                    const SizedBox(height: AppDimens.p4),
                    Text(item.subtitle!, style: AppTextTokens.label(context)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建不可点击的提示项。
  ///
  /// 行高、内边距与文字字号都和可点击操作项保持一致，只用弱化颜色表达
  /// 「当前不可用」，避免同一菜单里同一个入口出现两种字号。
  PopupMenuItem<String> _buildTipItem(BuildContext context, AppMenuItem item) {
    return PopupMenuItem<String>(
      value: 'tip',
      enabled: false,
      height: _rowHeight,
      padding: EdgeInsets.zero,
      child: Container(
        width: menuWidth,
        constraints: const BoxConstraints(minHeight: _rowHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          item.label ?? '',
          style: AppTextTokens.title(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
      ),
    );
  }
}
