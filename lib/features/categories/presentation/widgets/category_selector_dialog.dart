import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_grid_selector.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 分类过滤器回调类型
/// 返回 true 表示该分类可选，返回 false 表示不可选（置灰）
typedef CategoryFilterCallback =
    Future<bool> Function(CategoryDisplay category);

/// 所属分类候选沿用明确身份与关系过滤，模板场景使用紧凑网格。
Future<CategoryDisplay?> showParentCategorySelector(
  BuildContext context, {
  CategoryDisplay? initialSelection,
  List<String>? excludeIds,
  CategoryFilterCallback? categoryFilter,
  String? ledgerId,
  CategoryActions? categoryActions,
  bool compact = false,
  String? title,
}) async {
  try {
    final CategoryActions actions =
        categoryActions ??
        ProviderScope.containerOf(
          context,
        ).read<CategoryActions>(categoryActionsProvider);
    final categories = await actions.getTopLevel('expense', ledgerId: ledgerId);
    final available = <CategoryDisplay>[];
    for (final category in categories) {
      if (excludeIds?.contains(category.id) ?? false) continue;
      if (categoryFilter != null && !await categoryFilter(category)) continue;
      available.add(category);
    }
    if (!context.mounted) return null;
    final selected = await showCategoryGridSelector(
      context,
      availableCategories: [
        for (final category in available)
          (category: category, transactionCount: 0),
      ],
      initialSelection: initialSelection?.id,
      title: title ?? AppLocalizations.of(context).categorySelectParentTitle,
      showTransactionCount: false,
      compact: compact,
    );
    if (selected == null) return null;
    return available.firstWhere((category) => category.id == selected);
  } catch (error, stack) {
    logger.error(
      'CategorySelector',
      '读取所属分类候选失败',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
