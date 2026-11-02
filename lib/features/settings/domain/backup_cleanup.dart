/// 清理来源只携带展示身份，不把云端凭据交给页面。
class BackupCleanupSource {
  /// 本机使用 local，云端使用已经保存的后端标识。
  const BackupCleanupSource({required this.id, required this.displayName});

  final String id;
  final String displayName;
  bool get isLocal => id == 'local';
}

/// 文件识别状态与删除资格分开，未验证和无法识别的文件始终保留。
enum BackupCleanupStatus {
  unverified,
  current,
  unsupported,
  auxiliary,
  unknown,
  pending,
  inUse,
}

/// 预览中的单个文件；内容摘要只在明确检查后生成。
class BackupCleanupEntry {
  /// 路径键只用于回交同一份预览，实际删除由服务重新校验范围和内容。
  const BackupCleanupEntry({
    required this.key,
    required this.fileName,
    required this.sizeBytes,
    required this.modifiedAt,
    required this.createdAt,
    required this.status,
    this.sha256,
    this.isProtected = false,
    this.deletionSupported = true,
  });

  final String key;
  final String fileName;
  final int? sizeBytes;
  final DateTime? modifiedAt;
  final DateTime? createdAt;
  final BackupCleanupStatus status;
  final String? sha256;
  final bool isProtected;
  final bool deletionSupported;

  /// 只有已经核实内容且不受保护的文件可以进入删除确认。
  bool get canDelete =>
      !isProtected &&
      deletionSupported &&
      sha256 != null &&
      const {
        BackupCleanupStatus.current,
        BackupCleanupStatus.unsupported,
        BackupCleanupStatus.auxiliary,
      }.contains(status);

  /// 尚未检查的普通文件可以由用户单独发起内容检查。
  bool get canInspect => status == BackupCleanupStatus.unverified;

  /// 服务更新识别结果或保护标记时发布新的不可变展示项。
  BackupCleanupEntry copyWith({
    BackupCleanupStatus? status,
    String? sha256,
    bool? isProtected,
    DateTime? createdAt,
  }) => BackupCleanupEntry(
    key: key,
    fileName: fileName,
    sizeBytes: sizeBytes,
    modifiedAt: modifiedAt,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    sha256: sha256 ?? this.sha256,
    isProtected: isProtected ?? this.isProtected,
    deletionSupported: deletionSupported,
  );
}

/// 预览固定来源和服务身份，切换账号、配置或重新预览后不能复用旧确认。
class BackupCleanupPreview {
  /// token 由服务生成，页面只保留并原样回交。
  BackupCleanupPreview({
    required this.source,
    required this.token,
    required List<BackupCleanupEntry> entries,
    this.supportsDeletion = true,
  }) : entries = List.unmodifiable(entries);

  final BackupCleanupSource source;
  final String token;
  final List<BackupCleanupEntry> entries;
  final bool supportsDeletion;

  bool get hasCurrentBackup => entries.any((entry) => entry.isProtected);
}

/// 删除按文件反馈结果，部分失败不能伪装为全部成功。
class BackupCleanupResult {
  const BackupCleanupResult({
    required this.deletedCount,
    required this.failedCount,
  });

  final int deletedCount;

  /// 未完成或未收到删除确认的数量；网络失败不能解释为文件必然仍在。
  final int failedCount;
}

/// 业务边界只向页面暴露稳定原因，底层错误详情留在脱敏日志中。
enum BackupCleanupFailure {
  busy,
  stalePreview,
  fileChanged,
  protectedBackup,
  inUse,
  unverified,
  noCurrentBackup,
  unavailable,
}

class BackupCleanupException implements Exception {
  const BackupCleanupException(this.reason);
  final BackupCleanupFailure reason;

  @override
  String toString() => 'BackupCleanupException(${reason.name})';
}
