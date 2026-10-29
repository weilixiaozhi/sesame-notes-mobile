import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import 'category_subcategory_dialog.dart';

/// 分类网格负责排序与卡片展示，页面通过回调组合导航和删除行为。
class CategoryManageGrid extends ConsumerStatefulWidget {
  final List<({db.CategoryDisplay category, int transactionCount})>
  categoriesWithCount;

  /// 是否处于删除模式
  final bool isDeleteMode;

  /// 删除模式下选中的分类 ID 集合（UUID 字符串）
  final Set<String> selectedCategoryIds;

  final void Function(String categoryId) onToggleSelect;

  /// 使用展示模型与选择回调组合分类卡片，不直接持有存储实现。
  const CategoryManageGrid({
    super.key,
    required this.categoriesWithCount,
    required this.isDeleteMode,
    required this.selectedCategoryIds,
    required this.onToggleSelect,
  });

  @override
  ConsumerState<CategoryManageGrid> createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends ConsumerState<CategoryManageGrid> {
  late final CategoryActions _actions;
  List<_CategoryItem> _flatList = [];

  @override
  void initState() {
    super.initState();
    _actions = ref.read(categoryActionsProvider);
    _loadData();
  }

  @override
  void didUpdateWidget(CategoryManageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoriesWithCount != oldWidget.categoriesWithCount) {
      _loadData();
    }
  }

  /// 按展示顺序构建一级分类及其汇总笔数。
  void _loadData() {
    // 获取一级分类
    final topLevelCategories = widget.categoriesWithCount
        .where((item) => item.category.parentId == null)
        .toList();

    // 按 sortOrder 排序
    topLevelCategories.sort(
      (a, b) => a.category.sortOrder.compareTo(b.category.sortOrder),
    );

    final flatList = <_CategoryItem>[];
    final subcategoryCounts = <String, int>{};
    for (final item in widget.categoriesWithCount) {
      final parentId = item.category.parentId;
      if (parentId != null) {
        subcategoryCounts.update(
          parentId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    for (final topItem in topLevelCategories) {
      // transactionCount 已经包含了所有子分类的交易数，不需要再累加
      flatList.add(
        _CategoryItem(
          category: topItem.category,
          transactionCount: topItem.transactionCount,
          subcategoryCount: subcategoryCounts[topItem.category.id] ?? 0,
        ),
      );
    }

    setState(() {
      _flatList = flatList;
    });
  }

  /// 按当前模式构建可排序或可多选的父分类网格。
  @override
  Widget build(BuildContext context) {
    final topLevelCategories = List<_CategoryItem>.of(_flatList);

    if (topLevelCategories.isEmpty) {
      return AppEmpty(
        text: AppLocalizations.of(context).categoryEmpty,
        icon: AppIcons.category,
      );
    }

    // 选择模式只切换分类勾选，普通模式沿用长按拖拽排序。
    if (widget.isDeleteMode) {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.p16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: AppDimens.p8,
                mainAxisSpacing: AppDimens.p8,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = topLevelCategories[index];
                return _CategoryCard(
                  key: ValueKey(item.category.id),
                  item: item,
                  isDeleteMode: true,
                  isSelected: widget.selectedCategoryIds.contains(
                    item.category.id,
                  ),
                  onTap: () => widget.onToggleSelect(item.category.id),
                );
              }, childCount: topLevelCategories.length),
            ),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppDimens.p16),
          sliver: ReorderableSliverGridView(
            crossAxisCount: 4,
            crossAxisSpacing: AppDimens.p8,
            mainAxisSpacing: AppDimens.p8,
            childAspectRatio: 0.9,
            // 自定义拖拽中的卡片外观：包默认用 Material(elevation: 3) 包裹，
            // 会在圆角卡片底部衬出一个方形背景；用透明 Material 不绘制该背景，
            // 拖拽时只呈现卡片自身的圆角样式。
            dragWidgetBuilderV2: DragWidgetBuilderV2(
              builder: (index, child, screenshot) =>
                  Material(type: MaterialType.transparency, child: child),
            ),
            onReorder: (oldIndex, newIndex) {
              _onReorderTopLevel(oldIndex, newIndex, topLevelCategories);
            },
            children: [
              for (final item in topLevelCategories)
                _CategoryCard(
                  key: ValueKey(item.category.id),
                  item: item,
                  isDeleteMode: false,
                  isSelected: false,
                  onTap: () => _onCategoryTap(item),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 拖拽排序后批量更新 sortOrder。
  ///
  /// 注意：reorderable_grid_view 的 onReorder 回调中 newIndex 已是「直接插入位置」，
  /// 与原生 ReorderableListView（newIndex 为移除拖拽项后的下标）语义不同，
  /// 切勿再做 `if (oldIndex < newIndex) newIndex -= 1` 的修正，
  /// 否则向右相邻一格拖拽会变成 remove 后原样 insert，表现为「移动失败、跳回原位」。
  Future<void> _onReorderTopLevel(
    int oldIndex,
    int newIndex,
    List<_CategoryItem> topLevelCategories,
  ) async {
    // 同步获取文案，避免在异步 gap 后跨 BuildContext 读取
    final l10n = AppLocalizations.of(context);
    final failMessage = l10n.categorySortSaveFailed;

    // 1. 先乐观更新本地状态（reorderable_grid_view 的 newIndex 即为插入位置，无需减 1），
    //    保证 UI 立即响应拖拽、不回跳。
    final reorderedItems = List<_CategoryItem>.from(topLevelCategories);
    final movedItem = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(newIndex, movedItem);

    // 重建 _flatList，保持一级分类的新顺序
    setState(() {
      _flatList = reorderedItems;
    });

    try {
      for (final item in reorderedItems) {
        _actions.requireCategoryContext(item.category);
      }
      // 2. 批量保存到数据库
      final updates = reorderedItems.asMap().entries.map((entry) {
        return (id: entry.value.category.id, sortOrder: entry.key);
      }).toList();
      await _actions.reorder(updates);
      if (!mounted) return;

      // 拖拽排序也记了 ChangeTracker 变更，推到云端让 web 的 sortOrder 一致
      // 3. 刷新 provider 以同步其他地方的数据
      ref.invalidate(categoriesWithCountProvider);
    } catch (e, stack) {
      // 记录详细错误日志，便于排查排序保存失败的原因
      logger.error('CategoryManage', '拖拽排序一级分类失败', e, stack);
      // 保存失败时回滚乐观更新，恢复拖拽前的顺序，避免 UI 与数据库不一致
      if (mounted) {
        setState(() {
          _flatList = List<_CategoryItem>.from(topLevelCategories);
        });
        // 向用户展示友好的错误提示
        showToast(context, categoryActionErrorMessage(e, failMessage));
      }
    }
  }

  /// 有子分类时展开列表，无子分类时直接进入现有编辑页。
  void _onCategoryTap(_CategoryItem item) async {
    try {
      if (item.subcategoryCount > 0) {
        await _showSubcategoryDialog(item.category);
      } else {
        await _onEditCategory(item.category);
      }
    } catch (error, stack) {
      logger.error('CategoryManage', '打开分类失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 关闭父分类面板后进入现有编辑页，编辑返回分类管理页。
  Future<void> _showSubcategoryDialog(db.CategoryDisplay parentCategory) async {
    try {
      final request =
          await showAppSheet<({db.CategoryDisplay category, bool add})>(
            context: context,
            child: Builder(
              builder: (sheetContext) => CategorySubcategoryDialog(
                parentCategory: parentCategory,
                categoriesWithCount: widget.categoriesWithCount,
                onSubCategoryTap: (category) => Navigator.pop(sheetContext, (
                  category: category,
                  add: false,
                )),
                onAddSubCategory: () => Navigator.pop(sheetContext, (
                  category: parentCategory,
                  add: true,
                )),
                onEditParentCategory: () => Navigator.pop(sheetContext, (
                  category: parentCategory,
                  add: false,
                )),
              ),
            ),
          );
      if (request == null || !mounted) return;
      if (request.add) {
        await _onAddSubCategory(request.category);
      } else {
        await _onEditCategory(request.category);
      }
    } catch (error, stack) {
      logger.error('CategoryManage', '打开分类面板失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 跳转到分类编辑页（路由名跳转，record 参数 = (category, parent)）。
  Future<void> _onEditCategory(db.CategoryDisplay category) async {
    await context.pushNamed(Routes.categoryEdit, extra: (category, null));
  }

  /// 跳转到新增子分类页（路由名跳转，record 参数 = (category, parent)）。
  Future<void> _onAddSubCategory(db.CategoryDisplay parent) async {
    await context.pushNamed(Routes.categoryEdit, extra: (null, parent));
    if (mounted) _loadData();
  }
}

/// 分类项数据模型
class _CategoryItem {
  final db.CategoryDisplay category;
  final int transactionCount;
  final int subcategoryCount;

  _CategoryItem({
    required this.category,
    required this.transactionCount,
    required this.subcategoryCount,
  });
}

/// 紧凑分类卡片依次展示图标、名称、子分类数量和笔数，选择态复用统一角标。
class _CategoryCard extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback onTap;
  final bool isDeleteMode;
  final bool isSelected;

  const _CategoryCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDeleteMode,
    required this.isSelected,
  });

  /// 采用项目分类图标组件和表面、文字、选中态令牌。
  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isDeleteMode ? isSelected : null,
      child: Material(
        color: AppTokens.surface(context),
        shape: selectableCardShape(context),
        child: InkWell(
          onTap: onTap,
          customBorder: selectableCardShape(context),
          child: Container(
            decoration: ShapeDecoration(
              shape: selectableCardShape(
                context,
                selected: isDeleteMode && isSelected,
                unselectedBorder: BorderSide(
                  color: AppTokens.borderStrong(context),
                ),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.p8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CategoryIconWidget(
                            category: item.category,
                            size: AppDimens.icon18,
                            showBackground: true,
                            backgroundSize: AppDimens.p32,
                          ),
                          const SizedBox(height: AppDimens.p4),
                          Text(
                            CategoryUtils.getDisplayName(
                              item.category.name,
                              context,
                            ),
                            style: AppTextTokens.label(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppDimens.p4),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).categoryManageSubcategoryCount(
                              item.subcategoryCount,
                            ),
                            style: AppTextTokens.caption(context),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).categoryMigrationTransactionLabel(
                              item.transactionCount,
                            ),
                            style: AppTextTokens.caption(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isDeleteMode && isSelected)
                  const SelectableCardCheckBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
