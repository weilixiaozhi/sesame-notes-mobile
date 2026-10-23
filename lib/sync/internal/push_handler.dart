import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_rejection.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/repositories/local/sync_history.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 按实体顺序处理待推队列、冻结请求与确认结果。
class SyncPushCoordinator {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  SyncPushCoordinator(
    this._runtime,
    this._ports, {
    required this.dayRepository,
    required this.fitnessEnabled,
    required this.memoRepository,
  });
  final SyncRuntime _runtime;
  final SyncPushCoordinatorPorts _ports;
  final DayRepository? dayRepository;
  final bool fitnessEnabled;
  final MemoRepository? memoRepository;

  /// 账本实体自身定义财务父范围，其他财务实体使用其明确记录的所属账本。
  String? _ledgerScopeId(SyncChange change) =>
      change.entityType == 'ledger' ? change.entityId : change.ledgerId;

  /// 执行scopeKey对应的同步步骤，沿用所属域的身份与事务规则。
  String scopeKey(SyncChange change) => change.dayBookId != null
      ? 'day_book:${change.dayBookId}'
      : change.memoBookId != null
      ? 'memo_book:${change.memoBookId}'
      : change.fitnessSpaceId != null
      ? 'fitness_space:${change.fitnessSpaceId}'
      : change.ledgerId != null
      ? 'ledger:${change.ledgerId}'
      : '${change.entityType}:${change.entityId}';

  /// 读取分类的父级或交易、周期模板引用的分类；其他实体没有分类依赖。
  String? categoryDependencyId(SyncChange change) {
    final field = switch (change.entityType) {
      'category' => 'parent_id',
      'transaction' || 'recurring_transaction' => 'category_id',
      _ => null,
    };
    if (field == null) return null;
    try {
      final decoded = jsonDecode(change.payload);
      if (decoded is! Map) return null;
      final id = decoded[field];
      return id is String && id.isNotEmpty ? id : null;
    } catch (_) {
      return null;
    }
  }

