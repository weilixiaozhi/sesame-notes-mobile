import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/ledger_sync_status.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';
import 'package:sesame_notes/sync/sync_service.dart';
// 只取展示模型：本文件已 import 生成 API 的 Ledger，全量 barrel 会撞名。
import 'package:sesame_notes/data/models.dart' show SyncConflictView;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 当前账本的 OPEN 冲突列表（冲突 UI 数据源）。
/// FutureProvider + 表变化信号驱动：不使用 drift watch 流（widget 测试的
/// fake_async 环境对流取消的延迟 timer 敏感，且冲突变更频率低）。
///
/// 出口为 [SyncConflictView]：Drift Row 在本 Provider 内完成映射，
/// 页面不接触 schema 类型（schema 增列不外溢到 UI）。
final ledgerOpenConflictsProvider =
    FutureProvider.autoDispose<List<SyncConflictView>>((ref) async {
      final ledgerId = ref.watch(currentLedgerIdProvider);
      if (ledgerId.isEmpty) return const [];
      final ledger = ref.watch(currentLedgerProvider).value;
      if (ledger == null || ledger.storageMode != 'cloud') return const [];
      // 账本/冲突/交易等表变化时重新查询
      ref.watch(dataChangeSignalProvider);
      final db = ref.watch(databaseProvider);
      final rows =
          await (db.select(db.syncConflicts)..where(
                (c) => c.ledgerId.equals(ledgerId) & c.status.equals('OPEN'),
              ))
              .get();
      return [
        for (final row in rows)
          SyncConflictView(
            id: row.id,
            entityId: row.entityId,
            baseRevision: row.baseRevision,
            remoteRevision: row.remoteRevision,
          ),
      ];
    });

/// 当前账本的同步绑定状态（null/bound 正常；'stale' = SYNC_ID_MISMATCH）。
final ledgerBindingStatusProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  if (ledgerId.isEmpty) return null;
  final ledger = ref.watch(currentLedgerProvider).value;
  if (ledger == null || ledger.storageMode != 'cloud') return null;
  ref.watch(dataChangeSignalProvider);
  final db = ref.watch(databaseProvider);
  final row = await (db.select(
    db.ledgers,
  )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
  return row?.bindingStatus;
});

/// 同步服务实例：设备标识必须与会话绑定设备一致（push 校验），
/// 登录后 deviceId 即本地预生成、服务端原样接受的持久化设备 id；
/// 未登录时用本地占位 id 兜底（不会真正发起 push/pull）。
final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(apiClientProvider);
  final db = ref.watch(databaseProvider);
  final session = ref.watch(authSessionProvider);
  return SyncService(
    client: client,
    db: db,
    deviceId: session?.deviceId ?? localDeviceId,
    // 412 时把本地状态保护为 Local Safety Fork（绝不默认放弃本地修改）
    repo: LocalLedgerRepository(db),
    localSelfIdLoader: () => ref.read(localSelfIdProvider.future),
    currentAccountIdGetter: () => ref.read(authSessionProvider)?.userId,
  );
});

/// 同步编排器：统一触发 push / pull / full，并上报最近一次同步结果。
final syncCoordinatorProvider = Provider<SyncCoordinator>(
  (ref) => SyncCoordinator(ref),
);

/// 同步执行结果（最近一次动作的汇总）。
class SyncRunResult {
  final int pushed;
  final int pulled;
  final String? error;

  const SyncRunResult({this.pushed = 0, this.pulled = 0, this.error});

  bool get ok => error == null;
}

/// 同步编排：按「先推后拉」顺序执行完整一轮，异常时记录日志并返回错误信息。
class SyncCoordinator {
  final Ref ref;

  Future<SyncRunResult>? _activeRun;
  bool _rerunRequested = false;

  SyncCoordinator(this.ref);

  SyncService get _service => ref.read(syncServiceProvider);

