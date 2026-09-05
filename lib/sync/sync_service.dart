import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/sync/ledger_sync_state.dart';
import 'package:sesame_notes/sync/lww_conflict.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;

/// 同步服务：围绕生成 API client 的最小编排。
///
/// - push：读 sync_changes 未推送变更 → POST /sync/push（≤500/批）→ 标记已推送；
/// - pull：按 server_cursor 增量拉取 → 逐条 apply 到本地 → 整页成功后才推进游标；
/// - full：整本账本快照落库（新设备/本地清空后收敛）。
///
/// 分层约定：core/sync 是 data 层的唯一特许消费者——同步引擎
/// 必须直读 sync_changes / 直写业务表，故本目录直连 db.dart 属设计内；
/// data→core 仅 logger 横切引用，可接受。
class SyncService {
  final SesameApiClient client;
  final SesameDatabase db;
  final String deviceId;

  /// 测试注入点:默认用生成客户端构造;测试可注入 mock 拦截 HTTP 行为。
  final SyncApi? _apiOverride;

  /// 本地状态保护 Fork 的仓储：412 → 先保护再标记 STALE_BINDING；
  /// 未注入时降级为仅标记 stale（不产生保护副本）。
  final LocalLedgerRepository? repo;

  /// 读取当前设备 localSelfId（保护 Fork 的"我是谁"决策用）。
  final Future<String> Function()? localSelfIdLoader;

  /// 读取当前登录账号 id（保护 Fork 的重映射决策用；未登录为 null）。
  final String? Function()? currentAccountIdGetter;

  SyncService({
    required this.client,
    required this.db,
    required this.deviceId,
    SyncApi? apiOverride,
    this.repo,
    this.localSelfIdLoader,
    this.currentAccountIdGetter,
  }) : _apiOverride = apiOverride; // ignore: prefer_initializing_formals

  SyncApi get _api => _apiOverride ?? SyncApi(client.dio, client.serializers);

  /// 读取云同步操作绑定的账号域。
  ///
  /// 生产环境注入账号读取器后必须失败关闭：账号缺失或读取异常时停止落库，
  /// 避免把云端数据写进本地域，或生成下一次 push 永远选不中的 mutation。
  String? _currentAccountIdForCloudOperation(String operation) {
    try {
      final accountId = currentAccountIdGetter?.call();
      if (currentAccountIdGetter != null &&
          (accountId == null || accountId.isEmpty)) {
        throw StateError('当前未登录，无法$operation');
      }
      return accountId;
    } catch (error, stackTrace) {
      logger.error('SyncService', '读取当前账号失败，已取消$operation', error, stackTrace);
      rethrow;
    }
  }