  /// 根据实际引用展开分类及祖先，仅把本次操作必需的账号分类纳入待推计划。
  ///
  /// 分类属于账号范围，单本队列无法直接包含它们；读取独立分类队列及可见
  /// 父子关系，才能在单本推送时沿用同一套前置登记、拒绝和冲突门禁。
  Future<
    ({
      List<SyncChange> changes,
      Set<String> categoryIds,
      Map<String, Set<String>> categoryParents,
    })
  >
  _categoryDependencyPlan(
    String account,
    List<SyncChange> selected, {
    required bool scoped,
    required Set<String> ownedLedgerIds,
    Set<String> retainedCategoryIds = const {},
  }) async {
    try {
      final categoryIds = <String>{};
      final stack = <String>[
        ...retainedCategoryIds,
        for (final change in selected) ...[
          if (change.entityType == 'category') change.entityId,
          if (change.entityType == 'category' ||
              ownedLedgerIds.contains(change.ledgerId))
            ?categoryDependencyId(change),
        ],
      ];
      if (stack.isEmpty) {
        return (
          changes: selected,
          categoryIds: categoryIds,
          categoryParents: <String, Set<String>>{},
        );
      }
      final categoryChanges = scoped
          ? await (_runtime.db.select(_runtime.db.syncChanges)
                  ..where(
                    (c) =>
                        c.accountId.equals(account) &
                        c.entityType.equals('category') &
                        c.pushedAt.isNull(),
                  )
                  ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
                .get()
          : selected.where((c) => c.entityType == 'category').toList();
      final changesByCategory = <String, List<SyncChange>>{};
      for (final change in categoryChanges) {
        (changesByCategory[change.entityId] ??= []).add(change);
      }
      final categories = await (_runtime.db.select(
        _runtime.db.categories,
      )..where((c) => c.scopeAccountId.equals(account))).get();
      final catalogParents = {
        for (final row in categories) row.id: row.parentId,
      };
      final parents = <String, Set<String>>{};
      while (stack.isNotEmpty) {
        final id = stack.removeLast();
        if (!categoryIds.add(id)) continue;
        // 已确认子分类可能没有队列行，仍须从本地目录取得其父分类依赖。
        // 后继分类意图也可能改变父级，计划同时保留各待推意图的关系。
        final ownParents = <String>{
          ?catalogParents[id],
          for (final change in changesByCategory[id] ?? <SyncChange>[])
            ?categoryDependencyId(change),
        };
        parents[id] = ownParents;
        stack.addAll(ownParents);
      }
      final selectedIds = selected.map((c) => c.id).toSet();
      return (
        changes: [
          ...selected,
          if (scoped)
            for (final change in categoryChanges)
              if (categoryIds.contains(change.entityId) &&
                  !selectedIds.contains(change.id))
                change,
        ],
        categoryIds: categoryIds,
        categoryParents: parents,
      );
    } catch (error, stack) {
      logger.error('SyncService', '读取分类同步依赖失败 account=$account', error, stack);
      Error.throwWithStackTrace(StateError('分类同步准备失败，请稍后重试'), stack);
    }
  }

  /// 展开受阻分类的子级，再阻止所有直接或间接引用它们的待推记录。
  void blockCategoryDependents(
    List<SyncChange> pending,
    Set<String> blockedCategoryIds,
    Set<(String, String)> blocked, {
    Map<String, Set<String>> categoryParents = const {},
    Set<String>? ownedLedgerIds,
  }) {
    if (blockedCategoryIds.isEmpty) return;
    var expanded = true;
    while (expanded) {
      expanded = false;
      for (final entry in categoryParents.entries) {
        if (entry.value.any(blockedCategoryIds.contains) &&
            blockedCategoryIds.add(entry.key)) {
          expanded = true;
        }
      }
      for (final change in pending) {
        // 删除记录只解除引用，不依赖被引用分类的创建或冲突处理结果。
        if (change.action == 'delete') continue;
        if ((change.entityType == 'transaction' ||
                change.entityType == 'recurring_transaction') &&
            ownedLedgerIds != null &&
            !ownedLedgerIds.contains(change.ledgerId)) {
          continue;
        }
        if (!blockedCategoryIds.contains(categoryDependencyId(change))) {
          continue;
        }
        blocked.add((change.entityType, change.entityId));
        // 子分类受阻后继续展开其引用方，队列中的排列顺序不会影响依赖判断。
        if (change.entityType == 'category' &&
            blockedCategoryIds.add(change.entityId)) {
          expanded = true;
        }
      }
    }
  }

  /// 每个实体只处理最早未确认意图；明确拒收前缀后只可重放已发送且结果未知的请求。
  ({List<SyncChange> heads, Set<int> confirmations}) _pendingEntityHeads(
    List<SyncChange> pending,
  ) {
    final chains = <(String, String), List<SyncChange>>{};
    for (final change in pending) {
      (chains[(change.entityType, change.entityId)] ??= []).add(change);
    }
    final heads = <SyncChange>[];
    final confirmations = <int>{};
    for (final chain in chains.values) {
      chain.sort((a, b) => a.id.compareTo(b.id));
      final first = chain.first;
      final next = first.rejectionReason == null
          ? first
          : chain.where((c) => c.rejectionReason == null).firstOrNull;
      // 未发送后继保留在拒收链后，不能为了找到更晚冻结请求而越过它。
      final head = next?.frozenRequest != null ? next! : first;
      heads.add(head);
      if (head.frozenRequest != null && head.rejectionReason == null) {
        confirmations.add(head.id);
      }
    }
    return (heads: heads, confirmations: confirmations);
  }

  /// 执行pushPending对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> pushPending(
    String account, {
    SyncTarget? target,
    Set<SyncDomain>? readyDomains,
  }) async {
    final attempted = <String>{};
    // 单本推送已纳入的分类依赖贯穿整轮；交易迁移确认后源引用会消失，
    // 仍须继续提交其待办删除，且不能扩大到其他账本的交易队列。
    final retainedCategoryIds = <String>{};
    (Object, StackTrace)? failure;
    // 分类是交易的云端前置依赖：本次推送内分类请求失败时，后续账本级变更
    // 必须整轮放弃，否则服务端按「分类不存在」逐条拒绝，把可自动重试的
    // 待上传变成需要用户逐条修改的失败记录。
    var prerequisitesFailed = false;
    while (true) {
      _runtime.requireAccount(account);
      var pending =
          await (_runtime.db.select(_runtime.db.syncChanges)
                ..where(
                  (c) =>
                      c.pushedAt.isNull() &
                      c.accountId.equals(account) &
                      (target == null
                          ? const d.Constant(true)
                          : _runtime.scopeChanges(c, target)),
                )
                ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
              .get();
      if (readyDomains != null) {
        pending = pending.where((change) {
          final domain = change.entityType.startsWith('day_')
              ? SyncDomain.days
              : change.entityType.startsWith('memo_')
              ? SyncDomain.memos
              : fitnessSyncTypes.contains(change.entityType)
              ? SyncDomain.fitness
              : SyncDomain.accounting;
          return readyDomains.contains(domain);
        }).toList();
      }
      if (pending.isEmpty && retainedCategoryIds.isEmpty) break;
      if (await _ports.accountingEnsureReferencedCategoryRegistrations(
        account,
        pending.where((c) => c.ledgerId != null).toList(),
      )) {
        continue;
      }
      final ownedLedgerIds =
          (await (_runtime.db.select(_runtime.db.ledgers)..where(
                    (l) =>
                        l.storageMode.equals('cloud') &
                        l.scopeAccountId.equals(account) &
                        l.ownerAccountId.equals(account) &
                        l.deletedAt.isNull(),
                  ))
                  .get())
              .map((l) => l.id)
              .toSet();
      final categoryPlan = await _categoryDependencyPlan(
        account,
        pending,
        scoped: target != null,
        ownedLedgerIds: ownedLedgerIds,
        retainedCategoryIds: retainedCategoryIds,
      );
      pending = categoryPlan.changes;
      if (pending.isEmpty) break;
      if (target != null) {
        retainedCategoryIds.addAll(categoryPlan.categoryIds);
      }
      final conflicts =
          await (_runtime.db.select(_runtime.db.syncConflicts)..where(
                (c) => c.status.equals('OPEN') & c.accountId.equals(account),
              ))
              .get();
      final conflictedEntities = {
        for (final c in conflicts) (c.entityType, c.entityId),
      };
      final blocked = {
        ...conflictedEntities,
        for (final c in pending)
          if (c.rejectionReason != null) (c.entityType, c.entityId),
      };
      // 依赖门禁：交易/周期模板引用的分类被拒绝或有未决冲突时，先修分类再推
      // 引用方；否则云端必然拒绝该笔记录，用户被迫逐条编辑。
      final blockedCategoryIds = {
        for (final c in conflicts)
          if (c.entityType == 'category') c.entityId,
        for (final c in pending)
          if (c.rejectionReason != null && c.entityType == 'category')
            c.entityId,
      };
      blockCategoryDependents(
        pending,
        blockedCategoryIds,
        blocked,
        categoryParents: categoryPlan.categoryParents,
        ownedLedgerIds: ownedLedgerIds,
      );
      final headPlan = _pendingEntityHeads(pending);
      pending = headPlan.heads;
      final confirmations = headPlan.confirmations;
      pending.sort((a, b) {
        // 分类创建先于引用，分类删除晚于交易迁移或删除，子级删除先于父级。
        final aRemoval = a.entityType == 'category' && a.action == 'delete';
        final bRemoval = b.entityType == 'category' && b.action == 'delete';
        if (aRemoval != bRemoval) return aRemoval ? 1 : -1;
        final aCategory = a.entityType == 'category';
        final bCategory = b.entityType == 'category';
        if (aCategory != bCategory) return aCategory ? -1 : 1;
        if (aCategory && bCategory) {
          final level = _ports
              .payloadCategoryLevelOf(a.payload)
              .compareTo(_ports.payloadCategoryLevelOf(b.payload));
          if (level != 0) {
            return aRemoval && bRemoval ? -level : level;
          }
        }
        // 初始周期历史会引用成员，成员必须先于规则、规则先于派生交易。
        final aParent = a.entityType == 'ledger' || a.entityType == 'member';
        final bParent = b.entityType == 'ledger' || b.entityType == 'member';
        if (aParent != bParent) return aParent ? -1 : 1;
        // 本地账本首次转云可能先登记历史交易；派生发生必须等规则先在服务端存在。
        final aRule = a.entityType == 'recurring_transaction';
        final bRule = b.entityType == 'recurring_transaction';
        if (aRule != bRule) return aRule ? -1 : 1;
        return a.id.compareTo(b.id);
      });
      final scopes = <String, List<SyncChange>>{};
      for (final c in pending) {
        (scopes[scopeKey(c)] ??= []).add(c);
      }
      var progressed = false;
      var referencesProgressed = false;
      for (final own in scopes.values) {
        final categoryRemoval =
            own.first.entityType == 'category' && own.first.action == 'delete';
        // 迁移后的完整载荷只含目标分类，因此先排空可推进的引用修改链。
        // 拒收或冲突由服务端真实引用校验给出明确结果，不阻塞无关分类；
        // 结果未知的冻结删除始终可用原请求确认，不能被后续编辑挡住。
        if (categoryRemoval &&
            referencesProgressed &&
            !own.any((c) => confirmations.contains(c.id))) {
          continue;
        }
        // 分类请求已失败：本轮不再推送依赖它的账本级变更，留待下次重试。
        final prerequisiteBlocked =
            prerequisitesFailed &&
            (own.first.entityType == 'category' ||
                ownedLedgerIds.contains(own.first.ledgerId));
        if (prerequisiteBlocked &&
            !own.any((c) => confirmations.contains(c.id))) {
          continue;
        }
        final first = own.first;
        final parentType = first.dayBookId != null
            ? 'day_book'
            : first.memoBookId != null
            ? 'memo_book'
            : first.fitnessSpaceId != null
            ? 'fitness_space'
            : first.ledgerId != null
            ? 'ledger'
            : null;
        final parentId =
            first.dayBookId ??
            first.memoBookId ??
            first.fitnessSpaceId ??
            first.ledgerId;
        final parentBlocked =
            parentType != null && blocked.contains((parentType, parentId));
        if (parentBlocked &&
            (conflictedEntities.contains((parentType, parentId)) ||
                !own.any((c) => confirmations.contains(c.id)))) {
          continue;
        }
        final scope = await pushScope(first, account);
        if (scope == null) continue;
        var ready = own
            .where(
              (c) =>
                  (!blocked.contains((c.entityType, c.entityId)) ||
                      confirmations.contains(c.id) &&
                          !conflictedEntities.contains((
                            c.entityType,
                            c.entityId,
                          ))) &&
                  (!(parentBlocked || prerequisiteBlocked) ||
                      confirmations.contains(c.id)) &&
                  !attempted.contains(c.mutationId),
            )
            .toList();
        final parent = own.where((c) => c.entityType == parentType).firstOrNull;
        if (scope.stale) {
          ready = [];
        } else if (scope.deleted || scope.hidden || scope.deleting) {
          // 删除不丢弃未知结果：先确认已发送版本，再提交父删除。
          ready = ready.where((c) => c.frozenRequest != null).toList();
          if (ready.isEmpty &&
              scope.deleting &&
              parent != null &&
              parent.rejectionReason == null &&
              !conflictedEntities.contains((
                parent.entityType,
                parent.entityId,
              )) &&
              !attempted.contains(parent.mutationId)) {
            ready = [parent];
          }
        } else if (parent != null) {
          ready = ready
              .where((c) => c.id == parent.id || confirmations.contains(c.id))
              .toList();
        }
        if (parentType != null && scope.syncId == null) {
          ready = ready
              .where(
                (c) =>
                    c.entityType == parentType && c.action == 'upsert' ||
                    confirmations.contains(c.id),
              )
              .toList();
        }
        if (ready.isEmpty) continue;
        // 每个请求固定父范围；实际字节预算由冻结请求统一控制。
        for (final batch in _runtime.chunks(ready, 500)) {
          attempted.addAll(batch.map((c) => c.mutationId));
          try {
            final result = await _pushBatch(batch, account);
            // 同轮后续作用域必须使用刚收到的拒绝或冲突结果，不能等下一轮读库。
            final byMutation = {for (final c in batch) c.mutationId: c};
            for (final outcome in result) {
              if (outcome.status !=
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid &&
                  outcome.status !=
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict) {
                continue;
              }
              final change = byMutation[outcome.mutationId];
              if (change == null) continue;
              blocked.add((change.entityType, change.entityId));
              if (change.entityType == 'category') {
                blockedCategoryIds.add(change.entityId);
              }
            }
            blockCategoryDependents(
              pending,
              blockedCategoryIds,
              blocked,
              categoryParents: categoryPlan.categoryParents,
              ownedLedgerIds: ownedLedgerIds,
            );
            progressed = true;
            if (!categoryRemoval) referencesProgressed = true;
          } catch (error, stack) {
            final cause = cloudOperationFailure(error);
            if (cause.code == 'NETWORK_UNAVAILABLE' ||
                cause.code == 'AUTH_REQUIRED') {
              // 同一连接不可用时终止本轮，避免各账本依次等待网络期限；未知请求保持冻结。
              logger.error(
                'SyncService',
                '上传连接不可用，本轮停止: code=${cause.code}',
                safeErrorSummary(error),
                stack,
              );
              Error.throwWithStackTrace(error, stack);
            }
            failure ??= (error, stack);
            if (own.any((c) => c.entityType == 'category')) {
              prerequisitesFailed = true;
            }
            break;
          }
        }
      }
      if (prerequisitesFailed || !progressed) break;
    }
    await _runtime.inAccountTransaction(
      account,
      () => compactSyncHistory(_runtime.db, accountId: account),
    );
    if (failure != null) Error.throwWithStackTrace(failure.$1, failure.$2);
  }

  /// 表结构差异只在元数据映射处出现，调度策略不再分别实现。
  Future<
    ({String? syncId, bool stale, bool deleted, bool hidden, bool deleting})?
  >
  pushScope(SyncChange change, String account) async {
    if (change.dayBookId != null) {
      if (dayRepository == null) return null;
      final b = await (_runtime.db.select(
        _runtime.db.dayBooks,
      )..where((b) => b.id.equals(change.dayBookId!))).getSingleOrNull();
      if (b == null ||
          b.scopeAccountId != account ||
          b.storageMode != 'cloud') {
        return null;
      }
      return (
        syncId: b.syncId,
        stale: b.isStale,
        deleted: b.deletedAt != null,
        hidden: b.isHidden,
        deleting: b.pendingLocalDelete,
      );
    }
    if (change.memoBookId != null) {
      if (memoRepository == null) return null;
      final b = await _ports.memosMemoBook(change.memoBookId!);
      if (b == null ||
          b.scopeAccountId != account ||
          b.storageMode != 'cloud') {
        return null;
      }
      return (
        syncId: b.syncId,
        stale: b.isStale,
        deleted: b.deletedAt != null,
        hidden: b.isHidden,
        deleting: b.pendingLocalDelete,
      );
    }
    if (fitnessSyncTypes.contains(change.entityType)) {
      if (!fitnessEnabled) return null;
      final b = change.fitnessSpaceId == null
          ? null
          : await _ports.fitnessFitnessSpace(change.fitnessSpaceId!);
      if (b == null ||
          b.scopeAccountId != account ||
          b.storageMode != 'cloud') {
        return null;
      }
      return (
        syncId: b.syncId,
        stale: b.isStale,
        deleted: b.deletedAt != null,
        hidden: b.isHidden,
        deleting: b.pendingLocalDelete,
      );
    }
    final ledgerId = _ledgerScopeId(change);
    if (ledgerId != null) {
      final b = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((b) => b.id.equals(ledgerId))).getSingleOrNull();
      if (b != null &&
          (b.storageMode != 'cloud' || b.scopeAccountId != account)) {
        return null;
      }
      return (
        syncId: b?.syncId,
        stale: b?.bindingStatus == 'stale',
        deleted: false,
        hidden: false,
        deleting: b?.deletedAt != null,
      );
    }
    return (
      syncId: null,
      stale: false,
      deleted: false,
      hidden: false,
      deleting: false,
    );
  }

