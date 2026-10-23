/// 同步状态闸门。
///
/// 设计意图：退出登录 purge 云端账本期间必须暂停同步引擎——否则并发触发的
/// push/pull/bootstrap 会把刚清掉的云端账本重新拉回（purge 白做）；闸门为
/// 内存瞬态状态，置起时 run/bootstrap 直接降级返回，不发起任何网络请求。
/// 无论 purge 成功或失败都必须开闸（finally），否则同步永久停摆。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/account_reminder_invalidation_provider.dart';

/// 常驻监听认证身份失效，清理操作与纯身份状态分离，避免仓储反向依赖清库。
final accountAuthFailureCleanupProvider = Provider<void>((ref) {
  ref.listen<AccountState>(accountStateProvider, (previous, next) {
    if (previous?.isAuthenticated != true || next.isAuthenticated) return;
    try {
      // 启动刷新可能早于业务监听器，先记录已确认的失效事件供各提醒独立清理。
      ref
          .read(accountReminderInvalidationProvider.notifier)
          .invalidateReminders();
    } catch (error, stackTrace) {
      logger.error('AuthFailureIsolate', '记录账号提醒清理事件失败', error, stackTrace);
    }
    unawaited(isolateCloudDataOnAuthFailure(ref));
  });
});

/// 同步闸门：true = 暂停同步（退出登录 purge 期间）。
final syncGateProvider = NotifierProvider<SyncGateNotifier, bool>(
  SyncGateNotifier.new,
);

/// 闸门状态：默认开启（false = 不暂停）；hold 置闸 / release 开闸。
class SyncGateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 置闸：暂停同步（purge 云端账本前调用）。
  void hold() {
    ref.read(authSessionProvider.notifier).setRefreshBlocked(true);
    state = true;
  }

  /// 开闸：恢复同步（purge 完成后调用，异常路径也必须恢复）。
  void release() {
    ref.read(authSessionProvider.notifier).setRefreshBlocked(false);
    state = false;
  }
}

/// 认证失效只隔离账号数据，不删除本机行：账本、交易、待推送变更与冲突记录
/// 按账号域隐藏（见各仓储的可见性条件），同账号重新登录后直接继续同步与补推，
/// 下载任务与尚未发布的事实随本机行保留，同账号重认证后继续补齐。
/// 真正的内容清理只发生在用户显式退出登录或换账号时。
/// 已持有账号清理闸门时跳过；失败记录日志，始终释放本次持有的闸门。
Future<void> isolateCloudDataOnAuthFailure(Ref ref) async {
  final gate = ref.read(syncGateProvider.notifier);
  if (ref.read(syncGateProvider)) return;
  gate.hold();
  try {
    final db = ref.read(databaseProvider);
    await db
        .update(db.syncState)
        .write(const SyncStateCompanion(serverCursor: d.Value(null)));
  } catch (error, stackTrace) {
    logger.error('AuthFailureIsolate', '认证失效后隔离账号数据失败', error, stackTrace);
  } finally {
    gate.release();
  }
}
