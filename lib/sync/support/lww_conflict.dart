/// LWW 冲突决策：`(updated_at, device_id)` 字典序大者胜。
///
/// 仅用于双方真实写入设备均可获取的版本比较；读取设备身份不是写入版本。
/// 普通记账增量由服务端裁决，客户端按事件游标与元数据时间投影。
library;

/// 判断远端变更是否应覆盖本地行。
///
/// [localUpdatedAt] 为 null 表示本地无该实体（直接应用）。
/// [localDeviceId] 必须是本地已保存版本的实际写入设备。
/// 时间相同按 device_id 字典序比较，大者胜。
bool lwwShouldApply({
  required DateTime? localUpdatedAt,
  required String? localDeviceId,
  required DateTime remoteUpdatedAt,
  required String? remoteDeviceId,
}) {
  final local = localUpdatedAt;
  if (local == null) return true;

  // 先比时间：远端更晚 → 应用；本地更晚 → 跳过。
  final timeCompare = remoteUpdatedAt.compareTo(local);
  if (timeCompare != 0) return timeCompare > 0;

  // 时间相同：device_id 字典序大者胜；远端更大才应用。
  final remoteId = remoteDeviceId ?? '';
  final localId = localDeviceId ?? '';
  return remoteId.compareTo(localId) > 0;
}
