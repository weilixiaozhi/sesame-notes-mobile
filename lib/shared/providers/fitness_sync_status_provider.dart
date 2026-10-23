import 'fitness_space_provider.dart';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness_sync_status.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

final fitnessSyncStatusProvider = FutureProvider<FitnessSyncStatus>((
  ref,
) async {
  final account = ref.watch(currentAccountIdProvider);
  final spaceId = await ref.watch(currentFitnessSpaceIdProvider.future);
  ref.watch(dataChangeSignalProvider);
  ref.watch(syncRunTickProvider);
  final db = ref.watch(fitnessSpaceRepositoryProvider).db;
  return db.transaction(() async {
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
    final stale =
        await (db.select(db.fitnessEntities)
              ..where(
                (e) =>
                    e.fitnessSpaceId.equals(spaceId ?? '') &
                    e.isStale.equals(true),
              )
              ..limit(1))
            .get();
    final pending =
        await (db.select(db.syncChanges)..where(
              (c) =>
                  (owner == null
                      ? c.accountId.isNull()
                      : c.accountId.equals(owner)) &
                  c.fitnessSpaceId.equals(spaceId ?? '') &
                  c.pushedAt.isNull(),
            ))
            .get();
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
    return FitnessSyncStatus(
      isComplete:
          scope != null &&
          !scope.isStale &&
          (scope.storageMode == 'local' ||
              scope.syncId == null ||
              scope.fullCursor != null) &&
          stale.isEmpty &&
          !conflicts.any((c) {
            final remote = jsonDecode(c.remotePayload) as Map;
            return c.status == 'OPEN' &&
                remote['id'] != null &&
                remote['id'] != c.entityId;
          }),
      isStale: stale.isNotEmpty,
      pendingCount: pending.length,
      rejectedCount: pending.where((c) => c.rejectionReason != null).length,
      conflicts: [
        for (final conflict in conflicts)
          () {
            final local = jsonDecode(conflict.localPayload) as Map;
            final remote = jsonDecode(conflict.remotePayload) as Map;
            return FitnessSyncConflict(
              id: conflict.id,
              entityId: conflict.entityId,
              name: local['name'] as String? ?? '',
              remoteName: remote['name'] as String? ?? '',
              isRecovery: remote['fitness_recovery'] == true,
              isOtherRunningWorkout:
                  remote['id'] != null && remote['id'] != conflict.entityId,
              remoteDeleted:
                  remote['deleted'] == true || remote['deleted_at'] != null,
            );
          }(),
      ],
    );
  });
});
