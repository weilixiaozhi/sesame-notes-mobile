/// 账本列表页面。
///
/// 账本归属模型:每本账都明确属于「本地」或「云端」,由账本自身的
/// storage_mode 决定,而不是"当前有没有登录"。因此列表常驻两个分区标题
/// (本地账本 / 云端账本),即使某一侧为空也保留标题 —— 让用户
/// 随时看得见"我的数据分别放在哪",而不是登录状态一变列表就换一副面孔。
///
/// 卡片的编辑入口直接打开编辑页,编辑页内承载账本名称/币种/起始日等
/// 元信息编辑;共享性由 member_count 派生。
library;

import 'package:flutter/material.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/presentation/format_utils.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class LedgersPage extends ConsumerStatefulWidget {
  const LedgersPage({super.key});

  @override
  ConsumerState<LedgersPage> createState() => _LedgersPageState();
}

class _LedgersPageState extends ConsumerState<LedgersPage> {
  @override
  Widget build(BuildContext context) {
    final currentId = ref.watch(currentLedgerIdProvider);
    // 账本列表：本地 + 云端一体查询，写库经 dataChangeSignal 自动重算，
    // 无需手动刷新信号；导入/同步等任意写入都会推送新列表。
    final ledgersAsync = ref.watch(_ledgersProvider);

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: AppLocalizations.of(context).ledgersTitle,
            // 与「分类管理」页保持一致：添加账本入口统一收归右上角 actions，
            // 并使用圆圈加号图标(AppIcons.addCircle)，整站"新增"心智模型一致；
            // 刷新入口为列表下拉(RefreshIndicator)，不占用头部按钮。
            // 唯一入口是首页 ledger picker 的「管理账本」按钮通过 Navigator.push
            // 进来，可以 pop。showBack=true 让用户回到首页。
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.addCircle, // 与分类页「添加分类」同源：圆圈加号
                tooltip: AppLocalizations.of(context).ledgersCreate,
                onPressed: () => _showCreateLedgerDialog(context),
              ),
              // 加入共享账本：邀请码 → 预览 → 接受。
              HeaderIconAction(
                icon: AppIcons.link,
                tooltip: AppLocalizations.of(context).joinSharedTitle,
                onPressed: () => context.pushNamed(Routes.joinSharedLedger),
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
    try {
      final result = await ref.read(syncCoordinatorProvider).refreshData();
      if (mounted && !result.ok) {
        logger.warning('LedgersPage', '下拉同步云账本失败: ${result.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).commonOperationFailed),
          ),
        );
      }
      // 保留列表专用 tick：当前账本为空时的自愈监听依赖它选择第一本账。
      ref.read(ledgerListRefreshProvider.notifier).tick();
      await ref.read(_ledgersProvider.future);
    } catch (e, st) {
      logger.warning('LedgersPage', '下拉刷新本地账本失败: $e', st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).commonOperationFailed),
        ),
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
      return Center(
        child: Text('${AppLocalizations.of(context).commonError}: $error'),
      );
    }

    return _buildSectionedLedgerList(context, ref, ledgers, currentId);
  }

  /// 构建「本地账本 / 云端账本」双分区列表。
  ///
  /// 两个标题常驻:即使某一侧一本账都没有也保留标题 + 空提示。这样用户在
  /// 账本全在本地 / 全在云端等任何状态下看到的都是同一套结构,
  /// 「我的账本存在哪」这件事一眼可见,不需要靠图标去猜。
  Widget _buildSectionedLedgerList(
    BuildContext context,
    WidgetRef ref,
    List<LedgerDisplayItem> ledgers,
    String currentId,
  ) {
    final l10n = AppLocalizations.of(context);
    // 归属分区的唯一依据是 storage_mode（含 isShared 兜底），与登录状态无关。
    final localOnly = ledgers.where((l) => !l.isCloudLedger).toList();
    final cloudOnly = ledgers.where((l) => l.isCloudLedger).toList();

    Widget card(LedgerDisplayItem ledger) => LedgerCard(
      ledger: ledger,
      selected: ledger.id == currentId,
      onTap: () => _handleLocalLedgerTap(ledger),
      onMore: () => _openLedgerEditPage(ledger),
    );

    return ListView(
      // 内容不足一屏时（如只有一两个账本）夹紧滚动物理不产生 overscroll，
      // 下拉刷新会失效；AlwaysScrollableScrollPhysics 保证任何状态都可下拉。
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
      children: [
        // ---------------- 本地账本 ----------------
        _buildSectionHeader(
          context,
          icon: AppIcons.localStorage,
          title: l10n.ledgersSectionLocal,
        ),
        if (localOnly.isEmpty)
          _buildSectionEmptyHint(
            context,
            text: l10n.ledgersSectionLocalEmpty,
            // 全空时这里是用户唯一的引导入口，保留「新建账本」按钮。
            action: OutlinedButton.icon(
              onPressed: () => _showCreateLedgerDialog(context),
              icon: const Icon(AppIcons.addCircle, size: AppDimens.icon16),
              label: Text(l10n.ledgersNew),
            ),
          )
        else
          ...localOnly.map(card),

        const SizedBox(height: AppDimens.p16),

        // ---------------- 云端账本 ----------------
        _buildSectionHeader(
          context,
          icon: AppIcons.cloudQueue,
          title: l10n.ledgersSectionCloud,
        ),
        // 云端账本始终渲染:退出登录只是"暂时连不上",
        // 若因此把云端账本从列表里藏掉，用户会以为数据丢了。
        if (cloudOnly.isNotEmpty)
          ...cloudOnly.map(card)
        else
          _buildSectionEmptyHint(context, text: l10n.ledgersSectionCloudEmpty),
        const SizedBox(height: 60.0),
      ],
    );
  }

  /// 分区标题（图标 + 文案），本地/云端两侧共用同一套视觉。
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p8,
        AppDimens.p16,
        AppDimens.p8,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppDimens.icon16, color: theme.colorScheme.outline),
          const SizedBox(width: AppDimens.p8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  /// 分区空提示：一句说明 + 可选行动按钮。
  ///
  /// 刻意不用整页 AppEmpty —— 分区标题必须常驻，空提示只能占据分区内部
  /// 的一小块，否则一侧为空就会把另一侧的账本挤出视野。
  Widget _buildSectionEmptyHint(
    BuildContext context, {
    required String text,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        AppDimens.p4,
        AppDimens.p16,
        AppDimens.p12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          if (action != null) ...[const SizedBox(height: AppDimens.p8), action],
        ],
      ),
    );
  }

  /// 处理账本点击：切换当前账本并提示。
  ///
  /// 新 schema 无云同步冲突概念（数据变更由统一信号自动驱动），
  /// 点击直接切换，无需等待同步状态。
  void _handleLocalLedgerTap(LedgerDisplayItem ledger) {
    ref.read(currentLedgerIdProvider.notifier).set(ledger.id);
    // 切换账本后 family 参数（ledgerId）变化即触发各汇总重算；
    // 数据刷新由统一数据变更信号自动驱动，无需手动 bump。
    showToast(
      context,
      AppLocalizations.of(
        context,
      ).ledgersSwitched(translateLedgerName(context, ledger.name)),
    );
  }

  /// 打开账本编辑二级页面（编辑态经 extra 传账本展示项）。
  Future<void> _openLedgerEditPage(LedgerDisplayItem ledger) async {
    await context.pushNamed(Routes.ledgerEdit, extra: ledger);
  }

  /// 打开新建账本二级页面（不传参数 = 新建模式）。
  void _showCreateLedgerDialog(BuildContext context) {
    context.pushNamed(Routes.ledgerEdit);
  }
}

/// 账本列表：聚合统计后构建展示项（本地 + 云端一体）。
///
/// 监听统一数据变更信号 + 列表刷新 tick，任何写库（记账/导入/同步回写）
/// 都会自动重算；失败兜底为空列表并记日志，不让列表页整页崩溃。
final _ledgersProvider = FutureProvider.autoDispose<List<LedgerDisplayItem>>((
  ref,
) async {
  ref.watch(ledgerListRefreshProvider);
  ref.watch(dataChangeSignalProvider);

  try {
    final actions = ref.read(ledgerActionsProvider);
    return await actions.getAllWithStats();
  } catch (e, stackTrace) {
    logger.error('LedgersPage', '获取账本列表失败', e, stackTrace);
    return [];
  }
});
