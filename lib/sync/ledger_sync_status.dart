/// 账本卡片同步状态：由持久字段 + 会话 + 待推/冲突计数投影出的展示状态。
///
/// 与 [LedgerSyncState]（同步引擎可执行性）不同，本枚举只回答「卡片图标
/// 画什么、什么颜色」：
/// - 绿云语义 = 「能连上服务器」：已登录且绑定正常即绿（含待推送）；
/// - 未登录 / 绑定失效 / 存在 OPEN 冲突（推送被暂停）一律离线灰；
/// - 纯本地账本不画云（local 图标）。
enum LedgerSyncStatus {
  /// 纯本地账本：卡片画本地图标，不画云。
  local,

  /// 云端账本但当前未登录：离线灰。
  notLoggedIn,

  /// 云端账本绑定失效（SYNC_ID_MISMATCH 后同步暂停）：离线灰。
  staleBinding,

  /// 存在 OPEN 冲突待解决（相关实体推送被暂停）：离线灰。
  conflict,

  /// 有本地变更待推送（服务器可达）：在线绿。
  pendingPush,

  /// 无待推、无冲突、绑定正常：在线绿。
  inSync,
}

/// 卡片颜色判定：绿 = 能连上服务器（已同步或待推送）。
extension LedgerSyncStatusColor on LedgerSyncStatus {
  /// 在线绿（已同步 / 待推送），其余云端态离线灰。
  bool get isConnected =>
      this == LedgerSyncStatus.inSync || this == LedgerSyncStatus.pendingPush;
}

/// 将账本持久字段与运行态信号唯一投影为卡片同步状态。
///
/// 输入均为纯值，便于单测：语义与查询解耦，provider 只负责取数。
LedgerSyncStatus ledgerSyncStatusOf({
  required String storageMode,
  String? bindingStatus,
  required bool hasSession,
  required int pendingCount,
  required int conflictCount,
}) {
  // 归属是权威：本地账本不画云。
  if (storageMode != 'cloud') return LedgerSyncStatus.local;
  // 未登录：连不上服务器，离线灰。
  if (!hasSession) return LedgerSyncStatus.notLoggedIn;
  // 绑定失效：同步已暂停，离线灰。
  if (bindingStatus == 'stale') return LedgerSyncStatus.staleBinding;
  // OPEN 冲突：相关实体推送被暂停，离线灰（等冲突 UI 解决）。
  if (conflictCount > 0) return LedgerSyncStatus.conflict;
  // 有待推变更：服务器可达，在线绿（上传由同步编排异步完成）。
  if (pendingCount > 0) return LedgerSyncStatus.pendingPush;
  return LedgerSyncStatus.inSync;
}
