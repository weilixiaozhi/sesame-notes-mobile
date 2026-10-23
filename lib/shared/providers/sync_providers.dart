import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/data/models/category_conflict_state.dart';
import 'package:sesame_notes/shared/application/ports/mutation_executor.dart';
import 'package:sesame_notes/data/db.dart' show SyncPullErrorsCompanion;
import '../../data/models/private_book.dart';
export '../../data/models/private_book.dart' show BookDirectoryStatus;
import 'package:sesame_notes/data/repositories/local/sync_scope.dart';
import 'dart:async';
import 'dart:convert';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/data/models/day_book.dart' as days;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';
import 'package:sesame_notes/sync/sync_service.dart';
// 只取展示模型：本文件已 import 生成 API 的 Ledger，全量 barrel 会撞名。
import 'package:sesame_notes/data/models.dart' show SyncRejectionView;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_sync_run_feedback_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 当前账本及当前账号全局实体的拒绝记录；同步结束与本地编辑后重新读取持久状态。
final ledgerSyncRejectionsProvider = FutureProvider.autoDispose
    .family<List<SyncRejectionView>, String>((ref, ledgerId) async {
      ref.watch(syncRunTickProvider);
      ref.watch(dataChangeSignalProvider);
      final session = ref.watch(authSessionProvider);
      if (session == null || ledgerId.isEmpty) return const [];
      final db = ref.watch(databaseProvider);
      try {
        final ledger = await (db.select(
          db.ledgers,
        )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
        if (ledger == null || ledger.storageMode != 'cloud') return const [];
        final rows =
            await (db.select(db.syncChanges)..where(
                  (c) =>
                      accountingSyncScope(c.entityType, c.ledgerId, [
                        ledgerId,
                      ]) &
                      c.accountId.equals(session.userId) &
                      c.pushedAt.isNull() &
                      c.rejectionReason.isNotNull(),
                ))
                .get();
        return [
          for (final row in rows)
            (
              entityId: row.entityId,
              entityType: row.entityType,
              label: _rejectionLabel(row.entityType, row.payload),
              reason: row.rejectionReason!,
            ),
        ];
      } catch (error, stackTrace) {
        logger.error(
          'SyncProviders',
          '读取未上传记录失败: $ledgerId',
          error,
          stackTrace,
        );
        rethrow;
      }
    });

/// 摘要只用于本地展示；格式异常时仍保留定位与处理入口，不记录载荷内容。
String _rejectionLabel(String entityType, String payload) {
  try {
    final values = jsonDecode(payload) as Map<String, dynamic>;
    final name = values['note'] ?? values['name'] ?? values['display_name'];
    if (name is String && name.trim().isNotEmpty) return name;
  } catch (error) {
    logger.warning(
      'SyncProviders',
      '未上传记录摘要不可读: $entityType (${error.runtimeType})',
    );
  }
  return switch (entityType) {
    'transaction' => '交易记录',
    'category' => '分类',
    'member' => '成员',
    'ledger' => '账本',
    'recurring_transaction' => '周期账单',
    'exchange_rate_override' => '汇率',
    _ => '记录',
  };
}

/// 同步服务实例：设备标识必须与会话绑定设备一致（push 校验），
/// 登录后 deviceId 即本地预生成、服务端原样接受的持久化设备 id；
/// 未登录时用本地占位 id 兜底（不会真正发起 push/pull）。
final syncServiceProvider = Provider<SyncService>((ref) {
  ref.watch(authIdentityGenerationProvider);
  ref.watch(cloudCapabilityProvider.select((value) => value.canSync));
  ref.watch(cloudOperationGenerationProvider);
  final client = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  // 令牌刷新沿用在途服务；只有账号或设备变化才重新装配，避免旧服务持有失效 Ref。
  final account = ref.watch(
    authSessionProvider.select(
      (session) => (session?.userId, session?.deviceId),
    ),
  );
  return SyncService(
    client: client,
    db: db,
    deviceId: account.$2 ?? localDeviceId,
    // 412 时把本地状态保护为 Local Safety Fork（绝不默认放弃本地修改）
    repo: LocalLedgerRepository(db),
    dayRepository: ref.watch(dayRepositoryProvider),
    memoRepository: ref.watch(memoRepositoryProvider),
    fitnessEnabled: true,
    localSelfIdLoader: () => ref.read(localSelfIdProvider.future),
    currentAccountIdGetter: () =>
        ref.mounted && ref.read(cloudCapabilityProvider).canSync
        ? ref.read(authSessionProvider)?.userId
        : null,
    sessionGenerationGetter: () =>
        ref.mounted ? ref.read(cloudOperationGenerationProvider) : -1,
    downloadStore: ref.watch(cloudLedgerDownloadStoreProvider),
  );
});

/// 同步编排器：提供 push / pull / full 用例，并返回动作结果。
final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) => SyncCoordinator(ref),
);

