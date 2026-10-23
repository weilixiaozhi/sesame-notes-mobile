import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/category_grid_item.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';

/// 根据图标和当前字号确定行高，父项与子项均保留完整标签。
double _categoryRowHeight(BuildContext context, {bool child = false}) {
  final minimum = child
      ? AppDimens.categoryPickerSubcategoryRowMinHeight
      : AppDimens.categoryPickerRowMinHeight;
  final painter = TextPainter(
    text: TextSpan(
      text: '分类Ag',
      style: AppTextTokens.label(context).copyWith(fontWeight: FontWeight.w600),
    ),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
  );
  try {
    // 使用实际字体行高并向上取整，字形回退与缩放的小数高度不会裁切标签。
    painter.layout();
    return ((child ? AppDimens.p36 : AppDimens.icon40) +
            AppDimens.p4 +
            painter.height +
            AppDimens.p3 * 2)
        .ceilToDouble()
        .clamp(minimum, double.infinity);
  } catch (error, stack) {
    logger.error('CategoryGridSection', '测量分类标签高度失败', error, stack);
    return minimum;
  } finally {
    painter.dispose();
  }
}

/// 分类网格区：一级分类 5 列网格 + 二级分类原地展开卡片 + 底部「编辑分类」入口。
///
/// - 父分类 5 列网格，圆角方形图标 40×40。
/// - **选中含子分类的父项时，其子分类区域必须自动展开**（不 toggle）。
///   从「早餐」切到「午餐」再切回「早餐」，早餐子分类必须重新自动展开。
/// - 选择无子分类的父分类时，当前子分类区域收起。
/// - 父分类本身就是可提交分类，不强制选择子分类。
/// - 子分类容器：圆角 20px、最大可视高度 200px、内部可滚动、隐藏滚动条。
/// - 底部「编辑分类」入口：Edit3 图标 + 文本。
///
/// 分类树复用当前账本的预热订阅，数据写入由数据库监听自动更新。
class CategoryGridSection extends ConsumerStatefulWidget {
  /// 固定账本绑定编辑器上下文，不随首页当前本变化替换目录。
  final String? ledgerId;

  /// 已选分类被移除或账本查询失败时通知编辑器阻断保存。
  final VoidCallback? onSelectionUnavailable;

  /// 初始选中分类 ID（UUID；编辑模式回显 / quickAdd 预选）
  final String? initialSelectedId;

  /// 分类选中回调，上报给父 sheet
  final ValueChanged<CategoryDisplay> onCategorySelected;

  /// 父项与子项均可提交，初始子项会自动展开所属父项。
  const CategoryGridSection({
    super.key,
    required this.onCategorySelected,
    this.initialSelectedId,
    this.ledgerId,
    this.onSelectionUnavailable,
  });

  /// 分类区独立持有选择、展开和滚动状态。
  @override
  ConsumerState<CategoryGridSection> createState() =>
      _CategoryGridSectionState();
}

class _CategoryGridSectionState extends ConsumerState<CategoryGridSection> {
  String? _expandedCategoryId; // 当前展开的一级分类 ID
  String? _selectedId; // 当前点击的分类（用于高亮）
  bool _initialized = false; // 初始选中/展开/滚动是否已执行（一次性）
  CategoryPickerTree? _reportedTree;
  bool _selectionUnavailable = false;
  final _scrollController = ScrollController(); // 一级列表独立滚动。

  /// 首帧仅记录标识，分类树就绪后初始化展开状态。
  @override
  void initState() {
    super.initState();
    // 编辑模式/预选：先高亮初始分类；展开父级与滚动定位依赖分类树数据，
    // 在首个数据帧的 _initOnce 中从树同步解析（不单独反查 DB）。
    _selectedId = widget.initialSelectedId;
  }

