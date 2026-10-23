import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models.dart';
// 列表项的删除/编辑动作由调用方注入，组件内不直接依赖 repositoryProvider、
// currentLedgerIdProvider、countsForLedgerProvider 等 provider，故不 import 对应模块。
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
// 精确导入而非 barrel 自引用，避免 biz.dart export 本文件时形成循环依赖
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/day_section_header.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;

/// 可复用的交易列表组件
/// 支持显示分组的交易列表，包含日期头部和交易项
class TransactionList extends ConsumerStatefulWidget {
  /// 首页汇总与交易共用滚动容器，短列表和空列表也能完整浏览汇总。
  final Widget? header;

  /// 启用卡片表面；账单模式共用整月单卡，其他调用方按日分卡。
  final bool cardGroups;

  /// 首页账单突出记录备注；分类、日历等独立场景保持自己的默认语义。
  final bool billPresentation;

  /// 交易数据
  final List<({TransactionDisplay t, CategoryDisplay? category})> transactions;

  /// 是否启用可见性检测用于月份跳转（主要用于首页）
  final bool enableVisibilityTracking;

  /// 月份变化回调（用于首页月份跳转逻辑）
  final Function(String dateKey, bool isVisible)? onDateVisibilityChanged;

  /// 自定义空状态显示
  final Widget? emptyWidget;

  /// 列表控制器（可选，用于精准跳转）
  final FlutterListViewController? controller;

  /// 列表项点击回调：onTap / onCategoryTap / onDelete 三个动作由调用方决定
  /// 如何打开编辑器 / 删除（首页用长按删除 + 模态确认）。
  final Future<void> Function(TransactionDisplay t, CategoryDisplay? category)?
  onEdit;

  /// 列表项删除回调（长按触发后的最终删除动作）。
  final Future<void> Function(TransactionDisplay t)? onDelete;

  /// 列表项点击分类图标的回调。
  final Future<void> Function(CategoryDisplay category)? onCategoryTap;

  /// 共享账本成员表:userId → LedgerMemberDisplay(含 avatarUrl/displayName)。
  /// 由调用方在共享账本场景从成员展示 Provider 构建,
  /// 传给列表项渲染真实头像 + 创建人/编辑人重叠(与详情页一致)。
  /// null = 单人账本,不展示头像。
  final Map<String, LedgerMemberDisplay>? memberDisplayMap;

  /// 是否为共享账本。仅共享账本渲染协作头像;非共享账本不渲染(避免占位圆)。
  final bool isShared;

  /// 下拉刷新回调:由调用方(HomePage)传入 _onRefresh;列表滚到顶部下拉时触发。
  /// 为 null 时不启用下拉刷新(向前兼容其他使用方)。
  final Future<void> Function()? onRefresh;

  /// 是否使用外部自定义下拉刷新（首页专用）。
  ///
  /// 首页由外部容器管理刷新状态，列表提供纵向滚动通知。当此值为 true 时：
  /// - 不包裹 RefreshIndicator，仅返回可滚动容器（含空表场景）
  /// - 列表使用 BouncingScrollPhysics + AlwaysScrollableScrollPhysics，
  ///   让外部 NotificationListener 能捕获 overscroll 做跟手动画
  /// - onRefresh 由外部（HomePage）自行管理，此参数为 true 时 onRefresh 可为 null
  final bool useExternalRefresh;

  const TransactionList({
    super.key,
    this.header,
    this.cardGroups = false,
    this.billPresentation = false,
    required this.transactions,
    this.enableVisibilityTracking = false,
    this.onDateVisibilityChanged,
    this.emptyWidget,
    this.controller,
    this.onEdit,
    this.onDelete,
    this.onCategoryTap,
    this.memberDisplayMap,
    this.isShared = false,
    this.onRefresh,
    this.useExternalRefresh = false,
  });

  @override
  ConsumerState<TransactionList> createState() => TransactionListState();
}

class TransactionListState extends ConsumerState<TransactionList> {
  /// 平铺账单仅消费外层页面边距，卡片和其他明细继续保留行内边距。
  double get _horizontalPadding =>
      widget.billPresentation && !widget.cardGroups ? 0 : AppDimens.p12;

