/// 账本列表页面。
///
/// storage_mode 表达本子归属；已登录先显示云端，没有本机本时隐藏本机分区。
///
/// 卡片的编辑入口直接打开编辑页,编辑页内承载账本名称/币种/起始日等
/// 元信息编辑;共享性由 member_count 派生。
library;

import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';

import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_card.dart';
import 'package:sesame_notes/providers/book_selection_actions.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/book_overview_card.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/shared/presentation/minimum_refresh_duration.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class LedgersPage extends ConsumerStatefulWidget {
  const LedgersPage({super.key, this.archived = false});

  /// 归档列表展示个人已收起的账本概览，卡片提供恢复使用和删除。
  final bool archived;

  @override
  ConsumerState<LedgersPage> createState() => _LedgersPageState();
}

class _LedgersPageState extends ConsumerState<LedgersPage> {
  final _pendingLedgerIds = <String>{};
  @override
  Widget build(BuildContext context) {
    final currentId = widget.archived ? '' : ref.watch(currentLedgerIdProvider);
    // 账本列表：本地 + 云端一体查询，写库经 dataChangeSignal 自动重算，
    // 无需手动刷新信号；导入/同步等任意写入都会推送新列表。
    final ledgersAsync = ref.watch(_ledgersProvider(widget.archived));

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: widget.archived
                ? AppLocalizations.of(context).ledgersArchivedTitle
                : AppLocalizations.of(context).ledgersTitle,
            // 与「分类管理」页保持一致：添加账本入口统一收归右上角 actions，
            // 并使用圆圈加号图标(AppIcons.add)，整站"新增"心智模型一致；
            // 刷新入口为列表下拉(RefreshIndicator)，不占用头部按钮。
            // 唯一入口是首页 ledger picker 的「管理账本」按钮通过 Navigator.push
            // 进来，可以 pop。showBack=true 让用户回到首页。
            showBack: true,
            actions: widget.archived
                ? null
                : [
                    HeaderIconAction(
                      icon: AppIcons.add, // 与分类页「添加分类」同源：圆圈加号
                      tooltip: AppLocalizations.of(context).ledgersCreate,
                      onPressed: () => _showCreateLedgerDialog(context),
                    ),
                    HeaderIconAction(
                      icon: AppIcons.archive,
                      tooltip: AppLocalizations.of(
                        context,
                      ).ledgersArchivedTitle,
                      onPressed: () =>
                          context.pushNamed(Routes.archivedLedgers),
                    ),
                  ],
          ),
          Expanded(
            // 刷新入口为列表下拉：RefreshIndicator 提供顶部转圈反馈，无独立刷新按钮。
            child: RefreshIndicator(
              onRefresh: () => _handleRefresh(ref),
              child: _buildLedgerListBody(
                context,
                ref,
                currentId,
                ledgersAsync,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 下拉刷新回调：云账本先执行账号级同步，随后重查本地账本列表。
  ///
  /// 本地账本不会触网；云同步失败时仍展示本地快照，并给出友好提示。
  Future<void> _handleRefresh(WidgetRef ref) async {
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);

    /// 网络结果和最短动画等待结束后，反馈仍须属于原账号与原会话。
    bool sameSession() =>
        ref.read(currentAccountIdProvider) == account &&
        ref.read(authIdentityGenerationProvider) == generation;

    try {
      // 最小展示 1 秒：本地账本瞬时重查也会让指示器完整转一圈再收起。
      final result = await ensureMinimumRefreshDuration(
        () => ref.read(syncCoordinatorProvider).refreshData(),
      );
      if (!mounted || !sameSession()) return;
      if (!result.ok) {
        logger.warning('LedgersPage', '下拉同步云账本失败: ${result.error}');
        showToast(
          context,
          result.error!,
          duration: const Duration(milliseconds: 1500),
        );
      }
      // 保留列表专用 tick：当前账本为空时的自愈监听依赖它选择第一本账。
      ref.read(ledgerListRefreshProvider.notifier).tick();
      await ref.read(_ledgersProvider(widget.archived).future);
    } catch (e, st) {
      logger.warning('LedgersPage', '下拉刷新本地账本失败: $e', st);
      if (!mounted || !sameSession()) return;
      showToast(
        context,
        cloudOperationErrorMessage(e, fallback: '刷新失败，请稍后重试'),
        duration: const Duration(milliseconds: 1500),
      );
    }
  }

  /// 账本列表主体：加载态 / 错误态 / 双分区列表
  Widget _buildLedgerListBody(
    BuildContext context,
    WidgetRef ref,
    String currentId,
    AsyncValue<List<LedgerDisplayItem>> ledgersAsync,
  ) {
    final ledgers = ledgersAsync.value ?? [];
    final error = ledgersAsync.error;

    // 如果列表在加载中且没有缓存数据，显示全局加载
    if (ledgersAsync.isLoading && ledgers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 如果加载失败，显示错误
    if (error != null && ledgers.isEmpty) {
      logger.error('LedgersPage', '账本列表加载失败', error, ledgersAsync.stackTrace);
      return AppLoadError(
        message: AppLocalizations.of(context).commonOperationFailed,
        onRetry: () => ref.invalidate(_ledgersProvider(widget.archived)),
        scrollable: true,
      );
    }

    return _buildSectionedLedgerList(context, ref, ledgers, currentId);
  }

  /// 云端优先；未登录隐藏云区，无本机本隐藏本机区。
  Widget _buildSectionedLedgerList(
    BuildContext context,
    WidgetRef ref,
    List<LedgerDisplayItem> ledgers,
    String currentId,
  ) {
    final l10n = AppLocalizations.of(context);
    // 归属由 storage_mode 决定，可见性由当前账号过滤。
    final localOnly = ledgers.where((l) => !l.isCloudLedger).toList();
    final cloudOnly = ledgers.where((l) => l.isCloudLedger).toList();
    final loggedIn = ref.watch(currentLedgerAccountIdProvider) != null;
    Widget card(LedgerDisplayItem ledger) => LedgerCard(
      ledger: ledger,
      selected: !widget.archived && ledger.id == currentId,
      onTap: ledger.isArchived ? null : () => _handleLocalLedgerTap(ledger),
      onMore: ledger.isArchived ? null : () => _openLedgerEditPage(ledger),
      onRestore: ledger.isArchived && !_pendingLedgerIds.contains(ledger.id)
          ? () => _restoreLedger(ledger)
          : null,
      onDelete: ledger.isArchived && !_pendingLedgerIds.contains(ledger.id)
          ? () => _deleteArchivedLedger(ledger)
          : null,
    );

    return ListView(
      // 内容不足一屏时（如只有一两个账本）夹紧滚动物理不产生 overscroll，
      // 下拉刷新会失效；AlwaysScrollableScrollPhysics 保证任何状态都可下拉。
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
      children: [
        if (loggedIn) ...[
          BookSectionTitle(title: l10n.ledgersSectionCloud),
          ...cloudOnly.map(card),
          if (!widget.archived)
            Center(
              child: TextButton(
                onPressed: () => context.pushNamed(Routes.joinSharedLedger),
                style: TextButton.styleFrom(
                  foregroundColor: AppTokens.primary(
                    context,
                  ).withValues(alpha: 0.75),
                ),
                child: Text('${l10n.joinSharedTitle} >'),
              ),
            ),
        ],
        if (localOnly.isNotEmpty) ...[
          BookSectionTitle(title: l10n.ledgersSectionLocal),
          ...localOnly.map(card),
        ],
        const SizedBox(height: 60.0),
      ],
    );
  }

  /// 选择入口在提交前复核已发布账本，界面只处理结果与导航。
  Future<void> _handleLocalLedgerTap(LedgerDisplayItem ledger) async {
    final changed = ref.read(currentLedgerIdProvider) != ledger.id;
    final completed = ref
        .read(productAnalyticsControllerProvider)
        .captureCompletion(
          pageId: 'accounting.ledgers',
          context: ref
              .read(productAnalyticsControllerProvider)
              .captureContext(),
        );
    try {
      await selectBook(ref.read, mode: AppMode.bookkeeping, bookId: ledger.id);
      if (changed) completed(ProductAction.accountingLedgerSelect);
      if (!mounted) return;
      showToast(
        context,
        AppLocalizations.of(
          context,
        ).ledgersSwitched(translateLedgerName(context, ledger.name)),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error, stackTrace) {
      logger.error('LedgersPage', '选择账本失败', error, stackTrace);
      if (mounted) {
        showToast(
          context,
          cloudOperationErrorMessage(
            error,
            fallback: AppLocalizations.of(context).commonOperationFailed,
          ),
        );
      }
    }
  }

  /// 恢复个人账本使用状态，按钮在提交期间禁用，成功后列表自动更新。
  Future<void> _restoreLedger(LedgerDisplayItem ledger) async {
    if (!_pendingLedgerIds.add(ledger.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(ledgerActionsProvider).setArchived(ledger.id, false);
      if (mounted) showToast(context, l10n.ledgersRestoreSuccess);
    } catch (error, stackTrace) {
      logger.error('LedgersPage', '恢复账本失败: ${ledger.id}', error, stackTrace);
      if (mounted) {
        showToast(
          context,
          cloudOperationErrorMessage(
            error,
            fallback: l10n.commonOperationFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pendingLedgerIds.remove(ledger.id));
    }
  }

  /// 确认后按账本角色删除；云端失败保留归档账本，弹窗内可重试。
  Future<void> _deleteArchivedLedger(LedgerDisplayItem ledger) async {
    if (!_pendingLedgerIds.add(ledger.id)) return;
    setState(() {});
    final l10n = AppLocalizations.of(context);
    final isOwner = ledger.myRole == 'owner';
    final name = translateLedgerName(context, ledger.name);
    try {
      final actions = ref.read(ledgerActionsProvider);
      final confirmed = await AppDialog.confirmAsync(
        context,
        title: !ledger.isShared
            ? l10n.ledgersDeleteConfirm
            : isOwner
            ? l10n.ledgersDeleteSharedConfirm
            : l10n.ledgersLeaveAndDeleteConfirm,
        message: !ledger.isShared
            ? l10n.ledgersDeleteMessage
            : isOwner
            ? l10n.ledgersDeleteSharedMessage(name)
            : l10n.ledgersLeaveAndDeleteMessage(name),
        onConfirm: () => !ledger.isShared
            ? actions.delete(ledger.id)
            : isOwner
            ? actions.deleteSharedAsOwner(ledger.id)
            : actions.leaveSharedLedger(ledger.id),
        errorMessage: (error) => cloudOperationErrorMessage(
          error,
          fallback: l10n.commonOperationFailed,
        ),
      );
      if (!confirmed || !mounted) return;
      ref.read(ledgerListRefreshProvider.notifier).tick();
      showToast(
        context,
        !ledger.isShared
            ? l10n.ledgersDeleted
            : isOwner
            ? l10n.ledgersDeleteSharedSuccess
            : l10n.ledgersLeaveAndDeleteSuccess,
      );
    } catch (error, stackTrace) {
      logger.error('LedgersPage', '删除归档账本失败: ${ledger.id}', error, stackTrace);
      if (mounted) {
        showToast(
          context,
          cloudOperationErrorMessage(
            error,
            fallback: l10n.commonOperationFailed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pendingLedgerIds.remove(ledger.id));
    }
  }

  /// 打开使用中账本的编辑页（编辑态经 extra 传账本展示项）。
  Future<void> _openLedgerEditPage(LedgerDisplayItem ledger) async {
    if (ledger.isArchived) return;
    try {
      final current = await ref.read(ledgerActionsProvider).getById(ledger.id);
      if (current == null || current.isArchived || !mounted) return;
      await context.pushNamed(Routes.ledgerEdit, extra: current);
    } catch (error, stackTrace) {
      logger.error('LedgersPage', '打开账本设置失败', error, stackTrace);
      if (mounted) {
        showToast(
          context,
          cloudOperationErrorMessage(
            error,
            fallback: AppLocalizations.of(context).commonOperationFailed,
          ),
        );
      }
    }
  }

  /// 打开新建账本二级页面（不传参数 = 新建模式）。
  void _showCreateLedgerDialog(BuildContext context) {
    context.pushNamed(Routes.ledgerEdit);
  }
}

/// 账本列表：聚合统计后构建展示项（本地 + 云端一体）。
///
/// 监听统一数据变更信号 + 列表刷新 tick，任何写库（记账/导入/同步回写）
/// 都会自动重算；失败记录日志并交给页面呈现可重试错误。
final _ledgersProvider = FutureProvider.autoDispose
    .family<List<LedgerDisplayItem>, bool>((ref, archived) async {
      ref.watch(ledgerListRefreshProvider);
      ref.watch(dataChangeSignalProvider);
      ref.watch(unpublishedCloudLedgersProvider);
      ref.watch(currentLedgerAccountIdProvider);

      try {
        final actions = ref.read(ledgerActionsProvider);
        return await actions.getAllWithStats(archived: archived);
      } catch (e, stackTrace) {
        logger.error('LedgersPage', '获取账本列表失败', e, stackTrace);
        rethrow;
      }
    });
