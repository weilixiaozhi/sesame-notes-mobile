import 'package:flutter/material.dart';

import '../../../../data/models/sync_issue.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 决策携带用户实际看过的版本；网络请求、回执及重试身份由同步层维护。
typedef CategoryConflictDecision =
    Future<String?> Function({
      required String conflictId,
      required String expectedDecisionVersion,
      required bool keepLocal,
      required bool restoreDeleted,
    });

/// 分类冲突保持原身份，独立于其他业务的“保留本地副本”工作流。
class CategoryConflictActions extends StatefulWidget {
  const CategoryConflictActions({
    super.key,
    required this.issue,
    required this.onResolve,
    required this.onRetry,
    required this.onRefresh,
    this.busy = false,
  });

  final SyncIssue issue;
  final CategoryConflictDecision onResolve;
  final Future<String?> Function() onRetry;
  final Future<String?> Function() onRefresh;
  final bool busy;

  @override
  State<CategoryConflictActions> createState() =>
      _CategoryConflictActionsState();
}

class _CategoryConflictActionsState extends State<CategoryConflictActions> {
  bool _working = false;
  bool _submitting = false;
  String? _error;

  bool _deleted(Map<String, dynamic>? payload) =>
      payload?['deleted'] == true || payload?['deleted_at'] != null;

  /// 确认前固定所见版本；弹窗期间同步刷新也不能替用户确认新的快照。
  Future<void> _choose(bool keepLocal) async {
    final reviewed = widget.issue;
    final version = reviewed.decisionVersion;
    if (_working ||
        widget.busy ||
        reviewed.resolutionPending ||
        version == null ||
        version.isEmpty) {
      return;
    }
    setState(() {
      _working = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      final localDeleted = reviewed.deletion || _deleted(reviewed.local);
      final confirmed = await AppDialog.confirm(
        context,
        title: keepLocal && localDeleted
            ? l.categoryConflictDeleteTitle
            : keepLocal
            ? l.categoryConflictUseLocal
            : l.categoryConflictUseCloud,
        message: keepLocal && localDeleted
            ? l.categoryConflictDeleteMessage
            : keepLocal
            ? l.categoryConflictChooseLocal
            : l.categoryConflictChooseCloud,
      );
      if (confirmed != true || !mounted) return;
      final restore = keepLocal && !localDeleted && _deleted(reviewed.remote);
      if (restore) {
        final confirmedRestore = await AppDialog.confirm(
          context,
          title: l.categoryConflictRestoreTitle,
          message: l.categoryConflictRestoreMessage,
          okLabel: l.categoryConflictRestore,
        );
        if (confirmedRestore != true || !mounted) return;
      }
      // 这里的检查提供即时反馈；同步层仍须在冻结事务内再核对版本。
      if (widget.issue.id != reviewed.id ||
          widget.issue.decisionVersion != version ||
          widget.issue.resolutionPending) {
        setState(() => _error = l.categoryConflictChanged);
        return;
      }
      setState(() => _submitting = true);
      final error = await widget.onResolve(
        conflictId: reviewed.id,
        expectedDecisionVersion: version,
        keepLocal: keepLocal,
        restoreDeleted: restore,
      );
      if (mounted) setState(() => _error = error);
    } catch (_) {
      if (mounted) setState(() => _error = l.syncCenterActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _submitting = false;
        });
      }
    }
  }

  /// 未知回执只重试同步层已冻结的决定，不重新拼接或切换选择。
  Future<void> _run(Future<String?> Function() work) async {
    if (_working || widget.busy) return;
    setState(() {
      _working = true;
      _submitting = true;
      _error = null;
    });
    try {
      final error = await work();
      if (mounted) setState(() => _error = error);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).syncCenterActionFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final issue = widget.issue;
    final busy = _working || widget.busy;
    final pending = issue.resolutionPending;
    final ready =
        issue.decisionVersion?.isNotEmpty == true &&
        issue.remote != null &&
        (issue.local != null || issue.deletion);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimens.p16,
        0,
        AppDimens.p16,
        AppDimens.p12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.categoryConflictExplanation),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(l.syncCenterCompare),
            children: [
              _CategoryConflictVersion(
                title: l.categoryConflictSubmitted,
                payload: issue.local,
                deleted: issue.deletion || _deleted(issue.local),
              ),
              _CategoryConflictVersion(
                title: l.categoryConflictCloud,
                payload: issue.remote,
                deleted: _deleted(issue.remote),
              ),
            ],
          ),
          if (pending || !ready)
            Semantics(
              liveRegion: true,
              child: Text(
                pending
                    ? l.categoryConflictPending
                    : l.categoryConflictRefreshRequired,
              ),
            ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: AppTextTokens.body(
                  context,
                ).copyWith(color: AppTokens.error(context)),
              ),
            ),
          if (_submitting) const LinearProgressIndicator(),
          Wrap(
            spacing: AppDimens.p8,
            children: [
              TextButton(
                onPressed: busy || pending || !ready
                    ? null
                    : () => _choose(true),
                child: Text(l.categoryConflictUseLocal),
              ),
              TextButton(
                onPressed: busy || pending || !ready
                    ? null
                    : () => _choose(false),
                child: Text(l.categoryConflictUseCloud),
              ),
              if (pending)
                TextButton(
                  onPressed: busy ? null : () => _run(widget.onRetry),
                  child: Text(l.categoryConflictRetry),
                )
              else
                TextButton(
                  onPressed: busy ? null : () => _run(widget.onRefresh),
                  child: Text(l.categoryConflictRefresh),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 展示业务字段和图标，不泄漏账号、设备、请求身份或服务端版本标记。
class _CategoryConflictVersion extends StatelessWidget {
  const _CategoryConflictVersion({
    required this.title,
    required this.payload,
    required this.deleted,
  });

  final String title;
  final Map<String, dynamic>? payload;
  final bool deleted;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = payload;
    final name = data?['name'] as String?;
    final icon = data?['icon'] as String?;
    final parent = data?['parent_name'] as String?;
    final level = data?['level'];
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.p12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextTokens.strongTitle(context)),
          if (deleted) Text(l.syncCenterDeleted),
          if (data == null && !deleted)
            Text(l.categoryConflictUnavailable)
          else if (data != null) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Semantics(
                label: l.categoryIconLabel,
                child: CategoryIconWidget(iconName: icon, showBackground: true),
              ),
              title: SelectableText(name ?? ''),
              subtitle: Text(
                level == 1
                    ? l.categoryTopLevelLabel
                    : l.categorySecondLevelLabel,
              ),
            ),
            Text(
              '${l.categoryConflictType}：${data['kind'] == 'expense' ? l.categoryExpense : l.categoryConflictUnavailable}',
            ),
            if (level == 2)
              Text(
                '${l.categoryParentCategoryTitle}：${parent ?? l.categoryConflictParentMissing}',
              ),
            if (data['sort_order'] is num)
              Text(l.categoryConflictPosition(data['sort_order'].toString())),
          ],
        ],
      ),
    );
  }
}
