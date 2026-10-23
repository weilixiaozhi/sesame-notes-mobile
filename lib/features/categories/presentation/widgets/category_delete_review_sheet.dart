import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/features/categories/domain/category_manage_logic.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 展示删除影响与处理方式；确认只返回选择，由调用方执行分类用例。
Future<({int option, String? targetId})?> showCategoryDeleteReview(
  BuildContext context, {
  required List<({db.CategoryDisplay category, int transactionCount})>
  categoriesWithCount,
  required Set<String> selectedIds,
  required bool includeParents,
  int initialOption = 0,
  required Future<String?> Function() selectTarget,
}) async {
  try {
    return await showAppSheet<({int option, String? targetId})>(
      context: context,
      child: Builder(
        builder: (sheetContext) => CategoryDeleteReviewSheet(
          categoriesWithCount: List.of(categoriesWithCount),
          selectedIds: Set.of(selectedIds),
          includeParents: includeParents,
          initialOption: initialOption,
          selectTarget: selectTarget,
          onBack: () => Navigator.pop(sheetContext),
          onConfirm: (decision) => Navigator.pop(sheetContext, decision),
        ),
      ),
    );
  } catch (error, stack) {
    logger.error('CategoryDeleteReview', '打开分类删除确认面板失败', error, stack);
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
    return null;
  }
}

/// 删除复核面板：保留源分类选择，在同一面板切换策略与迁移目标。
class CategoryDeleteReviewSheet extends StatefulWidget {
  final List<({db.CategoryDisplay category, int transactionCount})>
  categoriesWithCount;
  final Set<String> selectedIds;
  final bool includeParents;
  final int initialOption;
  final Future<String?> Function() selectTarget;
  final VoidCallback onBack;
  final void Function(({int option, String? targetId}) decision) onConfirm;

  /// 创建可嵌入当前面板的复核步骤，导航与业务执行交给调用方。
  const CategoryDeleteReviewSheet({
    super.key,
    required this.categoriesWithCount,
    required this.selectedIds,
    required this.includeParents,
    required this.initialOption,
    required this.selectTarget,
    required this.onBack,
    required this.onConfirm,
  });

  /// 创建仅保存删除交互选择的状态。
  @override
  State<CategoryDeleteReviewSheet> createState() =>
      _CategoryDeleteReviewSheetState();
}

class _CategoryDeleteReviewSheetState extends State<CategoryDeleteReviewSheet> {
  late int _option;
  String? _targetId;
  bool _selectingTarget = false;

  /// 初始化调用方传入的删除方式，子分类只允许删除或迁移两种方式。
  @override
  void initState() {
    super.initState();
    _option = widget.initialOption;
    if (_option < 0 || _option > (widget.includeParents ? 2 : 1)) {
      _option = 0;
    }
  }

  /// 获取本次选中的源分类，沿用传入分类的展示顺序。
  List<({db.CategoryDisplay category, int transactionCount})>
  get _selectedItems => widget.categoriesWithCount
      .where((item) => widget.selectedIds.contains(item.category.id))
      .toList();

  /// 校验迁移目标仍在候选快照中，且不属于即将删除的分类树。
  db.CategoryDisplay? get _targetCategory {
    for (final item in widget.categoriesWithCount) {
      final category = item.category;
      if (category.id != _targetId ||
          widget.selectedIds.contains(category.id) ||
          (widget.includeParents &&
              widget.selectedIds.contains(category.parentId))) {
        continue;
      }
      return category;
    }
    return null;
  }

  /// 子分类目标展示所属父分类，区分跨父分类的同名子分类。
  String _targetLabel(db.CategoryDisplay category) {
    final name = CategoryUtils.getDisplayName(category.name, context);
    if (category.parentId == null) return name;
    for (final item in widget.categoriesWithCount) {
      if (item.category.id == category.parentId) {
        final parent = CategoryUtils.getDisplayName(
          item.category.name,
          context,
        );
        return '$parent / $name';
      }
    }
    return name;
  }

