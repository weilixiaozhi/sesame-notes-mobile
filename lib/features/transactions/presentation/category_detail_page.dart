import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/transactions/domain/category_detail_summary.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_detail_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_edit_utils.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_aa_edit_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

enum SortType { timeAsc, timeDesc, amountAsc, amountDesc }

// ============================================================
// 分类汇总列表的展示项模型（用于 ListView.builder 统一渲染）
// ============================================================

/// 日期分组标题行：展示日期 + 当日支出小计
class _DateHeaderItem {
  final String dateKey;
  final double expense;
  _DateHeaderItem(this.dateKey, this.expense);
}

/// 交易行
class _TransactionDisplayItem {
  final db.TransactionDisplay transaction;
  final db.CategoryDisplay category;
  _TransactionDisplayItem(this.transaction, this.category);
}

class CategoryDetailPage extends ConsumerStatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? ledgerId;
  final DateTime? startDate; // 周期开始时间（可选）
  final DateTime? endDate; // 周期结束时间（可选）
  final String? periodLabel; // 周期标签（如"2024年11月"）

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.ledgerId,
    this.startDate,
    this.endDate,
    this.periodLabel,
  });

  @override
  ConsumerState<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends ConsumerState<CategoryDetailPage> {
  /// 删除进行中标记:防止详情 sheet 与行内删除入口连点重复执行。
  bool _deleting = false;
  late final String _ledgerId;

  /// 明细固定使用打开时的账本身份，其他页面切换账本不会改变该分类的所有者。
  @override
  void initState() {
    super.initState();
    _ledgerId = widget.ledgerId ?? ref.read(currentLedgerIdProvider);
  }

  @override
  Widget build(BuildContext context) {
    // 仅统计当前账本：不做跨账本汇总（账本标签显示异常，
    // 且多币种 nativeAmount 直接求和后挂单一币种符号的语义不严谨）。
    final ledgerId = _ledgerId;
    final transactionsAsync = ref.watch(
      _categoryTransactionsWithSortProvider((
        categoryId: widget.categoryId,
        ledgerId: ledgerId,
      )),
    );
    final currentSortType = ref.watch(
      _categorySortTypeProvider(widget.categoryId),
    );

    // 分类 Map：key=categoryId，value=Category 对象，用于每笔交易按实际分类显示 icon/名称
    final categoryMapAsync = ref.watch(
      categorySubsMapProvider((
        categoryId: widget.categoryId,
        ledgerId: ledgerId,
      )),
    );

    // 如果有周期限制，需要筛选交易数据
    final filteredTransactionsAsync = transactionsAsync.when(
      loading: () => const AsyncValue<List<db.TransactionDisplay>>.loading(),
      error: (error, stack) =>
          AsyncValue<List<db.TransactionDisplay>>.error(error, stack),
      data: (transactions) {
        if (widget.startDate != null && widget.endDate != null) {
          final filtered = transactions.where((t) {
            // 区间为 [startDate, endDate):包含起始日,排除结束日的下一天。
            return t.happenedAt.isAtSameMomentAs(widget.startDate!) ||
                (t.happenedAt.isAfter(widget.startDate!) &&
                    t.happenedAt.isBefore(widget.endDate!));
          }).toList();
          return AsyncValue.data(filtered);
        }
        return AsyncValue.data(transactions);
      },
    );

    // 基于筛选后的数据计算汇总
    final summaryAsync = filteredTransactionsAsync.when(
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
      data: (transactions) {
        // 总额按 Decimal 累加、平均 = 总额 / 笔数：口径统一收敛在 domain 层。
        return AsyncValue.data(summarizeCategoryDetail(transactions));
      },
    );

    // 构建 categoryMap 快照，供列表渲染使用
    final categoryMap =
        categoryMapAsync.value ?? <String, db.CategoryDisplay>{};

    final ledger = ref.watch(ledgerByIdProvider(ledgerId)).asData?.value;

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: AppLocalizations.of(context).categoryDetailSummaryTitle,
            showBack: true,
          ),
          Expanded(
            child: Column(
              children: [
                // 汇总信息卡片
                summaryAsync.when(
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) {
                    // 原始异常只进日志,页面展示统一友好文案。
                    logger.error(
                      'CategoryDetailPage',
                      '分类汇总加载失败 category=${widget.categoryId}',
                      error,
                      stack,
                    );
                    return Container(
                      height: 120,
                      margin: const EdgeInsets.all(AppDimens.p16),
                      child: AppEmpty(
                        text: AppLocalizations.of(
                          context,
                        ).categoryDetailLoadFailed,
                        padding: EdgeInsets.zero,
                      ),
                    );
                  },
                  data: (summary) => _buildSummaryCard(summary),
                ),
                // 排序控件
                _buildSortControls(currentSortType),
                // 交易记录列表
                Expanded(
                  child: filteredTransactionsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) {
                      logger.error(
                        'CategoryDetailPage',
                        '分类交易加载失败 category=${widget.categoryId}',
                        error,
                        stack,
                      );
                      return _buildLoadError(
                        () => ref.invalidate(
                          _categoryTransactionsWithSortProvider((
                            categoryId: widget.categoryId,
                            ledgerId: ledgerId,
                          )),
                        ),
                      );
                    },
                    data: (transactions) {
                      // 分类映射未就绪:交易先到也不能静默跳过分类组,
                      // 先展示加载态,避免整组交易消失。
                      if (categoryMapAsync.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // 分类映射加载失败:展示错误 + 重试,不静默当「无交易」。
                      if (categoryMapAsync.hasError) {
                        return _buildLoadError(
                          () => ref.invalidate(
                            categorySubsMapProvider((
                              categoryId: widget.categoryId,
                              ledgerId: ledgerId,
                            )),
                          ),
                        );
                      }
                      return _buildTransactionsList(
                        transactions,
                        currentSortType,
                        categoryMap,
                        ledger?.aaEnabled ?? false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 汇总卡统一管理内外边距，文字和金额使用各自的主题语义色。
  Widget _buildSummaryCard(
    ({int totalCount, double totalAmount, double averageAmount}) summary,
  ) {
    return SectionCard(
      margin: const EdgeInsets.all(AppDimens.p16),
      padding: const EdgeInsets.all(AppDimens.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                AppIcons.barChart,
                color: AppTokens.primary(context),
                size: AppDimens.icon20,
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Text(
                  widget.periodLabel != null
                      ? '${CategoryUtils.getDisplayName(widget.categoryName, context)} · ${widget.periodLabel}'
                      : CategoryUtils.getDisplayName(
                          widget.categoryName,
                          context,
                        ),
                  style: AppTextTokens.strongTitle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.p16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: AppLocalizations.of(context).categoryDetailTotalCount,
                  value: AppLocalizations.of(
                    context,
                  ).categoryMigrationTransactionLabel(summary.totalCount),
                  color: AppTokens.primary(context),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: AppLocalizations.of(context).categoryDetailTotalAmount,
                  value: summary.totalAmount,
                  currencyCode: ref
                      .watch(ledgerByIdProvider(_ledgerId))
                      .asData
                      ?.value
                      ?.currency,
                  isAmount: true,
                  color: AppTokens.error(context),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  label: AppLocalizations.of(
                    context,
                  ).categoryDetailAverageAmount,
                  value: summary.averageAmount,
                  currencyCode: ref
                      .watch(ledgerByIdProvider(_ledgerId))
                      .asData
                      ?.value
                      ?.currency,
                  isAmount: true,
                  color: AppTokens.textPrimary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 排序说明使用次要文字色，与选中按钮的强调色区分层级。
  Widget _buildSortControls(SortType currentSortType) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p8,
      ),
      child: Row(
        children: [
          Icon(
            AppIcons.sort,
            size: AppDimens.icon16,
            color: AppTokens.iconSecondary(context),
          ),
          const SizedBox(width: AppDimens.p8),
          Text(
            AppLocalizations.of(context).categoryDetailSortTitle,
            style: AppTextTokens.label(context),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _SortButton(
                    label: AppLocalizations.of(
                      context,
                    ).categoryDetailSortTimeDesc,
                    isSelected: currentSortType == SortType.timeDesc,
                    onTap: () => ref
                        .read(
                          _categorySortTypeProvider(widget.categoryId).notifier,
                        )
                        .set(SortType.timeDesc),
                  ),
                  const SizedBox(width: AppDimens.p8),
                  _SortButton(
                    label: AppLocalizations.of(
                      context,
                    ).categoryDetailSortTimeAsc,
                    isSelected: currentSortType == SortType.timeAsc,
                    onTap: () => ref
                        .read(
                          _categorySortTypeProvider(widget.categoryId).notifier,
                        )
                        .set(SortType.timeAsc),
                  ),
                  const SizedBox(width: AppDimens.p8),
                  _SortButton(
                    label: AppLocalizations.of(
                      context,
                    ).categoryDetailSortAmountDesc,
                    isSelected: currentSortType == SortType.amountDesc,
                    onTap: () => ref
                        .read(
                          _categorySortTypeProvider(widget.categoryId).notifier,
                        )
                        .set(SortType.amountDesc),
                  ),
                  const SizedBox(width: AppDimens.p8),
                  _SortButton(
                    label: AppLocalizations.of(
                      context,
                    ).categoryDetailSortAmountAsc,
                    isSelected: currentSortType == SortType.amountAsc,
                    onTap: () => ref
                        .read(
                          _categorySortTypeProvider(widget.categoryId).notifier,
                        )
                        .set(SortType.amountAsc),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 删除交易:写库 → 后台同步 → 刷新账本笔数与全局统计。
  /// 详情 sheet 与行内删除入口共用同一逻辑。
  Future<void> _deleteTransaction(
    db.TransactionDisplay transaction,
    ProductAnalyticsContext analyticsContext,
  ) async {
    if (_deleting) return;
    _deleting = true;
    final ledgerId = _ledgerId;
    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(transactionActionsProvider).delete(transaction.id);
      if (mounted) {
        ref
            .read(productAnalyticsControllerProvider)
            .trackAction(
              pageId: 'accounting.transaction',
              action: ProductAction.accountingTransactionDeleted,
              context: analyticsContext,
            );
      }

      // 刷新：账本笔数与全局统计
      if (mounted) ref.invalidate(countsForLedgerProvider(ledgerId));
    } catch (e, st) {
      logger.error('CategoryDetailPage', '删除交易失败 tx=${transaction.id}', e, st);
      if (mounted) {
        showToast(context, l10n.categoryDetailDeleteFailed);
      }
    } finally {
      _deleting = false;
    }
  }

  /// 业务文案和重试行为交给统一错误态呈现。
  Widget _buildLoadError(VoidCallback onRetry) => AppLoadError(
    message: AppLocalizations.of(context).categoryDetailLoadFailed,
    onRetry: onRetry,
  );

  Widget _buildTransactionsList(
    List<db.TransactionDisplay> transactions,
    SortType currentSortType,
    Map<String, db.CategoryDisplay> categoryMap,
    bool aaEnabled,
  ) {
    if (transactions.isEmpty) {
      return AppEmpty(
        text: AppLocalizations.of(context).categoryDetailNoTransactions,
        subtext: AppLocalizations.of(
          context,
        ).categoryDetailNoTransactionsSubtext,
      );
    }

    final isAmountSort =
        currentSortType == SortType.amountDesc ||
        currentSortType == SortType.amountAsc;

    // 父分类与各子分类的交易平铺在同一个列表里，仅按日期分组；
    // 每行按交易自身 categoryId 渲染真实分类名与 icon。
    final groups = groupCategoryDetailByDate(
      transactions,
      isAmountSort: isAmountSort,
      timeDesc: currentSortType == SortType.timeDesc,
    );

    final items = <Object>[]; // [_DateHeaderItem | _TransactionDisplayItem]
    for (final group in groups) {
      items.add(_DateHeaderItem(group.dateKey, group.expense));
      for (final tx in group.transactions) {
        final cat = _getCategoryForTransaction(tx, categoryMap);
        if (cat == null) continue;
        items.add(_TransactionDisplayItem(tx, cat));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _DateHeaderItem) {
          return DaySectionHeader(
            dateText: item.dateKey,
            expense: item.expense,
            // 日期小计带当前账本本位币符号（与主页 transaction_list 口径一致）
            currencyCode: ref
                .watch(ledgerByIdProvider(_ledgerId))
                .asData
                ?.value
                ?.currency,
          );
        } else if (item is _TransactionDisplayItem) {
          final transaction = item.transaction;
          final cat = item.category;
          return TransactionListItem(
            ledgerId: transaction.ledgerId,
            category: cat,
            title: transaction.note ?? '',
            // 平铺列表每行显示该交易自身的分类名。
            categoryName: CategoryUtils.getDisplayName(cat.name, context),
            // 金额使用规范化十进制字符串，保留存储精度。
            amount: transaction.amount,
            currencyCode: transaction.currencyCode,
            nativeAmount: transaction.nativeAmount,
            happenedAt: transaction.happenedAt,
            onTap: () async {
              // 点击行 → 详情 sheet(AA 支出人/分摊明细 + 常驻「编辑记账」按钮),
              // 与首页交易列表的「先看再改」交互口径一致。
              await showTransactionDetailSheet(
                context: context,
                transaction: transaction,
                category: cat,
                // 账本是否开启分摊决定底部按钮态(单/双)与右上角删除 icon 布局
                aaEnabled: aaEnabled,
                onEdit: (analyticsContext) =>
                    TransactionEditUtils.editTransaction(
                      context,
                      ref,
                      transaction,
                      analyticsSourcePageId: 'accounting.transaction',
                      analyticsContext: analyticsContext,
                    ),
                // 编辑分摊入口:仅开启分摊时使用,跳 AaEditPage 直接落库 AA 字段
                onEditAa: () => TransactionAaEditUtils.editTransactionAa(
                  context,
                  ref,
                  transaction,
                  cat,
                ),
                onDelete: (analyticsContext) =>
                    _deleteTransaction(transaction, analyticsContext),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// 根据交易的 [tx.categoryId] 查找其实际所属的分类对象。
  ///
  /// 设计意图：分类汇总页同时展示一级 + 二级分类的交易，每笔交易应使用
  /// 其真实分类的 icon 与名称；查不到时回退到当前一级分类。
  db.CategoryDisplay? _getCategoryForTransaction(
    db.TransactionDisplay tx,
    Map<String, db.CategoryDisplay> categoryMap,
  ) {
    final catId = tx.categoryId;
    if (catId != null && categoryMap.containsKey(catId)) {
      return categoryMap[catId];
    }
    // 回退：交易分类已被删除或不在映射中时，用当前一级分类兜底展示
    return categoryMap[widget.categoryId];
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final dynamic value; // 可以是 String 或 double
  final Color color;
  final bool isAmount; // 是否为金额类型
  final String? currencyCode;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.isAmount = false,
    this.currencyCode,
  });

  /// 数值沿用全局大数字样式，统计名称使用可读的次要文字色。
  @override
  Widget build(BuildContext context) {
    Widget valueWidget;
    if (isAmount && value is double) {
      // 金额类型,使用 AmountText；showCurrency 显示当前账本本位币符号
      // （总金额/平均金额基于 nativeAmount 汇总，口径即本位币）。
      valueWidget = AmountText(
        value: value as double,
        signed: false,
        showCurrency: currencyCode != null,
        currencyCode: currencyCode,
        style: AppTextTokens.boldTitle(context).copyWith(color: color),
      );
    } else {
      // 其他类型,直接显示字符串
      valueWidget = Text(
        value.toString(),
        style: AppTextTokens.boldTitle(context).copyWith(color: color),
      );
    }

    return Column(
      children: [
        valueWidget,
        const SizedBox(height: AppDimens.p4),
        Text(label, style: AppTextTokens.label(context)),
      ],
    );
  }
}

// ===== 响应式Provider设计 =====

// 排序状态管理
final _categorySortTypeProvider =
    NotifierProvider.family<SimpleStateNotifier<SortType>, SortType, String>(
      (categoryId) => SimpleStateNotifier((ref) => SortType.timeDesc),
    );

// 排序列表仅在页面使用期间保留，退出后释放列表及上游交易查询。
final _categoryTransactionsWithSortProvider = Provider.autoDispose
    .family<
      AsyncValue<List<db.TransactionDisplay>>,
      ({String categoryId, String ledgerId})
    >((ref, params) {
      final transactionsAsync = ref.watch(categoryTransactionsProvider(params));
      final sortType = ref.watch(_categorySortTypeProvider(params.categoryId));

      return transactionsAsync.when(
        loading: () => const AsyncValue.loading(),
        error: (error, stack) => AsyncValue.error(error, stack),
        data: (transactions) {
          final sorted = List<db.TransactionDisplay>.from(transactions);

          switch (sortType) {
            case SortType.timeAsc:
              sorted.sort((a, b) => a.happenedAt.compareTo(b.happenedAt));
              break;
            case SortType.timeDesc:
              sorted.sort((a, b) => b.happenedAt.compareTo(a.happenedAt));
              break;
            case SortType.amountAsc:
              // 金额排序与列表展示/小计口径一致:按折本位币金额排。
              // decimal 字符串不能按字典序比较（"9.99" > "10.00" 会出错），
              // 直接比较十进制值，避免高精度金额转 double 后失去排序差异。
              sorted.sort(
                (a, b) => categoryDetailAmountOf(
                  a,
                ).compareTo(categoryDetailAmountOf(b)),
              );
              break;
            case SortType.amountDesc:
              sorted.sort(
                (a, b) => categoryDetailAmountOf(
                  b,
                ).compareTo(categoryDetailAmountOf(a)),
              );
              break;
          }

          return AsyncValue.data(sorted);
        },
      );
    });

class _SortButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  /// 排序按钮通过主题前景色、背景色及边框表达选中状态。
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p12,
        vertical: AppDimens.p4,
      ),
      labelPadding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selectedColor: AppTokens.primary(context),
      backgroundColor: AppTokens.surface(context),
      side: BorderSide(
        color: isSelected
            ? AppTokens.primary(context)
            : AppTokens.border(context),
      ),
      labelStyle: AppTextTokens.label(context).copyWith(
        color: isSelected
            ? AppTokens.textOnPrimary(context)
            : AppTokens.textPrimary(context),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