  /// 推送本地待同步变更（分批 ≤500，契约上限）。
  ///
  /// 同实体 FIFO：存在 OPEN 冲突的实体暂停推送——前序 mutation
  /// 冲突时后序不得继续发送，等待用户解决（冲突 UI）。
  Future<void> push() async {
    // 账号域过滤（不变量 I-05 配套）：注入账号上下文后只推送当前账号的
    // mutation，account_id 为 null 的旧数据一律不上传（B 推不到 A 的数据）；
    // 未注入账号上下文的调用方（旧行为）保持推送全部待同步变更。
    String? accountId;
    try {
      accountId = currentAccountIdGetter?.call();
    } catch (e, st) {
      // 无法确认账号域时必须失败关闭；继续推送可能把其他账号的 mutation
      // 带入当前请求，宁可保留本地队列等待下次重试，也不能跨账号泄漏。
      logger.error('SyncService', '读取当前同步账号失败，已跳过 push', e, st);
      return;
    }
    if (currentAccountIdGetter != null && accountId == null) {
      logger.info('SyncService', '当前未登录，保留 pending mutation 并跳过 push');
      return;
    }
    var pending =
        await (db.select(db.syncChanges)
              ..where((t) {
                final unpushed = t.pushedAt.isNull();
                if (accountId == null) return unpushed;
                return unpushed & t.accountId.equals(accountId);
              })
              ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
            .get();
    if (pending.isEmpty) return;

    // 分类先导登记：账本级变更引用的 user 级分类必须先于引用它的变更上云，
    // 否则服务端按序应用时分类不存在，交易被判 invalid 永久丢弃。
    final ensuredCategories = await _ensureReferencedCategoryRegistrations(
      accountId,
      pending,
    );
    if (ensuredCategories) {
      // 重新读取以纳入刚登记的分类变更（新行 id 更大，批次内按下方重排置前）
      pending =
          await (db.select(db.syncChanges)
                ..where((t) {
                  final unpushed = t.pushedAt.isNull();
                  if (accountId == null) return unpushed;
                  return unpushed & t.accountId.equals(accountId);
                })
                ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
              .get();
    }

    // 有 OPEN 冲突的实体整组暂停（本地 pending 保留，解决后重推）
    final conflicted = await _openConflictEntityIds();
    final blockedLedgers = await _blockedLedgerIds(
      pending.map((change) => change.ledgerId),
    );
    final sendable = pending
        .where(
          (change) =>
              !conflicted.contains(change.entityId) &&
              (change.ledgerId == null ||
                  !blockedLedgers.contains(change.ledgerId)),
        )
        .toList();
    if (sendable.isEmpty) return;

    // user 级变更（分类/汇率）置前：服务端按请求数组顺序逐条应用，
    // 分类必须早于引用它的账本级变更落库。
    final ordered = [
      ...sendable.where((change) => change.ledgerId == null),
      ...sendable.where((change) => change.ledgerId != null),
    ];

    for (final batch in _chunks(ordered, 500)) {
      final outcomes = await _pushBatch(batch);
      logger.info(
        'SyncService',
        'push 完成 ${batch.length} 条, cursor=${outcomes.$2}',
      );
    }
  }

  /// 把账本级待推变更引用的未登记分类补登记为 user 级 upsert 变更。
  ///
  /// 种子默认分类是确定性 UUIDv5 且通常在无云上下文时创建，从未进过同步队列；
  /// 云账本交易引用它们时必须在交易之前上云。返回是否登记了任何新变更。
  Future<bool> _ensureReferencedCategoryRegistrations(
    String? accountId,
    List<SyncChange> changes,
  ) async {
    if (accountId == null || accountId.isEmpty) return false;
    final referencedIds = <String>{};
    for (final change in changes) {
      if (change.entityType != 'transaction' &&
          change.entityType != 'recurring_transaction') {
        continue;
      }
      Map<String, dynamic> payload;
      try {
        payload = jsonDecode(change.payload) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      final categoryId = payload['category_id'] as String?;
      if (categoryId != null && categoryId.isNotEmpty) {
        referencedIds.add(categoryId);
      }
    }
    if (referencedIds.isEmpty) return false;

    final rows = await (db.select(
      db.categories,
    )..where((c) => c.deletedAt.isNull())).get();
    if (rows.isEmpty) return false;
    final rowById = {for (final row in rows) row.id: row};
    // 沿 parentId 展开祖先链：交易直接引用二级分类时，其一/多级父分类必须
    // 先于子分类上云，否则服务端按序应用时报「父分类不存在」。
    final ensureIds = <String>{};
    final stack = referencedIds.toList();
    while (stack.isNotEmpty) {
      final id = stack.removeLast();
      final row = rowById[id];
      if (row == null || !ensureIds.add(id)) continue;
      final parentId = row.parentId;
      if (parentId != null && parentId.isNotEmpty) stack.add(parentId);
    }
    final pendingCategoryChanges =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  c.entityType.equals('category') &
                  c.entityId.isIn(ensureIds) &
                  c.accountId.equals(accountId) &
                  c.pushedAt.isNull(),
            ))
            .get();
    final pendingIds = {
      for (final change in pendingCategoryChanges) change.entityId,
    };
    final toEnsure =
        ensureIds
            .map((id) => rowById[id]!)
            .where(
              (row) =>
                  row.scopeAccountId != accountId &&
                  !pendingIds.contains(row.id),
            )
            .toList()
          // 服务端按请求数组顺序应用：一级（父）必须先于二级（子）落库
          ..sort((a, b) => a.level.compareTo(b.level));
    if (toEnsure.isEmpty) return false;

    await db.transaction(() async {
      for (final category in toEnsure) {
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'category',
                entityId: category.id,
                action: 'upsert',
                payload: jsonEncode({
                  'name': category.name,
                  'kind': category.kind,
                  // wire 契约中 level 为字符串枚举（'1'/'2'）
                  'level': category.level.toString(),
                  'sort_order': category.sortOrder,
                  'icon': category.icon,
                  'parent_id': category.parentId,
                }),
                updatedAt: category.updatedAt,
                mutationId: const Uuid().v4(),
                accountId: d.Value(accountId),
              ),
            );
        await (db.update(db.categories)..where((c) => c.id.equals(category.id)))
            .write(CategoriesCompanion(scopeAccountId: d.Value(accountId)));
      }
    });
    logger.info('SyncService', '已登记 ${toEnsure.length} 个未上云分类，先于引用它们的变更推送');
    return true;
  }

  /// 权威查询源账本在服务端的存活状态（云转本地移动的 ignored 复核专用）：
  /// 404 = 已 tombstone/不可访问（视为已删除）；412 = 时间线不一致但账本存活。
  Future<({bool deleted})> fetchLedgerRemoteStatus(String ledgerId) async {
    try {
      await _api.getSyncFull(ledgerId: ledgerId);
      return (deleted: false);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return (deleted: true);
      if (error.response?.statusCode == 412) return (deleted: false);
      rethrow;
    }
  }

  /// 推送给定账本的账本级 delete 变更并返回 outcome（云转本地移动专用）。
  ///
  /// 设计意图：只把「accepted」视为成功；「ignored」必须由调用方再经服务端
  /// 权威查询证明源账本已 tombstone；invalid/conflict 一律不继续，保证
  /// 隐藏 Fork 发布前云端删除是真实发生的。
  /// 推送给定账本的账本级 delete 变更并返回 outcome 状态字符串
  /// （'accepted' | 'ignored' | 'invalid' | 'conflict' | null=无待推变更）。
  /// 云转本地移动专用：业务层不直接依赖生成客户端类型。
  Future<String?> pushLedgerDelete({required String ledgerId}) async {
    final pending =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  c.ledgerId.equals(ledgerId) &
                  c.entityType.equals('ledger') &
                  c.action.equals('delete') &
                  c.pushedAt.isNull(),
            ))
            .get();
    if (pending.isEmpty) return null;
    final outcomes = await _pushBatch(pending);
    final mine = outcomes.$1.where((o) => o.entityId == ledgerId).firstOrNull;
    return mine?.status.name;
  }

  /// 推送一批变更并应用 per-mutation 结果；返回 outcome 列表与最新服务端游标。
  Future<(BuiltList<PostSyncPush200ResponseOutcomesInner>, String)> _pushBatch(
    List<SyncChange> batch,
  ) async {
    // 预加载本批涉及账本的同步身份（一次查询）：账本级变更必须携带 sync_id，
    // 首次上云（本地尚未持有 sync_id）则缺省，由服务端创建账本后经 outcome 返回。
    final ledgerIds = batch.map((c) => c.ledgerId).whereType<String>().toSet();
    final syncIdByLedger = <String, String>{};
    if (ledgerIds.isNotEmpty) {
      final rows = await (db.select(
        db.ledgers,
      )..where((l) => l.id.isIn(ledgerIds))).get();
      for (final row in rows) {
        if (row.syncId != null) syncIdByLedger[row.id] = row.syncId!;
      }
    }
    final req = PostSyncPushRequest(
      (b) => b
        ..deviceId = deviceId
        ..changes = BuiltList<PostSyncPushRequestChangesInner>(
          batch.map((ch) => _toChangeInner(ch, syncIdByLedger)).toList(),
        ).toBuilder(),
    );
    final resp = await _api.postSyncPush(postSyncPushRequest: req);
    // per-mutation 结果处理：accepted/ignored 标记已推送并落 revision；
    // conflict 保留 pending 并写入 SyncConflict；invalid 标记已推送避免无限重试
    await _applyPushOutcomes(batch, resp.data!.outcomes);
    return (resp.data!.outcomes, resp.data!.serverCursor);
  }

  /// 按 per-mutation 结果处理本批队列行。
  ///
  /// - accepted / ignored：已应用（或幂等重放）→ 标记 pushedAt；transaction 更新
  ///   server_revision（ignored 幂等场景服务端同样返回首次结果 revision）；
  /// - conflict：不标记 pushedAt（本地 pending 保留，解决后基于最新 revision 重推），
  ///   创建/更新 OPEN 冲突记录（本地/云端两版 payload + 双方 revision 供 UI）；
  /// - invalid：载荷类错误，标记已推送并记日志（避免同步队列无限重试卡死）。
  Future<void> _applyPushOutcomes(
    List<SyncChange> batch,
    BuiltList<PostSyncPush200ResponseOutcomesInner> outcomes,
  ) async {
    final outcomeByMutation = {for (final o in outcomes) o.mutationId: o};
    final pushedAt = DateTime.now().toUtc();
    for (final ch in batch) {
      final outcome = outcomeByMutation[ch.mutationId];
      if (outcome == null) continue;
      switch (outcome.status) {
        case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
            PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
          await (db.update(db.syncChanges)..where((t) => t.id.equals(ch.id)))
              .write(SyncChangesCompanion(pushedAt: d.Value(pushedAt)));
          if (ch.entityType == 'transaction' && outcome.revision != null) {
            await _updateServerRevision(ch.entityId, outcome.revision!);
          }
          // ledger 实体返回的 sync_id：首次上云创建账本时据此建立绑定
          final syncId = outcome.syncId;
          if (syncId != null) {
            await (db.update(db.ledgers)
                  ..where((l) => l.id.equals(outcome.entityId)))
                .write(LedgersCompanion(syncId: d.Value(syncId)));
          }
        case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
          await _upsertConflict(
            ledgerId: ch.ledgerId ?? '',
            entityType: ch.entityType,
            entityId: ch.entityId,
            localPayload: ch.payload,
            baseRevision: ch.baseRevision,
            remoteRevision: outcome.currentRevision,
            remotePayload: outcome.currentDeleted == true
                ? jsonEncode({
                    'deleted': true,
                    'revision': outcome.currentRevision,
                  })
                // JsonObject 需要解包 value 后才能 jsonEncode
                : jsonEncode(
                    outcome.currentEntity?.value ?? <Object, Object>{},
                  ),
            localMutationId: ch.mutationId,
          );
        case PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid:
          await (db.update(db.syncChanges)..where((t) => t.id.equals(ch.id)))
              .write(SyncChangesCompanion(pushedAt: d.Value(pushedAt)));
          logger.warning(
            'SyncService',
            'mutation ${ch.mutationId} 被服务端拒绝: ${outcome.message}',
          );
        default:
          break;
      }
    }
  }

  /// 更新云端账本交易的 server_revision（推送成功后服务端权威值）。
  Future<void> _updateServerRevision(String entityId, int revision) async {
    await (db.update(db.transactions)..where((t) => t.id.equals(entityId)))
        .write(TransactionsCompanion(serverRevision: d.Value(revision)));
  }

  /// pull 侧冲突落库：远端修订超前于本地 pending 基线时，
  /// 保留本地最新修改（链尾 payload）与远端版本，禁止直接覆盖。
  Future<void> _upsertPullConflict(
    String id,
    List<SyncChange> chain,
    Map<String, dynamic> remotePayload,
    int remoteRevision,
    String action,
  ) async {
    final head = chain.first; // 链首：base 起点（解决冲突的基线）
    final tail = chain.last; // 链尾：本地最新修改
    await _upsertConflict(
      ledgerId: tail.ledgerId ?? '',
      entityType: 'transaction',
      entityId: id,
      localPayload: tail.payload,
      baseRevision: head.baseRevision,
      remoteRevision: remoteRevision,
      remotePayload: action == 'delete'
          ? jsonEncode({'deleted': true, 'revision': remoteRevision})
          : jsonEncode(remotePayload),
      localMutationId: head.mutationId,
    );
  }

  /// 查询存在 OPEN 冲突的实体集合（这些实体的 pending 暂停推送）。
  Future<Set<String>> _openConflictEntityIds() async {
    final rows = await (db.select(
      db.syncConflicts,
    )..where((c) => c.status.equals('OPEN'))).get();
    return rows.map((c) => c.entityId).toSet();
  }

  /// 创建或更新实体的 OPEN 冲突记录（同一实体冲突唯一，解决前不重复创建）。
  Future<void> _upsertConflict({
    required String ledgerId,
    required String entityType,
    required String entityId,
    required String localPayload,
    required int? baseRevision,
    required int? remoteRevision,
    required String remotePayload,
    required String localMutationId,
  }) async {
    final existing =
        await (db.select(db.syncConflicts)..where(
              (c) =>
                  c.entityType.equals(entityType) &
                  c.entityId.equals(entityId) &
                  c.status.equals('OPEN'),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    await db
        .into(db.syncConflicts)
        .insertOnConflictUpdate(
          SyncConflictsCompanion.insert(
            id: existing?.id ?? const Uuid().v4(),
            ledgerId: ledgerId,
            entityType: entityType,
            entityId: entityId,
            localPayload: localPayload,
            remotePayload: remotePayload,
            baseRevision: baseRevision ?? 0,
            remoteRevision: remoteRevision ?? 0,
            localMutationId: localMutationId,
            createdAt: d.Value(existing?.createdAt ?? now),
          ),
        );
  }

  /// 冲突解决——保留本地：
  /// 清除该实体旧 pending 链，以最新 remote revision 为 base 创建 resolution mutation
  /// （payload = 本地实体最新值），随后正常推送走 CAS——不存在绕过 revision 的 force overwrite。
  Future<void> resolveConflictKeepLocal(String conflictId) async {
    final conflict = await (db.select(
      db.syncConflicts,
    )..where((c) => c.id.equals(conflictId))).getSingleOrNull();
    if (conflict == null) throw StateError('冲突不存在: $conflictId');
    if (conflict.entityType != 'transaction') {
      throw StateError('暂不支持该实体类型的冲突解决: ${conflict.entityType}');
    }
    final accountId = _currentAccountIdForCloudOperation('保留本地冲突');
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      // 旧 pending 链作废（resolution mutation 取代）
      await (db.delete(db.syncChanges)..where(
            (c) =>
                c.entityType.equals(conflict.entityType) &
                c.entityId.equals(conflict.entityId) &
                c.pushedAt.isNull(),
          ))
          .go();
      // 以当前本地实体最新值构造 resolution payload
      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(conflict.entityId))).getSingleOrNull();
      if (tx == null) throw StateError('本地实体不存在: ${conflict.entityId}');
      final payload = await _localTxPayload(tx);
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: conflict.entityType,
              entityId: conflict.entityId,
              ledgerId: d.Value(conflict.ledgerId),
              action: 'upsert',
              payload: payload,
              updatedAt: now,
              mutationId: const Uuid().v4(),
              accountId: d.Value(accountId),
              // base = 冲突时的最新 remote revision：下次 push 按 CAS 重放本地值
              baseRevision: d.Value(conflict.remoteRevision),
            ),
          );
      await (db.update(
        db.syncConflicts,
      )..where((c) => c.id.equals(conflictId))).write(
        SyncConflictsCompanion(
          status: d.Value('RESOLVED_LOCAL'),
          resolvedAt: d.Value(now),
        ),
      );
    });
  }

  /// 冲突解决——采用云端：本地实体 ← 服务端当前 payload（云端已删除则本地删除），
  /// server_revision 同步更新，清除该实体 pending；随后继续正常同步。
  Future<void> resolveConflictAdoptRemote(String conflictId) async {
    final conflict = await (db.select(
      db.syncConflicts,
    )..where((c) => c.id.equals(conflictId))).getSingleOrNull();
    if (conflict == null) throw StateError('冲突不存在: $conflictId');
    final remote = jsonDecode(conflict.remotePayload) as Map<String, dynamic>;
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      // 先清 pending：用户决策采用云端，_applyTransaction 不做冲突检测
      await (db.delete(db.syncChanges)..where(
            (c) =>
                c.entityType.equals(conflict.entityType) &
                c.entityId.equals(conflict.entityId) &
                c.pushedAt.isNull(),
          ))
          .go();
      if (remote['deleted'] == true) {
        // 云端已删除：本地同步删除（tombstone），不复活
        await _applyTransaction(conflict.entityId, 'delete', {
          'revision': conflict.remoteRevision,
        });
      } else {
        await _applyTransaction(conflict.entityId, 'upsert', remote);
      }
      await (db.update(
        db.syncConflicts,
      )..where((c) => c.id.equals(conflictId))).write(
        SyncConflictsCompanion(
          status: d.Value('RESOLVED_REMOTE'),
          resolvedAt: d.Value(now),
        ),
      );
    });
  }

  /// STALE_BINDING 处理——放弃本地修改：清该账本全部 pending，按服务端当前
  /// 时间线全量重建（sync_id 更新为服务端当前值，binding 恢复 bound）。
  Future<void> abandonLocalChanges({required String ledgerId}) async {
    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals(ledgerId))).getSingleOrNull();
    final state = ledger == null
        ? LedgerSyncState.invalid
        : ledgerSyncStateOf(
            storageMode: ledger.storageMode,
            syncId: ledger.syncId,
            bindingStatus: ledger.bindingStatus,
          );
    if (state != LedgerSyncState.staleBinding) {
      logger.warning('SyncService', '拒绝放弃非 STALE_BINDING 账本的本地修改: $ledgerId');
      throw StateError('当前账本不处于可重绑状态');
    }
    // 先在不改动本地分支的前提下获取新时间线，避免网络失败时提前丢失
    // pending 和冲突。不带 sync_id 表示用户已显式选择重绑。
    final resp = await _api.getSyncFull(ledgerId: ledgerId);
    await db.transaction(() async {
      // 用户已选择放弃旧分支：在同一事务内清除旧队列与冲突，
      // 使 full 快照能成为新时间线的唯一权威集合。
      await (db.delete(
        db.syncChanges,
      )..where((change) => change.ledgerId.equals(ledgerId))).go();
      await (db.delete(
        db.syncConflicts,
      )..where((conflict) => conflict.ledgerId.equals(ledgerId))).go();
      await _applyFullSnapshot(ledgerId, resp.data!);
      await (db.update(
        db.ledgers,
      )..where((row) => row.id.equals(ledgerId))).write(
        LedgersCompanion(
          syncId: d.Value(resp.data!.ledger.syncId),
          bindingStatus: d.Value(null),
        ),
      );
    });
  }

  /// 构造本地实体最新值的交易 payload（member 直写契约，冲突解决专用）。
  Future<String> _localTxPayload(dynamic tx) async {
    final splits = await (db.select(
      db.transactionSplits,
    )..where((s) => s.transactionId.equals(tx.id as String))).get();
    return jsonEncode({
      'tx_type': tx.txType,
      'amount': tx.amount,
      'happened_at': (tx.happenedAt as DateTime).toUtc().toIso8601String(),
      'note': tx.note,
      'category_id': tx.categoryId,
      'exclude_from_stats': tx.excludeFromStats,
      'currency_code': tx.currencyCode,
      'native_amount': tx.nativeAmount,
      'recurring_id': tx.recurringId,
      'payer_member_id': tx.payerMemberId,
      'aa_mode': tx.aaMode?.toString(),
      'splits': [
        for (final s in splits) {'member_id': s.memberId, 'amount': s.amount},
      ],
      'last_edited_at': (tx.lastEditedAt as DateTime?)
          ?.toUtc()
          .toIso8601String(),
    });
  }

  /// 增量拉取并应用（游标全局，与账本无关）；返回处理条数。
  Future<int> pull() async {
    var cursor = await _serverCursor();
    var applied = 0;
    final fullLedgerIds = <String>{};
    try {
      while (true) {
        final resp = await _api.getSyncPull(since: cursor);
        final data = resp.data!;
        final blockedLedgers = await _blockedLedgerIds(
          data.changes.map((change) => change.ledgerId),
        );
        for (final change in data.changes) {
          if (change.ledgerId case final ledgerId?
              when blockedLedgers.contains(ledgerId)) {
            continue;
          }
          if (change.entityType.name == 'ledger' &&
              change.action.name == 'upsert' &&
              change.payload['requires_full']?.value == true) {
            fullLedgerIds.add(change.entityId);
          }
          await _applyChange(change);
          applied++;
        }
        cursor = data.serverCursor;
        if (!data.hasMore) break;
      }
      for (final ledgerId in fullLedgerIds) {
        final ledger = await (db.select(
          db.ledgers,
        )..where((row) => row.id.equals(ledgerId))).getSingleOrNull();
        // 同一批事件可能已包含本人 LEFT/REMOVED；此时服务端权限已经撤销，
        // 本地只需保留隐藏状态，无需再请求注定失败的历史快照。
        if (ledger == null || ledger.deletedAt != null) continue;
        try {
          await full(ledgerId: ledgerId, advanceCursor: false);
        } catch (error, stackTrace) {
          logger.error(
            'SyncService',
            '受邀账本历史补全失败: $ledgerId',
            error,
            stackTrace,
          );
          rethrow;
        }
      }
      await _saveServerCursor(cursor);
      logger.info('SyncService', 'pull 完成 $applied 条, cursor=$cursor');
      return applied;
    } on DioException catch (e) {
      // 服务端清理历史后游标过期(410):全部云端账本走全量快照收敛,
      // full 会以服务端返回的最新游标覆盖本地游标,后续增量继续可用。
      if (e.response?.statusCode == 410) {
        logger.warning('SyncService', '游标已过期(410),执行全量 resync');
        final cloudLedgers = await (db.select(
          db.ledgers,
        )..where((t) => t.storageMode.equals('cloud'))).get();
        for (final ledger in cloudLedgers) {
          if (!ledgerSyncStateOf(
            storageMode: ledger.storageMode,
            syncId: ledger.syncId,
            bindingStatus: ledger.bindingStatus,
          ).canSync) {
            continue;
          }
          await full(ledgerId: ledger.id);
        }
        return 0;
      }
      rethrow;
    }
  }

  /// 查询本页涉及的不可同步账本，作为 push/pull 共用状态门禁。
  Future<Set<String>> _blockedLedgerIds(Iterable<String?> candidateIds) async {
    final ids = candidateIds.whereType<String>().toSet();
    if (ids.isEmpty) return const {};
    final ledgers = await (db.select(
      db.ledgers,
    )..where((ledger) => ledger.id.isIn(ids))).get();
    return {
      for (final ledger in ledgers)
        if (!ledgerSyncStateOf(
          storageMode: ledger.storageMode,
          syncId: ledger.syncId,
          bindingStatus: ledger.bindingStatus,
        ).canSync)
          ledger.id,
    };
  }

  /// 整本快照落库（覆盖式收敛）。
  ///
  /// [advanceCursor] 为 false 时只补齐指定账本，保留 pull 已确认的全局游标。
  Future<void> full({
    required String ledgerId,
    bool advanceCursor = true,
  }) async {
    // 本地已有同步身份则携带：服务端校验不一致返回 412 SYNC_ID_MISMATCH，
    // 禁止静默覆盖另一条时间线（本地分支保留，由用户决策，见 STALE_BINDING）
    final existing = await (db.select(
      db.ledgers,
    )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
    if (existing != null &&
        !ledgerSyncStateOf(
          storageMode: existing.storageMode,
          syncId: existing.syncId,
          bindingStatus: existing.bindingStatus,
        ).canSync) {
      logger.warning('SyncService', '拒绝对不可同步状态执行 full: $ledgerId');
      throw StateError('当前账本状态不允许全量同步');
    }
    try {
      final resp = await _api.getSyncFull(
        ledgerId: ledgerId,
        syncId: existing?.syncId,
      );
      await _applyFullSnapshot(
        ledgerId,
        resp.data!,
        advanceCursor: advanceCursor,
      );
    } on DioException catch (e) {
      // SYNC_ID_MISMATCH → STALE_BINDING（持久标记，同步暂停等待用户决策），
      // 绝不静默覆盖另一条时间线
      if (e.response?.statusCode == 412) {
        // 绝不默认丢弃本地数据——先把本地状态保护为 Local Safety Fork
        //（DR_PROTECT），再标记 STALE_BINDING 等待用户显式决策（手动 abandon）。
        await _protectLocalStateAsFork(ledgerId);
        await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId)))
            .write(LedgersCompanion(bindingStatus: d.Value('stale')));
      }
      rethrow;
    }
  }

  /// 本地状态保护：仅当该账本存在未推送修改或 OPEN 冲突（有数据
  /// 可丢）时，把当前本地数据复制为 DR_PROTECT 保护副本；无修改则无需保护。
  /// 每次 412 都保护（不幂等跳过）——重绑后又产生的新修改同样得到保护。
  Future<void> _protectLocalStateAsFork(String ledgerId) async {
    final repository = repo;
    if (repository == null) return;
    try {
      // 只统计业务实体变更（transaction/category 等）：账本本体变更在时间线
      // 更换后以服务端为准，不构成"本地数据可丢"；离线业务修改才是保护对象
      final pending =
          await (db.select(db.syncChanges)..where(
                (c) =>
                    c.ledgerId.equals(ledgerId) &
                    c.pushedAt.isNull() &
                    c.entityType.isNotValue('ledger'),
              ))
              .get();
      final openConflicts =
          await (db.select(db.syncConflicts)..where(
                (c) => c.ledgerId.equals(ledgerId) & c.status.equals('OPEN'),
              ))
              .get();
      if (pending.isEmpty && openConflicts.isEmpty) return;
      final localSelfId =
          await (localSelfIdLoader?.call() ?? Future.value(deviceId));
      // 每次 412 都保护（不幂等跳过）：重绑后又产生的新修改同样需要保护副本
      await repository.protectCloudLedgerToLocalFork(
        sourceLedgerId: ledgerId,
        targetLedgerId: const Uuid().v4(),
        localSelfId: localSelfId,
        currentAccountId: currentAccountIdGetter?.call(),
      );
      logger.info('SyncService', '已保护本地状态为 DR_PROTECT 副本: $ledgerId');
    } catch (e, st) {
      // 保护失败不阻断 stale 标记：同步仍暂停等待用户决策，数据仍在本地原行
      logger.error('SyncService', '本地状态保护失败', e, st);
    }
  }

  /// full 响应落库（覆盖式收敛，full 与 STALE_BINDING 恢复路径复用）。
  Future<void> _applyFullSnapshot(
    String ledgerId,
    GetSyncFull200Response data, {
    bool advanceCursor = true,
  }) async {
    final accountId = _currentAccountIdForCloudOperation('应用云账本全量快照');
    await db.transaction(() async {
      final protectedIds = await _snapshotProtectedEntityIds();

      // full 以云端账本元数据为权威；待推送或冲突中的本地分支仍保留。
      final localLedger = await (db.select(
        db.ledgers,
      )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
      if (localLedger == null) {
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: data.ledger.id,
                name: data.ledger.name,
                currency: d.Value(data.ledger.currency),
                monthStartDay: d.Value(data.ledger.monthStartDay),
                aaEnabled: d.Value(data.ledger.aaEnabled),
                storageMode: const d.Value('cloud'),
                scopeAccountId: d.Value(accountId),
                // 首次绑定：full 快照的 sync_id 即该账本的同步时间线身份
                syncId: d.Value(data.ledger.syncId),
                updatedAt: data.ledger.updatedAt,
                deletedAt: const d.Value(null),
              ),
            );
      } else {
        final preserveLocalLedger =
            protectedIds['ledger']?.contains(ledgerId) == true;
        // 保留 role、selfMemberId、bindingStatus 等本地绑定字段；
        // 登录态 full 同时修正账号域，供账号切换时精确清理。
        await (db.update(
          db.ledgers,
        )..where((t) => t.id.equals(ledgerId))).write(
          LedgersCompanion(
            name: preserveLocalLedger
                ? const d.Value.absent()
                : d.Value(data.ledger.name),
            currency: preserveLocalLedger
                ? const d.Value.absent()
                : d.Value(data.ledger.currency),
            monthStartDay: preserveLocalLedger
                ? const d.Value.absent()
                : d.Value(data.ledger.monthStartDay),
            aaEnabled: preserveLocalLedger
                ? const d.Value.absent()
                : d.Value(data.ledger.aaEnabled),
            syncId: localLedger.syncId == null
                ? d.Value(data.ledger.syncId)
                : const d.Value.absent(),
            scopeAccountId: currentAccountIdGetter == null
                ? const d.Value.absent()
                : d.Value(accountId),
            // 未合并的本地删除/冲突分支必须保留；没有保护分支时，服务端
            // full 快照中存在该账本才代表当前时间线上的活动实体。
            updatedAt: preserveLocalLedger
                ? const d.Value.absent()
                : d.Value(data.ledger.updatedAt),
            deletedAt: preserveLocalLedger
                ? const d.Value.absent()
                : const d.Value(null),
          ),
        );
      }
      for (final cat in data.categories) {
        if (protectedIds['category']?.contains(cat.id) == true) continue;
        await _upsertCategory(cat, accountId: accountId);
      }
      for (final rt in data.recurringTransactions) {
        if (protectedIds['recurring_transaction']?.contains(rt.id) == true) {
          continue;
        }
        await _upsertRecurring(rt);
      }
      // 交易可能引用周期模板；先落模板再落交易，保证开启 SQLite 外键时
      // 新设备也能从空库应用完整快照。
      for (final tx in data.transactions) {
        if (protectedIds['transaction']?.contains(tx.id) == true) continue;
        await _upsertTransaction(tx);
      }
      for (final m in data.members) {
        if (protectedIds['member']?.contains(m.id) == true) continue;
        await _upsertMember(m);
      }
      for (final ov in data.exchangeRateOverrides) {
        if (protectedIds['exchange_rate_override']?.contains(ov.id) == true) {
          continue;
        }
        await _upsertOverride(ov, accountId: accountId);
      }
      await _tombstoneMissingLedgerEntities(
        ledgerId: ledgerId,
        transactionIds: data.transactions.map((tx) => tx.id).toSet(),
        recurringIds: data.recurringTransactions.map((rt) => rt.id).toSet(),
        memberIds: data.members.map((m) => m.id).toSet(),
        protectedIds: protectedIds,
      );
      if (advanceCursor) await _saveServerCursor(data.serverCursor);
    });
    logger.info('SyncService', 'full 落库完成, cursor=${data.serverCursor}');
  }

  /// 返回 full 覆盖时必须保留的本地实体，避免快照覆盖待推送修改或冲突分支。
  Future<Map<String, Set<String>>> _snapshotProtectedEntityIds() async {
    final protected = <String, Set<String>>{};
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    for (final change in pending) {
      protected
          .putIfAbsent(change.entityType, () => <String>{})
          .add(change.entityId);
    }
    final conflicts = await (db.select(
      db.syncConflicts,
    )..where((c) => c.status.equals('OPEN'))).get();
    for (final conflict in conflicts) {
      protected
          .putIfAbsent(conflict.entityType, () => <String>{})
          .add(conflict.entityId);
    }
    return protected;
  }

  /// 让 full 成为账本云副本的权威集合，同时保留本地待合并分支。
  Future<void> _tombstoneMissingLedgerEntities({
    required String ledgerId,
    required Set<String> transactionIds,
    required Set<String> recurringIds,
    required Set<String> memberIds,
    required Map<String, Set<String>> protectedIds,
  }) async {
    final deletedAt = DateTime.now().toUtc();
    final keptTransactions = {
      ...transactionIds,
      ...?protectedIds['transaction'],
    };
    final transactionUpdate = db.update(db.transactions)
      ..where((t) {
        final active = t.ledgerId.equals(ledgerId) & t.deletedAt.isNull();
        return keptTransactions.isEmpty
            ? active
            : active & t.id.isNotIn(keptTransactions);
      });
    await transactionUpdate.write(
      TransactionsCompanion(deletedAt: d.Value(deletedAt)),
    );

    final keptRecurring = {
      ...recurringIds,
      ...?protectedIds['recurring_transaction'],
    };
    final recurringUpdate = db.update(db.recurringTransactions)
      ..where((t) {
        final active = t.ledgerId.equals(ledgerId) & t.deletedAt.isNull();
        return keptRecurring.isEmpty
            ? active
            : active & t.id.isNotIn(keptRecurring);
      });
    await recurringUpdate.write(
      RecurringTransactionsCompanion(deletedAt: d.Value(deletedAt)),
    );

    // 成员权威集合：快照下发的 PLACEHOLDER 行缺失时 tombstone（REGISTERED/LOCAL
    // 成员有本地生命周期语义，不由云快照推删）。
    final keptMembers = {...memberIds, ...?protectedIds['member']};
    final memberUpdate = db.update(db.ledgerMembers)
      ..where((m) {
        final active =
            m.ledgerId.equals(ledgerId) &
            m.memberType.equals('PLACEHOLDER') &
            m.deletedAt.isNull();
        return keptMembers.isEmpty
            ? active
            : active & m.id.isNotIn(keptMembers);
      });
    await memberUpdate.write(
      LedgerMembersCompanion(deletedAt: d.Value(deletedAt)),
    );
  }

  // ---------------------------------------------------------------
  // push 变更构造（6 实体 × upsert/delete 变体）
  // ---------------------------------------------------------------

  PostSyncPushRequestChangesInner _toChangeInner(
    SyncChange ch,
    Map<String, String> syncIdByLedger,
  ) {
    // 账本级变更携带同步身份；user 级实体（category/rate）无账本边界，不带
    final syncId = ch.ledgerId == null ? null : syncIdByLedger[ch.ledgerId];
    // base_revision 由队列行携带（ChangeRecorder 按同实体 FIFO 链计算）
    switch (ch.entityType) {
      case 'ledger':
        return _ledgerChange(ch, syncId);
      case 'transaction':
        return _transactionChange(ch, syncId);
      case 'category':
        return _categoryChange(ch);
      case 'recurring_transaction':
        return _recurringChange(ch, syncId);
      case 'exchange_rate_override':
        return _overrideChange(ch);
      case 'member':
        return _memberChange(ch, syncId);
      default:
        throw StateError('未知 entityType: ');
    }
  }

  PostSyncPushRequestChangesInner _ledgerChange(SyncChange ch, String? syncId) {
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf>(
            value: PostSyncPushRequestChangesInnerAnyOf(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOfAnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
                              .ledger
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId ?? ch.entityId
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf>(
          value: PostSyncPushRequestChangesInnerAnyOf(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOfAnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
                            .ledger
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId ?? ch.entityId
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
                            >(
                              ch.payload,
                              PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  PostSyncPushRequestChangesInner _transactionChange(
    SyncChange ch,
    String? syncId,
  ) {
    // 推送出口对齐服务端契约：amount/native_amount 必须为规范化 decimal
    //（历史验收填充数据可能带尾零，如 "857.00"）。
    final payload = _normalizeTransactionAmounts(ch.payload);
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf1>(
            value: PostSyncPushRequestChangesInnerAnyOf1(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf1AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf1AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf1AnyOf1EntityTypeEnum
                              .transaction
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf1AnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf1>(
          value: PostSyncPushRequestChangesInnerAnyOf1(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf1AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf1AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf1AnyOfEntityTypeEnum
                            .transaction
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf1AnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
                            >(
                              payload,
                              PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 把交易 payload 的金额字段规范化为契约格式（尾零剥离，如 "857.00" → "857"）。
  ///
  /// 服务端金额契约要求规范化 decimal；验收填充等历史数据可能带尾零，
  /// 推送出口统一归一，避免整批因单条金额格式被 400 拒绝。
  String _normalizeTransactionAmounts(String rawPayload) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(rawPayload) as Map<String, dynamic>;
    } catch (_) {
      return rawPayload;
    }
    for (final key in const ['amount', 'native_amount']) {
      final value = data[key];
      if (value is String) {
        final parsed = Decimal.tryParse(value);
        if (parsed != null) data[key] = normalizeDecimal(parsed);
      }
    }
    // 指定分摊行金额同口径规范化（历史填充数据同样可能带尾零）。
    final splits = data['splits'];
    if (splits is List) {
      for (final split in splits) {
        if (split is Map<String, dynamic>) {
          final amount = split['amount'];
          if (amount is String) {
            final parsed = Decimal.tryParse(amount);
            if (parsed != null) split['amount'] = normalizeDecimal(parsed);
          }
        }
      }
    }
    return jsonEncode(data);
  }

  PostSyncPushRequestChangesInner _categoryChange(SyncChange ch) {
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
            value: PostSyncPushRequestChangesInnerAnyOf2(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf2AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf2AnyOf1EntityTypeEnum
                              .category
                      ..entityId = ch.entityId
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf2AnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
          value: PostSyncPushRequestChangesInnerAnyOf2(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf2AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
                            .category
                    ..entityId = ch.entityId
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
                            >(
                              ch.payload,
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  PostSyncPushRequestChangesInner _recurringChange(
    SyncChange ch,
    String? syncId,
  ) {
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf3>(
            value: PostSyncPushRequestChangesInnerAnyOf3(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf3AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf3AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf3AnyOf1EntityTypeEnum
                              .recurringTransaction
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf3AnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf3>(
          value: PostSyncPushRequestChangesInnerAnyOf3(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf3AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf3AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf3AnyOfEntityTypeEnum
                            .recurringTransaction
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf3AnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
                            >(
                              ch.payload,
                              PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  PostSyncPushRequestChangesInner _overrideChange(SyncChange ch) {
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4>(
            value: PostSyncPushRequestChangesInnerAnyOf4(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf4AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf4AnyOf1EntityTypeEnum
                              .exchangeRateOverride
                      ..entityId = ch.entityId
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf4AnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4>(
          value: PostSyncPushRequestChangesInnerAnyOf4(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf4AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf4AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf4AnyOfEntityTypeEnum
                            .exchangeRateOverride
                    ..entityId = ch.entityId
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf4AnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
                            >(
                              ch.payload,
                              PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  PostSyncPushRequestChangesInner _memberChange(SyncChange ch, String? syncId) {
    if (ch.action == 'delete') {
      return PostSyncPushRequestChangesInner(
        (b) => b
          ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5>(
            value: PostSyncPushRequestChangesInnerAnyOf5(
              (b) => b
                ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5AnyOf1>(
                  value: PostSyncPushRequestChangesInnerAnyOf5AnyOf1(
                    (b) => b
                      ..mutationId = ch.mutationId
                      ..entityType =
                          PostSyncPushRequestChangesInnerAnyOf5AnyOf1EntityTypeEnum
                              .member
                      ..entityId = ch.entityId
                      ..ledgerId = ch.ledgerId!
                      ..syncId = syncId
                      ..baseRevision = ch.baseRevision
                      ..action =
                          PostSyncPushRequestChangesInnerAnyOf5AnyOf1ActionEnum
                              .delete
                      ..updatedAt = ch.updatedAt.toUtc()
                      ..payload = JsonObject(jsonDecode(ch.payload)),
                  ),
                ),
            ),
          ),
      );
    }
    return PostSyncPushRequestChangesInner(
      (b) => b
        ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5>(
          value: PostSyncPushRequestChangesInnerAnyOf5(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf5AnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf5AnyOf(
                  (b) => b
                    ..mutationId = ch.mutationId
                    ..entityType =
                        PostSyncPushRequestChangesInnerAnyOf5AnyOfEntityTypeEnum
                            .member
                    ..entityId = ch.entityId
                    ..ledgerId = ch.ledgerId!
                    ..syncId = syncId
                    ..baseRevision = ch.baseRevision
                    ..action =
                        PostSyncPushRequestChangesInnerAnyOf5AnyOfActionEnum
                            .upsert
                    ..updatedAt = ch.updatedAt.toUtc()
                    ..payload =
                        _deser<
                              PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
                            >(
                              ch.payload,
                              PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
                                  .serializer,
                            )
                            .toBuilder(),
                ),
              ),
          ),
        ),
    );
  }

  /// 把本地 payload JSON 反序列化为生成模型的 payload 对象。
  T _deser<T>(String json, Serializer<T> serializer) {
    return client.serializers.deserialize(
          jsonDecode(json),
          specifiedType: FullType(serializer.types.first),
        )
        as T;
  }

  List<List<SyncChange>> _chunks(List<SyncChange> items, int size) {
    final out = <List<SyncChange>>[];
    for (var i = 0; i < items.length; i += size) {
      out.add(
        items.sublist(i, i + size > items.length ? items.length : i + size),
      );
    }
    return out;
  }

  // ---------------------------------------------------------------
  // 拉取应用（pull change → 本地写）
  // ---------------------------------------------------------------

  Future<void> _applyChange(GetSyncPull200ResponseChangesInner change) async {
    // 生成客户端的 Dart 枚举名使用 camelCase，而同步队列与分派契约使用
    // 服务端 wire snake_case；入口统一规范化，避免事件被计数却未实际落库。
    final type = switch (change.entityType.name) {
      'recurringTransaction' => 'recurring_transaction',
      'exchangeRateOverride' => 'exchange_rate_override',
      final name => name,
    };
    final action = change.action.name;
    final entityId = change.entityId;
    // JsonObject 载荷转回普通 Map 供各实体落库方法使用。
    final payload = <String, dynamic>{
      for (final e in change.payload.entries) e.key: e.value?.value,
    };

    // LWW 冲突守卫：无未推送本地修改时才按 (updated_at, device_id) 裁决。
    // 存在 pending 的实体必须交给实体级修订/冲突决策——交易按 revision 链
    // 超前即建 OPEN 冲突、不超前则跳过；其余实体按各自应用规则收敛。否则
    // 「应提示冲突」会被误判为「静默跳过」，离线分支永远无法让用户决策。
    final hasPending = await _hasPendingChange(type, entityId);
    final localUpdatedAt = await _localUpdatedAt(type, entityId);
    final shouldApply =
        hasPending ||
        lwwShouldApply(
          localUpdatedAt: localUpdatedAt,
          localDeviceId: deviceId,
          remoteUpdatedAt: change.updatedAt,
          remoteDeviceId: change.deviceId,
        );
    if (!shouldApply) return;

    switch (type) {
      case 'ledger':
        await _applyLedger(entityId, action, payload, change.updatedAt);
      case 'transaction':
        await _applyTransaction(entityId, action, payload);
      case 'category':
        await _applyCategory(entityId, action, payload);
      case 'exchange_rate_override':
        await _applyOverride(entityId, action, payload);
      case 'member':
        await _applyMember(
          entityId,
          action,
          payload,
          ledgerId: change.ledgerId ?? '',
          eventUpdatedAt: change.updatedAt,
        );
      case 'recurring_transaction':
        await _applyRecurring(entityId, action, payload);
    }
  }

  /// 该实体是否存在未推送的本地变更（pending 链非空）。
  Future<bool> _hasPendingChange(String type, String entityId) async {
    final row =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  c.entityType.equals(type) &
                  c.entityId.equals(entityId) &
                  c.pushedAt.isNull(),
            ))
            .getSingleOrNull();
    return row != null;
  }

  /// 读本地实体行的 updated_at（无行返回 null）。
  Future<DateTime?> _localUpdatedAt(String type, String entityId) {
    switch (type) {
      case 'ledger':
        return (db.select(db.ledgers)..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'transaction':
        return (db.select(db.transactions)..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'category':
        return (db.select(db.categories)..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'exchange_rate_override':
        return (db.select(db.exchangeRateOverrides)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'member':
        // 成员实体以 LedgerMembers 行落库（PLACEHOLDER 同 id）。
        return (db.select(db.ledgerMembers)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'recurring_transaction':
        return (db.select(db.recurringTransactions)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      default:
        return Future.value(null);
    }
  }

  Future<void> _applyLedger(
    String id,
    String action,
    Map<String, dynamic> p,
    DateTime eventUpdatedAt,
  ) async {
    if (action == 'delete') {
      // tombstone 软删：契约删除走 deleted_at，不靠缺失推断（避免离线副本误复活）。
      await (db.update(db.ledgers)..where((t) => t.id.equals(id))).write(
        LedgersCompanion(deletedAt: d.Value(_deleteTime(p))),
      );
      return;
    }
    final accountId = _currentAccountIdForCloudOperation('应用云账本增量');
    final existing = await (db.select(
      db.ledgers,
    )..where((ledger) => ledger.id.equals(id))).getSingleOrNull();
    await db
        .into(db.ledgers)
        .insertOnConflictUpdate(
          LedgersCompanion.insert(
            id: id,
            name: p['name']?.toString() ?? '',
            currency: d.Value(p['currency']?.toString() ?? 'CNY'),
            monthStartDay: d.Value(
              (p['month_start_day'] as num?)?.toInt() ?? 1,
            ),
            aaEnabled: d.Value(p['aa_enabled'] == true),
            // 账本事件不携带接收者角色；已有账本保留本机角色，新账本由随后
            // 到达的本人 member 权威快照写入角色。
            role: d.Value(existing?.role ?? p['role']?.toString() ?? 'owner'),
            memberCount: d.Value((p['member_count'] as num?)?.toInt() ?? 1),
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountId),
            syncId: p.containsKey('sync_id')
                ? d.Value(p['sync_id']?.toString())
                : d.Value(existing?.syncId),
            updatedAt: eventUpdatedAt.toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _applyTransaction(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    final remoteRevision = (p['revision'] as num?)?.toInt();
    // 存在 pending 本地修改的实体遇到更高 remote revision，
    // 不得直接覆盖本地（本地编辑会丢），必须进入 conflict 供 UI 决策。
    final pendingChain =
        await (db.select(db.syncChanges)
              ..where(
                (c) =>
                    c.entityType.equals('transaction') &
                    c.entityId.equals(id) &
                    c.pushedAt.isNull(),
              )
              ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
            .get();
    if (pendingChain.isNotEmpty) {
      final chainHeadBase = pendingChain.first.baseRevision;
      // create 语义（base 为 null，期望实体不存在）：远端已存在（revision>0）即冲突
      if (chainHeadBase == null) {
        if (remoteRevision != null && remoteRevision > 0) {
          await _upsertPullConflict(
            id,
            pendingChain,
            p,
            remoteRevision,
            action,
          );
          return;
        }
        // 无 revision 信息（旧事件）：保守跳过，保持本地 create 基线
        return;
      }
      if (remoteRevision != null && remoteRevision > chainHeadBase) {
        await _upsertPullConflict(id, pendingChain, p, remoteRevision, action);
        return;
      }
      // remoteRevision <= 本地基线：该事件已包含在本地修改的基线内，跳过
      if (remoteRevision == null || remoteRevision <= chainHeadBase) {
        return;
      }
    }
    // 无 pending：按 revision 单调应用，旧事件跳过
    final local = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (remoteRevision != null &&
        local?.serverRevision != null &&
        remoteRevision <= local!.serverRevision!) {
      return;
    }
    if (action == 'delete') {
      // tombstone 软删：deleted_at 用事件时间（payload 优先，回退事件 updated_at）。
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          deletedAt: d.Value(_deleteTime(p)),
          serverRevision: d.Value(remoteRevision),
        ),
      );
      return;
    }
    final ledgerId = p['ledger_id']?.toString() ?? '';
    await db.transaction(() async {
      // member 单轨直读（服务端事件 payload 只输出 member_id）
      final createdByMemberId = p['created_by_member_id']?.toString();
      final lastEditedByMemberId = p['last_edited_by_member_id']?.toString();
      final payerMemberId = p['payer_member_id']?.toString();
      await db
          .into(db.transactions)
          .insertOnConflictUpdate(
            TransactionsCompanion.insert(
              id: id,
              ledgerId: ledgerId,
              txType: p['tx_type']?.toString() ?? 'expense',
              amount: p['amount']?.toString() ?? '0',
              happenedAt:
                  DateTime.tryParse(
                    p['happened_at']?.toString() ?? '',
                  )?.toUtc() ??
                  DateTime.now().toUtc(),
              note: d.Value(p['note']?.toString()),
              categoryId: d.Value(p['category_id']?.toString()),
              excludeFromStats: d.Value(p['exclude_from_stats'] == true),
              currencyCode: p['currency_code']?.toString() ?? 'CNY',
              nativeAmount: p['native_amount']?.toString() ?? '0',
              createdByMemberId: d.Value(createdByMemberId),
              lastEditedByMemberId: d.Value(lastEditedByMemberId),
              payerMemberId: d.Value(payerMemberId),
              aaMode: d.Value((p['aa_mode'] as num?)?.toInt()),
              // 本地编辑计数列：以服务端权威 revision 对齐（契约已无 version 字段）
              version: d.Value(remoteRevision ?? 1),
              serverRevision: d.Value(remoteRevision),
              lastEditedAt: d.Value(
                DateTime.tryParse(
                  p['last_edited_at']?.toString() ?? '',
                )?.toUtc(),
              ),
              createdAt:
                  DateTime.tryParse(
                    p['created_at']?.toString() ?? '',
                  )?.toUtc() ??
                  DateTime.now().toUtc(),
              updatedAt:
                  DateTime.tryParse(
                    p['updated_at']?.toString() ?? '',
                  )?.toUtc() ??
                  DateTime.now().toUtc(),
              // 远端 upsert 是复活语义，不能保留同主键旧行的 tombstone。
              deletedAt: const d.Value(null),
            ),
          );
      // 指定分摊整批替换:payload.splits 是契约形状的数组,先删后插保证与远端一致。
      await (db.delete(
        db.transactionSplits,
      )..where((s) => s.transactionId.equals(id))).go();
      final rawSplits = p['splits'];
      if (rawSplits is List && rawSplits.isNotEmpty) {
        // 先逐条完成成员映射（含按需创建），再整批插入分摊行。
        final splitRows = <TransactionSplitsCompanion>[];
        for (final s in rawSplits) {
          if (s is! Map<String, dynamic>) continue;
          // 参与人单轨：member_id 直写（占位成员与注册成员同形态）
          final memberId = s['member_id']?.toString();
          if (memberId == null || memberId.isEmpty) continue;
          splitRows.add(
            TransactionSplitsCompanion.insert(
              transactionId: id,
              memberId: memberId,
              amount: s['amount']?.toString() ?? '',
            ),
          );
        }
        if (splitRows.isNotEmpty) {
          await db.batch((b) => b.insertAll(db.transactionSplits, splitRows));
        }
      }
    });
  }

  Future<void> _applyCategory(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    if (action == 'delete') {
      await (db.update(db.categories)..where((t) => t.id.equals(id))).write(
        CategoriesCompanion(deletedAt: d.Value(_deleteTime(p))),
      );
      return;
    }
    final accountId = _currentAccountIdForCloudOperation('应用云分类增量');
    await db
        .into(db.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion.insert(
            id: id,
            name: p['name']?.toString() ?? '',
            kind: p['kind']?.toString() ?? 'expense',
            level: (p['level'] as num?)?.toInt() ?? 1,
            sortOrder: d.Value((p['sort_order'] as num?)?.toInt() ?? 0),
            icon: d.Value(p['icon']?.toString()),
            parentId: d.Value(p['parent_id']?.toString()),
            scopeAccountId: d.Value(accountId),
            updatedAt:
                DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _applyOverride(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    if (action == 'delete') {
      await (db.update(
        db.exchangeRateOverrides,
      )..where((t) => t.id.equals(id))).write(
        ExchangeRateOverridesCompanion(deletedAt: d.Value(_deleteTime(p))),
      );
      return;
    }
    final accountId = _currentAccountIdForCloudOperation('应用云汇率增量');
    await db
        .into(db.exchangeRateOverrides)
        .insertOnConflictUpdate(
          ExchangeRateOverridesCompanion.insert(
            id: id,
            baseCurrency: p['base_currency']?.toString() ?? '',
            quoteCurrency: p['quote_currency']?.toString() ?? '',
            rate: p['rate']?.toString() ?? '0',
            scopeAccountId: d.Value(accountId),
            updatedAt:
                DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _applyMember(
    String id,
    String action,
    Map<String, dynamic> p, {
    required String ledgerId,
    required DateTime eventUpdatedAt,
  }) async {
    // 成员实体以 LedgerMembers 行落库（member id 直用）；REST 生命周期事件的
    // member_type/status 是服务端权威快照，缺省值仅兼容占位成员 push 事件。
    if (action == 'delete') {
      await (db.update(db.ledgerMembers)..where((t) => t.id.equals(id))).write(
        LedgerMembersCompanion(status: d.Value('REMOVED')),
      );
      return;
    }
    final existing = await (db.select(
      db.ledgerMembers,
    )..where((member) => member.id.equals(id))).getSingleOrNull();
    final memberType =
        p['member_type']?.toString() ?? existing?.memberType ?? 'PLACEHOLDER';
    final linkedAccountId = p.containsKey('linked_account_id')
        ? p['linked_account_id']?.toString()
        : existing?.linkedAccountId;
    final role = p['role']?.toString() ?? existing?.role ?? 'editor';
    final status = p['status']?.toString() ?? 'ACTIVE';
    final updatedAt =
        DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
        eventUpdatedAt.toUtc();
    await db
        .into(db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName:
                p['display_name']?.toString() ?? existing?.displayName ?? '',
            memberType: memberType,
            linkedAccountId: d.Value(linkedAccountId),
            role: d.Value(role),
            status: d.Value(status),
            updatedAt: updatedAt,
            // 远端 upsert 表示该成员当前存在，必须清除此前 full 缺失留下的墓碑。
            deletedAt: const d.Value(null),
          ),
        );
    final accountId = _currentAccountIdForCloudOperation('应用云成员增量');
    if (accountId != null && linkedAccountId == accountId) {
      // 本人生命周期就是本设备的账本访问状态：撤权只隐藏云账本并保留离线
      // 数据，重新受邀 ACTIVE 时同一事件链可恢复显示。
      await (db.update(
        db.ledgers,
      )..where((ledger) => ledger.id.equals(ledgerId))).write(
        LedgersCompanion(
          selfMemberId: d.Value(id),
          role: d.Value(role),
          deletedAt: status == 'ACTIVE'
              ? const d.Value(null)
              : d.Value(updatedAt),
        ),
      );
    }
  }

  Future<void> _applyRecurring(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    if (action == 'delete') {
      await (db.update(
        db.recurringTransactions,
      )..where((t) => t.id.equals(id))).write(
        RecurringTransactionsCompanion(deletedAt: d.Value(_deleteTime(p))),
      );
      return;
    }
    await db
        .into(db.recurringTransactions)
        .insertOnConflictUpdate(
          RecurringTransactionsCompanion.insert(
            id: id,
            ledgerId: p['ledger_id']?.toString() ?? '',
            txType: p['tx_type']?.toString() ?? 'expense',
            amount: p['amount']?.toString() ?? '0',
            currencyCode: p['currency_code']?.toString() ?? 'CNY',
            categoryId: d.Value(p['category_id']?.toString()),
            note: d.Value(p['note']?.toString()),
            frequency: p['frequency']?.toString() ?? 'monthly',
            interval: d.Value((p['interval'] as num?)?.toInt() ?? 1),
            dayOfMonth: d.Value((p['day_of_month'] as num?)?.toInt()),
            dayOfWeek: d.Value((p['day_of_week'] as num?)?.toInt()),
            monthOfYear: d.Value((p['month_of_year'] as num?)?.toInt()),
            startDate:
                DateTime.tryParse(p['start_date']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            endDate: d.Value(
              DateTime.tryParse(p['end_date']?.toString() ?? '')?.toUtc(),
            ),
            lastGeneratedDate: d.Value(
              DateTime.tryParse(
                p['last_generated_date']?.toString() ?? '',
              )?.toUtc(),
            ),
            enabled: d.Value(p['enabled'] != false),
            updatedAt:
                DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 写入 full 返回的权威交易与分摊，并对齐服务端 revision。
  Future<void> _upsertTransaction(Transaction tx) async {
    try {
      await db.transaction(() async {
        // 成员引用直接使用 full 快照输出的 member_id。
        final createdByMemberId = tx.createdByMemberId;
        final lastEditedByMemberId = tx.lastEditedByMemberId;
        final payerMemberId = tx.payerMemberId;
        await db
            .into(db.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion.insert(
                id: tx.id,
                ledgerId: tx.ledgerId,
                txType: tx.txType.name,
                amount: tx.amount,
                happenedAt: tx.happenedAt,
                note: d.Value(tx.note),
                categoryId: d.Value(tx.categoryId),
                excludeFromStats: d.Value(tx.excludeFromStats),
                currencyCode: tx.currencyCode,
                nativeAmount: tx.nativeAmount,
                recurringId: d.Value(tx.recurringId),
                createdByMemberId: d.Value(createdByMemberId),
                lastEditedByMemberId: d.Value(lastEditedByMemberId),
                payerMemberId: d.Value(payerMemberId),
                aaMode: d.Value(
                  tx.aaMode?.name == null ? null : int.parse(tx.aaMode!.name),
                ),
                // 本地编辑计数列：全量快照以服务端 revision 对齐
                version: d.Value(tx.revision),
                serverRevision: d.Value(tx.revision),
                lastEditedAt: d.Value(tx.lastEditedAt),
                createdAt: tx.createdAt,
                updatedAt: tx.updatedAt,
                deletedAt: const d.Value(null),
              ),
            );
        // 指定分摊整批替换:客户端模型 tx.splits 即契约 TransactionSplit 列表。
        await (db.delete(
          db.transactionSplits,
        )..where((s) => s.transactionId.equals(tx.id))).go();
        if (tx.splits.isNotEmpty) {
          final splitRows = <TransactionSplitsCompanion>[];
          for (final s in tx.splits) {
            // 参与人单轨：member_id 直读（full 快照已按成员引用输出）
            final memberId = s.memberId;
            if (memberId == null || memberId.isEmpty) continue;
            splitRows.add(
              TransactionSplitsCompanion.insert(
                transactionId: tx.id,
                memberId: memberId,
                amount: s.amount,
              ),
            );
          }
          if (splitRows.isNotEmpty) {
            await db.batch((b) => b.insertAll(db.transactionSplits, splitRows));
          }
        }
      });
    } catch (error, stackTrace) {
      logger.error('SyncService', '全量交易落库失败: ${tx.id}', error, stackTrace);
      rethrow;
    }
  }

  Future<void> _upsertCategory(
    Category cat, {
    required String? accountId,
  }) async {
    await db
        .into(db.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion.insert(
            id: cat.id,
            name: cat.name,
            kind: cat.kind.name,
            // 生成客户端用 n1/n2 作为 Dart enum 名，wire value 才是 1/2。
            level: cat.level == CategoryLevelEnum.n1 ? 1 : 2,
            sortOrder: d.Value(cat.sortOrder),
            icon: d.Value(cat.icon),
            parentId: d.Value(cat.parentId),
            scopeAccountId: d.Value(accountId),
            updatedAt: cat.updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _upsertRecurring(RecurringTransaction rt) async {
    await db
        .into(db.recurringTransactions)
        .insertOnConflictUpdate(
          RecurringTransactionsCompanion.insert(
            id: rt.id,
            ledgerId: rt.ledgerId,
            txType: rt.txType.name,
            amount: rt.amount,
            currencyCode: rt.currencyCode,
            categoryId: d.Value(rt.categoryId),
            note: d.Value(rt.note),
            frequency: rt.frequency.name,
            interval: d.Value(rt.interval),
            dayOfMonth: d.Value(rt.dayOfMonth),
            dayOfWeek: d.Value(rt.dayOfWeek),
            monthOfYear: d.Value(rt.monthOfYear),
            startDate: rt.startDate,
            endDate: d.Value(rt.endDate),
            lastGeneratedDate: d.Value(rt.lastGeneratedDate),
            enabled: d.Value(rt.enabled),
            updatedAt: rt.updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _upsertMember(Member m) async {
    // full 快照成员单轨落库：REGISTERED/PLACEHOLDER 统一 LedgerMembers 行，
    // status（ACTIVE/LEFT/REMOVED）随快照权威更新，行保留以解释历史账务。
    await db
        .into(db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: m.id,
            ledgerId: m.ledgerId,
            displayName: m.displayName,
            memberType: m.memberType.name,
            status: d.Value(m.status.name),
            updatedAt: m.updatedAt,
            // full 快照中存在的成员是当前权威实体，允许同主键成员重新加入。
            deletedAt: const d.Value(null),
          ),
        );
  }

  Future<void> _upsertOverride(
    ExchangeRateOverride ov, {
    required String? accountId,
  }) async {
    await db
        .into(db.exchangeRateOverrides)
        .insertOnConflictUpdate(
          ExchangeRateOverridesCompanion.insert(
            id: ov.id,
            baseCurrency: ov.baseCurrency,
            quoteCurrency: ov.quoteCurrency,
            rate: ov.rate,
            scopeAccountId: d.Value(accountId),
            updatedAt: ov.updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 提取删除事件的 deleted_at：payload 优先，缺失回退事件 updated_at。
  DateTime _deleteTime(Map<String, dynamic> p) {
    return DateTime.tryParse(p['deleted_at']?.toString() ?? '')?.toUtc() ??
        DateTime.now().toUtc();
  }

  /// 读取当前设备已确认的服务端游标。
  Future<String> _serverCursor() async {
    final row = await (db.select(
      db.syncState,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    return row?.serverCursor ?? '0';
  }

  /// 保存当前设备已完成应用的服务端游标。
  Future<void> _saveServerCursor(String cursor) async {
    await db
        .into(db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            deviceId: deviceId,
            serverCursor: d.Value(cursor),
            lastPullAt: d.Value(DateTime.now().toUtc()),
          ),
        );
  }
}
