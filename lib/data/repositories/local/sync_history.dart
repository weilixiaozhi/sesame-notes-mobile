import 'package:drift/drift.dart';
import '../../db.dart';

/// 已确认历史只保留最近 100 条诊断元数据，未知请求和未解决分支原样保留。
Future<void> compactSyncHistory(
  SesameDatabase db, {
  required String? accountId,
}) async {
  await db.transaction(() async {
    final variables = [Variable<String>(accountId)];
    var changeCount = await db.customUpdate(
      "UPDATE sync_changes SET payload='{}', frozen_request=NULL, rejection_reason=NULL WHERE account_id IS ? AND pushed_at IS NOT NULL AND (payload<>'{}' OR frozen_request IS NOT NULL OR rejection_reason IS NOT NULL)",
      variables: variables,
    );
    changeCount += await db.customUpdate(
      'DELETE FROM sync_changes WHERE account_id IS ? AND pushed_at IS NOT NULL AND id NOT IN (SELECT id FROM sync_changes WHERE account_id IS ? AND pushed_at IS NOT NULL ORDER BY id DESC LIMIT 100)',
      variables: [...variables, ...variables],
    );
    var conflictCount = await db.customUpdate(
      "UPDATE sync_conflicts SET local_payload='{}', remote_payload='{}' WHERE account_id IS ? AND status<>'OPEN' AND resolved_at IS NOT NULL AND (local_payload<>'{}' OR remote_payload<>'{}')",
      variables: variables,
    );
    conflictCount += await db.customUpdate(
      "DELETE FROM sync_conflicts WHERE account_id IS ? AND status<>'OPEN' AND resolved_at IS NOT NULL AND id NOT IN (SELECT id FROM sync_conflicts WHERE account_id IS ? AND status<>'OPEN' AND resolved_at IS NOT NULL ORDER BY resolved_at DESC,id DESC LIMIT 100)",
      variables: [...variables, ...variables],
    );
    // 空清理不发布表变化，避免仍有冲突时触发自动同步空转。
    db.notifyUpdates({
      if (changeCount > 0) TableUpdate(db.syncChanges.actualTableName),
      if (conflictCount > 0) TableUpdate(db.syncConflicts.actualTableName),
    });
  });
}
