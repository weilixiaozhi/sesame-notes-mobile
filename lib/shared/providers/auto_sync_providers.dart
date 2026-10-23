/// 本地变更与待完整下载任务共用自动同步入口，页面不承担下载与重试。
/// 本地变更防抖合并，可恢复失败有界指数退避；离线和闸门期间暂停。
library;

import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 调度器只决定等待时间，所有触发仍进入同一同步队列。
typedef AutoSyncTimerFactory =
    Timer Function(Duration delay, void Function() run);

/// 待推内容只由请求身份、正文和编辑时钟决定；冻结和回执等簿记不构成新写入。
typedef AutoSyncPendingMutation = ({
  String mutationId,
  String payload,
  DateTime updatedAt,
});

/// 生产使用系统计时器，回归可精确推进调度而不等待真实网络时长。
final autoSyncTimerFactoryProvider = Provider<AutoSyncTimerFactory>(
  (ref) => Timer.new,
);

/// 自动推送编排实例。
class AutoSyncCoordinator {
  final Stream<Set<TableUpdate>> changes;
  final bool Function() isLoggedIn;
  final Future<SyncRunResult> Function() sync;
  final Future<Set<AutoSyncPendingMutation>> Function() pendingMutations;
  final Future<bool> Function() hasPendingDownloads;
  final bool Function() canSync;
  final Duration debounce;
  final Duration initialRetryDelay;
  final Duration maxRetryDelay;
  final int maxRetryAttempts;
  final AutoSyncTimerFactory scheduleTimer;

  Timer? _timer;
  Timer? _retryTimer;
  bool _running = false;
  bool _disposed = false;
  bool _downloadsPresent = false;
  bool _mutationsPresent = false;
  Set<AutoSyncPendingMutation> _knownMutations = const {};
  Set<String> _downloadIds = const {};
  bool _downloadsAddedWhileRunning = false;
  bool _environmentReady = false;
  bool _resumeSync = false;
  bool _retryPending = false;
  int _retryAttempt = 0;
  int _downloadRevision = 0;
  int _mutationReadRevision = 0;

  /// 同步执行期间到达的新变更标记：执行完成后重新排队，避免变更被吞。
  bool _pendingWhileRunning = false;

  StreamSubscription<Set<TableUpdate>>? _sub;

  /// 同一调度器同时管理上传与完整下载，重试次数包含自动补跑，不包含首次执行。
  AutoSyncCoordinator({
    required this.changes,
    required this.isLoggedIn,
    required this.sync,
    required this.pendingMutations,
    Future<bool> Function()? hasPendingDownloads,
    bool Function()? canSync,
    AutoSyncTimerFactory? scheduleTimer,
    this.debounce = const Duration(seconds: 2),
    this.initialRetryDelay = const Duration(seconds: 5),
    this.maxRetryDelay = const Duration(minutes: 1),
    this.maxRetryAttempts = 5,
  }) : hasPendingDownloads = hasPendingDownloads ?? (() async => false),
       canSync = canSync ?? (() => true),
       scheduleTimer = scheduleTimer ?? Timer.new,
       assert(maxRetryAttempts >= 0),
       assert(initialRetryDelay > Duration.zero),
       assert(maxRetryDelay >= initialRetryDelay);

  /// 只依据明确无网与闸门暂停，HTTP 暂时失败仍允许后台重试。
  bool get _canRun => !_disposed && isLoggedIn() && canSync();

  /// 开始监听变更流（幂等；dispose 后不可复用）。
  ///
  /// [syncOnStart] 用于登录态冷启动或重新登录：主动调度一轮，消费监听建立前
  /// 已经存在的 pending mutation，并顺便收敛远端游标。
  void start({bool syncOnStart = false}) {
    if (_disposed || _sub != null) return;
    _environmentReady = _canRun;
    _sub = changes.listen((_) => unawaited(_localChangesChanged()));
    if (syncOnStart) _schedule();
  }

  /// 旧账号或作用域结束后取消所有调度，迟到查询也不能创建新计时器。
  void dispose() {
    _disposed = true;
    _pendingWhileRunning = false;
    _retryPending = false;
    _timer?.cancel();
    _retryTimer?.cancel();
    _sub?.cancel();
    _sub = null;
  }

