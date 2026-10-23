import 'package:sesame_notes/shared/application/provider_reader.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';

import 'category_template_widgets.dart';
import 'category_template_submission.dart';

/// 二级分类模板页（hierarchical 模板库）
///
/// 在 flat 模板页交互基础上增加：
/// - 点父分类展开/收起其子类（对齐记账页分类选择器交互）；
/// - 父分类选中状态由子分类汇总，已有子分类保留勾选；
/// - 仅记录本次选择的子分类，写入计划自动补齐尚未添加的父分类。
class CategoryTemplateHierarchicalPage extends ConsumerStatefulWidget {
  const CategoryTemplateHierarchicalPage({super.key});

  @override
  ConsumerState<CategoryTemplateHierarchicalPage> createState() =>
      _CategoryTemplateHierarchicalPageState();
}

class _CategoryTemplateHierarchicalPageState
    extends ConsumerState<CategoryTemplateHierarchicalPage> {
  /// 本次勾选的子分类 key，不含已添加条目。
  Set<String> _selected = {};

  /// 当前展开子类的父分类 key（单展开，对齐记账页）
  String? _expandedKey;

  /// 是否正在执行写入
  bool _isAdding = false;

  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catsAsync = ref.watch(categoriesWithCountProvider);
    final pendingAsync = ref.watch(categoryTemplatePendingIdsProvider);

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.categoryTemplateHierarchicalTitle,
            showBack: true,
          ),
          Expanded(
            child: catsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) {
                logger.error('categoryTemplate', 'hierarchical 分类加载失败', e, st);
                return AppLoadError(
                  message: l10n.commonOperationFailed,
                  onRetry: () => ref.invalidate(categoriesWithCountProvider),
                );
              },
              data: (cats) => pendingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => AppLoadError(
                  message: l10n.commonOperationFailed,
                  onRetry: () =>
                      ref.invalidate(categoryTemplatePendingIdsProvider),
                ),
                data: (pendingIds) =>
                    _buildBody(context, l10n, cats, pendingIds),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    List<({db.CategoryDisplay category, int transactionCount})> cats,
    Set<String> pendingIds,
  ) {
    final existingIndex = ExistingCategoryIndex([
      for (final c in cats)
        (
          id: c.category.id,
          name: c.category.name,
          level: c.category.level,
          parentId: c.category.parentId,
        ),
    ], pendingIds: pendingIds);
    final groups = buildHierarchicalTemplateGroups(l10n, existingIndex);
    // 扁平化全部条目（生成写入计划 / 统计可选数用）
    final allItems = [
      for (final g in groups) ...[g.parent, ...g.children],
    ];
    final selectableCount = groups
        .expand((group) => group.children)
        .where((child) => child.canAdd)
        .length;

    final selected = _selected.intersection({
      for (final item in allItems)
        if (item.canAdd) item.key,
    });
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(AppDimens.p16),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p12),
            itemBuilder: (context, index) =>
                _buildGroup(context, groups[index]),
          ),
        ),
        TemplateBottomBar(
          selectedCount: selected.length,
          allSelected:
              selectableCount > 0 && selected.length == selectableCount,
          isAdding: _isAdding,
          isWriting: _isWriting,
          onToggleSelectAll: () => setState(() {
            final all = computeHierarchicalSelectAll(groups);
            // 全局选择仅包含未添加子分类，父卡片同步汇总子项的状态。
            _selected = selected.length == all.length ? {} : all;
          }),
          onAdd: () => _onAdd(l10n, allItems),
        ),
      ],
    );
  }

  /// 单个父子组：父分类行 + 展开时的子分类网格
  Widget _buildGroup(BuildContext context, CategoryTemplateGroup group) {
    final parent = group.parent;
    final expanded = _expandedKey == parent.key;
    final l10n = AppLocalizations.of(context);
    final blocked = categoryTemplateBlockMessage(l10n, parent.blockedReason);

    return Column(
      children: [
        _buildParentTile(context, group, expanded),
        if (parent.pendingConfirmation)
          Text(l10n.categoryTemplatePending(1))
        else if (blocked != null)
          Text(blocked),
        if (expanded) _buildChildrenCard(context, group),
      ],
    );
  }

  /// 父分类整行展开子项，角标按子项覆盖数表达完整或部分选中。
  Widget _buildParentTile(
    BuildContext context,
    CategoryTemplateGroup group,
    bool expanded,
  ) {
    final parent = group.parent;
    final coveredCount = group.children
        .where(
          (item) =>
              (item.alreadyAdded && !item.pendingConfirmation) ||
              (item.canAdd && _selected.contains(item.key)),
        )
        .length;
    final checked = coveredCount > 0;
    final partial = checked && coveredCount < group.children.length;

    return Container(
      key: ValueKey('templateParentCard_${parent.key}'),
      decoration: ShapeDecoration(
        color: AppTokens.surface(context),
        shape: selectableCardShape(
          context,
          selected: checked,
          unselectedBorder: BorderSide(color: AppTokens.borderStrong(context)),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            checked: partial ? null : checked,
            mixed: partial,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: selectableCardShape(context),
                onTap: () =>
                    setState(() => _expandedKey = expanded ? null : parent.key),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppDimens.p40 + AppDimens.p16,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p12,
                    ),
                    child: Row(
                      children: [
                        CategoryIconWidget(
                          iconName: parent.iconName,
                          showBackground: true,
                          size: AppDimens.icon22,
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Expanded(
                          child: Text(
                            parent.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextTokens.body(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                          ),
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Icon(
                          AppIcons.chevronRight,
                          key: ValueKey('templateParentArrow_${parent.key}'),
                          size: AppDimens.icon16,
                          color: AppTokens.iconTertiary(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (checked) SelectableCardCheckBadge(partial: partial),
        ],
      ),
    );
  }

  /// 展开的子分类网格卡片
  Widget _buildChildrenCard(BuildContext context, CategoryTemplateGroup group) {
    return Container(
      padding: const EdgeInsets.only(
        top: AppDimens.p8,
        left: AppDimens.p8,
        right: AppDimens.p8,
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: AppDimens.p8,
          crossAxisSpacing: AppDimens.p8,
          mainAxisExtent: categoryTemplateTileHeight(context, compact: true),
        ),
        itemCount: group.children.length,
        itemBuilder: (context, index) {
          final child = group.children[index];
          return TemplateItemTile(
            item: child,
            compact: true,
            selected: _selected.contains(child.key),
            onToggle: () => _toggleChild(child),
          );
        },
      ),
    );
  }

  /// 切换未添加的子分类，父卡片随子项状态自动更新。
  void _toggleChild(CategoryTemplateItem child) {
    if (_isAdding || !child.canAdd) return;
    setState(() {
      _selected = toggleFlatSelection(_selected, child.key);
    });
  }

  /// 点击"添加"：二次确认 → 写入 categories 表（父先子后）
  Future<void> _onAdd(
    AppLocalizations l10n,
    List<CategoryTemplateItem> allItems,
  ) async {
    if (_isAdding) return;
    final plan = buildInsertPlan(allItems: allItems, selectedKeys: _selected);
    if (plan.total == 0) return;
    final read = ref.read(applicationReaderProvider);
    final session = captureTemplateInsertSession(read);
    setState(() => _isAdding = true);
    try {
      final result = await submitCategoryTemplatePlan(
        context,
        count: plan.total,
        onWriting: (writing) {
          if (mounted) setState(() => _isWriting = writing);
        },
        execute: (restoreIds) async {
          session.assertCurrent();
          final current = await ref.read(categoriesWithCountProvider.future);
          session.assertCurrent();
          return executeTemplateInsertPlanFromUi(
            read,
            session: session,
            plan: plan,
            existingCategories: [for (final entry in current) entry.category],
            restoreLocalDeletedIds: restoreIds,
          );
        },
      );
      if (mounted && result != null) {
        session.assertCurrent();
        showToast(context, result.describe(l10n));
        setState(() => _selected = {});
      }
    } catch (e, st) {
      reportCategoryTemplateSubmissionFailure(
        mounted ? context : null,
        ref: ref,
        session: session,
        error: e,
        stackTrace: st,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
          _isWriting = false;
        });
      }
    }
  }
}
