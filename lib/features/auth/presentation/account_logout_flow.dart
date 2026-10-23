import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/account_logout_actions.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 同步后保留登录状态，只有明确选择保护副本才继续退出。
enum _PendingLogoutAction { synchronize, keepLocalCopy }

/// 展示统一的登出确认流程，并由账号切换协调器执行完整登出协议。
///
/// 返回 `true` 表示本地登出已完成；pending/conflict 必须经用户显式确认
/// Safety Fork，取消或失败均返回 `false`。
Future<bool> confirmAccountLogout(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  // 所有确认与异步读取固定在打开流程时的身份代次，令牌刷新不影响此代次。
  final session = ref.read(accountLogoutActionsProvider).start();

  try {
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.profileLogoutConfirmTitle,
      message: '${l10n.profileLogoutConfirmMessage}\n${l10n.profileLogoutHint}',
      okLabel: l10n.profileLogout,
    );
    if (confirmed != true || !context.mounted) return false;

    try {
      return await session.logout();
    } on PendingChangesBlockedException {
      // 未同步修改只能在用户明确同意保留本地副本后继续清理账号域。
      final issues = await session.loadPendingIssues();
      if (!context.mounted) return false;
      final action = await showDialog<_PendingLogoutAction>(
        context: context,
        builder: (dialogContext) => AppContentDialog(
          title: l10n.profileLogoutPendingTitle,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.profileLogoutPendingMessage),
                Text(
                  l10n.syncCenterPending(
                    issues.fold(0, (total, issue) => total + issue.count),
                  ),
                ),
                for (final title
                    in issues
                        .map((issue) => issue.title)
                        .where((title) => title.isNotEmpty)
                        .toSet()) ...[
                  const SizedBox(height: AppDimens.p8),
                  Text(title),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(AppLocalizations.of(dialogContext).commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_PendingLogoutAction.synchronize),
              child: Text(l10n.profileLogoutSyncFirst),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_PendingLogoutAction.keepLocalCopy),
              child: Text(l10n.profileLogoutKeepLocalCopy),
            ),
          ],
        ),
      );
      if (action == null || !context.mounted) return false;
      if (action == _PendingLogoutAction.synchronize) {
        return await session.synchronizeFirst();
      }
      return await session.keepLocalCopyAndLogout();
    }
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