  /// 宿主显式切本时重置分类状态，避免另一账本沿用旧标识。
  @override
  void didUpdateWidget(covariant CategoryGridSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ledgerId != widget.ledgerId) {
      _initialized = false;
      _expandedCategoryId = null;
      _selectedId = widget.initialSelectedId;
      _reportedTree = null;
      _selectionUnavailable = false;
    }
  }

  /// 分类区关闭时释放独立滚动状态。
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 回调异常记录完整堆栈，保留现有金额和备注草稿。
  void _notifySelection(CategoryDisplay category) {
    try {
      widget.onCategorySelected(category);
    } catch (error, stack) {
      _report('应用分类选择失败', error, stack);
    }
  }

  /// 处理一级分类点击。
  ///
  /// 规则：
  /// - 含子分类：直接选中该父分类（父分类本身可提交），并**始终展开**其子分类区域。
  ///   重复点击同一含子分类父项时，子分类保持展开（不 toggle）。
  /// - 无子分类：直接选中，关闭已展开的子分类区域。
  void _onTopCategoryTap(
    CategoryDisplay topCat,
    List<CategoryDisplay> children,
  ) {
    final hasChildren = children.isNotEmpty;
    setState(() {
      _selectedId = topCat.id;
      _selectionUnavailable = false;
      // 含子分类 → 始终展开；无子分类 → 收起
      _expandedCategoryId = hasChildren ? topCat.id : null;
    });
    _notifySelection(topCat);
  }

  /// 查询和重试绑定同一本，加载和失败均保留分类管理入口。
  @override
  Widget build(BuildContext context) {
    final treeAsync = widget.ledgerId == null
        ? ref.watch(categoryPickerTreeProvider('expense'))
        : ref.watch(
            categoryPickerTreeForLedgerProvider((
              ledgerId: widget.ledgerId!,
              type: 'expense',
            )),
          );
    return treeAsync.when(
      loading: () => _placeholder(context, const CircularProgressIndicator()),
      error: (error, stack) {
        logger.error('CategoryGridSection', '读取记账分类失败', error, stack);
        _notifyUnavailable();
        return _placeholder(context, AppLoadError(onRetry: _retryCategories));
      },
      data: (tree) => _buildGrid(context, tree),
    );
  }

  /// 空态和错误内容允许在短屏滚动，管理入口始终可见。
  Widget _placeholder(BuildContext context, Widget status) =>
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              status,
              const SizedBox(height: AppDimens.p12),
              _buildEditCategoryEntry(context),
            ],
          ),
        ),
      );

  /// 一级分类每行个数。行分组循环、网格列数、滚动定位共用此常量，保证三者一致。
  static const int _kColumns = 5;

  /// 用分类树数据构建网格（一级 5 列 + 展开的二级卡片 + 编辑入口）。
  Widget _buildGrid(BuildContext context, CategoryPickerTree tree) {
    final topLevelCategories = tree.topLevel;
    final subCategoriesMap = tree.children;

    if (topLevelCategories.isEmpty) {
      _notifyUnavailable();
      // 分类为空时，仅提示「暂无分类」无法引导用户进入分类管理，
      // 故在此追加一条文字链复用底部「编辑分类」入口跳转分类管理页，
      // 让用户能直接去新增分类，避免在记账页卡死。
      return AppEmpty(
        text: AppLocalizations.of(context).categoryEmpty,
        action: _buildEditCategoryEntry(context),
      );
    }

    _initOnce(tree);
    _publishSelection(tree);
    final rowHeight = _categoryRowHeight(context);

    final displayItems = <Widget>[];

    // 按每 _kColumns 个一组显示一级分类
    for (int i = 0; i < topLevelCategories.length; i += _kColumns) {
      final endIndex = (i + _kColumns).clamp(0, topLevelCategories.length);
      final rowItems = topLevelCategories.sublist(i, endIndex);

      displayItems.add(
        GridView.builder(
          key: ValueKey('category-parent-row-${i ~/ _kColumns}'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _kColumns,
            // 父分类水平间距 8px
            crossAxisSpacing: AppDimens.p8,
            // 父分类垂直行距 12px
            mainAxisSpacing: AppDimens.p12,
            // 行高由图标、间距和实际字体测量确定，窄屏下仍保留完整内容。
            mainAxisExtent: rowHeight,
          ),
          itemCount: rowItems.length,
          itemBuilder: (context, index) {
            final topCat = rowItems[index];
            final children = subCategoriesMap[topCat.id] ?? [];
            final hasChildren = children.isNotEmpty;

            return CategoryGridItem(
              key: ValueKey('category-item-${topCat.id}'),
              category: topCat,
              selected: _selectedId == topCat.id,
              hasChildren: hasChildren,
              expanded: _expandedCategoryId == topCat.id,
              onTap: () => _onTopCategoryTap(topCat, children),
            );
          },
        ),
      );

      // 检查该行是否有展开的分类，有则插入二级分类卡片
      for (int j = 0; j < rowItems.length; j++) {
        final topCat = rowItems[j];
        final children = subCategoriesMap[topCat.id] ?? [];
        final hasChildren = children.isNotEmpty;

        if (_expandedCategoryId == topCat.id && hasChildren) {
          // 子分类卡片距离父分类行：8px
          displayItems.add(const SizedBox(height: AppDimens.p8));
          displayItems.add(
            _SubcategorySelectorCard(
              key: ValueKey('category-subcategory-card-${topCat.id}'),
              subCategories: children,
              selectedId: _selectedId,
              onSubCategoryTap: (cat) {
                setState(() {
                  _selectedId = cat.id;
                  _selectionUnavailable = false;
                });
                _notifySelection(cat);
              },
            ),
          );
          break; // 每行只展开一个
        }
      }

      if (i + _kColumns < topLevelCategories.length) {
        // 父分类两行之间：12px
        displayItems.add(const SizedBox(height: AppDimens.p12));
      }
    }

    // 底部「编辑分类」入口（Edit3 图标 + 文本），入口上方留白 18px
    displayItems.add(const SizedBox(height: AppDimens.icon18));
    displayItems.add(_buildEditCategoryEntry(context));
    displayItems.add(const SizedBox(height: AppDimens.p12));

    // 整个分类区独立滚动、隐藏滚动条
    return ScrollConfiguration(
      behavior: const _NoScrollbarBehavior(),
      child: ListView(
        key: const ValueKey('category-grid-viewport'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppDimens.p12,
          AppDimens.p12,
          AppDimens.p12,
          AppDimens.p12,
        ),
        children: displayItems,
      ),
    );
  }

  /// 分类首帧同步高亮默认项，编辑预选则展开父级并定位其所在行。
  void _initOnce(CategoryPickerTree tree) {
    if (_initialized) return;
    _initialized = true;

    final initialId = widget.initialSelectedId;
    if (initialId == null) {
      if (_selectedId == null && tree.topLevel.isNotEmpty) {
        final first = tree.topLevel.first;
        _selectedId = first.id;
        _expandedCategoryId = (tree.children[first.id] ?? []).isEmpty
            ? null
            : first.id;
      }
      return;
    }

    // 编辑/预选：从树同步解析父级（一级 → 仅高亮；二级 → 展开其父分类）。
    String? parentId;
    if (tree.children[initialId]?.isNotEmpty == true) {
      parentId = initialId;
    } else if (!tree.topLevel.any((c) => c.id == initialId)) {
      for (final entry in tree.children.entries) {
        if (entry.value.any((c) => c.id == initialId)) {
          parentId = entry.key;
          break;
        }
      }
    }
    if (parentId != null) {
      // 首帧 build 进行中直接赋值字段（本帧即生效，无需 setState）
      _expandedCategoryId = parentId;
    }

    final index = tree.topLevel.indexWhere(
      (category) => category.id == (parentId ?? initialId),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (!mounted || !_scrollController.hasClients || index < 0) return;
        final offset =
            (index ~/ _kColumns) *
            (_categoryRowHeight(context) + AppDimens.p12);
        _scrollController.jumpTo(
          offset.clamp(0, _scrollController.position.maxScrollExtent),
        );
      } catch (error, stack) {
        _report('定位预选分类失败', error, stack);
      }
    });
  }

  /// 默认项和编辑预选直接使用树内节点，数据更新后刷新同一标识的分类快照。
  void _publishSelection(CategoryPickerTree tree) {
    if (identical(_reportedTree, tree)) return;
    _reportedTree = tree;
    final selected = [
      ...tree.topLevel,
      for (final parent in tree.topLevel)
        ...tree.children[parent.id] ?? const <CategoryDisplay>[],
    ].where((category) => category.id == _selectedId).firstOrNull;
    if (selected == null) {
      _notifyUnavailable();
      return;
    }
    _selectionUnavailable = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          identical(_reportedTree, tree) &&
          _selectedId == selected.id) {
        _notifySelection(selected);
      }
    });
  }

  /// 查询失败或树已确定缺少选中项时，下一帧清空编辑器的可提交分类。
  void _notifyUnavailable() {
    if (_selectionUnavailable) return;
    _selectionUnavailable = true;
    _reportedTree = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (mounted && _selectionUnavailable) {
          widget.onSelectionUnavailable?.call();
        }
      } catch (error, stack) {
        _report('更新分类不可用状态失败', error, stack);
      }
    });
  }

  /// 底部文字入口沿用固定账本的共享权限，协作者只能选择所有者分类。
  Widget _buildEditCategoryEntry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ledger = widget.ledgerId == null
        ? ref.watch(currentLedgerDisplayProvider).value
        : ref.watch(ledgerDisplayByIdProvider(widget.ledgerId!)).value;
    // 共享账本判定:成员数 > 1 视为共享(与数据层口径一致)。
    final isEditorInShared =
        ledger != null && ledger.memberCount > 1 && ledger.myRole != 'owner';
    return Center(
      child: Tooltip(
        message: isEditorInShared
            ? l10n.txEditCategoryReadOnly
            : l10n.txEditCategory,
        child: TextButton.icon(
          key: const ValueKey('category-edit-entry'),
          onPressed: isEditorInShared ? null : _openCategoryManagement,
          style: TextButton.styleFrom(
            foregroundColor: AppTokens.primary(context),
            disabledForegroundColor: AppTokens.textDisabled(context),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p16,
              vertical: AppDimens.p8,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: AppTextTokens.label(context),
          ),
          icon: const Icon(AppIcons.edit, size: AppDimens.icon16),
          label: Text(
            isEditorInShared
                ? l10n.txEditCategoryReadOnly
                : l10n.txEditCategory,
          ),
        ),
      ),
    );
  }

  /// 只重试当前账本的目录，保留已选择标识和编辑器草稿。
  void _retryCategories() {
    try {
      final ledgerId = widget.ledgerId;
      if (ledgerId == null) {
        ref.invalidate(categoryPickerTreeProvider('expense'));
      } else {
        ref.invalidate(
          categoryPickerTreeForLedgerProvider((
            ledgerId: ledgerId,
            type: 'expense',
          )),
        );
      }
    } catch (error, stack) {
      _report('重试分类查询失败', error, stack);
    }
  }

  /// 临时进入分类管理后返回同一表单，当前本变化时不访问其他本的目录。
  Future<void> _openCategoryManagement() async {
    try {
      final fixedId = widget.ledgerId;
      if (fixedId != null &&
          (ref.read(currentLedgerIdProvider) != fixedId ||
              ref.read(ledgerDisplayByIdProvider(fixedId)).value == null)) {
        showToast(
          context,
          AppLocalizations.of(context).txEditorContextUnavailable,
        );
        return;
      }
      await context.pushNamed(Routes.categoryManage);
    } catch (error, stack) {
      _report('打开分类管理失败', error, stack);
    }
  }

  /// 所有动作失败记录详细堆栈，用户看到可理解的失败提示。
  void _report(String message, Object error, StackTrace stack) {
    logger.error('CategoryGridSection', message, error, stack);
    if (mounted) {
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }
}

