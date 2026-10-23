import 'dart:convert';
import 'package:built_collection/built_collection.dart';
import 'package:uuid/uuid.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/sync/models/ledger_sync_state.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart'
    show categorySyncPayload;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'sync_runtime.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/services/category_seed_service.dart';

/// 账号记账目录、账本快照、保护副本和记账推送回执处理。
class AccountingSyncHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  AccountingSyncHandler(
    this._runtime,
    this._ports, {
    required this.downloadStore,
    required this.localSelfIdLoader,
    required this.repo,
  });
  final SyncRuntime _runtime;
  final AccountingSyncHandlerPorts _ports;
  final CloudLedgerDownloadStore? downloadStore;
  final Future<String> Function()? localSelfIdLoader;
  final LocalLedgerRepository? repo;

  /// 把账本级待推变更引用的未登记分类补登记为 user 级 upsert 变更。
  ///
  /// 种子默认分类是确定性 UUIDv5，在无云上下文创建时不登记同步变更；
  /// 云账本交易引用它们时必须在交易之前上云。返回是否登记了任何新变更。
  Future<bool> ensureReferencedCategoryRegistrations(
    String accountId,
    List<SyncChange> changes,
  ) async {
    final ledgerIds = changes
        .map((c) => c.ledgerId)
        .whereType<String>()
        .toSet();
    final ledgers =
        await (_runtime.db.select(_runtime.db.ledgers)..where(
              (l) =>
                  l.id.isIn(ledgerIds) &
                  l.scopeAccountId.equals(accountId) &
                  l.storageMode.equals('cloud'),
            ))
            .get();
    final ownerLedgerIds = <String>{};
    for (final ledger in ledgers) {
      var owner = ledger.ownerAccountId;
      if (owner == null) {
        final newOwnedIntent =
            ledger.syncId == null &&
            changes.any(
              (c) =>
                  c.entityType == 'ledger' &&
                  c.entityId == ledger.id &&
                  c.action == 'upsert' &&
                  c.accountId == accountId,
            );
        if (newOwnedIntent) {
          owner = accountId;
        } else {
          final remote =
              (await _runtime.client.getLedgersApi().getLedgersByLedgerId(
                ledgerId: ledger.id,
              )).data!;
          _runtime.requireAccount(accountId);
          owner = remote.ownerId;
          if (owner == null || owner.isEmpty) {
            throw SyncOperationFailure(
              code: 'CLOUD_OWNERSHIP_MISSING',
              message: '云端账本的归属信息不完整，请重新同步账本后再试',
              target: SyncTarget('ledger', ledger.id),
            );
          }
        }
      }
      if (ledger.ownerAccountId != owner ||
          ledger.role != (owner == accountId ? 'owner' : 'editor')) {
        await _runtime.inAccountTransaction(accountId, () async {
          await (_runtime.db.update(_runtime.db.ledgers)..where(
                (l) =>
                    l.id.equals(ledger.id) & l.scopeAccountId.equals(accountId),
              ))
              .write(
                LedgersCompanion(
                  ownerAccountId: d.Value(owner),
                  role: d.Value(owner == accountId ? 'owner' : 'editor'),
                ),
              );
        });
      }
      if (owner == accountId) ownerLedgerIds.add(ledger.id);
    }
    final referencedIds = <String>{};
    for (final change in changes) {
      if (!ownerLedgerIds.contains(change.ledgerId)) continue;
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

    var rows = await (_runtime.db.select(
      _runtime.db.categories,
    )..where((c) => categoryScopePredicate(c, accountId))).get();
    final knownIds = rows.map((c) => c.id).toSet();
    final localSources =
        await (_runtime.db.select(_runtime.db.categories)..where(
              (c) =>
                  categoryScopePredicate(c, null) &
                  c.id.isIn(referencedIds.difference(knownIds)) &
                  c.deletedAt.isNull(),
            ))
            .get();
    if (localSources.isNotEmpty) {
      // 当前账号自己的待传账单明确引用纯本地来源时，复制目录而不移动或换绑原行。
      await _runtime.inAccountTransaction(accountId, () async {
        await cloneCategoryReferences(
          source: _runtime.db,
          target: _runtime.db,
          categoryIds: localSources.map((c) => c.id),
          sourceAccountId: null,
          targetAccountId: accountId,
        );
      });
      rows = await (_runtime.db.select(
        _runtime.db.categories,
      )..where((c) => categoryScopePredicate(c, accountId))).get();
    }
    if (rows.isEmpty) return false;
    final rowById = {
      for (final row in rows)
        if (row.deletedAt == null) row.id: row,
    };
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
        await (_runtime.db.select(_runtime.db.syncChanges)..where(
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
              (row) => !row.cloudRegistered && !pendingIds.contains(row.id),
            )
            .toList()
          // 服务端按请求数组顺序应用：一级（父）必须先于二级（子）落库
          ..sort((a, b) => a.level.compareTo(b.level));
    if (toEnsure.isEmpty) return false;

    await _runtime.inAccountTransaction(accountId, () async {
      for (final category in toEnsure) {
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'category',
                entityId: category.id,
                action: 'upsert',
                payload: categorySyncPayload(
                  category.copyWith(serverVersionToken: const d.Value(null)),
                ),
                updatedAt: category.updatedAt,
                mutationId: const Uuid().v4(),
                accountId: d.Value(accountId),
              ),
            );
      }
    });
    logger.info('SyncService', '已登记 ${toEnsure.length} 个未上云分类，先于引用它们的变更推送');
    return true;
  }

  /// 权威查询源账本在服务端的存活状态（云转本地移动的 ignored 复核专用）：
  /// 404 = 已 tombstone/不可访问（视为已删除）；412 = 时间线不一致但账本存活。
  Future<({bool deleted})> fetchLedgerRemoteStatus(String ledgerId) async {
    final account = _runtime.currentAccountIdForCloudOperation('读取云端账本状态');
    try {
      await _runtime.api.getSyncFull(ledgerId: ledgerId);
      _runtime.requireAccount(account);
      return (deleted: false);
    } on DioException catch (error) {
      // 迟到的 404 不能被新会话解释为旧账号账本已删除。
      _runtime.requireAccount(account);
      if (error.response?.statusCode == 404) return (deleted: true);
      if (error.response?.statusCode == 412) return (deleted: false);
      rethrow;
    }
  }

  /// 预读账本级变更涉及账本的同步身份映射；未建立绑定的账本不在映射中。
  Future<Map<String, String>> syncIdsForLedgers(
    Iterable<String?> ledgerIds,
  ) async {
    final ids = ledgerIds.whereType<String>().toSet();
    if (ids.isEmpty) return const {};
    final rows = await (_runtime.db.select(
      _runtime.db.ledgers,
    )..where((l) => l.id.isIn(ids))).get();
    return {
      for (final row in rows)
        if (row.syncId != null) row.id: row.syncId!,
    };
  }

  /// 账号级公共实体仍与账本快照处于同一事务，目录遍历由四域共用入口执行。
  Future<void> applyAccountingDirectoryGlobals(
    GetSyncAccountingFull200Response body,
    String accountId,
  ) async {
    final protected = await snapshotProtectedEntityIds();
    final tombstones = [...body.categoryTombstones]
      ..sort(
        (a, b) => a.level == b.level
            ? 0
            : a.level == CategoryLevelEnum.n1
            ? -1
            : 1,
      );
    for (final category in tombstones) {
      if (category.ownerId == accountId) {
        if (protected['category']?.contains(category.id) != true) {
          await _ports.projectionUpsertCategory(category, accountId: accountId);
        }
      } else {
        await _ports.projectionApplyCategory(
          category.id,
          'delete',
          _runtime.modelMap(category, Category.serializer),
          eventUpdatedAt: category.updatedAt,
        );
      }
    }
    for (final category in body.categories) {
      if (category.ownerId != accountId) {
        throw const FormatException('本人分类目录含其他所有者数据');
      }
      if (protected['category']?.contains(category.id) != true) {
        await _ports.projectionUpsertCategory(category, accountId: accountId);
      }
    }
    for (final rate in body.exchangeRateOverrides) {
      if (protected['exchange_rate_override']?.contains(rate.id) != true) {
        await _ports.projectionUpsertOverride(rate, accountId: accountId);
      }
    }
    final now = DateTime.now().toUtc();
    // 权威目录只清理已有云基线的缺失行，未确认的本地意图和草稿保持原样。
    final knownIds = {
      ...body.categories.map((c) => c.id),
      ...tombstones.where((c) => c.ownerId == accountId).map((c) => c.id),
      ...?protected['category'],
    };
    await (_runtime.db.update(_runtime.db.categories)..where(
          (c) =>
              categoryScopePredicate(c, accountId) &
              c.cloudRegistered.equals(true) &
              (knownIds.isEmpty
                  ? const d.Constant(true)
                  : c.id.isNotIn(knownIds)),
        ))
        .write(CategoriesCompanion(deletedAt: d.Value(now)));
    if (body.categories.isEmpty &&
        !tombstones.any((c) => c.ownerId == accountId)) {
      await CategorySeedService.ensureAccountSeed(_runtime.db, accountId);
    }
    for (final id in body.deletedExchangeRateOverrideIds) {
      if (protected['exchange_rate_override']?.contains(id) != true) {
        await (_runtime.db.update(_runtime.db.exchangeRateOverrides)
              ..where((c) => c.id.equals(id)))
            .write(ExchangeRateOverridesCompanion(deletedAt: d.Value(now)));
      }
    }
  }

  /// 历史快照在业务事务前下载，只持久登记任务，完整提交前不发布新账本元数据。
  Future<(Map<String, GetSyncFull200Response>, Set<String>)>
  prepareAccountingDownloads(
    Set<String> ids,
    List<GetSyncPull200ResponseChangesInner> changes,
    String accountId,
  ) async {
    final blocked = await blockedLedgerIds(
      changes.map(
        (change) => change.entityType.name == 'ledger'
            ? change.entityId
            : change.ledgerId,
      ),
    );
    final revoked = <String>{};
    final discovered = <String>{};
    final knownBindings = <String, String>{};
    final unpublished =
        await downloadStore?.unpublished(accountId) ?? <String>{};
    for (final change in changes) {
      final ledgerId = change.entityType.name == 'ledger'
          ? change.entityId
          : change.ledgerId;
      if (blocked.contains(ledgerId)) continue;
      if (change.entityType.name == 'ledger' &&
          change.action.name == 'upsert') {
        final ledger = await (_runtime.db.select(
          _runtime.db.ledgers,
        )..where((row) => row.id.equals(change.entityId))).getSingleOrNull();
        final binding = change.payload['sync_id']?.value;
        if (binding is String && binding.isNotEmpty) {
          knownBindings[change.entityId] = binding;
        }
        if (change.payload['requires_full']?.value == true || ledger == null) {
          if (binding is! String || binding.isEmpty) {
            throw const FormatException('账本同步事件缺少 sync_id');
          }
          _runtime.requireAccount(accountId);
          await downloadStore?.markPending(
            accountId,
            change.entityId,
            hasLocalSnapshot:
                ledger != null &&
                ledger.scopeAccountId == accountId &&
                ledger.deletedAt == null &&
                !unpublished.contains(change.entityId),
          );
          ids.add(change.entityId);
        }
        discovered.add(change.entityId);
      }
      if (change.entityType.name == 'member') {
        final existing = await (_runtime.db.select(
          _runtime.db.ledgerMembers,
        )..where((m) => m.id.equals(change.entityId))).getSingleOrNull();
        final linked =
            change.payload['linked_account_id']?.value ??
            existing?.linkedAccountId;
        final status = change.payload['status']?.value;
        if (linked == accountId && status != null && status != 'ACTIVE') {
          if (change.ledgerId case final id?) revoked.add(id);
        }
      }
    }
    final snapshots = <String, GetSyncFull200Response>{};
    final isolated = <String>{};
    for (final id in ids.toList()) {
      final book = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((b) => b.id.equals(id))).getSingleOrNull();
      if (revoked.contains(id) ||
          (book != null &&
              ((book.deletedAt != null && !discovered.contains(id)) ||
                  book.storageMode != 'cloud'))) {
        await downloadStore?.forget(accountId, id);
        ids.remove(id);
        continue;
      }
      if (book?.bindingStatus == 'stale') continue;
      try {
        snapshots[id] = await downloadLedgerFull(
          id,
          accountId,
          knownSyncId: knownBindings[id],
        );
      } on DioException catch (error) {
        if (![403, 404, 412].contains(error.response?.statusCode)) rethrow;
        isolated.add(id);
        ids.remove(id);
      }
    }
    return (snapshots, isolated);
  }

  /// 按 per-mutation 结果处理本批队列行。
  ///
  /// - accepted / ignored：已应用（或幂等重放）→ 标记 pushedAt；transaction 更新
  ///   server_revision（ignored 幂等场景服务端同样返回首次结果 revision）；
  /// - conflict：不标记 pushedAt（本地 pending 保留，解决后基于最新 revision 重推），
  ///   创建/更新 OPEN 冲突记录（本地/云端两版 payload + 双方 revision 供 UI）；
  /// - invalid：保留未上传行与安全原因，用户修正后登记新的 mutation。
  Future<void> applyPushOutcomes(
    List<SyncChange> batch,
    BuiltList<PostSyncPush200ResponseOutcomesInner> outcomes,
    String accountId,
  ) async {
    final outcomeByMutation = {for (final o in outcomes) o.mutationId: o};
    // 单事务批量落库：逐行独立提交（每行一次 SQLite 事务 + fsync）会让
    // 每批收尾耗时与批大小成正比，实测 41 行约 2.5s；整批并入一个事务
    // 只提交一次，行为不变。
    await _runtime.inAccountTransaction(accountId, () async {
      for (final ch in batch) {
        final outcome = outcomeByMutation[ch.mutationId];
        if (outcome == null) continue;
        switch (outcome.status) {
          case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
              PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
            if (ch.entityType == 'transaction' &&
                outcome.status ==
                    PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored &&
                outcome.currentRevision != null) {
              final revision = outcome.currentRevision!;
              final remaining =
                  await (_runtime.db.select(_runtime.db.syncChanges)
                        ..where(
                          (row) =>
                              row.entityType.equals('transaction') &
                              row.entityId.equals(ch.entityId) &
                              row.accountId.equals(accountId) &
                              row.pushedAt.isNull(),
                        )
                        ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
                      .get();
              final remote = outcome.currentEntity?.value;
              if (remaining.isNotEmpty) {
                // 发生已由别端创建，后继人工编辑不能借去重确认静默覆盖另一端更新。
                final tail = remaining.last;
                await _runtime.upsertConflict(
                  ledgerId: ch.ledgerId!,
                  entityType: 'transaction',
                  entityId: ch.entityId,
                  localPayload: tail.action == 'delete'
                      ? jsonEncode({
                          ...jsonDecode(tail.payload) as Map<String, dynamic>,
                          'deleted': true,
                        })
                      : tail.payload,
                  baseRevision: remaining.first.baseRevision,
                  remoteRevision: revision,
                  remotePayload: outcome.currentDeleted == true
                      ? jsonEncode({'deleted': true, 'revision': revision})
                      : jsonEncode(remote),
                  localMutationId: remaining.first.mutationId,
                );
              } else if (outcome.currentDeleted == true) {
                await (_runtime.db.update(
                  _runtime.db.transactions,
                )..where((row) => row.id.equals(ch.entityId))).write(
                  TransactionsCompanion(
                    deletedAt: d.Value(DateTime.now().toUtc()),
                    serverRevision: d.Value(revision),
                  ),
                );
              } else {
                if (remote is! Map ||
                    remote['id'] != ch.entityId ||
                    remote['ledger_id'] != ch.ledgerId) {
                  throw const FormatException('周期发生去重响应缺少权威快照');
                }
                final tx = _runtime.deser<Transaction>(
                  jsonEncode(remote),
                  Transaction.serializer,
                );
                await _ports.projectionUpsertTransaction(tx);
              }
              continue;
            }
            if (outcome.currentEntity?.value case final Map snapshot
                when ch.entityType == 'ledger_archive') {
              if (snapshot['ledger_id'] != ch.entityId) {
                throw const FormatException('账本归档确认数据无效');
              }
              // 无后继操作时采用服务器保存后的版本，包含未来时钟裁剪和旧版本裁决。
              if (!await _ports.projectionHasPendingChange(
                'ledger_archive',
                ch.entityId,
              )) {
                await _ports.projectionApplyLedgerArchive(
                  ch.entityId,
                  archivedAt: snapshot['archived_at'] == null
                      ? null
                      : DateTime.parse(snapshot['archived_at'] as String),
                  updatedAt: DateTime.parse(snapshot['updated_at'] as String),
                  remoteDeviceId: snapshot['device_id'] as String?,
                  serverCursor: snapshot['server_cursor'] as String,
                  confirmed: true,
                );
              }
            }
            if (ch.entityType == 'transaction' && outcome.revision != null) {
              await _ports.projectionUpdateServerRevision(
                ch.entityId,
                outcome.revision!,
              );
            }
            // ledger 实体返回的 sync_id：首次上云创建账本时据此建立绑定
            final syncId = outcome.syncId;
            if (syncId != null) {
              await (_runtime.db.update(_runtime.db.ledgers)
                    ..where((l) => l.id.equals(outcome.entityId)))
                  .write(LedgersCompanion(syncId: d.Value(syncId)));
            }
          case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
            await _runtime.upsertConflict(
              ledgerId: ch.ledgerId ?? '',
              entityType: ch.entityType,
              entityId: ch.entityId,
              localPayload: ch.action == 'delete'
                  ? jsonEncode({
                      ...jsonDecode(ch.payload) as Map<String, dynamic>,
                      'deleted': true,
                    })
                  : ch.payload,
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
          default:
            break;
        }
      }
    });
  }

  /// 确认账本仍处于等待用户处理的失效绑定状态。
  Future<void> requireStaleBinding(String ledgerId) async {
    final ledger = await (_runtime.db.select(
      _runtime.db.ledgers,
    )..where((row) => row.id.equals(ledgerId))).getSingleOrNull();
    if (ledger == null ||
        ledger.deletedAt != null ||
        ledgerSyncStateOf(
              storageMode: ledger.storageMode,
              syncId: ledger.syncId,
              bindingStatus: ledger.bindingStatus,
            ) !=
            LedgerSyncState.staleBinding) {
      throw StateError('当前账本不处于可重绑状态');
    }
  }

  /// 查询本页涉及的不可同步账本，作为 push/pull 共用状态门禁。
  Future<Set<String>> blockedLedgerIds(Iterable<String?> candidateIds) async {
    final ids = candidateIds.whereType<String>().toSet();
    if (ids.isEmpty) return const {};
    final ledgers = await (_runtime.db.select(
      _runtime.db.ledgers,
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

  /// 执行fullLedger对应的同步步骤，沿用所属域的身份与事务规则。
  Future<String> fullLedger({required String ledgerId}) async {
    final accountId = _runtime.currentAccountIdForCloudOperation('下载云账本快照');
    final data = await downloadLedgerFull(ledgerId, accountId);
    await applyFullSnapshot(ledgerId, data, accountId: accountId);
    _runtime.requireAccount(accountId);
    await downloadStore?.markReady(accountId, ledgerId);
    return data.serverCursor;
  }

  /// 网络请求与业务写事务分开；失效绑定和明确撤权复用同一保护流程。
  Future<GetSyncFull200Response> downloadLedgerFull(
    String ledgerId,
    String accountId, {
    String? knownSyncId,
  }) async {
    // 本地已有同步身份则携带：服务端校验不一致返回 412 SYNC_ID_MISMATCH，
    // 禁止静默覆盖另一条时间线（本地分支保留，由用户决策，见 STALE_BINDING）
    final existing = await (_runtime.db.select(
      _runtime.db.ledgers,
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
    // 已有本地分支固定原绑定；首次发现使用事件中的绑定，避免请求期间串到另一时间线。
    final expectedSyncId = existing?.syncId ?? knownSyncId;
    try {
      _runtime.requireAccount(accountId);
      final resp = await _runtime.api.getSyncFull(
        ledgerId: ledgerId,
        syncId: expectedSyncId,
        includeRecurringState: true,
      );
      _runtime.requireAccount(accountId);
      final data = resp.data!;
      if (data.ledger.id != ledgerId ||
          (expectedSyncId != null && data.ledger.syncId != expectedSyncId)) {
        throw const FormatException('账本快照身份不匹配');
      }
      return data;
    } on DioException catch (e) {
      if (downloadStore != null &&
          (e.response?.statusCode == 403 || e.response?.statusCode == 404) &&
          (await downloadStore!.pending(accountId)).contains(ledgerId)) {
        // 首次快照被明确拒绝时隐藏占位行，保留本机内容供既有数据保护流程处理。
        await _runtime.inAccountTransaction(accountId, () async {
          await (_runtime.db.update(
            _runtime.db.ledgers,
          )..where((row) => row.id.equals(ledgerId))).write(
            LedgersCompanion(deletedAt: d.Value(DateTime.now().toUtc())),
          );
        });
        await downloadStore!.forget(accountId, ledgerId);
      }
      // SYNC_ID_MISMATCH → STALE_BINDING（持久标记，同步暂停等待用户决策），
      // 绝不静默覆盖另一条时间线
      if (e.response?.statusCode == 412) {
        // 绝不默认丢弃本地数据——先把本地状态保护为 Local Safety Fork
        //（DR_PROTECT），再标记 STALE_BINDING 等待用户显式决策（手动 abandon）。
        await _runtime.inAccountTransaction(accountId, () async {
          await _ports.operationsQuarantineLedger(
            ledgerId,
            accountId,
            stale: true,
          );
        });
      }
      rethrow;
    }
  }

  /// 在调用方事务内读取分支指纹；业务队列或冲突内容变化即视为不同分支。
  Future<String?> localStateProtectionKey(String ledgerId) async {
    final ledger = await (_runtime.db.select(
      _runtime.db.ledgers,
    )..where((row) => row.id.equals(ledgerId))).getSingle();
    final pending =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (change) =>
                    change.ledgerId.equals(ledgerId) & change.pushedAt.isNull(),
              )
              ..orderBy([(change) => d.OrderingTerm.asc(change.id)]))
            .get();
    final openConflicts =
        await (_runtime.db.select(_runtime.db.syncConflicts)
              ..where(
                (conflict) =>
                    conflict.ledgerId.equals(ledgerId) &
                    conflict.status.equals('OPEN'),
              )
              ..orderBy([(conflict) => d.OrderingTerm.asc(conflict.id)]))
            .get();
    if (pending.isEmpty && openConflicts.isEmpty) return null;
    // 同一来源、同一时间线且队列/冲突内容完全相同，才对应同一个保护版本。
    return const Uuid().v5(
      Namespace.url.value,
      jsonEncode([
        'sesame-notes/local-state-protection/v1',
        ledger.id,
        ledger.syncId,
        pending.map((change) => change.toJson()).toList(),
        openConflicts.map((conflict) => conflict.toJson()).toList(),
      ]),
    );
  }

  /// 从持久来源信息确认当前分支已被复制；失效绑定本身不表示保护成功。
  Future<LocalStateProtection> localStateProtection(String ledgerId) async {
    try {
      return await _runtime.db.transaction(() async {
        final key = await localStateProtectionKey(ledgerId);
        if (key == null) return LocalStateProtection.notNeeded;
        final fork =
            await (_runtime.db.select(_runtime.db.ledgers)
                  ..where(
                    (row) =>
                        row.originLedgerId.equals(ledgerId) &
                        row.originBackupId.equals(key) &
                        row.originType.equals('DR_PROTECT') &
                        row.storageMode.equals('local') &
                        row.syncId.isNull() &
                        row.bindingStatus.isNull() &
                        row.deletedAt.isNull(),
                  )
                  ..limit(1))
                .getSingleOrNull();
        return fork == null
            ? LocalStateProtection.failed
            : LocalStateProtection.protected;
      });
    } catch (error, stackTrace) {
      logger.error('SyncService', '读取本地分支保护状态失败: $ledgerId', error, stackTrace);
      return LocalStateProtection.failed;
    }
  }

  /// 将待保护分支与其指纹在同一事务写入本地副本；失败不会修改源分支。
  Future<LocalStateProtection> protectLocalStateAsFork(String ledgerId) async {
    try {
      return await _runtime.db.transaction(() async {
        final key = await localStateProtectionKey(ledgerId);
        if (key == null) return LocalStateProtection.notNeeded;
        if (await localStateProtection(ledgerId) ==
            LocalStateProtection.protected) {
          return LocalStateProtection.protected;
        }
        final repository = repo;
        final loader = localSelfIdLoader;
        if (repository == null || loader == null) {
          throw StateError('本地副本服务不可用');
        }
        final forkId = await repository.protectCloudLedgerToLocalFork(
          sourceLedgerId: ledgerId,
          targetLedgerId: const Uuid().v4(),
          localSelfId: await loader(),
          currentAccountId: _runtime.currentAccountIdForCloudOperation(
            '保护本地状态',
          ),
        );
        // 指纹只有在整份副本复制成功后才随事务提交，重启也可验证保护结果。
        await (_runtime.db.update(_runtime.db.ledgers)
              ..where((row) => row.id.equals(forkId)))
            .write(LedgersCompanion(originBackupId: d.Value(key)));
        logger.info('SyncService', '已保护本地状态为 DR_PROTECT 副本: $ledgerId');
        return LocalStateProtection.protected;
      });
    } catch (e, st) {
      // 保护失败不阻断 stale 标记：同步仍暂停等待用户决策，数据仍在本地原行
      logger.error('SyncService', '本地状态保护失败: $ledgerId', e, st);
      return LocalStateProtection.failed;
    }
  }

  /// full 响应落库（覆盖式收敛，full 与 STALE_BINDING 恢复路径复用）。
  Future<void> applyFullSnapshot(
    String ledgerId,
    GetSyncFull200Response data, {
    required String accountId,
  }) async {
    final ownerId = data.ledger.ownerId;
    if (ownerId == null || ownerId.isEmpty) {
      throw SyncOperationFailure(
        code: 'CLOUD_OWNERSHIP_MISSING',
        message: '云端账本的归属信息不完整，请重新同步账本后再试',
        target: SyncTarget('ledger', ledgerId),
      );
    }
    await _runtime.inAccountTransaction(accountId, () async {
      final protectedIds = await snapshotProtectedEntityIds();

      // full 以云端账本元数据为权威；待推送或冲突中的本地分支仍保留。
      final localLedger = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
      final changedBinding =
          localLedger != null && localLedger.syncId != data.ledger.syncId;
      if (localLedger == null) {
        await _runtime.db
            .into(_runtime.db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: data.ledger.id,
                name: data.ledger.name,
                currency: d.Value(data.ledger.currency),
                monthStartDay: d.Value(data.ledger.monthStartDay),
                aaEnabled: d.Value(data.ledger.aaEnabled),
                storageMode: const d.Value('cloud'),
                scopeAccountId: d.Value(accountId),
                ownerAccountId: d.Value(ownerId),
                role: d.Value(ownerId == accountId ? 'owner' : 'editor'),
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
        await (_runtime.db.update(
          _runtime.db.ledgers,
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
            // 完整快照已经核验绑定，页内较旧的账本事件不能把内容留在另一条时间线。
            syncId: d.Value(data.ledger.syncId),
            // 归档游标仅属于当前云端时间线，重新绑定时由本次快照建立。
            archiveServerCursor: changedBinding
                ? const d.Value(null)
                : const d.Value.absent(),
            scopeAccountId: d.Value(accountId),
            ownerAccountId: d.Value(ownerId),
            role: d.Value(ownerId == accountId ? 'owner' : 'editor'),
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
      await _ports.projectionApplyLedgerArchive(
        ledgerId,
        archivedAt: data.ledger.archivedAt,
        updatedAt: data.ledger.archiveUpdatedAt,
        remoteDeviceId: data.ledger.archiveDeviceId,
        serverCursor: data.serverCursor,
        // 已放弃旧分支的重绑采用新时间线版本，本人未上传选择仍受保护。
        confirmed:
            changedBinding &&
            protectedIds['ledger_archive']?.contains(ledgerId) != true,
      );
      final catalog = [...data.categoryTombstones, ...data.categories]
        ..sort(
          (a, b) => a.level == b.level
              ? 0
              : a.level == CategoryLevelEnum.n1
              ? -1
              : 1,
        );
      if (ownerId != accountId) {
        final liveIds = data.categories.map((c) => c.id).toSet();
        await (_runtime.db.update(_runtime.db.sharedLedgerCategories)..where(
              (c) =>
                  c.ledgerId.equals(ledgerId) &
                  (liveIds.isEmpty
                      ? const d.Constant(true)
                      : c.categoryId.isNotIn(liveIds)),
            ))
            .write(
              SharedLedgerCategoriesCompanion(
                deletedAt: d.Value(DateTime.now().toUtc()),
              ),
            );
      }
      for (final cat in catalog) {
        if (cat.ownerId != ownerId) {
          throw const FormatException('分类归属与账本所有者不一致');
        }
        if (ownerId == accountId) {
          if (protectedIds['category']?.contains(cat.id) == true) continue;
          await _ports.projectionUpsertCategory(cat, accountId: accountId);
        } else {
          await _ports.projectionApplyCategory(
            cat.id,
            cat.deletedAt == null ? 'upsert' : 'delete',
            _runtime.modelMap(cat, Category.serializer),
            eventUpdatedAt: cat.updatedAt,
          );
        }
      }
      for (final rt in data.recurringTransactions) {
        if (protectedIds['recurring_transaction']?.contains(rt.id) == true) {
          continue;
        }
        await _ports.projectionUpsertRecurring(rt);
      }
      // 交易可能引用周期模板；先落模板再落交易，保证开启 SQLite 外键时
      // 新设备也能从空库应用完整快照。
      for (final tx in data.transactions) {
        if (protectedIds['transaction']?.contains(tx.id) == true) continue;
        await _ports.projectionUpsertTransaction(tx);
      }
      for (final m in data.members) {
        if (protectedIds['member']?.contains(m.id) == true) continue;
        await _ports.projectionUpsertMember(m);
      }
      for (final ov in data.exchangeRateOverrides) {
        if (protectedIds['exchange_rate_override']?.contains(ov.id) == true) {
          continue;
        }
        await _ports.projectionUpsertOverride(ov, accountId: accountId);
      }
      // 完整快照携带周期墓碑；沿用生成模型解码后再走统一投影。
      // 全部写入和原快照处于同一事务，复制操作不会观察到暂时复活的行。
      final snapshot = _runtime.modelMap(
        data,
        GetSyncFull200Response.serializer,
      );
      final recurringState = snapshot['recurring_state'] as Map?;
      final recurringRuleIds = <String>{};
      final recurringTransactionIds = <String>{};
      if (recurringState != null) {
        for (final raw in recurringState['rules'] as List) {
          final payload = Map<String, dynamic>.from(raw as Map);
          final rule = _runtime.deser<RecurringTransaction>(
            jsonEncode(payload),
            RecurringTransaction.serializer,
          );
          if (rule.ledgerId != ledgerId || rule.protocolVersion != 1) {
            throw const FormatException('周期完整快照身份不匹配');
          }
          recurringRuleIds.add(rule.id);
          if (protectedIds['recurring_transaction']?.contains(rule.id) ==
              true) {
            continue;
          }
          await _ports.projectionUpsertRecurring(rule);
          await (_runtime.db.update(
            _runtime.db.recurringTransactions,
          )..where((row) => row.id.equals(rule.id))).write(
            RecurringTransactionsCompanion(
              deletedAt: d.Value(
                payload['deleted_at'] == null
                    ? null
                    : DateTime.parse(payload['deleted_at'] as String),
              ),
            ),
          );
        }
        for (final raw in recurringState['occurrences'] as List) {
          final payload = Map<String, dynamic>.from(raw as Map);
          final occurrence = _runtime.deser<Transaction>(
            jsonEncode(payload),
            Transaction.serializer,
          );
          if (occurrence.ledgerId != ledgerId ||
              !recurringRuleIds.contains(occurrence.recurringId)) {
            throw const FormatException('周期历史发生的来源不匹配');
          }
          recurringTransactionIds.add(occurrence.id);
          if (protectedIds['transaction']?.contains(occurrence.id) == true) {
            continue;
          }
          await _ports.projectionUpsertTransaction(occurrence);
          await (_runtime.db.update(
            _runtime.db.transactions,
          )..where((row) => row.id.equals(occurrence.id))).write(
            TransactionsCompanion(
              deletedAt: d.Value(
                payload['deleted_at'] == null
                    ? null
                    : DateTime.parse(payload['deleted_at'] as String),
              ),
            ),
          );
        }
      }
      await tombstoneMissingLedgerEntities(
        ledgerId: ledgerId,
        transactionIds: {
          ...data.transactions.map((tx) => tx.id),
          ...recurringTransactionIds,
        },
        recurringIds: {
          ...data.recurringTransactions.map((rt) => rt.id),
          ...recurringRuleIds,
        },
        memberIds: data.members.map((m) => m.id).toSet(),
        protectedIds: protectedIds,
      );
    });
    logger.info('SyncService', 'full 落库完成, cursor=${data.serverCursor}');
  }

  /// 返回当前账号 full 覆盖时必须保留的实体，同编号的其他目录分支独立处理。
  Future<Map<String, Set<String>>> snapshotProtectedEntityIds() async {
    final account = _runtime.currentAccountIdForCloudOperation('读取快照保护分支');
    final protected = <String, Set<String>>{};
    final pending = await (_runtime.db.select(
      _runtime.db.syncChanges,
    )..where((c) => c.pushedAt.isNull() & c.accountId.equals(account))).get();
    for (final change in pending) {
      protected
          .putIfAbsent(change.entityType, () => <String>{})
          .add(change.entityId);
    }
    final conflicts =
        await (_runtime.db.select(_runtime.db.syncConflicts)..where(
              (c) => c.status.equals('OPEN') & c.accountId.equals(account),
            ))
            .get();
    for (final conflict in conflicts) {
      protected
          .putIfAbsent(conflict.entityType, () => <String>{})
          .add(conflict.entityId);
    }
    return protected;
  }

  /// 让 full 成为账本云副本的权威集合，同时保留本地待合并分支。
  Future<void> tombstoneMissingLedgerEntities({
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
    final transactionUpdate = _runtime.db.update(_runtime.db.transactions)
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
    final recurringUpdate =
        _runtime.db.update(_runtime.db.recurringTransactions)..where((t) {
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
    final memberUpdate = _runtime.db.update(_runtime.db.ledgerMembers)
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
}

/// 账号记账目录、账本快照、保护副本和记账推送回执处理所需的外部协作端口。
class AccountingSyncHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const AccountingSyncHandlerPorts({
    required this.operationsQuarantineLedger,
    required this.projectionApplyLedgerArchive,
    required this.projectionHasPendingChange,
    required this.projectionUpdateServerRevision,
    required this.projectionUpsertCategory,
    required this.projectionApplyCategory,
    required this.projectionUpsertMember,
    required this.projectionUpsertOverride,
    required this.projectionUpsertRecurring,
    required this.projectionUpsertTransaction,
  });

  /// 委托operations域执行quarantineLedger。
  final Future<void> Function(
    String id,
    String? account, {
    bool stale,
    bool deleted,
    DateTime? remoteDeletedAt,
  })
  operationsQuarantineLedger;

  /// 委托projection域执行applyLedgerArchive。
  final Future<void> Function(
    String ledgerId, {
    required DateTime? archivedAt,
    required DateTime? updatedAt,
    required String? remoteDeviceId,
    required String serverCursor,
    bool confirmed,
  })
  projectionApplyLedgerArchive;

  /// 委托projection域执行hasPendingChange。
  final Future<bool> Function(String type, String entityId)
  projectionHasPendingChange;

  /// 委托projection域执行updateServerRevision。
  final Future<void> Function(String entityId, int revision)
  projectionUpdateServerRevision;

  /// 委托projection域执行upsertCategory。
  final Future<void> Function(Category cat, {required String accountId})
  projectionUpsertCategory;

  /// 所有者明确的共享分类与墓碑走独立镜像，不进入私有目录。
  final Future<void> Function(
    String id,
    String action,
    Map<String, dynamic> payload, {
    DateTime? eventUpdatedAt,
  })
  projectionApplyCategory;

  /// 委托projection域执行upsertMember。
  final Future<void> Function(Member m) projectionUpsertMember;

  /// 委托projection域执行upsertOverride。
  final Future<void> Function(
    ExchangeRateOverride ov, {
    required String accountId,
  })
  projectionUpsertOverride;

  /// 委托projection域执行upsertRecurring。
  final Future<void> Function(RecurringTransaction rt)
  projectionUpsertRecurring;

  /// 委托projection域执行upsertTransaction。
  final Future<void> Function(Transaction tx) projectionUpsertTransaction;
}
