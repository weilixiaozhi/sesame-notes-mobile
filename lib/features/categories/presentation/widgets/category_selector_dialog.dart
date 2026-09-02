import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 分类过滤器回调类型
/// 返回 true 表示该分类可选，返回 false 表示不可选（置灰）
typedef CategoryFilterCallback =
    Future<bool> Function(CategoryDisplay category);

/// 显示分类选择器
///
/// [type] 分类类型：全局仅支出模式，固定为 'expense'
/// [currentCategoryId] 当前选中的分类ID（用于高亮显示）
/// [includeParentCategories] 是否包含有子分类的一级分类
/// [excludeNames] 排除的分类名称列表
/// [excludeIds] 排除的分类ID列表
/// [showTransactionCount] 是否显示交易笔数
/// [ledgerId] 如果要显示笔数，需要账本ID
/// [expandChildrenByDefault] 是否默认展开二级分类
/// [onlyTopLevel] 是否只显示一级分类（不显示二级分类）
/// [categoryFilter] 自定义过滤器，决定分类是否可选
/// [title] 自定义标题
Future<CategoryDisplay?> showCategorySelector(
  BuildContext context, {
  required String type,
  String? currentCategoryId,
  bool includeParentCategories = false,
  List<String>? excludeNames,
  List<String>? excludeIds,
  bool showTransactionCount = false,
  String? ledgerId,
  bool expandChildrenByDefault = false,
  bool onlyTopLevel = false,
  CategoryFilterCallback? categoryFilter,
  String? title,
}) {
  return showDialog<CategoryDisplay>(
    context: context,
    builder: (context) => CategorySelectorDialog(
      type: type,
      currentCategoryId: currentCategoryId,
      includeParentCategories: includeParentCategories,
      excludeNames: excludeNames,
      excludeIds: excludeIds,
      showTransactionCount: showTransactionCount,
      ledgerId: ledgerId,
      expandChildrenByDefault: expandChildrenByDefault,
      onlyTopLevel: onlyTopLevel,
      categoryFilter: categoryFilter,
      title: title,
    ),
  );
}

/// 显示选择所属分类的 BottomSheet（用于分类编辑页选择父分类）
///
/// 内容结构：
/// - 顶部标题"选择所属分类"
/// - 搜索框（搜索分类名）
/// - 分类列表（仅一级分类，每行含图标 + 名称 + 选中勾，行间细分割线分隔）
/// - 底部取消/确定按钮
///
/// [initialSelection] 进入 sheet 时已选中的父分类（用户不改动则原样返回）
/// [excludeIds] 需要排除的分类 ID 列表（如当前编辑的分类自身）
/// [categoryFilter] 自定义过滤器，返回 false 的分类不显示
///
/// 返回用户确认选择的分类；取消则返回 null。
Future<CategoryDisplay?> showParentCategorySelector(
  BuildContext context, {
  CategoryDisplay? initialSelection,
  List<String>? excludeIds,
  CategoryFilterCallback? categoryFilter,
}) {
  return showAppSheet<CategoryDisplay>(
    context: context,
    child: _ParentCategorySelectorSheet(
      initialSelection: initialSelection,
      excludeIds: excludeIds,
      categoryFilter: categoryFilter,
    ),
  );
}

/// 选择所属分类 BottomSheet 内容组件
class _ParentCategorySelectorSheet extends ConsumerStatefulWidget {
  final CategoryDisplay? initialSelection;
  final List<String>? excludeIds;
  final CategoryFilterCallback? categoryFilter;

  const _ParentCategorySelectorSheet({
    this.initialSelection,
    this.excludeIds,
    this.categoryFilter,
  });

  @override
  ConsumerState<_ParentCategorySelectorSheet> createState() =>
      _ParentCategorySelectorSheetState();
}

