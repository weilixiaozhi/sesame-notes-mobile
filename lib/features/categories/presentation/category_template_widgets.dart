import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';
import 'widgets/compact_category_tile.dart';

/// 模板卡片只描述本次选择，内容布局与已有分类候选保持一致。
class TemplateItemTile extends StatelessWidget {
  final CategoryTemplateItem item;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;

  const TemplateItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
    this.enabled = true,
  });

  /// 纯内容卡片不显示原有父子结构或已添加状态。
  @override
  Widget build(BuildContext context) => CompactCategoryTile(
    name: item.name,
    iconName: item.iconName,
    selected: selected,
    enabled: enabled,
    onTap: onToggle,
  );
}

/// 模板页底部常驻操作栏
///
/// 左侧"本次已勾选 N 项"；右侧"全选/取消全选"文字链 + 添加按钮
/// （未勾选时添加按钮为禁用态）。
class TemplateBottomBar extends StatelessWidget {
  /// 本次实际创建的分类数量，包含自动带入的父项。
  final int selectedCount;

  /// 是否已全选（决定文字链显示"全选"还是"取消全选"）
  final bool allSelected;

  /// 是否正在执行写入
  final bool isAdding;

  /// 只有实际写入期间显示进度；确认框等待期间仅禁用重复提交。
  final bool isWriting;
  final bool selectionLocked;
  final bool canSubmit;
  final String? addLabel;

  final VoidCallback onToggleSelectAll;
  final VoidCallback onAdd;

  const TemplateBottomBar({
    super.key,
    required this.selectedCount,
    required this.allSelected,
    required this.isAdding,
    this.isWriting = false,
    this.selectionLocked = false,
    this.canSubmit = true,
    this.addLabel,
    required this.onToggleSelectAll,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canAdd = selectedCount > 0 && !isAdding && canSubmit;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p8,
        AppDimens.p16,
        AppDimens.p8,
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
              l10n.categoryTemplateCompactSelectedCount(selectedCount),
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
          ),
          // 全选与取消全选共用文字按钮，按当前选择数量决定动作。
          TextButton(
            onPressed: selectionLocked ? null : onToggleSelectAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: AppDimens.p8,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
          const SizedBox(width: AppDimens.p8),
          // 右：添加按钮（未勾选时禁用）
          AppPrimaryButton(
            fullWidth: false,
            label: addLabel ?? l10n.commonAdd,
            busy: isWriting,
            onPressed: canAdd ? onAdd : null,
          ),
        ],
      ),
    );
  }
}
