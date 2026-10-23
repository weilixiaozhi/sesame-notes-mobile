import 'fitness_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 fitness 处理器所需回调，所有跨域协作通过共享端口完成。
mixin FitnessSyncAssembly on SyncAssemblyContext {
  /// 装配健身空间与实体的版本化同步和完整性维护，延迟回调避免构造期间执行其他处理器。
  @override
  late final FitnessSyncHandler fitnessHandler = FitnessSyncHandler(
    runtime,
    FitnessSyncHandlerPorts(
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
      pushApplyPendingOutcome: (change, outcome, account) =>
          pushCoordinator.applyPendingOutcome(change, outcome, account),
    ),
    fitnessEnabled: fitnessEnabled,
  );
}
