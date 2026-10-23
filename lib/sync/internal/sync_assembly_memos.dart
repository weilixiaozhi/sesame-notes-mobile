import 'memos_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 memos 处理器所需回调，所有跨域协作通过共享端口完成。
mixin MemosSyncAssembly on SyncAssemblyContext {
  /// 装配笔记本与条目的拉取、推送、保护和冲突处理，延迟回调避免构造期间执行其他处理器。
  @override
  late final MemoSyncHandler memosHandler = MemoSyncHandler(
    runtime,
    MemoSyncHandlerPorts(
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
      pushPushPending: (account, {target}) =>
          pushCoordinator.pushPending(account, target: target),
    ),
    memoRepository: memoRepository,
  );
}
