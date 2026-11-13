import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

/// 服务端云端修订号独立于本机编辑序号，变更内容保持原始字符串和 JSON 值。
class CloudRecordHistoryEntry {
  const CloudRecordHistoryEntry({
    required this.id,
    required this.recordId,
    required this.version,
    required this.createdAt,
    required this.changes,
    this.operatorMemberId,
    this.operatorDisplayName,
  });
  final String id;
  final String recordId;
  final int version;
  final DateTime createdAt;
  final Object? changes;
  final String? operatorMemberId;
  final String? operatorDisplayName;
}

/// 单页响应只包含服务端确认的历史及下一页位置。
class CloudRecordHistoryPage {
  const CloudRecordHistoryPage(this.items, this.nextCursor);
  final List<CloudRecordHistoryEntry> items;
  final String? nextCursor;
}

/// 批量读取一批交易的历史页；服务端单次最多接受 100 个交易编号。
typedef CloudRecordHistoryLoader =
    Future<CloudRecordHistoryPage> Function({
      required String ledgerId,
      required List<String> transactionIds,
      String? cursor,
      required CancelToken cancelToken,
    });

/// 使用生成客户端批量读取历史，服务响应不能跨账本或请求集合混入结果。
final cloudRecordHistoryLoaderProvider = Provider<CloudRecordHistoryLoader>((
  ref,
) {
  final client = ref.watch(apiClientProvider);
  return ({
    required String ledgerId,
    required List<String> transactionIds,
    String? cursor,
    required CancelToken cancelToken,
  }) async {
    try {
      final response = await client
          .getTransactionsApi()
          .getTransactionsEditHistory(
            ledgerId: ledgerId,
            transactionIds: transactionIds.join(','),
            limit: _batchPageLimit,
            cursor: cursor,
            cancelToken: cancelToken,
          );
      final data = response.data;
      if (data == null) throw const FormatException('编辑历史响应为空');
      final requested = transactionIds.toSet();
      final items = <CloudRecordHistoryEntry>[];
      for (final item in data.items) {
        if (item.ledgerId != ledgerId ||
            !requested.contains(item.transactionId)) {
          throw const FormatException('编辑历史响应归属不一致');
        }
        items.add(
          CloudRecordHistoryEntry(
            id: item.id,
            recordId: item.transactionId,
            version: item.version,
            createdAt: item.createdAt,
            changes: item.changes?.value,
            operatorMemberId: item.operatorMemberId,
            operatorDisplayName: item.operatorDisplayName,
          ),
        );
      }
      return CloudRecordHistoryPage(List.unmodifiable(items), data.nextCursor);
    } catch (error, stack) {
      logger.error(
        'RecordHistory',
        '批量读取云端编辑历史失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  };
});

/// 单次批量请求的交易数量上限，与服务端契约保持一致。
const _batchTransactionLimit = 100;

/// 单页最多 200 行；逐页写入本机缓存，任何时刻只保留一页数据在内存中。
const _batchPageLimit = 200;

/// 同一账号、交易和服务端版本在窗口内只尝试一次。
const Duration _refreshCooldown = Duration(seconds: 30);

/// 静默补拉的进程内冷却状态；页面重建或切换账期不会重复请求同一版本。
final _recordHistoryRefreshStateProvider =
    Provider<Map<(int, String), ({int revision, DateTime at})>>(
      (ref) => <(int, String), ({int revision, DateTime at})>{},
    );

/// 同一交易正在补拉时不再启动第二份，避免页面重建放大请求量。
final _recordHistoryInFlightProvider = Provider<Set<String>>(
  (ref) => <String>{},
);

/// 静默补拉一批交易的云端编辑历史，按页写入本机缓存。
///
/// 只处理云端账本、已上传且缓存尚未完整的交易；服务端每产生一次编辑写入
/// 一行版本 2..revision 的历史，因此同时核对最高版本和行数，避免中断的
/// 批量补拉被误判为完成。未登录、离线、服务端异常都只记录日志，页面不订阅
/// 本函数的状态，也不展示转圈、重试或错误文案。
Future<void> refreshCloudRecordEditHistories(
  ProviderContainer container,
  String ledgerId,
  Iterable<TransactionDisplay> transactions,
) async {
  try {
    final candidates = transactions
        .where(
          (transaction) =>
              transaction.ledgerId == ledgerId &&
              transaction.serverRevision != null &&
              transaction.serverRevision! > 1,
        )
        .toList(growable: false);
    if (candidates.isEmpty) return;
    if (!container.read(cloudCapabilityProvider).canSync) return;
    final ledger = await container
        .read(ledgerDataAccessProvider)
        .getLedgerById(ledgerId);
    final account = container.read(currentAccountIdProvider);
    if (ledger == null ||
        ledger.storageMode != 'cloud' ||
        ledger.syncId == null ||
        // 页面数据可能来自旧账号，账本必须仍属于当前账号的数据域。
        ledger.scopeAccountId != null && ledger.scopeAccountId != account) {
      return;
    }
    final generation = container.read(authIdentityGenerationProvider);
    final cacheStates = await container
        .read(statisticsDataAccessProvider)
        .cloudEditHistoryCacheStates(
          candidates.map((transaction) => transaction.id),
        );
    final refreshState = container.read(_recordHistoryRefreshStateProvider);
    final inFlight = container.read(_recordHistoryInFlightProvider);
    final now = DateTime.now();
    final stale = <TransactionDisplay>[];
    for (final transaction in candidates) {
      final revision = transaction.serverRevision!;
      final state = cacheStates[transaction.id];
      if (state != null &&
          state.maxVersion >= revision &&
          state.count >= revision - 1) {
        continue;
      }
      final key = (generation, transaction.id);
      final last = refreshState[key];
      if (last != null &&
          last.revision == revision &&
          now.difference(last.at) < _refreshCooldown) {
        continue;
      }
      if (!inFlight.add(transaction.id)) continue;
      refreshState[key] = (revision: revision, at: now);
      stale.add(transaction);
    }
    if (stale.isEmpty) return;

    // 按服务端上限切块，逐块串行处理；每块内部逐页写入，内存只保留当前页。
    for (
      var offset = 0;
      offset < stale.length;
      offset += _batchTransactionLimit
    ) {
      final end = (offset + _batchTransactionLimit).clamp(0, stale.length);
      final chunk = stale.sublist(offset, end);
      try {
        await _refreshChunk(
          container: container,
          ledgerId: ledgerId,
          transactions: chunk,
          account: account,
          generation: generation,
        );
      } catch (error, stack) {
        logger.warning(
          'RecordHistory',
          '云端历史静默补拉失败 ledger=$ledgerId count=${chunk.length}',
          '${safeErrorSummary(error)}\n$stack',
        );
      } finally {
        for (final transaction in chunk) {
          inFlight.remove(transaction.id);
        }
      }
    }
  } catch (error, stack) {
    logger.warning(
      'RecordHistory',
      '云端历史静默补拉未启动 ledger=$ledgerId',
      '${safeErrorSummary(error)}\n$stack',
    );
  }
}

/// 处理一个交易块的连续分页；每页立即落库，失败时保留已写入的前页并在下轮重试。
Future<void> _refreshChunk({
  required ProviderContainer container,
  required String ledgerId,
  required List<TransactionDisplay> transactions,
  required String? account,
  required int generation,
}) async {
  final transactionIds = transactions
      .map((transaction) => transaction.id)
      .toList(growable: false);
  final loader = container.read(cloudRecordHistoryLoaderProvider);
  final repository = container.read(transactionDataAccessProvider);
  final cancelToken = CancelToken();
  final seenCursors = <String>{};
  String? cursor;
  var pages = 0;
  while (true) {
    final page = await loader(
      ledgerId: ledgerId,
      transactionIds: transactionIds,
      cursor: cursor,
      cancelToken: cancelToken,
    );
    if (!_isCurrentIdentity(container, account, generation)) return;
    if (page.items.isEmpty && page.nextCursor != null) {
      throw const FormatException('空编辑历史页不能继续分页');
    }
    if (page.nextCursor != null &&
        (page.nextCursor == cursor ||
            !seenCursors.add(page.nextCursor!) ||
            ++pages >= 1000)) {
      throw const FormatException('编辑历史分页位置没有前进');
    }
    if (page.items.isNotEmpty) {
      final rows = page.items
          .map(
            (entry) => CloudRecordEditHistorySnapshot(
              id: entry.id,
              recordId: entry.recordId,
              version: entry.version,
              operatorMemberId: entry.operatorMemberId,
              operatorDisplayName: entry.operatorDisplayName,
              changesJson: jsonEncode(entry.changes),
              createdAt: entry.createdAt,
            ),
          )
          .toList(growable: false);
      await repository.upsertCloudEditHistories(rows);
    }
    if (!_isCurrentIdentity(container, account, generation)) return;
    if (page.nextCursor == null) return;
    cursor = page.nextCursor;
  }
}

/// 身份切换后旧请求结果失去写入资格；令牌刷新不改变身份代次。
bool _isCurrentIdentity(
  ProviderContainer container,
  String? account,
  int generation,
) =>
    container.read(cloudCapabilityProvider).hasSession &&
    container.read(currentAccountIdProvider) == account &&
    container.read(authIdentityGenerationProvider) == generation;
