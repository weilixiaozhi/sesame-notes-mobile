import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 展示统一的登出确认流程，并由账号切换协调器执行完整登出协议。
///
/// 返回 `true` 表示本地登出已完成；pending/conflict 必须经用户显式确认
/// Safety Fork，取消或失败均返回 `false`。
Future<bool> confirmAccountLogout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  try {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileLogoutConfirmTitle),
        content: Text(
          '${l10n.profileLogoutConfirmMessage}\n${l10n.profileLogoutHint}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(dialogContext).commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.profileLogout),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return false;

    try {
      await ref.read(accountSwitchCoordinatorProvider).logout();
    } on PendingChangesBlockedException catch (blocked) {
      // 未同步修改只能在用户明确同意保留本地副本后继续清理账号域。
      if (!context.mounted) return false;
      final forkConfirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.profileLogoutPendingTitle),
          content: Text('${l10n.profileLogoutPendingMessage}\n$blocked'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(AppLocalizations.of(dialogContext).commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.profileLogoutKeepLocalCopy),
            ),
          ],
        ),
      );
      if (forkConfirmed != true || !context.mounted) return false;
      await ref
          .read(accountSwitchCoordinatorProvider)
          .logout(policy: AccountSwitchPolicy.safetyFork);
    }
    return true;
  } catch (error, stackTrace) {
    logger.error('AccountLogoutFlow', '退出账号失败', error, stackTrace);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.commonOperationFailed)));
    }
    return false;
  }
}
