import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

/// 记录编辑历史：本机历史与云端缓存历史合并后的列表。
///
/// 详情页只订阅本机数据库，不发起网络请求，因此离线、弱网或云端失败时
/// 仍立即展示已缓存内容；云端补拉由列表页静默完成并写回本机缓存。
final recordEditHistoryProvider = StreamProvider.family
    .autoDispose<List<RecordEditHistoryDisplay>, String>((
      ref,
      recordId,
    ) async* {
      final account = ref.watch(currentAccountIdProvider);
      final generation = ref.watch(authIdentityGenerationProvider);
      final transactions = ref.watch(transactionDataAccessProvider);
      final repo = ref.watch(statisticsDataAccessProvider);
      try {
        // 先确认交易与账本仍属于当前账号，避免旧页面读到其他账号域的历史。
        final transaction = await transactions.getTransactionById(recordId);
        if (!ref.mounted || transaction == null) {
          throw StateError('记录暂不可用');
        }
        final ledger = await ref.watch(
          ledgerByIdProvider(transaction.ledgerId).future,
        );
        if (!ref.mounted ||
            ledger == null ||
            ref.read(currentAccountIdProvider) != account ||
            ref.read(authIdentityGenerationProvider) != generation) {
          throw StateError('历史记录所属账号或账本已变化');
        }
        await for (final rows in repo.watchEditHistories(recordId)) {
          if (!ref.mounted ||
              ref.read(currentAccountIdProvider) != account ||
              ref.read(authIdentityGenerationProvider) != generation) {
            throw StateError('历史记录所属账号或账本已变化');
          }
          yield _mergeHistories(
            rows.local,
            rows.cloud,
            transaction.serverRevision,
          );
        }
      } catch (error, stack) {
        logger.error(
          'RecordHistory',
          '读取编辑历史失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });

/// 合并本机行与云端缓存行；云端完整时本机行只是同一编辑的乐观副本。
///
/// 服务端每个修订号只有一条历史，客户端只在云端尚未覆盖时展示本机行；
/// 云端完整后仅保留 `version > serverRevision` 的待同步本机行，避免同一次
/// 编辑在详情里出现“本机摘要 + 云端详细内容”两条。
List<RecordEditHistoryDisplay> _mergeHistories(
  List<RecordEditHistorySnapshot> localRows,
  List<CloudRecordEditHistorySnapshot> cloudRows,
  int? serverRevision,
) {
  try {
    final cloudItems = <RecordEditHistoryDisplay>[
      for (final row in cloudRows)
        RecordEditHistoryDisplay(
          version: row.version,
          operatorMemberId: row.operatorMemberId,
          operatorDisplayName: row.operatorDisplayName,
          changes: _decodeChanges(row.changesJson),
          isCloud: true,
          createdAt: row.createdAt,
        ),
    ];
    final cloudComplete = _cloudComplete(cloudRows, serverRevision);
    final cloudVersions = cloudRows.map((row) => row.version).toSet();
    final localItems = <RecordEditHistoryDisplay>[
      for (final row in localRows)
        if (cloudComplete
            ? serverRevision != null && row.version > serverRevision
            : !cloudVersions.contains(row.version))
          row.toDisplay(),
    ];
    final items = <RecordEditHistoryDisplay>[...cloudItems, ...localItems];
    // 时间倒序；同一时刻优先服务端修订，再按版本号保证顺序稳定。
    items.sort((left, right) {
      final time = right.createdAt.compareTo(left.createdAt);
      if (time != 0) return time;
      final source = left.isCloud == right.isCloud
          ? 0
          : (left.isCloud ? -1 : 1);
      if (source != 0) return source;
      return right.version.compareTo(left.version);
    });
    return List.unmodifiable(items);
  } catch (error, stack) {
    logger.error('RecordHistory', '整理编辑历史失败', safeErrorSummary(error), stack);
    rethrow;
  }
}

/// 云端历史覆盖到服务端修订号且行数完整时，才允许隐藏本机副本。
///
/// 服务端只在更新时写历史，正常数据应有 revision-1 条版本 2..revision 的记录；
/// 行数校验用于识别中断的批量补拉，避免只拿到最新版本就误判完整。
bool _cloudComplete(
  List<CloudRecordEditHistorySnapshot> cloudRows,
  int? serverRevision,
) {
  if (serverRevision == null) return false;
  if (serverRevision <= 1) return cloudRows.isEmpty;
  var maxVersion = 0;
  for (final row in cloudRows) {
    if (row.version > maxVersion) maxVersion = row.version;
  }
  return maxVersion >= serverRevision && cloudRows.length >= serverRevision - 1;
}

/// 缓存正文损坏时按“已记录一次编辑”降级，不让整段历史读取失败。
Object? _decodeChanges(String changesJson) {
  try {
    return jsonDecode(changesJson);
  } catch (error, stack) {
    logger.warning(
      'RecordHistory',
      '云端编辑历史正文无法解析',
      '${safeErrorSummary(error)}\n$stack',
    );
    return null;
  }
}