  /// 串行执行完整同步（push → pull），返回最后一轮结果。
  ///
  /// 闸门置起（退出登录 purge 期间）时直接降级返回，不发起任何网络请求，
  /// 避免并发同步把刚清掉的云端账本重新拉回。执行期间的新触发会被合并为
  /// 一次尾随补跑，确保首轮 push 取快照后新增的 mutation 不会被吞掉。
  Future<SyncRunResult> run() {
    final active = _activeRun;
    if (active != null) {
      _rerunRequested = true;
      return active;
    }

    late final Future<SyncRunResult> current;
    current = _runSerially().whenComplete(() {
      if (identical(_activeRun, current)) _activeRun = null;
    });
    _activeRun = current;
    return current;
  }

  /// 执行当前轮及被合并的尾随轮；同一时刻只允许一个网络同步链路运行。
  ///
  /// 整轮（含尾随补跑）期间置起 busy 信号供账本卡片显示上传转圈；
  /// 结束后 bump 同步 tick —— push 标记 pushedAt 不发射业务数据信号，
  /// 卡片状态等派生方依赖该 tick 重算「待推送 → 已同步」。
  Future<SyncRunResult> _runSerially() async {
    ref.read(syncBusyProvider.notifier).start();
    try {
      var result = await _runOnce();
      while (_rerunRequested) {
        _rerunRequested = false;
        result = await _runOnce();
      }
      return result;
    } finally {
      ref.read(syncBusyProvider.notifier).stop();
      ref.read(syncRunTickProvider.notifier).tick();
    }
  }

  /// 执行单轮 push → pull，并把技术异常转换为可展示的失败结果。
  Future<SyncRunResult> _runOnce() async {
    if (ref.read(syncGateProvider)) {
      return const SyncRunResult(error: '同步暂停中（数据清理进行中）');
    }
    try {
      await _service.push();
      final pulled = await _service.pull();
      logger.info('SyncCoordinator', '同步完成, pull=$pulled');
      return SyncRunResult(pulled: pulled);
    } catch (e, st) {
      logger.error('SyncCoordinator', '同步失败: $e', e, st);
      return const SyncRunResult(error: '同步失败，请检查网络后重试');
    }
  }

  /// 刷新客户端业务数据。
  ///
  /// [ledgerId] 非空时按该账本的 storageMode 决策，本地账本只重查本地库；
  /// 为空时用于账本列表，只要账号下存在云账本便执行一次账号级增量同步。
  /// 无论云同步成功与否都会触发本地重查，让页面至少展示当前可用快照。
  Future<SyncRunResult> refreshData({String? ledgerId}) async {
    try {
      final repo = ref.read(repositoryProvider);
      final isAccountRefresh = ledgerId == null || ledgerId.isEmpty;
      final ledger = isAccountRefresh
          ? null
          : await repo.getLedgerById(ledgerId);
      final session = ref.read(authSessionProvider);
      // 账号级刷新不能依赖本地已缓存云账本，否则无法发现其他设备刚创建或
      // 分享给当前账号的远端账本；未登录时仍只刷新本地快照。
      final needsCloudSync = isAccountRefresh
          ? session != null
          : ledger?.storageMode == 'cloud';

      if (!needsCloudSync) return const SyncRunResult();
      if (session == null) {
        return const SyncRunResult(error: '请先登录后再同步云账本');
      }
      if (ledger?.bindingStatus == 'stale') {
        return const SyncRunResult(error: '云账本绑定已失效，请重新连接');
      }
      return await run();
    } catch (e, st) {
      logger.error('SyncCoordinator', '刷新业务数据失败: $e', e, st);
      return const SyncRunResult(error: '刷新失败，请稍后重试');
    } finally {
      // 即使网络失败也重新读取本地快照，避免页面保留已过期缓存。
      ref.read(manualDataRefreshProvider.notifier).tick();
    }
  }

