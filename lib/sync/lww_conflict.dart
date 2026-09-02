/// LWW 冲突决策：`(updated_at, device_id)` 字典序大者胜。
///
/// 设计意图：pull 应用前先比较远端变更与本地行的更新时间；
/// 本地行更新时间更晚说明存在未推送的本地修改，跳过远端变更避免覆盖。
library;

/// 判断远端变更是否应覆盖本地行。
///
/// [localUpdatedAt] 为 null 表示本地无该实体（直接应用）。
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
