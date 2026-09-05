/// 备份恢复页。
///
/// 入口（本机快照点击 / 从文件恢复 / 从云端恢复）必然携带 .snbak 文件路径：
/// 进入页面即明文解帧打开并预览备份内容（零写入）。内容页按「本地账本 /
/// 云端账本」分区展示，账本卡片点击勾选恢复策略（默认全选），底部
/// 「立即恢复」单事务应用，任一步失败整体回滚；成功后展示逐账本结果。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/currency_flag.dart';
import 'package:sesame_notes/shared/widgets/format_money.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

/// 恢复流程页面入口（单步：打开 → 勾选 → 立即恢复）。
class RestoreBackupPage extends ConsumerStatefulWidget {
  const RestoreBackupPage({super.key, this.initialBackupPath});

  /// 待恢复的 .snbak 文件路径（三个入口均必传；文件不存在时提示并退出）。
  final String? initialBackupPath;

  @override
  ConsumerState<RestoreBackupPage> createState() => _RestoreBackupPageState();
}

class _RestoreBackupPageState extends ConsumerState<RestoreBackupPage> {
  /// initState 捕获的流程 Notifier：dispose 阶段不能使用 ref，用字段调用。
  late BackupRestoreFlowNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(backupRestoreFlowProvider.notifier);
    final path = widget.initialBackupPath;
    // 进入页面即打开备份；路径缺失（异常路由）或文件已被删除时提示并退出。
    Future.microtask(() async {
      if (!mounted) return;
      if (path == null || path.isEmpty) {
        _exitWithMissingFileToast();
        return;
      }
      final file = File(path);
      if (!await file.exists()) {
        if (!mounted) return;
        _exitWithMissingFileToast();
        return;
      }
      if (!mounted) return;
      await _notifier.openBackup(file: file);
    });
  }

  /// 备份文件不存在：提示后退出页面（恢复流程无选择列表兜底步骤）。
  void _exitWithMissingFileToast() {
    showToast(context, AppLocalizations.of(context).restoreFileNotFound);
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    // 退出页面即关闭恢复会话，释放解压出的临时 sqlite 文件。
    unawaited(_notifier.closeSession());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(backupRestoreFlowProvider);
    final l10n = AppLocalizations.of(context);
    final Widget body;
    if (flow.report != null) {
      // 完成态：逐账本展示恢复结果，AppBar 返回退出。
      body = _buildDone(context, flow);
    } else if (flow.session == null) {
      // 打开中 / 打开失败
      body = _buildOpening(context, flow);
    } else {
      // 备份内容 + 勾选恢复策略
      body = _buildContent(context, flow);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          flow.report != null ? l10n.restoreDone : l10n.restoreStep2Title,
        ),
      ),
      body: SafeArea(child: body),
    );
  }

  // ---------------------------------------------------------------
  // 打开中 / 打开失败
  // ---------------------------------------------------------------

  Widget _buildOpening(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    final errorText = _errorText(context, flow.error);
    if (errorText == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorText,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTokens.error(context)),
            ),
            const SizedBox(height: AppDimens.p16),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(l10n.commonBack),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // 备份内容：本地账本 / 云端账本 双分区 + 勾选恢复策略
  // ---------------------------------------------------------------

  Widget _buildContent(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    final currentAccountId = ref.watch(authSessionProvider)?.userId;
    // 云端账本分区的账号昵称副标题：仅当前账号的云端账本进入该分区，
    // 直接取当前登录资料昵称展示（旧备份 manifest 无昵称也能显示）。
    final nickname =
        ref.watch(accountStateProvider).profile?.displayName?.trim() ?? '';
    // 分区判定：云端账本且归属账号 == 当前账号 → 云端分区；其余（本地账本 +
    // 未登录/账号不符/缺账号信息的云端账本）→ 本地分区（恢复为本地副本）。
    final clouds = flow.items
        .where(
          (i) => cloudSectionOf(item: i, currentAccountId: currentAccountId),
        )
        .toList();
    final locals = flow.items
        .where(
          (i) => !cloudSectionOf(item: i, currentAccountId: currentAccountId),
        )
        .toList();
    final errorText = _errorText(context, flow.error);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Text(
              errorText,
              style: TextStyle(color: AppTokens.error(context)),
            ),
          ),
        _sectionHeader(
          context,
          AppIcons.localStorage,
          l10n.restoreSectionLocal,
        ),
        for (final item in locals)
          _RestoreLedgerCard(
            item: item,
            selected:
                (flow.decisions[item.ledgerBackupId] ?? RestoreDecision.skip) !=
                RestoreDecision.skip,
            onToggle: () => _toggleDecision(item, currentAccountId),
          ),
        const SizedBox(height: AppDimens.p16),
        _sectionHeader(context, AppIcons.cloudQueue, l10n.restoreSectionCloud),
        for (final item in clouds)
          _RestoreLedgerCard(
            item: item,
            selected:
                (flow.decisions[item.ledgerBackupId] ?? RestoreDecision.skip) !=
                RestoreDecision.skip,
            accountNickname: nickname,
            onToggle: () => _toggleDecision(item, currentAccountId),
          ),
        const SizedBox(height: AppDimens.p16),
        FilledButton(
          onPressed: flow.loading
              ? null
              : () => ref.read(backupRestoreFlowProvider.notifier).apply(),
          child: Text(flow.loading ? l10n.restoreApplying : l10n.restoreApply),
        ),
      ],
    );
  }

  /// 分区标题（图标 + 文案），与账本管理页双分区标题同一视觉。
  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p4,
        AppDimens.p8,
        AppDimens.p4,
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

  /// 勾选/取消勾选：选中 = 该账本默认决策恢复，未选中 = skip（暂不处理）。
  void _toggleDecision(RestoreLedgerItem item, String? currentAccountId) {
    final state = ref.read(backupRestoreFlowProvider);
    final current =
        state.decisions[item.ledgerBackupId] ?? RestoreDecision.skip;
    final next = current == RestoreDecision.skip
        ? defaultDecisionFor(item: item, currentAccountId: currentAccountId)
        : RestoreDecision.skip;
    ref
        .read(backupRestoreFlowProvider.notifier)
        .setDecision(item.ledgerBackupId, next);
  }

  // ---------------------------------------------------------------
  // 完成态：逐账本展示恢复结果
  // ---------------------------------------------------------------

  Widget _buildDone(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        PrimaryHeader(title: l10n.restoreDone),
        for (final entry in flow.report!.entries)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(entry.name),
              subtitle: Text(_resultLabel(context, entry)),
            ),
          ),
      ],
    );
  }

  String _resultLabel(BuildContext context, RestoreApplyEntry entry) {
    final l10n = AppLocalizations.of(context);
    if (!entry.success) return l10n.restoreDecisionSkip;
    return switch (entry.decision) {
      RestoreDecision.restoreLocal =>
        l10n.restoreDecisionRestoreLocal +
            (entry.detail == 'conflict_fork'
                ? '（${l10n.restoreDecisionFork}）'
                : ''),
      RestoreDecision.forkCloudToLocal => l10n.restoreDecisionFork,
      RestoreDecision.reconnect => l10n.restoreDecisionReconnect,
      RestoreDecision.skip => l10n.restoreDecisionSkip,
    };
  }

  String? _errorText(BuildContext context, RestoreFlowError error) {
    if (error == RestoreFlowError.none) return null;
    final l10n = AppLocalizations.of(context);
    return switch (error) {
      RestoreFlowError.none => null,
      RestoreFlowError.openFailed => l10n.restoreOpenFailed,
      RestoreFlowError.schemaTooOld => l10n.restoreSchemaTooOld,
      RestoreFlowError.schemaTooNew => l10n.restoreSchemaTooNew,
      RestoreFlowError.applyFailed => l10n.restoreApplyFailed,
    };
  }
}

