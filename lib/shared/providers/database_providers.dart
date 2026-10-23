import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'account_state_provider.dart';

/// 管理数据库连接及组合仓储的生命周期，共用事务和账号变更登记。
final databaseProvider = Provider<SesameDatabase>((ref) {
  final db = SesameDatabase();
  ref.onDispose(() async {
    // 本地备份恢复流程会在 invalidate 前手动 close 过连接，此处二次 close
    // Drift 会抛 StateError，故幂等容错。
    try {
      await db.close();
    } catch (_) {}
  });
  return db;
});

// 仓储Provider — LocalRepository(本地优先)。变更登记经 ChangeRecorder 端口
// 注入：写操作落 sync_changes 表，由 SyncService 消费推送。
final repositoryProvider = Provider<LocalRepository>((ref) {
  final db = ref.watch(databaseProvider);
  // 变更登记带当前账号域：登录后编辑的 mutation 归属当前账号，未登录不归属
  return LocalRepository(
    db,
    changeTracker: ChangeRecorderImpl(
      db,
      accountIdGetter: () => ref.read(currentAccountIdProvider),
    ),
    // 汇率覆盖等确定性派生主键需要当前账号身份，与变更登记同源。
    accountIdGetter: () => ref.read(currentAccountIdProvider),
  );
});
