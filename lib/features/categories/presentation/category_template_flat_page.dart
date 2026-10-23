import 'package:sesame_notes/shared/application/provider_reader.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';

import 'category_template_widgets.dart';
import 'category_template_submission.dart';

/// 一级分类模板页（flat 模板库）
///
/// 交互对齐分类管理删除模式：
/// - 卡片选中时展示主题色角标；已在 categories 表的条目保持勾选、不可再选；
/// - 底部常驻操作栏（已选计数 / 全选·取消全选 / 添加），添加前二次确认；
/// - 仅相同稳定身份算已添加；同名自建分类显示阻止原因，不混同身份。
class CategoryTemplateFlatPage extends ConsumerStatefulWidget {
  const CategoryTemplateFlatPage({super.key});

  @override
  ConsumerState<CategoryTemplateFlatPage> createState() =>
      _CategoryTemplateFlatPageState();
}

class _CategoryTemplateFlatPageState
    extends ConsumerState<CategoryTemplateFlatPage> {
  /// 本次勾选的模板 key（不含已添加条目）
  Set<String> _selected = {};

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
          PrimaryHeader(title: l10n.categoryTemplateFlatTitle, showBack: true),
          Expanded(
            child: catsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) {
                logger.error('categoryTemplate', 'flat 分类加载失败', e, st);
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
    final items = buildFlatTemplateItems(l10n, existingIndex);
    final selectableCount = items.where((it) => it.canAdd).length;

    final selected = _selected.intersection({
      for (final item in items)
        if (item.canAdd) item.key,
    });
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppDimens.p16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppDimens.p12,
              crossAxisSpacing: AppDimens.p12,
              mainAxisExtent: categoryTemplateTileHeight(context),
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return TemplateItemTile(
                item: item,
                selected: selected.contains(item.key),
                onToggle: () {
                  if (_isAdding) return;
                  setState(
                    () => _selected = toggleFlatSelection(_selected, item.key),
                  );
                },
              );
            },
          ),
        ),
        TemplateBottomBar(
          selectedCount: selected.length,
          allSelected:
              selectableCount > 0 && selected.length == selectableCount,
          isAdding: _isAdding,
          isWriting: _isWriting,
          onToggleSelectAll: () => setState(() {
            final all = computeFlatSelectAll(items);
            // 已全选 → 取消全选；否则全选（只含未添加条目）
            _selected = selected.length == all.length ? {} : all;
          }),
          onAdd: () => _onAdd(l10n, items),
        ),
      ],
    );
  }

  /// 点击"添加"：二次确认 → 写入 categories 表
  Future<void> _onAdd(
    AppLocalizations l10n,
    List<CategoryTemplateItem> items,
  ) async {
    if (_isAdding) return;
    final plan = buildInsertPlan(allItems: items, selectedKeys: _selected);
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
