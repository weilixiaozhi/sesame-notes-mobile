import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/shared/widgets/selectable_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';

/// 同名冲突只阻止添加，不把自建分类当成已经存在的模板身份。
String? categoryTemplateBlockMessage(
  AppLocalizations l10n,
  CategoryTemplateBlockReason? reason,
) => switch (reason) {
  CategoryTemplateBlockReason.duplicateName =>
    l10n.categoryTemplateBlockedDuplicate,
  CategoryTemplateBlockReason.parentDuplicateName =>
    l10n.categoryTemplateBlockedParentDuplicate,
  CategoryTemplateBlockReason.parentHierarchyChanged =>
    l10n.categoryTemplateBlockedParentHierarchy,
  null => null,
};

/// 按图标背景和两行文字的实际高度确定网格行高，窄屏与大字号共用。
double categoryTemplateTileHeight(
  BuildContext context, {
  bool compact = false,
}) {
  var height = (compact ? AppDimens.icon20 : AppDimens.icon22) * 1.5;
  // 名称和状态各占一行；文字测量遵循当前主题字体与系统缩放。
  for (final style in [
    AppTextTokens.label(context),
    AppTextTokens.caption(context),
  ]) {
    final painter = TextPainter(
      text: TextSpan(text: '分类 Ag', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    );
    try {
      painter.layout();
      height += painter.height;
    } finally {
      painter.dispose();
    }
  }
  return height + AppDimens.p4 * 2 + AppDimens.p8 * 2;
}

/// 模板条目卡片（flat / hierarchical 两个模板页共用）
///
/// 选中条目使用统一卡片角标；已添加条目保留勾选，点击展示提示。
/// [compact] 为 true 时使用子分类紧凑样式，选中标记统一使用主题色。
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

  /// 用卡片边框和角标表达选中状态，名称与图标保持正常可读。
  @override
  Widget build(BuildContext context) {
    final added = item.alreadyAdded;
    final pending = item.pendingConfirmation;
    final checked = (added && !pending) || (selected && item.canAdd);
    final l10n = AppLocalizations.of(context);
    final blocked = categoryTemplateBlockMessage(l10n, item.blockedReason);
    final iconSize = compact ? AppDimens.icon20 : AppDimens.icon22;
    final nameStyle = AppTextTokens.label(
      context,
    ).copyWith(color: AppTokens.textPrimary(context));
    final captionStyle = AppTextTokens.caption(context);

    return Semantics(
      selected: checked,
      enabled: true,
      hint: pending
          ? l10n.categoryTemplatePending(1)
          : added
          ? l10n.categoryTemplateAlreadyAddedHint
          : blocked,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: ShapeDecoration(
          color: AppTokens.surface(context),
          shape: selectableCardShape(
            context,
            selected: checked,
            unselectedBorder: BorderSide(
              color: AppTokens.borderStrong(context),
            ),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                onTap: () {
                  if (pending) {
                    showToast(context, l10n.categoryTemplatePending(1));
                    return;
                  }
                  if (added) {
                    showToast(context, l10n.categoryTemplateAlreadyAddedHint);
                    return;
                  }
                  if (blocked != null) {
                    showToast(context, blocked);
                    return;
                  }
                  onToggle();
                },
                customBorder: selectableCardShape(context),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CategoryIconWidget(
                        iconName: item.iconName,
                        showBackground: true,
                        size: iconSize,
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
                          style: nameStyle,
                        ),
                      ),
                      if (pending || added || blocked != null) ...[
                        const SizedBox(height: AppDimens.p4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.p4,
                          ),
                          child: Text(
                            pending
                                ? l10n.categoryTemplatePendingLabel
                                : added
                                ? l10n.categoryTemplateAlreadyAdded
                                : l10n.categoryTemplateBlockedLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: captionStyle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (checked) const SelectableCardCheckBadge(),
            ],
          ),
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

  /// 只有实际写入期间显示进度；确认框等待期间仅禁用重复提交。
  final bool isWriting;

  final VoidCallback onToggleSelectAll;
  final VoidCallback onAdd;

  const TemplateBottomBar({
    super.key,
    required this.selectedCount,
    required this.allSelected,
    required this.isAdding,
    this.isWriting = false,
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
          // 全选与取消全选共用文字按钮，按当前选择数量决定动作。
          TextButton(
            onPressed: isAdding ? null : onToggleSelectAll,
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
            label: l10n.commonAdd,
            busy: isWriting,
            onPressed: canAdd ? onAdd : null,
          ),
        ],
      ),
    );
  }
}
