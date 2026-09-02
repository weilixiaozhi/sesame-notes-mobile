/// 账本持久字段投影出的同步绑定状态。
enum LedgerSyncState {
  local,

  /// 云转本地移动的隐藏 Fork：本地副本已建、源云端账本删除尚未确认。
  /// 属于持久化 intent，启动恢复时按此状态完成发布或回退。
  pendingLocalMove,
  cloudUnbound,
  cloudBound,
  staleBinding,
  invalid,
}

/// 同步状态的可执行规则。
extension LedgerSyncStateRules on LedgerSyncState {
  /// 只有待绑定或已绑定的云账本可与服务端交换数据。
  bool get canSync =>
      this == LedgerSyncState.cloudUnbound ||
      this == LedgerSyncState.cloudBound;
}

/// 将 Drift 持久字段唯一投影为绑定状态。
///
/// 非法组合采用失败关闭，防止损坏的本地绑定意外读写云端时间线。
LedgerSyncState ledgerSyncStateOf({
  required String storageMode,
  String? syncId,
  String? bindingStatus,
}) {
  final hasSyncId = syncId?.isNotEmpty == true;
  if (storageMode == 'local') {
    // 隐藏 Fork 的持久化 intent：本地副本尚未发布，不作为普通本地账本展示
    if (!hasSyncId && bindingStatus == 'pending_local_move') {
      return LedgerSyncState.pendingLocalMove;
    }
    return !hasSyncId && bindingStatus == null
        ? LedgerSyncState.local
        : LedgerSyncState.invalid;
  }
  if (storageMode != 'cloud') return LedgerSyncState.invalid;
  if (bindingStatus == 'stale') return LedgerSyncState.staleBinding;
  if (bindingStatus != null && bindingStatus != 'bound') {
    return LedgerSyncState.invalid;
  }
  return hasSyncId
      ? LedgerSyncState.cloudBound
      : bindingStatus == null
      ? LedgerSyncState.cloudUnbound
      : LedgerSyncState.invalid;
}
