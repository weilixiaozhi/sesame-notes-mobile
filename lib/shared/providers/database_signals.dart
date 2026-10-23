import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'database_providers.dart';
import 'refresh_ticks.dart';

// 数据库Provider
/// 统一业务数据变更信号：任何业务表发生写入（插入/更新/删除）都会发射一次。
///
/// 所有汇总/统计 provider 只依赖这一个信号，保证「无论从哪条路径写库都会
/// 自动刷新」。只订阅业务表，排除同步簿记表（sync_changes / sync_state /
/// sync_pull_errors / backup_state）与编辑历史表。
final dataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((ref) {
  // 手动刷新只重建这一个数据依赖源，所有派生 provider 会随之重算。
  final manualRefreshRevision = ref.watch(manualDataRefreshProvider);
  final db = ref.watch(databaseProvider);
  return _watchBusinessDataChanges(
    db,
    emitManualRefresh: manualRefreshRevision > 0,
  );
});

/// 财务派生值只监听真正影响它的表，其他业务保存正文不会重算财务汇总。
final accountingDataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((
  ref,
) {
  final revision = ref.watch(manualDataRefreshProvider);
  final db = ref.watch(databaseProvider);
  return _watchBusinessDataChanges(
    db,
    emitManualRefresh: revision > 0,
    query: TableUpdateQuery.onAllTables([
      db.ledgers,
      db.categories,
      db.transactions,
      db.transactionSplits,
      db.recurringTransactions,
      db.ledgerMembers,
      db.sharedLedgerCategories,
      db.exchangeRates,
      db.exchangeRateOverrides,
    ]),
  );
});

/// 监听所有会影响客户端展示的业务表。
///
/// 手动刷新时先发射空集合，让重建的流真正通知消费者；
/// 常规首次订阅不额外发射，避免页面初始化重查两次。
Stream<Set<TableUpdate>> _watchBusinessDataChanges(
  SesameDatabase db, {
  required bool emitManualRefresh,
  TableUpdateQuery? query,
}) async* {
  if (emitManualRefresh) yield <TableUpdate>{};
  try {
    yield* db.tableUpdates(
      query ??
          TableUpdateQuery.onAllTables([
            db.ledgers,
            db.dayBooks,
            db.dayEvents,
            db.memoBooks,
            db.memoEntries,
            db.memoImportReceipts,
            db.fitnessEntities,
            db.fitnessSpaces,
            db.fitnessImportReceipts,
            db.categories,
            db.transactions,
            db.transactionSplits,
            db.recurringTransactions,
            db.ledgerMembers,
            db.sharedLedgerCategories,
            db.exchangeRates,
            db.exchangeRateOverrides,
            // 同步冲突属于业务状态，解决或新增时需要刷新冲突 UI。
            db.syncConflicts,
          ]),
    );
  } catch (e, st) {
    logger.error('DataChangeSignal', '监听业务数据变更失败', e, st);
    rethrow;
  }
}
