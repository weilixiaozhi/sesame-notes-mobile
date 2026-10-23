import 'accounting_handler.dart';
import 'projection_handler.dart';
import 'payload_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 accounting 处理器所需回调，所有跨域协作通过共享端口完成。
mixin AccountingSyncAssembly on SyncAssemblyContext {
  /// 装配账号记账目录、账本快照、保护副本和记账推送回执处理，延迟回调避免构造期间执行其他处理器。
  @override
  late final AccountingSyncHandler accountingHandler = AccountingSyncHandler(
    runtime,
    AccountingSyncHandlerPorts(
      operationsQuarantineLedger:
          (id, account, {stale = false, deleted = false, remoteDeletedAt}) =>
              operationsHandler.quarantineLedger(
                id,
                account,
                stale: stale,
                deleted: deleted,
                remoteDeletedAt: remoteDeletedAt,
              ),
      projectionApplyLedgerArchive:
          (
            ledgerId, {
            required archivedAt,
            required updatedAt,
            required remoteDeviceId,
            required serverCursor,
            confirmed = false,
          }) => projectionHandler.applyLedgerArchive(
            ledgerId,
            archivedAt: archivedAt,
            updatedAt: updatedAt,
            remoteDeviceId: remoteDeviceId,
            serverCursor: serverCursor,
            confirmed: confirmed,
          ),
      projectionHasPendingChange: (type, entityId) =>
          projectionHandler.hasPendingChange(type, entityId),
      projectionUpdateServerRevision: (entityId, revision) =>
          projectionHandler.updateServerRevision(entityId, revision),
      projectionUpsertCategory: (cat, {required accountId}) =>
          projectionHandler.upsertCategory(cat, accountId: accountId),
      projectionApplyCategory: (id, action, payload, {eventUpdatedAt}) =>
          projectionHandler.applyCategory(
            id,
            action,
            payload,
            eventUpdatedAt: eventUpdatedAt,
          ),
      projectionUpsertMember: (m) => projectionHandler.upsertMember(m),
      projectionUpsertOverride: (ov, {required accountId}) =>
          projectionHandler.upsertOverride(ov, accountId: accountId),
      projectionUpsertRecurring: (rt) => projectionHandler.upsertRecurring(rt),
      projectionUpsertTransaction: (tx) =>
          projectionHandler.upsertTransaction(tx),
    ),
    downloadStore: downloadStore,
    localSelfIdLoader: localSelfIdLoader,
    repo: repo,
  );

  /// 装配记账远端实体到本地表的版本化投影，延迟回调避免构造期间执行其他处理器。
  @override
  late final AccountingProjection projectionHandler = AccountingProjection(
    runtime,
    AccountingProjectionPorts(
      accountingBlockedLedgerIds: (candidateIds) =>
          accountingHandler.blockedLedgerIds(candidateIds),
      operationsQuarantineLedger:
          (id, account, {stale = false, deleted = false, remoteDeletedAt}) =>
              operationsHandler.quarantineLedger(
                id,
                account,
                stale: stale,
                deleted: deleted,
                remoteDeletedAt: remoteDeletedAt,
              ),
      payloadCategoryLevel: (value) => payloadCodec.categoryLevel(value),
      payloadDeleteTime: (p) => payloadCodec.deleteTime(p),
    ),
  );

  /// 装配记账实体的同步载荷与金额规范化，延迟回调避免构造期间执行其他处理器。
  @override
  late final AccountingPayloadCodec payloadCodec = AccountingPayloadCodec(
    runtime,
  );
}