/// 隐藏滚动条的 ScrollBehavior（分类区独立滚动、无可见滚动条）。
class _NoScrollbarBehavior extends ScrollBehavior {
  /// 父子分类列表共用隐藏滚动条的行为。
  const _NoScrollbarBehavior();

  /// 保留滚动交互，仅隐藏系统滚动条。
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

/// 二级分类选择器卡片（展开时显示在对应一级分类行下方）。
///
/// - 容器圆角 20px。
/// - 最大可视高度 200px，内部可滚动、隐藏滚动条。
/// - 父子分类共用图标配色，通过较小图标与独立分组背景表达层级。
class _SubcategorySelectorCard extends StatefulWidget {
  final List<CategoryDisplay> subCategories;
  final String? selectedId;
  final ValueChanged<CategoryDisplay> onSubCategoryTap;

  /// 每个父项拥有独立子分类列表和预选标识。
  const _SubcategorySelectorCard({
    super.key,
    required this.subCategories,
    required this.selectedId,
    required this.onSubCategoryTap,
  });

  /// 子列表保留原位展开期间的滚动位置。
  @override
  State<_SubcategorySelectorCard> createState() =>
      _SubcategorySelectorCardState();
}

class _SubcategorySelectorCardState extends State<_SubcategorySelectorCard> {
  final _scrollController = ScrollController();
  bool _positioned = false;

