/// 只有明确属于云端或共享的账本才进入云端生命周期。
bool isCloudLedgerOf(String? storageMode, {required bool isShared}) =>
    storageMode == 'cloud' || isShared;

/// 未知存储模式不降级为本地，防止身份边界被绕过。
bool isLocalLedgerOf(String? storageMode, {required bool isShared}) =>
    storageMode == 'local' && !isShared;