  late FlutterListViewController _controller;
  List<dynamic> _flatItems = []; // 扁平化的项目列表

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FlutterListViewController();
    // 首次进入即构建扁平列表，build 不重复分组排序。
    _buildFlatItems();
  }

  @override
  void didUpdateWidget(covariant TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 交易数据变化时才重建分组/排序结果（memo 化），
    // 避免月交易量大时每帧 build 都重复 O(n log n)。
    if (!identical(widget.transactions, oldWidget.transactions)) {
      _buildFlatItems();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose(); // 只在我们创建的controller时才dispose
    }
    super.dispose();
  }

  /// 构建扁平化的项目列表
  void _buildFlatItems() {
    final transactions = widget.transactions;

    // 按天分组
    final dateFmt = DateFormat('yyyy-MM-dd');
    final groups =
        <String, List<({TransactionDisplay t, CategoryDisplay? category})>>{};
    for (final item in transactions) {
      final dt = item.t.happenedAt.toLocal();
      final key = dateFmt.format(DateTime(dt.year, dt.month, dt.day));
      groups.putIfAbsent(key, () => []).add(item);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    // 构建扁平的项目列表
    _flatItems = <dynamic>[];

    for (final key in sortedKeys) {
      final list = groups[key]!;
      // 添加日期头部
      _flatItems.add(('header', key, list));
      // 添加所有交易项
      for (final item in list) {
        _flatItems.add(('transaction', item, list));
      }
    }
  }

  /// 构建单个日期头部。
  ///
  /// 抽出为独立方法并标注 [visibleForTesting]：可见性回调依赖
  /// visibility_detector 的运行时 paint 通知，widget test 环境不会触发，
  /// 测试直接构造本方法产物以验证「可见比例 > 50% 才算可见」的判定接线。
  @visibleForTesting
  Widget buildDayHeader({
    required String dateKey,
    required List<({TransactionDisplay t, CategoryDisplay? category})> dayItems,
    required String? ledgerCurrency,
  }) {
    // 日支出用 Decimal 累加(nativeAmount 为规范化 Decimal 字符串,单位:元),
    // 避免 double 尾差;展示时直接 toDouble。
    var dayExpense = Decimal.zero;
    for (final it in dayItems) {
      final na = it.t.nativeAmount.isNotEmpty ? it.t.nativeAmount : it.t.amount;
      dayExpense += Decimal.tryParse(na) ?? Decimal.zero;
    }
    // 日支出汇总统一以账本本位币符号展示（nativeAmount 已折算为本位币），
    // currencyCode 为 null 时 DaySectionHeader 回退为无符号纯数字。
    Widget header = DaySectionHeader(
      dateText: dateKey,
      expense: dayExpense.toDouble(),
      currencyCode: ledgerCurrency,
      horizontalPadding: _horizontalPadding,
    );

    // 如果启用可见性跟踪，则包装VisibilityDetector
    if (widget.enableVisibilityTracking &&
        widget.onDateVisibilityChanged != null) {
      header = VisibilityDetector(
        key: Key('header-$dateKey'),
        onVisibilityChanged: (VisibilityInfo info) {
          // 当可见比例大于50%时认为可见
          widget.onDateVisibilityChanged!(dateKey, info.visibleFraction > 0.5);
        },
        child: header,
      );
    }

    return header;
  }

  @override
  Widget build(BuildContext context) {
    final parentNames = _parentCategoryNames(context);
    final aaEnabled =
        widget.billPresentation &&
        ref.watch(currentLedgerDisplayProvider).value?.aaEnabled == true;
    // 无数据时展示空状态。
    // 空表也必须能下拉刷新 —— 用户场景是"刚切换账本/新装应用时空表,
    // 想下拉从云端同步数据进来"。用 SingleChildScrollView +
    // AlwaysScrollableScrollPhysics 包一层,内容尺寸为 0 也能触发下拉。
    if (_flatItems.isEmpty) {
      final empty =
          widget.emptyWidget ??
          AppEmpty(
            text: AppLocalizations.of(context).commonEmpty,
            subtext: AppLocalizations.of(context).homeNoRecords,
          );
      // 无刷新需求且非外部刷新模式时直接返回空态（向前兼容其他使用方）
      if (widget.onRefresh == null && !widget.useExternalRefresh) return empty;

      // 可滚动容器：即使内容尺寸为 0,physics 也允许 overscroll,从而触发外部
      // NotificationListener 的下拉检测。SizedBox(height: maxHeight) 让空态撑满
      // viewport 居中展示,整个区域都能作为下拉触发区。
      final scrollable = widget.header == null
          ? ScrollableEmpty(child: empty)
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                bottom: AppDimens.domainBottomClearance,
              ),
              children: [widget.header!, empty],
            );

      // 外部刷新模式：不包 RefreshIndicator，仅返回可滚动容器
      if (widget.useExternalRefresh) return scrollable;

      // 内置刷新模式：包 RefreshIndicator
      return RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: widget.onRefresh!,
        child: scrollable,
      );
    }

    // 使用FlutterListView渲染列表;外层包 RefreshIndicator,仅列表滚到顶部下拉触发刷新。
    final listView = FlutterListView(
      controller: _controller,
      // 数据不足一屏时也要能下拉刷新。
      // BouncingScrollPhysics 默认在内容 < viewport 时禁止 overscroll → 拉不动;
      // 以 AlwaysScrollableScrollPhysics 作为父级,让任何情况都允许 overscroll,
      // 同时保留 Bouncing(iOS 风格回弹)的视觉效果。
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      delegate: FlutterListViewDelegate(
        (BuildContext context, int index) {
          if (widget.header != null && index == 0) return widget.header!;
          final itemIndex = index - (widget.header == null ? 0 : 1);
          if (itemIndex == _flatItems.length) {
            return const SizedBox(height: AppDimens.domainBottomClearance);
          }
          final item = _flatItems[itemIndex];
          final type = item.$1 as String;

          if (type == 'header') {
            // 渲染日期头部
            final dateKey = item.$2 as String;
            final list =
                item.$3
                    as List<
                      ({TransactionDisplay t, CategoryDisplay? category})
                    >;
            final ledgerCurrency = ref
                .watch(currentLedgerDisplayProvider)
                .asData
                ?.value
                ?.currency;
            final header = buildDayHeader(
              dateKey: dateKey,
              dayItems: list,
              ledgerCurrency: ledgerCurrency,
            );
            if (!widget.cardGroups) return header;
            return _groupSurface(
              first: !widget.billPresentation || itemIndex == 0,
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimens.p8),
                child: header,
              ),
            );
          } else {
            // 渲染交易项
            final it =
                item.$2 as ({TransactionDisplay t, CategoryDisplay? category});

            // 获取分类显示名称
            final categoryName = CategoryUtils.getDisplayName(
              it.category?.name,
              context,
            );

            // 删除入口为长按 → 外部 onDelete 回调。
            final row = _TransactionListRow(
              it: it,
              categoryName: categoryName,
              categoryPath: it.category?.parentId == null
                  ? categoryName
                  : switch (parentNames[(
                      ledgerId: it.t.ledgerId,
                      categoryId: it.category!.parentId!,
                    )]) {
                      final parent? => '$parent / $categoryName',
                      _ => categoryName,
                    },
              billPresentation: widget.billPresentation,
              horizontalPadding: _horizontalPadding,
              participatesInAa:
                  aaEnabled && AaMode.fromDb(it.t.aaMode) != AaMode.noSplit,
              memberDisplayMap: widget.memberDisplayMap,
              isShared: widget.isShared,
              onTap: widget.onEdit == null
                  ? null
                  : () async {
                      await widget.onEdit!(it.t, it.category);
                    },
              onCategoryTap:
                  (widget.onCategoryTap == null || it.category?.id == null)
                  ? null
                  : () async {
                      await widget.onCategoryTap!(it.category!);
                    },
              onLongPress: widget.onDelete == null
                  ? null
                  : () async {
                      // 删除确认统一由调用方(onDelete)负责(首页会展示"将删除{分类}"提示),
                      // 此处不重复弹窗,避免双重确认。
                      await widget.onDelete!(it.t);
                    },
            );
            if (!widget.cardGroups) return row;
            final lastOfDay =
                itemIndex == _flatItems.length - 1 ||
                _flatItems[itemIndex + 1].$1 == 'header';
            final lastOfCard = widget.billPresentation
                ? itemIndex == _flatItems.length - 1
                : lastOfDay;
            return _groupSurface(
              last: lastOfCard,
              child: Column(
                children: [
                  row,
                  if (!lastOfCard)
                    AppTokens.cardDivider(
                      context,
                      indent: AppDimens.p12 + AppDimens.p36 + AppDimens.p12,
                      verticalGap: 0,
                      height: 1,
                      endIndent: AppDimens.p12,
                    ),
                ],
              ),
            );
          }
        },
        childCount:
            _flatItems.length +
            (widget.header == null ? 0 : 1) +
            // 账单底部为新增按钮留位，与是否绘制卡片表面无关。
            (widget.cardGroups || widget.billPresentation ? 1 : 0),
      ),
    );
    // 外部刷新模式：不包 RefreshIndicator，直接返回可滚动列表
    // 外部（HomePage）通过 NotificationListener 跟踪 overscroll 实现自定义指示器
    if (widget.useExternalRefresh) return listView;
    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: widget.onRefresh ?? () async {},
      child: listView,
    );
  }

  /// 只有账单包含子分类时才按账本订阅分类树，父名称批量复用一次查询。
  Map<({String ledgerId, String categoryId}), String> _parentCategoryNames(
    BuildContext context,
  ) {
    if (!widget.billPresentation) return const {};
    final ledgerIds = {
      for (final item in widget.transactions)
        if (item.category?.parentId != null) item.t.ledgerId,
    };
    return {
      for (final ledgerId in ledgerIds)
        for (final parent
            in ref
                    .watch(
                      categoryPickerTreeForLedgerProvider((
                        ledgerId: ledgerId,
                        type: 'expense',
                      )),
                    )
                    .value
                    ?.topLevel ??
                const <CategoryDisplay>[])
          (ledgerId: ledgerId, categoryId: parent.id):
              CategoryUtils.getDisplayName(parent.name, context),
    };
  }

  /// 虚拟列表的可见片段连续拼接，仅整卡首尾绘制圆角与外缘阴影。
  Widget _groupSurface({
    required Widget child,
    bool first = false,
    bool last = false,
  }) {
    final radius = Radius.circular(AppTokens.cardRadius(context));
    final side = AppTokens.cardBorder(context);
    final decoration = AppTokens.cardDecoration(context);
    final texture = decoration.gradient;
    // 账单分片的横向纸色坐标一致，连接处连续；其他卡片使用主题完整纹理。
    final gradient = widget.billPresentation && texture is LinearGradient
        ? LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: texture.colors,
            stops: texture.stops,
            tileMode: texture.tileMode,
            transform: texture.transform,
          )
        : texture;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? AppDimens.p12 : 0),
      child: Container(
        decoration: decoration.copyWith(
          gradient: gradient,
          borderRadius: BorderRadius.vertical(
            top: first ? radius : Radius.zero,
            bottom: last ? radius : Radius.zero,
          ),
          // 隐藏内部横边，四边使用相同颜色以支持非等宽圆角边框。
          border: Border(
            left: side,
            right: side,
            top: first
                ? side
                : side.copyWith(width: 0, style: BorderStyle.none),
            bottom: last
                ? side
                : side.copyWith(width: 0, style: BorderStyle.none),
          ),
          boxShadow: last ? AppTokens.cardShadow(context) : const [],
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: last ? AppDimens.p8 : 0),
          child: child,
        ),
      ),
    );
  }
}

