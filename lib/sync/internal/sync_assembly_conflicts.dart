import 'conflicts_handler.dart';

import 'sync_assembly_context.dart';

/// 集中装配 conflicts 处理器所需回调，所有跨域协作通过共享端口完成。
mixin ConflictsSyncAssembly on SyncAssemblyContext {
  /// 装配统一处理本地与远端版本的冲突选择，延迟回调避免构造期间执行其他处理器。
  @override
  late final SyncConflictHandler conflictHandler = SyncConflictHandler(
    runtime,
    SyncConflictHandlerPorts(
      daysResolveDayConflict: (conflict, accountId, {required keepLocal}) =>
          daysHandler.resolveDayConflict(
            conflict,
            accountId,
            keepLocal: keepLocal,
          ),
      fitnessApplyFitnessSpacePayload: (id, payload, account) =>
          fitnessHandler.applyFitnessSpacePayload(id, payload, account),
      fitnessResolveFitnessConflict:
          (conflict, account, {required keepLocal}) => fitnessHandler
              .resolveFitnessConflict(conflict, account, keepLocal: keepLocal),
      memosApplyMemoBookPayload: (id, payload, accountId) =>
          memosHandler.applyMemoBookPayload(id, payload, accountId),
      memosResolveMemoConflict: (conflict, account, {required keepLocal}) =>
          memosHandler.resolveMemoConflict(
            conflict,
            account,
            keepLocal: keepLocal,
          ),
      operationsProtectTargetToLocal: (target) =>
          operationsHandler.protectTargetToLocal(target),
      operationsResolveLedgerConflict: (conflict, account) =>
          operationsHandler.resolveLedgerConflict(conflict, account),
      payloadLocalTxPayload: (tx) => payloadCodec.localTxPayload(tx),
      projectionApplyTransaction: (id, action, p) =>
          projectionHandler.applyTransaction(id, action, p),
    ),
  );
}
