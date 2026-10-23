import 'operations_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 operations 处理器所需回调，所有跨域协作通过共享端口完成。
mixin OperationsSyncAssembly on SyncAssemblyContext {
  /// 装配删除、恢复和本地保护等同步数据操作，延迟回调避免构造期间执行其他处理器。
  @override
  late final SyncDataOperations operationsHandler = SyncDataOperations(
    runtime,
    SyncDataOperationsPorts(
      accountingApplyFullSnapshot: (ledgerId, data, {required accountId}) =>
          accountingHandler.applyFullSnapshot(
            ledgerId,
            data,
            accountId: accountId,
          ),
      accountingLocalStateProtectionKey: (ledgerId) =>
          accountingHandler.localStateProtectionKey(ledgerId),
      accountingProtectLocalStateAsFork: (ledgerId) =>
          accountingHandler.protectLocalStateAsFork(ledgerId),
      accountingRequireStaleBinding: (ledgerId) =>
          accountingHandler.requireStaleBinding(ledgerId),
      daysApplyDayFull: (snapshot, accountId) =>
          daysHandler.applyDayFull(snapshot, accountId),
      daysProtectDayBook: (id, accountId, {stale = false, deleted = false}) =>
          daysHandler.protectDayBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      daysRequiredDayRepository: () => daysHandler.requiredDayRepository,
      facadeFull: ({required ledgerId}) => full(ledgerId: ledgerId),
      facadeFullDayBook: ({required dayBookId, refreshPendingDelete = false}) =>
          fullDayBook(
            dayBookId: dayBookId,
            refreshPendingDelete: refreshPendingDelete,
          ),
      facadeFullFitnessSpace: (spaceId) => fullFitnessSpace(spaceId),
      facadeFullMemoBook: ({required memoBookId}) =>
          fullMemoBook(memoBookId: memoBookId),
      fitnessFitnessEntity: (id) => fitnessHandler.fitnessEntity(id),
      fitnessFitnessSpace: (id) => fitnessHandler.fitnessSpace(id),
      fitnessFitnessSpaceRepository: () =>
          fitnessHandler.fitnessSpaceRepository,
      fitnessFullFitness: ({required spaceId, minimumCursor, downloaded}) =>
          fitnessHandler.fullFitness(
            spaceId: spaceId,
            minimumCursor: minimumCursor,
            downloaded: downloaded,
          ),
      fitnessProtectFitnessSpace:
          (id, account, {stale = false, deleted = false}) => fitnessHandler
              .protectFitnessSpace(id, account, stale: stale, deleted: deleted),
      memosApplyMemoFull: (full, accountId) =>
          memosHandler.applyMemoFull(full, accountId),
      memosMemoBook: (id) => memosHandler.memoBook(id),
      memosProtectMemoBook: (id, accountId, {stale = false, deleted = false}) =>
          memosHandler.protectMemoBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      projectionApplyLedger: (id, action, p, eventUpdatedAt) =>
          projectionHandler.applyLedger(id, action, p, eventUpdatedAt),
      transfersPublishCopyOnly: (target, id) =>
          transferHandler.publishCopyOnly(target, id),
      transfersPublishTransferCopy: (target, id, account) =>
          transferHandler.publishTransferCopy(target, id, account),
      transfersQueueScopeDelete: (target, account, {expectedFullCursor}) =>
          transferHandler.queueScopeDelete(
            target,
            account,
            expectedFullCursor: expectedFullCursor,
          ),
      transfersTransferCopy: (target, account, operation) =>
          transferHandler.transferCopy(target, account, operation),
      transfersTransferSource: (target, account) =>
          transferHandler.transferSource(target, account),
      transfersTransferToLocal: (target, {required move, expectedFullCursor}) =>
          transferHandler.transferToLocal(
            target,
            move: move,
            expectedFullCursor: expectedFullCursor,
          ),
      transfersWriteTransferCopy:
          (target, account, operation, {required hidden}) => transferHandler
              .writeTransferCopy(target, account, operation, hidden: hidden),
    ),
    downloadStore: downloadStore,
    localSelfIdLoader: localSelfIdLoader,
    memoRepository: memoRepository,
    repo: repo,
  );
}
