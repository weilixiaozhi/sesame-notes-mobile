import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'category_icon.dart';
import 'detail_list_item.dart';
import 'amount_text.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/data/models.dart' as db;

class CategoryRankRow extends StatefulWidget {
  final String? categoryId; // 分类ID
  final db.CategoryDisplay? category; // 分类对象（用于显示图标）
  final String name;
  final double value;
  final double percent; // 0..1 (相对于总金额的真实占比)
  final Color color;

  /// 点击分类（icon / 子分类行）时的回调，由 page 层注入导航逻辑
  ///（widget 不感知具体 page，保持 pages → widgets 单向依赖）。
  final void Function(String categoryId, String categoryName)? onCategoryTap;
  final List<
    ({String id, db.CategoryDisplay? category, String name, double total})
  >?
  subCategories; // 预计算的子分类明细

  const CategoryRankRow({
    super.key,
    this.categoryId,
    this.category,
    required this.name,
    required this.value,
    required this.percent,
    required this.color,
    this.onCategoryTap,
    this.subCategories,
  });

  @override
  State<CategoryRankRow> createState() => _CategoryRankRowState();
}

class _CategoryRankRowState extends State<CategoryRankRow> {
  bool _expanded = false;

  /// 该父分类是否「实际」存在可展示的子分类。
  /// 与 _toggleExpand 的展开判定保持一致：预计算的子分类里存在金额 > 0 的明细。
  /// 用于决定是否渲染收起/展开指示箭头，避免对无子分类的父分类显示误导性箭头。
  bool get _hasSubCategories =>
      widget.subCategories?.any((s) => s.total > 0) ?? false;

  /// 换成另一父分类或已无子项时收起，当前父分类的数据更新保持展开状态。
  @override
  void didUpdateWidget(CategoryRankRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId || !_hasSubCategories) {
      _expanded = false;
    }
  }

  /// 导航职责由页面承担，仅回传有效分类身份。
  void _handleTap(String? categoryId, String categoryName) {
    if (categoryId == null) return;
    // 导航职责在 page 层：widget 只上报点击事件，不感知目标页面
    widget.onCategoryTap?.call(categoryId, categoryName);
  }

  /// 点击父分类的内容区域（标题/金额/百分比/进度条）时触发：展开或折叠子分类。
  /// 仅负责展开/折叠，不负责跳转详情页（跳转由点击 icon 单独处理）。
  void _toggleExpand() {
    if (widget.categoryId != null && _hasSubCategories) {
      setState(() {
        _expanded = !_expanded;
      });
    }
  }

  /// 绘制分类排名及独立的图标入口，父子分类共用背景轮廓。
  Widget _buildCategoryRow({
    required String? categoryId,
    required db.CategoryDisplay? category,
    required String name,
    required double value,
    required double percent,
    required bool isTopLevel,
  }) {
    // 父子分类共用主题图标色，统计进度条独立使用数值强调色。
    final iconWidget = CategoryIconWidget(
      category: category,
      size: isTopLevel ? AppDimens.icon20 : AppDimens.icon18,
    );

    // 父分类点击展开，子分类点击进入详情。
    // Expanded 由调用方放在 Row 下，避免手势包装层隔离导致 ParentDataWidget 异常。
    final contentColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      CategoryUtils.getDisplayName(name, context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.categoryRank(
                        context,
                        topLevel: isTopLevel,
                      ),
                    ),
                  ),
                  // 仅顶级父分类且「实际存在子分类」时，在标题隔壁放置收起/展开指示箭头：
                  // 收起态 → 向右(chevronRight)，点击展开后旋转 90° 向下(chevronDown)。
                  // 放在标题右侧而非金额下方，使箭头的语义与标题直接绑定，更直观。
                  // 使用 AnimatedRotation 平滑过渡，避免图标突兀切换。
                  if (isTopLevel && _hasSubCategories) ...[
                    const SizedBox(width: AppDimens.p4),
                    AnimatedRotation(
                      turns: _expanded ? 0.25 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        AppIcons.chevronRight,
                        size: AppDimens.icon16,
                        color: AppTokens.iconTertiary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            // 金额补上货币符号（showCurrency: true），与趋势网格口径一致
            AmountText(
              value: value,
              signed: false,
              showCurrency: true,
              style: AppTextTokens.body(context),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p4),
        Row(
          children: [
            Text(
              '${(percent * 100).toStringAsFixed(1)}%',
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textTertiary(context)),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radius4),
          child: Stack(
            children: [
              Container(
                height: isTopLevel
                    ? AppDimens.categoryRankParentBarHeight
                    : AppDimens.categoryRankChildBarHeight,
                color: widget.color.withValues(alpha: 0.15),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0, 1),
                child: Container(
                  height: isTopLevel
                      ? AppDimens.categoryRankParentBarHeight
                      : AppDimens.categoryRankChildBarHeight,
                  color: widget.color.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // 父子分类使用同一底色，通过尺寸和缩进表达层级。
    final iconContainer = DetailListIcon(
      size: isTopLevel
          ? AppDimens.categoryRankParentIconSize
          : AppDimens.categoryRankChildIconSize,
      iconSize: isTopLevel ? AppDimens.icon20 : AppDimens.icon18,
      backgroundColor: AppTokens.surfaceCategoryIcon(context),
      // 父图标独立跳转；子图标的点击交给外层整行，避免产生双重响应。
      onTap: isTopLevel && categoryId != null
          ? () => _handleTap(categoryId, name)
          : null,
      child: iconWidget,
    );

    if (isTopLevel) {
      // 父分类：区分两个点击事件
      // - 点击 icon → 进入该父分类的分类汇总页面
      // - 点击标题/金额/百分比/进度条 → 展开/折叠子分类
      return Padding(
        padding: const EdgeInsets.only(
          left: 0,
          top: AppDimens.p8,
          bottom: AppDimens.p8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // icon 区域：独立可点击，跳转分类汇总页
            iconContainer,
            const SizedBox(width: AppDimens.p12),
            // 内容区域：点击展开/折叠子分类。
            // Expanded 必须作为 Row 直接子节点；点击区（Material + InkWell）包在
            // Expanded 内部（而非外部），否则 Expanded 脱离 Flex 父级会触发断言异常。
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExpand,
                  // 内容列已包含标题旁的箭头；此处不单独渲染箭头。
                  child: contentColumn,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 子分类：整行可点击，跳转详情页
    return InkWell(
      onTap: () => _handleTap(categoryId, name),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppDimens.p16,
          top: AppDimens.p8,
          bottom: AppDimens.p8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconContainer,
            const SizedBox(width: AppDimens.p12),
            Expanded(child: contentColumn),
          ],
        ),
      ),
    );
  }

  /// 直接呈现本轮预计算子项，子项金额或名称变化不依赖父合计是否变化。
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 一级分类
        _buildCategoryRow(
          categoryId: widget.categoryId,
          category: widget.category,
          name: widget.name,
          value: widget.value,
          percent: widget.percent,
          isTopLevel: true,
        ),
        // 二级分类展开区域
        if (_expanded)
          for (final subCat in widget.subCategories ?? const [])
            if (subCat.total > 0)
              _buildCategoryRow(
                categoryId: subCat.id,
                category: subCat.category,
                name: subCat.name,
                value: subCat.total,
                percent: widget.value > 0
                    ? widget.percent * (subCat.total / widget.value)
                    : 0,
                isTopLevel: false,
              ),
      ],
    );
  }
}