/// 恢复预览账本卡片：复刻账本管理页 LedgerCard 布局（无编辑入口），
/// 点击切换勾选（选中 = 恢复，未选中 = 暂不处理）。
class _RestoreLedgerCard extends StatelessWidget {
  const _RestoreLedgerCard({
    required this.item,
    required this.selected,
    required this.onToggle,
    this.accountNickname,
  });

  final RestoreLedgerItem item;
  final bool selected;
  final VoidCallback onToggle;

  /// 账号昵称副标题（仅「云端账本」分区传入；本地分区为 null）。
  final String? accountNickname;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final isCloud = item.storageOrigin == LedgerStorageOrigin.cloud;
    final warnings = <String>[
      if (item.pendingCount > 0) l10n.restorePendingWarning(item.pendingCount),
      if (item.conflictCount > 0)
        l10n.restoreConflictWarning(item.conflictCount),
    ];
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p4,
        ),
        decoration: BoxDecoration(
          color: AppTokens.surface(context),
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          border: AppTokens.isDark(context)
              ? Border.all(color: AppTokens.border(context), width: 1)
              : null,
          boxShadow: AppTokens.isDark(context)
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radius12),
          child: Stack(
            children: [
              // 左侧色条：仅选中时显示（与账本管理页选中态同一视觉）
              if (selected)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimens.radius12),
                        bottomLeft: Radius.circular(AppDimens.radius12),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部：账本名称 + 账号昵称副标题 + 归属图标 + 勾选状态
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextTokens.boldTitle(
                              context,
                            ).copyWith(color: AppTokens.textPrimary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (accountNickname != null &&
                            accountNickname!.isNotEmpty) ...[
                          const SizedBox(width: AppDimens.p8),
                          Flexible(
                            child: Text(
                              accountNickname!,
                              style: AppTextTokens.label(context).copyWith(
                                color: AppTokens.textSecondary(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(width: AppDimens.p8),
                        Icon(
                          isCloud ? AppIcons.cloudQueue : AppIcons.localStorage,
                          size: AppDimens.icon20,
                          color: isCloud
                              ? AppTokens.statusOnline(context)
                              : AppTokens.brandLocal,
                        ),
                        const SizedBox(width: AppDimens.p4),
                        Icon(
                          selected
                              ? AppIcons.radioChecked
                              : AppIcons.radioUnchecked,
                          size: AppDimens.icon20,
                          color: selected
                              ? primary
                              : AppTokens.iconTertiary(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.p12),
                    // 统计字段（与账本管理页卡片同口径）：币种 / 笔数 / 支出
                    Row(
                      children: [
                        Text(
                          '${l10n.ledgersCurrency}：',
                          style: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.textSecondary(context)),
                        ),
                        currencyFlagLabel(
                          context,
                          item.currency,
                          textStyle: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.textSecondary(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      l10n.ledgersRecords(item.transactionCount.toString()),
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      l10n.ledgersExpense(
                        formatMoneyWithCurrency(
                          item.expenseTotal,
                          currencyCode: item.currency,
                        ),
                      ),
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textPrimary(context)),
                    ),
                    const SizedBox(height: AppDimens.p4),
                    // 成员数 + 未同步改动/冲突警告
                    Text(
                      l10n.restoreMemberCount(item.memberCount),
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                    for (final warning in warnings)
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimens.p4),
                        child: Text(
                          warning,
                          style: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.warning(context)),
                        ),
                      ),
                    // 云端账本落入本地分区：明示「不是当前账号，恢复为本地副本」
                    if (isCloud &&
                        (accountNickname == null || accountNickname!.isEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: AppDimens.p4),
                        child: Text(
                          l10n.restoreCloudForkHint,
                          style: AppTextTokens.body(
                            context,
                          ).copyWith(color: AppTokens.warning(context)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
