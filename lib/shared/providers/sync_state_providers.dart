/// 同步状态闸门（P1）。
///
/// 设计意图：退出登录 purge 云端账本期间必须暂停同步引擎——否则并发触发的
/// push/pull/bootstrap 会把刚清掉的云端账本重新拉回（purge 白做）；闸门为
/// 内存瞬态状态，置起时 run/bootstrap 直接降级返回，不发起任何网络请求。
/// 无论 purge 成功或失败都必须开闸（finally），否则同步永久停摆。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
