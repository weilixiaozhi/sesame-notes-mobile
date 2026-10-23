import 'push_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 push 处理器所需回调，所有跨域协作通过共享端口完成。
mixin PushSyncAssembly on SyncAssemblyContext {
  /// 装配按实体顺序处理待推队列、冻结请求与确认结果，延迟回调避免构造期间执行其他处理器。
  @override
  late final SyncPushCoordinator pushCoordinator = SyncPushCoordinator(
    runtime,
    SyncPushCoordinatorPorts(
      categoryApplyOutcome: (change, outcome, account) =>
          categoryConflicts.applyOutcome(change, outcome, account),
      accountingApplyPushOutcomes: (batch, outcomes, accountId) =>
          accountingHandler.applyPushOutcomes(batch, outcomes, accountId),
      accountingEnsureReferencedCategoryRegistrations: (accountId, changes) =>
          accountingHandler.ensureReferencedCategoryRegistrations(
            accountId,
            changes,
          ),
      accountingSyncIdsForLedgers: (ledgerIds) =>
          accountingHandler.syncIdsForLedgers(ledgerIds),
      daysApplyDayPushOutcome: (change, outcome, accountId) =>
          daysHandler.applyDayPushOutcome(change, outcome, accountId),
      daysFreezeDayChange: (source, accountId) =>
          daysHandler.freezeDayChange(source, accountId),
      daysProtectDayBook: (id, accountId, {stale = false, deleted = false}) =>
          daysHandler.protectDayBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      fitnessApplyFitnessPushOutcome: (change, outcome, account) =>
          fitnessHandler.applyFitnessPushOutcome(change, outcome, account),
      fitnessFitnessSpace: (id) => fitnessHandler.fitnessSpace(id),
      fitnessFreezeFitnessChange: (source, account) =>
          fitnessHandler.freezeFitnessChange(source, account),
      fitnessProtectFitnessSpace:
          (id, account, {stale = false, deleted = false}) => fitnessHandler
              .protectFitnessSpace(id, account, stale: stale, deleted: deleted),
      memosApplyMemoPushOutcome: (change, outcome, accountId) =>
          memosHandler.applyMemoPushOutcome(change, outcome, accountId),
      memosFreezeMemoChange: (source, accountId) =>
          memosHandler.freezeMemoChange(source, accountId),
      memosMemoBook: (id) => memosHandler.memoBook(id),
      memosProtectMemoBook: (id, accountId, {stale = false, deleted = false}) =>
          memosHandler.protectMemoBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      operationsClearTargetPending: (target, account, {retire = false}) =>
          operationsHandler.clearTargetPending(target, account, retire: retire),
      operationsQuarantineLedger:
          (id, account, {stale = false, deleted = false, remoteDeletedAt}) =>
              operationsHandler.quarantineLedger(
                id,
                account,
                stale: stale,
                deleted: deleted,
                remoteDeletedAt: remoteDeletedAt,
              ),
      operationsScopeDeleted: (target, syncId) =>
          operationsHandler.scopeDeleted(target, syncId),
      payloadCategoryLevelOf: (rawPayload) =>
          payloadCodec.categoryLevelOf(rawPayload),
      payloadToChangeInner: (ch, syncIdByLedger) =>
          payloadCodec.toChangeInner(ch, syncIdByLedger),
      transfersPublishTransferCopy: (target, id, account) =>
          transferHandler.publishTransferCopy(target, id, account),
      transfersTransferCopy: (target, account, operation) =>
          transferHandler.transferCopy(target, account, operation),
      transfersTransferSource: (target, account) =>
          transferHandler.transferSource(target, account),
    ),
    dayRepository: dayRepository,
    fitnessEnabled: fitnessEnabled,
    memoRepository: memoRepository,
  );
}
