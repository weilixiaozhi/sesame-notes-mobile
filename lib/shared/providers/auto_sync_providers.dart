/// 自动推送编排（post_processor 核对结论的落地实现）。
///
/// 设计意图：「记账后自动上传到云端」——本地写库登记 sync_changes 变更后，
/// 自动触发一轮完整同步（push→pull），无需用户手动刷新。要点：
/// - 监听 sync_changes 表变化（业务写库的唯一同步入口；pull 应用业务表
///   不登记 change → 天然无循环）；
/// - 防抖 2s：批量写库（如批量导入）合并为一次同步；
/// - 未登录不触发（无云端会话，push 无意义，deviceId 为本地占位）；
/// - 同步闸门（退出登录 purge 期间）由 SyncCoordinator.run 内部降级，此处
///   无需重复判断。
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 自动推送编排实例。
class AutoSyncCoordinator {
  final Stream<Set<TableUpdate>> changes;
  final bool Function() isLoggedIn;
  final Future<void> Function() sync;
  final Duration debounce;

  Timer? _timer;
  bool _running = false;

  /// 同步执行期间到达的新变更标记：执行完成后重新排队，避免变更被吞。
  bool _pendingWhileRunning = false;

  StreamSubscription<Set<TableUpdate>>? _sub;

  AutoSyncCoordinator({
    required this.changes,
    required this.isLoggedIn,
    required this.sync,
    this.debounce = const Duration(seconds: 2),
  });

  /// 开始监听变更流（幂等；dispose 后不可复用）。
  ///
  /// [syncOnStart] 用于登录态冷启动或重新登录：主动调度一轮，消费监听建立前
  /// 已经存在的 pending mutation，并顺便收敛远端游标。
  void start({bool syncOnStart = false}) {
    if (_sub != null) return;
    _sub = changes.listen((_) => _schedule());
    if (syncOnStart) _schedule();
  }

  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    _sub = null;
  }

  /// 防抖调度：窗口内多次变更重置计时器只触发一次；执行期间的变更
  /// 记 pending 标记，待本轮完成后重新排队（防止变更被吞）。
  void _schedule() {
    if (_running) {
      _pendingWhileRunning = true;
      return;
    }
    _timer?.cancel();
    _timer = Timer(debounce, _sync);
  }

  /// 执行同步：单飞防重入；未登录直接跳过（变更保留在队列，登录后由
  /// 显式同步/下次触发推送）。
  Future<void> _sync() async {
    if (_running || !isLoggedIn()) return;
    _running = true;
    try {
      await sync();
    } finally {
      _running = false;
      if (_pendingWhileRunning) {
        _pendingWhileRunning = false;
        _schedule();
      }
    }
  }
}

/// 自动推送编排 provider：监听 sync_changes 表变化，防抖后触发完整同步。
///
/// 需要被显式 watch 保持活跃（main.dart 装配处 watch 一次）。
final autoSyncCoordinatorProvider = Provider<AutoSyncCoordinator>((ref) {
  final db = ref.watch(databaseProvider);
  // 监听会话而非只在回调中 read：登录/登出会重建协调器，登录后立即消费
  // 冷启动或离线期间遗留的 pending，不必等待用户再编辑一笔。
  final session = ref.watch(authSessionProvider);
  final coordinator = AutoSyncCoordinator(
    changes: db.tableUpdates(TableUpdateQuery.onAllTables([db.syncChanges])),
    isLoggedIn: () => ref.read(authSessionProvider) != null,
    sync: () async {
      final result = await ref.read(syncCoordinatorProvider).run();
      if (result.error != null) {
        logger.warning('AutoSync', '自动同步失败(下次变更会重试): ${result.error}');
      }
    },
  );
  coordinator.start(syncOnStart: session != null);
  ref.onDispose(coordinator.dispose);
  return coordinator;
});
