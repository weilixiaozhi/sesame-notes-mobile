import 'package:sesame_notes/features/fitness/application/fitness_space_queries.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_workout_navigation.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';

import '../../../shared/providers/fitness_space_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';

import '../../../data/models/sync_issue.dart';
import '../../../infrastructure/api/api_error_mapper.dart';
import '../../../l10n/app_localizations.dart';

import 'package:sesame_notes/navigation/route_consts.dart';

import '../../../shared/providers/sync_issues_provider.dart';
import '../../../shared/providers/sync_providers.dart';
import '../../../shared/providers/cloud_sync_run_feedback_provider.dart';
import '../../../shared/providers/fitness_recovery_actions_provider.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/ui_state_providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/app_status_banner.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import '../../ledgers/application/ledger_actions.dart';
import '../../transactions/application/transaction_actions.dart';
import '../../transactions/presentation/widgets/transaction/transaction_edit_utils.dart';
import '../../days/presentation/widgets/day_widgets.dart';
import '../../memos/presentation/memo_detail_sheet.dart';
import '../../categories/application/category_actions.dart';
import 'widgets/category_conflict_actions.dart';
import '../application/sync_center_session.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 页面自身及同步编排器已经脱敏的说明可以展示，未知底层异常继续隐藏。
class _SyncCenterActionError implements Exception {
  const _SyncCenterActionError(this.message);
  final String message;
}

/// 全局待处理页只读取事实与提交明确决策，不自行维护同步或删除状态机。
class SyncCenterPage extends ConsumerStatefulWidget {
  const SyncCenterPage({super.key});
  @override
  ConsumerState<SyncCenterPage> createState() => _SyncCenterPageState();
}

class _SyncCenterPageState extends ConsumerState<SyncCenterPage> {
  bool _busy = false;
  String? _categoryError;
  String? _actionError;
  SyncTarget? _failedTarget;
  int? _actionGeneration;

