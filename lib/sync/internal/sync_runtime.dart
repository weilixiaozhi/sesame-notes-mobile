import 'dart:convert';
import 'package:sesame_notes/data/models/private_book.dart' as private_books;
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as d;
import 'package:built_value/serializer.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/sync_change_codec.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/sync/storage/sync_rejection_recovery.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/sync/models/sync_domain.dart';

/// 共享协议编解码、账号守卫、游标与原子写入基础能力。
class SyncRuntime {
  /// 固定本次服务创建时的会话代次，不能在首次请求时重新绑定身份。
  SyncRuntime({
    required this.client,
    required this.db,
    required this.deviceId,
    required this.currentAccountIdGetter,
    required this.sessionGenerationGetter,
    required int? generation,
    this.apiOverride,
  }) : _sessionGeneration = generation;
  final SesameApiClient client;
  final SesameDatabase db;
  final String deviceId;
  final SyncApi? apiOverride;
  final String? Function() currentAccountIdGetter;
  final int Function()? sessionGenerationGetter;
  final int? _sessionGeneration;

  /// 各域冻结校验与重试读取共享当前客户端的协议转换能力。
  late final SyncChangeCodec changeCodec = SyncChangeCodec(client.serializers);

  /// 拒收后的重新登记与依赖恢复共用一套会话隔离事务。
  late final SyncRejectionRecovery rejectionRecovery = SyncRejectionRecovery(
    db,
    transaction: inAccountTransaction,
  );

  /// 执行scopeConflicts对应的同步步骤，沿用所属域的身份与事务规则。
  d.Expression<bool> scopeConflicts(SyncConflicts c, SyncTarget target) =>
      switch (target.type) {
        'ledger' => c.ledgerId.equals(target.id),
        'day_book' => c.dayBookId.equals(target.id),
        'memo_book' => c.memoBookId.equals(target.id),
        'fitness_space' => c.fitnessSpaceId.equals(target.id),
        _ => c.entityType.equals(target.type) & c.entityId.equals(target.id),
      };

  /// 执行scopeChanges对应的同步步骤，沿用所属域的身份与事务规则。
  d.Expression<bool> scopeChanges(SyncChanges c, SyncTarget target) =>
      switch (target.type) {
        'ledger' => c.ledgerId.equals(target.id),
        'day_book' => c.dayBookId.equals(target.id),
        'memo_book' => c.memoBookId.equals(target.id),
        'fitness_space' => c.fitnessSpaceId.equals(target.id),
        _ => c.entityType.equals(target.type) & c.entityId.equals(target.id),
      };

  /// 生成模型负责 HTTP 解码，此处只转换已经校验类型的业务投影。
  Map<String, dynamic> modelMap<T>(T value, Serializer<T> serializer) =>
      Map<String, dynamic>.from(
        client.serializers.serialize(
              value,
              specifiedType: FullType(serializer.types.first),
            )!
            as Map,
      );

  /// 读取账号与设备组成的唯一水位行。
  Future<SyncStateData?> domainState() =>
      (db.select(db.syncState)..where(
            (s) =>
                s.accountId.equals(
                  currentAccountIdForCloudOperation('读取同步进度'),
                ) &
                s.deviceId.equals(deviceId),
          ))
          .getSingleOrNull();

