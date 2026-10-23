/// 全局同步操作定位；类型仅用于匹配已有实体存储，不建立独立业务工作流。
class SyncTarget {
  const SyncTarget(this.type, this.id, {this.parentId});
  final String type;
  final String id;
  final String? parentId;
  @override
  bool operator ==(Object other) =>
      other is SyncTarget &&
      other.type == type &&
      other.id == id &&
      other.parentId == parentId;
  @override
  int get hashCode => Object.hash(type, id, parentId);
}

enum SyncIssueKind {
  conflict,
  rejected,
  stale,
  pendingDelete,
  pendingMove,
  incomplete,
  pendingUpload,
  pullError,
}

/// 可见记账事项的业务摘要；只在读取该事项明细时查询，不进入常驻同步摘要。
class SyncIssueAccountingContext {
  const SyncIssueAccountingContext({
    this.bookName,
    this.categoryName,
    this.categoryId,
    this.amount,
    this.currencyCode,
    this.happenedAt,
  });

  final String? bookName;
  final String? categoryName;
  final String? categoryId;
  final String? amount;
  final String? currencyCode;
  final DateTime? happenedAt;
}

/// 同步事项与可见详情共用的事实投影，页面通过实体类型选择对应操作。
class SyncIssue {
  const SyncIssue({
    required this.id,
    required this.kind,
    required this.target,
    required this.title,
    this.reason,
    this.rejectionCode,
    this.local,
    this.remote,
    this.recovery = false,
    this.deletion = false,
    this.count = 1,
    this.resolutionPending = false,
    this.decisionVersion,
    this.accountingContext,
    this.uploadOutcomeUnknown = false,
  });
  final String id;
  final SyncIssueKind kind;
  final SyncTarget target;
  final String title;
  final String? reason;

  /// 服务端稳定拒绝码，用于明确归因，不依赖展示文案推断业务状态。
  final String? rejectionCode;
  final Map<String, dynamic>? local, remote;
  final bool recovery;
  final bool deletion;
  final int count;

  /// 已冻结确认尚未收到明确回执时，只能重试原决策。
  final bool resolutionPending;

  /// 用户正在比较的候选与云版本；确认时原样交还服务校验。
  final String? decisionVersion;

  /// 已可见交易的分类、金额、日期和账本名称，供用户识别待处理记录。
  final SyncIssueAccountingContext? accountingContext;

  /// 已发送但没有确定回执的请求必须沿用原身份确认，不能编辑后替换请求。
  final bool uploadOutcomeUnknown;
}

/// 删除重试固定完整快照和会话；确认期间变化时重新预览，不静默扩大删除范围。
class SyncDeletePreview {
  SyncDeletePreview({
    required this.target,
    required this.accountId,
    required this.generation,
    required this.branchKey,
    required this.syncId,
    required this.cursor,
    required this.name,
    required this.count,
    required this.gone,
    required this.moving,
    required this.snapshotJson,
  });
  final SyncTarget target;
  final String accountId;
  final int? generation;
  final String? branchKey, syncId, cursor;
  final String name;
  final int count;

  final bool gone, moving;
  final String snapshotJson;
}
