import 'transfers_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 transfers 处理器所需回调，所有跨域协作通过共享端口完成。
mixin TransfersSyncAssembly on SyncAssemblyContext {
  /// 装配跨本复制和搬迁的持久快照与发布步骤，延迟回调避免构造期间执行其他处理器。
  @override
  late final BookTransferHandler transferHandler = BookTransferHandler(
    runtime,
    BookTransferHandlerPorts(
      accountingFullLedger: ({required ledgerId}) =>
          accountingHandler.fullLedger(ledgerId: ledgerId),
      daysRefreshDayMoveCopy: (sourceId, copyId) =>
          daysHandler.refreshDayMoveCopy(sourceId, copyId),
      daysRequiredDayRepository: () => daysHandler.requiredDayRepository,
      facadeFullDayBook: ({required dayBookId, refreshPendingDelete = false}) =>
          fullDayBook(
            dayBookId: dayBookId,
            refreshPendingDelete: refreshPendingDelete,
          ),
      facadeFullFitnessSpace: (spaceId) => fullFitnessSpace(spaceId),
      facadeFullMemoBook: ({required memoBookId}) =>
          fullMemoBook(memoBookId: memoBookId),
      fitnessFitnessSpace: (id) => fitnessHandler.fitnessSpace(id),
      fitnessFitnessSpaceRepository: () =>
          fitnessHandler.fitnessSpaceRepository,
      memosMemoBook: (id) => memosHandler.memoBook(id),
      pushPushPending: (account, {target}) =>
          pushCoordinator.pushPending(account, target: target),
    ),
    localSelfIdLoader: localSelfIdLoader,
    memoRepository: memoRepository,
    repo: repo,
  );
}
