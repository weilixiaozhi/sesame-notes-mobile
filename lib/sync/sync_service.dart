import 'internal/sync_assembly_categories.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/sync/models/ledger_sync_state.dart';
import 'package:sesame_notes/data/models/day_book.dart' as day_books;
import 'package:sesame_notes/sync/models/sync_domain.dart';

import 'internal/sync_assembly_context.dart';
import 'internal/sync_assembly_accounting.dart';
import 'internal/sync_assembly_days.dart';
import 'internal/sync_assembly_memos.dart';
import 'internal/sync_assembly_fitness.dart';
import 'internal/sync_assembly_pull.dart';
import 'internal/sync_assembly_push.dart';
import 'internal/sync_assembly_transfers.dart';
import 'internal/sync_assembly_conflicts.dart';
import 'internal/sync_assembly_operations.dart';
export 'package:sesame_notes/sync/models/sync_domain.dart' show SyncDomain;

/// 对外同步用例入口，装配细节按领域和协调职责分别维护。
class SyncService extends SyncAssemblyContext
    with
        AccountingSyncAssembly,
        CategoriesSyncAssembly,
        DaysSyncAssembly,
        MemosSyncAssembly,
        FitnessSyncAssembly,
        PullSyncAssembly,
        PushSyncAssembly,
        TransfersSyncAssembly,
        ConflictsSyncAssembly,
        OperationsSyncAssembly {
  /// 注入同步依赖，处理器按需初始化并共享同一会话守卫。
  SyncService({
    required super.client,
    required super.db,
    required super.deviceId,
    super.apiOverride,
    super.repo,
    super.dayRepository,
    super.memoRepository,
    super.fitnessEnabled = false,
    super.localSelfIdLoader,
    required super.currentAccountIdGetter,
    super.sessionGenerationGetter,
    super.downloadStore,
  });

  /// 通过所属域执行transferToLocal，保持统一的同步入口。
  @override
  Future<String> transferToLocal(
    SyncTarget target, {
    required bool move,
    String? expectedFullCursor,
  }) => transferHandler.transferToLocal(
    target,
    move: move,
    expectedFullCursor: expectedFullCursor,
  );

  /// 通过所属域执行prepareScopeDelete，保持统一的同步入口。
  @override
  Future<SyncDeletePreview> prepareScopeDelete(SyncTarget target) =>
      operationsHandler.prepareScopeDelete(target);

  /// 通过所属域执行confirmScopeDelete，保持统一的同步入口。
  @override
  Future<void> confirmScopeDelete(SyncDeletePreview preview) =>
      operationsHandler.confirmScopeDelete(preview);

  /// 通过所属域执行retryRejectedChange，保持统一的同步入口。
  @override
  Future<void> retryRejectedChange(String id) =>
      operationsHandler.retryRejectedChange(id);

  /// 完整本地保护不要求失效绑定重新联网；每个源范围使用稳定操作身份避免重复副本。
  @override
  Future<String> protectTargetToLocal(SyncTarget target) =>
      operationsHandler.protectTargetToLocal(target);

  /// 通过所属域执行refreshTarget，保持统一的同步入口。
  @override
  Future<void> refreshTarget(SyncTarget target) =>
      operationsHandler.refreshTarget(target);

  /// 通过所属域执行copyDayBookToLocal，保持统一的同步入口。
  @override
  Future<day_books.DayBook> copyDayBookToLocal({required String dayBookId}) =>
      daysHandler.copyDayBookToLocal(dayBookId: dayBookId);

  /// 通过所属域执行moveDayBookToLocal，保持统一的同步入口。
  @override
  Future<day_books.DayBook> moveDayBookToLocal({required String dayBookId}) =>
      daysHandler.moveDayBookToLocal(dayBookId: dayBookId);

  /// 建立账号日子目录屏障，完整快照实现复用同一事务边界。
  @override
  Future<void> discoverDayBooks() => daysHandler.discoverDayBooks();

  /// 执行discoverMemoBooks对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> discoverMemoBooks() => memosHandler.discoverMemoBooks();

  /// 执行discoverFitnessSpaces对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> discoverFitnessSpaces() =>
      pullCoordinator.discoverBookDirectory(SyncDomain.fitness);

  /// 执行fullFitnessSpace对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> fullFitnessSpace(String spaceId) =>
      fitnessHandler.fullFitness(spaceId: spaceId);

  /// 执行fullMemoBook对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> fullMemoBook({required String memoBookId}) =>
      memosHandler.fullMemoBook(memoBookId);

  /// 显式单本恢复不提升任一域水位。
  @override
  Future<void> fullDayBook({
    required String dayBookId,
    bool refreshPendingDelete = false,
  }) => daysHandler.fullDayBook(
    dayBookId: dayBookId,
    refreshPendingDelete: refreshPendingDelete,
  );

  /// 使用账号完整快照恢复记账域及账号共享实体。
  @override
  Future<void> accountingFull() =>
      pullCoordinator.discoverBookDirectory(SyncDomain.accounting);

  /// 推送本地待同步变更（分批 ≤500，契约上限）。
  ///
  /// 同实体 FIFO：存在 OPEN 冲突的实体暂停推送——前序 mutation
  /// 冲突时后序不得继续发送，等待用户解决（冲突 UI）。
  @override
  Future<void> push() => pushCoordinator.push();

  /// 完整轮次先补齐未初始化域，仅推送已就绪域，再由同一轮扫描消费增量。
  /// 任一域完整快照失败时保留该域待办；其他域仍完成同步，最后传播原始失败。
  Future<int> synchronize() => pullCoordinator.pullDomains(
    pushReadyDomains: (readyDomains) =>
        pushCoordinator.push(readyDomains: readyDomains),
  );

  /// 权威查询源账本在服务端的存活状态（云转本地移动的 ignored 复核专用）：
  /// 404 = 已 tombstone/不可访问（视为已删除）；412 = 时间线不一致但账本存活。
  @override
  Future<({bool deleted})> fetchLedgerRemoteStatus(String ledgerId) =>
      accountingHandler.fetchLedgerRemoteStatus(ledgerId);

  /// 分类确认绑定用户看到的云版本，并独立于通用副本保护策略。
  Future<void> resolveCategoryConflict(
    String id, {
    required bool keepLocal,
    required String expectedDecisionVersion,
    bool restoreDeleted = false,
  }) => categoryConflicts.resolve(
    id,
    keepLocal: keepLocal,
    expectedDecisionVersion: expectedDecisionVersion,
    restoreDeleted: restoreDeleted,
  );

  /// 重放分类确认的持久化原请求。
  Future<void> retryCategoryConflictResolution(String id) =>
      categoryConflicts.retry(id);

  /// 拉取本账号多设备未决与已解决候选。
  Future<void> refreshCategoryConflicts() => categoryConflicts.refresh();

  /// 执行resolveConflictKeepLocal对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> resolveConflictKeepLocal(String conflictId) =>
      conflictHandler.resolveConflict(conflictId, keepLocal: true);

  /// 执行resolveConflictAdoptRemote对应的同步步骤，沿用所属域的身份与事务规则。
  @override
  Future<void> resolveConflictAdoptRemote(String conflictId) =>
      conflictHandler.resolveConflict(conflictId, keepLocal: false);

  /// 保护当前本地分支后按云端时间线重建；保护与替换必须在同一事务提交。
  @override
  Future<void> abandonLocalChanges({required String ledgerId}) async {
    await accountingHandler.requireStaleBinding(ledgerId);
    await operationsHandler.refreshTarget(SyncTarget('ledger', ledgerId));
  }

  /// 增量拉取并应用（游标全局，与账本无关）；返回处理条数。
  @override
  Future<int> pull() => pullCoordinator.pullDomains();

  /// 补齐指定账本的整本快照，域级同步水位由目录屏障和增量拉取维护。
  @override
  Future<void> full({required String ledgerId}) async {
    await accountingHandler.fullLedger(ledgerId: ledgerId);
  }

  /// 从持久来源信息确认当前分支已被复制；失效绑定本身不表示保护成功。
  @override
  Future<LocalStateProtection> localStateProtection(String ledgerId) =>
      accountingHandler.localStateProtection(ledgerId);
}