class _ParentCategorySelectorSheetState
    extends ConsumerState<_ParentCategorySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  /// 用户在 sheet 内临时选中的分类（点击行高亮，点确定才返回）
  /// 初始化为 [widget.initialSelection]，用户不改动则原样返回
  late CategoryDisplay? _tempSelected;

  /// 过滤器结果缓存，避免每次 build 都重新异步计算
  Map<String, bool> _filterResults = {};

  /// 已加载的分类列表缓存（只在首次 build 时异步加载一次，
  /// 搜索过滤在内存中进行，避免每次按键都查 DB）
  List<CategoryDisplay>? _cachedCategories;
  Future<List<CategoryDisplay>>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _tempSelected = widget.initialSelection;
    _loadFuture = _loadCategories();
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

  /// 异步加载所有可选的一级分类
  /// 过滤逻辑：排除指定 ID → 应用 categoryFilter → 应用搜索文本
  Future<List<CategoryDisplay>> _loadCategories() async {
    // 全局仅支出模式，只查 expense 一级分类
    final categories = await ref
        .read(categoryActionsProvider)
        .getTopLevel('expense');

    // 排除指定 ID
    var filtered = categories.where((c) {
      return !(widget.excludeIds?.contains(c.id) ?? false);
    }).toList();

    // 应用自定义过滤器（如：有子分类 OR 无交易记录）
    if (widget.categoryFilter != null) {
      final results = <String, bool>{};
      for (final c in filtered) {
        results[c.id] = await widget.categoryFilter!(c);
      }
      _filterResults = results;
      filtered = filtered.where((c) => _filterResults[c.id] ?? true).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return AppSheet(
      title: l10n.categorySelectParentTitle,
      footer: AppSheetFilledButton(
        label: l10n.commonConfirm,
        onPressed: () => Navigator.pop(context, _tempSelected),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 搜索框 ──
          Container(
            decoration: BoxDecoration(
              color: AppTokens.surfaceSecondary(context),
              borderRadius: BorderRadius.circular(AppDimens.radius16),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.categorySearchCategory,
                hintStyle: TextStyle(color: AppTokens.textSecondary(context)),
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
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppDimens.p12,
                  horizontal: AppDimens.p12,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.p8),
          // ── 分类列表 ──
          Expanded(
            child: FutureBuilder<List<CategoryDisplay>>(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 缓存首次加载结果，后续 rebuild 直接复用
                _cachedCategories ??= snapshot.data!;
                final categories = _cachedCategories!;

                // 应用搜索过滤（内存中进行，无需重新查 DB）
                final filtered = _searchText.isEmpty
                    ? categories
                    : categories.where((c) {
                        final name = CategoryUtils.getDisplayName(
                          c.name,
                          context,
                        ).toLowerCase();
                        return name.contains(_searchText);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.commonEmpty,
                      style: TextStyle(color: AppTokens.textTertiary(context)),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p16,
                  ),
                  itemCount: filtered.length,
                  // 行间细分割线，区分各分类内容区
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppTokens.divider(context),
                  ),
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final isSelected = _tempSelected?.id == category.id;

                    return _ParentCategoryTile(
                      category: category,
                      isSelected: isSelected,
                      primaryColor: primaryColor,
                      onTap: () {
                        setState(() {
                          _tempSelected = category;
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 所属分类选择列表项
class _ParentCategoryTile extends StatelessWidget {
  final CategoryDisplay category;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ParentCategoryTile({
    required this.category,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius4),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.p4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        decoration: BoxDecoration(
          // 选中行：主题色 8% 背景 + 主题色边框
          color: isSelected
              ? primaryColor.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radius4),
        ),
        child: Row(
          children: [
            // 32x32 图标容器（主题色 10% 背景，圆角 16）
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius16),
              ),
              child: CategoryIconWidget(
                category: category,
                size: AppDimens.icon16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: AppDimens.p12),
            // 分类名（无副标题"一级分类"标签，行级区分靠列表分割线）
            Expanded(
              child: Text(
                CategoryUtils.getDisplayName(category.name, context),
                style: AppTextTokens.title(context).copyWith(
                  color: isSelected
                      ? primaryColor
                      : AppTokens.textPrimary(context),
                ),
              ),
            ),
            // 选中勾
            if (isSelected)
              Icon(AppIcons.check, size: AppDimens.icon16, color: primaryColor),
          ],
        ),
      ),
    );
  }
}

class CategorySelectorDialog extends ConsumerStatefulWidget {
  final String type;
  final String? currentCategoryId;
  final bool includeParentCategories;
  final List<String>? excludeNames;
  final List<String>? excludeIds;
  final bool showTransactionCount;
  final String? ledgerId;
  final bool expandChildrenByDefault;
  final bool onlyTopLevel;
  final CategoryFilterCallback? categoryFilter;
  final String? title;

  const CategorySelectorDialog({
    super.key,
    required this.type,
    this.currentCategoryId,
    this.includeParentCategories = false,
    this.excludeNames,
    this.excludeIds,
    this.showTransactionCount = false,
    this.ledgerId,
    this.expandChildrenByDefault = false,
    this.onlyTopLevel = false,
    this.categoryFilter,
    this.title,
  });

  @override
  ConsumerState<CategorySelectorDialog> createState() =>
      _CategorySelectorDialogState();
}

class _CategorySelectorDialogState
    extends ConsumerState<CategorySelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  Map<String, int> _transactionCounts = {};
  Map<String, bool> _categoryFilterResults = {}; // 存储过滤器结果
  /// 分类加载 future 缓存：首次 / 业务数据变化时重建一次，
  /// 搜索与父级 setState 只做内存过滤，避免每次按键都全量重查数据库。
  Future<List<CategoryDisplay>>? _categoriesFuture;
  Object? _loadedDataChangeSignal;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
    if (widget.showTransactionCount) {
      _loadTransactionCounts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载所有分类
  Future<List<CategoryDisplay>> _loadAllCategories() async {
    final actions = ref.read(categoryActionsProvider);

    // 全局仅支出模式，只查 expense 分类。
    // 共享账本 Editor 直接由用例层替换为 Owner 镜像，避免页面先做 N+1 主表查询。
    final allCategories = await actions.filterForPicker(
      ledgerId: widget.ledgerId,
      kind: 'expense',
      topLevelOnly: widget.onlyTopLevel,
    );

    // 如果有过滤器，计算每个分类的可选状态
    if (widget.categoryFilter != null) {
      final filterResults = <String, bool>{};
      for (final category in allCategories) {
        filterResults[category.id] = await widget.categoryFilter!(category);
      }
      if (mounted) {
        setState(() {
          _categoryFilterResults = filterResults;
        });
      }
    }

    return allCategories;
  }

  /// 加载每个分类的交易笔数
  Future<void> _loadTransactionCounts() async {
    try {
      // 获取交易（ledgerId 可选，不传则获取所有账本）
      final transactions = await ref
          .read(categoryActionsProvider)
          .transactionsWithCategory(ledgerId: widget.ledgerId);

      // 统计每个分类的笔数
      final counts = <String, int>{};
      for (final item in transactions) {
        if (item.category != null) {
          counts[item.category!.id] = (counts[item.category!.id] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _transactionCounts = counts;
        });
      }
    } catch (e) {
      // 忽略错误
    }
  }

  /// 构建分类分组数据
  List<_CategoryGroup> _buildCategoryGroups(
    List<CategoryDisplay> allCategories,
  ) {
    // 全局仅支出模式，按 kind 过滤（type 固定为 'expense'）。
    final typedCategories = allCategories
        .where((c) => c.kind == widget.type)
        .toList();

    // 应用排除规则
    final filteredCategories = typedCategories.where((c) {
      // 排除指定ID
      if (widget.excludeIds?.contains(c.id) ?? false) return false;

      // 排除指定名称
      if (widget.excludeNames?.contains(c.name) ?? false) return false;

      return true;
    }).toList();

    // 分离父分类和子分类
    final parentCategories = <CategoryDisplay>[];
    final childCategories = <CategoryDisplay>[];
    final parentIds = <String>{};

    // 第一轮：找出所有父分类
    for (final category in filteredCategories) {
      if (category.parentId != null) {
        parentIds.add(category.parentId!);
        childCategories.add(category);
      }
    }

    // 第二轮：获取所有父分类
    for (final category in filteredCategories) {
      if (category.parentId == null) {
        parentCategories.add(category);
      }
    }

    // 构建分组
    final groups = <_CategoryGroup>[];

    for (final parent in parentCategories) {
      final hasChildren = parentIds.contains(parent.id);
      final children = childCategories
          .where((c) => c.parentId == parent.id)
          .toList();

      // 判断父分类是否可选
      bool isParentSelectable = !hasChildren || widget.includeParentCategories;
      // 如果有过滤器，应用过滤器结果
      if (widget.categoryFilter != null &&
          _categoryFilterResults.containsKey(parent.id)) {
        isParentSelectable =
            isParentSelectable && _categoryFilterResults[parent.id]!;
      }

      // 应用搜索过滤
      if (_searchText.isNotEmpty) {
        final parentName = CategoryUtils.getDisplayName(
          parent.name,
          context,
        ).toLowerCase();
        final parentMatches = parentName.contains(_searchText);

        final matchedChildren = children.where((c) {
          final childName = CategoryUtils.getDisplayName(
            c.name,
            context,
          ).toLowerCase();
          return childName.contains(_searchText);
        }).toList();

        // 如果父分类匹配，显示所有子分类
        if (parentMatches) {
          groups.add(
            _CategoryGroup(
              parent: parent,
              children: children,
              isExpanded: true,
              isParentSelectable: isParentSelectable,
            ),
          );
        } else if (matchedChildren.isNotEmpty) {
          // 如果只有子分类匹配，只显示匹配的子分类
          groups.add(
            _CategoryGroup(
              parent: parent,
              children: matchedChildren,
              isExpanded: true,
              isParentSelectable: isParentSelectable,
            ),
          );
        }
      } else {
        // 无搜索时，显示所有
        // 判断是否需要展开：如果当前选中的是子分类且属于该父分类，则展开
        bool shouldExpand = widget.expandChildrenByDefault;
        if (widget.currentCategoryId != null && !shouldExpand) {
          // 检查是否有子分类被选中
          shouldExpand = children.any((c) => c.id == widget.currentCategoryId);
        }

        groups.add(
          _CategoryGroup(
            parent: parent,
            children: children,
            isExpanded: shouldExpand,
            isParentSelectable: isParentSelectable,
          ),
        );
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    // 本地写入或云端 pull 都会更新统一数据信号；仅在信号变化时
    // 重建分类加载 future（其余 rebuild 走缓存），
    // 搜索 / 父级 setState 只做内存过滤，不全量重查数据库。
    final dataChangeSignal = ref.watch(dataChangeSignalProvider);
    if (_categoriesFuture == null ||
        dataChangeSignal != _loadedDataChangeSignal) {
      _categoriesFuture = _loadAllCategories();
      _loadedDataChangeSignal = dataChangeSignal;
    }
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius16),
      ),
      backgroundColor: AppTokens.scaffoldBackground(context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppTokens.scaffoldBackground(context),
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
        child: Column(
          children: [
            // 顶部栏
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
                vertical: AppDimens.p12,
              ),
              decoration: BoxDecoration(
                color: AppTokens.surfaceElevated(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radius16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppTokens.divider(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title ?? l10n.categoryExpense,
                          style: AppTextTokens.boldTitle(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTokens.textPrimary(context),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          AppIcons.close,
                          color: AppTokens.iconPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p12),
                  // 搜索框
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: l10n.commonSearch,
                      prefixIcon: Icon(
                        AppIcons.search,
                        color: AppTokens.iconTertiary(context),
                      ),
                      suffixIcon: _searchText.isNotEmpty
                          ? IconButton(
                              onPressed: () => _searchController.clear(),
                              icon: Icon(
                                AppIcons.close,
                                color: AppTokens.iconTertiary(context),
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p12,
                        horizontal: AppDimens.p16,
                      ),
                      filled: true,
                      fillColor: AppTokens.surfaceInput(context),
                    ),
                  ),
                ],
              ),
            ),
            // 分类列表
            Expanded(
              child: FutureBuilder<List<CategoryDisplay>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final groups = _buildCategoryGroups(snapshot.data!);

                  if (groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.searchOff,
                            size: 64,
                            color: AppTokens.textTertiary(context),
                          ),
                          const SizedBox(height: AppDimens.p16),
                          Text(
                            _searchText.isNotEmpty
                                ? l10n.commonEmpty
                                : l10n.categoryEmpty,
                            style: AppTextTokens.title(
                              context,
                            ).copyWith(color: AppTokens.textTertiary(context)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _CategoryGroupItem(
                        group: group,
                        currentCategoryId: widget.currentCategoryId,
                        showTransactionCount: widget.showTransactionCount,
                        transactionCounts: _transactionCounts,
                        primaryColor: Theme.of(context).colorScheme.primary,
                        onCategorySelected: (category) {
                          Navigator.pop(context, category);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类分组数据
class _CategoryGroup {
  final CategoryDisplay parent;
  final List<CategoryDisplay> children;
  final bool isExpanded;
  final bool isParentSelectable;

  _CategoryGroup({
    required this.parent,
    required this.children,
    this.isExpanded = false,
    required this.isParentSelectable,
  });
}

/// 分类分组项组件
class _CategoryGroupItem extends StatefulWidget {
  final _CategoryGroup group;
  final String? currentCategoryId;
  final bool showTransactionCount;
  final Map<String, int> transactionCounts;
  final Color primaryColor;
  final Function(CategoryDisplay) onCategorySelected;

  const _CategoryGroupItem({
    required this.group,
    this.currentCategoryId,
    required this.showTransactionCount,
    required this.transactionCounts,
    required this.primaryColor,
    required this.onCategorySelected,
  });

  @override
  State<_CategoryGroupItem> createState() => _CategoryGroupItemState();
}

class _CategoryGroupItemState extends State<_CategoryGroupItem> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.group.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.group.children.isNotEmpty;
    final isParentSelectable = widget.group.isParentSelectable;

    return Column(
      children: [
        // 父分类
        _CategoryTile(
          category: widget.group.parent,
          isSelected: widget.currentCategoryId == widget.group.parent.id,
          showTransactionCount: widget.showTransactionCount,
          transactionCount:
              widget.transactionCounts[widget.group.parent.id] ?? 0,
          primaryColor: widget.primaryColor,
          isParent: hasChildren,
          isExpanded: _isExpanded,
          isSelectable: isParentSelectable,
          onTap: () {
            if (hasChildren) {
              // 如果有子分类，总是展开/收起
              setState(() {
                _isExpanded = !_isExpanded;
              });
            } else if (isParentSelectable) {
              // 如果是可选的普通分类（无子分类），则选择
              widget.onCategorySelected(widget.group.parent);
            }
          },
        ),
        // 子分类（如果展开）
        if (hasChildren && _isExpanded)
          ...widget.group.children.map((child) {
            return _CategoryTile(
              category: child,
              isSelected: widget.currentCategoryId == child.id,
              showTransactionCount: widget.showTransactionCount,
              transactionCount: widget.transactionCounts[child.id] ?? 0,
              primaryColor: widget.primaryColor,
              isChild: true,
              onTap: () {
                widget.onCategorySelected(child);
              },
            );
          }),
      ],
    );
  }
}

/// 分类项组件
class _CategoryTile extends StatelessWidget {
  final CategoryDisplay category;
  final bool isSelected;
  final bool showTransactionCount;
  final int transactionCount;
  final Color primaryColor;
  final bool isParent;
  final bool isChild;
  final bool isExpanded;
  final bool isSelectable;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    this.isSelected = false,
    required this.showTransactionCount,
    required this.transactionCount,
    required this.primaryColor,
    this.isParent = false,
    this.isChild = false,
    this.isExpanded = false,
    this.isSelectable = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 不可选时显示为半透明
    final opacity = !isSelectable ? 0.5 : 1.0;

    return InkWell(
      onTap: isSelectable || isParent ? onTap : null, // 不可选且非父分类时禁用点击
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            // 选中状态背景色（通栏）
            color: isSelected ? primaryColor.withValues(alpha: 0.08) : null,
            border: Border(
              bottom: BorderSide(color: AppTokens.divider(context), width: 0.5),
            ),
          ),
          child: Padding(
            // 子分类添加左边距，父分类正常边距
            padding: EdgeInsets.fromLTRB(
              isChild ? 56 : AppDimens.p16, // 左边距：子分类56，父分类AppDimens.p16
              AppDimens.p12,
              AppDimens.p16,
              AppDimens.p12,
            ),
            child: Row(
              children: [
                // 分类图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radius8),
                    // 选中状态添加边框
                    border: isSelected
                        ? Border.all(color: primaryColor, width: 1.5)
                        : null,
                  ),
                  child: CategoryIconWidget(
                    category: category,
                    size: AppDimens.icon22,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: AppDimens.p12),
                // 分类名称
                Expanded(
                  child: Text(
                    CategoryUtils.getDisplayName(category.name, context),
                    style: TextStyle(
                      fontSize: isChild ? 15 : 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : (isChild ? FontWeight.normal : FontWeight.w400),
                      color: isSelected
                          ? primaryColor
                          : AppTokens.textPrimary(context),
                    ),
                  ),
                ),
                // 交易笔数
                if (showTransactionCount && transactionCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p8,
                      vertical: AppDimens.p4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.surface(context),
                      borderRadius: BorderRadius.circular(AppDimens.radius12),
                    ),
                    child: Text(
                      AppLocalizations.of(
                        context,
                      ).categoryMigrationTransactionLabel(transactionCount),
                      style: AppTextTokens.label(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                  ),
                // 选中图标
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: AppDimens.p8),
                    child: Icon(
                      AppIcons.checkCircle,
                      color: primaryColor,
                      size: AppDimens.icon20,
                    ),
                  ),
                // 展开/收起图标（父分类总是显示）
                if (isParent)
                  Padding(
                    padding: EdgeInsets.only(
                      left: isSelected ? 0 : AppDimens.p8,
                    ),
                    child: Icon(
                      isExpanded ? AppIcons.chevronUp : AppIcons.chevronDown,
                      color: AppTokens.iconTertiary(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
