// 同步状态横幅：STALE_BINDING 提示 + 冲突列表与解决。
//
// SYNC_ID_MISMATCH 进入 STALE_BINDING 后由用户决策
// （放弃本地修改重新下载 / 保留数据 Detach 为本地副本），禁止自动覆盖；
// 冲突 UI 提供「保留本地（rebase 提交）/ 采用云端」二选一。
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 账本详情页顶部的同步状态横幅（冲突与绑定失效提示）。
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerId = ref.watch(currentLedgerIdProvider);
    if (ledgerId.isEmpty) return const SizedBox.shrink();
    final conflicts =
        ref.watch(ledgerOpenConflictsProvider).value ??
        const <SyncConflictView>[];
    final bindingStatus = ref.watch(ledgerBindingStatusProvider).value;

    if (bindingStatus == 'stale') {
      return _StaleBindingBanner(ledgerId: ledgerId);
    }
    if (conflicts.isNotEmpty) {
      return _ConflictBanner(conflicts: conflicts);
    }
    return const SizedBox.shrink();
  }
}

/// STALE_BINDING 横幅：同步身份与云端时间线不一致，同步已暂停。
class _StaleBindingBanner extends ConsumerWidget {
  final String ledgerId;

  const _StaleBindingBanner({required this.ledgerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '同步身份已失效（云端时间线已更换），本地修改已保存为保护副本，同步已暂停',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onErrorContainer),
            ),
            const SizedBox(height: AppDimens.p8),
            Row(
              children: [
                TextButton(
                  onPressed: () => _abandonLocal(context, ref),
                  // 本地修改已自动保护为副本，此处是用户显式放弃原行
                  child: const Text('放弃本地修改，重新下载（副本已保留）'),
                ),
                TextButton(
                  onPressed: () => _detachToLocal(context, ref),
                  child: const Text('保留数据，转为本地账本'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 放弃本地修改：清待推送队列并按服务端当前时间线全量重建。
  Future<void> _abandonLocal(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(syncServiceProvider)
          .abandonLocalChanges(ledgerId: ledgerId);
      ref.invalidate(currentLedgerProvider);
    } catch (e, st) {
      logger.error('SyncStatusBanner', '放弃本地修改失败', e, st);
    }
  }

  /// 保留数据转本地：清除同步身份与归属（Detach），数据原样保留。
  Future<void> _detachToLocal(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(ledgerActionsProvider).detachFromCloud(ledgerId);
      ref.invalidate(currentLedgerProvider);
      ref.read(currentLedgerIdProvider.notifier).set(ledgerId);
    } catch (e, st) {
      logger.error('SyncStatusBanner', '转为本地账本失败', e, st);
    }
  }
}

/// 冲突横幅：点击展开解决弹窗（保留本地 / 采用云端）。
class _ConflictBanner extends ConsumerWidget {
  final List<SyncConflictView> conflicts;

  const _ConflictBanner({required this.conflicts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.tertiaryContainer,
      child: InkWell(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => _ConflictSheet(conflicts: conflicts),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p16,
            vertical: AppDimens.p12,
          ),
          child: Row(
            children: [
              Icon(
                Icons.sync_problem_outlined,
                color: colors.onTertiaryContainer,
                size: 18,
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Text(
                  '${conflicts.length} 个同步冲突待解决（点击查看）',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 冲突解决弹窗：列出每个冲突实体与两个解决选项。
class _ConflictSheet extends ConsumerWidget {
  final List<SyncConflictView> conflicts;

  const _ConflictSheet({required this.conflicts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('同步冲突', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.p8),
            for (final conflict in conflicts) _ConflictTile(conflict: conflict),
          ],
        ),
      ),
    );
  }
}

/// 单个冲突：本地/云端摘要 + 解决按钮。
class _ConflictTile extends ConsumerWidget {
  final SyncConflictView conflict;

  const _ConflictTile({required this.conflict});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppDimens.p4),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交易 ${conflict.entityId.substring(0, 8)}…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppDimens.p4),
            Text(
              '云端版本：修订 ${conflict.remoteRevision}（本地基线：${conflict.baseRevision}）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppDimens.p8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _keepLocal(context, ref),
                    child: const Text('保留本地'),
                  ),
                ),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _adoptRemote(context, ref),
                    child: const Text('采用云端'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 保留本地：以最新 remote revision 为 base 重新提交本地值。
  Future<void> _keepLocal(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(syncServiceProvider).resolveConflictKeepLocal(conflict.id);
      // 触发一轮同步把 resolution mutation 推上去
      unawaited(ref.read(syncCoordinatorProvider).run());
      ref.invalidate(ledgerOpenConflictsProvider);
    } catch (e, st) {
      logger.error('SyncStatusBanner', '保留本地失败', e, st);
    }
  }

  /// 采用云端：本地采纳服务端当前状态。
  Future<void> _adoptRemote(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(syncServiceProvider)
          .resolveConflictAdoptRemote(conflict.id);
      ref.invalidate(ledgerOpenConflictsProvider);
      ref.invalidate(currentLedgerProvider);
    } catch (e, st) {
      logger.error('SyncStatusBanner', '采用云端失败', e, st);
    }
  }
}