  /// 推送一批变更并应用 per-mutation 结果，返回已校验的确认列表。
  Future<BuiltList<PostSyncPush200ResponseOutcomesInner>> _pushBatch(
    List<SyncChange> batch,
    String accountId,
  ) async {
    final frozen = <SyncChange>[];
    for (final change in batch) {
      try {
        final value = await freezePending(change, accountId);
        if (value != null) frozen.add(value);
      } catch (error, stack) {
        _throwPreparationFailure(change, error, stack);
      }
    }
    if (frozen.isEmpty) {
      return BuiltList<PostSyncPush200ResponseOutcomesInner>();
    }
    // 冻结后的正文不会被并发编辑改写；按 UTF-8 字节分批，避免小笔记逐条往返。
    // 每条额外预留协议字段空间，最终仍以实际冻结请求的 UTF-8 编码复核。
    final batches = <List<SyncChange>>[];
    var current = <SyncChange>[];
    var bytes = 256;
    for (final change in frozen) {
      final size = utf8.encode(change.frozenRequest!).length + 256;
      if (current.isNotEmpty &&
          (bytes + size > 960 * 1024 || current.length == 500)) {
        batches.add(current);
        current = [];
        bytes = 256;
      }
      current.add(change);
      bytes += size;
    }
    if (current.isNotEmpty) batches.add(current);
    final outcomes = ListBuilder<PostSyncPush200ResponseOutcomesInner>();
    for (final batch in batches) {
      final result = await _pushFrozenBatch(batch, accountId);
      outcomes.addAll(result);
    }
    return outcomes.build();
  }

