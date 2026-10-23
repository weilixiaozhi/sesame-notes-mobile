import 'package:sesame_notes/utils/wire_timestamp.dart';

/// 私有本与健身空间共用存储归属和同步状态；登录只控制访问，不改变数据归属。
class PrivateBook {
  final String id, name, storageMode;
  final String? scopeAccountId,
      syncId,
      fullCursor,
      sourceAccountId,
      sourceOperationId;
  final int? serverRevision;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
  final bool isStale, isHidden, pendingLocalDelete;
  const PrivateBook({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.storageMode = 'local',
    this.scopeAccountId,
    this.syncId,
    this.fullCursor,
    this.serverRevision,
    this.deletedAt,
    this.isStale = false,
    this.isHidden = false,
    this.pendingLocalDelete = false,
    this.sourceAccountId,
    this.sourceOperationId,
  });
  bool get isCloud => storageMode == 'cloud';
  bool get isComplete => !isCloud || syncId == null || fullCursor != null;
  Map<String, Object?> get payload => {
    'name': name,
    'created_at': wireTimestamp(createdAt),
    'updated_at': wireTimestamp(updatedAt),
  };
}

typedef PrivateBookTarget = ({
  String bookId,
  String? accountId,
  String? syncId,
  int generation,
});

class FitnessSpace extends PrivateBook {
  final String? sourceFitnessSpaceId;
  final int entityCount;
  const FitnessSpace({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    super.storageMode,
    super.scopeAccountId,
    super.syncId,
    super.fullCursor,
    super.serverRevision,
    super.deletedAt,
    super.isStale,
    super.isHidden,
    super.pendingLocalDelete,
    super.sourceAccountId,
    super.sourceOperationId,
    this.sourceFitnessSpaceId,
    this.entityCount = 0,
  });
}

/// 会话和父本固定，未绑定创建允许接收首次绑定；已知绑定不能静默跨代。
bool matchesPrivateBookTarget(
  PrivateBookTarget expected,
  PrivateBookTarget current,
) =>
    expected.bookId == current.bookId &&
    expected.accountId == current.accountId &&
    expected.generation == current.generation &&
    (expected.syncId == null || expected.syncId == current.syncId);

/// 各私有本目录共享发现状态，未知或失败不能伪装成空目录。
enum BookDirectoryStatus { unknown, loading, ready, failed }