  /// 只把失败载荷保存在账号隔离的诊断表，普通日志不输出用户内容。
  Future<void> rememberDomainFailure(
    GetSyncPull200ResponseChangesInner change,
    String accountId,
    Object error,
    StackTrace stackTrace,
  ) async {
    final now = DateTime.now().toUtc();
    await inAccountTransaction(accountId, () async {
      if (change.fitnessSpaceId != null) {
        await (db.update(db.fitnessSpaces)..where(
              (s) =>
                  s.id.equals(change.fitnessSpaceId!) &
                  s.scopeAccountId.equals(accountId),
            ))
            .write(const FitnessSpacesCompanion(isStale: d.Value(true)));
      }
      final old =
          await (db.select(db.syncPullErrors)..where(
                (e) =>
                    e.changeId.equals(change.changeId) &
                    e.accountId.equals(accountId),
              ))
              .getSingleOrNull();
      if (old == null) {
        await db
            .into(db.syncPullErrors)
            .insert(
              SyncPullErrorsCompanion.insert(
                changeId: change.changeId,
                accountId: d.Value(accountId),
                dayBookId: d.Value(change.dayBookId),
                memoBookId: d.Value(change.memoBookId),
                fitnessSpaceId: d.Value(change.fitnessSpaceId),
                ledgerId: d.Value(change.ledgerId),
                entityType:
                    modelMap(
                          change,
                          GetSyncPull200ResponseChangesInner.serializer,
                        )['entity_type']
                        as String,
                entityId: change.entityId,
                action: change.action.name,
                rawChangeJson: jsonEncode(
                  modelMap(
                    change,
                    GetSyncPull200ResponseChangesInner.serializer,
                  ),
                ),
                errorClass: d.Value(error.runtimeType.toString()),
                stackTrace: d.Value(stackTrace.toString()),
                firstSeenAt: now,
                lastAttemptAt: now,
              ),
            );
      } else {
        await (db.update(
          db.syncPullErrors,
        )..where((e) => e.id.equals(old.id))).write(
          SyncPullErrorsCompanion(
            lastAttemptAt: d.Value(now),
            attemptCount: d.Value(old.attemptCount + 1),
          ),
        );
      }
    });
  }

  /// 该域已提交的消费水位；单域水位列缺失时视为尚未消费。
  String? domainCursor(SyncStateData? state, SyncDomain domain) =>
      switch (domain) {
        SyncDomain.accounting => state?.serverCursor,
        SyncDomain.days => state?.dayEventsCursor,
        SyncDomain.memos => state?.memosCursor,
        SyncDomain.fitness => state?.fitnessCursor,
      };

  /// 水位只前进：乱序或并发响应不得把已提交的进度改小。
  String advanceCursor(String? previous, String cursor) =>
      previous != null && BigInt.parse(previous) > BigInt.parse(cursor)
      ? previous
      : cursor;

