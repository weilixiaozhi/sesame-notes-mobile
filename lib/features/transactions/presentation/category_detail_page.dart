import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models.dart' show LedgerMemberDisplay;
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_detail_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_edit_utils.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_aa_edit_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

enum SortType { timeAsc, timeDesc, amountAsc, amountDesc }

/// schema v1 账本共享判定：账本行无 isShared/myRole 派生列，
/// 共享 = 成员数 > 1 或当前角色非 owner（与 AA 参与人名册口径一致）。
bool _isSharedLedger(LedgerDisplayItem ledger) =>
    ledger.memberCount > 1 || ledger.myRole != 'owner';

/// 取交易按本位币折算的金额数值（decimal 字符串 → double）。
///
/// nativeAmount 为空串时回退原币金额；解析失败兜底 0，避免排序崩溃。
double _amountOf(db.TransactionDisplay t) {
  final raw = t.nativeAmount.isNotEmpty ? t.nativeAmount : t.amount;
  return (Decimal.tryParse(raw) ?? Decimal.zero).toDouble();
}

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
  final DateTime? startDate; // 周期开始时间（可选）
  final DateTime? endDate; // 周期结束时间（可选）
  final String? periodLabel; // 周期标签（如"2024年11月"）

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
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

  @override
  Widget build(BuildContext context) {
    // 仅统计当前账本：不做跨账本汇总（账本标签显示异常，
    // 且多币种 nativeAmount 直接求和后挂单一币种符号的语义不严谨）。
    final ledgerId = ref.watch(currentLedgerIdProvider);
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
      categorySubsMapProvider(widget.categoryId),
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
        final totalCount = transactions.length;
        // 金额为规范化 decimal 字符串：用 Decimal 累加避免浮点尾差，
        // 汇总后再转 double 供展示组件消费（schema v1 无整数分）。
        final totalAmountDecimal = transactions.fold<Decimal>(Decimal.zero, (
          sum,
          t,
        ) {
          final raw = t.nativeAmount.isNotEmpty ? t.nativeAmount : t.amount;
          return sum + (Decimal.tryParse(raw) ?? Decimal.zero);
        });
        final totalAmount = totalAmountDecimal.toDouble();
        final averageAmount = totalCount > 0
            ? totalAmountDecimal.toDouble() / totalCount
            : 0.0;
        return AsyncValue.data((
          totalCount: totalCount,
          totalAmount: totalAmount,
          averageAmount: averageAmount,
        ));
      },
    );

    // 构建 categoryMap 快照，供列表渲染使用
    final categoryMap =
        categoryMapAsync.value ?? <String, db.CategoryDisplay>{};

    // 共享账本成员表(userId→成员),详情 sheet 用于协作成员 / AA 支出人展示名
    final ledger = ref.watch(currentLedgerDisplayProvider).asData?.value;
    // schema v1 无 syncId：成员表按账本 UUID 直查；共享判定用 [isSharedLedger]。
    var memberMap = const <String, LedgerMemberDisplay>{};
    if (ledger != null && _isSharedLedger(ledger)) {
      final members = ref
          .watch(ledgerMemberDisplaysProvider(ledger.id))
          .asData
          ?.value;
      if (members != null) {
        memberMap = {for (final m in members) m.id: m};
      }
    }
    // 本地账本无成员表:取本地昵称供详情页兜底展示(纯本地,不依赖云端登录态)
    final localOwnerName = (ledger != null && _isSharedLedger(ledger))
        ? null
        : ref.read(displayNameProvider);

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
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).categoryDetailLoadFailed,
                        ),
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
                            categorySubsMapProvider(widget.categoryId),
                          ),
                        );
                      }
                      return _buildTransactionsList(
                        transactions,
                        currentSortType,
                        categoryMap,
                        memberMap,
                        localOwnerName,
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

  Widget _buildSummaryCard(
    ({int totalCount, double totalAmount, double averageAmount}) summary,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppDimens.p16),
      child: SectionCard(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppIcons.barChart,
                    color: Theme.of(context).colorScheme.primary,
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.p16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: AppLocalizations.of(
                        context,
                      ).categoryDetailTotalCount,
                      value: AppLocalizations.of(
                        context,
                      ).categoryMigrationTransactionLabel(summary.totalCount),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      label: AppLocalizations.of(
                        context,
                      ).categoryDetailTotalAmount,
                      value: summary.totalAmount,
                      isAmount: true,
                      color: ref.watch(expenseColorSchemeProvider) == 'green'
                          ? AppTokens.success(context)
                          : AppTokens.error(context),
                    ),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      label: AppLocalizations.of(
                        context,
                      ).categoryDetailAverageAmount,
                      value: summary.averageAmount,
                      isAmount: true,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: AppDimens.p8),
          Text(
            AppLocalizations.of(context).categoryDetailSortTitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
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

  // ============================================================
  // 核心改动：按分类分组 → 分类内按日期分组 → 每笔交易用实际分类 icon/名称
  // ============================================================

  /// 删除交易:写库 → 后台同步 → 刷新账本笔数与全局统计。
  /// 详情 sheet 与行内删除入口共用同一逻辑。
  Future<void> _deleteTransaction(db.TransactionDisplay transaction) async {
    if (_deleting) return;
    _deleting = true;
    final ledgerId = ref.read(currentLedgerIdProvider);
    final l10n = AppLocalizations.of(context);

    try {
      await ref.read(transactionActionsProvider).delete(transaction.id);

      // 刷新：账本笔数与全局统计
      ref.invalidate(countsForLedgerProvider(ledgerId));

      // 同步失败单独记录:删除已成功,不应误报为「删除失败」,
      // 数据会由后续自动同步机制补推。
      try {} catch (e, st) {
        logger.warning(
          'CategoryDetailPage',
          '删除成功但同步失败 tx=${transaction.id}',
          '$e\n$st',
        );
      }
    } catch (e, st) {
      logger.error('CategoryDetailPage', '删除交易失败 tx=${transaction.id}', e, st);
      if (mounted) {
        showToast(context, l10n.categoryDetailDeleteFailed);
      }
    } finally {
      _deleting = false;
    }
  }

  /// 列表加载失败占位:友好文案 + 重试按钮。
  Widget _buildLoadError(VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.categoryDetailLoadFailed,
            style: TextStyle(color: AppTokens.textSecondary(context)),
          ),
          const SizedBox(height: AppDimens.p8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(AppIcons.refresh, size: AppDimens.icon16),
            label: Text(l10n.analyticsRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(
    List<db.TransactionDisplay> transactions,
    SortType currentSortType,
    Map<String, db.CategoryDisplay> categoryMap,
    Map<String, LedgerMemberDisplay> memberMap,
    String? localOwnerName,
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
    final dateOrder = <String>[];
    final dateGroups = <String, List<db.TransactionDisplay>>{};
    for (final tx in transactions) {
      final dk = DateFormat('yyyy-MM-dd').format(tx.happenedAt.toLocal());
      if (!dateGroups.containsKey(dk)) {
        dateGroups[dk] = [];
        dateOrder.add(dk);
      }
      dateGroups[dk]!.add(tx);
    }
    // 时间排序按日期键排；金额排序保持 provider 已排好的金额顺序，只切日期标题。
    if (!isAmountSort) {
      dateOrder.sort(
        currentSortType == SortType.timeDesc
            ? (a, b) => b.compareTo(a)
            : (a, b) => a.compareTo(b),
      );
    }

    final items = <Object>[]; // [_DateHeaderItem | _TransactionDisplayItem]
    for (final dk in dateOrder) {
      final dayTxns = dateGroups[dk]!;
      // 当日支出小计：仅统计支出类交易，decimal 字符串用 Decimal 累加
      final dayExpense = dayTxns
          .where((t) => t.txType == 'expense')
          .fold<Decimal>(
            Decimal.zero,
            (sum, t) =>
                sum +
                (Decimal.tryParse(
                      t.nativeAmount.isNotEmpty ? t.nativeAmount : t.amount,
                    ) ??
                    Decimal.zero),
          );
      items.add(_DateHeaderItem(dk, dayExpense.toDouble()));
      for (final tx in dayTxns) {
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
            currencyCode: ref.watch(currentLedgerCurrencyProvider),
          );
        } else if (item is _TransactionDisplayItem) {
          final transaction = item.transaction;
          final cat = item.category;
          return TransactionListItem(
            icon: getCategoryIconData(category: cat),
            category: cat,
            title: transaction.note ?? '',
            // 平铺列表每行显示该交易自身的分类名。
            categoryName: CategoryUtils.getDisplayName(cat.name, context),
            // schema v1 金额为规范化 decimal 字符串，直接透传
            amount: transaction.amount,
            currencyCode: transaction.currencyCode,
            nativeAmount: transaction.nativeAmount,
            isExpense: transaction.txType == 'expense',
            happenedAt: transaction.happenedAt,
            onTap: () async {
              // 点击行 → 详情 sheet(AA 支出人/分摊明细 + 常驻「编辑记账」按钮),
              // 与首页交易列表的「先看再改」交互口径一致。
              await showTransactionDetailSheet(
                context: context,
                transaction: transaction,
                category: cat,
                memberDisplayMap: memberMap,
                // 本地账本无成员表:传本地昵称供详情页兜底展示(纯本地,不依赖云端登录态)
                localOwnerDisplayName: localOwnerName,
                // 账本是否开启分摊决定底部按钮态(单/双)与右上角删除 icon 布局
                aaEnabled: aaEnabled,
                onEdit: () => TransactionEditUtils.editTransaction(
                  context,
                  ref,
                  transaction,
                  cat,
                ),
                // 编辑分摊入口:仅开启分摊时使用,跳 AaEditPage 直接落库 AA 字段
                onEditAa: () => TransactionAaEditUtils.editTransactionAa(
                  context,
                  ref,
                  transaction,
                  cat,
                ),
                onDelete: () => _deleteTransaction(transaction),
              );
            },
            onDelete: () => _deleteTransaction(transaction),
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

class _SummaryItem extends ConsumerWidget {
  final String label;
  final dynamic value; // 可以是 String 或 double
  final Color color;
  final bool isAmount; // 是否为金额类型

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget valueWidget;
    if (isAmount && value is double) {
      // 金额类型,使用 AmountText；showCurrency 显示当前账本本位币符号
      // （总金额/平均金额基于 nativeAmount 汇总，口径即本位币）。
      valueWidget = AmountText(
        value: value as double,
        signed: false,
        showCurrency: true,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      // 其他类型,直接显示字符串
      valueWidget = Text(
        value.toString(),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Column(
      children: [
        valueWidget,
        const SizedBox(height: AppDimens.p4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
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

// 派生数据：排序后的交易列表（自动响应排序状态变化）
final _categoryTransactionsWithSortProvider =
    Provider.family<
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
              // 统一先转 double 再比大小。
              sorted.sort((a, b) => _amountOf(a).compareTo(_amountOf(b)));
              break;
            case SortType.amountDesc:
              sorted.sort((a, b) => _amountOf(b).compareTo(_amountOf(a)));
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimens.radius16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected
                ? AppTokens.textOnPrimary(context)
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
