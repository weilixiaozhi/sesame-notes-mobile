import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/database_fingerprint.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/domain/fitness/fitness_recovery_branch.dart';
import 'package:sesame_notes/domain/fitness/fitness_custom_transfer.dart';

/// 导入、恢复和退出保护复制共用关系映射；所有内容与回执在同一事务中提交。
class FitnessDataTransfer {
  static Future<List<FitnessTransferRecord>> snapshot(
    SesameDatabase db, {
    required String fitnessSpaceId,
    String? accountId,
    bool requireComplete = true,
  }) async {
    final space = await (db.select(
      db.fitnessSpaces,
    )..where((b) => b.id.equals(fitnessSpaceId))).getSingle();
    if (space.storageMode == 'cloud' && space.scopeAccountId != accountId) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    if (requireComplete &&
        (space.isStale ||
            (space.storageMode == 'cloud' &&
                space.syncId != null &&
                space.fullCursor == null))) {
      throw StateError('FITNESS_INCOMPLETE');
    }
    if (requireComplete) {
      final conflicts =
          await (db.select(db.syncConflicts)..where(
                (c) =>
                    c.fitnessSpaceId.equals(fitnessSpaceId) &
                    c.status.equals('OPEN'),
              ))
              .get();
      if (conflicts.any((c) {
        final remote = jsonDecode(c.remotePayload) as Map;
        return remote['id'] != null && remote['id'] != c.entityId;
      })) {
        throw StateError('FITNESS_INCOMPLETE');
      }
    }
    final rows =
        await (db.select(db.fitnessEntities)
              ..where((e) => e.fitnessSpaceId.equals(fitnessSpaceId))
              ..orderBy([(e) => OrderingTerm.asc(e.id)]))
            .get();
    if (requireComplete && rows.any((r) => r.isStale)) {
      throw StateError('FITNESS_INCOMPLETE');
    }
    return [
      for (final row in rows)
        FitnessTransferRecord(
          id: row.id,
          entityType: row.entityType,
          fitnessSpaceId: fitnessSpaceId,
          payload: jsonDecode(row.payload) as Map<String, dynamic>,
          deletedAt: row.deletedAt,
        ),
    ];
  }

  static Future<String> fingerprint(
    SesameDatabase db,
    String fitnessSpaceId, {
    Future<void>? cancelled,
  }) async => (await fingerprints(db, [
    fitnessSpaceId,
  ], cancelled: cancelled))[fitnessSpaceId]!;

  static Future<Map<String, String>> fingerprints(
    SesameDatabase db,
    Iterable<String> ids, {
    Future<void>? cancelled,
  }) => fingerprintGroups(db, {
    for (final id in ids)
      id: [
        FingerprintTable('fitness_spaces', 'id', id),
        FingerprintTable('fitness_entities', 'fitness_space_id', id),
        FingerprintTable('fitness_import_receipts', 'fitness_space_id', id),
        FingerprintTable(
          'sync_conflicts',
          'fitness_space_id',
          id,
          filter:
              "status='OPEN' OR (resolved_at IS NULL AND (local_mutation_id LIKE 'fitness-recovery:%' OR local_mutation_id LIKE 'fitness-superseded:%'))",
        ),
      ],
  }, cancelled: cancelled);

  static Future<int> skipped(
    SesameDatabase db,
    FitnessTransferDocument document,
    String fitnessSpaceId,
  ) async {
    final receipts =
        await (db.select(db.fitnessImportReceipts)..where(
              (r) =>
                  r.fitnessSpaceId.equals(fitnessSpaceId) &
                  r.exportId.equals(document.exportId),
            ))
            .get();
    final keys = receipts.map((r) => '${r.entityType}:${r.sourceId}').toSet();
    return document.records
        .where((r) => keys.contains('${r.entityType}:${r.id}'))
        .length;
  }