  /// 单条记录准备失败只携带安全原因和原实体定位，原正文、冻结请求与 mutation 保持原样。
  Never _throwPreparationFailure(
    SyncChange change,
    Object error,
    StackTrace stack,
  ) {
    logger.error(
      'SyncService',
      '准备同步记录失败：type=${change.entityType}，entity=${change.entityId}',
      safeErrorSummary(error),
      stack,
    );
    final failure = cloudOperationFailure(
      error,
      target: SyncTarget(
        change.entityType,
        change.entityId,
        parentId:
            change.ledgerId ??
            change.dayBookId ??
            change.memoBookId ??
            change.fitnessSpaceId,
      ),
    );
    Error.throwWithStackTrace(failure, stack);
  }

  /// 发送冻结批次，提交前校验确认结果，超出预算时拆分且不改写幂等请求。
  Future<BuiltList<PostSyncPush200ResponseOutcomesInner>> _pushFrozenBatch(
    List<SyncChange> frozen,
    String accountId,
  ) async {
    final commands = <PostSyncPushRequestChangesInner>[];
    var initialOccurrenceCount = 0;
    for (final change in frozen) {
      try {
        commands.add(pendingFromFrozen(change));
        final wire = jsonDecode(change.frozenRequest!) as Map;
        final payload = wire['payload'];
        final state = payload is Map ? payload['initial_state'] : null;
        initialOccurrenceCount += state is Map && state['occurrences'] is List
            ? (state['occurrences'] as List).length
            : 0;
      } catch (error, stack) {
        _throwPreparationFailure(change, error, stack);
      }
    }
    final request = PostSyncPushRequest(
      (b) => b
        ..deviceId = _runtime.deviceId
        ..changes = ListBuilder(commands),
    );
    // 直接拼接已冻结的变更正文，保留未知字段、显式 null 和原始 JSON 表达。
    // 请求模型只负责当前类型与身份检查，发送时不能重新序列化旧 mutation 的正文。
    final body =
        '{"device_id":${jsonEncode(_runtime.deviceId)},"changes":['
        '${frozen.map((change) => change.frozenRequest!).join(',')}]}';
    if (frozen.length > 1 &&
        (initialOccurrenceCount > 10000 ||
            utf8.encode(body).length > 1024 * 1024)) {
      final middle = frozen.length ~/ 2;
      final left = await _pushFrozenBatch(frozen.sublist(0, middle), accountId);
      final right = await _pushFrozenBatch(frozen.sublist(middle), accountId);
      return left.rebuild((b) => b.addAll(right));
    }
    _runtime.requireAccount(accountId);
    try {
      final response = await _invokePush(request, body);
      final outcomes = response?.outcomes;
      if (outcomes == null ||
          outcomes.length != frozen.length ||
          outcomes.map((o) => o.mutationId).toSet().length != outcomes.length) {
        throw const FormatException('同步确认响应不完整');
      }
      final byMutation = {for (final o in outcomes) o.mutationId: o};
      for (final change in frozen) {
        final outcome = byMutation[change.mutationId];
        if (outcome == null || outcome.entityId != change.entityId) {
          throw const FormatException('同步确认身份不一致');
        }
        if (change.action == 'delete' &&
            ['ledger', 'day_book', 'memo_book'].contains(change.entityType) &&
            outcome.status ==
                PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored) {
          _runtime.requireAccount(accountId);
          final binding =
              (jsonDecode(change.frozenRequest!) as Map)['sync_id'] as String?;
          if (!await _ports.operationsScopeDeleted(
            SyncTarget(change.entityType, change.entityId),
            binding,
          )) {
            await _runtime.inAccountTransaction(
              accountId,
              () => markPendingStale(change, accountId),
            );
            throw StateError('云端原件仍存在，删除尚未确认，请处理同步绑定');
          }
        }
      }
      await _runtime.inAccountTransaction(accountId, () async {
        for (final change in frozen) {
          final outcome = byMutation[change.mutationId];
          if (outcome == null || outcome.entityId != change.entityId) {
            throw const FormatException('同步确认身份不一致');
          }
          await applyPendingOutcome(change, outcome, accountId);
        }
      });
      return outcomes;
    } on DioException catch (error) {
      if (error.response?.statusCode == 413) {
        await _runtime.inAccountTransaction(accountId, () async {
          for (final change in frozen) {
            await (_runtime.db.update(
              _runtime.db.syncChanges,
            )..where((c) => c.id.equals(change.id))).write(
              const SyncChangesCompanion(
                rejectionReason: d.Value('SYNC_BUDGET'),
              ),
            );
          }
        });
        return BuiltList<PostSyncPush200ResponseOutcomesInner>();
      }
      if (error.response?.statusCode != 412) rethrow;
      await _runtime.inAccountTransaction(accountId, () async {
        for (final change in frozen) {
          await markPendingStale(change, accountId);
        }
      });
      return BuiltList<PostSyncPush200ResponseOutcomesInner>();
    }
  }

