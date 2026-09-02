import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';

/// 模板条目卡片（flat / hierarchical 两个模板页共用）
///
/// 右上角常驻复选框；已添加条目勾选 + 置灰，不可再点。
/// [compact] 为 true 时使用子分类紧凑样式（更小图标与字号）。
class TemplateItemTile extends StatelessWidget {
  final CategoryTemplateItem item;
  final bool selected;
  final VoidCallback onToggle;
  final bool compact;

  const TemplateItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final added = item.alreadyAdded;
    // 已添加条目视觉上也保持勾选态（表达"已在分类表"）
    final checked = added || selected;
    final highlighted = selected && !added;

    return Opacity(
      // 已添加条目降透明度，直观表达"不可再操作"
      opacity: added ? 0.55 : 1,
      child: InkWell(
        onTap: added ? null : onToggle,
        borderRadius: BorderRadius.circular(AppDimens.radius12),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: highlighted
                    ? AppTokens.surfaceSelected(context)
                    : AppTokens.surface(context),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(
                  color: highlighted
                      ? AppTokens.primary(context)
                      : AppTokens.borderStrong(context),
                  width: highlighted ? 2 : 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      resolveCategoryIcon(item.iconName),
                      size: compact ? 22 : 26,
                      color: AppTokens.primary(context),
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p4,
                      ),
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 11 : 12,
                          color: AppTokens.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 右上角常驻复选框
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                checked ? AppIcons.checkSquare : AppIcons.square,
                size: AppDimens.icon16,
                color: added
                    ? AppTokens.textDisabled(context)
                    : checked
                    ? AppTokens.primary(context)
                    : AppTokens.iconSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 模板页底部常驻操作栏
///
/// 左侧"本次已勾选 N 项"；右侧"全选/取消全选"文字链 + 添加按钮
/// （未勾选时添加按钮为禁用态）。
class TemplateBottomBar extends StatelessWidget {
  /// 本次勾选数（不含已添加条目）
  final int selectedCount;

  /// 是否已全选（决定文字链显示"全选"还是"取消全选"）
  final bool allSelected;

  /// 是否正在执行写入
  final bool isAdding;

  final VoidCallback onToggleSelectAll;
  final VoidCallback onAdd;

  const TemplateBottomBar({
    super.key,
    required this.selectedCount,
    required this.allSelected,
    required this.isAdding,
    required this.onToggleSelectAll,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = selectedCount > 0 && !isAdding;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p8,
        AppDimens.p16,
        AppDimens.p16,
      ),
      decoration: BoxDecoration(
        color: AppTokens.surface(context),
        border: Border(top: BorderSide(color: AppTokens.borderStrong(context))),
      ),
      child: Row(
        children: [
          // 左：本次已勾选计数
          Expanded(
            child: Text(
              l10n.categoryTemplateSelectedCount(selectedCount),
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
          ),
          // 右：全选/取消全选文字链
          // 全选/取消全选文字链，纯动作无选中态，按原则补涟漪反馈
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radius4),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onToggleSelectAll,
              borderRadius: BorderRadius.circular(AppDimens.radius4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p8,
                  vertical: AppDimens.p8,
                ),
                child: Text(
                  allSelected
                      ? l10n.categoryTemplateDeselectAll
                      : l10n.categoryTemplateSelectAll,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(color: AppTokens.textLink(context)),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          // 右：添加按钮（未勾选时禁用）
          FilledButton(
            onPressed: canAdd ? onAdd : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.buttonPrimary(context),
              foregroundColor: AppTokens.buttonPrimaryText(context),
            ),
            child: isAdding
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.commonAdd),
          ),
        ],
      ),
    );
  }
}