  /// CSV 仅追加新身份；偏好替换由同一个导入预览明确确认，重试先查回执。
  static Future<({int imported, int skipped, Map<String, String> ids})>
  importDocument({
    required SesameDatabase db,
    required FitnessTransferDocument document,
    required String fitnessSpaceId,
    String? accountId,
    ChangeRecorder? changeRecorder,
    void Function()? validateContext,
    void Function(int, int)? onProgress,
    bool replaceContents = false,
    bool preserveIds = false,
    bool preservePreferenceSnapshot = false,
    List<Map<String, Object?>> receipts = const [],
    List<FitnessRecoveryBranch> branches = const [],
  }) => db.transaction(() async {
    validateContext?.call();
    FitnessTransferFormat.validateRecords(document.records);
    if (!FitnessTransferFormat.uuid.hasMatch(document.exportId) ||
        document.records.map((r) => r.fitnessSpaceId).toSet().length > 1) {
      throw const FormatException('fitness import scope or export id');
    }
    final space = await (db.select(
      db.fitnessSpaces,
    )..where((b) => b.id.equals(fitnessSpaceId))).getSingle();
    if (space.storageMode == 'cloud' && space.scopeAccountId != accountId) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    if (space.isStale ||
        (space.storageMode == 'cloud' &&
            space.syncId != null &&
            space.fullCursor == null)) {
      throw StateError('FITNESS_INCOMPLETE');
    }
    // 空间归属决定内容行与未确认分支的 scope；本机空间没有归属账号。
    final owner = space.scopeAccountId;
    final targetPreferences =
        await (db.select(db.fitnessEntities)..where(
              (r) =>
                  r.fitnessSpaceId.equals(fitnessSpaceId) &
                  r.entityType.equals('fitness_preferences') &
                  r.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    final targetCustom = replaceContents || targetPreferences == null
        ? <Map<String, dynamic>>[]
        : transferCustomExercises(
            jsonDecode(targetPreferences.payload) as Map<String, dynamic>,
          );
    final availableCustomIds = {
      for (final item in targetCustom) item['id'] as String,
      for (final record in document.records.where(
        (r) => r.entityType == 'fitness_preferences',
      ))
        for (final item in transferCustomExercises(record.payload))
          item['id'] as String,
    };
    if (replaceContents) await clearSpaceContents(db, fitnessSpaceId);
    final existingReceipts =
        await (db.select(db.fitnessImportReceipts)..where(
              (r) =>
                  r.fitnessSpaceId.equals(fitnessSpaceId) &
                  r.exportId.equals(document.exportId),
            ))
            .get();
    final bySource = {
      for (final r in existingReceipts)
        '${r.entityType}:${r.sourceId}': r.targetId,
    };
    final ids = <String, String>{};
    final collisions =
        (await (db.select(db.fitnessEntities)..where(
                  (e) =>
                      e.id.isIn(document.records.map((r) => r.id).toList()) &
                      e.fitnessSpaceId.equals(fitnessSpaceId).not(),
                ))
                .get())
            .map((e) => e.id)
            .toSet();
    final namespace = const Uuid().v5(
      Namespace.url.value,
      'fitness-import:$fitnessSpaceId:${document.exportId}',
    );
    // 同一文件可先导偏好、后导训练；复用前一次已落库的动作身份。
    for (final reference in {
      for (final record in document.records)
        ...transferCustomReferences(record.payload),
    }) {
      final importedId = 'custom:${const Uuid().v5(namespace, reference)}';
      if (!preserveIds && targetCustom.any((e) => e['id'] == importedId)) {
        ids[reference] = importedId;
      } else if (!availableCustomIds.contains(reference)) {
        throw const FormatException('自定义动作缺少定义，请同时选择对应的健身偏好或重新映射动作。');
      }
    }
    for (final r in document.records) {
      ids[r.id] =
          bySource['${r.entityType}:${r.id}'] ??
          (r.entityType == 'fitness_preferences'
              ? fitnessSpaceId
              : preserveIds && !collisions.contains(r.id)
              ? r.id
              : const Uuid().v5(namespace, r.id));
    }
    // 嵌套动作、组和计划安排均重新映射，同一计划的发生键使用相同安排身份。
    void collect(dynamic node) {
      if (node is List) {
        for (final v in node) {
          collect(v);
        }
      }
      if (node is! Map) return;
      // 已永久删除的来源仍有历史身份，必须与本次目标一起映射，避免跨账号派生出相同训练 ID。
      for (final field in ['id', 'source_plan_id', 'source_template_id']) {
        if (node[field] is String) {
          final id = node[field] as String;
          ids.putIfAbsent(
            id,
            () => preserveIds
                ? id
                : id.startsWith('custom:')
                ? 'custom:${const Uuid().v5(namespace, id)}'
                : const Uuid().v5(namespace, id),
          );
        }
      }
      if (node['occurrence_key'] is String) {
        for (final id
            in (node['occurrence_key'] as String)
                .split(':')
                .where(FitnessTransferFormat.uuid.hasMatch)) {
          ids.putIfAbsent(
            id,
            () => preserveIds ? id : const Uuid().v5(namespace, id),
          );
        }
      }
      for (final v in node.values) {
        collect(v);
      }
    }

    for (final r in document.records) {
      collect(r.payload);
    }
    final preservedBranches = [...branches];
    for (final branch in branches) {
      if (!ids.containsKey(branch.canonicalId) ||
          branch.fitnessSpaceId != document.records.first.fitnessSpaceId) {
        throw const FormatException('fitness recovery branch source');
      }
      validateFitnessPayload(branch.entityType, branch.payload);
      validateFitnessIdentity(
        branch.entityType,
        branch.entityId,
        branch.payload,
      );
      ids.putIfAbsent(
        branch.entityId,
        () => const Uuid().v5(namespace, branch.entityId),
      );
      collect(branch.payload);
    }
    for (final r in document.records.where(
      (r) =>
          r.entityType == 'fitness_workout' &&
          r.payload['source_kind'] == 'plan' &&
          !bySource.containsKey('${r.entityType}:${r.id}'),
    )) {
      final plan = r.payload['source_plan_id'] as String;
      final key = (r.payload['occurrence_key'] as String)
          .split(':')
          .map((part) => ids[part] ?? part)
          .join(':');
      ids[r.id] = const Uuid().v5(ids[plan] ?? plan, key);
    }
    for (final branch in branches.where(
      (b) =>
          b.entityType == 'fitness_workout' &&
          b.payload['source_kind'] == 'plan',
    )) {
      final plan = branch.payload['source_plan_id'] as String;
      final key = (branch.payload['occurrence_key'] as String)
          .split(':')
          .map((p) => ids[p] ?? p)
          .join(':');
      ids[branch.entityId] = const Uuid().v5(ids[plan] ?? plan, key);
    }
    dynamic remap(dynamic node, [String? field]) {
      if (node is List) return [for (final v in node) remap(v, field)];
      if (node is Map) {
        return <String, dynamic>{
          for (final e in node.entries)
            (field == 'exercise_rest_settings' ||
                        field == 'exercise_weight_modes'
                    ? ids[e.key] ?? e.key
                    : e.key)
                as String: remap(
              e.value,
              e.key as String,
            ),
        };
      }
      if (node is String &&
          {
            'id',
            'source_plan_id',
            'source_template_id',
            'exercise_id',
            'set_id',
            'pinned_exercise_ids',
          }.contains(field)) {
        return ids[node] ?? node;
      }
      if (node is String && field == 'occurrence_key') {
        return node.split(':').map((s) => ids[s] ?? s).join(':');
      }
      return node;
    }

    var imported = 0;
    var skipped = 0;
    final now = DateTime.fromMillisecondsSinceEpoch(
      DateTime.now().millisecondsSinceEpoch,
      isUtc: true,
    );
    for (final r in document.records) {
      validateContext?.call();
      if (bySource.containsKey('${r.entityType}:${r.id}')) {
        skipped++;
        onProgress?.call(imported + skipped, document.records.length);
        continue;
      }
      final payload =
          remap(normalizeFitnessNames(r.payload)) as Map<String, dynamic>;
      // 替换训练偏好时保留目标已有自定义动作，避免原有训练失去名称和图片。
      if (r.entityType == 'fitness_preferences' &&
          !replaceContents &&
          !preservePreferenceSnapshot &&
          targetCustom.isNotEmpty) {
        payload['custom_exercises'] = {
          for (final item in targetCustom) item['id']: item,
          for (final item in transferCustomExercises(payload)) item['id']: item,
        }.values.toList();
      }
      final deletedAt = r.deletedAt;
      final id = ids[r.id]!;
      final previous = await (db.select(
        db.fitnessEntities,
      )..where((e) => e.id.equals(id))).getSingleOrNull();
      if (previous != null &&
          (previous.fitnessSpaceId != fitnessSpaceId ||
              previous.entityType != r.entityType ||
              r.entityType != 'fitness_preferences')) {
        throw StateError('FITNESS_IMPORT_ID_COLLISION');
      }
      final preserve =
          preservePreferenceSnapshot &&
          previous != null &&
          previous.deletedAt == null &&
          r.entityType == 'fitness_preferences';
      if (preserve) {
        preservedBranches.add(
          FitnessRecoveryBranch(
            fitnessSpaceId: r.fitnessSpaceId,
            entityType: r.entityType,
            canonicalId: r.id,
            entityId: r.id,
            payload: r.payload,
            deletedAt: deletedAt,
            kind: 'conflict_remote',
            operationId: 'preference:${document.exportId}:${r.id}',
            revision: 0,
            accountId: owner,
          ),
        );
      } else {
        if (previous != null && owner != null) {
          if (previous.deletedAt != null && deletedAt == null) {
            throw StateError('FITNESS_PREFERENCES_DELETED');
          }
          payload['created_at'] = wireTimestamp(previous.createdAt);
          payload['updated_at'] = wireTimestamp(
            now.isAfter(previous.updatedAt)
                ? now
                : previous.updatedAt.add(const Duration(milliseconds: 1)),
          );
        }
        validateFitnessPayload(r.entityType, payload);
        validateFitnessIdentity(r.entityType, id, payload);
        await db
            .into(db.fitnessEntities)
            .insertOnConflictUpdate(
              FitnessEntitiesCompanion.insert(
                id: id,
                entityType: r.entityType,
                fitnessSpaceId: fitnessSpaceId,
                payload: jsonEncode(payload),
                scopeAccountId: Value(owner),
                storageMode: Value(space.storageMode),
                syncId: Value(space.syncId),
                serverRevision: Value(
                  owner == null ? null : previous?.serverRevision ?? 0,
                ),
                createdAt: DateTime.parse(payload['created_at'] as String),
                updatedAt: DateTime.parse(payload['updated_at'] as String),
                deletedAt: Value(deletedAt),
              ),
            );
        if (owner != null) {
          if (changeRecorder == null) {
            throw StateError('FITNESS_SYNC_UNAVAILABLE');
          }
          await changeRecorder.recordFitnessChange(
            entityType: r.entityType,
            entityId: id,
            accountId: owner,
            fitnessSpaceId: fitnessSpaceId,
            action: deletedAt == null || previous == null ? 'upsert' : 'delete',
            payload: jsonEncode(payload),
            updatedAt: now,
            baseRevision: previous?.serverRevision ?? 0,
          );
        }
      }
      await db
          .into(db.fitnessImportReceipts)
          .insert(
            FitnessImportReceiptsCompanion.insert(
              fitnessSpaceId: fitnessSpaceId,
              exportId: document.exportId,
              entityType: r.entityType,
              sourceId: r.id,
              targetId: id,
              importedAt: now,
            ),
          );
      imported++;
      onProgress?.call(imported + skipped, document.records.length);
    }
    for (final branch in preservedBranches) {
      validateContext?.call();
      final targetId = ids[branch.canonicalId]!;
      final target = await (db.select(
        db.fitnessEntities,
      )..where((r) => r.id.equals(targetId))).getSingle();
      final id = const Uuid().v5(
        namespace,
        'branch:${branch.canonicalId}:${branch.operationId}',
      );
      final mapped = remap(branch.payload) as Map<String, dynamic>;
      validateFitnessPayload(branch.entityType, mapped);
      validateFitnessIdentity(branch.entityType, ids[branch.entityId]!, mapped);
      if (await (db.select(
            db.syncConflicts,
          )..where((r) => r.id.equals(id))).getSingleOrNull() !=
          null) {
        continue;
      }
      await db
          .into(db.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: id,
              entityType: branch.entityType,
              fitnessSpaceId: Value(fitnessSpaceId),
              accountId: Value(branch.accountId ?? owner),

              entityId: targetId,
              localPayload: jsonEncode({
                ...jsonDecode(target.payload) as Map<String, dynamic>,
                if (target.deletedAt != null) 'deleted': true,
              }),
              remotePayload: jsonEncode(
                branch.recoveryPayload(
                  id: ids[branch.entityId]!,
                  mappedPayload: mapped,
                ),
              ),
              baseRevision: 0,
              remoteRevision: branch.revision,
              localMutationId: 'fitness-recovery:$id',
              status: const Value('RESOLVED_REMOTE'),
            ),
          );
    }
    for (final receipt in receipts) {
      final target = ids[receipt['target_id']];
      if (target == null) throw const FormatException('fitness receipt target');
      await db
          .into(db.fitnessImportReceipts)
          .insert(
            FitnessImportReceiptsCompanion.insert(
              fitnessSpaceId: fitnessSpaceId,
              exportId: receipt['export_id'] as String,
              entityType: receipt['entity_type'] as String,
              sourceId: receipt['source_id'] as String,
              targetId: target,
              importedAt: DateTime.fromMillisecondsSinceEpoch(
                receipt['imported_at'] as int,
                isUtc: true,
              ),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
    validateContext?.call();
    return (imported: imported, skipped: skipped, ids: ids);
  });

  /// 单本恢复只清理目标空间，其他空间及账号数据不受影响。
  static Future<void> clearSpaceContents(SesameDatabase db, String id) async {
    for (final table in <TableInfo>[
      db.syncConflicts,
      db.syncChanges,
      db.syncPullErrors,
      db.fitnessImportReceipts,
      db.fitnessEntities,
    ]) {
      await db.customUpdate(
        'DELETE FROM ${table.actualTableName} WHERE fitness_space_id=?',
        variables: [Variable(id)],
        updates: {table},
      );
    }
  }

  /// 捕获已知健身子实体的未确认事实，父空间状态由独立同步屏障维护。
  static Future<List<FitnessRecoveryBranch>> captureBranches(
    SesameDatabase db,
    List<FitnessTransferRecord> records,
  ) async {
    if (records.any(
      (record) => !FitnessTransferFormat.types.contains(record.entityType),
    )) {
      throw const FormatException('fitness branch entity type');
    }
    final fitnessSpaceIds = records.map((r) => r.fitnessSpaceId).toSet();
    // 子实体记录、失败意图和冲突共用同一类型边界，父变更不能按子载荷解析。
    final types = FitnessTransferFormat.types.toList(growable: false);
    final placeholders = List.filled(types.length, '?').join(',');
    final typeVariables = [for (final type in types) Variable(type)];
    final changes = await db
        .customSelect(
          'SELECT * FROM sync_changes WHERE entity_type IN ($placeholders) AND pushed_at IS NULL ORDER BY id',
          variables: typeVariables,
        )
        .get();
    final conflicts = await db
        .customSelect(
          "SELECT * FROM sync_conflicts WHERE entity_type IN ($placeholders) AND (status='OPEN' OR (resolved_at IS NULL AND (local_mutation_id LIKE 'fitness-superseded:%' OR local_mutation_id LIKE 'fitness-recovery:%'))) ORDER BY id",
          variables: typeVariables,
        )
        .get();
    return FitnessRecoveryBranch.fromRows(
      records: records,
      changes: [
        for (final r in changes)
          if (fitnessSpaceIds.contains(r.data['fitness_space_id'])) r.data,
      ],
      conflicts: [
        for (final r in conflicts)
          if (fitnessSpaceIds.contains(r.data['fitness_space_id'])) r.data,
      ],
    );
  }
}
