/// 个人健身域的同步事实；未下载完成不能被显示为空数据或完整报表。
class FitnessSyncStatus {
  final bool isComplete;
  final bool isStale;
  final int pendingCount;
  final int rejectedCount;
  final List<FitnessSyncConflict> conflicts;
  int get openConflictCount => conflicts.length;

  const FitnessSyncStatus({
    required this.isComplete,
    this.isStale = false,
    this.pendingCount = 0,
    this.rejectedCount = 0,
    this.conflicts = const [],
  });
}

/// 页面不接触同步行、冻结请求或私密完整载荷，只显示双方名称与可用决策。
class FitnessSyncConflict {
  final String id;
  final String entityId;
  final String name;
  final String remoteName;
  final bool isOtherRunningWorkout;
  final bool remoteDeleted;
  final bool isRecovery;

  const FitnessSyncConflict({
    required this.id,
    required this.entityId,
    required this.name,
    required this.remoteName,
    required this.isOtherRunningWorkout,
    required this.remoteDeleted,
    this.isRecovery = false,
  });
}
