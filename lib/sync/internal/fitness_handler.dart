import 'dart:convert';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/data/models/private_book.dart' as private_books;
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/data/models/fitness_payload_shapes.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';
import 'sync_runtime.dart';

/// 健身空间与实体的版本化同步和完整性维护。
class FitnessSyncHandler {
  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  FitnessSyncHandler(
    this._runtime,
    this._ports, {
    required this.fitnessEnabled,
  });
  final SyncRuntime _runtime;
  final FitnessSyncHandlerPorts _ports;
  final bool fitnessEnabled;

  /// 执行fitnessSpace对应的同步步骤，沿用所属域的身份与事务规则。
  Future<FitnessSpaceRow?> fitnessSpace(String id) => (_runtime.db.select(
    _runtime.db.fitnessSpaces,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  /// 执行fitnessType对应的同步步骤，沿用所属域的身份与事务规则。
  String fitnessType(String name) => switch (name) {
    'fitnessSpace' => 'fitness_space',
    'fitnessTemplate' => 'fitness_template',
    'fitnessPlan' => 'fitness_plan',
    'fitnessWorkout' => 'fitness_workout',
    'fitnessPreferences' => 'fitness_preferences',
    _ => throw const FormatException('FITNESS_ENTITY_TYPE'),
  };

  /// 执行fitnessPayload对应的同步步骤，沿用所属域的身份与事务规则。
  Map<String, dynamic> fitnessPayload(
    String type,
    Map<String, dynamic> remote,
  ) {
    final payload = Map<String, dynamic>.from(remote)
      ..remove('id')
      ..remove('fitness_space_id')
      ..remove('sync_id')
      ..remove('revision')
      ..remove('deleted_at')
      ..remove('deleted');
    // 按形状注册表筛选已知字段，再逐个校验其类型与业务约束。
    final sanitized = fitnessPayloadIgnoringUnknown(type, payload);
    validateFitnessPayload(type, sanitized);
    return sanitized;
  }

  /// 执行validateFitnessRemote对应的同步步骤，沿用所属域的身份与事务规则。
  void validateFitnessRemote(
    String type,
    String id,
    Map<String, dynamic> remote,
  ) {
    final revision = remote['revision'];
    final syncId = remote['sync_id'];
    if (!fitnessSyncTypes.contains(type) ||
        remote['id'] != id ||
        !Uuid.isValidUUID(fromString: id) ||
        syncId is! String ||
        !Uuid.isValidUUID(fromString: syncId) ||
        revision is! int ||
        revision < 1 ||
        (remote['deleted_at'] != null &&
            DateTime.tryParse(remote['deleted_at'].toString()) == null)) {
      throw const FormatException('FITNESS_REMOTE_IDENTITY');
    }
    validateFitnessIdentity(type, id, fitnessPayload(type, remote));
  }

  /// 完整个人快照没有虚拟父本；五类与墓碑一起校验、一起落库后才发布完整状态。
  Future<void> fullFitness({
    required String spaceId,
    String? minimumCursor,
    GetSyncFitnessSpacesFull200Response? downloaded,
  }) async {
    if (!fitnessEnabled) return;
    final account = _runtime.currentAccountIdForCloudOperation('恢复健身数据');
    final localSpace = await fitnessSpace(spaceId);
    final before = localSpace?.fullCursor;
    final full =
        downloaded ??
        (await _runtime.api.getSyncFitnessSpacesFull(
          fitnessSpaceId: spaceId,
          syncId: localSpace?.syncId,
        )).data!;
    _runtime.requireAccount(account);
    final snapshot = _runtime.modelMap(
      full,
      GetSyncFitnessSpacesFull200Response.serializer,
    );
    final cursor = snapshot['server_cursor'] as String;
    final meta = Map<String, dynamic>.from(snapshot['fitness_space'] as Map);
    if (meta['id'] != spaceId ||
        (localSpace?.syncId != null && meta['sync_id'] != localSpace!.syncId)) {
      throw StateError('FITNESS_SPACE_CHANGED');
    }
    if (BigInt.parse(cursor) < BigInt.zero ||
        (minimumCursor != null &&
            BigInt.parse(cursor) < BigInt.parse(minimumCursor)) ||
        (before != null && BigInt.parse(cursor) < BigInt.parse(before))) {
      throw const FormatException('FITNESS_STALE_FULL');
    }
    final records = <(String, Map<String, dynamic>)>[];
    final ids = <String>{};
    for (final (type, field) in const [
      ('fitness_template', 'fitness_templates'),
      ('fitness_plan', 'fitness_plans'),
      ('fitness_workout', 'fitness_workouts'),
      ('fitness_preferences', 'fitness_preferences'),
    ]) {
      for (final value in snapshot[field] as List) {
        final remote = Map<String, dynamic>.from(value as Map);
        final id = remote['id'] as String;
        if (!ids.add(id)) throw const FormatException('FITNESS_FULL_DUPLICATE');
        validateFitnessRemote(type, id, remote);
        if (remote['fitness_space_id'] != spaceId) {
          throw const FormatException('FITNESS_FULL_SCOPE');
        }
        if (type == 'fitness_preferences' && id != spaceId) {
          throw const FormatException('FITNESS_PREFERENCES_SCOPE');
        }
        records.add((type, remote));
      }
    }
    // 先应用结束/删除，再应用运行中的场次，避免相同快照的行顺序制造唯一性冲突。
    records.sort(
      (a, b) => fitnessRunning(a.$2).compareTo(fitnessRunning(b.$2)),
    );
    await _runtime.inAccountTransaction(account, () async {
      await applyFitnessSpacePayload(spaceId, meta, account);
      for (final (type, remote) in records) {
        await applyFitnessRemote(type, remote['id'] as String, remote, account);
      }
      final cached = await (_runtime.db.select(
        _runtime.db.fitnessEntities,
      )..where((e) => e.fitnessSpaceId.equals(spaceId))).get();
      for (final local in cached) {
        if (!ids.contains(local.id) && (local.serverRevision ?? 0) > 0) {
          // 服务端完整快照包含永久墓碑；缺失绑定不能被推测为允许新建或删除。
          await (_runtime.db.update(_runtime.db.fitnessEntities)
                ..where((e) => e.id.equals(local.id)))
              .write(const FitnessEntitiesCompanion(isStale: d.Value(true)));
        }
      }
      await (_runtime.db.update(
        _runtime.db.fitnessSpaces,
      )..where((s) => s.id.equals(spaceId))).write(
        FitnessSpacesCompanion(
          fullCursor: d.Value(cursor),
          isStale: const d.Value(false),
        ),
      );
      await refreshFitnessCompleteness(account);
    });
  }

  /// 执行fitnessRunning对应的同步步骤，沿用所属域的身份与事务规则。
  int fitnessRunning(Map<String, dynamic> payload) =>
      payload['status'] == 'in_progress' &&
          payload['deleted_at'] == null &&
          payload['deleted'] != true
      ? 1
      : 0;

  /// 执行pullFitnessPage对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> pullFitnessPage(
    List<GetSyncPull200ResponseChangesInner> changes,
    String account,
    String cursor,
  ) => _runtime.inAccountTransaction(account, () async {
    for (final change in changes) {
      if (change.ledgerId != null ||
          change.dayBookId != null ||
          change.memoBookId != null) {
        throw const FormatException('FITNESS_CHANGE_SCOPE');
      }
      final type = fitnessType(change.entityType.name);
      final spaceId = change.fitnessSpaceId;
      if (spaceId == null) throw const FormatException('FITNESS_CHANGE_SCOPE');
      final scope = await fitnessSpace(spaceId);
      final remote = <String, dynamic>{
        for (final entry in change.payload.entries)
          entry.key: entry.value?.value,
      };
      if (type != 'fitness_space') {
        validateFitnessRemote(type, change.entityId, remote);
      }
      final own =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) =>
                    c.accountId.equals(account) &
                    c.mutationId.equals(change.mutationId),
              ))
              .getSingleOrNull();
      if (own != null && own.pushedAt == null) {
        if (own.entityType != type || own.entityId != change.entityId) {
          throw const FormatException('FITNESS_CHANGE_IDENTITY');
        }
        await _ports.pushApplyPendingOutcome(
          own,
          PostSyncPush200ResponseOutcomesInner(
            (b) => b
              ..mutationId = own.mutationId
              ..entityId = own.entityId
              ..status = PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted
              ..changeId = change.changeId
              ..revision = remote['revision'] as int
              ..syncId = remote['sync_id'] as String,
          ),
          account,
        );
        continue;
      }
      if (type == 'fitness_space') {
        await applyFitnessSpacePayload(spaceId, remote, account);
        continue;
      }
      if (scope?.fullCursor != null &&
          BigInt.parse(change.changeId) <= BigInt.parse(scope!.fullCursor!)) {
        continue;
      }
      await applyFitnessRemote(type, change.entityId, remote, account);
    }
    await saveFitnessCursor(cursor, account);
    await refreshFitnessCompleteness(account);
  });

  /// 执行applyFitnessRemote对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyFitnessRemote(
    String type,
    String id,
    Map<String, dynamic> remote,
    String account,
  ) async {
    validateFitnessRemote(type, id, remote);
    final spaceId = remote['fitness_space_id'] as String?;
    final space = spaceId == null ? null : await fitnessSpace(spaceId);
    if (space == null ||
        space.scopeAccountId != account ||
        space.deletedAt != null ||
        space.isHidden ||
        space.isStale ||
        space.syncId != remote['sync_id']) {
      throw StateError('FITNESS_SPACE_CHANGED');
    }
    final local = await fitnessEntity(id);
    if (local != null &&
        (local.entityType != type ||
            local.scopeAccountId != account ||
            local.storageMode != 'cloud')) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    if (type == 'fitness_preferences' && id != spaceId) {
      throw const FormatException('FITNESS_PREFERENCES_SCOPE');
    }
    if (local != null) {
      final conflicts =
          await (_runtime.db.select(_runtime.db.syncConflicts)..where(
                (c) =>
                    c.accountId.equals(account) &
                    c.entityId.equals(id) &
                    c.status.equals('OPEN'),
              ))
              .get();
      if (conflicts.any(
        (c) => (jsonDecode(c.remotePayload) as Map)['id'] == id,
      )) {
        await fitnessConflict(local, remote, account);
        return;
      }
      if (local.syncId != null && local.syncId != remote['sync_id']) {
        await fitnessConflict(local, remote, account);
        await (_runtime.db.update(_runtime.db.fitnessEntities)
              ..where((e) => e.id.equals(id)))
            .write(const FitnessEntitiesCompanion(isStale: d.Value(true)));
        return;
      }
      if ((local.serverRevision ?? 0) >= (remote['revision'] as int)) return;
      final head = await _runtime.pendingChange(type, id, account);
      if (head != null) {
        // 未知结果必须重放原请求；仅确认未发送或明确绑定失效才建立冲突。
        if (head.frozenRequest == null || local.isStale) {
          await fitnessConflict(local, remote, account, head: head);
        } else {
          // 回滚整页与水位，重放确认冻结请求后再获取此远端版本。
          throw StateError('FITNESS_FROZEN_REMOTE_PENDING');
        }
        return;
      }
    }
    if (type == 'fitness_workout' && fitnessRunning(remote) == 1) {
      final workouts =
          await (_runtime.db.select(_runtime.db.fitnessEntities)..where(
                (e) =>
                    e.fitnessSpaceId.equals(spaceId!) &
                    e.entityType.equals(type) &
                    e.deletedAt.isNull(),
              ))
              .get();
      final running = workouts
          .where(
            (e) =>
                e.id != id &&
                (jsonDecode(e.payload) as Map)['status'] == 'in_progress',
          )
          .firstOrNull;
      if (running != null) {
        await fitnessConflict(running, remote, account);
        return;
      }
    }
    await writeFitnessRemote(type, id, remote, account);
  }

  /// 执行writeFitnessRemote对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> writeFitnessRemote(
    String type,
    String id,
    Map<String, dynamic> remote,
    String account,
  ) async {
    validateFitnessRemote(type, id, remote);
    final spaceId = remote['fitness_space_id'] as String?;
    final space = spaceId == null ? null : await fitnessSpace(spaceId);
    if (space == null ||
        space.scopeAccountId != account ||
        space.deletedAt != null ||
        space.isHidden ||
        space.isStale ||
        space.syncId != remote['sync_id']) {
      throw StateError('FITNESS_SPACE_CHANGED');
    }
    final local = await fitnessEntity(id);
    if (local != null &&
        (local.scopeAccountId != account || local.entityType != type)) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    final payload = fitnessPayload(type, remote);
    await _runtime.db
        .into(_runtime.db.fitnessEntities)
        .insertOnConflictUpdate(
          FitnessEntitiesCompanion.insert(
            id: id,
            entityType: type,
            fitnessSpaceId: spaceId!,
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(account),
            syncId: d.Value(remote['sync_id'] as String),
            serverRevision: d.Value(remote['revision'] as int),
            payload: jsonEncode(payload),
            isStale: const d.Value(false),
            createdAt: DateTime.parse(payload['created_at'] as String),
            updatedAt: DateTime.parse(payload['updated_at'] as String),
            deletedAt: d.Value(
              remote['deleted_at'] != null
                  ? DateTime.parse(remote['deleted_at'] as String)
                  : remote['deleted'] == true
                  ? DateTime.now().toUtc()
                  : null,
            ),
          ),
        );
  }

  /// 执行saveFitnessCursor对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> saveFitnessCursor(String cursor, String account) =>
      _runtime.saveDomainCursor(SyncDomain.fitness, cursor, account);

  /// 执行refreshFitnessCompleteness对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> refreshFitnessCompleteness(String account) async {
    final rows =
        await (_runtime.db.select(_runtime.db.fitnessEntities)..where(
              (e) => e.scopeAccountId.equals(account) & e.isStale.equals(true),
            ))
            .get();
    for (final id in rows.map((e) => e.fitnessSpaceId).toSet()) {
      await (_runtime.db.update(_runtime.db.fitnessSpaces)
            ..where((s) => s.id.equals(id)))
          .write(const FitnessSpacesCompanion(isStale: d.Value(true)));
    }
  }

  /// 执行fitnessEntity对应的同步步骤，沿用所属域的身份与事务规则。
  Future<FitnessEntityRow?> fitnessEntity(String id) => (_runtime.db.select(
    _runtime.db.fitnessEntities,
  )..where((e) => e.id.equals(id))).getSingleOrNull();

  /// 执行freezeFitnessChange对应的同步步骤，沿用所属域的身份与事务规则。
  Future<SyncChange?> freezeFitnessChange(
    SyncChange source,
    String account,
  ) async {
    SyncChange? result;
    await _runtime.inAccountTransaction(account, () async {
      final row =
          await (_runtime.db.select(_runtime.db.syncChanges)..where(
                (c) => c.id.equals(source.id) & c.accountId.equals(account),
              ))
              .getSingleOrNull();
      if (row == null || row.pushedAt != null) return;
      final space = row.fitnessSpaceId == null
          ? null
          : await fitnessSpace(row.fitnessSpaceId!);
      final entity = row.entityType == 'fitness_space'
          ? null
          : await fitnessEntity(row.entityId);
      if (space == null ||
          space.scopeAccountId != account ||
          space.storageMode != 'cloud' ||
          space.isStale ||
          row.ledgerId != null ||
          row.dayBookId != null ||
          row.memoBookId != null ||
          (row.entityType != 'fitness_space' &&
              (entity == null ||
                  entity.fitnessSpaceId != space.id ||
                  entity.entityType != row.entityType))) {
        throw StateError('FITNESS_SCOPE_CHANGED');
      }
      if (row.frozenRequest == null) {
        final payload = Map<String, dynamic>.from(
          jsonDecode(row.payload) as Map,
        );
        if (row.action == 'upsert' && row.entityType != 'fitness_space') {
          validateFitnessPayload(row.entityType, payload);
        }
        final wire = jsonEncode({
          'mutation_id': row.mutationId,
          'entity_type': row.entityType,
          'entity_id': row.entityId,
          'ledger_id': null,
          'day_book_id': null,
          'memo_book_id': null,
          'fitness_space_id': space.id,
          'sync_id': ?space.syncId,
          'base_revision': row.baseRevision ?? 0,
          'action': row.action,
          if (row.action == 'upsert' &&
              entity != null &&
              (row.baseRevision ?? 0) == 0 &&
              entity.deletedAt != null)
            'deleted_at': entity.deletedAt!.toUtc().toIso8601String(),
          'updated_at': row.updatedAt.toUtc().toIso8601String(),
          'payload': row.action == 'delete' && row.entityType != 'fitness_space'
              ? <String, dynamic>{}
              : payload,
        });
        _runtime.changeCodec.fitnessChangeFromFrozen(wire);
        await (_runtime.db.update(_runtime.db.syncChanges)
              ..where((c) => c.id.equals(row.id)))
            .write(SyncChangesCompanion(frozenRequest: d.Value(wire)));
      }
      result = await (_runtime.db.select(
        _runtime.db.syncChanges,
      )..where((c) => c.id.equals(row.id))).getSingle();
    });
    return result;
  }

  /// 执行applyFitnessPushOutcome对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyFitnessPushOutcome(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  ) async {
    if (change.entityType == 'fitness_space') {
      await applyFitnessSpacePushOutcome(change, outcome, account);
      return;
    }
    final entity = await fitnessEntity(change.entityId);
    if (entity == null ||
        entity.scopeAccountId != account ||
        entity.entityType != change.entityType) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    switch (outcome.status) {
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
          PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
        final revision = outcome.revision;
        final syncId = outcome.syncId;
        if (revision == null ||
            revision < 1 ||
            syncId == null ||
            (entity.syncId != null && entity.syncId != syncId)) {
          throw const FormatException('FITNESS_OUTCOME_VERSION');
        }
        // 响应不能覆盖请求飞行期间的动作输入、结束/重新开始或休息计时。
        await (_runtime.db.update(
          _runtime.db.fitnessEntities,
        )..where((e) => e.id.equals(entity.id))).write(
          FitnessEntitiesCompanion(
            syncId: d.Value(syncId),
            serverRevision: d.Value(
              revision > (entity.serverRevision ?? 0)
                  ? revision
                  : entity.serverRevision,
            ),
          ),
        );
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
        final wire = _runtime.modelMap(
          outcome,
          PostSyncPush200ResponseOutcomesInner.serializer,
        );
        final blocking = wire['blocking_entity'];
        final remote = Map<String, dynamic>.from(
          blocking as Map? ?? outcome.currentEntity?.value as Map? ?? {},
        );
        if (blocking == null) {
          if (outcome.currentDeleted == true) remote['deleted'] = true;
          remote['revision'] = outcome.currentRevision;
        }
        await fitnessConflict(entity, remote, account, head: change);
        await refreshFitnessCompleteness(account);
      default:
        throw const FormatException('FITNESS_OUTCOME_STATUS');
    }
  }

  /// OPEN 冲突保存最新本机事实与完整远端事实；待用户决策前不覆盖活跃输入。
  Future<void> fitnessConflict(
    FitnessEntityRow local,
    Map<String, dynamic> remote,
    String account, {
    SyncChange? head,
  }) async {
    if (local.scopeAccountId != account) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    final revision = remote['revision'];
    if (revision is! int || revision < 1) {
      throw const FormatException('FITNESS_CONFLICT_VERSION');
    }
    head ??= await _runtime.pendingChange(local.entityType, local.id, account);
    final open =
        await (_runtime.db.select(_runtime.db.syncConflicts)..where(
              (c) =>
                  c.accountId.equals(account) &
                  c.entityType.equals(local.entityType) &
                  c.entityId.equals(local.id) &
                  c.status.equals('OPEN'),
            ))
            .get();
    // 每个本机实体只能有一个 OPEN 冲突；保留旧阻塞场次快照供备份追溯。
    var existing = open.firstOrNull;
    if (existing != null &&
        (jsonDecode(existing.remotePayload) as Map)['id'] != remote['id']) {
      await (_runtime.db.update(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(existing!.id))).write(
        SyncConflictsCompanion(
          status: const d.Value('RESOLVED_REMOTE'),
          localMutationId: d.Value(
            'fitness-superseded:${existing.localMutationId}',
          ),
        ),
      );
      existing = null;
    }
    if (existing != null &&
        existing.remoteRevision > revision &&
        (jsonDecode(existing.remotePayload) as Map)['id'] == remote['id']) {
      return;
    }
    await _runtime.upsertConflict(
      fitnessSpaceId: local.fitnessSpaceId,
      entityType: local.entityType,
      entityId: local.id,
      localPayload: jsonEncode({
        ...jsonDecode(local.payload) as Map<String, dynamic>,
        if (local.deletedAt != null) 'deleted': true,
      }),
      remotePayload: jsonEncode(remote),
      baseRevision: head?.baseRevision ?? local.serverRevision,
      remoteRevision: revision,
      localMutationId: head?.mutationId ?? 'fitness-pull:${local.id}',
    );
  }

  /// 执行resolveFitnessConflict对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> resolveFitnessConflict(
    SyncConflict conflict,
    String? account, {
    required bool keepLocal,
  }) async {
    if (account == null || conflict.accountId != account) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    await _runtime.inAccountTransaction(account, () async {
      final fresh = await (_runtime.db.select(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(conflict.id))).getSingle();
      if (fresh.status != 'OPEN' ||
          fresh.remotePayload != conflict.remotePayload) {
        throw StateError('FITNESS_CONFLICT_CHANGED');
      }
      final local = await fitnessEntity(conflict.entityId);
      if (local == null || local.scopeAccountId != account) {
        throw StateError('FITNESS_SCOPE_CHANGED');
      }
      final remote = Map<String, dynamic>.from(
        jsonDecode(conflict.remotePayload) as Map,
      );
      final remoteId = remote['id'] as String? ?? local.id;
      if (remoteId != local.id && keepLocal) {
        throw StateError('FITNESS_OTHER_WORKOUT_RUNNING');
      }
      final wallTime = DateTime.fromMillisecondsSinceEpoch(
        DateTime.now().millisecondsSinceEpoch,
        isUtc: true,
      );
      final now = wallTime.isAfter(local.updatedAt)
          ? wallTime
          : local.updatedAt.add(const Duration(milliseconds: 1));
      await (_runtime.db.delete(_runtime.db.syncChanges)..where(
            (c) =>
                c.accountId.equals(account) &
                c.entityType.equals(local.entityType) &
                c.entityId.equals(local.id) &
                c.pushedAt.isNull(),
          ))
          .go();
      if (remoteId != local.id) {
        // 跨场选择云端是明确结束本机训练，不丢弃组数据，也不累计结束后的间隔。
        final payload = Map<String, dynamic>.from(
          jsonDecode(local.payload) as Map,
        );
        payload['status'] = 'completed';
        payload['rest_timer'] = null;
        payload['updated_at'] = now.toIso8601String();
        for (final segment in (payload['run_segments'] as List).cast<Map>()) {
          if (segment['ended_at'] == null) {
            final started = DateTime.parse(segment['started_at'] as String);
            segment['ended_at'] = (now.isBefore(started) ? started : now)
                .toIso8601String();
          }
        }
        validateFitnessPayload(local.entityType, payload);
        await (_runtime.db.update(
          _runtime.db.fitnessEntities,
        )..where((e) => e.id.equals(local.id))).write(
          FitnessEntitiesCompanion(
            payload: d.Value(jsonEncode(payload)),
            updatedAt: d.Value(now),
          ),
        );
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: local.entityType,
                entityId: local.id,
                accountId: d.Value(account),
                fitnessSpaceId: d.Value(local.fitnessSpaceId),
                action: 'upsert',
                payload: jsonEncode(payload),
                updatedAt: now,
                mutationId: const Uuid().v4(),
                baseRevision: d.Value(local.serverRevision ?? 0),
              ),
            );
        await writeFitnessRemote(local.entityType, remoteId, remote, account);
      } else if (keepLocal) {
        if (remote['deleted'] == true || remote['deleted_at'] != null) {
          throw StateError('FITNESS_REMOTE_DELETED');
        }
        final syncId = remote['sync_id'] as String?;
        if (syncId == null) {
          throw const FormatException('FITNESS_REMOTE_BINDING');
        }
        await (_runtime.db.update(
          _runtime.db.fitnessEntities,
        )..where((e) => e.id.equals(local.id))).write(
          FitnessEntitiesCompanion(
            syncId: d.Value(syncId),
            serverRevision: d.Value(conflict.remoteRevision),
            isStale: const d.Value(false),
          ),
        );
        await _runtime.db
            .into(_runtime.db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: local.entityType,
                entityId: local.id,
                accountId: d.Value(account),
                fitnessSpaceId: d.Value(local.fitnessSpaceId),
                action: local.deletedAt == null ? 'upsert' : 'delete',
                payload: local.payload,
                updatedAt: local.updatedAt,
                mutationId: const Uuid().v4(),
                baseRevision: d.Value(conflict.remoteRevision),
              ),
            );
      } else {
        await writeFitnessRemote(local.entityType, local.id, remote, account);
      }
      await (_runtime.db.update(
        _runtime.db.syncConflicts,
      )..where((c) => c.id.equals(conflict.id))).write(
        SyncConflictsCompanion(
          status: d.Value(keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE'),
          resolvedAt: d.Value(now),
        ),
      );
      await refreshFitnessCompleteness(account);
    });
  }

  /// 执行applyFitnessSpacePayload对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyFitnessSpacePayload(
    String id,
    Map<String, dynamic> payload,
    String account,
  ) async {
    final local = await fitnessSpace(id);
    if (local != null &&
        (local.scopeAccountId != account || local.storageMode != 'cloud')) {
      throw StateError('FITNESS_SCOPE');
    }
    if (local?.isStale == true) return;
    if (payload['deleted'] == true || payload['deleted_at'] != null) {
      await protectFitnessSpace(id, account, deleted: true);
      return;
    }
    final remote = _runtime.deser(
      jsonEncode(payload),
      GetSyncFitnessSpacesFull200ResponseFitnessSpace.serializer,
    );
    if (remote.id != id || remote.revision < 1 || !isValidName(remote.name)) {
      throw const FormatException('FITNESS_SPACE_PAYLOAD');
    }
    if (local?.syncId != null && local!.syncId != remote.syncId) {
      await protectFitnessSpace(id, account, stale: true);
      return;
    }
    if (local != null && remote.revision <= (local.serverRevision ?? 0)) return;
    final head = await _runtime.pendingChange('fitness_space', id, account);
    if (head != null) {
      if (head.frozenRequest == null) {
        await fitnessSpaceConflict(head, payload, account);
      }
      if (local?.syncId == null) {
        await (_runtime.db.update(
          _runtime.db.fitnessSpaces,
        )..where((b) => b.id.equals(id))).write(
          FitnessSpacesCompanion(
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
          ),
        );
      }
      return;
    }
    await _runtime.db
        .into(_runtime.db.fitnessSpaces)
        .insertOnConflictUpdate(
          FitnessSpacesCompanion.insert(
            id: id,
            name: normalizeName(remote.name),
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(account),
            syncId: d.Value(remote.syncId),
            serverRevision: d.Value(remote.revision),
            createdAt: remote.createdAt,
            updatedAt:
                local != null && local.updatedAt.isAfter(remote.updatedAt)
                ? local.updatedAt
                : remote.updatedAt,
          ),
        );
  }

  /// 执行fitnessSpaceConflict对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> fitnessSpaceConflict(
    SyncChange head,
    Map<String, dynamic> remote,
    String account,
  ) => _runtime.privateBookConflict(head, remote, account);

  /// 执行applyFitnessSpacePushOutcome对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyFitnessSpacePushOutcome(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  ) async {
    final book = await fitnessSpace(change.entityId);
    if (book == null || book.scopeAccountId != account) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    switch (outcome.status) {
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted ||
          PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored:
        await _runtime.ackPrivateBook(
          change,
          outcome,
          account,
          book: fitnessSpaceFromRow(book),
          table: _runtime.db.fitnessSpaces,
          contents: _runtime.db.fitnessEntities,
          parentColumn: 'fitness_space_id',
          contentBinding: true,
        );
      case PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict:
        await _runtime.privateBookConflict(
          change,
          _runtime.privateBookConflictPayload(outcome),
          account,
        );
      default:
        throw const FormatException('FITNESS_OUTCOME_STATUS');
    }
  }

  /// 执行protectFitnessSpace对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> protectFitnessSpace(
    String id,
    String account, {
    bool stale = false,
    bool deleted = false,
  }) async {
    final book = await fitnessSpace(id);
    if (book == null) return;
    if (book.scopeAccountId != account) throw StateError('数据不属于当前账号');
    await _ports.operationsQuarantinePrivateBook(
      SyncTarget('fitness_space', id),
      account,
      stale: stale,
      deleted: deleted,
      book: fitnessSpaceFromRow(book),
      table: _runtime.db.fitnessSpaces,
      contents: _runtime.db.fitnessEntities,
      parentColumn: 'fitness_space_id',
      protect: (branch) async {
        await fitnessSpaceRepository.copyToLocalForAccountExit(
          id,
          'scope-protection:$id:$branch',
        );
      },
    );
  }

  /// 执行fitnessSpaceRepository对应的同步步骤，沿用所属域的身份与事务规则。
  FitnessSpaceRepository get fitnessSpaceRepository => FitnessSpaceRepository(
    _runtime.db,
    accountIdGetter: () => _runtime.currentAccountIdGetter(),
    generationGetter: () => _runtime.sessionGenerationGetter?.call() ?? 0,
    changeRecorder: ChangeRecorderImpl(
      _runtime.db,
      accountIdGetter: () => _runtime.currentAccountIdGetter(),
    ),
  );
}

/// 健身空间与实体的版本化同步和完整性维护所需的外部协作端口。
class FitnessSyncHandlerPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const FitnessSyncHandlerPorts({
    required this.operationsQuarantinePrivateBook,
    required this.pushApplyPendingOutcome,
  });

  /// 委托operations域执行quarantinePrivateBook。
  final Future<void> Function(
    SyncTarget target,
    String account, {
    required bool stale,
    required bool deleted,
    required private_books.PrivateBook book,
    required d.TableInfo table,
    required d.TableInfo contents,
    required String parentColumn,
    required Future<void> Function(String branch) protect,
  })
  operationsQuarantinePrivateBook;

  /// 委托push域执行applyPendingOutcome。
  final Future<void> Function(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  )
  pushApplyPendingOutcome;
}
