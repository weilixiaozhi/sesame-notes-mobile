import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import '../../db.dart';
import '../../models/sync_issue.dart';
import '../../models/category_conflict_state.dart';
import '../support/ledger_category_catalog.dart';

/// 解析持久化的同步载荷；载荷由本机按契约写入，解析失败说明数据已损坏。
///
/// 空对象降级保留事项定位，解析错误记录脱敏日志供诊断。
Map<String, dynamic> _snapshot(String value) {
  try {
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '同步载荷解析失败，保留事项定位',
      safeErrorSummary(error),
      stackTrace,
    );
    return const {};
  }
}

/// 全局待处理事实的唯一查询，供同步结果、页面与退出保护共同使用。
Future<List<SyncIssue>> readSyncIssues(
  SesameDatabase db, {
  required String? account,
  bool includeFitnessCompleteness = true,
  bool includeDetails = true,
  bool expandPendingUploads = false,
}) async {
  try {
    return await db.transaction(() async {
      final fitnessSpaces =
          await (db.select(db.fitnessSpaces)..where(
                (b) => account == null
                    ? b.scopeAccountId.isNull()
                    : b.scopeAccountId.isNull() |
                          b.scopeAccountId.equals(account),
              ))
              .get();
      final ledgers =
          await (db.select(db.ledgers)..where(
                (b) => account == null
                    ? b.scopeAccountId.isNull()
                    : b.scopeAccountId.equals(account) |
                          b.scopeAccountId.isNull(),
              ))
              .get();
      final days =
          await (db.select(db.dayBooks)..where(
                (b) => account == null
                    ? b.scopeAccountId.isNull()
                    : b.scopeAccountId.equals(account) |
                          b.scopeAccountId.isNull(),
              ))
              .get();
      final memos =
          await (db.select(db.memoBooks)..where(
                (b) => account == null
                    ? b.scopeAccountId.isNull()
                    : b.scopeAccountId.equals(account) |
                          b.scopeAccountId.isNull(),
              ))
              .get();
      final names = <String, String>{
        for (final b in ledgers) b.id: b.name,
        for (final b in days) b.id: b.name,
        for (final b in memos) b.id: b.name,
        for (final b in fitnessSpaces) b.id: b.name,
      };
      final conflicts = account == null
          ? <SyncConflict>[]
          : await db
                .customSelect(
                  "SELECT ${_issueColumns(db.syncConflicts.$columns, includeDetails)} FROM sync_conflicts WHERE account_id=? AND (status='OPEN' OR (resolved_at IS NULL AND local_mutation_id LIKE 'fitness-recovery:%'))",
                  variables: [Variable(account)],
                )
                .map((row) => db.syncConflicts.map(row.data))
                .get();
      final pending = account == null
          ? <SyncChange>[]
          : await db
                .customSelect(
                  "SELECT ${_issueColumns(db.syncChanges.$columns, includeDetails)} FROM sync_changes WHERE account_id=? AND pushed_at IS NULL AND (rejection_reason IS NOT NULL OR action='delete')",
                  variables: [Variable(account)],
                )
                .map((row) => db.syncChanges.map(row.data))
                .get();
      // 正常待上传只汇总数量，常驻提示不反复读取所有笔记正文和训练组数据。
      final uploading = account == null
          ? 0
          : (await db
                    .customSelect(
                      "SELECT count(*) AS total FROM sync_changes WHERE account_id=? AND pushed_at IS NULL AND rejection_reason IS NULL AND action='upsert'",
                      variables: [Variable(account)],
                    )
                    .getSingle())
                .read<int>('total');
      final pullErrors = account == null
          ? <SyncPullError>[]
          : await db
                .customSelect(
                  'SELECT ${_issueColumns(db.syncPullErrors.$columns, false)} FROM sync_pull_errors WHERE resolved_at IS NULL AND account_id=?',
                  variables: [Variable(account)],
                )
                .map((row) => db.syncPullErrors.map(row.data))
                .get();
      String title(String id, Map<String, dynamic> payload, {String? parent}) =>
          (payload['name'] ??
                  payload['title'] ??
                  payload['note'] ??
                  names[id] ??
                  names[parent] ??
                  '')
              .toString();
      SyncIssue conflictIssue(SyncConflict c) {
        final local = includeDetails
            ? _snapshot(c.localPayload)
            : const <String, dynamic>{};
        final remote = includeDetails
            ? _snapshot(c.remotePayload)
            : const <String, dynamic>{};
        return SyncIssue(
          id: c.id,
          kind: SyncIssueKind.conflict,
          target: SyncTarget(
            c.entityType,
            c.entityId,
            parentId:
                c.ledgerId ?? c.dayBookId ?? c.memoBookId ?? c.fitnessSpaceId,
          ),
          title: title(
            c.entityId,
            local,
            parent:
                c.ledgerId ?? c.dayBookId ?? c.memoBookId ?? c.fitnessSpaceId,
          ),
          local: includeDetails
              ? c.entityType == 'category'
                    ? categoryConflictDisplay(local)
                    : local
              : null,
          remote: includeDetails
              ? c.entityType == 'category'
                    ? categoryConflictDisplay(remote)
                    : remote
              : null,
          resolutionPending: c.resolutionRequest != null,
          decisionVersion: c.entityType == 'category'
              ? categoryDecisionVersion(remote)
              : null,
          recovery: c.localMutationId.startsWith('fitness-recovery:'),
          deletion: local['deleted'] == true,
        );
      }

      return [
        for (final row in pullErrors)
          SyncIssue(
            id: 'pull:${row.id}',
            kind: SyncIssueKind.pullError,
            target: SyncTarget(
              row.entityType,
              row.entityId,
              parentId:
                  row.ledgerId ??
                  row.dayBookId ??
                  row.memoBookId ??
                  row.fitnessSpaceId,
            ),
            title:
                names[row.ledgerId ??
                    row.dayBookId ??
                    row.memoBookId ??
                    row.fitnessSpaceId] ??
                '',
          ),
        if (uploading > 0 && !expandPendingUploads)
          SyncIssue(
            id: 'pending-uploads',
            kind: SyncIssueKind.pendingUpload,
            target: const SyncTarget('application', ''),
            title: '',
            count: uploading,
          ),
        if (expandPendingUploads && account != null)
          ...await _readPendingUploadSummaries(db, account, names),
        for (final c in conflicts) conflictIssue(c),
        for (final c in pending)
          SyncIssue(
            id: c.id.toString(),
            kind: c.rejectionReason != null
                ? SyncIssueKind.rejected
                : c.action == 'delete'
                ? SyncIssueKind.pendingDelete
                : SyncIssueKind.pendingUpload,
            target: SyncTarget(
              c.entityType,
              c.entityId,
              parentId:
                  c.ledgerId ?? c.dayBookId ?? c.memoBookId ?? c.fitnessSpaceId,
            ),
            title: title(
              c.entityId,
              _snapshot(c.payload),
              parent:
                  c.ledgerId ?? c.dayBookId ?? c.memoBookId ?? c.fitnessSpaceId,
            ),
            reason: c.rejectionReason,
            rejectionCode: c.rejectionCode,
            local: includeDetails ? _snapshot(c.payload) : null,
            deletion: c.action == 'delete',
          ),
        for (final b in ledgers)
          if (b.bindingStatus == 'stale' ||
              b.bindingStatus == 'pending_local_move' &&
                  b.originAccountId == account)
            SyncIssue(
              id: b.id,
              kind: b.bindingStatus == 'stale'
                  ? SyncIssueKind.stale
                  : SyncIssueKind.pendingMove,
              target: SyncTarget(
                'ledger',
                b.bindingStatus == 'stale' ? b.id : b.originLedgerId!,
              ),
              title: b.name,
            ),
        for (final b in days)
          if (b.isStale ||
              b.storageMode == 'cloud' &&
                  b.deletedAt == null &&
                  b.syncId != null &&
                  b.fullCursor == null &&
                  !b.pendingLocalDelete ||
              b.isHidden &&
                  b.sourceOperationId != null &&
                  b.sourceAccountId == account)
            SyncIssue(
              id: b.id,
              kind: b.isStale
                  ? SyncIssueKind.stale
                  : b.isHidden
                  ? SyncIssueKind.pendingMove
                  : SyncIssueKind.incomplete,
              target: SyncTarget(
                'day_book',
                b.isHidden ? b.sourceDayBookId! : b.id,
              ),
              title: b.name,
            ),
        for (final b in memos)
          if (b.isStale ||
              b.isHidden &&
                  b.sourceOperationId != null &&
                  b.sourceAccountId == account ||
              b.syncId != null &&
                  b.fullCursor == null &&
                  b.deletedAt == null &&
                  b.storageMode == 'cloud')
            SyncIssue(
              id: b.id,
              kind: b.isStale
                  ? SyncIssueKind.stale
                  : b.isHidden
                  ? SyncIssueKind.pendingMove
                  : SyncIssueKind.incomplete,
              target: SyncTarget(
                'memo_book',
                b.isHidden ? b.sourceMemoBookId! : b.id,
              ),
              title: b.name,
            ),
        for (final b in fitnessSpaces)
          if (b.isStale ||
              b.isHidden &&
                  b.sourceOperationId != null &&
                  b.sourceAccountId == account ||
              includeFitnessCompleteness &&
                  b.syncId != null &&
                  b.fullCursor == null &&
                  b.deletedAt == null &&
                  b.storageMode == 'cloud')
            SyncIssue(
              id: b.id,
              kind: b.isStale
                  ? SyncIssueKind.stale
                  : b.isHidden
                  ? SyncIssueKind.pendingMove
                  : SyncIssueKind.incomplete,
              target: SyncTarget(
                'fitness_space',
                b.isHidden ? b.sourceFitnessSpaceId! : b.id,
              ),
              title: b.name,
            ),
      ];
    });
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '读取同步事项事实失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}

/// 每个实体只展示一个待上传事项，并保留其队列数量与未知回执事实。
/// SQL 只投影定位字段，不把笔记正文或冻结请求读入常驻页面列表。
Future<List<SyncIssue>> _readPendingUploadSummaries(
  SesameDatabase db,
  String account,
  Map<String, String> names,
) async {
  try {
    final rows = await db
        .customSelect(
          "SELECT MAX(id) AS id, entity_type, entity_id, ledger_id, day_book_id, memo_book_id, fitness_space_id, "
          "COUNT(*) AS total, MAX(CASE WHEN frozen_request IS NOT NULL THEN 1 ELSE 0 END) AS unknown_outcome "
          "FROM sync_changes WHERE account_id=? AND pushed_at IS NULL AND rejection_reason IS NULL AND action='upsert' "
          'GROUP BY entity_type,entity_id,ledger_id,day_book_id,memo_book_id,fitness_space_id ORDER BY MIN(id)',
          variables: [Variable(account)],
        )
        .get();
    return [
      for (final row in rows)
        SyncIssue(
          id: row.read<int>('id').toString(),
          kind: SyncIssueKind.pendingUpload,
          target: SyncTarget(
            row.read<String>('entity_type'),
            row.read<String>('entity_id'),
            parentId:
                row.readNullable<String>('ledger_id') ??
                row.readNullable<String>('day_book_id') ??
                row.readNullable<String>('memo_book_id') ??
                row.readNullable<String>('fitness_space_id'),
          ),
          title:
              names[row.read<String>('entity_id')] ??
              names[row.readNullable<String>('ledger_id') ??
                  row.readNullable<String>('day_book_id') ??
                  row.readNullable<String>('memo_book_id') ??
                  row.readNullable<String>('fitness_space_id')] ??
              '',
          count: row.read<int>('total'),
          uploadOutcomeUnknown: row.read<int>('unknown_outcome') != 0,
        ),
    ];
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '读取待上传实体列表失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}

/// 常驻摘要不把历史正文和冻结请求带入 Dart；字段列表来自生成表结构。
String _issueColumns(Iterable<GeneratedColumn> columns, bool details) => columns
    .map((column) {
      final name = column.$name;
      if (!details && ['stack_trace', 'error_message'].contains(name)) {
        return 'NULL AS "$name"';
      }
      if (name == 'frozen_request') return 'NULL AS "$name"';
      if (!details && name == 'resolution_request') {
        return 'CASE WHEN resolution_request IS NULL THEN NULL ELSE \'{}\' END AS "$name"';
      }
      if (!details &&
          [
            'local_payload',
            'remote_payload',
            'payload',
            'raw_change_json',
          ].contains(name)) {
        return "'{}' AS \"$name\"";
      }
      return '"$name"';
    })
    .join(',');

/// 从当前账号的账本与分类镜像解析交易摘要；金额和日期只读取已可见事项的载荷。
Future<SyncIssueAccountingContext> _readAccountingContext(
  SesameDatabase db,
  SyncTarget target,
  Map<String, dynamic> payload,
  String account,
) async {
  try {
    final ledger = target.parentId == null
        ? null
        : await (db.select(db.ledgers)..where(
                (row) =>
                    row.id.equals(target.parentId!) &
                    (row.scopeAccountId.equals(account) |
                        row.scopeAccountId.isNull()),
              ))
              .getSingleOrNull();
    String? categoryName;
    final categoryId = payload['category_id'];
    if (ledger != null && categoryId is String && categoryId.isNotEmpty) {
      // 同步中心与记账、统计共用账本目录，不把登录账号或本地域猜作分类的所有者。
      try {
        final categories = await readLedgerCategoryCatalog(
          db,
          ledger.id,
          categoryIds: [categoryId],
        );
        categoryName = categories[categoryId]?.name;
      } catch (error, stackTrace) {
        // 分类目录不可读时保留金额、日期和账本定位，不能用其他账号类别补名称。
        logger.error(
          'SyncIssues',
          '待处理记录的分类目录不可读',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    }
    return SyncIssueAccountingContext(
      bookName: ledger?.name,
      categoryName: categoryName,
      categoryId: categoryId is String && categoryId.isNotEmpty
          ? categoryId
          : null,
      amount: payload['amount']?.toString(),
      currencyCode: payload['currency_code']?.toString(),
      happenedAt: payload['happened_at'] is String
          ? DateTime.tryParse(payload['happened_at'] as String)?.toLocal()
          : null,
    );
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '读取待处理交易摘要失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}

/// 仅可见的待处理卡片读取正文；旧账号或已解决的事项不能沿用缓存。
Future<SyncIssue> readSyncIssueDetails(
  SesameDatabase db,
  SyncIssue summary, {
  required String? account,
}) async {
  try {
    if (summary.kind == SyncIssueKind.pullError) {
      final issues = await readSyncIssues(
        db,
        account: account,
        includeDetails: false,
      );
      final current = issues
          .where(
            (issue) =>
                issue.kind == SyncIssueKind.pullError && issue.id == summary.id,
          )
          .firstOrNull;
      if (current == null || current.target != summary.target) {
        throw StateError('事项已变化，请刷新');
      }
      return current;
    }
    Map<String, dynamic>? local, remote;
    var resolutionPending = summary.resolutionPending;
    var decisionVersion = summary.decisionVersion;
    var rejectionCode = summary.rejectionCode;
    var reason = summary.reason;
    var uploadOutcomeUnknown = summary.uploadOutcomeUnknown;
    SyncIssueAccountingContext? accountingContext;
    if (summary.kind == SyncIssueKind.conflict) {
      final row =
          await (db.select(db.syncConflicts)..where(
                (c) =>
                    c.id.equals(summary.id) &
                    (account == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(account)) &
                    (c.status.equals('OPEN') |
                        (c.resolvedAt.isNull() &
                            c.localMutationId.like('fitness-recovery:%'))),
              ))
              .getSingleOrNull();
      if (row == null) throw StateError('事项已变化，请刷新');
      if (row.entityId != summary.target.id ||
          row.entityType != summary.target.type) {
        throw StateError('事项已变化，请刷新');
      }

      local = _snapshot(row.localPayload);
      remote = _snapshot(row.remotePayload);
      resolutionPending = row.resolutionRequest != null;
      if (row.entityType == 'category') {
        decisionVersion = categoryDecisionVersion(remote);
        local = categoryConflictDisplay(local);
        remote = categoryConflictDisplay(remote);
        for (final payload in [local, remote]) {
          final parent = payload['parent_id'];
          if (parent is String && account != null) {
            final category =
                await (db.select(db.categories)..where(
                      (c) =>
                          c.id.equals(parent) &
                          c.scopeAccountId.equals(account),
                    ))
                    .getSingleOrNull();
            if (category != null) payload['parent_name'] = category.name;
          }
        }
      }
    } else if ([
      SyncIssueKind.rejected,
      SyncIssueKind.pendingUpload,
      SyncIssueKind.pendingDelete,
    ].contains(summary.kind)) {
      // 全局数量卡片没有实体正文；同步中心使用实体级定位读取当前账号的可见详情。
      if (summary.target.type == 'application') return summary;
      if (account == null) throw StateError('账号已变化');
      final row = await db
          .customSelect(
            'SELECT payload, entity_type, entity_id, rejection_code, rejection_reason, action FROM sync_changes WHERE id=? AND account_id=? AND pushed_at IS NULL',
            variables: [Variable(int.parse(summary.id)), Variable(account)],
          )
          .getSingleOrNull();
      if (row == null) throw StateError('事项已变化，请刷新');
      if (row.read<String>('entity_type') != summary.target.type ||
          row.read<String>('entity_id') != summary.target.id) {
        throw StateError('事项已变化，请刷新');
      }
      final rejected = row.readNullable<String>('rejection_reason');
      final action = row.read<String>('action');
      final kind = rejected != null
          ? SyncIssueKind.rejected
          : action == 'delete'
          ? SyncIssueKind.pendingDelete
          : SyncIssueKind.pendingUpload;
      if (kind != summary.kind) throw StateError('事项已变化，请刷新');
      local = _snapshot(row.read<String>('payload'));
      rejectionCode = row.readNullable<String>('rejection_code');
      reason = rejected;
      if (kind == SyncIssueKind.pendingUpload) {
        final unknown = await db
            .customSelect(
              'SELECT EXISTS(SELECT 1 FROM sync_changes WHERE account_id=? AND entity_type=? AND entity_id=? AND pushed_at IS NULL AND rejection_reason IS NULL AND frozen_request IS NOT NULL) AS unknown_outcome',
              variables: [
                Variable(account),
                Variable(summary.target.type),
                Variable(summary.target.id),
              ],
            )
            .getSingle();
        uploadOutcomeUnknown = unknown.read<int>('unknown_outcome') != 0;
      }
    } else {
      return summary;
    }
    if (summary.target.type == 'transaction' && account != null) {
      accountingContext = await _readAccountingContext(
        db,
        summary.target,
        local,
        account,
      );
    }
    if (summary.kind == SyncIssueKind.pendingUpload && account != null) {
      reason = await _pendingUploadReason(
        db,
        summary.target,
        local,
        account,
        uploadOutcomeUnknown,
        accountingContext,
      );
    }
    return SyncIssue(
      id: summary.id,
      kind: summary.kind,
      target: summary.target,
      title: (local['name'] ?? local['title'] ?? local['note'] ?? summary.title)
          .toString(),
      reason: reason,
      rejectionCode: rejectionCode,
      local: local,
      remote: remote,
      recovery: summary.recovery,
      deletion: summary.deletion || local['deleted'] == true,
      count: summary.count,
      resolutionPending: resolutionPending,
      decisionVersion: decisionVersion,
      accountingContext: accountingContext,
      uploadOutcomeUnknown: uploadOutcomeUnknown,
    );
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '读取同步事项详情失败: type=${summary.target.type}',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}

/// 从当前账号真实依赖判断等待原因，未知回执与尚未发送使用不同的说明。
Future<String> _pendingUploadReason(
  SesameDatabase db,
  SyncTarget target,
  Map<String, dynamic> payload,
  String account,
  bool unknownOutcome,
  SyncIssueAccountingContext? context,
) async {
  if (unknownOutcome) return '上传结果尚未确认，重试会使用原请求继续同步。';
  try {
    final categoryId = payload['category_id'];
    if (target.type == 'transaction' &&
        categoryId is String &&
        target.parentId != null) {
      final ledger =
          await (db.select(db.ledgers)..where(
                (row) =>
                    row.id.equals(target.parentId!) &
                    row.scopeAccountId.equals(account),
              ))
              .getSingleOrNull();
      // 共享账本只依赖其所有者目录；当前账号同编号的私有分类不能成为共享记录的依赖。
      if (ledger != null && ledger.ownerAccountId == null) {
        return '尚未确认账本的分类归属，联网同步后才能上传这条记录。';
      }
      if (ledger?.ownerAccountId == account) {
        final pending = await db
            .customSelect(
              "SELECT EXISTS(SELECT 1 FROM sync_changes WHERE account_id=? AND entity_type='category' AND entity_id=? AND pushed_at IS NULL) AS waiting",
              variables: [Variable(account), Variable(categoryId)],
            )
            .getSingle();
        if (pending.read<int>('waiting') != 0) {
          final name = context?.categoryName;
          return name == null ? '等待这条记录使用的分类同步完成后上传。' : '等待分类“$name”同步完成后上传。';
        }
      }
    }
    return '已保存在本机，尚未上传到云端。';
  } catch (error, stackTrace) {
    logger.error(
      'SyncIssues',
      '读取待上传依赖失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
}