  /// 打开现有迁移目标选择器，返回后保留当前处理方式与已选目标。
  Future<void> _chooseTarget() async {
    if (_selectingTarget) return;
    setState(() => _selectingTarget = true);
    try {
      final targetId = await widget.selectTarget();
      if (!mounted || targetId == null) return;
      setState(() => _targetId = targetId);
      if (_targetCategory == null) {
        showToast(context, AppLocalizations.of(context).categoryCannotDelete);
      }
    } catch (error, stack) {
      logger.error('CategoryDeleteReview', '选择分类迁移目标失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _selectingTarget = false);
    }
  }

  /// 展示单个受影响分类；关联子分类缩进显示，笔数不参与父分类汇总叠加。
  Widget _buildSourceRow(CategoryWithCount item, {bool isChild = false}) {
    return Padding(
      padding: EdgeInsets.only(
        left: isChild ? AppDimens.p20 : 0,
        top: AppDimens.p4,
        bottom: AppDimens.p4,
      ),
      child: Row(
        children: [
          CategoryIconWidget(
            category: item.category,
            showBackground: true,
            size: isChild ? AppDimens.icon16 : AppDimens.icon20,
          ),
          const SizedBox(width: AppDimens.p8),
          Expanded(
            child: Text(
              CategoryUtils.getDisplayName(item.category.name, context),
              style: AppTextTokens.body(context).copyWith(
                color: isChild ? AppTokens.textSecondary(context) : null,
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context).categoryMigrationTransactionLabel(
              affectedTransactionCount(
                item,
                widget.categoriesWithCount,
                includeParents: widget.includeParents,
                option: _option,
              ),
            ),
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  /// 构建源分类、策略选择、迁移目标和固定底部确认操作。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedItems = _selectedItems;
    // 影响范围：选中分类 + 随删除/迁移一并消失的子分类
    final impactScope = buildDeleteImpactScope(
      widget.categoriesWithCount,
      widget.selectedIds,
      includeParents: widget.includeParents,
      option: _option,
    );
    // 总计只累计选中分类，子分类笔数已含在父分类内
    final transactionCount = totalAffectedTransactionCount(
      widget.categoriesWithCount,
      widget.selectedIds,
      includeParents: widget.includeParents,
      option: _option,
    );
    final target = _targetCategory;
    final options = widget.includeParents
        ? [
            l10n.categoryDeleteOptionAll,
            l10n.categoryDeleteOptionMigrate,
            l10n.categoryDeleteOptionPromote,
          ]
        : [
            l10n.subcategoryDeleteOptionAll,
            l10n.subcategoryDeleteOptionMigrate,
          ];
    final canConfirm =
        selectedItems.length == widget.selectedIds.length &&
        selectedItems.isNotEmpty &&
        !_selectingTarget &&
        (_option != 1 || target != null);

    return AppSheet(
      header: AppEditorHeader(
        title: l10n.categoryDeleteSelectedTitle,
        onBack: widget.onBack,
      ),
      footer: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: canConfirm
              ? () => widget.onConfirm((
                  option: _option,
                  targetId: _option == 1 ? _targetId : null,
                ))
              : null,
          style: _option == 1
              ? null
              : FilledButton.styleFrom(
                  backgroundColor: AppTokens.error(context),
                ),
          child: Text(
            _option == 1
                ? l10n.categoryMigrateConfirmButton
                : l10n.categoryManageConfirmDelete,
            textAlign: TextAlign.center,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimens.p12),
                  SectionCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(AppDimens.p12),
                    color: AppTokens.surfaceSecondary(context),
                    showShadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.categoryTemplateSelectedCount(
                            selectedItems.length,
                          ),
                          style: AppTextTokens.title(context),
                        ),
                        const SizedBox(height: AppDimens.p8),
                        for (final row in impactScope)
                          _buildSourceRow(row.item, isChild: row.isChild),
                        AppTokens.cardDivider(
                          context,
                          indent: 0,
                          verticalGap: 0,
                          height: AppDimens.p20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.categoryDetailTotalCount,
                                style: AppTextTokens.body(context),
                              ),
                            ),
                            Text(
                              l10n.categoryMigrationTransactionLabel(
                                transactionCount,
                              ),
                              style: AppTextTokens.title(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  for (var index = 0; index < options.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.p8),
                      child: Semantics(
                        checked: _option == index,
                        inMutuallyExclusiveGroup: true,
                        child: Material(
                          color: _option == index
                              ? AppTokens.surfaceSelected(context)
                              : AppTokens.surface(context),
                          shape: selectableCardShape(
                            context,
                            selected: _option == index,
                            unselectedBorder: BorderSide(
                              color: AppTokens.borderStrong(context),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppRadioTile(
                            title: options[index],
                            selected: _option == index,
                            onTap: () => setState(() => _option = index),
                          ),
                        ),
                      ),
                    ),
                  if (_option == 1) ...[
                    const SizedBox(height: AppDimens.p4),
                    AppListTile(
                      leading: AppIcons.driveFileMove,
                      title: l10n.categoryMigrateSelectTargetTitle,
                      subtitle: target == null ? null : _targetLabel(target),
                      enabled: !_selectingTarget,
                      onTap: _chooseTarget,
                    ),
                  ] else ...[
                    const SizedBox(height: AppDimens.p8),
                    Text(
                      widget.includeParents
                          ? (_option == 0
                                ? l10n.categoryDeleteSelectedSubtitleWithSub(
                                    selectedItems.length,
                                  )
                                : l10n.categoryDeleteSelectedSubtitleWithoutSub(
                                    selectedItems.length,
                                  ))
                          : l10n.subcategoryDeleteSelectedSubtitle(
                              selectedItems.length,
                            ),
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
