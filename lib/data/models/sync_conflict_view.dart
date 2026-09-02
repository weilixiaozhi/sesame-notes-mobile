/// 同步冲突的展示模型（UI 唯一合法形态）。
///
/// 设计意图：冲突行本身是 Drift 生成的 Row（[SyncConflict]），带 payload、
/// mutation id 等同步内部字段。页面只需要「哪个实体、双方 revision 差多少」
/// 与解决入口 id，因此在这里收敛为纯 Dart 值对象：schema 增列不会上浮到 UI。
class SyncConflictView {
  /// 冲突记录主键；解决冲突时作为入参回传。
  final String id;

  /// 冲突实体 id（当前为交易 UUID）。
  final String entityId;

  /// 冲突基线：本地 pending mutation 的 base_revision。
  final int baseRevision;

  /// 冲突时云端 revision。
  final int remoteRevision;

  const SyncConflictView({
    required this.id,
    required this.entityId,
    required this.baseRevision,
    required this.remoteRevision,
  });
}
