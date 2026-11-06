import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../helpers/test_isolation.dart';

/// 验证记账提交后财务汇总自动更新，显式刷新保留准确金额。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final month = DateTime(2026, 10);
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<double>> subscription;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger',
            name: '日常',
            updatedAt: DateTime.utc(2026),
          ),
        );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        statisticsDataAccessProvider.overrideWithValue(repo),
      ],
    );
    subscription = container.listen(
      monthlyTotalsProvider((ledgerId: 'ledger', month: month)),
      (_, _) {},
    );
    await container.read(
      monthlyTotalsProvider((ledgerId: 'ledger', month: month)).future,
    );
    await container.pump();
  });
  tearDown(() async {
    subscription.close();
    container.dispose();
    await db.close();
  });

  /// 等待已有的流通知与依赖重算完成，不靠真实计时器制造观察窗口。
  Future<double> settleTotals() async {
    await container.pump();
    final total = await container.read(
      monthlyTotalsProvider((ledgerId: 'ledger', month: month)).future,
    );
    await container.pump();
    return total;
  }

  test('记账提交仍更新真实汇总，手动刷新仍能重新读取', () async {
    try {
      await container
          .read(syncCoordinatorProvider)
          .runDataMutation(
            () => repo.addTransaction(
              ledgerId: 'ledger',
              type: 'expense',
              amount: '12.34',
              happenedAt: DateTime(2026, 10, 19),
            ),
          );
      expect(await settleTotals(), 12.34);
      container.read(manualDataRefreshProvider.notifier).tick();
      expect(await settleTotals(), 12.34);
    } catch (error, stackTrace) {
      logger.error('AccountingRefreshTest', '财务写入及显式刷新验证失败', error, stackTrace);
      rethrow;
    }
  });
}
