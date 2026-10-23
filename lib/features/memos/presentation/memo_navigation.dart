import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/shared/widgets/app_action_grid.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/app_mode.dart';
import '../../../l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/icons/app_icons.dart';
import '../application/memo_providers.dart';

/// 新建与编辑统一通过全局命名路由进入。
Future<String?> createMemoBook(BuildContext context) =>
    context.pushNamed<String>(Routes.memoBookEdit);

/// 底部 + 号：账号密码与空白笔记共用一个入口，弹窗规格与健身业务域一致。
Future<void> openMemoCreateSheet(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  final action = await showAppSheet<String>(
    context: context,
    child: AppSheet(
      title: l.commonAdd,
      child: SingleChildScrollView(
        child: AppActionGrid<String>(
          actions: [
            (value: 'note', icon: AppIcons.edit, label: l.calendarNote),
            (value: 'card', icon: AppIcons.lock, label: l.calendarCredential),
          ],
          onSelected: (value) => Navigator.pop(context, value),
        ),
      ),
    ),
  );
  if (!context.mounted) return;
  switch (action) {
    case 'note':
      await openMemoEditor(context, ref);
    case 'card':
      await openMemoCredentialEditor(context, ref);
  }
}

/// 打开普通笔记编辑器；没有任何本子时由首条记录顺带创建默认本子。
Future<void> openMemoEditor(
  BuildContext context,
  WidgetRef ref, {
  String? entryId,
}) async {
  final analyticsContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  if (entryId == null) {
    trackProductEntryAction(
      context,
      ref.read,
      fallbackPageId: 'memos',
      action: ProductAction.memosNoteCreateClick,
      context: analyticsContext,
    );
  }
  final l = AppLocalizations.of(context);
  try {
    var id = ref.read(currentMemoBookIdProvider).value;
    if (id == null) {
      // 没有任何本子时由首条记录顺带创建默认本子；只是当前未选中时保持既有建本入口。
      id = await ref
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.memos, l);
      if (id == null) {
        if (!context.mounted) return;
        id = await createMemoBook(context);
      }
      if (!context.mounted) return;
    }
    await _openEditor(
      context,
      ref,
      bookId: id,
      entryId: entryId,
      analyticsContext: analyticsContext,
    );
  } catch (error, stackTrace) {
    logger.error(
      'MemoNavigation',
      '准备笔记编辑器失败',
      safeErrorSummary(error),
      stackTrace,
    );
    if (context.mounted) showToast(context, l.memoUnavailable);
  }
}

/// 打开账号密码卡片编辑器；没有账号密码本时顺带创建一本并设为当前本。
Future<void> openMemoCredentialEditor(
  BuildContext context,
  WidgetRef ref,
) async {
  final analyticsContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  trackProductEntryAction(
    context,
    ref.read,
    fallbackPageId: 'credentials',
    action: ProductAction.credentialsCreateClick,
    context: analyticsContext,
  );
  final l = AppLocalizations.of(context);
  try {
    final bookId = await ref
        .read(defaultBookProvisionerProvider)
        .ensureCredentialBook(l);
    if (!context.mounted) return;
    await _openEditor(
      context,
      ref,
      bookId: bookId,
      entryId: null,
      analyticsContext: analyticsContext,
    );
  } catch (error, stackTrace) {
    logger.error(
      'MemoNavigation',
      '准备账号卡片编辑器失败',
      safeErrorSummary(error),
      stackTrace,
    );
    if (context.mounted) showToast(context, l.memoUnavailable);
  }
}

/// 编辑器只接收应用用例复核后的原本、账号、绑定和可选正文。
Future<void> _openEditor(
  BuildContext context,
  WidgetRef ref, {
  required String? bookId,
  String? entryId,
  required ProductAnalyticsContext analyticsContext,
}) async {
  final l10n = AppLocalizations.of(context);
  try {
    if (bookId == null || !context.mounted) return;
    final snapshot = await ref
        .read(memoActionsProvider)
        .prepareEditor(bookId, entryId: entryId);
    if (!context.mounted) return;
    await context.pushNamed(
      Routes.memoEditor,
      extra: ProductAnalyticsNavigation(
        context: analyticsContext,
        arguments: (
          book: snapshot.book,
          target: snapshot.target,
          entryId: entryId ?? const Uuid().v4(),
          entry: snapshot.entry,
        ),
      ),
    );
  } catch (_) {
    if (context.mounted) showToast(context, l10n.memoUnavailable);
  }
}
