import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/db.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

final fitnessRecoveryActionsProvider = Provider(FitnessRecoveryActions.new);

/// 恢复分支只通过明确选择落入当前作用域，不重放备份中的旧请求。
class FitnessRecoveryActions {
  FitnessRecoveryActions(this.ref);
  final Ref ref;

  Future<void> keepLocal(String id) => _resolve(id, adopt: false);
  Future<void> adoptBranch(String id) => _resolve(id, adopt: true);

  Future<void> _resolve(String id, {required bool adopt}) async {
    final db = ref.read(databaseProvider);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref
        .read(authSessionProvider.notifier)
        .identityGeneration;
    void checkScope() {
      if (ref.read(currentAccountIdProvider) != account ||
          ref.read(authSessionProvider.notifier).identityGeneration !=
              generation) {
        throw StateError('FITNESS_SCOPE_CHANGED');
      }
    }

    await db.transaction(() async {
      checkScope();
      final conflict = await (db.select(
        db.syncConflicts,
      )..where((c) => c.id.equals(id))).getSingle();
      final branch = jsonDecode(conflict.remotePayload) as Map<String, dynamic>;
      final space = await (db.select(
        db.fitnessSpaces,
      )..where((b) => b.id.equals(conflict.fitnessSpaceId ?? ''))).getSingle();
      if ((space.storageMode == 'cloud' && space.scopeAccountId != account) ||
          space.isHidden ||
          space.deletedAt != null ||
          conflict.accountId != space.scopeAccountId ||
          (conflict.status != 'OPEN' &&
              !(conflict.localMutationId.startsWith('fitness-recovery:') &&
                  conflict.resolvedAt == null)) ||
          branch['fitness_recovery'] != true) {
        throw StateError('FITNESS_CONFLICT_CHANGED');
      }
      if (adopt) {
        final targetId = branch['id'] as String;
        final canonical = await (db.select(
          db.fitnessEntities,
        )..where((e) => e.id.equals(conflict.entityId))).getSingle();
        final target = await (db.select(
          db.fitnessEntities,
        )..where((e) => e.id.equals(targetId))).getSingleOrNull();
        if (canonical.fitnessSpaceId != space.id ||
            canonical.entityType != conflict.entityType ||
            (target != null &&
                (target.fitnessSpaceId != space.id ||
                    target.entityType != conflict.entityType))) {
          throw StateError('FITNESS_SCOPE_CHANGED');
        }
        final payload = Map<String, dynamic>.from(branch['payload'] as Map);
        // 选择历史版本是当前的新意图；实体创建身份保持不变，内容中的训练时段仍原样保留。
        if (target != null) {
          payload['created_at'] = target.createdAt.toUtc().toIso8601String();
        }
        var updated = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch,
          isUtc: true,
        );
        for (final candidate in [
          DateTime.parse(payload['updated_at'] as String),
          if (target != null)
            target.updatedAt.add(const Duration(milliseconds: 1)),
        ]) {
          if (candidate.isAfter(updated)) updated = candidate;
        }
        payload['updated_at'] = updated.toUtc().toIso8601String();
        validateFitnessPayload(conflict.entityType, payload);
        validateFitnessIdentity(conflict.entityType, targetId, payload);
        final deletedAt = branch['deleted_at'] == null
            ? null
            : DateTime.parse(branch['deleted_at'] as String);
        if (account != null &&
            (target?.isStale == true ||
                (target?.syncId != null &&
                    target?.deletedAt != null &&
                    deletedAt == null))) {
          throw StateError('FITNESS_REMOTE_DELETED_OR_STALE');
        }
        // SQLite 的进行中与 occurrence 唯一约束同时保护其他训练；失败则保留待处理分支。
        await db
            .into(db.fitnessEntities)
            .insertOnConflictUpdate(
              FitnessEntitiesCompanion.insert(
                id: targetId,
                entityType: conflict.entityType,
                fitnessSpaceId: space.id,
                scopeAccountId: Value(account),
                storageMode: Value(account == null ? 'local' : 'cloud'),
                syncId: Value(target?.syncId),
                serverRevision: Value(target?.serverRevision),
                payload: jsonEncode(payload),
                createdAt: DateTime.parse(payload['created_at'] as String),
                updatedAt: DateTime.parse(payload['updated_at'] as String),
                deletedAt: Value(deletedAt),
              ),
            );
        if (space.scopeAccountId != null) {
          await ChangeRecorderImpl(
            db,
            accountIdGetter: () => ref.read(currentAccountIdProvider),
          ).recordFitnessChange(
            entityType: conflict.entityType,
            fitnessSpaceId: space.id,
            entityId: targetId,
            accountId: space.scopeAccountId!,
            action: deletedAt == null || target?.syncId == null
                ? 'upsert'
                : 'delete',
            payload: jsonEncode(payload),
            updatedAt: DateTime.parse(payload['updated_at'] as String),
            baseRevision: target?.serverRevision ?? 0,
          );
        }
      }
      await (db.update(db.syncConflicts)..where((c) => c.id.equals(id))).write(
        SyncConflictsCompanion(
          status: Value(adopt ? 'RESOLVED_REMOTE' : 'RESOLVED_LOCAL'),
          resolvedAt: Value(DateTime.now().toUtc()),
        ),
      );
      checkScope();
    });
  }
}
