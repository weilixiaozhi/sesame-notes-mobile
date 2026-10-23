import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/models/day_sync_status.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 按当前账号统计未确认修改及冲突，已隐藏的失败删除仍参与数据保护。
final daySyncStatusProvider = FutureProvider<List<DayBookSyncStatus>>((
  ref,
) async {
  final accountId = ref.watch(currentAccountIdProvider);
  if (accountId == null) return const [];
  ref.watch(dataChangeSignalProvider);
  ref.watch(syncRunTickProvider);
  final db = ref.watch(databaseProvider);
  try {
    return await db.transaction(() async {
      final books =
          await (db.select(db.dayBooks)..where(
                (b) =>
                    b.scopeAccountId.equals(accountId) &
                    b.storageMode.equals('cloud'),
              ))
              .get();
      final pending =
          await (db.select(db.syncChanges)..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.dayBookId.isNotNull() &
                    c.pushedAt.isNull(),
              ))
              .get();
      final conflicts =
          await (db.select(db.syncConflicts)..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.dayBookId.isNotNull() &
                    c.status.equals('OPEN'),
              ))
              .get();
      final ids = {
        ...books.map((b) => b.id),
        ...pending.map((c) => c.dayBookId!),
        ...conflicts.map((c) => c.dayBookId!),
      };
      return [
        for (final id in ids)
          DayBookSyncStatus(
            dayBookId: id,
            book: books
                .where((b) => b.id == id)
                .map(dayBookFromRow)
                .firstOrNull,
            pendingCount: pending.where((c) => c.dayBookId == id).length,
            rejectedCount: pending
                .where((c) => c.dayBookId == id && c.rejectionReason != null)
                .length,
            conflictCount: conflicts.where((c) => c.dayBookId == id).length,
          ),
      ];
    });
  } catch (error, stackTrace) {
    logger.error('DaySyncStatus', '读取日子同步状态失败', error, stackTrace);
    rethrow;
  }
});
