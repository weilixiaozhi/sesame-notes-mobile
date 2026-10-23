import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_issue.dart';
import '../../data/repositories/local/sync_issues_repository.dart';
import 'account_state_provider.dart';
import 'sync_providers.dart' show syncRunTickProvider;
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:drift/drift.dart';

final syncIssuesProvider = FutureProvider<List<SyncIssue>>((ref) {
  ref.watch(syncRunTickProvider);
  ref.watch(syncIssueChangesProvider);
  return readSyncIssues(
    ref.watch(databaseProvider),
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
final syncIssueChangesProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.tableUpdates(
    TableUpdateQuery.onAllTables([
      db.syncChanges,
      db.syncConflicts,
      db.syncPullErrors,
      db.ledgers,
      db.dayBooks,
      db.memoBooks,
      db.fitnessEntities,
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
