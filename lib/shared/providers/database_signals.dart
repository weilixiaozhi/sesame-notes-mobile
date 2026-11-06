import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'database_providers.dart';
import 'refresh_ticks.dart';

// 数据库Provider
/// 统一业务数据变更信号：任何业务表发生写入（插入/更新/删除）都会发射一次。
///
/// 跨业务视图使用完整业务信号，各域汇总使用对应的专属信号。只订阅业务表，
/// 排除同步簿记表（sync_changes / sync_state /
/// sync_pull_errors / backup_state）与编辑历史表。
final dataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((ref) {
  // 手动刷新重建业务信号，依赖它的跨域视图随之重算。
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

/// 日子同步状态仅响应本域数据与冲突变化，回执另由同步轮次通知。
final dayDataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((ref) {
  final revision = ref.watch(manualDataRefreshProvider);
  final db = ref.watch(databaseProvider);
  return _watchBusinessDataChanges(
    db,
    emitManualRefresh: revision > 0,
    query: TableUpdateQuery.onAllTables([
      db.dayBooks,
      db.dayEvents,
      db.syncConflicts,
    ]),
  );
});

/// 训练同步状态不因财务和笔记保存而重新读取队列或解码冲突正文。
final fitnessDataChangeSignalProvider = StreamProvider<Set<TableUpdate>>((ref) {
  final revision = ref.watch(manualDataRefreshProvider);
  final db = ref.watch(databaseProvider);
  return _watchBusinessDataChanges(
    db,
    emitManualRefresh: revision > 0,
    query: TableUpdateQuery.onAllTables([
      db.fitnessSpaces,
      db.fitnessEntities,
      db.syncConflicts,
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
