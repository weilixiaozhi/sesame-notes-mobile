import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

/// 固定空列表同时记录订阅次数，排除真实交易变更对计数的影响。
class _Repository extends Fake implements StatisticsRepository {
  int subscriptions = 0;

  /// 每次方法调用代表重新建立一次数据库查询流。
  @override
  Stream<List<({TransactionSnapshot t, CategorySnapshot? category})>>
  watchExcludedAaTransactions(String ledgerId) {
    subscriptions++;
    return Stream.value(const []);
  }
}

/// 验证列表由自身数据源驱动，统计异步状态不会反复取消查询。
void main() {
  test('统计完成和刷新不重订阅列表，替换数据源仍重建订阅', () async {
    final repository = _Repository();
    var completion = Completer<AaLedgerStatistics>();
    final statistics = aaStatisticsProvider('ledger');
    final container = ProviderContainer(
      overrides: [
        statisticsDataAccessProvider.overrideWithValue(repository),
        statistics.overrideWith((ref) => completion.future),
      ],
    );
    try {
      container.listen(statistics, (_, _) {});
      container.listen(aaNoSplitTxProvider('ledger'), (_, _) {});
      await container.pump();
      completion.complete(
        AaLedgerStatistics(participants: const [], transfers: const []),
      );
      await container.pump();
      expect(repository.subscriptions, 1);

      completion = Completer<AaLedgerStatistics>();
      container.invalidate(statistics);
      await container.pump();
      completion.complete(
        AaLedgerStatistics(participants: const [], transfers: const []),
      );
      await container.pump();
      expect(repository.subscriptions, 1, reason: '统计刷新没有改变列表查询来源');

      final replacement = _Repository();
      container.updateOverrides([
        statisticsDataAccessProvider.overrideWithValue(replacement),
        statistics.overrideWith((ref) => completion.future),
      ]);
      await container.pump();
      expect(replacement.subscriptions, 1, reason: '账号或仓储替换必须建立新来源的订阅');
    } catch (error, stackTrace) {
      // 这里只含受控测试对象，不输出账号或交易正文。
      logger.error('AaQueryLifecycleTest', 'AA 查询生命周期验证失败', error, stackTrace);
      rethrow;
    } finally {
      container.dispose();
    }
  });
}