/// 首次云目录发现状态；页面不能把未完成发现当成没有云本。

final dayDirectoryStatusProvider =
    NotifierProvider<BookDirectoryStatusNotifier, BookDirectoryStatus>(
      BookDirectoryStatusNotifier.new,
    );
final memoDirectoryStatusProvider =
    NotifierProvider<BookDirectoryStatusNotifier, BookDirectoryStatus>(
      BookDirectoryStatusNotifier.new,
    );

final fitnessDirectoryStatusProvider =
    NotifierProvider<BookDirectoryStatusNotifier, BookDirectoryStatus>(
      BookDirectoryStatusNotifier.new,
    );

/// 身份代次变化时重置目录提示，刷新令牌不丢失当前状态。
class BookDirectoryStatusNotifier extends Notifier<BookDirectoryStatus> {
  @override
  BookDirectoryStatus build() {
    ref.watch(authIdentityGenerationProvider);
    final canUseCloudBooks = ref.watch(
      cloudCapabilityProvider.select((value) => value.canUseCloudBooks),
    );
    ref.watch(apiConfigProvider);
    return canUseCloudBooks
        ? BookDirectoryStatus.unknown
        : BookDirectoryStatus.ready;
  }

  /// 更新当前账号的目录发现反馈。
  void setStatus(BookDirectoryStatus value) => state = value;
}

/// 刷新实际执行结果：本地重查、云同步完成及失败分别反馈。
enum DataRefreshOutcome { localOnly, cloudSynced, failed }

/// 同步执行结果（最近一次动作的汇总）。
class SyncRunResult {
  final String? _error;
  final SyncOperationFailure? failure;
  final int rejectedCount;
  final int pendingCount;
  final bool _cloudSynced;

  /// 同步结果保留未上传数量和安全失败事实，公开文案由失败事实优先提供。
  const SyncRunResult({
    String? error,
    this.failure,
    this.rejectedCount = 0,
    this.pendingCount = 0,
    // error 是公开参数名，实际文案优先由具有类型和定位的安全失败提供。
    // ignore: prefer_initializing_formals
  }) : _error = error,
       _cloudSynced = false;

  /// 只刷新本地快照，不代表数据已经上传。
  const SyncRunResult.localOnly() : this();

  /// 仅在真实同步完成且没有拒收或未上传事项时发布云端完成结果。
  const SyncRunResult.cloudSynced()
    : _error = null,
      failure = null,
      rejectedCount = 0,
      pendingCount = 0,
      _cloudSynced = true;

  /// 同步调用者读取安全文案，页面保留原因类别和实体定位。
  String? get error => failure?.message ?? _error;

  /// 成功只代表没有错误或待处理项，不能据此推断执行过云同步。
  bool get ok => error == null && rejectedCount == 0 && pendingCount == 0;

  /// 刷新提示依赖实际完成事实；失败和未上传事项优先于任何成功提示。
  DataRefreshOutcome get refreshOutcome => !ok
      ? DataRefreshOutcome.failed
      : _cloudSynced
      ? DataRefreshOutcome.cloudSynced
      : DataRefreshOutcome.localOnly;
}

/// 账号切换或显式云端决策期间，本机写入立即返回可展示说明，不排队等待网络。
class DataMutationPausedException extends StateError {
  /// 提示仅来自本机固定文案，不包含请求、账号资料或底层异常内容。
  DataMutationPausedException(this.userMessage) : super(userMessage);

  final String userMessage;
}

/// 同步编排：按「先推后拉」顺序执行完整一轮，异常时记录日志并返回错误信息。
class SyncCoordinator implements MutationExecutor {
  final Ref ref;

  Future<Object?>? _activeRun;
  Future<Object?>? _activeLocalMutation;
  int _localWriteBarriers = 0;
  ({
    Future<SyncRunResult> result,
    Future<Object?> entry,
    void Function() rerun,
  })?
  _incrementalRun;

  SyncCoordinator(this.ref);

  SyncService get _service => ref.read(syncServiceProvider);

  /// 内存会话或已恢复的登录身份才允许云端工作；本机模式不依赖旧本子归属。
  bool get _hasCloudAccount =>
      ref.read(cloudCapabilityProvider).canUseCloudBooks &&
      (ref.read(authSessionProvider) != null ||
          ref.read(accountStateProvider).isAuthenticated);

  /// 只比较账号和设备，令同一账号的令牌刷新不影响已排队的操作。
  (String, String, int)? get _account {
    final session = ref.read(authSessionProvider);
    return session == null || !ref.read(cloudCapabilityProvider).canSync
        ? null
        : (
            session.userId,
            session.deviceId,
            ref.read(cloudOperationGenerationProvider),
          );
  }

