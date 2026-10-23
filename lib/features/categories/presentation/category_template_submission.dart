import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/category_template_providers.dart';
import '../../../core/logging/logger_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/category_query_providers.dart';
import '../../../shared/widgets/app_content_dialog.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/toast.dart';

/// 展示实际完成的结果，云端候选不计为已经添加或恢复。
class TemplateSubmissionSummary {
  const TemplateSubmissionSummary({
    required this.created,
    required this.restored,
    required this.pendingCount,
  });

  final int created;
  final int restored;
  final int pendingCount;

  /// 新增、恢复和已持久化的待确认意图都属于已提交的结果。
  bool get hasChanges => created > 0 || restored > 0 || pendingCount > 0;

  /// 只展示已提交的实际数量，待确认意图单独说明。
  String describe(AppLocalizations l10n) {
    final messages = [
      if (created > 0) l10n.categoryTemplateAddSuccess(created),
      if (restored > 0) l10n.categoryTemplateRestored(restored),
      if (pendingCount > 0) l10n.categoryTemplatePending(pendingCount),
    ];
    return messages.isEmpty
        ? l10n.categoryTemplateNoChanges
        : messages.join('\n');
  }
}

/// 后续恢复失败时保留此前各轮已提交结果，以及原始错误和堆栈。
class TemplateSubmissionFailure implements Exception {
  /// 每轮成功提交后累积摘要，原始错误由页面统一记录。
  const TemplateSubmissionFailure({
    required this.completed,
    required this.cause,
    required this.stackTrace,
  });

  final TemplateSubmissionSummary completed;
  final Object cause;
  final StackTrace stackTrace;

  /// 有已提交结果时明确说明剩余未完成，没有结果时沿用普通失败提示。
  String describe(AppLocalizations l10n) => completed.hasChanges
      ? l10n.categoryTemplatePartiallyCompleted(completed.describe(l10n))
      : l10n.categoryTemplateAddFailed(l10n.commonOperationFailed);
}

/// 统一记录原始失败；仅向原账号会话展示摘要并刷新已提交的目录。
void reportCategoryTemplateSubmissionFailure(
  BuildContext? context, {
  required WidgetRef ref,
  required TemplateInsertSession session,
  required Object error,
  required StackTrace stackTrace,
}) {
  final failure = error is TemplateSubmissionFailure ? error : null;
  logger.error(
    'categoryTemplate',
    '模板写入失败',
    failure?.cause ?? error,
    failure?.stackTrace ?? stackTrace,
  );
  if (context == null || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  var message = l10n.categoryTemplateAddFailed(l10n.commonOperationFailed);
  if (failure != null && failure.completed.hasChanges) {
    try {
      // 刷新目录后，页面会过滤已完成的选择，剩余项继续保留供用户重试。
      session.assertCurrent();
      ref.invalidate(categoriesWithCountProvider);
      ref.invalidate(categoryTemplatePendingIdsProvider);
      message = failure.describe(l10n);
    } catch (scopeError, scopeStack) {
      logger.error('categoryTemplate', '模板结果会话已失效', scopeError, scopeStack);
    }
  }
  showToast(context, message);
}

/// 模板恢复只提交用户明确确认的原身份，取消或返回不恢复墓碑。
/// [execute] 由应用层固定账号会话，并在每次调用中读取最新本地状态。
Future<TemplateSubmissionSummary?> submitCategoryTemplatePlan(
  BuildContext context, {
  required int count,
  required Future<TemplateInsertResult> Function(Set<String> restoreIds)
  execute,
  required void Function(bool writing) onWriting,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await AppDialog.confirm(
    context,
    title: l10n.categoryTemplateConfirmTitle,
    message: l10n.categoryTemplateConfirmMessage(count),
  );
  if (confirmed != true || !context.mounted) return null;

  /// 每轮写入独立完成，等待下一次用户确认时不持有写入状态。
  Future<TemplateInsertResult> write(Set<String> ids) async {
    onWriting(true);
    try {
      return await execute(ids);
    } finally {
      onWriting(false);
    }
  }

  final initial = await write(const {});
  var created = initial.created;
  var restored = initial.restored;
  final pendingIds = {for (final item in initial.pending) item.syncId};
  final approvedIds = <String>{};
  var requiredRestores = initial.localRestoreRequired;
  try {
    // 父分类恢复后才可能发现子分类墓碑；每轮只确认新身份，避免隐式连带恢复。
    while (requiredRestores.isNotEmpty) {
      if (!context.mounted) break;
      final unreviewed = [
        for (final item in requiredRestores)
          if (!approvedIds.contains(item.syncId)) item,
      ];
      if (unreviewed.isEmpty) break;
      final restore = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppContentDialog(
          title: l10n.categoryTemplateRestoreTitle,
          content: SingleChildScrollView(
            child: Text(
              l10n.categoryTemplateRestoreMessage(
                unreviewed.map((item) => item.name).join('、'),
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              autofocus: true,
              onPressed: () {
                if (ModalRoute.of(dialogContext)?.isCurrent == true) {
                  Navigator.of(dialogContext).pop(false);
                }
              },
              child: Text(l10n.commonCancel),
            ),
            AppPrimaryButton(
              fullWidth: false,
              label: l10n.categoryTemplateRestoreConfirm,
              onPressed: () {
                if (ModalRoute.of(dialogContext)?.isCurrent == true) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
            ),
          ],
        ),
      );
      if (restore != true || !context.mounted) break;
      approvedIds.addAll(unreviewed.map((item) => item.syncId));
      final result = await write(Set.unmodifiable(approvedIds));
      created += result.created;
      restored += result.restored;
      pendingIds.addAll(result.pending.map((item) => item.syncId));
      requiredRestores = result.localRestoreRequired;
    }
  } catch (error, stackTrace) {
    // 每轮事务已经独立提交，失败只能影响当前轮，不能丢弃此前的结果。
    Error.throwWithStackTrace(
      TemplateSubmissionFailure(
        completed: TemplateSubmissionSummary(
          created: created,
          restored: restored,
          pendingCount: pendingIds.length,
        ),
        cause: error,
        stackTrace: stackTrace,
      ),
      stackTrace,
    );
  }
  return TemplateSubmissionSummary(
    created: created,
    restored: restored,
    pendingCount: pendingIds.length,
  );
}
