import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'widgets/home_expense_trend.dart';
import 'widgets/home_money_hero.dart';
import 'package:sesame_notes/shared/widgets/app_pull_to_refresh.dart';
import 'package:sesame_notes/shared/widgets/skeleton.dart'
    show DetailListSkeleton;
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_detail_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_edit_utils.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_aa_edit_utils.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/providers/sync_issues_provider.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';

/// 记账明细页：账期、汇总、趋势和每日账单共用纵向滚动区域。
class HomePage extends ConsumerStatefulWidget {
  /// 当前本与导航由业务壳提供，正文保留账期和统计入口。
  const HomePage({super.key, this.onViewAnalytics});
  final VoidCallback? onViewAnalytics;

  /// 创建首页状态，刷新与账期选择互相独立。
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isPulling = false;

  // -----------------------------------------------------------------------
  // 头部交互
  // -----------------------------------------------------------------------

  /// 账期选择使用草稿，点击完成后更新当前展示月份。
  Future<void> _onTapDateHeader() async {
    try {
      final month = ref.read(selectedMonthProvider);
      final l10n = AppLocalizations.of(context);
      final res = await showWheelDatePicker(
        context,
        initial: month,
        mode: WheelDatePickerMode.ym,
        title: l10n.homeSelectBillMonth,
        subtitle: l10n.homePickerHint,
        confirmLabel: l10n.commonDone,
      );
      if (res == null || !mounted) return;
      ref.read(selectedMonthProvider.notifier).set(res);
    } catch (error, stackTrace) {
      logger.error('HomePage', '选择账期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 回到当前自然月，交易查询继续遵循账本原有账期设置。
  void _backToCurrentMonth() {
    final now = DateTime.now();
    ref.read(selectedMonthProvider.notifier).set(DateTime(now.year, now.month));
  }

  /// 下拉刷新。
  ///
  /// 本地账本只重查本地数据；云账本先经统一编排器 push → pull，再执行
  /// 与本地账本相同的汇率、汇总和补折算流程。云同步失败时仍保留本地刷新结果。
  Future<String?> _onRefresh() async {
    if (_isPulling) return null;
    setState(() => _isPulling = true);
    final l10n = AppLocalizations.of(context);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final ledgerId = ref.read(currentLedgerIdProvider);
    String? errorMessage;
    String? resultText;
    try {
      final isCloud =
          account != null &&
          ref.read(currentLedgerDisplayProvider).value?.storageMode == 'cloud';
      // 统一刷新入口：以当前账本为参数，页面不自行决定刷新哪个账本。
      final syncResult = await ref
          .read(ledgerActionsProvider)
          .refreshCurrentLedger();

      // 无论云端是否可用，都重查本地汇总和列表；离线时按缓存汇率补折算，
      // 让用户看到当前数据库中的最新快照。
      if (mounted &&
          ref.read(currentAccountIdProvider) == account &&
          ref.read(authIdentityGenerationProvider) == generation) {
        await _runLocalRefresh(ledgerId);
      }
      if (syncResult.rejectedCount > 0) {
        resultText = '有 ${syncResult.rejectedCount} 条记录未上传，请打开「同步处理」';
      } else if (syncResult.ok) {
        resultText = isCloud
            ? l10n.homePullCloudSuccess
            : l10n.homePullLocalSuccess;
      } else if (isCloud) {
        resultText = l10n.homePullCloudFailedButLocalOk;
      }
      if (!syncResult.ok) {
        logger.warning('HomePage', '云账本下拉同步失败: ${syncResult.error}');
        // 网络失败已有原位置的本地刷新结果，不再叠加中央提示。
        if (syncResult.error != cloudNetworkErrorMessage ||
            resultText == null) {
          errorMessage = syncResult.error ?? l10n.homePullCloudFailed;
        }
      }
    } catch (e, st) {
      logger.error('HomePage', '下拉刷新失败', e, st);
      errorMessage = cloudOperationErrorMessage(
        e,
        fallback: l10n.homePullCloudFailed,
      );
    }

    if (!mounted) return null;

    setState(() => _isPulling = false);
    if (ref.read(currentAccountIdProvider) != account ||
        ref.read(authIdentityGenerationProvider) != generation) {
      return null;
    }
    if (errorMessage != null) {
      showToast(
        context,
        errorMessage,
        duration: const Duration(milliseconds: 1500),
      );
    }
    return resultText;
  }

  /// 本地刷新（下拉刷新与云同步降级共用）。
  ///
  /// 汇率连接策略（在线才拉汇率、离线复用缓存）与补折算（离线同样执行）统一由
  /// application 层承载；两者失败都非致命，不阻断刷新。
  /// 抽成独立方法供「未配置云同步」「云同步失败降级」「云同步成功」三条分支复用，
  /// 保证只要在刷新/同步路径上就必定执行本地刷新。
  Future<void> _runLocalRefresh(String ledgerId) async {
    // 补折算在任何网络状态下都会执行，且必须在重查之前完成，保证读到折算后的快照。
    await ref.read(ledgerActionsProvider).refreshLocalData(ledgerId: ledgerId);
    if (!mounted) return;
    // 重新汇总与列表：invalidate 月度汇总 + 当前账本；
    // 汇总/统计重算由统一数据变更信号自动驱动（写库即触发）。
    ref.invalidate(monthlyTotalsProvider);
    ref.invalidate(currentLedgerProvider);
    // 重新拉一次个性化设置（主题模式）以确保与磁盘一致。
    await ref.read(themeModeInitProvider.future);
  }

  /// 待处理的同步问题条数：正常待上传不计入，队列本身不是异常。
  int _syncAttentionCount(List<SyncIssue>? issues) {
    if (issues == null) return 0;
    return issues
        .where((issue) => issue.kind != SyncIssueKind.pendingUpload)
        .fold(0, (total, issue) => total + issue.count);
  }

  @override
  Widget build(BuildContext context) {
    final ledger = ref.watch(currentLedgerDisplayProvider);
    final l10n = AppLocalizations.of(context);
    // 同步异常统一走下拉区域常驻提示：问题仍在则刷新后继续常驻，点击进入同步处理。
    final issues = ref.watch(syncIssuesProvider);
    final attention = _syncAttentionCount(issues.value);
    final notice = issues.hasError
        ? l10n.syncCenterLoadFailed
        : attention > 0
        ? l10n.syncCenterPending(attention)
        : null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // 页头与顶部安全区由业务壳承载。
      body: Column(
        children: [
          // 刷新容器包住全部数据状态，加载期间保持旋转且不挤压列表视口。
          Expanded(
            child: AppPullToRefresh(
              key: ValueKey(ref.watch(currentLedgerIdProvider)),
              onRefresh: _onRefresh,
              refreshingText: l10n.homeSyncing,
              notice: notice,
              onNoticeTap: () => _runTransactionAction(() async {
                await context.pushNamed(Routes.syncCenter);
              }),
              child: ledger.when(
                data: (_) => _buildMonthContent(),
                loading: () => const DetailListSkeleton(),
                error: (error, stackTrace) {
                  logger.error('HomePage', '当前账本加载失败', error, stackTrace);
                  return AppLoadError(
                    onRetry: () => ref.invalidate(currentLedgerProvider),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 年月按钮与回本月入口均在内容区域内，账期变更只由明确操作触发。
  Widget _buildOverview() {
    final month = ref.watch(selectedMonthProvider);
    final ledger = ref.watch(currentLedgerDisplayProvider).value;
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final current = month.year == now.year && month.month == now.month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('home-month-picker'),
                  onPressed: _onTapDateHeader,
                  label: Text(monthYearLabel(context, month.month, month.year)),
                  icon: const Icon(
                    AppIcons.chevronDown,
                    size: AppDimens.icon16,
                  ),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTokens.textPrimary(context),
                    textStyle: AppTextTokens.strongTitle(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            if (!current)
              TextButton(
                onPressed: _backToCurrentMonth,
                child: Text(l10n.homeBackToCurrentMonth),
              ),
          ],
        ),
        _HeaderSummary(month: month),
        const SizedBox(height: AppDimens.p16),
        if (ledger != null)
          HomeExpenseTrend(
            month: month,
            onViewAnalytics: widget.onViewAnalytics,
          ),
        const SizedBox(height: AppDimens.p20),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeMonthlyBills(month.month.toString()),
                style: AppTextTokens.strongTitle(context),
              ),
            ),
            if (ledger?.aaEnabled == true)
              TextButton.icon(
                onPressed: () => _openAaStatistics(ledger!.id),
                icon: const Icon(AppIcons.pieChart, size: AppDimens.icon16),
                label: Text(l10n.ledgerAaStatisticsEntry),
              ),
          ],
        ),
        SizedBox(height: AppTokens.listGroupHeadingGap(context)),
      ],
    );
  }

  /// 开启分摊的账本可从账单标题旁进入独立统计页。
  Future<void> _openAaStatistics(String ledgerId) async {
    try {
      await context.pushNamed(Routes.aaStatistics, extra: ledgerId);
    } catch (error, stackTrace) {
      logger.error('HomePage', '打开分摊统计失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 编辑、删除与导航失败时统一记录错误，并保留当前页面供用户重试。
  Future<void> _runTransactionAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error, stackTrace) {
      logger.error('HomePage', '账单操作失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 当前月份只保留一个交易列表，顶部汇总随内容一起滚动。
  Widget _buildMonthContent() {
    final txActions = ref.read(transactionActionsProvider);
    final ledgerId = ref.watch(currentLedgerIdProvider);
    final monthStartDay = ref.watch(currentMonthStartDayProvider);
    final month = ref.watch(selectedMonthProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.domainPageInset,
      ),
      child: _MonthPage(
        header: _buildOverview(),
        ledgerId: ledgerId,
        month: month,
        monthStartDay: monthStartDay,
        getStream: () =>
            txActions.watchByMonth(ledgerId: ledgerId, month: month),
        onEdit: (tx, cat, analyticsContext) => _runTransactionAction(() async {
          await TransactionEditUtils.editTransaction(
            context,
            ref,
            tx,
            analyticsSourcePageId: 'accounting.transaction',
            analyticsContext: analyticsContext,
          );
        }),
        onDelete: (tx, {analyticsSourcePageId, analyticsContext}) =>
            _runTransactionAction(() async {
              final sourcePage =
                  analyticsSourcePageId ??
                  productAnalyticsEntryPage(
                    context,
                    ref.read,
                    fallbackPageId: 'accounting',
                  );
              final parentContext =
                  analyticsContext ??
                  ref.read(productAnalyticsControllerProvider).beginFlow();
              // 删除确认:标题 + 含「分类名」的描述(恒定分类值,不用备注)
              final l10n = AppLocalizations.of(context);
              String categoryName = l10n.categoryEmpty;
              if (tx.categoryId != null) {
                final cat = await ref
                    .read(categoryActionsProvider)
                    .getById(tx.categoryId!, ledgerId: tx.ledgerId);
                if (cat != null && cat.name.isNotEmpty) {
                  // 在 await 之后使用 context,先做 mounted 校验避免跨异步间隙使用 BuildContext
                  if (!mounted) return;
                  categoryName = CategoryUtils.getDisplayName(
                    cat.name,
                    context,
                  );
                }
              }
              if (!mounted) return;
              final ok = await AppDialog.confirm(
                context,
                title: l10n.homeDeleteDetailTitle,
                message: l10n.homeDeleteDetailMessage(categoryName),
              );
              if (ok != true) return;
              final completedContext = ref
                  .read(productAnalyticsControllerProvider)
                  .captureContext(parent: parentContext);
              await ref.read(transactionActionsProvider).delete(tx.id);
              if (!mounted) return;
              ref
                  .read(productAnalyticsControllerProvider)
                  .trackAction(
                    pageId: sourcePage,
                    action: ProductAction.accountingTransactionDeleted,
                    context: completedContext,
                  );
              ref.invalidate(countsForLedgerProvider(ledgerId));
              if (mounted) {
                showToast(context, l10n.ledgersDeleted);
              }
            }),
        onCategoryTap: (cat) => _runTransactionAction(() async {
          // 点击分类图标跳到分类详情。
          if (!mounted) return;
          await context.pushNamed(
            Routes.categoryDetail,
            queryParameters: {'ledgerId': ledgerId},
            extra: (
              cat.id,
              CategoryUtils.getDisplayName(cat.name, context),
              null,
              null,
              null,
            ),
          );
        }),
      ),
    );
  }
}

/// 账期金额为主视觉，今日与本周以两个独立数值区域展示。
class _HeaderSummary extends ConsumerWidget {
  /// 月度汇总仍使用既有统计来源，今日和本周保持原本的日期语义。
  const _HeaderSummary({required this.month});

  final DateTime month;

  /// 汇总缓存避免刷新期间归零，币种始终使用当前账本本位币。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final current = month.year == now.year && month.month == now.month;
    final ledgerId = ref.watch(currentLedgerIdProvider);
    final currency =
        ref.watch(currentLedgerDisplayProvider).value?.currency ?? 'CNY';
    final params = (ledgerId: ledgerId, month: month);
    final monthly = ref.watch(monthlyTotalsProvider(params));
    final monthCache = ref.watch(lastMonthlyTotalsProvider(params));
    final monthValue = monthly.value ?? monthCache;
    final today = ref.watch(todayExpenseProvider(ledgerId));
    final todayCache = ref.watch(lastTodayExpenseProvider(ledgerId));
    final todayValue = today.value ?? todayCache;
    final week = ref.watch(weekExpenseProvider(ledgerId));
    final weekCache = ref.watch(lastWeekExpenseProvider(ledgerId));
    final weekValue = week.value ?? weekCache;
    final failed =
        monthly.hasError || (current && (today.hasError || week.hasError));
    final cachedFailure =
        (monthly.hasError && monthValue != null) ||
        (current && today.hasError && todayValue != null) ||
        (current && week.hasError && weekValue != null);
    final retrying =
        (monthly.hasError && monthly.isLoading) ||
        (current && today.hasError && today.isLoading) ||
        (current && week.hasError && week.isLoading);
    // 只在新错误到达时记录原因，普通重建不重复输出同一条异常。
    for (final (label, provider) in [
      ('账期', monthlyTotalsProvider(params)),
      ('今日', todayExpenseProvider(ledgerId)),
      ('本周', weekExpenseProvider(ledgerId)),
    ]) {
      ref.listen(provider, (previous, next) {
        if (next.hasError && !next.isLoading && previous?.error != next.error) {
          logger.error(
            'HomeSummary',
            '$label支出读取失败',
            next.error,
            next.stackTrace,
          );
        }
      });
    }
    return Column(
      key: const ValueKey('home-expense-summary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (monthValue == null)
          Text(
            '—',
            key: const ValueKey('home-summary-amount-placeholder'),
            style: AppTextTokens.moneyHero(context),
          )
        else
          HomeMoneyHero(
            value: monthValue,
            currency: currency,
            label: current
                ? l10n.homeMonthExpense
                : l10n.homeMonthExpenseOf(month.month.toString()),
          ),
        if (failed)
          Row(
            children: [
              Expanded(
                child: Text(
                  cachedFailure
                      ? l10n.homeSummaryCachedFailure
                      : l10n.homeSummaryLoadFailed,
                  style: AppTextTokens.caption(context),
                ),
              ),
              TextButton(
                key: const ValueKey('home-summary-retry'),
                onPressed: retrying
                    ? null
                    : () {
                        // 只重查失败的汇总，不触发同步、补折算或修改其他统计口径。
                        if (monthly.hasError) {
                          ref.invalidate(monthlyTotalsProvider(params));
                        }
                        if (current && today.hasError) {
                          ref.invalidate(todayExpenseProvider(ledgerId));
                        }
                        if (current && week.hasError) {
                          ref.invalidate(weekExpenseProvider(ledgerId));
                        }
                      },
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        const SizedBox(height: AppDimens.p20),
        Container(
          padding: const EdgeInsets.all(AppDimens.p16),
          decoration: AppTokens.cardDecoration(context),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _smallTotal(
                  context,
                  l10n.homeTodayExpense,
                  current ? todayValue : null,
                  currency,
                ),
                VerticalDivider(
                  width: AppDimens.p32,
                  color: AppTokens.divider(context),
                ),
                _smallTotal(
                  context,
                  l10n.homeWeekExpense,
                  current ? weekValue : null,
                  currency,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 数字超长时缩放完整展示，历史月份的当前日周数值沿用占位语义。
  Widget _smallTotal(
    BuildContext context,
    String title,
    double? value,
    String currency,
  ) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextTokens.label(context)),
        const SizedBox(height: AppDimens.p8),
        if (value == null)
          Text('—', style: AppTextTokens.strongTitle(context))
        else
          AmountText(
            value: value,
            currencyCode: currency,
            showCurrency: true,
            signed: false,
            scaleDown: true,
            style: AppTextTokens.strongTitle(context),
          ),
      ],
    ),
  );
}

/// 单月页：单月交易 stream + 骨架屏。
class _MonthPage extends ConsumerStatefulWidget {
  /// 账本 id（UUID 字符串）。
  final String ledgerId;
  final Widget header;
  final DateTime month;
  final int monthStartDay;
  final Stream<List<({TransactionDisplay t, CategoryDisplay? category})>>
  Function()
  getStream;
  final Future<void> Function(
    TransactionDisplay,
    CategoryDisplay?,
    ProductAnalyticsContext,
  )
  onEdit;
  final Future<void> Function(
    TransactionDisplay, {
    String? analyticsSourcePageId,
    ProductAnalyticsContext? analyticsContext,
  })
  onDelete;
  final Future<void> Function(CategoryDisplay) onCategoryTap;

  const _MonthPage({
    required this.header,
    required this.ledgerId,
    required this.month,
    required this.monthStartDay,
    required this.getStream,
    required this.onEdit,
    required this.onDelete,
    required this.onCategoryTap,
  });

  @override
  ConsumerState<_MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends ConsumerState<_MonthPage> {
  late final FlutterListViewController _listCtrl;
  bool _active = true;
  // 缓存交易流：避免每次 build 都新建流（Drift 的 watch() 每次 new StreamController），
  // 否则 StreamBuilder 重新订阅时 snapshot.data 会短暂为 null → 渲染 DetailListSkeleton（灰色长方块）。
  // 流引用固定后，成员/账本 provider 变化触发的普通 rebuild 不会重新订阅，从而避免灰屏。
  Stream<List<({TransactionDisplay t, CategoryDisplay? category})>>? _txStream;

  @override
  void initState() {
    super.initState();
    _listCtrl = FlutterListViewController();
    // 首次进入即创建流并缓存到 State；之后所有 rebuild 复用同一引用，不重新订阅。
    // getStream 是 _MonthPage 持有、在 HomePage 创建时捕获了 repo 的闭包，
    // 内部仅依赖 widget.ledgerId/widget.month（均为 final），initState 时已就绪，安全。
    _txStream = widget.getStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.valuesOf(context).enabled;
    if (active != _active) {
      _active = active;
      // 保留列表与滚动状态，隐藏期间取消数据库订阅，回来时创建可重新监听的新流。
      _txStream = active ? widget.getStream() : null;
    }
  }

  @override
  void didUpdateWidget(covariant _MonthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 账本、月份或账期边界变化时重建流；其他账本展示字段变化仍复用旧引用。
    // didUpdateWidget 在 build 之前调用，保证「先换流、再 build 传新引用」无空窗。
    if (oldWidget.ledgerId != widget.ledgerId ||
        oldWidget.month != widget.month ||
        oldWidget.monthStartDay != widget.monthStartDay) {
      _txStream = _active ? widget.getStream() : null;
    }
  }

  @override
  void dispose() {
    _listCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final month = widget.month;
    // 隐藏页面暂停数据库订阅，返回页面时重新创建可监听的数据流。
    if (_txStream == null) return const SizedBox.shrink();
    // 数据已由数据层按账本 monthStartDay 边界过滤（watchTransactionsWithCategoryInMonth），
    // 列表直接消费当月流，避免整库全量拉取后再做 O(n) 客户端过滤。
    // ref.watch 上提到 StreamBuilder 之前（独立清理）：成员/账本 provider 变化只触发
    // _MonthPage 整体 rebuild，build 重跑时 memberMap 照常重算、头像实时更新，
    // 不依赖 StreamBuilder.builder 闭包内的 watch。
    final ledger = ref.watch(currentLedgerDisplayProvider).asData?.value;
    // 共享账本成员展示映射供列表项头像使用，保留 LEFT/REMOVED 历史成员。
    final isShared = (ledger?.memberCount ?? 0) > 1;
    final memberMap = (isShared && ledger != null)
        ? ref.watch(ledgerMemberDisplayMapProvider(ledger.id)).asData?.value ??
              const <String, LedgerMemberDisplay>{}
        : const <String, LedgerMemberDisplay>{};
    return StreamBuilder<
      List<({TransactionDisplay t, CategoryDisplay? category})>
    >(
      key: ValueKey('month_${widget.ledgerId}_${month.year}_${month.month}'),
      // 复用缓存的流引用：rebuild 不重新订阅，memberMap 实时刷新但交易流不丢、不灰屏。
      stream: _txStream!,
      builder: (context, snapshot) {
        // 流出错：展示友好错误 + 重试（重建流），避免永久骨架屏。
        if (snapshot.hasError) {
          logger.error(
            'HomePage',
            '交易流加载失败',
            snapshot.error,
            snapshot.stackTrace,
          );
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              widget.header,
              AppLoadError(
                onRetry: () {
                  setState(() {
                    _txStream = _active ? widget.getStream() : null;
                  });
                },
              ),
            ],
          );
        }

        final all = snapshot.data ?? const [];

        // 数据流尚未发射时显示骨架屏占位：切月后重新订阅流，
        // 首帧无数据 → 骨架屏，避免空状态闪烁；数据到达后自动替换为真实列表。
        if (!snapshot.hasData) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              widget.header,
              const SizedBox(height: 240, child: DetailListSkeleton()),
            ],
          );
        }

        // 空表也走 TransactionList —— useExternalRefresh 模式下
        // 空表返回可滚动容器包裹 AppEmpty，支持"空表下拉刷新"。
        // 直接 return AppEmpty 会绕过下拉刷新,空账本场景下用户无法拉云端数据。
        // 共享账本成员映射(member id→成员):供列表项头像读取
        // （ledger / memberMap 已上提到 build 外层计算，此处直接复用）
        return TransactionList(
          header: widget.header,
          cardGroups: AppTokens.listGroupsUseCards(context),
          billPresentation: true,
          transactions: all,
          controller: _listCtrl,
          emptyWidget: AppEmpty(
            text: AppLocalizations.of(context).homeNoRecords,
          ),
          memberDisplayMap: memberMap,
          isShared: isShared,
          // 首页刷新状态由外部容器管理，列表只提供纵向滚动通知。
          useExternalRefresh: true,
          // 列表点击 → 打开记录详情 Sheet(非直接编辑);详情内编辑/删除走原子回调
          onEdit: (tx, cat) async {
            try {
              await showTransactionDetailSheet(
                context: context,
                transaction: tx,
                category: cat,
                // 账本是否开启分摊决定底部按钮态(单/双)与右上角删除 icon 布局
                aaEnabled: ledger?.aaEnabled ?? false,
                onEdit: (analyticsContext) =>
                    widget.onEdit(tx, cat, analyticsContext),
                // 编辑分摊入口:仅开启分摊时使用,跳 AaEditPage 直接落库 AA 字段
                onEditAa: () => TransactionAaEditUtils.editTransactionAa(
                  context,
                  ref,
                  tx,
                  cat,
                ),
                onDelete: (analyticsContext) => widget.onDelete(
                  tx,
                  analyticsSourcePageId: 'accounting.transaction',
                  analyticsContext: analyticsContext,
                ),
              );
            } catch (error, stackTrace) {
              logger.error('HomePage', '打开账单详情失败', error, stackTrace);
              if (context.mounted) {
                showToast(
                  context,
                  AppLocalizations.of(context).commonOperationFailed,
                );
              }
            }
          },
          onDelete: widget.onDelete,
          onCategoryTap: widget.onCategoryTap,
        );
      },
    );
  }
}
