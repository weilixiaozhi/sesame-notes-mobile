import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/local_book_migration.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';

/// 注册经登录页返回时，等待两层认证页面都结束退场动画。
final _authExitTransitionsProvider = Provider((_) => <Future<Object?>>{});

/// 先完成成功导航，再在目标页面询问本机本子的迁移选择。
Future<void> finishAuthenticationNavigation(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final navigator = Navigator.of(context, rootNavigator: true);
  final router = GoRouter.of(context);
  final route = ModalRoute.of(context);
  final transitions = container.read(_authExitTransitionsProvider);
  final departure = route?.completed ?? Future<Object?>.value();
  try {
    transitions.add(departure);
    try {
      if (router.canPop()) {
        router.pop(true);
      } else {
        router.go(Routes.ledgers);
      }
      await departure;
    } finally {
      transitions.remove(departure);
    }
    await WidgetsBinding.instance.endOfFrame;
    await Future.wait(transitions.toList());
    await WidgetsBinding.instance.endOfFrame;
    if (!navigator.mounted ||
        [
          Routes.authLogin,
          Routes.authRegister,
        ].contains(router.state.uri.path)) {
      return;
    }
    final migration = container.read(localBookMigrationProvider);
    final plan = await migration.previewForPrompt();
    if (plan == null || plan.count == 0 || !navigator.mounted) return;
    final feedback = navigator.overlay?.context;
    if (feedback == null || !feedback.mounted) return;
    final l10n = AppLocalizations.of(feedback);
    final confirmed = await AppDialog.confirmAsync(
      feedback,
      title: l10n.localBookMigrationTitle,
      message: l10n.localBookMigrationMessage(plan.count),
      confirmLabel: l10n.localBookMigrationConfirm,
      cancelLabel: l10n.localBookMigrationKeepLocal,
      onConfirm: () => migration.migrate(plan),
      errorMessage: (_) => l10n.localBookMigrationFailed,
    );
    if (confirmed) {
      final overlay = navigator.mounted ? navigator.overlay : null;
      if (overlay != null) {
        showToastOnOverlay(overlay, l10n.localBookMigrationSuccess);
      }
      unawaited(_syncMigratedBooks(container));
    }
  } catch (error, stackTrace) {
    // 登录已经成功；迁移提示失败不回退登录状态，也不移动任何未确认的本子。
    logger.error(
      'PostLoginMigration',
      '登录后本机迁移流程未完成',
      safeErrorSummary(error),
      stackTrace,
    );
    if (!navigator.mounted) return;
    final overlay = navigator.overlay;
    if (overlay != null && overlay.mounted) {
      showToastOnOverlay(
        overlay,
        AppLocalizations.of(overlay.context).commonOperationFailed,
      );
    }
  }
}

/// 本机事务提交后启动既有同步流程，网络失败由已持久化的队列继续重试。
Future<void> _syncMigratedBooks(ProviderContainer container) async {
  try {
    final result = await container.read(syncCoordinatorProvider).run();
    if (result.error != null) {
      logger.warning('PostLoginMigration', '本子已加入同步队列，等待重试');
    }
  } catch (error, stackTrace) {
    logger.error(
      'PostLoginMigration',
      '迁移后的同步待重试',
      safeErrorSummary(error),
      stackTrace,
    );
  }
}