  /// 新增任务及时唤醒，集合未变的通知不能重置失败退避。
  void pendingDownloadsChanged(Set<String> ids) {
    if (_disposed ||
        ids.length == _downloadIds.length && ids.every(_downloadIds.contains)) {
      return;
    }
    final added = ids.any((id) => !_downloadIds.contains(id));
    _downloadRevision++;
    _downloadIds = Set.of(ids);
    _downloadsPresent = ids.isNotEmpty;
    if (!_downloadsPresent && !_mutationsPresent) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      _retryPending = false;
      _resumeSync = false;
    } else if (added) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryAttempt = 0;
      if (_running) {
        _downloadsAddedWhileRunning = true;
      } else if (_timer == null) {
        // 冷启动已安排的一轮能够同时消费首次读出的下载集合，不能替换其有效计时器。
        _schedule();
      }
    }
  }

  /// 网络或闸门恢复时继续原任务，阻断期间不靠计时器反复空转。
  void availabilityChanged() {
    if (_disposed) return;
    final available = _canRun;
    if (available == _environmentReady) return;
    _environmentReady = available;
    if (!available) {
      _resumeSync =
          _resumeSync || _timer != null || _retryTimer != null || _retryPending;
      _timer?.cancel();
      _timer = null;
      _retryTimer?.cancel();
      _retryTimer = null;
    } else if (_resumeSync || _downloadsPresent || _retryPending) {
      _resumeSync = false;
      _retryAttempt = 0;
      _schedule();
    }
  }

  /// 表通知先读取实际待推内容，回执、冻结或历史清理不能唤醒同一失败任务。
  Future<void> _localChangesChanged() async {
    try {
      await _refreshPendingMutations(triggerNewWork: true);
    } catch (error, stackTrace) {
      logger.error(
        'AutoSync',
        '读取本机待同步变更失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 快照仅接纳最新一次读取；移除已完成项不会补充重试预算，新增或编辑才会唤醒。
  Future<void> _refreshPendingMutations({required bool triggerNewWork}) async {
    if (_disposed || !isLoggedIn()) return;
    final revision = ++_mutationReadRevision;
    final current = await pendingMutations();
    if (_disposed || !isLoggedIn() || revision != _mutationReadRevision) return;
    final added = current.any(
      (mutation) => !_knownMutations.contains(mutation),
    );
    _knownMutations = Set.of(current);
    _mutationsPresent = current.isNotEmpty;
    if (!_mutationsPresent && !_downloadsPresent) {
      _retryTimer?.cancel();
      _retryTimer = null;
      _retryPending = false;
      _retryAttempt = 0;
    }
    if (added && triggerNewWork) {
      _retryAttempt = 0;
      _schedule();
    }
  }

  /// 防抖调度：窗口内多次变更重置计时器只触发一次；执行期间的变更
  /// 记 pending 标记，待本轮完成后重新排队（防止变更被吞）。
  void _schedule() {
    if (_disposed) return;
    if (_running) {
      _pendingWhileRunning = true;
      return;
    }
    if (!_canRun) {
      _environmentReady = false;
      _resumeSync = isLoggedIn();
      return;
    }
    _timer?.cancel();
    _retryTimer?.cancel();
    _retryTimer = null;
    _timer = scheduleTimer(debounce, () {
      _timer = null;
      unawaited(_sync());
    });
  }

  /// 自动补跑只服务可恢复失败和未完成下载，预算耗尽后保留任务等待新的有效触发。
  void _scheduleRetry() {
    if (!_canRun ||
        !_retryPending ||
        _retryAttempt >= maxRetryAttempts ||
        _running ||
        _timer != null ||
        _retryTimer != null) {
      return;
    }
    final milliseconds =
        initialRetryDelay.inMilliseconds * (1 << _retryAttempt.clamp(0, 20));
    final delay = Duration(
      milliseconds: milliseconds > maxRetryDelay.inMilliseconds
          ? maxRetryDelay.inMilliseconds
          : milliseconds,
    );
    _retryAttempt++;
    _retryTimer = scheduleTimer(delay, () {
      _retryTimer = null;
      unawaited(_sync());
    });
  }

  /// 执行同步：单飞防重入；未登录直接跳过（变更保留在队列，登录后由
  /// 显式同步/下次触发推送）。
  Future<void> _sync() async {
    if (_disposed || _running) return;
    if (!_canRun) {
      _environmentReady = false;
      _resumeSync = isLoggedIn();
      return;
    }
    _running = true;
    _downloadsAddedWhileRunning = false;
    SyncRunResult? result;
    try {
      // 首轮网络请求前记住原待推内容，随后冻结原请求产生的表通知不会被当成编辑。
      await _refreshPendingMutations(triggerNewWork: false);
      if (!_canRun) return;
      // 网络轮次开始前已经到达的任务由本轮消费，只有执行中新增内容才需要尾随。
      _pendingWhileRunning = false;
      _downloadsAddedWhileRunning = false;
      result = await sync();
      if (result.error != null) {
        logger.warning('AutoSync', '后台同步未完成: ${result.error}');
      }
    } catch (error, stackTrace) {
      logger.error('AutoSync', '后台同步未完成', safeErrorSummary(error), stackTrace);
      result = SyncRunResult(failure: cloudOperationFailure(error));
    } finally {
      try {
        await _refreshPendingMutations(triggerNewWork: true);
        if (!_disposed && isLoggedIn()) {
          var downloadsRetryable = false;
          while (!_disposed && isLoggedIn()) {
            final revision = _downloadRevision;
            downloadsRetryable = await hasPendingDownloads();
            if (_disposed || revision == _downloadRevision) break;
            if (!_downloadsPresent) {
              downloadsRetryable = false;
              break;
            }
            // 查询期间其他任务可能完成或新邀请到达，按最新集合重新核实资格。
          }
          if (!_disposed && isLoggedIn()) {
            _downloadsPresent = downloadsRetryable;
            final code = result?.failure?.code;
            final recoverable =
                code == 'NETWORK_UNAVAILABLE' ||
                code == 'CLOUD_SERVICE_UNAVAILABLE';
            // 业务拒绝、冲突、权限、取消和未知原因均需新事件或用户处理，不能定时重放。
            _retryPending =
                recoverable && (_mutationsPresent || _downloadsPresent) ||
                result?.ok == true && _downloadsPresent;
            if (!_retryPending) {
              _retryTimer?.cancel();
              _retryTimer = null;
              _retryAttempt = 0;
            }
          }
        }
      } catch (error, stackTrace) {
        _retryPending = false;
        logger.error(
          'AutoSync',
          '读取后台同步待办失败',
          safeErrorSummary(error),
          stackTrace,
        );
      } finally {
        _running = false;
        if (!_disposed && isLoggedIn()) {
          final newWork =
              _pendingWhileRunning && _mutationsPresent ||
              _downloadsAddedWhileRunning && _downloadsPresent;
          _pendingWhileRunning = false;
          _downloadsAddedWhileRunning = false;
          if (newWork) {
            _schedule();
          } else if (_retryPending) {
            if (_canRun) {
              _scheduleRetry();
            } else {
              _environmentReady = false;
              _resumeSync = true;
            }
          }
        }
      }
    }
  }
}

/// 自动推送编排 provider：监听 sync_changes 表变化，防抖后触发完整同步。
///
/// 需要被显式 watch 保持活跃（main.dart 装配处 watch 一次）。
final autoSyncCoordinatorProvider = Provider<AutoSyncCoordinator>((ref) {
  final canSync = ref.watch(
    cloudCapabilityProvider.select((value) => value.canSync),
  );
  ref.watch(apiConfigProvider);
  final db = ref.watch(databaseProvider);
  // 身份变化重建调度器；令牌轮换保留在途任务与退避进度。
  final generation = ref.watch(authIdentityGenerationProvider);
  final session = ref.watch(
    authSessionProvider.select((value) => (value?.userId, value?.deviceId)),
  );
  final accountId = session.$1;

  /// 所有迟到异步读取都核验原身份，不能替新账号安排同步。
  bool isLoggedIn() =>
      ref.mounted &&
      canSync &&
      ref.read(cloudCapabilityProvider).canSync &&
      accountId != null &&
      ref.read(authIdentityGenerationProvider) == generation &&
      ref.read(authSessionProvider)?.userId == accountId;

  final coordinator = AutoSyncCoordinator(
    scheduleTimer: ref.watch(autoSyncTimerFactoryProvider),
    changes: db.tableUpdates(TableUpdateQuery.onAllTables([db.syncChanges])),
    isLoggedIn: isLoggedIn,
    canSync: () =>
        ref.mounted &&
        !ref.read(cloudConnectionProvider.notifier).isNetworkUnavailable &&
        !ref.read(syncGateProvider) &&
        !ref.read(restoreGateProvider),
    // 只比较真实编辑字段；冻结请求、拒收说明和回执字段不会为同一任务续重试次数。
    pendingMutations: () async {
      if (!isLoggedIn()) return const {};
      final query = db.select(db.syncChanges)
        ..where(
          (c) =>
              c.pushedAt.isNull() &
              c.rejectionReason.isNull() &
              c.accountId.equals(accountId!),
        );
      final rows = await query.get();
      if (!isLoggedIn()) return const {};
      return {
        for (final row in rows)
          (
            mutationId: row.mutationId,
            payload: row.payload,
            updatedAt: row.updatedAt,
          ),
      };
    },
    hasPendingDownloads: () async {
      if (!isLoggedIn()) return false;
      final pending = await ref
          .read(cloudLedgerDownloadStoreProvider)
          .pending(accountId!);
      if (!isLoggedIn() || pending.isEmpty) return false;
      final rows = await (db.select(
        db.ledgers,
      )..where((row) => row.id.isIn(pending))).get();
      if (!isLoggedIn()) return false;
      final byId = {for (final row in rows) row.id: row};
      return pending.any((id) {
        final row = byId[id];
        // 首次加入尚无本地行也需下载；失效绑定等用户决策任务不能反复定时重试。
        return row == null ||
            row.storageMode == 'cloud' &&
                row.scopeAccountId == accountId &&
                row.deletedAt == null &&
                row.bindingStatus != 'stale';
      });
    },
    sync: () => ref.read(syncCoordinatorProvider).run(),
  );
  coordinator.start(syncOnStart: canSync && accountId != null);
  ref.listen<AsyncValue<Set<String>>>(pendingCloudLedgerDownloadsProvider, (
    _,
    next,
  ) {
    if (next is AsyncData<Set<String>>) {
      coordinator.pendingDownloadsChanged(next.value);
    }
  }, fireImmediately: true);
  ref.listen(
    cloudConnectionProvider,
    (_, _) => coordinator.availabilityChanged(),
  );
  ref.listen(syncGateProvider, (_, _) => coordinator.availabilityChanged());
  ref.listen(restoreGateProvider, (_, _) => coordinator.availabilityChanged());
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
