import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../domain/category_manage_logic.dart';
import '../widgets/category_delete_review_sheet.dart';
import '../widgets/category_grid_selector.dart';

import 'category_delete_mode.dart';

/// 子分类底部面板：父子分类均以右箭头进入现有编辑页，列表支持长按与批量选择。
class CategorySubcategoryDialog extends ConsumerStatefulWidget {
  final db.CategoryDisplay parentCategory;
  final List<({db.CategoryDisplay category, int transactionCount})>
  categoriesWithCount;
  final Function(db.CategoryDisplay) onSubCategoryTap;
  final VoidCallback onAddSubCategory;
  final VoidCallback onEditParentCategory;

  /// 固定父分类与初始展示快照，导航和新增操作由调用方提供。
  const CategorySubcategoryDialog({
    super.key,
    required this.parentCategory,
    required this.categoriesWithCount,
    required this.onSubCategoryTap,
    required this.onAddSubCategory,
    required this.onEditParentCategory,
  });

  @override
  ConsumerState<CategorySubcategoryDialog> createState() =>
      _SubcategoryDialogState();
}

class _SubcategoryDialogState extends ConsumerState<CategorySubcategoryDialog>
    with CategoryDeleteModeState {
  late final CategoryActions _actions;
  List<({db.CategoryDisplay category, int transactionCount})>? _subCategories;
  List<({db.CategoryDisplay category, int transactionCount})>?
  _reviewCategories;
  bool _isLoading = true;

  /// 加载失败标志:失败时展示重试入口,避免弹窗永久转圈。
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(categoryActionsProvider);
    _loadSubCategories();
  }

  /// 异步加载子分类列表及其交易笔数
  ///
  /// 笔数优先取 provider 最新值（删除刷新后仍能拿到正确笔数），
  /// provider 未就绪时回退到打开弹窗时传入的快照。
  Future<void> _loadSubCategories() async {
    try {
      _actions.requireCategoryContext(widget.parentCategory);
      final subCategories = await _actions.getSubCategories(
        widget.parentCategory.id,
      );
      if (!mounted) return;

      final countsSource =
          ref.read(categoriesWithCountProvider).value ??
          widget.categoriesWithCount;
      final result = <({db.CategoryDisplay category, int transactionCount})>[];
      for (final subCat in subCategories) {
        final subCount = countsSource
            .firstWhere(
              (item) => item.category.id == subCat.id,
              orElse: () => (category: subCat, transactionCount: 0),
            )
            .transactionCount;
        result.add((category: subCat, transactionCount: subCount));
      }

      if (mounted) {
        setState(() {
          _subCategories = result;
          _isLoading = false;
          _loadFailed = false;
        });
      }
    } catch (e, st) {
      // 加载失败进入失败态,用户可点重试重新查询。
      logger.error(
        'CategoryManage',
        '加载子分类失败 parentId=${widget.parentCategory.id}',
        e,
        st,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  /// 子分类弹窗内拖拽排序后的处理。
  ///
  /// 注意：reorderable_grid_view 的 newIndex 为「直接插入位置」，无需做减 1 修正。
  void _onReorderSubCategory(int oldIndex, int newIndex) {
    if (_subCategories == null) return;

    // 1. 乐观更新本地列表顺序，立即刷新弹窗网格
    final reordered = applyReorder(_subCategories!, oldIndex, newIndex);

    setState(() {
      _subCategories = reordered;
    });

    // 2. 持久化 + 云同步（失败仅提示，不回滚本地顺序以免打断连续拖拽）
    _persistSubCategoryOrder(reordered);
  }

  /// 将子分类的新顺序写入数据库，并触发云同步
  Future<void> _persistSubCategoryOrder(
    List<({db.CategoryDisplay category, int transactionCount})> ordered,
  ) async {
    // 同步获取文案，避免在异步 gap 后跨 BuildContext 读取
    final l10n = AppLocalizations.of(context);
    final failMessage = l10n.categorySortSaveFailed;
    try {
      _actions.requireCategoryContext(widget.parentCategory);
      for (final item in ordered) {
        _actions.requireCategoryContext(item.category);
      }
      // 新顺序的下标即 sortOrder
      await _actions.reorder(reorderUpdates(ordered));
    } catch (e, stack) {
      // 记录详细错误日志，便于排查子分类排序保存失败的原因
      logger.error('SubcategoryDialog', '拖拽排序子分类失败', e, stack);
      // 向用户展示友好的错误提示
      if (mounted) {
        showToast(context, categoryActionErrorMessage(e, failMessage));
      }
    }
  }

  /// 展示父分类概况、子分类列表及当前选择阶段的操作。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final categories = _subCategories ?? [];
    final allSelected =
        categories.isNotEmpty &&
        categories.every(
          (item) => selectedCategoryIds.contains(item.category.id),
        );
    final counts =
        ref.watch(categoriesWithCountProvider).value ??
        widget.categoriesWithCount;
    final countById = {
      for (final item in counts) item.category.id: item.transactionCount,
    };
    // 父子笔数使用同一份快照，保持同步刷新后的直属笔数准确。
    final breakdown = parentTransactionBreakdown(counts, widget.parentCategory);

    return PopScope(
      canPop: !isDeleteMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_reviewCategories != null) {
          _backToSelection();
        } else {
          exitDeleteMode();
        }
      },
      child: _reviewCategories != null
          ? CategoryDeleteReviewSheet(
              categoriesWithCount: _reviewCategories!,
              selectedIds: Set.of(selectedCategoryIds),
              includeParents: false,
              initialOption: deleteOption,
              selectTarget: _selectMigrateTarget,
              onBack: _backToSelection,
              onConfirm: _executeReviewedDelete,
            )
          : AppSheet(
              footer: SizedBox(
                width: double.infinity,
                height: AppDimens.actionButtonMinHeight,
                child: isDeleteMode
                    ? AppPrimaryButton(
                        fullWidth: false,
                        label: l10n.commonNext,
                        onPressed:
                            selectedCategoryIds.isEmpty ||
                                _isLoading ||
                                _loadFailed
                            ? null
                            : _confirmDelete,
                      )
                    : FilledButton.icon(
                        onPressed: widget.onAddSubCategory,
                        icon: const Icon(AppIcons.add, size: AppDimens.icon20),
                        label: Text(l10n.subcategoryAdd),
                      ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, l10n),
                  if (!_isLoading && !_loadFailed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p12,
                      ),
                      child: Text(
                        l10n.categoryTransactionBreakdown(
                          breakdown.directCount,
                          breakdown.totalCount,
                        ),
                        style: AppTextTokens.label(context),
                      ),
                    ),
                  AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isDeleteMode
                              ? l10n.categoryTemplateSelectedCount(
                                  selectedCategoryIds.length,
                                )
                              : l10n.categoryChildrenTitle,
                          style: AppTextTokens.strongTitle(context),
                        ),
                      ),
                      if (isDeleteMode)
                        TextButton(
                          key: const ValueKey('subcategorySelectAll'),
                          onPressed: () => setState(() {
                            if (allSelected) {
                              selectedCategoryIds.clear();
                            } else {
                              selectedCategoryIds.addAll(
                                categories.map((item) => item.category.id),
                              );
                            }
                          }),
                          child: Text(
                            allSelected
                                ? l10n.categoryTemplateDeselectAll
                                : l10n.categoryTemplateSelectAll,
                          ),
                        )
                      else if (!_isLoading &&
                          !_loadFailed &&
                          categories.isNotEmpty)
                        TextButton(
                          key: const ValueKey('subcategoryBatchDelete'),
                          onPressed: enterDeleteMode,
                          child: Text(l10n.subcategoryDelete),
                        ),
                    ],
                  ),
                  if (!isDeleteMode &&
                      !_isLoading &&
                      !_loadFailed &&
                      categories.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.p8),
                      child: Row(
                        children: [
                          Icon(
                            AppIcons.sort,
                            size: AppDimens.icon16,
                            color: AppTokens.textSecondary(context),
                          ),
                          const SizedBox(width: AppDimens.p4),
                          Expanded(
                            child: Text(
                              l10n.categoryManageReorderHint,
                              style: AppTextTokens.label(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppDimens.p32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_loadFailed)
                    AppLoadError(
                      message: l10n.commonOperationFailed,
                      onRetry: () {
                        setState(() {
                          _isLoading = true;
                          _loadFailed = false;
                        });
                        _loadSubCategories();
                      },
                    )
                  else if (categories.isEmpty)
                    AppEmpty(text: l10n.subcategoryEmpty)
                  else
                    Flexible(
                      child: ReorderableGridView.builder(
                        shrinkWrap: true,
                        dragEnabled: !isDeleteMode,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisExtent:
                              MediaQuery.textScalerOf(
                                context,
                              ).scale(AppDimens.p40) +
                              AppDimens.p12 * 2,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final item = categories[index];
                          return _DialogSubCategoryCard(
                            key: ValueKey(item.category.id),
                            category: item.category,
                            transactionCount: countById[item.category.id] ?? 0,
                            isDeleteMode: isDeleteMode,
                            isSelected: selectedCategoryIds.contains(
                              item.category.id,
                            ),
                            onTap: () {
                              if (isDeleteMode) {
                                toggleSelect(item.category.id);
                              } else {
                                widget.onSubCategoryTap(item.category);
                              }
                            },
                          );
                        },
                        dragWidgetBuilderV2: DragWidgetBuilderV2(
                          builder: (index, child, screenshot) => Material(
                            color: AppTokens.surfaceSheet(context),
                            child: child,
                          ),
                        ),
                        onReorder: _onReorderSubCategory,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  /// 展示父分类概况，普通模式支持进入父分类编辑页。
  Widget _buildHeader(BuildContext context, AppLocalizations l10n) =>
      AppListTile(
        leading: AppIcons.category,
        leadingWidget: DetailListIcon(
          backgroundColor: AppTokens.surfaceCategoryIcon(context),
          child: CategoryIconWidget(
            category: widget.parentCategory,
            size: AppDimens.icon20,
          ),
        ),
        title: CategoryUtils.getDisplayName(
          widget.parentCategory.name,
          context,
        ),
        subtitle: !_isLoading && !_loadFailed
            ? l10n.categorySubcategoryCount(_subCategories?.length ?? 0)
            : null,
        onTap: isDeleteMode ? null : widget.onEditParentCategory,
      );

  /// 选择后在当前面板切换到复核步骤。
  void _confirmDelete() {
    if (selectedCategoryIds.isEmpty) return;
    try {
      final counts =
          ref.read(categoriesWithCountProvider).value ??
          widget.categoriesWithCount;
      setState(() => _reviewCategories = List.of(counts));
    } catch (error, stack) {
      logger.error('SubcategoryDialog', '打开删除确认失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 返回子分类选择步骤，保留已勾选的分类。
  void _backToSelection() {
    setState(() => _reviewCategories = null);
  }

  /// 复核确认后退出复核步骤，并按原策略执行删除或迁移。
  Future<void> _executeReviewedDelete(
    ({int option, String? targetId}) decision,
  ) async {
    if (!mounted || _reviewCategories == null) return;
    setState(() {
      _reviewCategories = null;
      deleteOption = decision.option;
    });
    try {
      if (deleteOption == 1) {
        await _executeMigrateAndDelete(decision.targetId!);
      } else {
        await _executeDelete();
      }
    } catch (error, stack) {
      logger.error('SubcategoryDialog', '执行删除确认失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 子分类迁移只排除选中项，仍可迁移到原父分类或其他子分类。
  Future<String?> _selectMigrateTarget() async {
    final l10n = AppLocalizations.of(context);
    final countsSource =
        ref.read(categoriesWithCountProvider).value ??
        widget.categoriesWithCount;
    // 子分类只删选中项本身，原父分类仍可作为迁移目标
    final availableCategories = selectMigrateTargets(
      countsSource,
      selectedCategoryIds,
      excludeChildrenOfSelected: false,
    );
    if (availableCategories.isEmpty) {
      if (mounted) showToast(context, l10n.categoryCannotDelete);
      return null;
    }
    return showCategoryGridSelector(
      context,
      availableCategories: availableCategories,
    );
  }

  /// 执行删除（策略 0）：先删子分类下的交易，再删子分类记录
  Future<void> _executeDelete() async {
    final l10n = AppLocalizations.of(context);
    final selectedIds = selectedCategoryIds.toList();

    try {
      await _actions.deleteCascade(selectedIds);
      await _afterMutation(selectedIds.length);
    } catch (e) {
      logger.error('SubcategoryDialog', '批量删除子分类失败: $e');
      if (!mounted) return;
      showToast(
        context,
        categoryActionErrorMessage(e, l10n.categoryDeleteError),
      );
    }
  }

  /// 执行迁移并删除（策略 1）：先迁移数据到目标分类，再删除源子分类
  Future<void> _executeMigrateAndDelete(String targetCategoryId) async {
    final l10n = AppLocalizations.of(context);
    final selectedIds = selectedCategoryIds.toList();

    try {
      // 迁移子分类交易到目标分类（二级分类无子级，仅迁移交易）后删除源分类
      await _actions.migrateAndDelete(selectedIds, targetCategoryId);
      await _afterMutation(selectedIds.length);
    } catch (e) {
      logger.error('SubcategoryDialog', '迁移并删除子分类失败: $e');
      if (!mounted) return;
      showToast(
        context,
        categoryActionErrorMessage(e, l10n.categoryDeleteError),
      );
    }
  }

  /// 删除或迁移成功后提示结果、刷新管理页并重载子分类列表。
  Future<void> _afterMutation(int deletedCount) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showToast(context, l10n.categoryClearUnusedSuccess(deletedCount));
    ref.invalidate(categoriesWithCountProvider);
    exitDeleteMode();
    // 重载子分类列表；若已全部删除，弹窗保留展示空态
    await _loadSubCategories();
  }
}

/// 底部面板中的子分类列表行
///
/// 正常模式点击进入编辑，删除模式通过行首复选框反馈选中状态。
class _DialogSubCategoryCard extends StatelessWidget {
  final db.CategoryDisplay category;
  final int transactionCount;
  final VoidCallback onTap;

  /// 是否处于删除模式
  final bool isDeleteMode;

  /// 删除模式下是否被选中
  final bool isSelected;

  const _DialogSubCategoryCard({
    super.key,
    required this.category,
    required this.transactionCount,
    required this.onTap,
    this.isDeleteMode = false,
    this.isSelected = false,
  });

  /// 使用项目图标、笔数样式和选中语义构建可点击的子分类行。
  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isDeleteMode ? isSelected : null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppTokens.border(context)),
            ),
          ),
          child: Row(
            children: [
              if (isDeleteMode) ...[
                SizedBox.square(
                  dimension: AppDimens.icon20,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => onTap(),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
              ],
              CategoryIconWidget(
                category: category,
                size: AppDimens.icon20,
                showBackground: true,
                backgroundSize: AppDimens.p40,
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CategoryUtils.getDisplayName(category.name, context),
                      style: AppTextTokens.body(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).categoryMigrationTransactionLabel(transactionCount),
                      style: AppTextTokens.label(context),
                    ),
                  ],
                ),
              ),
              if (!isDeleteMode) ...[
                const SizedBox(width: AppDimens.p12),
                Icon(
                  AppIcons.chevronRight,
                  size: AppDimens.icon20,
                  color: AppTokens.iconTertiary(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
