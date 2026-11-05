import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/mutation_executor_provider.dart';
import 'package:sesame_notes/shared/providers/published_ledger_queries.dart';

import 'recurring_transaction_service.dart';

/// 启动后按当前账号的已发布账本补记周期交易，归档模板仍正常生成。
final startupRecurringGenerationProvider = Provider<Future<Set<String>> Function()>(
  (ref) => () async {
    final database = ref.read(databaseProvider);
    final repository = ref.read(transactionDataAccessProvider);
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);

    /// 账号、同账号重登录和数据库替换均使旧扫描失效，令牌轮换不会误停。
    void verifyScope() {
      if (!ref.mounted ||
          ref.read(currentAccountIdProvider) != account ||
          ref.read(authIdentityGenerationProvider) != generation ||
          !identical(ref.read(databaseProvider), database) ||
          !identical(ref.read(transactionDataAccessProvider), repository)) {
        throw const RecurringGenerationCancelledException();
      }
    }

    try {
      final ledgers = await readPublishedLedgers(ref.read, archived: null);
      verifyScope();
      return await RecurringTransactionService.generatePendingTransactionsStatic(
        repository: repository,
        ledgers: ledgers,
        mutationExecutor: ref.read(mutationExecutorProvider),
        verifyScope: verifyScope,
      );
    } on RecurringGenerationCancelledException {
      logger.info('Recurring', '启动周期扫描所属状态已变化，等待后续扫描');
      return {};
    } catch (error, stackTrace) {
      logger.error(
        'Recurring',
        '准备周期补记失败，请稍后重试',
        safeErrorSummary(error),
        stackTrace,
      );
      return {};
    }
  },
);
