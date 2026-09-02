/// Reconnect v1 服务：登录原账号 → 下载服务器当前状态。
///
/// - 只下载服务器当前状态（full 快照收敛），**绝不重放备份 queue/cursor**——
///   本服务不读不写 sync_changes / sync_state，本地队列与游标原样保留；
/// - 备份恢复出的 LOCAL Fork 账本绝不被下载/改写（LOCAL 账本
///   sync_id 恒 NULL，无隐式 Merge）；
/// - 服务端 sync identity 轮换（DR）后旧身份 full → 412 → 客户端标记
///   STALE_BINDING，由用户显式决策（abandonLocalChanges 重绑 / detach）。
library;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/sync/ledger_sync_state.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Ledger,
        Transaction,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import 'sync_service.dart';

/// Reconnect 结果报告（每类账本清单，供 UI 提示）。
class ReconnectReport {
  const ReconnectReport({
    required this.refreshed,
    required this.stale,
    required this.gone,
  });

  /// 已按服务器当前状态刷新的云端账本。
  final List<String> refreshed;

  /// 同步身份不匹配（412）→ 已标记 STALE_BINDING，等待用户决策重绑。
  final List<String> stale;

  /// 服务器已不存在（账号失去访问）的本地云端账本行，保留待用户决策。
  final List<String> gone;

  bool get allOk => stale.isEmpty && gone.isEmpty;
}

/// Reconnect v1：登录原账号后的云端状态收敛。
class ReconnectV1Service {
  ReconnectV1Service({
    required this.db,
    required this.sync,
    LedgersApi? ledgersApi,
  }) : _ledgersApi = ledgersApi; // ignore: prefer_initializing_formals

  final SesameDatabase db;
  final SyncService sync;

  /// 测试注入点：默认用 sync 的 client 构造。
  final LedgersApi? _ledgersApi;

  /// 登录后执行：按服务器当前账本清单逐个 full 收敛。
  ///
  /// 绝不重放备份 queue/cursor：本方法不触碰 sync_changes / sync_state
  /// （本地队列与游标原样保留）；本地 LOCAL 账本（含备份 Fork 产物）不参与下载
  /// （sync_id 恒 NULL，无隐式 Merge）。
  Future<ReconnectReport> reconnectAfterLogin() async {
    try {
      final api =
          _ledgersApi ?? LedgersApi(sync.client.dio, sync.client.serializers);
      final serverResp = await api.getLedgers();
      final serverLedgers = serverResp.data ?? const <Ledger>[];
      final serverIds = {for (final l in serverLedgers) l.id};

      // 本地云端账本逐个 full（携带本地 sync_id → 服务端校验身份）
      final localCloud =
          await (db.select(db.ledgers)..where(
                (l) => l.storageMode.equals('cloud') & l.deletedAt.isNull(),
              ))
              .get();
      final refreshed = <String>[];
      final stale = <String>[];
      final gone = <String>[];
      for (final ledger in localCloud) {
        // 服务器已无此账本（失去访问/已删除）：保留本地行，由用户决策
        if (!serverIds.contains(ledger.id)) {
          gone.add(ledger.id);
          continue;
        }
        if (ledgerSyncStateOf(
              storageMode: ledger.storageMode,
              syncId: ledger.syncId,
              bindingStatus: ledger.bindingStatus,
            ) ==
            LedgerSyncState.staleBinding) {
          stale.add(ledger.id);
          continue;
        }
        try {
          await sync.full(ledgerId: ledger.id);
          refreshed.add(ledger.id);
        } on DioException catch (e) {
          // 412 SYNC_ID_MISMATCH：sync.full 已标记 STALE_BINDING（本地分支保留）
          if (e.response?.statusCode == 412) {
            stale.add(ledger.id);
            continue;
          }
          rethrow;
        }
      }
      // 服务器有、本地无的账本（新设备/新邀请）：首次绑定下载。
      // 本地 id 集合必须包含全部账本（含 LOCAL Fork 产物）——否则本地已有
      // 的 Fork 会被误判为"新账本"重新下载，破坏"LOCAL 账本不被改写"语义。
      final allLocal = await (db.select(
        db.ledgers,
      )..where((l) => l.deletedAt.isNull())).get();
      final localIds = {for (final l in allLocal) l.id};
      for (final l in serverLedgers) {
        if (!localIds.contains(l.id)) {
          await sync.full(ledgerId: l.id);
          refreshed.add(l.id);
        }
      }
      return ReconnectReport(refreshed: refreshed, stale: stale, gone: gone);
    } catch (e, st) {
      logger.error('Reconnect', 'reconnect 失败', e, st);
      rethrow;
    }
  }
}