  /// 通过现有认证客户端发送冻结正文，测试替身保持生成 API 的注入接口。
  Future<PostSyncPush200Response?> _invokePush(
    PostSyncPushRequest request,
    String body,
  ) async {
    if (_runtime.apiOverride != null) {
      return (await _runtime.api.postSyncPush(
        postSyncPushRequest: request,
      )).data;
    }
    final Response<Object> response;
    try {
      // 与生成 API 使用同一个 Dio 和 Bearer 元数据，认证刷新、重试与追踪拦截器继续生效。
      // String 正文由 Dio 原样编码，401 重试也复用同一冻结内容。
      response = await _runtime.client.dio.post<Object>(
        '/api/v1/sync/push',
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          extra: const {
            'secure': [
              {'type': 'http', 'scheme': 'bearer', 'name': 'bearerAuth'},
            ],
          },
        ),
      );
    } catch (error, stackTrace) {
      logger.error('SyncService', '冻结同步请求发送失败', error.runtimeType, stackTrace);
      rethrow;
    }
    try {
      return _runtime.client.serializers.deserializeWith(
        PostSyncPush200Response.serializer,
        response.data,
      );
    } catch (error, stackTrace) {
      // 解析异常可能携带响应片段，日志只记录类型与堆栈，保留生成 API 的异常包装语义。
      logger.error('SyncService', '同步确认响应解析失败', error.runtimeType, stackTrace);
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// 执行freezePending对应的同步步骤，沿用所属域的身份与事务规则。
  Future<SyncChange?> freezePending(SyncChange change, String account) async {
    if (change.dayBookId != null) {
      return _ports.daysFreezeDayChange(change, account);
    }
    if (change.memoBookId != null) {
      return _ports.memosFreezeMemoChange(change, account);
    }
    if (fitnessSyncTypes.contains(change.entityType)) {
      return _ports.fitnessFreezeFitnessChange(change, account);
    }
    return _runtime.db.transaction(() async {
      _runtime.requireAccount(account);
      final current = await (_runtime.db.select(
        _runtime.db.syncChanges,
      )..where((c) => c.id.equals(change.id))).getSingleOrNull();
      if (current == null || current.pushedAt != null) return null;
      if (current.frozenRequest != null) return current;
      final ids = await _ports.accountingSyncIdsForLedgers([
        _ledgerScopeId(current),
      ]);
      final wire = jsonEncode(
        _runtime.modelMap(
          _ports.payloadToChangeInner(current, ids),
          PostSyncPushRequestChangesInner.serializer,
        ),
      );
      await (_runtime.db.update(_runtime.db.syncChanges)
            ..where((c) => c.id.equals(current.id)))
          .write(SyncChangesCompanion(frozenRequest: d.Value(wire)));
      return current.copyWith(frozenRequest: d.Value(wire));
    });
  }

  /// 校验完整冻结身份与父范围，模型仅用于读取，实际发送始终沿用原始字节。
  PostSyncPushRequestChangesInner pendingFromFrozen(SyncChange change) {
    var stage = 'identity';
    try {
      final frozen = change.frozenRequest!;
      final wire = jsonDecode(frozen) as Map<String, dynamic>;
      // 账本实体自身就是财务父范围，范围不能指向另一账本。
      final ledgerRoot = change.entityType == 'ledger';
      final expectedLedgerId = _ledgerScopeId(change);
      if (wire['mutation_id'] != change.mutationId ||
          wire['entity_id'] != change.entityId ||
          wire['entity_type'] != change.entityType ||
          wire['action'] != change.action ||
          (ledgerRoot &&
              change.ledgerId != null &&
              change.ledgerId != change.entityId) ||
          wire['ledger_id'] != expectedLedgerId ||
          wire['day_book_id'] != change.dayBookId ||
          wire['memo_book_id'] != change.memoBookId ||
          wire['fitness_space_id'] != change.fitnessSpaceId) {
        throw const FormatException('冻结请求身份与父范围不一致');
      }
      stage = 'time';
      final frozenUpdatedAt = tryParseUtcWireTimestamp(wire['updated_at']);
      if (frozenUpdatedAt == null) {
        throw const FormatException('冻结请求缺少有效 UTC 时间');
      }
      stage = 'payload';
      if (change.dayBookId != null) {
        return _runtime.changeCodec.dayChangeFromFrozen(frozen);
      }
      if (change.memoBookId != null) {
        return _runtime.changeCodec.memoChangeFromFrozen(frozen);
      }
      if (fitnessSyncTypes.contains(change.entityType)) {
        return _runtime.changeCodec.fitnessChangeFromFrozen(frozen);
      }
      return _ports.payloadToChangeInner(
        change.copyWith(
          payload: jsonEncode(wire['payload']),
          action: wire['action'] as String,
          mutationId: wire['mutation_id'] as String,
          updatedAt: frozenUpdatedAt,
          baseRevision: d.Value(wire['base_revision'] as int?),
        ),
        {
          if (expectedLedgerId != null && wire['sync_id'] != null)
            expectedLedgerId: wire['sync_id'] as String,
        },
      );
    } catch (error, stackTrace) {
      logger.error(
        'SyncService',
        '冻结请求校验失败：type=${change.entityType}，mutation=${change.mutationId}，stage=$stage',
        safeErrorSummary(error),
        stackTrace,
      );
      Error.throwWithStackTrace(
        SyncOperationFailure(
          code: 'SYNC_FROZEN_REQUEST_INVALID',
          message: stage == 'time'
              ? '待确认上传请求的时间信息无效，原记录已保留，请反馈此问题。'
              : '待确认上传请求与原记录不一致或无法读取，数据已保留，请反馈此问题。',
        ),
        stackTrace,
      );
    }
  }

  /// 执行applyPendingOutcome对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyPendingOutcome(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  ) async {
    if (await pushScope(change, account) == null) {
      throw StateError('同步目标归属已变化');
    }
    if (change.entityType == 'category' &&
        await _ports.categoryApplyOutcome(change, outcome, account)) {
      await _recoverCategoryDependents(change, outcome, account);
      return;
    }
    switch (outcome.status) {
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid:
        final code = syncRejectionCode(outcome.code);
        logger.warning(
          'SyncService',
          '云端拒绝同步变更: type=${change.entityType}, entity=${change.entityId}, mutation=${change.mutationId}, code=$code',
        );
        await (_runtime.db.update(
          _runtime.db.syncChanges,
        )..where((c) => c.id.equals(change.id))).write(
          SyncChangesCompanion(
            rejectionReason: d.Value(syncRejectionReason(code)),
            rejectionCode: d.Value(code),
          ),
        );
        return;
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
          PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
        await (_runtime.db.update(
          _runtime.db.syncChanges,
        )..where((c) => c.id.equals(change.id))).write(
          SyncChangesCompanion(
            pushedAt: d.Value(DateTime.now().toUtc()),
            payload: const d.Value('{}'),
            frozenRequest: const d.Value(null),
            rejectionReason: const d.Value(null),
            rejectionCode: const d.Value(null),
          ),
        );
        if (outcome.revision case final revision?) {
          await (_runtime.db.update(_runtime.db.syncChanges)..where(
                (c) =>
                    c.entityType.equals(change.entityType) &
                    c.entityId.equals(change.entityId) &
                    c.pushedAt.isNull() &
                    c.frozenRequest.isNull() &
                    c.accountId.equals(account),
              ))
              .write(SyncChangesCompanion(baseRevision: d.Value(revision)));
        }
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
        break;
      default:
        throw const FormatException('同步确认状态无效');
    }
    await _recoverCategoryDependents(change, outcome, account);
    if (change.dayBookId != null) {
      await _ports.daysApplyDayPushOutcome(change, outcome, account);
    } else if (change.memoBookId != null) {
      await _ports.memosApplyMemoPushOutcome(change, outcome, account);
    } else if (fitnessSyncTypes.contains(change.entityType)) {
      await _ports.fitnessApplyFitnessPushOutcome(change, outcome, account);
    } else {
      await _ports.accountingApplyPushOutcomes(
        [change],
        BuiltList([outcome]),
        account,
      );
    }
    if (change.action == 'delete' &&
        [
          'ledger',
          'day_book',
          'memo_book',
          'fitness_space',
        ].contains(change.entityType) &&
        (outcome.status ==
                PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
            outcome.status ==
                PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored)) {
      final target = SyncTarget(change.entityType, change.entityId);
      await _ports.operationsClearTargetPending(target, account, retire: true);
      if (change.entityType == 'ledger') {
        await (_runtime.db.update(
          _runtime.db.ledgers,
        )..where((b) => b.id.equals(change.entityId))).write(
          LedgersCompanion(
            deletedAt: d.Value(DateTime.now().toUtc()),
            bindingStatus: const d.Value(null),
          ),
        );
      }
      final source = await _ports.transfersTransferSource(target, account);
      final operation =
          'local-move:$account:${target.type}:${target.id}:${source.syncId}';
      final copy = await _ports.transfersTransferCopy(
        target,
        account,
        operation,
      );
      if (copy != null && copy.hidden) {
        await _ports.transfersPublishTransferCopy(target, copy.id, account);
      }
    }
  }