  /// 失败说明保留在页面与原事项中，忙碌状态独立解除，不丢失可操作原因。
  Future<void> _run(Future<void> Function() work, {SyncTarget? target}) async {
    if (_busy) return;
    final generation = ref.read(syncCenterSessionGenerationProvider);
    setState(() {
      _busy = true;
      _categoryError = null;
      _actionError = null;
      _failedTarget = null;
      _actionGeneration = generation;
    });
    try {
      await work();
    } catch (error, stack) {
      logger.error(
        'SyncCenter',
        '同步事项操作未完成: type=${target?.type}',
        safeErrorSummary(error),
        stack,
      );
      if (mounted &&
          ref.read(syncCenterSessionGenerationProvider) == generation) {
        final failure = error is _SyncCenterActionError
            ? null
            : cloudOperationFailure(
                error,
                fallback: categoryActionErrorMessage(
                  error,
                  AppLocalizations.of(context).syncCenterActionFailed,
                ),
                target: target,
              );
        final message = error is _SyncCenterActionError
            ? error.message
            : failure!.message;
        setState(() {
          _actionError = message;
          _failedTarget = failure?.target ?? target;
        });
        showToast(context, message);
      }
    } finally {
      if (mounted) {
        ref.invalidate(syncIssuesProvider);
        ref.invalidate(syncCenterIssuesProvider);
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _refresh() => _run(() async {
    final result = await ref.read(syncCoordinatorProvider).refreshData();
    _requireSuccess(result);
  });

  /// 编排器结果只展示其公开失败说明，失败不能当成正常完成。
  void _requireSuccess(SyncRunResult result) {
    if (!result.ok) {
      if (result.failure != null) throw result.failure!;
      throw _SyncCenterActionError(
        result.error ?? AppLocalizations.of(context).syncCenterActionFailed,
      );
    }
  }

  /// 普通待上传重试执行上传确认，不把整账号重新下载作为上传按钮的动作。
  Future<void> _retryPending(SyncIssue issue) => _run(() async {
    final result = await ref.read(syncCoordinatorProvider).run();
    _requireSuccess(result);
  }, target: issue.target);

  /// 只有存在业务编辑入口且尚未删除的事项提供编辑，不从同步状态推测可恢复身份。
  bool _canEdit(SyncIssue issue) =>
      !issue.deletion &&
      !issue.uploadOutcomeUnknown &&
      const {
        'category',
        'transaction',
        'ledger',
        'day_book',
        'day_event',
        'memo_book',
        'memo_entry',
        'fitness_space',
        'fitness_workout',
        'fitness_plan',
        'fitness_template',
        'member',
        'recurring_transaction',
        'exchange_rate_override',
      }.contains(issue.target.type);

  /// 错误定位没有提供父本时仍按实体匹配；已提供父本时必须属于同一业务范围。
  bool _matchesTarget(SyncTarget? failure, SyncTarget issue) =>
      failure != null &&
      failure.type == issue.type &&
      failure.id == issue.id &&
      (failure.parentId == null ||
          issue.parentId == null ||
          failure.parentId == issue.parentId);

  Future<void> _resolve(SyncIssue issue, bool remote) async {
    if (!remote &&
        issue.deletion &&
        ['ledger', 'day_book', 'memo_book'].contains(issue.target.type)) {
      await _confirmDelete(issue.target);
      return;
    }
    final l = AppLocalizations.of(context);
    if (_busy) setState(() => _busy = false);
    await AppDialog.confirmAsync(
      context,
      title: remote ? l.syncCenterUseRemote : l.syncCenterKeepLocal,
      message: l.syncCenterDecisionConfirm,
      onConfirm: () => _confirmWork(() async {
        if (issue.recovery) {
          final recovery = ref.read(fitnessRecoveryActionsProvider);
          await ref
              .read(syncCoordinatorProvider)
              .runDataOperation(
                (_) => remote
                    ? recovery.adoptBranch(issue.id)
                    : recovery.keepLocal(issue.id),
              );
        } else {
          final coordinator = ref.read(syncCoordinatorProvider);
          final result = remote
              ? await coordinator.resolveConflictAdoptRemote(issue.id)
              : await coordinator.resolveConflictKeepLocal(issue.id);
          _requireSuccess(result);
        }
      }, target: issue.target),
      errorMessage: (error) => cloudOperationFailure(
        error,
        fallback: l.syncCenterActionFailed,
      ).message,
    );
  }

  /// 用户阅读确认内容时没有在途操作，只有真实提交阶段占用页面忙碌状态。
  Future<void> _confirmWork(
    Future<void> Function() work, {
    SyncTarget? target,
  }) async {
    final generation = ref.read(syncCenterSessionGenerationProvider);
    if (_busy) {
      throw _SyncCenterActionError(
        AppLocalizations.of(context).syncCenterActionFailed,
      );
    }
    setState(() => _busy = true);
    try {
      await work();
    } catch (error, stack) {
      logger.error(
        'SyncCenter',
        '确认同步事项失败: type=${target?.type}',
        safeErrorSummary(error),
        stack,
      );
      if (mounted &&
          ref.read(syncCenterSessionGenerationProvider) == generation) {
        final failure = cloudOperationFailure(
          error,
          fallback: AppLocalizations.of(context).syncCenterActionFailed,
          target: target,
        );
        setState(() {
          _actionGeneration = generation;
          _actionError = failure.message;
          _failedTarget = failure.target ?? target;
        });
      }
      rethrow;
    } finally {
      if (mounted) {
        ref.invalidate(syncIssuesProvider);
        ref.invalidate(syncCenterIssuesProvider);
        setState(() => _busy = false);
      }
    }
  }

  /// 分类决策独立于通用副本恢复；失败后重读双方，未知回执由同步层保留。
  Future<String?> _categoryOperation(
    int reviewedGeneration,
    Future<SyncRunResult> Function() operation,
  ) async {
    // 确认弹窗尚未重绘也要拒绝旧身份决定；同步层再保护提交后的异步过程。
    if (ref.read(syncCenterSessionGenerationProvider) != reviewedGeneration) {
      return AppLocalizations.of(context).syncCenterActionFailed;
    }
    if (_busy) return AppLocalizations.of(context).syncCenterActionFailed;
    setState(() {
      _busy = true;
      _categoryError = null;
      _actionGeneration = reviewedGeneration;
    });
    try {
      final result = await operation();
      final error = result.ok
          ? null
          : result.error ??
                (mounted
                    ? AppLocalizations.of(context).syncCenterActionFailed
                    : null);
      if (mounted) setState(() => _categoryError = error);
      return error;
    } catch (error, stack) {
      logger.error('SyncCenter', '分类确认未完成', safeErrorSummary(error), stack);
      if (!mounted) return null;
      final message = cloudOperationFailure(
        error,
        fallback: AppLocalizations.of(context).syncCenterActionFailed,
      ).message;
      setState(() => _categoryError = message);
      return message;
    } finally {
      if (mounted) {
        ref.invalidate(syncIssuesProvider);
        ref.invalidate(syncCenterIssuesProvider);
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _confirmDelete(SyncTarget target) async {
    final coordinator = ref.read(syncCoordinatorProvider);
    final preview = await coordinator.prepareScopeDelete(target);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    if (_busy) setState(() => _busy = false);
    await AppDialog.confirmAsync(
      context,
      title: preview.moving ? l.ledgersActionMoveToLocal : l.commonDelete,
      message: preview.gone
          ? l.syncCenterDeleteGone(preview.name)
          : preview.moving
          ? l.syncCenterMoveReview(preview.name, preview.count)
          : l.syncCenterDeleteReview(preview.name, preview.count),
      onConfirm: () => _confirmWork(
        () => coordinator.confirmScopeDelete(preview),
        target: target,
      ),
      errorMessage: (error) => cloudOperationFailure(
        error,
        fallback: l.syncCenterActionFailed,
      ).message,
    );
  }

  /// 明确拒收重新登记后仍检查真实同步结果，未上传完毕不能显示成功。
  Future<void> _retry(SyncIssue issue) async {
    if (issue.deletion &&
        [
          'ledger',
          'day_book',
          'memo_book',
          'fitness_space',
        ].contains(issue.target.type)) {
      await _confirmDelete(issue.target);
      return;
    }
    _requireSuccess(
      await ref.read(syncCoordinatorProvider).retryRejected(issue.id),
    );
  }

  Future<void> _open(SyncIssue issue) async {
    final l = AppLocalizations.of(context);
    final target = issue.target;
    switch (target.type) {
      case 'transaction':
        final transaction = await ref
            .read(transactionActionsProvider)
            .getById(target.id);
        if (transaction == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await TransactionEditUtils.editTransaction(context, ref, transaction);
      case 'ledger':
        final book = await ref.read(ledgerActionsProvider).getById(target.id);
        if (book == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.ledgerEdit, extra: book);
      case 'day_book':
        final book = await ref
            .read(dayActionsProvider)
            .getBook(target.id, accountId: ref.read(currentAccountIdProvider));
        if (book == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.dayBookEdit, extra: book);
      case 'day_event':
        final found = await ref.read(dayActionsProvider).findEvent(target.id);
        if (found == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await openDayEditor(context, ref, event: found.event, book: found.book);
        return;
      case 'memo_book':
        final book = await ref
            .read(memoActionsProvider)
            .getBook(target.id, accountId: ref.read(currentAccountIdProvider));
        if (book == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.memoBookEdit, extra: book);
      case 'memo_entry':
        final entry = await ref.read(memoActionsProvider).findEntry(target.id);
        if (entry == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await openMemoEntry(context, ref, entry);
        return;
      case 'fitness_space':
        final book = await ref
            .read(fitnessSpaceQueriesProvider)
            .getBook(target.id, accountId: ref.read(currentAccountIdProvider));
        if (book == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.fitnessSpaceEdit, extra: book);
      case 'fitness_workout':
        if (target.parentId == null) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await ref
            .read(currentFitnessSpaceIdProvider.notifier)
            .select(target.parentId!);
        if (!mounted) return;
        await openTrackedFitnessWorkout(context, target.id);
      case 'fitness_plan':
        if (target.parentId == null) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await ref
            .read(currentFitnessSpaceIdProvider.notifier)
            .select(target.parentId!);
        if (!mounted) return;
        await context.pushNamed(Routes.fitnessPlanDetail, extra: target.id);
      case 'fitness_template':
        if (target.parentId == null) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await ref
            .read(currentFitnessSpaceIdProvider.notifier)
            .select(target.parentId!);
        if (!mounted) return;
        await context.pushNamed(Routes.fitnessTemplateDetail, extra: target.id);
      case 'category':
        final category = await ref
            .read(categoryActionsProvider)
            .getById(target.id);
        if (category == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.categoryEdit, extra: (category, null));
      case 'exchange_rate_override':
        await context.pushNamed(Routes.exchangeRate);
      case 'member':
        if (target.parentId == null) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        final ledger = await ref
            .read(ledgerActionsProvider)
            .getById(target.parentId!);
        if (ledger == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(Routes.ledgerEdit, extra: ledger);
      case 'recurring_transaction':
        final recurring = (await ref.read(
          recurringTransactionDisplaysProvider.future,
        )).where((r) => r.id == target.id).firstOrNull;
        if (recurring == null || !mounted) {
          throw _SyncCenterActionError(l.syncCenterRecordUnavailable);
        }
        await context.pushNamed(
          Routes.recurringTransactionEdit,
          extra: recurring,
        );
      case 'ledger_archive':
        final ledger = await ref.read(ledgerActionsProvider).getById(target.id);
        if (!mounted) return;
        await context.pushNamed(
          ledger?.isArchived == true ? Routes.archivedLedgers : Routes.ledgers,
        );
      case 'fitness_preferences':
        ref.read(bottomTabIndexProvider.notifier).set(3);
        Navigator.of(context).popUntil((route) => route.isFirst);
      default:
        throw StateError('请在原记录设置中修改');
    }
  }

  Future<void> _continueMove(SyncIssue issue) async {
    // 未知响应先精确重放；尚未完成的转换再展示实际快照，不能自动扩大删除范围。
    final result = await ref.read(syncCoordinatorProvider).run();
    // 转换本身等待确认属于预期业务状态；传输、归属和内容失败仍须立即反馈。
    if (!result.ok && result.failure?.code != 'SYNC_REQUIRES_ATTENTION') {
      _requireSuccess(result);
    }
    if (!mounted) return;
    final issues = await ref.refresh(syncCenterIssuesProvider.future);
    if (!mounted ||
        !issues.any(
          (current) =>
              current.kind == SyncIssueKind.pendingMove &&
              current.target == issue.target,
        )) {
      return;
    }
    await _confirmDelete(issue.target);
  }

  String _kind(AppLocalizations l, SyncIssueKind kind) => switch (kind) {
    SyncIssueKind.conflict => l.syncCenterConflict,
    SyncIssueKind.rejected => l.syncCenterRejected,
    SyncIssueKind.stale => l.syncCenterStale,
    SyncIssueKind.pendingDelete => l.syncCenterDeleting,
    SyncIssueKind.pendingMove => l.syncCenterMoving,
    SyncIssueKind.incomplete => l.syncCenterIncomplete,
    SyncIssueKind.pendingUpload => l.syncCenterUploading,
    SyncIssueKind.pullError => l.syncCenterPullFailed,
  };

  /// 标题明确同步对象，分类名称和所属账本不会被误认为记账记录本身。
  String _issueTitle(SyncIssue issue, AppLocalizations l) =>
      switch (issue.target.type) {
        'category' => l.syncCenterCategoryTitle(issue.title),
        'transaction' => l.syncCenterTransactionTitle(
          issue.accountingContext?.categoryName ??
              (issue.accountingContext?.categoryId == null
                  ? l.commonUncategorized
                  : l.syncCenterUnknownCategory),
        ),
        _ => l.syncCenterEntityTitle(
          _entityType(l, issue.target.type),
          issue.title.isNotEmpty ? issue.title : _kind(l, issue.kind),
        ),
      };

  /// 类型只使用本机可读名称，实体键和后台实现名称不作为记录标题。
  String _entityType(AppLocalizations l, String type) => switch (type) {
    'ledger' => l.syncCenterTypeLedger,
    'day_book' => l.syncCenterTypeDayBook,
    'day_event' => l.syncCenterTypeDayEvent,
    'memo_book' => l.syncCenterTypeMemoBook,
    'memo_entry' => l.syncCenterTypeMemoEntry,
    'fitness_space' => l.syncCenterTypeFitnessSpace,
    'fitness_workout' => l.syncCenterTypeFitnessWorkout,
    'fitness_plan' => l.syncCenterTypeFitnessPlan,
    'fitness_template' => l.syncCenterTypeFitnessTemplate,
    'member' => l.syncCenterTypeMember,
    'recurring_transaction' => l.syncCenterTypeRecurring,
    'exchange_rate_override' => l.syncCenterTypeExchangeRate,
    _ => l.syncCenterTypeRecord,
  };

  /// 可见交易展示原币金额、发生日期和所属账本，失败原因保持同步层的明确判定。
  String _issueSubtitle(SyncIssue issue, AppLocalizations l) {
    final reason =
        issue.kind == SyncIssueKind.pendingUpload && issue.uploadOutcomeUnknown
        ? l.syncCenterAwaitingReceiptHint
        : issue.reason == 'SYNC_BUDGET'
        ? l.syncCenterBudget
        : issue.reason ??
              (issue.kind == SyncIssueKind.pendingUpload
                  ? l.syncCenterPendingRecordHint
                  : _kind(l, issue.kind));
    final details = issue.accountingContext;
    if (details == null) return reason;
    try {
      final amount = double.tryParse(details.amount ?? '');
      final accounting = <String>[
        if (amount != null && amount.isFinite)
          formatMoneyWithCurrency(
            amount,
            currencyCode: details.currencyCode,
            decimals: 10,
          ),
        if (details.happenedAt != null)
          DateFormat.yMd(l.localeName).format(details.happenedAt!),
      ].join(' · ');
      return [
        if (accounting.isNotEmpty) accounting,
        if (details.bookName?.isNotEmpty == true)
          l.syncCenterBookContext(
            translateLedgerName(context, details.bookName!),
          ),
        reason,
      ].join('\n');
    } catch (error, stackTrace) {
      logger.error('SyncCenter', '格式化待处理交易摘要失败', error, stackTrace);
      return reason;
    }
  }

  /// 只展示用户内容，账号、游标、幂等键等实现字段不进入冲突界面。
  String _content(Map<String, dynamic>? payload, AppLocalizations l) {
    if (payload == null) return '';
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      return l.syncCenterDeleted;
    }
    String value(Object? v) {
      if (v is Map) {
        if (v['ops'] is List) {
          return (v['ops'] as List)
              .map((o) => o is Map ? o['insert'] ?? '' : '')
              .join();
        }
        // 账号密码卡片的字段列表按“名称：取值”逐行展示。
        if (v['fields'] is List) {
          return (v['fields'] as List)
              .map(
                (f) =>
                    f is Map ? '${f['label'] ?? ''}：${f['value'] ?? ''}' : '',
              )
              .join('\n');
        }
        if (v['original_year'] != null) {
          return '${v['original_year']}-${v['original_month']}-${v['original_day']}';
        }
        return v.entries
            .where(
              (e) => ![
                'id',
                'exercise_id',
                'source_template_id',
                'set_id',
              ].contains(e.key),
            )
            .map((e) => value(e.value))
            .join(' · ');
      }
      if (v is List) return v.map(value).join('\n');
      return v?.toString() ?? '';
    }

    return [
      for (final key in [
        'name',
        'title',
        'amount',
        'currency',
        'currency_code',
        'happened_at',
        'note',
        'event',
        'start',
        'end',
        'body',
        'start_date',
        'cycle_days',
        'exercises',
        'days',
      ])
        if (payload[key] != null && value(payload[key]).isNotEmpty)
          value(payload[key]),
    ].join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final issues = ref.watch(syncCenterIssuesProvider);
    final generation = ref.watch(syncCenterSessionGenerationProvider);
    final feedback = ref.watch(cloudSyncRunFeedbackProvider);
    final actionError = _actionGeneration == generation ? _actionError : null;
    final latestError =
        actionError ?? feedback.failure?.message ?? feedback.error;
    final failedTarget = actionError != null
        ? _failedTarget
        : feedback.failure?.target;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l.syncCenterTitle,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.refresh,
                tooltip: l.commonRetry,
                onPressed: _busy ? null : _refresh,
              ),
            ],
          ),
          if (_busy) const LinearProgressIndicator(),
          if (latestError != null)
            AppStatusBanner(
              icon: AppIcons.info,
              message: actionError != null
                  ? latestError
                  : l.syncCenterLastFailure(latestError),
            ),
          if (_categoryError != null && _actionGeneration == generation)
            Padding(
              padding: const EdgeInsets.all(AppDimens.p12),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  _categoryError!,
                  style: AppTextTokens.body(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          Expanded(
            child: issues.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.syncCenterLoadFailed,
                onRetry: () => ref.invalidate(syncCenterIssuesProvider),
              ),
              data: (items) => RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimens.p12),
                  itemCount: items.isEmpty ? 1 : items.length,
                  itemBuilder: (context, index) {
                    if (items.isEmpty) return AppEmpty(text: l.syncCenterEmpty);
                    return Consumer(
                      builder: (context, ref, _) {
                        final summary = items[index];
                        // 只有当前可见事项读取业务正文；头部计数与列表头保持轻量。
                        final details = ref.watch(
                          syncIssueDetailsProvider(summary),
                        );
                        return details.when(
                          loading: () => const SizedBox(
                            height: AppDimens.p16 * 3,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (_, _) => AppLoadError(
                            message: l.syncCenterLoadFailed,
                            onRetry: () => ref.invalidate(
                              syncIssueDetailsProvider(summary),
                            ),
                          ),
                          data: (issue) => SectionCard(
                            margin: const EdgeInsets.only(bottom: AppDimens.p8),
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.p12,
                                    vertical: AppDimens.p8,
                                  ),
                                  child: AppListTile(
                                    title: _issueTitle(issue, l),
                                    titleMaxLines: null,
                                    subtitleMaxLines: null,
                                    subtitle: _issueSubtitle(issue, l),
                                  ),
                                ),
                                if (latestError != null &&
                                    _matchesTarget(failedTarget, issue.target))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimens.p12,
                                    ),
                                    child: AppStatusBanner(
                                      inset: true,
                                      icon: AppIcons.info,
                                      message: latestError,
                                    ),
                                  ),
                                if (issue.kind == SyncIssueKind.conflict &&
                                    issue.target.type == 'category')
                                  CategoryConflictActions(
                                    key: ValueKey((issue.id, generation)),
                                    issue: issue,
                                    busy: _busy,
                                    onResolve:
                                        ({
                                          required conflictId,
                                          required expectedDecisionVersion,
                                          required keepLocal,
                                          required restoreDeleted,
                                        }) => _categoryOperation(
                                          generation,
                                          () => ref
                                              .read(syncCoordinatorProvider)
                                              .resolveCategoryConflict(
                                                conflictId,
                                                keepLocal: keepLocal,
                                                expectedDecisionVersion:
                                                    expectedDecisionVersion,
                                                restoreDeleted: restoreDeleted,
                                              ),
                                        ),
                                    onRetry: () => _categoryOperation(
                                      generation,
                                      () => ref
                                          .read(syncCoordinatorProvider)
                                          .retryCategoryConflictResolution(
                                            issue.id,
                                          ),
                                    ),
                                    onRefresh: () => _categoryOperation(
                                      generation,
                                      () => ref
                                          .read(syncCoordinatorProvider)
                                          .refreshData(),
                                    ),
                                  )
                                else if (issue.kind ==
                                    SyncIssueKind.conflict) ...[
                                  ExpansionTile(
                                    title: Text(l.syncCenterCompare),
                                    children: [
                                      ListTile(
                                        title: Text(l.syncCenterLocal),
                                        subtitle: SelectableText(
                                          _content(issue.local, l),
                                        ),
                                      ),
                                      ListTile(
                                        title: Text(l.syncCenterRemote),
                                        subtitle: SelectableText(
                                          _content(issue.remote, l),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      TextButton(
                                        onPressed:
                                            _busy ||
                                                (!issue.recovery &&
                                                    issue.target.type ==
                                                        'fitness_workout' &&
                                                    issue.remote?['id'] !=
                                                        null &&
                                                    issue.remote?['id'] !=
                                                        issue.target.id)
                                            ? null
                                            : () => _run(
                                                () => _resolve(issue, false),
                                              ),
                                        child: Text(l.syncCenterKeepLocal),
                                      ),
                                      TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _run(
                                                () => _resolve(issue, true),
                                              ),
                                        child: Text(l.syncCenterUseRemote),
                                      ),
                                    ],
                                  ),
                                ] else
                                  Wrap(
                                    children: [
                                      if (issue.kind ==
                                          SyncIssueKind.rejected) ...[
                                        if (_canEdit(issue))
                                          TextButton(
                                            onPressed: _busy
                                                ? null
                                                : () => _run(
                                                    () => _open(issue),
                                                    target: issue.target,
                                                  ),
                                            child: Text(
                                              issue.target.type == 'category'
                                                  ? l.categoryEditTitle
                                                  : l.syncCenterEdit,
                                            ),
                                          ),
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => _retry(issue),
                                                  target: issue.target,
                                                ),
                                          child: Text(l.commonRetry),
                                        ),
                                      ],
                                      if (issue.kind == SyncIssueKind.pullError)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => ref
                                                      .read(
                                                        syncCoordinatorProvider,
                                                      )
                                                      .retryPullError(issue.id),
                                                ),
                                          child: Text(l.commonRetry),
                                        ),
                                      if (issue.kind == SyncIssueKind.stale)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(() async {
                                                  await ref
                                                      .read(
                                                        syncCoordinatorProvider,
                                                      )
                                                      .protectToLocal(
                                                        issue.target,
                                                      );
                                                  if (context.mounted) {
                                                    showToast(
                                                      context,
                                                      l.commonDone,
                                                    );
                                                  }
                                                }),
                                          child: Text(l.syncCenterProtect),
                                        ),
                                      if (issue.kind == SyncIssueKind.stale ||
                                          issue.kind ==
                                              SyncIssueKind.incomplete)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => ref
                                                      .read(
                                                        syncCoordinatorProvider,
                                                      )
                                                      .refreshTarget(
                                                        issue.target,
                                                      ),
                                                ),
                                          child: Text(l.syncCenterDownload),
                                        ),
                                      if (issue.kind ==
                                              SyncIssueKind.pendingDelete ||
                                          issue.kind ==
                                              SyncIssueKind.pendingUpload)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _retryPending(issue),
                                          child: Text(l.commonRetry),
                                        ),
                                      if (issue.kind ==
                                              SyncIssueKind.pendingUpload &&
                                          _canEdit(issue))
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => _open(issue),
                                                  target: issue.target,
                                                ),
                                          child: Text(
                                            issue.target.type == 'category'
                                                ? l.categoryEditTitle
                                                : l.syncCenterEdit,
                                          ),
                                        ),
                                      if (issue.kind ==
                                          SyncIssueKind.pendingMove)
                                        TextButton(
                                          onPressed: _busy
                                              ? null
                                              : () => _run(
                                                  () => _continueMove(issue),
                                                  target: issue.target,
                                                ),
                                          child: Text(l.commonRetry),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
