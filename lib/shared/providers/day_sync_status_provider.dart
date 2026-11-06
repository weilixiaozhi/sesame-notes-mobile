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
  ref.watch(dayDataChangeSignalProvider);
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
      final changes = db.syncChanges;
      final pendingCount = changes.id.count();
      final rejectedCount = changes.rejectionReason.count();
      // 仅传回按本聚合的数字，长正文与冻结请求不进入状态对象。
      final pending =
          await (db.selectOnly(changes)
                ..addColumns([changes.dayBookId, pendingCount, rejectedCount])
                ..where(
                  changes.accountId.equals(accountId) &
                      changes.dayBookId.isNotNull() &
                      changes.pushedAt.isNull(),
                )
                ..groupBy([changes.dayBookId]))
              .get();
      final conflictTable = db.syncConflicts;
      final conflictCount = conflictTable.id.count();
      final conflicts =
          await (db.selectOnly(conflictTable)
                ..addColumns([conflictTable.dayBookId, conflictCount])
                ..where(
                  conflictTable.accountId.equals(accountId) &
                      conflictTable.dayBookId.isNotNull() &
                      conflictTable.status.equals('OPEN'),
                )
                ..groupBy([conflictTable.dayBookId]))
              .get();
      // 每组结果只遍历一次，多个本子不会重复扫描全部待推记录。
      final booksById = {
        for (final book in books) book.id: dayBookFromRow(book),
      };
      final pendingById = {
        for (final row in pending)
          row.read(changes.dayBookId)!: (
            count: row.read(pendingCount) ?? 0,
            rejected: row.read(rejectedCount) ?? 0,
          ),
      };
      final conflictsById = {
        for (final row in conflicts)
          row.read(conflictTable.dayBookId)!: row.read(conflictCount) ?? 0,
      };
      final ids = {
        ...booksById.keys,
        ...pendingById.keys,
        ...conflictsById.keys,
      };
      return [
        for (final id in ids)
          DayBookSyncStatus(
            dayBookId: id,
            book: booksById[id],
            pendingCount: pendingById[id]?.count ?? 0,
            rejectedCount: pendingById[id]?.rejected ?? 0,
            conflictCount: conflictsById[id] ?? 0,
          ),
      ];
    });
  } catch (error, stackTrace) {
    logger.error('DaySyncStatus', '读取日子同步状态失败', error, stackTrace);
    rethrow;
  }
});
