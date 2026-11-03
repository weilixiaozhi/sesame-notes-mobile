import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 记录编辑历史:某条交易的编辑历史列表,按版本号倒序。
///
/// 为记录详情的统一编辑历史列表提供本机条目。
/// 本机编辑序号仅保留其来源语义，Provider 只读缓存原始记录；
/// 交易被编辑后由调用方主动 invalidate 此 provider 触发刷新。
final recordEditHistoryProvider = FutureProvider.family
    .autoDispose<List<RecordEditHistoryDisplay>, String>((ref, recordId) async {
      final account = ref.watch(currentAccountIdProvider);
      final generation = ref.watch(authIdentityGenerationProvider);
      final repo = ref.watch(statisticsDataAccessProvider);
      final transactions = ref.watch(transactionDataAccessProvider);
      try {
        final transaction = await transactions.getTransactionById(recordId);
        if (!ref.mounted || transaction == null) {
          throw StateError('记录暂不可用');
        }
        final ledger = await ref.watch(
          ledgerByIdProvider(transaction.ledgerId).future,
        );
        final rows = await repo.getEditHistories(recordId);
        if (!ref.mounted ||
            ledger == null ||
            ref.read(currentAccountIdProvider) != account ||
            ref.read(authIdentityGenerationProvider) != generation) {
          throw StateError('历史记录所属账号或账本已变化');
        }
        return rows.map((row) => row.toDisplay()).toList(growable: false);
      } catch (error, stack) {
        logger.error(
          'RecordHistory',
          '读取本机编辑历史失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });
