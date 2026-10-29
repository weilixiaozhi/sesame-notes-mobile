import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
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

import '../domain/category_manage_logic.dart';
import 'widgets/category_delete_review_sheet.dart';
import 'widgets/category_grid_selector.dart';

import 'widgets/category_delete_mode.dart';
import 'widgets/category_manage_grid.dart';

/// 分类管理页面
///
/// 支持长按拖拽排序、添加分类、复选删除模式（三种删除策略）。
class CategoryManagePage extends ConsumerStatefulWidget {
  const CategoryManagePage({super.key});

  @override
  ConsumerState<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends ConsumerState<CategoryManagePage>
    with CategoryDeleteModeState {
  late final CategoryActions _actions;

  /// 管理页面的选择及待确认操作始终属于打开页面时的账号。
  @override
  void initState() {
    super.initState();
    _actions = ref.read(categoryActionsProvider);
  }

  /// 展示分类管理入口与批量选择状态。
  @override
  Widget build(BuildContext context) {
    final categoriesWithCountAsync = ref.watch(categoriesWithCountProvider);
    final l10n = AppLocalizations.of(context);

    // 删除模式下按返回键退出删除模式而非关闭页面
    return PopScope(
      canPop: !isDeleteMode,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) exitDeleteMode();
      },
      child: Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              title: isDeleteMode
                  ? l10n.categorySelectParentsTitle
                  : l10n.categoryTitle,
              showBack: true,
              actions: isDeleteMode
                  ? null
                  : [
                      IconButtonTheme(
                        data: IconButtonThemeData(
                          style: IconButton.styleFrom(
                            foregroundColor: AppTokens.iconPrimary(context),
                          ),
                        ),
                        child: HeaderIconAction(
                          icon: AppIcons.add,
                          tooltip: l10n.categoryManageAdd,
                          onPressed: _addCategory,
                        ),
                      ),
                      AppPopupMenu(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).showMenuTooltip,
                        onSelected: (action) {
                          if (action == 'delete') enterDeleteMode();
                          if (action == 'unused') _clearUnusedCategories();
                        },
                        items: [
                          AppMenuItem.action(
                            value: 'delete',
                            label: l10n.categoryManageDelete,
                            icon: AppIcons.delete,
                          ),
                          AppMenuItem.action(
                            value: 'unused',
                            label: l10n.categoryClearUnused,
                            icon: AppIcons.clearAll,
                          ),
                        ],
                      ),
                    ],
            ),
            // 共享账本横幅：按角色提示分类归属（Owner → 修改同步给成员；
            // Editor → 记账用 Owner 分类，此处仅影响个人分类），非共享不渲染
            _buildSharedLedgerBanner(l10n),
            Expanded(
              child: categoriesWithCountAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  logger.error('CategoryManage', '分类列表加载失败', error, stack);
                  return AppEmpty(
                    text: l10n.commonOperationFailed,
                    icon: AppIcons.error,
                  );
                },
                data: (categoriesWithCount) {
                  return _buildBody(context, l10n, categoriesWithCount);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 共享账本横幅：仅当前账本为共享账本时渲染，按我的角色切换文案——
  /// Owner：提示分类变更会同步给全体成员；Editor：提示共享账本记账使用
  /// Owner 的分类，此页编辑仅影响个人分类。角色取自 [currentLedgerProvider]
  /// 状态入口，不直连 db。
  Widget _buildSharedLedgerBanner(AppLocalizations l10n) {
    final ledger = ref.watch(currentLedgerDisplayProvider).value;
    // 共享状态由成员数与当前角色共同判定，与 AA 参与人名册口径一致。
    if (ledger == null ||
        (ledger.memberCount <= 1 && ledger.myRole == 'owner')) {
      return const SizedBox.shrink();
    }
    final isOwner = ledger.myRole == 'owner';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p4,
        AppDimens.p16,
        0,
      ),
      child: AppStatusBanner(
        inset: true,
        icon: AppIcons.people,
        message: isOwner
            ? l10n.categorySharedManageBannerOwner
            : l10n.categorySharedManageBannerEditor,
      ),
    );
  }

  /// 分类列表独立滚动，选择模式的下一步操作固定在底部。
  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List<({db.CategoryDisplay category, int transactionCount})>
    categoriesWithCount,
  ) {
    final parentIds = categoriesWithCount
        .where((item) => item.category.parentId == null)
        .map((item) => item.category.id)
        .toSet();
    final allSelected =
        parentIds.isNotEmpty && selectedCategoryIds.containsAll(parentIds);

    return Column(
      children: [
        if (!isDeleteMode) _buildTemplateEntries(context, l10n),
        if (!isDeleteMode) _buildReorderHint(context, l10n),
        if (isDeleteMode)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.categoryTemplateSelectedCount(
                      selectedCategoryIds.length,
                    ),
                    style: AppTextTokens.label(context),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        selectedCategoryIds.clear();
                      } else {
                        selectedCategoryIds.addAll(parentIds);
                      }
                    });
                  },
                  child: Text(
                    allSelected
                        ? l10n.categoryTemplateDeselectAll
                        : l10n.categoryTemplateSelectAll,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: CategoryManageGrid(
            categoriesWithCount: categoriesWithCount,
            isDeleteMode: isDeleteMode,
            selectedCategoryIds: selectedCategoryIds,
            onToggleSelect: toggleSelect,
          ),
        ),
        if (isDeleteMode) _buildDeleteFooter(l10n),
      ],
    );
  }

  /// 统一模板入口同时支持新建父子分类和向已有父分类添加子项。
  Widget _buildTemplateEntries(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p12,
        AppDimens.p16,
        0,
      ),
      child: EntryBarButton(
        onTap: () => context.pushNamed(Routes.categoryTemplates),
        icon: AppIcons.checklist,
        label: l10n.categoryTemplateLibraryTitle,
      ),
    );
  }

  // ==================== 排序提示 ====================

  /// 分类长按排序提示，沿用项目图标和文字令牌。
  Widget _buildReorderHint(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p12,
        AppDimens.p16,
        AppDimens.p4,
      ),
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
    );
  }

  /// 选择阶段只展示下一步，分类数据未就绪时禁止进入确认。
  Widget _buildDeleteFooter(AppLocalizations l10n) {
    final ready =
        selectedCategoryIds.isNotEmpty &&
        ref.watch(categoriesWithCountProvider).hasValue;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: SizedBox(
          width: double.infinity,
          height: AppDimens.actionButtonMinHeight,
          child: AppPrimaryButton(
            fullWidth: false,
            label: l10n.commonNext,
            onPressed: ready ? _confirmDelete : null,
          ),
        ),
      ),
    );
  }

  /// 确认页仅收集策略和迁移目标，执行仍交给现有业务方法。
  Future<void> _confirmDelete() async {
    if (selectedCategoryIds.isEmpty) return;
    try {
      final categories = ref.read(categoriesWithCountProvider).value;
      if (categories == null) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
        return;
      }
      final decision = await showCategoryDeleteReview(
        context,
        categoriesWithCount: categories,
        selectedIds: selectedCategoryIds,
        includeParents: true,
        initialOption: deleteOption,
        selectTarget: () => _selectMigrateTarget(categories),
      );
      if (decision == null || !mounted) return;
      deleteOption = decision.option;
      if (deleteOption == 1) {
        await _executeMigrateAndDelete(decision.targetId!);
      } else {
        await _executeDelete(categories);
      }
    } catch (error, stack) {
      logger.error('CategoryManage', '打开删除确认失败', error, stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 父分类迁移候选沿用原过滤规则，排除选中分类及其子分类。
  Future<String?> _selectMigrateTarget(
    List<({db.CategoryDisplay category, int transactionCount})>
    categoriesWithCount,
  ) async {
    final l10n = AppLocalizations.of(context);
    // 排除选中分类及其子分类：管理页删除的是选中分类的整棵树。
    final availableCategories = selectMigrateTargets(
      categoriesWithCount,
      selectedCategoryIds,
      excludeChildrenOfSelected: true,
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

  /// 执行删除操作（策略 0 和 2）
  Future<void> _executeDelete(
    List<({db.CategoryDisplay category, int transactionCount})>
    categoriesWithCount,
  ) async {
    final l10n = AppLocalizations.of(context);
    final selectedIds = selectedCategoryIds.toList();

    try {
      final actions = _actions;

      if (deleteOption == 0) {
        // 策略 0：删除分类和分类下的所有数据（含二级）
        // 收集待删一级分类的二级分类 id（UUID 字符串主键）一并清空交易
        await actions.deleteCascade(
          selectedIds,
          subCategoryIds: collectSubCategoryIds(
            categoriesWithCount,
            selectedIds,
          ),
        );
      } else {
        // 策略 2：删除分类和分类下的所有数据（不含二级，二级变一级）
        await actions.deletePromotingChildren(selectedIds);
      }

      if (!mounted) return;
      showToast(context, l10n.categoryClearUnusedSuccess(selectedIds.length));
      ref.invalidate(categoriesWithCountProvider);
      exitDeleteMode();
    } catch (e) {
      logger.error('CategoryManage', '批量删除分类失败: $e');
      if (!mounted) return;
      showToast(
        context,
        categoryActionErrorMessage(e, l10n.categoryDeleteError),
      );
    }
  }

  /// 执行迁移并删除（策略 1）
  ///
  /// 两步操作：先把源分类（含其二级分类）的全部数据统一迁移到目标分类，
  /// 再删除源分类及其子分类
  Future<void> _executeMigrateAndDelete(String targetCategoryId) async {
    final l10n = AppLocalizations.of(context);
    final selectedIds = selectedCategoryIds.toList();

    try {
      await _actions.migrateAndDelete(selectedIds, targetCategoryId);

      if (!mounted) return;
      showToast(context, l10n.categoryClearUnusedSuccess(selectedIds.length));
      ref.invalidate(categoriesWithCountProvider);
      exitDeleteMode();
    } catch (e) {
      logger.error('CategoryManage', '迁移并删除分类失败: $e');
      if (!mounted) return;
      showToast(
        context,
        categoryActionErrorMessage(e, l10n.categoryDeleteError),
      );
    }
  }

  // ==================== 添加分类 ====================

  /// 跳转到新增分类页面（路由名跳转）。
  void _addCategory() async {
    await context.pushNamed(Routes.categoryEdit, extra: (null, null));
  }

  // ==================== 清空未使用分类 ====================

  /// 清空未使用的分类（交易数为 0 的分类）
  Future<void> _clearUnusedCategories() async {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(categoriesWithCountProvider);
    if (state.hasError) {
      showToast(
        context,
        categoryActionErrorMessage(
          state.error!,
          l10n.categoryClearUnusedFailed,
        ),
      );
      return;
    }
    final categoriesWithCount = state.value ?? [];

    // 找出交易数为 0 的分类（统计已包含子分类交易数）
    final unusedCategories = selectUnusedCategories(categoriesWithCount);

    if (unusedCategories.isEmpty) {
      showToast(context, l10n.categoryClearUnusedEmpty);
      return;
    }

    // 收集将被删除的分类信息（包括子分类）
    final toDeleteList = <String>[];
    for (final item in unusedCategories) {
      final categoryName = CategoryUtils.getDisplayName(
        item.category.name,
        context,
      );
      toDeleteList.add(categoryName);

      // 如果是父分类，添加其所有将被删除的子分类
      if (item.category.parentId == null) {
        final children = unusedCategories
            .where((c) => c.category.parentId == item.category.id)
            .toList();
        for (final child in children) {
          final childName = CategoryUtils.getDisplayName(
            child.category.name,
            context,
          );
          toDeleteList.add('  ├─ $childName');
        }
      }
    }

    final confirm = await showAppSheet<bool>(
      context: context,
      child: AppSheet(
        title: l10n.categoryClearUnused,
        footer: Builder(
          builder: (sheetContext) => SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(sheetContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppTokens.error(context),
              ),
              child: Text(l10n.commonDelete),
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.categoryClearUnusedMessage(unusedCategories.length),
                style: AppTextTokens.body(context),
              ),
              const SizedBox(height: AppDimens.p16),
              Text(
                l10n.categoryClearUnusedListTitle,
                style: AppTextTokens.strongTitle(context),
              ),
              const SizedBox(height: AppDimens.p8),
              Text(
                toDeleteList.join('\n'),
                style: AppTextTokens.label(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      final ids = unusedCategories.map((item) => item.category.id).toList();
      await _actions.delete(ids);

      if (!mounted) return;
      showToast(context, l10n.categoryClearUnusedSuccess(ids.length));
      ref.invalidate(categoriesWithCountProvider);
    } catch (e, stack) {
      logger.error('CategoryManage', '清空未使用分类失败', safeErrorSummary(e), stack);
      if (!mounted) return;
      showToast(
        context,
        categoryActionErrorMessage(e, l10n.categoryClearUnusedFailed),
      );
    }
  }
}