/// 单条交易行：长按删除 + 点击编辑。封装后便于在 _buildListDelegate 中复用。
class _TransactionListRow extends StatelessWidget {
  final ({TransactionDisplay t, CategoryDisplay? category}) it;
  final String categoryName;
  final String categoryPath;
  final bool billPresentation;
  final double horizontalPadding;
  final bool participatesInAa;
  final Map<String, LedgerMemberDisplay>? memberDisplayMap;
  final bool isShared;
  final VoidCallback? onTap;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onLongPress;

  const _TransactionListRow({
    required this.it,
    required this.categoryName,
    required this.categoryPath,
    required this.billPresentation,
    required this.horizontalPadding,
    required this.participatesInAa,
    required this.memberDisplayMap,
    required this.isShared,
    required this.onTap,
    required this.onCategoryTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    // 把整张成员表 + 交易的创建人/编辑人 userId 透传给列表项,
    // 由 TransactionListItem 自行解析真实头像并做重叠展示。
    return GestureDetector(
      onLongPress: onLongPress,
      child: TransactionListItem(
        ledgerId: it.t.ledgerId,
        category: it.category,
        title: it.t.note ?? '',
        categoryName: categoryName,
        categoryPath: categoryPath,
        billPresentation: billPresentation,
        horizontalPadding: horizontalPadding,
        participatesInAa: participatesInAa,
        amount: it.t.amount,
        currencyCode: it.t.currencyCode,
        nativeAmount: it.t.nativeAmount,
        happenedAt: it.t.happenedAt,
        lastEditedAt: it.t.lastEditedAt,
        collaboratorMap: memberDisplayMap,
        creatorUserId: it.t.createdByMemberId,
        editorUserId: it.t.lastEditedByMemberId,
        isShared: isShared,
        onTap: onTap,
        onCategoryTap: onCategoryTap,
      ),
    );
  }
}
