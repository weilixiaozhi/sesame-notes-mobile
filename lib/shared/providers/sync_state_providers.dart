/// 同步状态闸门（P1）。
///
/// 设计意图：退出登录 purge 云端账本期间必须暂停同步引擎——否则并发触发的
/// push/pull/bootstrap 会把刚清掉的云端账本重新拉回（purge 白做）；闸门为
/// 内存瞬态状态，置起时 run/bootstrap 直接降级返回，不发起任何网络请求。
/// 无论 purge 成功或失败都必须开闸（finally），否则同步永久停摆。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 同步闸门：true = 暂停同步（退出登录 purge 期间）。
final syncGateProvider = NotifierProvider<SyncGateNotifier, bool>(
  SyncGateNotifier.new,
);

/// 闸门状态：默认开启（false = 不暂停）；hold 置闸 / release 开闸。
class SyncGateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 置闸：暂停同步（purge 云端账本前调用）。
  void hold() => state = true;

  /// 开闸：恢复同步（purge 完成后调用，异常路径也必须恢复）。
  void release() => state = false;
}

/// 认证类 401 的账号域清理：与显式退出登录同口径执行 P0-1 purge。
///
/// 语义：
/// - 整本清除 storage_mode='cloud' 的账本（本地账本一行不动）；
/// - 云端账本清空后同步簿记（待推送队列/设备游标/冲突/拉取错误）全部失效，
///   整表清除——本地账本不进同步通道，不会误伤本地数据；
/// - 重登后由 reconnect 全量快照拉回云端账本；
/// - [syncGateProvider] 已置起（显式登出协调器正在清理）时直接跳过：
///   该路径已完成更完整的账号域清理，此处不得提前开闸；
/// - 清理成功或失败都必须开闸（finally 语义），否则同步永久停摆；
/// - 失败只记日志不抛出：凭证已被服务端作废，清理失败不能阻塞回未登录。
Future<void> purgeCloudDataOnAuthFailure(Ref ref) async {
  final gate = ref.read(syncGateProvider.notifier);
  if (ref.read(syncGateProvider)) return;
  gate.hold();
  try {
    final db = ref.read(databaseProvider);
    final repo = ref.read(repositoryProvider);
    await repo.purgeAllCloudLedgers();
    await (db.delete(db.syncChanges)).go();
    await (db.delete(db.syncState)).go();
    await (db.delete(db.syncConflicts)).go();
    await (db.delete(db.syncPullErrors)).go();
  } catch (error, stackTrace) {
    logger.error('AuthFailurePurge', '认证失效后清理云端数据失败', error, stackTrace);
  } finally {
    gate.release();
  }
}
