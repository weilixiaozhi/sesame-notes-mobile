import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_issue.dart';
import '../../data/repositories/local/sync_issues_repository.dart';
import 'account_state_provider.dart';
import 'sync_providers.dart' show syncRunTickProvider, syncBusyProvider;
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:drift/drift.dart';

final syncIssuesProvider = FutureProvider<List<SyncIssue>>((ref) {
  ref.watch(syncRunTickProvider);
  final db = ref.watch(databaseProvider);
  ref.listen(syncIssueChangesProvider, (_, next) {
    final changes = next.asData?.value;
    if (changes == null) {
      if (next.hasError) ref.invalidateSelf();
      return;
    }
    final queueBookkeeping =
        changes.isNotEmpty &&
        changes.every(
          (change) =>
              change.table == db.syncChanges.actualTableName &&
              change.kind == UpdateKind.update,
        );
    // 增量轮次结束会统一刷新。逐条冻结和确认只更新队列表时，不重复读取全部本子。
    // 新任务、冲突和父本变化仍立即响应；退出保护的显式刷新始终重新查数据库。
    if (!queueBookkeeping || !ref.read(syncBusyProvider)) {
      ref.invalidateSelf();
    }
  });
  return readSyncIssues(
    db,
    account: ref.watch(currentAccountIdProvider),
    includeDetails: false,
  );
});

/// 同步中心按实体展开队列头信息；正文仅在卡片可见时读取。
final syncCenterIssuesProvider = FutureProvider.autoDispose<List<SyncIssue>>((
  ref,
) {
  ref.watch(syncRunTickProvider);
  ref.watch(syncIssueChangesProvider);
  return readSyncIssues(
    ref.watch(databaseProvider),
    account: ref.watch(currentAccountIdProvider),
    includeDetails: false,
    expandPendingUploads: true,
  );
});

// 只监听待处理事实所在表；修改正文、分类或汇率不直接重算全局异常列表。
final syncIssueChangesProvider = StreamProvider<Set<TableUpdate>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.syncChanges,
      db.syncConflicts,
      db.syncPullErrors,
      db.ledgers,
      db.dayBooks,
      db.memoBooks,
      db.fitnessSpaces,
    ]),
  );
});
final syncIssueDetailsProvider = FutureProvider.autoDispose
    .family<SyncIssue, SyncIssue>((ref, summary) {
      return readSyncIssueDetails(
        ref.watch(databaseProvider),
        summary,
        account: ref.watch(currentAccountIdProvider),
      );
    });