  /// 明确接受或存活权威快照证明分类已就绪，冲突、墓碑与无证据的 ignored 保持暂停。
  Future<void> _recoverCategoryDependents(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  ) async {
    if (change.entityType != 'category' || change.action != 'upsert') return;
    final state = outcome.categoryState;
    final confirmed =
        outcome.status ==
        PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted;
    final existing =
        outcome.status ==
            PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored &&
        state?.id == change.entityId &&
        state?.deletedAt == null;
    if (confirmed || existing) {
      await (_runtime.db.update(_runtime.db.categories)..where(
            (c) =>
                c.id.equals(change.entityId) & c.scopeAccountId.equals(account),
          ))
          .write(const CategoriesCompanion(cloudRegistered: d.Value(true)));
      await _runtime.rejectionRecovery.categoryAvailable(
        change.entityId,
        account,
      );
    }
  }

  /// 执行markPendingStale对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> markPendingStale(SyncChange change, String account) async {
    if (change.dayBookId != null) {
      await _ports.daysProtectDayBook(change.dayBookId!, account, stale: true);
    } else if (change.memoBookId != null) {
      await _ports.memosProtectMemoBook(
        change.memoBookId!,
        account,
        stale: true,
      );
    } else if (change.fitnessSpaceId != null) {
      await _ports.fitnessProtectFitnessSpace(
        change.fitnessSpaceId!,
        account,
        stale: true,
      );
    } else if (change.ledgerId != null) {
      await _ports.operationsQuarantineLedger(
        change.ledgerId!,
        account,
        stale: true,
      );
    }
  }

  /// 推送本地待同步变更（分批 ≤500，契约上限）。
  ///
  /// 同实体 FIFO：存在 OPEN 冲突的实体暂停推送——前序 mutation
  /// 冲突时后序不得继续发送，等待用户解决（冲突 UI）。
  Future<void> push({Set<SyncDomain>? readyDomains}) async {
    // 账号域过滤：只推送当前账号的 mutation，
    // account_id 与当前账号不一致的数据一律不上传（B 推不到 A 的数据）。
    final String accountId;
    try {
      accountId = _runtime.currentAccountIdForCloudOperation('推送同步变更');
    } catch (e, st) {
      // 无法确认账号域时必须失败关闭；继续推送可能把其他账号的 mutation
      // 带入当前请求，宁可保留本地队列等待下次重试，也不能跨账号泄漏。
      logger.error('SyncService', '读取当前同步账号失败，已跳过 push', e, st);
      return;
    }
    await pushPending(accountId, readyDomains: readyDomains);
  }
}

