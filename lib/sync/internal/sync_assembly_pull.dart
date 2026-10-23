import 'pull_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 pull 处理器所需回调，所有跨域协作通过共享端口完成。
mixin PullSyncAssembly on SyncAssemblyContext {
  /// 装配按业务域协调目录发现、分页拉取和游标推进，延迟回调避免构造期间执行其他处理器。
  @override
  late final SyncPullCoordinator pullCoordinator = SyncPullCoordinator(
    runtime,
    SyncPullCoordinatorPorts(
      accountingApplyFullSnapshot: (ledgerId, data, {required accountId}) =>
          accountingHandler.applyFullSnapshot(
            ledgerId,
            data,
            accountId: accountId,
          ),
      accountingBlockedLedgerIds: (candidateIds) =>
          accountingHandler.blockedLedgerIds(candidateIds),
      accountingApplyDirectoryGlobals: (body, accountId) =>
          accountingHandler.applyAccountingDirectoryGlobals(body, accountId),
      daysApplyDayChange: (change, accountId) =>
          daysHandler.applyDayChange(change, accountId),
      daysApplyDayFull: (snapshot, accountId) =>
          daysHandler.applyDayFull(snapshot, accountId),
      daysDownloadDayBook: (id, accountId, {knownSyncId}) =>
          daysHandler.downloadDayBook(id, accountId, knownSyncId: knownSyncId),
      accountingPrepareDownloads: (ids, changes, accountId) =>
          accountingHandler.prepareAccountingDownloads(ids, changes, accountId),
      daysProtectDayBook: (id, accountId, {stale = false, deleted = false}) =>
          daysHandler.protectDayBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      daysSaveDayCursor: (cursor) => daysHandler.saveDayCursor(cursor),
      facadeAccountingFull: () => accountingFull(),
      facadeDiscoverDayBooks: () => discoverDayBooks(),
      facadeDiscoverFitnessSpaces: () => discoverFitnessSpaces(),
      facadeDiscoverMemoBooks: () => discoverMemoBooks(),
      fitnessApplyFitnessSpacePayload: (id, payload, account) =>
          fitnessHandler.applyFitnessSpacePayload(id, payload, account),
      fitnessFullFitness: ({required spaceId, minimumCursor, downloaded}) =>
          fitnessHandler.fullFitness(
            spaceId: spaceId,
            minimumCursor: minimumCursor,
            downloaded: downloaded,
          ),
      fitnessProtectFitnessSpace:
          (id, account, {stale = false, deleted = false}) => fitnessHandler
              .protectFitnessSpace(id, account, stale: stale, deleted: deleted),
      fitnessPullFitnessPage: (changes, account, cursor) =>
          fitnessHandler.pullFitnessPage(changes, account, cursor),
      fitnessSaveFitnessCursor: (cursor, account) =>
          fitnessHandler.saveFitnessCursor(cursor, account),
      memosApplyMemoBookPayload: (id, payload, accountId) =>
          memosHandler.applyMemoBookPayload(id, payload, accountId),
      memosApplyMemoChange: (change, accountId) =>
          memosHandler.applyMemoChange(change, accountId),
      memosApplyMemoFull: (full, accountId) =>
          memosHandler.applyMemoFull(full, accountId),
      memosDownloadMemoBook: (id, accountId, {knownSyncId}) => memosHandler
          .downloadMemoBook(id, accountId, knownSyncId: knownSyncId),
      memosMemoBook: (id) => memosHandler.memoBook(id),
      memosProtectMemoBook: (id, accountId, {stale = false, deleted = false}) =>
          memosHandler.protectMemoBook(
            id,
            accountId,
            stale: stale,
            deleted: deleted,
          ),
      memosSaveMemoCursor: (cursor) => memosHandler.saveMemoCursor(cursor),
      operationsQuarantineLedger:
          (id, account, {stale = false, deleted = false, remoteDeletedAt}) =>
              operationsHandler.quarantineLedger(
                id,
                account,
                stale: stale,
                deleted: deleted,
                remoteDeletedAt: remoteDeletedAt,
              ),
      projectionApplyChange: (change) => projectionHandler.applyChange(change),
    ),
    dayRepository: dayRepository,
    downloadStore: downloadStore,
    fitnessEnabled: fitnessEnabled,
    memoRepository: memoRepository,
    repo: repo,
  );
}
