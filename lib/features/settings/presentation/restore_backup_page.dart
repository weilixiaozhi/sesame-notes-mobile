/// 备份恢复页（4 步流程）。
///
/// Step 1 选择备份：列表展示时间戳备份 + 输入密码/恢复词 → 打开（只读）；
/// Step 2 查看备份内容：按归属分域展示账本（成员数/交易数/最后同步/来源账号）；
/// Step 3 每个账本选择恢复策略（恢复为本地 / 登录原账号 / 暂不处理）；
/// Step 4 确认导入结果（明示"恢复不会覆盖现有账本"）→ 单事务应用。
/// Step 1–3 全程零写入，Step 4 任一步失败整体回滚。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

/// 恢复流程页面入口（4 步）。
class RestoreBackupPage extends ConsumerStatefulWidget {
  const RestoreBackupPage({super.key});

  @override
  ConsumerState<RestoreBackupPage> createState() => _RestoreBackupPageState();
}

class _RestoreBackupPageState extends ConsumerState<RestoreBackupPage> {
  final TextEditingController _secretController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 进入页面即加载备份列表（只读）
    Future.microtask(
      () => ref.read(backupRestoreFlowProvider.notifier).loadBackups(),
    );
  }

  @override
  void dispose() {
    _secretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(backupRestoreFlowProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).backupRestoreTitle),
      ),
      body: SafeArea(
        child: switch (flow.step) {
          1 => _buildStep1(context, flow),
          2 => _buildStep2(context, flow),
          3 => _buildStep3(context, flow),
          _ => _buildStep4(context, flow),
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // Step 1：选择备份 + 输入密码
  // ---------------------------------------------------------------

  Widget _buildStep1(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    final errorText = _errorText(context, flow.error);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        PrimaryHeader(
          title: l10n.restoreStep1Title,
          subtitle: l10n.restoreStep1Subtitle,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Text(
              errorText,
              style: TextStyle(color: AppTokens.error(context)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.p12),
          child: TextField(
            controller: _secretController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: l10n.restorePasswordHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (flow.backups.isEmpty && !flow.loading)
          Padding(
            padding: const EdgeInsets.all(AppDimens.p32),
            child: Center(child: Text(l10n.restoreNoBackups)),
          ),
        for (final backup in flow.backups)
          AppListTile(
            leading: Icons.backup_outlined,
            title: _formatBackupTime(backup.createdAt),
            subtitle: backup.sizeLabel,
            trailing: flow.selected?.pathKey == backup.pathKey
                ? Icon(Icons.check_circle, color: AppTokens.primary(context))
                : null,
            onTap: () => _openBackup(context, backup),
          ),
        if (flow.loading) const LinearProgressIndicator(),
      ],
    );
  }

  Future<void> _openBackup(
    BuildContext context,
    RestoreBackupFile backup,
  ) async {
    final l10n = AppLocalizations.of(context);
    final secret = _secretController.text.trim();
    if (secret.isEmpty) {
      showToast(context, l10n.restorePasswordHint);
      return;
    }
    await ref
        .read(backupRestoreFlowProvider.notifier)
        .openBackup(file: backup, secret: secret);
  }

  // ---------------------------------------------------------------
  // Step 2：查看备份内容（按归属分域）
  // ---------------------------------------------------------------

  Widget _buildStep2(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    final locals = flow.items.where(
      (i) => i.storageOrigin == LedgerStorageOrigin.local,
    );
    final clouds = flow.items.where(
      (i) => i.storageOrigin == LedgerStorageOrigin.cloud,
    );
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        PrimaryHeader(
          title: l10n.restoreStep2Title,
          subtitle: flow.selected?.sizeLabel ?? '',
        ),
        if (locals.isNotEmpty)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.p12),
                  child: Text(
                    '仅本地',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final item in locals) _itemTile(context, item),
              ],
            ),
          ),
        for (final account in _groupByAccount(clouds).entries)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.p12),
                  child: Text(
                    account.key,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                for (final item in account.value) _itemTile(context, item),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.p12),
          child: FilledButton(
            onPressed: () => ref
                .read(backupRestoreFlowProvider.notifier)
                .proceedToStrategy(),
            child: Text(l10n.restoreStep3Title),
          ),
        ),
      ],
    );
  }

  /// 云端账本按归属账号分域（账号引用无凭据，仅展示）。
  Map<String, List<RestoreLedgerItem>> _groupByAccount(
    Iterable<RestoreLedgerItem> clouds,
  ) {
    final grouped = <String, List<RestoreLedgerItem>>{};
    for (final item in clouds) {
      // 账号名可能为空串（客户端本地不存账号名），回退到账号 id 展示
      final rawName = item.accountName ?? '';
      final accountName = rawName.isNotEmpty
          ? rawName
          : (item.accountId ?? '未知账号');
      grouped.putIfAbsent(accountName, () => []).add(item);
    }
    return grouped;
  }

  Widget _itemTile(BuildContext context, RestoreLedgerItem item) {
    final l10n = AppLocalizations.of(context);
    final warnings = <String>[
      if (item.pendingCount > 0) l10n.restorePendingWarning(item.pendingCount),
      if (item.conflictCount > 0)
        l10n.restoreConflictWarning(item.conflictCount),
    ];
    final subtitleParts = <String>[
      l10n.restoreMemberCount(item.memberCount),
      l10n.restoreTxCount(item.transactionCount),
    ];
    return AppListTile(
      leading: Icons.menu_book_outlined,
      title: item.name,
      subtitle:
          subtitleParts.join(' · ') +
          (warnings.isEmpty ? '' : '\n${warnings.join('\n')}'),
    );
  }

  // ---------------------------------------------------------------
  // Step 3：每账本选择恢复策略（显式三选一，无隐式 Merge）
  // ---------------------------------------------------------------

  Widget _buildStep3(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        PrimaryHeader(
          title: l10n.restoreStep3Title,
          subtitle: flow.selected?.sizeLabel ?? '',
        ),
        for (final item in flow.items)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.p12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (item.storageOrigin == LedgerStorageOrigin.cloud &&
                          item.accountId != null)
                        Text(
                          l10n.restoreAccountOf(
                            (item.accountName ?? '').isEmpty
                                ? item.accountId!
                                : item.accountName!,
                          ),
                        ),
                    ],
                  ),
                ),
                RadioGroup<RestoreDecision>(
                  groupValue:
                      flow.decisions[item.ledgerBackupId] ??
                      _defaultDecision(item),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(backupRestoreFlowProvider.notifier)
                          .setDecision(item.ledgerBackupId, value);
                    }
                  },
                  child: Column(
                    children: [
                      for (final decision in _decisionsFor(item))
                        RadioListTile<RestoreDecision>(
                          title: Text(_decisionLabel(context, decision)),
                          value: decision,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.p12),
          child: FilledButton(
            onPressed: () =>
                ref.read(backupRestoreFlowProvider.notifier).proceedToConfirm(),
            child: Text(l10n.restoreStep4Title),
          ),
        ),
      ],
    );
  }

  /// 决策选项：云端账本 3 选（恢复为本地副本/登录原账号/暂不处理）；
  /// 本地账本 2 选（恢复为本地账本/暂不处理）。
  List<RestoreDecision> _decisionsFor(RestoreLedgerItem item) {
    if (item.storageOrigin == LedgerStorageOrigin.cloud) {
      return [
        RestoreDecision.forkCloudToLocal,
        RestoreDecision.reconnect,
        RestoreDecision.skip,
      ];
    }
    return [RestoreDecision.restoreLocal, RestoreDecision.skip];
  }

  RestoreDecision _defaultDecision(RestoreLedgerItem item) =>
      item.storageOrigin == LedgerStorageOrigin.cloud
      ? RestoreDecision.forkCloudToLocal
      : RestoreDecision.restoreLocal;

  String _decisionLabel(BuildContext context, RestoreDecision decision) {
    final l10n = AppLocalizations.of(context);
    return switch (decision) {
      RestoreDecision.restoreLocal => l10n.restoreDecisionRestoreLocal,
      RestoreDecision.forkCloudToLocal => l10n.restoreDecisionFork,
      RestoreDecision.reconnect => l10n.restoreDecisionReconnect,
      RestoreDecision.skip => l10n.restoreDecisionSkip,
    };
  }

  // ---------------------------------------------------------------
  // Step 4：确认导入结果 → 单事务应用
  // ---------------------------------------------------------------

  Widget _buildStep4(BuildContext context, BackupRestoreFlowState flow) {
    final l10n = AppLocalizations.of(context);
    if (flow.report != null) {
      // 完成态：展示映射清单与结果
      return ListView(
        padding: const EdgeInsets.all(AppDimens.p16),
        children: [
          PrimaryHeader(
            title: l10n.restoreDone,
            subtitle: flow.selected?.sizeLabel ?? '',
          ),
          for (final entry in flow.report!.entries)
            SectionCard(
              margin: const EdgeInsets.only(bottom: AppDimens.p12),
              child: AppListTile(
                leading: Icons.check_circle_outline,
                title: entry.name,
                subtitle: _resultLabel(context, entry),
              ),
            ),
        ],
      );
    }
    final errorText = _errorText(context, flow.error);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        PrimaryHeader(
          title: l10n.restoreStep4Title,
          subtitle: l10n.restoreNoOverwrite,
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Text(
              errorText,
              style: TextStyle(color: AppTokens.error(context)),
            ),
          ),
        for (final item in flow.items)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: AppListTile(
              leading: Icons.menu_book_outlined,
              title: item.name,
              subtitle: _decisionLabel(
                context,
                flow.decisions[item.ledgerBackupId] ?? RestoreDecision.skip,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: AppDimens.p12),
          child: FilledButton(
            onPressed: flow.loading
                ? null
                : () async {
                    await ref.read(backupRestoreFlowProvider.notifier).apply();
                  },
            child: Text(
              flow.loading ? l10n.restoreApplying : l10n.restoreApply,
            ),
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
    };
  }

  String _formatBackupTime(DateTime time) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = time.toLocal();
    return '${local.month}月${local.day}日 ${two(local.hour)}:${two(local.minute)}';
  }
}