  /// 写入单域水位，不改动其他域的列；账号与设备组成唯一状态行。
  ///
  /// `monotonic` 为真表示"消费型推进"：乱序或并发响应不得回退已提交进度；
  /// 为假表示"权威快照水位"：快照值就是当前进度，允许低于本地残留值。
  Future<void> writeDomainCursor(
    SyncDomain domain,
    String cursor,
    String account, {
    required bool monotonic,
  }) async {
    final state = await domainState();
    final next = monotonic
        ? advanceCursor(domainCursor(state, domain), cursor)
        : cursor;
    await db
        .into(db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            deviceId: deviceId,
            accountId: d.Value(account),
            serverCursor: domain == SyncDomain.accounting
                ? d.Value(next)
                : const d.Value.absent(),
            dayEventsCursor: domain == SyncDomain.days
                ? d.Value(next)
                : const d.Value.absent(),
            memosCursor: domain == SyncDomain.memos
                ? d.Value(next)
                : const d.Value.absent(),
            fitnessCursor: domain == SyncDomain.fitness
                ? d.Value(next)
                : const d.Value.absent(),
            lastPullAt: d.Value(DateTime.now().toUtc()),
          ),
        );
  }

  /// 消费型水位推进：day/memo/fitness 的增量消费共用同一条只前进规则。
  Future<void> saveDomainCursor(
    SyncDomain domain,
    String cursor,
    String account,
  ) => writeDomainCursor(domain, cursor, account, monotonic: true);

  /// 解码私有本及其内容的冲突事实，只有明确的零版本墓碑表示云端不存在。
  Map<String, dynamic> privateBookConflictPayload(
    PostSyncPush200ResponseOutcomesInner outcome,
  ) {
    try {
      final revision = outcome.currentRevision;
      final deleted = outcome.currentDeleted;
      final entity = outcome.currentEntity?.value;
      if (revision == null || revision < 0 || deleted == null) {
        throw const FormatException('私有本冲突缺少版本或删除状态');
      }
      if (revision == 0) {
        if (!deleted || entity != null) {
          throw const FormatException('私有本零版本冲突不是明确的云端缺失');
        }
        return {'revision': 0, 'deleted': true};
      }
      if (entity is! Map ||
          entity['id'] != outcome.entityId ||
          entity['revision'] != revision ||
          (entity['deleted_at'] != null) != deleted) {
        throw const FormatException('私有本冲突快照与确认事实不一致');
      }
      return {
        ...Map<String, dynamic>.from(entity),
        if (deleted) 'deleted': true,
      };
    } on FormatException catch (error, stackTrace) {
      // 保留安全原因与协议位置，详细日志由同步边界记录，正文和凭据不进入异常。
      Error.throwWithStackTrace(
        FormatException(
          '${error.message}：entity=${outcome.entityId}，mutation=${outcome.mutationId}',
        ),
        stackTrace,
      );
    }
  }

  /// 冲突统一留在全局处理队列，未作选择前不覆盖本机内容。
  Future<void> privateBookConflict(
    SyncChange head,
    Map<String, dynamic> remote,
    String accountId,
  ) async {
    final tail = await pendingChange(
      head.entityType,
      head.entityId,
      accountId,
      tail: true,
    );
    if (tail == null) return;
    await upsertConflict(
      memoBookId: head.memoBookId,
      fitnessSpaceId: head.fitnessSpaceId,
      entityType: head.entityType,
      entityId: head.entityId,
      localPayload: tail.action == 'delete'
          ? jsonEncode({
              'deleted': true,
              ...jsonDecode(tail.payload) as Map<String, dynamic>,
            })
          : tail.payload,
      remotePayload: jsonEncode(remote),
      baseRevision: head.baseRevision,
      remoteRevision: remote['revision'] as int,
      localMutationId: head.mutationId,
    );
  }

  /// 父本创建/恢复建立绑定，删除退休同本未发送意图；各私有域使用相同确认规则。
  Future<void> ackPrivateBook(
    SyncChange change,
    PostSyncPush200ResponseOutcomesInner outcome,
    String account, {
    required private_books.PrivateBook book,
    required d.TableInfo table,
    required d.TableInfo contents,
    required String parentColumn,
    bool contentBinding = false,
  }) async {
    final restoring =
        change.action == 'upsert' &&
        (jsonDecode(change.payload) as Map)['restore'] == true;
    final revision = outcome.revision, syncId = outcome.syncId;
    if (revision == null ||
        revision < 1 ||
        syncId == null ||
        (!restoring && book.syncId != null && book.syncId != syncId)) {
      throw const FormatException('BOOK_OUTCOME_VERSION');
    }
    final now = DateTime.now().toUtc();
    final values = <String, Object?>{
      'sync_id': syncId,
      'server_revision': restoring || revision > (book.serverRevision ?? 0)
          ? revision
          : book.serverRevision,
      if (restoring || (book.syncId == null && change.action == 'upsert'))
        'full_cursor': outcome.changeId,
      if (change.action == 'delete') 'deleted_at': now.millisecondsSinceEpoch,
      if (change.action == 'delete') 'pending_local_delete': 0,
    };
    await db.customUpdate(
      'UPDATE ${table.actualTableName} SET ${values.keys.map((key) => '$key=?').join(',')} WHERE id=?',
      variables: [
        for (final value in values.values) d.Variable(value),
        d.Variable(book.id),
      ],
      updates: {table},
    );
    if (contentBinding) {
      await db.customUpdate(
        'UPDATE ${contents.actualTableName} SET sync_id=? WHERE $parentColumn=?',
        variables: [d.Variable(syncId), d.Variable(book.id)],
        updates: {contents},
      );
    }
    if (change.action == 'delete') {
      await db.customUpdate(
        'UPDATE ${contents.actualTableName} SET deleted_at=? WHERE $parentColumn=?',
        variables: [
          d.Variable(now.millisecondsSinceEpoch),
          d.Variable(book.id),
        ],
        updates: {contents},
      );
      await db.customUpdate(
        'UPDATE sync_changes SET pushed_at=? WHERE account_id=? AND $parentColumn=? AND pushed_at IS NULL AND frozen_request IS NULL',
        variables: [
          d.Variable(now.millisecondsSinceEpoch ~/ 1000),
          d.Variable(account),
          d.Variable(book.id),
        ],
        updates: {db.syncChanges},
      );
    }
  }

  /// 执行api对应的同步步骤，沿用所属域的身份与事务规则。
  SyncApi get api => apiOverride ?? SyncApi(client.dio, client.serializers);

  /// 读取云同步操作绑定的账号域。
  ///
  /// 账号缺失或读取异常时失败关闭：停止落库，避免把云端数据写进本地域，
  /// 或生成下一次 push 永远选不中的 mutation。
  String currentAccountIdForCloudOperation(String operation) {
    try {
      final accountId = currentAccountIdGetter();
      if (sessionGenerationGetter?.call() != _sessionGeneration) {
        throw StateError('登录会话已变化，请重新操作');
      }
      if (accountId == null || accountId.isEmpty) {
        throw StateError('当前未登录，无法$operation');
      }
      return accountId;
    } catch (error) {
      // 中间层只保留操作上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error(
        'SyncService',
        '读取当前账号失败，已取消$operation',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 账号变化时回滚整个决策或快照，防止认证失效清理期间的迟到结果回写。
  Future<void> inAccountTransaction(
    String? accountId,
    Future<void> Function() action,
  ) async {
    try {
      await db.transaction(() async {
        requireAccount(accountId);
        await action();
        // 数据库等待期间会话也可能失效；在提交边界复核才能让所有写入一起回滚。
        requireAccount(accountId);
      });
    } catch (error) {
      // 中间层只保留事务上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error('SyncService', '同步结果事务未提交', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 请求与落库均绑定发起时的账号；认证失效或换号后停止继续同步。
  void requireAccount(String? accountId) {
    if (currentAccountIdForCloudOperation('提交同步结果') != accountId) {
      throw StateError('账号已变更，请重新操作');
    }
  }

  /// 创建或更新实体的 OPEN 冲突记录（同一实体冲突唯一，解决前不重复创建）。
  Future<void> upsertConflict({
    String? ledgerId,
    String? dayBookId,
    String? memoBookId,
    String? fitnessSpaceId,
    required String entityType,
    required String entityId,
    required String localPayload,
    required int? baseRevision,
    required int? remoteRevision,
    required String remotePayload,
    required String localMutationId,
  }) async {
    final accountId = currentAccountIdForCloudOperation('保存同步冲突');
    final existing =
        await (db.select(db.syncConflicts)..where(
              (c) =>
                  c.entityType.equals(entityType) &
                  c.entityId.equals(entityId) &
                  c.accountId.equals(accountId) &
                  c.status.equals('OPEN'),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    await db
        .into(db.syncConflicts)
        .insertOnConflictUpdate(
          SyncConflictsCompanion.insert(
            id: existing?.id ?? const Uuid().v4(),
            ledgerId: d.Value(ledgerId),
            dayBookId: d.Value(dayBookId),
            memoBookId: d.Value(memoBookId),
            fitnessSpaceId: d.Value(fitnessSpaceId),
            accountId: d.Value(accountId),
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

  /// 把本地 payload JSON 反序列化为生成模型的 payload 对象。
  T deser<T>(String json, Serializer<T> serializer) {
    return client.serializers.deserialize(
          jsonDecode(json),
          specifiedType: FullType(serializer.types.first),
        )
        as T;
  }

  /// 执行chunks对应的同步步骤，沿用所属域的身份与事务规则。
  List<List<SyncChange>> chunks(List<SyncChange> items, int size) {
    final out = <List<SyncChange>>[];
    for (var i = 0; i < items.length; i += size) {
      out.add(
        items.sublist(i, i + size > items.length ? items.length : i + size),
      );
    }
    return out;
  }

  /// 读取某实体在指定账号下的未推送变更链首条（`tail: true` 取最新一条）。
  ///
  /// 同一实体允许保留完整的 FIFO 变更链，因此只按 id 排序取一条，不要求唯一行；
  /// 首条用于冲突与冻结的基线判断，末条用于决策时读取最新本地内容。
  Future<SyncChange?> pendingChange(
    String type,
    String id,
    String accountId, {
    bool tail = false,
  }) =>
      (db.select(db.syncChanges)
            ..where(
              (c) =>
                  c.accountId.equals(accountId) &
                  c.entityType.equals(type) &
                  c.entityId.equals(id) &
                  c.pushedAt.isNull(),
            )
            ..orderBy([
              (c) =>
                  tail ? d.OrderingTerm.desc(c.id) : d.OrderingTerm.asc(c.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  /// 保存当前设备已完成应用的服务端游标。
  ///
  /// 账本域的完整快照本身就是权威进度，允许覆盖更超前的本地残留值。
  Future<void> saveServerCursor(String cursor) => writeDomainCursor(
    SyncDomain.accounting,
    cursor,
    currentAccountIdForCloudOperation('保存同步进度'),
    monotonic: false,
  );
}
