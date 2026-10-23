import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/features/categories/domain/category_manage_logic.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 分类迁移与周期账单共用的分类网格：父分类与子分类都可直接选择。
///
/// - 顶部搜索框：按分类显示名过滤（大小写不敏感）
/// - 排列顺序：先父后子——列完一个一级分类及其全部二级分类，再列下一个
/// - 每个分类标注层级：一级分类 / 二级·所属父分类名
///
/// 返回选中的目标分类 id；未选择直接关闭时返回 null。
Future<String?> showCategoryGridSelector(
  BuildContext context, {
  required List<({db.CategoryDisplay category, int transactionCount})>
  availableCategories,
  String? title,
  String? initialSelection,
  bool showTransactionCount = true,
}) {
  return showAppSheet<String>(
    context: context,
    child: _CategoryGridSelectorSheet(
      availableCategories: availableCategories,
      title: title,
      initialSelection: initialSelection,
      showTransactionCount: showTransactionCount,
    ),
  );
}

/// 迁移目标选择 BottomSheet 内容：搜索框 + 父子排序网格 + 确定按钮
class _CategoryGridSelectorSheet extends StatefulWidget {
  /// 可选的迁移目标分类（调用方已完成排除过滤）
  final List<({db.CategoryDisplay category, int transactionCount})>
  availableCategories;

  final String? title;
  final String? initialSelection;
  final bool showTransactionCount;

  const _CategoryGridSelectorSheet({
    required this.availableCategories,
    this.title,
    this.initialSelection,
    required this.showTransactionCount,
  });

  @override
  State<_CategoryGridSelectorSheet> createState() =>
      _CategoryGridSelectorSheetState();
}

class _CategoryGridSelectorSheetState
    extends State<_CategoryGridSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedTargetId;

  @override
  void initState() {
    super.initState();
    _selectedTargetId = widget.initialSelection;
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 父 → 子 有序排列：每个一级分类后紧跟其全部二级分类，再排下一个一级分类；
  /// 同级内部按 sortOrder 排序，与分类管理页展示顺序保持一致。
  List<({db.CategoryDisplay category, int transactionCount})>
  _buildOrderedList() => orderCategoriesParentFirst(widget.availableCategories);

  /// 按搜索词过滤（对本地化显示名做包含匹配）；命中项仍保持父 → 子 相对顺序
  List<({db.CategoryDisplay category, int transactionCount})> _filteredList() {
    final ordered = _buildOrderedList();
    if (_searchText.isEmpty) return ordered;
    return ordered.where((i) {
      final name = CategoryUtils.getDisplayName(
        i.category.name,
        context,
      ).toLowerCase();
      return name.contains(_searchText);
    }).toList();
  }

  /// 查子分类所属父分类的本地化显示名（层级标注"二级 · 父名"用）。
  /// 调用方的过滤规则保证候选中子分类的父必定同在候选内。
  String _parentDisplayName(String parentId) {
    for (final i in widget.availableCategories) {
      if (i.category.id == parentId) {
        return CategoryUtils.getDisplayName(i.category.name, context);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtered = _filteredList();

    return AppSheet(
      title: widget.title ?? l10n.categoryMigrateSelectTargetTitle,
      contentPadding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p4,
        AppDimens.p16,
        0,
      ),
      footer: AppPrimaryButton(
        label: l10n.commonConfirm,
        onPressed: _selectedTargetId == null
            ? null
            : () => Navigator.pop(context, _selectedTargetId),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 搜索框（样式对齐所属分类选择弹窗：圆角浅底 + 搜索图标 + 清除按钮）
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.categorySearchCategory,
              prefixIcon: Icon(
                AppIcons.search,
                size: AppDimens.icon16,
                color: AppTokens.iconTertiary(context),
              ),
              suffixIcon: _searchText.isNotEmpty
                  ? IconButton(
                      onPressed: () => _searchController.clear(),
                      icon: Icon(
                        AppIcons.close,
                        size: AppDimens.icon16,
                        color: AppTokens.iconTertiary(context),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppDimens.p12),
          // 分类网格（先父后子：列完一个分类的全部再列下个分类）
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppDimens.p12,
                runSpacing: AppDimens.p12,
                children: filtered.map((item) {
                  final isSelected = _selectedTargetId == item.category.id;
                  final category = item.category;
                  return _MigrateCategoryChip(
                    item: item,
                    showTransactionCount: widget.showTransactionCount,
                    isSelected: isSelected,
                    // 层级标注：一级分类 / 二级 · 所属父分类名
                    badgeLabel: category.level == 1
                        ? l10n.categoryTopLevelLabel
                        : l10n.categoryMigrateChildLabel(
                            _parentDisplayName(category.parentId ?? ''),
                          ),
                    onTap: () => setState(() {
                      _selectedTargetId = category.id;
                    }),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 迁移目标 BottomSheet 中的单个分类选项卡片
/// （管理页一级分类迁移与子分类弹窗迁移共用）
class _MigrateCategoryChip extends StatelessWidget {
  final ({db.CategoryDisplay category, int transactionCount}) item;

  /// 是否为当前选中的迁移目标
  final bool isSelected;
  final bool showTransactionCount;
  final VoidCallback onTap;

  /// 层级标注：一级分类显示"一级分类"，二级分类显示"二级 · 所属父分类名"
  final String badgeLabel;

  const _MigrateCategoryChip({
    required this.item,
    required this.showTransactionCount,
    required this.isSelected,
    required this.onTap,
    required this.badgeLabel,
  });

  /// 迁移候选沿用紧凑内容布局，选中时只绘制统一边框和角标。
  @override
  Widget build(BuildContext context) {
    final isSub = item.category.level == 2;

    return Semantics(
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 72,
            decoration: ShapeDecoration(
              color: AppTokens.surface(context),
              shape: selectableCardShape(
                context,
                selected: isSelected,
                unselectedBorder: BorderSide(
                  color: AppTokens.borderStrong(context),
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                  child: Column(
                    children: [
                      CategoryIconWidget(
                        category: item.category,
                        size: isSub ? AppDimens.icon16 : AppDimens.icon18,
                        showBackground: true,
                        backgroundSize: isSub ? 28 : AppDimens.p32,
                      ),
                      const SizedBox(height: AppDimens.p4),
                      Text(
                        CategoryUtils.getDisplayName(
                          item.category.name,
                          context,
                        ),
                        style: AppTextTokens.caption(
                          context,
                        ).copyWith(color: AppTokens.textPrimary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        badgeLabel,
                        style: AppTextTokens.caption(
                          context,
                        ).copyWith(color: AppTokens.textTertiary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (showTransactionCount)
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
                if (isSelected) const SelectableCardCheckBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
