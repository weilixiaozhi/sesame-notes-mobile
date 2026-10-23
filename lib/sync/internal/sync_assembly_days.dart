import 'days_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 days 处理器所需回调，所有跨域协作通过共享端口完成。
mixin DaysSyncAssembly on SyncAssemblyContext {
  /// 装配日子本与记录的拉取、推送、保护和冲突处理，延迟回调避免构造期间执行其他处理器。
  @override
  late final DaySyncHandler daysHandler = DaySyncHandler(
    runtime,
    DaySyncHandlerPorts(
      operationsQuarantinePrivateBook:
          (
            target,
            account, {
            required stale,
            required deleted,
            required book,
            required table,
            required contents,
            required parentColumn,
            required protect,
          }) => operationsHandler.quarantinePrivateBook(
            target,
            account,
            stale: stale,
            deleted: deleted,
            book: book,
            table: table,
            contents: contents,
            parentColumn: parentColumn,
            protect: protect,
          ),
      pullDiscoverBookDirectory: (domain) =>
          pullCoordinator.discoverBookDirectory(domain),
      transfersTransferToLocal: (target, {required move, expectedFullCursor}) =>
          transferHandler.transferToLocal(
            target,
            move: move,
            expectedFullCursor: expectedFullCursor,
          ),
    ),
    dayRepository: dayRepository,
  );
}
