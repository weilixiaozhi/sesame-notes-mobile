/// 变更记录器抽象（data 层端口 / port）。
///
/// Repository 对需要同步的写操作在同一事务内登记待同步变更。
/// data 定义端口，sync/change_recorder_impl.dart 实现 sync_changes 写入；
/// shared/providers/database_providers.dart 将实现注入仓储，
/// data 不直接依赖 sync 实现。
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
  /// 健身空间与其他父本同事务登记完整 CAS 版本。
  Future<void> recordFitnessChange({
    required String entityType,
    required String entityId,
    required String fitnessSpaceId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) => throw UnsupportedError('FITNESS_SYNC_UNAVAILABLE');

  Future<void> recordMemoChange({
    required String entityType,
    required String entityId,
    required String memoBookId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) => throw UnsupportedError('MEMO_SYNC_UNAVAILABLE');

  /// 日子变更携带明确父本与账号，不能作为无父依赖的账号全局数据上传。
  Future<void> recordDayChange({
    required String entityType,
    required String entityId,
    required String dayBookId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) => throw UnsupportedError('当前变更登记器未接入日子同步');

  /// 记录一条 user-global 实体（category / exchange_rate_override）的变更。
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  });

  /// 记录一条 ledger-scoped 实体（ledger / transaction /
  /// recurring_transaction / member）的变更。[ledgerId] 为账本 UUID。
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