  /// Reconnect v1：登录原账号 → 下载服务器当前状态。
  ///
  /// 语义：只做 full 快照收敛，绝不重放备份 queue/cursor；
  /// 本地 LOCAL 账本（含备份 Fork 产物）不被下载/改写。
  Future<ReconnectReport> reconnect() async {
    if (ref.read(syncGateProvider)) {
      return const ReconnectReport(refreshed: [], stale: [], gone: []);
    }
    final service = ReconnectV1Service(
      db: ref.read(databaseProvider),
      sync: _service,
    );
    return service.reconnectAfterLogin();
  }

  /// 首次登录/新设备：拉取账本列表，对每个账本做 full 快照收敛。
  Future<SyncRunResult> bootstrap() async {
    if (ref.read(syncGateProvider)) {
      return const SyncRunResult(error: '同步暂停中（数据清理进行中）');
    }
    try {
      // 登录后先取账本清单，逐个账本做全量快照落库。
      final client = ref.read(apiClientProvider);
      final api = LedgersApi(client.dio, client.serializers);
      final ledgers = await api.getLedgers();
      for (final l in ledgers.data ?? const <Ledger>[]) {
        await _service.full(ledgerId: l.id);
      }
      return const SyncRunResult();
    } catch (e, st) {
      logger.error('SyncCoordinator', 'bootstrap 失败: $e', st);
      return SyncRunResult(error: e.toString());
    }
  }
}

/// 同步轮结束 tick：同步服务直写 sync_changes（标记 pushedAt）不发射
/// 业务数据信号，账本卡片同步状态等派生方依赖它触发重算。
final syncRunTickProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

/// 同步执行中信号：整轮（push → pull，含尾随补跑）期间为 true。
final syncBusyProvider = NotifierProvider<SyncBusyNotifier, bool>(
  SyncBusyNotifier.new,
);

/// 同步执行中闸门状态：默认空闲（false）。
class SyncBusyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 标记一轮同步开始。
  void start() => state = true;

  /// 标记一轮同步结束。
  void stop() => state = false;
}

/// 指定账本的卡片同步状态。
///
/// 数据源：账本持久字段（storage_mode / binding_status）+ 会话 + 该账本
/// 待推 mutation 数与 OPEN 冲突数，经 [ledgerSyncStatusOf] 纯函数投影。
/// 重算时机：同步轮结束 tick、业务数据变更信号、会话切换。
final ledgerSyncStatusProvider = FutureProvider.autoDispose
    .family<LedgerSyncStatus, String>((ref, ledgerId) async {
      // 先同步订阅全部运行态信号，再进入异步查询（Riverpod 依赖图完整性）。
      ref.watch(syncRunTickProvider);
      ref.watch(dataChangeSignalProvider);
      final session = ref.watch(authSessionProvider);
      final db = ref.watch(databaseProvider);

      final ledger = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
      // 账本不存在或非云端归属：不画云。
      if (ledger == null || ledger.storageMode != 'cloud') {
        return LedgerSyncStatus.local;
      }
      // 未登录：连不上服务器，不再查询待推/冲突。
      if (session == null) return LedgerSyncStatus.notLoggedIn;

      // 待推 mutation：只统计当前账号域（与 push 的账号过滤一致）。
      final pending =
          await (db.select(db.syncChanges)..where(
                (c) =>
                    c.ledgerId.equals(ledgerId) &
                    c.pushedAt.isNull() &
                    c.accountId.equals(session.userId),
              ))
              .get();
      final conflicts =
          await (db.select(db.syncConflicts)..where(
                (x) => x.ledgerId.equals(ledgerId) & x.status.equals('OPEN'),
              ))
              .get();

      return ledgerSyncStatusOf(
        storageMode: ledger.storageMode,
        bindingStatus: ledger.bindingStatus,
        hasSession: true,
        pendingCount: pending.length,
        conflictCount: conflicts.length,
      );
    });
