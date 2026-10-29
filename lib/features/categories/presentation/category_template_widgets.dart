import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/shared/widgets/selectable_card.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';

/// 普通手机显示三至四列，大字号根据可读卡宽自动减少列数。
int categoryTemplateColumns(BuildContext context, double width) {
  final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
  final minimum = (AppDimens.icon40 * 2) * scale.clamp(1.0, 2.0);
  return ((width + AppDimens.p8) / (minimum + AppDimens.p8)).floor().clamp(
    2,
    5,
  );
}

/// 图标与文字高度随系统字体缩放，避免窄屏标签溢出。
double categoryTemplateTileHeight(
  BuildContext context, {
  bool compact = false,
}) {
  final painter = TextPainter(
    text: TextSpan(text: '分类 Ag', style: AppTextTokens.label(context)),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 2,
  );
  try {
    painter.layout(maxWidth: AppDimens.p40 * 2);
    return (compact ? AppDimens.icon20 : AppDimens.icon22) * 1.5 +
        painter.height * 2 +
        AppDimens.p32;
  } finally {
    painter.dispose();
  }
}

/// 模板卡片只表达本次选择，模板没有已添加或重名阻挡状态。
class TemplateItemTile extends StatelessWidget {
  final CategoryTemplateItem item;
  final bool selected;
  final bool enabled;
  final VoidCallback onToggle;
  final bool compact;

  const TemplateItemTile({
    super.key,
    required this.item,
    required this.selected,
    required this.onToggle,
    this.enabled = true,
    this.compact = false,
  });

  /// 用统一选择角标表达本次选择，图标与名称使用项目主题。
  @override
  Widget build(BuildContext context) => Semantics(
    checked: selected,
    enabled: enabled,
    child: Material(
      color: AppTokens.surface(context),
      shape: selectableCardShape(
        context,
        selected: selected,
        unselectedBorder: BorderSide(color: AppTokens.borderStrong(context)),
      ),
      child: InkWell(
        onTap: enabled ? onToggle : null,
        customBorder: selectableCardShape(context),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.p4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CategoryIconWidget(
                      iconName: item.iconName,
                      showBackground: true,
                      size: compact ? AppDimens.icon20 : AppDimens.icon22,
                    ),
                    const SizedBox(height: AppDimens.p8),
                    Text(
                      item.name,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.label(context),
                    ),
                  ],
                ),
              ),
            ),
            if (selected) const SelectableCardCheckBadge(),
          ],
        ),
      ),
    ),
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
