/// 变更记录器抽象（data 层端口 / port）。
///
/// 设计意图：本地 Repository 写操作后需要登记一条"待同步变更"，
/// 但变更追踪的具体实现（sync_changes 表写入）属于 cloud/sync 层。
/// data 层若直接 import cloud 层实现会形成上行依赖（data → cloud），
/// 违反分层方向。故在此定义抽象接口，由 cloud/sync 的实现注入
/// （依赖倒置，注入点见 providers/core/database_providers.dart）。
///
/// 形状对齐冻结同步契约：entity_id 为 UUID、action 仅 upsert/delete、
/// payload 为完整实体 JSON、updated_at 为 UTC 时间。
library;

/// 单条待同步变更（契约 Push change 的本地形状）。
typedef SyncChangeRecord = ({
  String entityType,
  String entityId,
  String? ledgerId,
  String action,
  String payload,
  DateTime updatedAt,
});

abstract class ChangeRecorder {
  /// 记录一条 user-global 实体（category / exchange_rate_override）的变更。
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  });

  /// 记录一条 ledger-scoped 实体（ledger / transaction / recurring /
  /// virtual_user）的变更。[ledgerId] 为账本 UUID。
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  });

  /// 批量记录 ledger-scoped 变更。
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes});

  /// 批量记录 user-global 实体（category / exchange_rate_override）的变更。
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  });
}