  /// 子卡关闭时释放独立滚动控制器。
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 预选子项定位到对应行，长子列表在二百像素内独立滚动。
  @override
  Widget build(BuildContext context) {
    if (!_positioned) {
      _positioned = true;
      final index = widget.subCategories.indexWhere(
        (category) => category.id == widget.selectedId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (!mounted || !_scrollController.hasClients || index < 0) return;
          final offset =
              (index ~/ 5) *
              (_categoryRowHeight(context, child: true) + AppDimens.p12);
          _scrollController.jumpTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
          );
        } catch (error, stack) {
          logger.error('CategoryGridSection', '定位预选子分类失败', error, stack);
          if (mounted) {
            showToast(
              context,
              AppLocalizations.of(context).commonOperationFailed,
            );
          }
        }
      });
    }
    return SectionCard(
      margin: EdgeInsets.zero,
      showShadow: false,
      textured: false,
      color: AppTokens.surfaceCategoryGroup(context),
      // 分组底色独立于图标底板，亮暗主题中都保留圆角方块的轮廓。
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p3,
        vertical: AppDimens.p8,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: AppDimens.categoryPickerSubcategoryMaxHeight,
        ),
        child: ScrollConfiguration(
          behavior: const _NoScrollbarBehavior(),
          child: GridView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              // 子分类与父分类对齐同为 5 列，列间距为 0（按钮按列宽居中排布）。
              crossAxisCount: 5,
              crossAxisSpacing: 0,
              mainAxisSpacing: AppDimens.p12,
              mainAxisExtent: _categoryRowHeight(context, child: true),
            ),
            itemCount: widget.subCategories.length,
            itemBuilder: (context, index) {
              final subCat = widget.subCategories[index];
              // 子分类格子比内容略高，用外层 Center 在格子内垂直居中，
              // 不依赖 tight 约束与内容高度常量，对系统字体缩放更鲁棒；
              // 父分类沿用各自网格，不受影响。
              return Center(
                child: CategoryGridItem(
                  key: ValueKey('category-item-${subCat.id}'),
                  category: subCat,
                  selected: widget.selectedId == subCat.id,
                  isSubCategory: true,
                  onTap: () => widget.onSubCategoryTap(subCat),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
