import 'fitness_space_provider.dart';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/fitness_sync_status.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

final fitnessSyncStatusProvider = FutureProvider<FitnessSyncStatus>((
  ref,
) async {
  final account = ref.watch(currentAccountIdProvider);
  final spaceId = await ref.watch(currentFitnessSpaceIdProvider.future);
  ref.watch(fitnessDataChangeSignalProvider);
  ref.watch(syncRunTickProvider);
  final db = ref.watch(fitnessSpaceRepositoryProvider).db;
  try {
    return await db.transaction(() async {
      final scope = await (db.select(
        db.fitnessSpaces,
      )..where((s) => s.id.equals(spaceId ?? ''))).getSingleOrNull();
      if (scope != null &&
          (scope.isHidden ||
              scope.deletedAt != null ||
              (scope.storageMode == 'cloud' &&
                  scope.scopeAccountId != account))) {
        return const FitnessSyncStatus(isComplete: false);
      }
      final owner = scope?.scopeAccountId;
      final entities = db.fitnessEntities;
      final stale =
          await (db.selectOnly(entities)
                ..addColumns([entities.id])
                ..where(
                  entities.fitnessSpaceId.equals(spaceId ?? '') &
                      entities.isStale.equals(true),
                )
                ..limit(1))
              .get();
      final changes = db.syncChanges;
      final pendingCount = changes.id.count();
      final rejectedCount = changes.rejectionReason.count();
      // 待推状态只需要两个计数，训练正文和冻结请求不必搬运到界面线程。
      final pending =
          await (db.selectOnly(changes)
                ..addColumns([pendingCount, rejectedCount])
                ..where(
                  (owner == null
                          ? changes.accountId.isNull()
                          : changes.accountId.equals(owner)) &
                      changes.fitnessSpaceId.equals(spaceId ?? '') &
                      changes.pushedAt.isNull(),
                ))
              .getSingle();
      final conflicts =
          await (db.select(db.syncConflicts)..where(
                (c) =>
                    (owner == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(owner)) &
                    c.fitnessSpaceId.equals(spaceId ?? '') &
                    (c.status.equals('OPEN') |
                        (c.localMutationId.like('fitness-recovery:%') &
                            c.resolvedAt.isNull())),
              ))
              .get();
      var hasOtherRunningWorkout = false;
      final conflictStates = <FitnessSyncConflict>[];
      // 同一冲突的正文各解码一次，完整性判断和展示共享解析结果。
      for (final conflict in conflicts) {
        final local = jsonDecode(conflict.localPayload) as Map;
        final remote = jsonDecode(conflict.remotePayload) as Map;
        final otherRunning =
            remote['id'] != null && remote['id'] != conflict.entityId;
        hasOtherRunningWorkout =
            hasOtherRunningWorkout || conflict.status == 'OPEN' && otherRunning;
        conflictStates.add(
          FitnessSyncConflict(
            id: conflict.id,
            entityId: conflict.entityId,
            name: local['name'] as String? ?? '',
            remoteName: remote['name'] as String? ?? '',
            isRecovery: remote['fitness_recovery'] == true,
            isOtherRunningWorkout: otherRunning,
            remoteDeleted:
                remote['deleted'] == true || remote['deleted_at'] != null,
          ),
        );
      }
      return FitnessSyncStatus(
        isComplete:
            scope != null &&
            !scope.isStale &&
            (scope.storageMode == 'local' ||
                scope.syncId == null ||
                scope.fullCursor != null) &&
            stale.isEmpty &&
            !hasOtherRunningWorkout,
        isStale: stale.isNotEmpty,
        pendingCount: pending.read(pendingCount) ?? 0,
        rejectedCount: pending.read(rejectedCount) ?? 0,
        conflicts: conflictStates,
      );
    });
  } catch (error, stackTrace) {
    logger.error(
      'FitnessSyncStatus',
      '读取训练同步状态失败',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
});