/// 按实体顺序处理待推队列、冻结请求与确认结果所需的外部协作端口。
class SyncPushCoordinatorPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const SyncPushCoordinatorPorts({
    required this.accountingApplyPushOutcomes,
    required this.categoryApplyOutcome,
    required this.accountingEnsureReferencedCategoryRegistrations,
    required this.accountingSyncIdsForLedgers,
    required this.daysApplyDayPushOutcome,
    required this.daysFreezeDayChange,
    required this.daysProtectDayBook,
    required this.fitnessApplyFitnessPushOutcome,
    required this.fitnessFitnessSpace,
    required this.fitnessFreezeFitnessChange,
    required this.fitnessProtectFitnessSpace,
    required this.memosApplyMemoPushOutcome,
    required this.memosFreezeMemoChange,
    required this.memosMemoBook,
    required this.memosProtectMemoBook,
    required this.operationsClearTargetPending,
    required this.operationsQuarantineLedger,
    required this.operationsScopeDeleted,
    required this.payloadCategoryLevelOf,
    required this.payloadToChangeInner,
    required this.transfersPublishTransferCopy,
    required this.transfersTransferCopy,
    required this.transfersTransferSource,
  });

  /// 专用分类确认只清来源请求，不走通用实体副本处理。
  final Future<bool> Function(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  )
  categoryApplyOutcome;

  /// 委托accounting域执行applyPushOutcomes。
  final Future<void> Function(
    List<SyncChange> batch,
    BuiltList<PostSyncPush200ResponseOutcomesInner> outcomes,
    String accountId,
  )
  accountingApplyPushOutcomes;

  /// 委托accounting域执行ensureReferencedCategoryRegistrations。
  final Future<bool> Function(String accountId, List<SyncChange> changes)
  accountingEnsureReferencedCategoryRegistrations;

  /// 委托accounting域执行syncIdsForLedgers。
  final Future<Map<String, String>> Function(Iterable<String?> ledgerIds)
  accountingSyncIdsForLedgers;

  /// 委托days域执行applyDayPushOutcome。
  final Future<void> Function(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String accountId,
  )
  daysApplyDayPushOutcome;

  /// 委托days域执行freezeDayChange。
  final Future<SyncChange> Function(SyncChange source, String accountId)
  daysFreezeDayChange;

  /// 委托days域执行protectDayBook。
  final Future<void> Function(
    String id,
    String accountId, {
    bool stale,
    bool deleted,
  })
  daysProtectDayBook;

  /// 委托fitness域执行applyFitnessPushOutcome。
  final Future<void> Function(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  )
  fitnessApplyFitnessPushOutcome;

  /// 委托fitness域执行fitnessSpace。
  final Future<FitnessSpaceRow?> Function(String id) fitnessFitnessSpace;

  /// 委托fitness域执行freezeFitnessChange。
  final Future<SyncChange?> Function(SyncChange source, String account)
  fitnessFreezeFitnessChange;

  /// 委托fitness域执行protectFitnessSpace。
  final Future<void> Function(
    String id,
    String account, {
    bool stale,
    bool deleted,
  })
  fitnessProtectFitnessSpace;

  /// 委托memos域执行applyMemoPushOutcome。
  final Future<void> Function(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String accountId,
  )
  memosApplyMemoPushOutcome;

  /// 委托memos域执行freezeMemoChange。
  final Future<SyncChange?> Function(SyncChange source, String accountId)
  memosFreezeMemoChange;

  /// 委托memos域执行memoBook。
  final Future<MemoBookRow?> Function(String id) memosMemoBook;

  /// 委托memos域执行protectMemoBook。
  final Future<void> Function(
    String id,
    String accountId, {
    bool stale,
    bool deleted,
  })
  memosProtectMemoBook;

  /// 委托operations域执行clearTargetPending。
  final Future<void> Function(SyncTarget target, String? account, {bool retire})
  operationsClearTargetPending;

  /// 委托operations域执行quarantineLedger。
  final Future<void> Function(
    String id,
    String? account, {
    bool stale,
    bool deleted,
    DateTime? remoteDeletedAt,
  })
  operationsQuarantineLedger;

  /// 委托operations域执行scopeDeleted。
  final Future<bool> Function(SyncTarget target, String? syncId)
  operationsScopeDeleted;

  /// 委托payload域执行categoryLevelOf。
  final int Function(String rawPayload) payloadCategoryLevelOf;

  /// 委托payload域执行toChangeInner。
  final PostSyncPushRequestChangesInner Function(
    SyncChange ch,
    Map<String, String> syncIdByLedger,
  )
  payloadToChangeInner;

  /// 委托transfers域执行publishTransferCopy。
  final Future<void> Function(SyncTarget target, String id, String account)
  transfersPublishTransferCopy;

  /// 委托transfers域执行transferCopy。
  final Future<({String id, bool hidden})?> Function(
    SyncTarget target,
    String account,
    String operation,
  )
  transfersTransferCopy;

  /// 委托transfers域执行transferSource。
  final Future<({String? syncId, bool deleted, bool stale})> Function(
    SyncTarget target,
    String account,
  )
  transfersTransferSource;
}
