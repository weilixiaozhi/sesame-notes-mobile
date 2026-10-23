import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 笔记列表与详情共用删除确认，持久化和目标复核由应用用例执行。
Future<bool> confirmMemoEntryDeletion(
  BuildContext context,
  WidgetRef ref,
  MemoEntry entry, {
  PrivateBookTarget? target,
  required String pageId,
}) async {
  final l10n = AppLocalizations.of(context);
  final parentContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  try {
    final actions = ref.read(memoActionsProvider);
    final fixed = target ?? await actions.target(entry.memoBookId);
    if (!context.mounted) return false;
    return await AppDialog.confirmAsync(
      context,
      title: l10n.memoDeleteEntry,
      message: l10n.memoDeleteEntryMessage,
      onConfirm: () async {
        final analyticsContext = ref
            .read(productAnalyticsControllerProvider)
            .captureContext(parent: parentContext);
        await actions.deleteEntry(entry, fixed);
        if (context.mounted) {
          ref
              .read(productAnalyticsControllerProvider)
              .trackAction(
                pageId: pageId,
                action: entry.isCard
                    ? ProductAction.credentialsDeleted
                    : ProductAction.memosNoteDeleted,
                context: analyticsContext,
              );
        }
      },
      errorMessage: (_) => l10n.memoUnavailable,
    );
  } catch (error, stackTrace) {
    logger.error('MemoActions', '删除内容失败', error.runtimeType, stackTrace);
    if (context.mounted) showToast(context, l10n.memoUnavailable);
    return false;
  }
}