  /// 云端同步、显式决策与账号切换共用网络操作尾部，失败只影响当前调用者。
  Future<T> _serialize<T>(Future<T> Function() action) {
    final previous = _activeRun;
    late final Future<T> current;
    current =
        Future<T>.microtask(() async {
          try {
            await previous;
          } catch (error, stackTrace) {
            logger.error(
              'SyncCoordinator',
              '前序操作失败，继续处理后续请求',
              error,
              stackTrace,
            );
          }
          return action();
        }).whenComplete(() {
          if (identical(_activeRun, current)) _activeRun = null;
        });
    _activeRun = current;
    return current;
  }

  /// 本机写入独立串行，数据库事务负责与同步投影互斥，不等待在途 HTTP。
  Future<T> _serializeLocalMutation<T>(Future<T> Function() action) {
    final previous = _activeLocalMutation;
    late final Future<T> current;
    current =
        Future<T>.microtask(() async {
          await _waitForLocalMutations(previous);
          return action();
        }).whenComplete(() {
          if (identical(_activeLocalMutation, current)) {
            _activeLocalMutation = null;
          }
        });
    _activeLocalMutation = current;
    return current;
  }

  /// 已提交的本机操作完成后再进入互斥流程；失败不阻断后续账号清理或写入。
  Future<void> _waitForLocalMutations(Future<Object?>? previous) async {
    try {
      await previous;
    } catch (error, stackTrace) {
      logger.error(
        'SyncCoordinator',
        '前序本机操作失败，继续处理后续请求',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 显式恢复、云端决策与切号先收敛已排队本机写入，并暂停新写入直到操作结束。
  Future<T> _serializeWithLocalBarrier<T>(Future<T> Function() action) {
    final previousLocal = _activeLocalMutation;
    _localWriteBarriers++;
    return _serialize(() async {
      await _waitForLocalMutations(previousLocal);
      return action();
    }).whenComplete(() {
      _localWriteBarriers--;
    });
  }

  /// 在途同步完成后才进入账号清理，防止置闸等待与在途令牌刷新互相等待。
  /// 认证失效清理已持有闸门时，先等待其完成，再提交新账号。
  Future<T> runAccountTransition<T>(Future<T> Function() action) =>
      _serializeWithLocalBarrier(() async {
        while (ref.read(syncGateProvider)) {
          final released = Completer<void>();
          final subscription = ref.listen(syncGateProvider, (_, held) {
            if (!held && !released.isCompleted) released.complete();
          });
          try {
            await released.future;
          } finally {
            subscription.close();
          }
        }
        return action();
      });

  /// 显式云端操作保持网络队列顺序，并在账号与恢复闸门内保护本机写入。
  Future<T> runDataOperation<T>(Future<T> Function(SyncService) action) {
    final account = _account;
    final paused = _pauseReason;
    if (paused != null) return Future.error(StateError(paused));
    return _serializeWithLocalBarrier(
      () => _runScopedDataAction(
        account,
        () => action(_service),
        refreshSnapshots: true,
      ),
    );
  }

  /// 本机写入立即进入本机队列；后台增量同步不会使离线保存等待网络。
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) {
    final account = _localAccount;
    final paused =
        _localPauseReason ??
        (_localWriteBarriers > 0 ? '正在切换账号或处理云端数据，请稍后再保存。' : null);
    if (paused != null) {
      return Future.error(DataMutationPausedException(paused));
    }
    return _serializeLocalMutation(
      () => _runScopedDataAction(account, action, refreshSnapshots: false),
    );
  }

  /// 执行前后复核相同会话；本机事务按表通知，显式云操作可强制重查本机快照。
  Future<T> _runScopedDataAction<T>(
    (String, String, int)? account,
    Future<T> Function() action, {
    required bool refreshSnapshots,
  }) async {
    final paused = refreshSnapshots ? _pauseReason : _localPauseReason;

    /// 按操作类型读取固定身份，本机保存不依赖网络资格。
    (String, String, int)? currentAccount() =>
        refreshSnapshots ? _account : _localAccount;
    if (paused != null || account != currentAccount()) {
      throw StateError(paused ?? '账号已变化，请重新操作');
    }
    try {
      final value = await action();
      if (account != currentAccount()) throw StateError('账号已变化，请重新操作');
      return value;
    } finally {
      if (ref.mounted && account == currentAccount()) {
        // 普通写入交由 Drift 提交后的表更新驱动，失败回滚也不会重查无关业务。
        // 显式云端决策仍需刷新未落业务表的状态与失败后保留的本机快照。
        if (refreshSnapshots) {
          ref.read(manualDataRefreshProvider.notifier).tick();
        }
        ref.read(syncRunTickProvider.notifier).tick();
      }
    }
  }

  Future<String> protectToLocal(SyncTarget target) =>
      runDataOperation((service) => service.protectTargetToLocal(target));

  Future<String> transferToLocal(SyncTarget target, {required bool move}) =>
      runDataOperation(
        (service) => service.transferToLocal(target, move: move),
      );

  Future<void> refreshTarget(SyncTarget target) =>
      runDataOperation((service) => service.refreshTarget(target));

  /// 拉取失败重新下载可信快照；成功后只清除本条错误，不重放缓存中的原始载荷。
  Future<void> retryPullError(String id) => runDataOperation((service) async {
    final account = _account;
    if (account == null) throw StateError('请先登录');
    final db = ref.read(databaseProvider);
    final issues = await readSyncIssues(
      db,
      account: account.$1,
      includeDetails: false,
    );
    final issue = issues
        .where((i) => i.kind == SyncIssueKind.pullError && i.id == id)
        .firstOrNull;
    if (issue == null) throw StateError('事项已变化，请刷新');
    final target = issue.target;
    final parentType = target.type.startsWith('fitness_')
        ? 'fitness_space'
        : target.type.startsWith('memo_')
        ? 'memo_book'
        : target.type.startsWith('day_')
        ? 'day_book'
        : 'ledger';
    final parentId =
        target.parentId ??
        ([
              'ledger',
              'ledger_archive',
              'day_book',
              'memo_book',
              'fitness_space',
            ].contains(target.type)
            ? target.id
            : null);
    if (parentId != null) {
      await service.refreshTarget(SyncTarget(parentType, parentId));
    } else if (['category', 'exchange_rate_override'].contains(target.type)) {
      await service.accountingFull();
    } else {
      throw StateError('缺少错误记录所属本');
    }
    if (account != _account) throw StateError('账号已变化');
    await (db.update(db.syncPullErrors)..where(
          (row) =>
              row.id.equals(int.parse(id.substring(5))) &
              row.resolvedAt.isNull(),
        ))
        .write(
          SyncPullErrorsCompanion(resolvedAt: Value(DateTime.now().toUtc())),
        );
  });

  /// 确定被拒绝的变更重新登记后，返回真实同步结果供页面判断是否完成。
  Future<SyncRunResult> retryRejected(String id) async {
    await runDataOperation((service) => service.retryRejectedChange(id));
    return run();
  }

  Future<SyncDeletePreview> prepareScopeDelete(SyncTarget target) =>
      runDataOperation((service) => service.prepareScopeDelete(target));

  Future<void> confirmScopeDelete(SyncDeletePreview preview) async {
    await runDataOperation((service) => service.confirmScopeDelete(preview));
    await run();
  }

  /// 本地写入只校验账号事务和恢复屏障，与服务器是否存在无关。
  (String, String, int)? get _localAccount {
    final account = ref.read(currentAccountIdProvider);
    return account == null
        ? null
        : (account, '', ref.read(authIdentityGenerationProvider));
  }

  /// 数据互斥规则同时适用于本机和云端操作。
  String? get _localPauseReason {
    if (ref.read(syncGateProvider)) return '同步暂停中（数据清理进行中）';
    if (ref.read(restoreGateProvider)) return '正在恢复云端数据，请稍候';
    return null;
  }

  /// 返回统一暂停原因；排队前和开始执行时都必须检查。
  String? get _pauseReason {
    final capability = ref.read(cloudCapabilityProvider);
    if (!capability.serverConfigured) return '未配置服务器地址，请先配置服务器';
    if (!capability.syncEnabled) return '云同步已关闭，本机数据仍可使用';
    if (!capability.hasSession) return '请先登录后再同步云端数据';
    return _localPauseReason;
  }

  /// 串行执行完整同步（按域补全 → 已就绪域 push → pull），返回最后一轮结果。
  ///
  /// 闸门置起（退出登录 purge 期间）时直接降级返回，不发起任何网络请求，
  /// 避免并发同步把刚清掉的云端账本重新拉回。执行期间的新触发会被合并为
  /// 一次尾随补跑，确保首轮 push 取快照后新增的 mutation 不会被吞掉。
  Future<SyncRunResult> run() {
    if (!ref.mounted) return Future.value(const SyncRunResult(error: '同步已取消'));
    if (!_hasCloudAccount) return Future.value(const SyncRunResult());
    final paused = _pauseReason;
    if (paused != null) return Future.value(SyncRunResult(error: paused));
    final active = _incrementalRun;
    if (active != null && identical(_activeRun, active.entry)) {
      active.rerun();
      return active.result;
    }

    late final Future<SyncRunResult> current;
    final account = _account;
    // 每段增量链独立合并；用户操作或换号已排队后，新触发必须排到它们之后。
    var rerunRequested = false;
    current =
        _serialize(
          () => _runSerially(account, () {
            final requested = rerunRequested;
            rerunRequested = false;
            return requested;
          }),
        ).whenComplete(() {
          if (identical(_incrementalRun?.result, current)) {
            _incrementalRun = null;
          }
        });
    _incrementalRun = (
      result: current,
      entry: _activeRun!,
      rerun: () => rerunRequested = true,
    );
    return current;
  }

  /// 合并增量轮次及尾随轮；执行顺序由统一队列控制。
  ///
  /// 整轮（含尾随补跑）期间置起 busy 信号供账本卡片显示上传转圈；
  /// 结束后 bump 同步 tick —— push 标记 pushedAt 不发射业务数据信号，
  /// 卡片状态等派生方依赖该 tick 重算「待推送 → 已同步」。
  Future<SyncRunResult> _runSerially(
    (String, String, int)? account,
    bool Function() takeRerun,
  ) async {
    // 排队期间所属作用域可能已关闭，取消旧任务且不创建新的状态订阅。
    if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
    final busy = ref.read(syncBusyProvider.notifier);
    final busyRun = busy.start();
    try {
      var result = await _runOnce(account);
      while (ref.mounted && takeRerun()) {
        result = await _runOnce(account);
      }
      if (ref.mounted && account != null && account == _account) {
        await _recordRunFeedback(result, accountId: account.$1);
      }
      return result;
    } finally {
      // busy 可比编排器存活更久，结束自己的轮次但不能覆盖后来启动的新轮次。
      busy.stop(busyRun);
      if (ref.mounted) ref.read(syncRunTickProvider.notifier).tick();
    }
  }

  /// 轮次结束只更新横幅反馈，身份变化后忽略旧结果。
  Future<void> _recordRunFeedback(
    SyncRunResult result, {
    required String accountId,
  }) async {
    if (ref.mounted && ref.read(currentAccountIdProvider) == accountId) {
      ref
          .read(cloudSyncRunFeedbackProvider.notifier)
          .record(error: result.error, failure: result.failure);
    }
  }

  /// 执行单轮初始化、推送与增量消费，并把技术异常转换为可展示的失败结果。
  Future<SyncRunResult> _runOnce((String, String, int)? account) async {
    if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
    final paused = _pauseReason;
    if (paused != null) return SyncRunResult(error: paused);
    if (account != _account) return const SyncRunResult(error: '账号已变更，请重新操作');
    try {
      final service = _service;
      _beginDirectoryLoad(account);
      final pulled = await service.synchronize();
      if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
      if (account != _account) return const SyncRunResult(error: '账号已变更，请重新操作');
      await service.refreshCategoryConflicts();
      if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
      if (account != _account) return const SyncRunResult(error: '账号已变更，请重新操作');
      final db = ref.read(databaseProvider);
      final attention = await readSyncIssues(
        db,
        account: account?.$1,
        includeFitnessCompleteness: false,
        includeDetails: false,
      );
      final rejected = attention
          .where((issue) => issue.kind == SyncIssueKind.rejected)
          .toList();
      if (rejected.isNotEmpty) {
        logger.warning(
          'SyncCoordinator',
          '同步仍有 ${rejected.length} 条记录未上传，需要处理',
        );
        return SyncRunResult(
          rejectedCount: rejected.length,
          failure: SyncOperationFailure(
            code: 'SYNC_REJECTED',
            message: '有 ${rejected.length} 条记录未上传，请查看每条记录的原因后处理',
            target: rejected.first.target,
          ),
        );
      }
      final unresolved = attention
          .where((issue) => issue.kind != SyncIssueKind.pendingUpload)
          .length;
      if (unresolved > 0) {
        return SyncRunResult(
          failure: SyncOperationFailure(
            code: 'SYNC_REQUIRES_ATTENTION',
            message: '有 $unresolved 项同步操作需要处理，请查看具体事项',
          ),
        );
      }
      final pendingCount = attention
          .where((issue) => issue.kind == SyncIssueKind.pendingUpload)
          .fold<int>(0, (total, issue) => total + issue.count);
      if (pendingCount > 0) {
        // 请求完成不等于队列上传完成；保留等待事实，不能报告同步成功。
        return SyncRunResult(
          pendingCount: pendingCount,
          failure: SyncOperationFailure(
            code: 'SYNC_PENDING_UPLOAD',
            message: '还有 $pendingCount 项未上传，数据已保存在本机，请查看每条记录的状态',
          ),
        );
      }
      if (!ref.mounted || account != _account) {
        return const SyncRunResult(error: '账号或同步配置已变化，请重新操作');
      }
      logger.info('SyncCoordinator', '同步完成, pull=$pulled');
      return const SyncRunResult.cloudSynced();
    } catch (e, st) {
      logger.error('SyncCoordinator', '同步失败', safeErrorSummary(e), st);
      return SyncRunResult(failure: cloudOperationFailure(e));
    } finally {
      if (ref.mounted && account == _account) {
        await _finishDirectoryLoad(account);
      }
    }
  }

  /// 同一账号的未完成目录共同进入加载态，已确认目录继续展示可用缓存。
  void _beginDirectoryLoad((String, String, int)? account) {
    if (!ref.mounted || account == null || account != _account) return;
    for (final provider in [
      dayDirectoryStatusProvider,
      memoDirectoryStatusProvider,
      fitnessDirectoryStatusProvider,
    ]) {
      if (ref.read(provider) != BookDirectoryStatus.ready) {
        ref.read(provider.notifier).setStatus(BookDirectoryStatus.loading);
      }
    }
  }

  /// 各目录状态来自对应业务域已提交的屏障；网络错误不能伪装成空目录。
  Future<void> _finishDirectoryLoad((String, String, int)? account) async {
    if (!ref.mounted || account == null || account != _account) return;
    try {
      final db = ref.read(databaseProvider);
      final state =
          await (db.select(db.syncState)..where(
                (s) =>
                    s.accountId.equals(account.$1) &
                    s.deviceId.equals(account.$2),
              ))
              .getSingleOrNull();
      if (!ref.mounted || account != _account) return;
      ref
          .read(fitnessDirectoryStatusProvider.notifier)
          .setStatus(
            state?.fitnessCursor == null
                ? BookDirectoryStatus.failed
                : BookDirectoryStatus.ready,
          );
      ref
          .read(memoDirectoryStatusProvider.notifier)
          .setStatus(
            state?.memosCursor == null
                ? BookDirectoryStatus.failed
                : BookDirectoryStatus.ready,
          );
      ref
          .read(dayDirectoryStatusProvider.notifier)
          .setStatus(
            state?.dayEventsCursor == null
                ? BookDirectoryStatus.failed
                : BookDirectoryStatus.ready,
          );
    } catch (error, stackTrace) {
      // 目录投影失败单独反馈，不能覆盖同步动作已经确定的成功或友好错误结果。
      logger.error(
        'SyncCoordinator',
        '读取云端目录状态失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (!ref.mounted || account != _account) return;
      for (final provider in [
        dayDirectoryStatusProvider,
        memoDirectoryStatusProvider,
        fitnessDirectoryStatusProvider,
      ]) {
        // 已完成发现的缓存仍可使用；未确认的目录明确显示失败，允许用户重试。
        if (ref.read(provider) != BookDirectoryStatus.ready) {
          ref.read(provider.notifier).setStatus(BookDirectoryStatus.failed);
        }
      }
    }
  }

  /// 云本复制与转换在同一串行队列中完成，保持服务端确认和本地事务顺序。
  Future<days.DayBook> _convertDayBook(
    String dayBookId, {
    required bool move,
  }) => runDataOperation(
    (service) => move
        ? service.moveDayBookToLocal(dayBookId: dayBookId)
        : service.copyDayBookToLocal(dayBookId: dayBookId),
  );

  /// 复制为本机本，完整快照和未确认分支保护由同步服务统一处理。
  Future<days.DayBook> copyDayBookToLocal({required String dayBookId}) =>
      _convertDayBook(dayBookId, move: false);

  /// 云端删除确认后发布稳定的本机副本，失败后沿用原操作重试。
  Future<days.DayBook> moveDayBookToLocal({required String dayBookId}) =>
      _convertDayBook(dayBookId, move: true);

  /// 用户同步决策必须在同一账号的增量同步之后执行，并返回可直接展示的结果。
  Future<SyncRunResult> _userAction(
    Future<void> Function(SyncService service) action, {
    required String failureMessage,
    bool syncAfter = false,
  }) async {
    final paused = _pauseReason;
    if (paused != null) return SyncRunResult(error: paused);
    final account = _account;
    if (account == null) return const SyncRunResult(error: '请先登录后操作云端数据');
    SyncRunResult result;
    try {
      await runDataOperation(action);
      result = const SyncRunResult();
    } catch (error, stackTrace) {
      logger.error(
        'SyncCoordinator',
        failureMessage,
        safeErrorSummary(error),
        stackTrace,
      );
      result = SyncRunResult(
        error: account != _account
            ? '账号已变更，请重新操作'
            : error is CategoryDecisionException
            ? error.message
            : _pauseReason ??
                  cloudOperationErrorMessage(error, fallback: failureMessage),
      );
    }
    // 决策提交成功即返回；上传失败由正常同步状态展示，不能把已提交决策误报为失败。
    if (result.ok &&
        syncAfter &&
        ref.mounted &&
        account == _account &&
        _incrementalRun == null) {
      unawaited(run());
    }
    return result;
  }

  /// 保留本地冲突后通过正常增量轮次上传新的决策变更。
  Future<SyncRunResult> resolveConflictKeepLocal(String conflictId) =>
      _userAction(
        (service) => service.resolveConflictKeepLocal(conflictId),
        failureMessage: '保留本地失败，请稍后重试',
        syncAfter: true,
      );

  /// 分类决策绑定实际展示版本，不能沿用通用墓碑副本工作流。
  Future<SyncRunResult> resolveCategoryConflict(
    String id, {
    required bool keepLocal,
    required String expectedDecisionVersion,
    bool restoreDeleted = false,
  }) => _userAction(
    (service) => service.resolveCategoryConflict(
      id,
      keepLocal: keepLocal,
      expectedDecisionVersion: expectedDecisionVersion,
      restoreDeleted: restoreDeleted,
    ),
    failureMessage: '分类确认未完成，请重新比较或重试',
    syncAfter: true,
  );

  /// 网络未知时保留原始确认及幂等身份。
  Future<SyncRunResult> retryCategoryConflictResolution(String id) =>
      _userAction(
        (service) => service.retryCategoryConflictResolution(id),
        failureMessage: '确认结果尚未收到，请重试确认',
        syncAfter: true,
      );

  /// 串行采用云端冲突结果，失败时保留现有本地状态。
  Future<SyncRunResult> resolveConflictAdoptRemote(String conflictId) =>
      _userAction(
        (service) => service.resolveConflictAdoptRemote(conflictId),
        failureMessage: '采用云端失败，请稍后重试',
      );

  /// 串行保护本地分支并重新下载失效账本的当前快照。
  Future<SyncRunResult> abandonLocalChanges({required String ledgerId}) =>
      _userAction(
        (service) => service.abandonLocalChanges(ledgerId: ledgerId),
        failureMessage: '重新下载失败，本地修改仍保留，请重试或转为本地账本',
      );

  /// 刷新客户端业务数据。
  ///
  /// [ledgerId] 非空时按该账本的 storageMode 决策，本地账本只重查本地库；
  /// 为空时用于账号级刷新；存在会话或缓存登录身份即可尝试同步，
  /// 不要求本地已有云账本，以便发现其他设备创建或分享的账本。
  /// 无论云同步成功与否都会触发本地重查，让页面至少展示当前可用快照。
  Future<SyncRunResult> refreshData({String? ledgerId}) async {
    if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
    try {
      // 未登录只触发 finally 中的本地重查，退出后旧页面的云本 ID 也不能恢复云端流程。
      if (!_hasCloudAccount) return const SyncRunResult.localOnly();
      final repo = ref.read(repositoryProvider);
      final isAccountRefresh = ledgerId == null || ledgerId.isEmpty;
      final ledger = isAccountRefresh
          ? null
          : await repo.getLedgerById(ledgerId);
      if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
      // 读取账本期间可能完成退出；此时忽略旧云本及云端闸门，回到本机刷新。
      if (!_hasCloudAccount) return const SyncRunResult.localOnly();
      var session = ref.read(authSessionProvider);
      // 账号级刷新不能依赖本地已缓存云账本，否则无法发现其他设备刚创建或
      // 分享给当前账号的远端账本；未登录时仍只刷新本地快照。
      final needsCloudSync = isAccountRefresh || ledger?.storageMode == 'cloud';

      if (!needsCloudSync) return const SyncRunResult.localOnly();
      if (ref.read(syncGateProvider)) {
        return const SyncRunResult(error: '同步暂停中（数据清理进行中）');
      }
      if (ref.read(restoreGateProvider)) {
        return const SyncRunResult(error: '正在恢复云端数据，请稍候');
      }
      if (ledger?.bindingStatus == 'stale') {
        return const SyncRunResult(error: '云账本绑定已失效，请重新连接');
      }
      // 缓存账号仍登录但启动恢复失败时，下拉主动重试同一会话刷新入口。
      if (session == null && ref.read(accountStateProvider).isAuthenticated) {
        await ref.read(authSessionProvider.notifier).refresh();
        if (!ref.mounted) return const SyncRunResult(error: '同步已取消');
        if (!_hasCloudAccount) return const SyncRunResult.localOnly();
        session = ref.read(authSessionProvider);
      }
      if (session == null) {
        return const SyncRunResult(error: '请先登录后再同步云账本');
      }
      final result = await run();
      // 退出后只保留本地重查结果，旧账号的取消或网络失败不交给本机页面展示。
      if (ref.mounted && !_hasCloudAccount) {
        return const SyncRunResult.localOnly();
      }
      return result;
    } catch (e, st) {
      logger.error('SyncCoordinator', '刷新业务数据失败', safeErrorSummary(e), st);
      // 会话恢复也可能在退出或认证失效后抛错，本机页面只接收本地刷新结果。
      if (ref.mounted && !_hasCloudAccount) {
        return const SyncRunResult.localOnly();
      }
      return SyncRunResult(
        failure: cloudOperationFailure(e, fallback: '刷新未完成，数据已保存在本机，请重试'),
      );
    } finally {
      // 即使网络失败也重新读取本地快照，避免页面保留已过期缓存。
      if (ref.mounted) ref.read(manualDataRefreshProvider.notifier).tick();
    }
  }

  /// Reconnect v1：登录原账号 → 下载服务器当前状态。
  ///
  /// 语义：只做 full 快照收敛，绝不重放备份 queue/cursor；
  /// 本地 LOCAL 账本（含备份 Fork 产物）不被下载/改写。
  ///
  /// 等待在途操作结束后置起恢复闸门，恢复快照期间暂停新用户决策与增量轮次。
  /// 普通重连释放闸门后触发增量；显式范围不发现其他本，也不尾随全局同步。
  Future<ReconnectReport> reconnect({
    Set<String>? ledgerIds,
    Set<String>? dayBookIds,
    Set<String>? memoBookIds,
    Set<String>? fitnessSpaceIds,
  }) async {
    final scoped =
        ledgerIds != null ||
        dayBookIds != null ||
        memoBookIds != null ||
        fitnessSpaceIds != null;
    if (_pauseReason != null) {
      return const ReconnectReport(refreshed: [], stale: [], gone: []);
    }
    final account = _account;
    try {
      return await _serializeWithLocalBarrier(() async {
        if (ref.read(syncGateProvider) || account != _account) {
          return const ReconnectReport(refreshed: [], stale: [], gone: []);
        }
        final gate = ref.read(restoreGateProvider.notifier);
        gate.hold();
        try {
          final service = ReconnectV1Service(
            db: ref.read(databaseProvider),
            sync: _service,
          );
          if (!scoped) {
            _beginDirectoryLoad(account);
          }
          return await service.reconnectAfterLogin(
            ledgerIds: ledgerIds,
            dayBookIds: dayBookIds,
            memoBookIds: memoBookIds,
            fitnessSpaceIds: fitnessSpaceIds,
          );
        } finally {
          gate.release();
        }
      });
    } catch (error, stackTrace) {
      logger.error('SyncCoordinator', '恢复云端数据失败', error, stackTrace);
      rethrow;
    } finally {
      // 显式范围只影响选中本；普通重连按各业务域已提交水位补跑。
      // 同步失败记录日志并返回错误，等待后续事件再次触发。
      // mounted 守卫：容器销毁（测试/极端生命周期）后不再触碰 ref。
      if (ref.mounted && account == _account && !scoped) {
        await _finishDirectoryLoad(account);
        // 目录查询会让出执行权，补跑仍须属于原编排器与原身份。
        if (ref.mounted && account == _account) unawaited(run());
      }
    }
  }

  /// 首次登录和新设备通过各业务域完整快照建立独立的同步屏障。
  Future<SyncRunResult> bootstrap() async {
    final paused = _pauseReason;
    if (paused != null) return SyncRunResult(error: paused);
    final account = _account;
    try {
      return await _serializeWithLocalBarrier(() async {
        if (ref.read(syncGateProvider) || account != _account) {
          return const SyncRunResult(error: '账号已变更或正在清理，请稍后重试');
        }
        final gate = ref.read(restoreGateProvider.notifier);
        gate.hold();
        try {
          _beginDirectoryLoad(account);
          await ReconnectV1Service(
            db: ref.read(databaseProvider),
            sync: _service,
          ).reconnectAfterLogin();
          return const SyncRunResult();
        } finally {
          gate.release();
        }
      });
    } catch (e, st) {
      logger.error('SyncCoordinator', 'bootstrap 失败', e, st);
      return const SyncRunResult(error: '恢复云端数据失败，请稍后重试');
    } finally {
      // 无论 full 成功或失败，释放闸门后都触发一轮增量同步。
      if (ref.mounted && account == _account) {
        await _finishDirectoryLoad(account);
        if (ref.mounted && account == _account) unawaited(run());
      }
    }
  }
}

/// 同步轮结束 tick：同步服务直写 sync_changes（标记 pushedAt）不发射
/// 业务数据信号，拒绝记录等派生方依赖它触发重算。
final syncRunTickProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

/// 同步执行中信号：整轮（push → pull，含尾随补跑）期间为 true。
final syncBusyProvider = NotifierProvider<SyncBusyNotifier, bool>(
  SyncBusyNotifier.new,
);

/// 同步执行中闸门状态：默认空闲（false）。
class SyncBusyNotifier extends Notifier<bool> {
  int _generation = 0;

  /// 状态重新装配时令旧轮次失效，旧请求完成不能收起新轮次的提示。
  @override
  bool build() {
    _generation++;
    return false;
  }

  /// 标记一轮同步开始，返回结束时核验的轮次标识。
  int start() {
    final generation = ++_generation;
    state = true;
    return generation;
  }

  /// 仅结束当前轮次；所属状态已销毁或已有新轮次时忽略迟到回调。
  void stop([int? generation]) {
    if (!ref.mounted || (generation != null && generation != _generation)) {
      return;
    }
    state = false;
  }
}
