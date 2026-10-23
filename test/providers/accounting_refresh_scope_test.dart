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

/// 记录真实汇总查询次数，数据库筛选与金额计算仍由生产仓储执行。
class _CountingRepository extends LocalRepository {
  /// 共用测试数据库，让读取计数围绕真实生产查询记录。
  _CountingRepository(super.db);

  int monthlyReads = 0;

  /// 查询次数只用于判断跨业务误失效，不以固定帧耗时替代业务正确性。
  @override
  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) {
    monthlyReads++;
    return super.monthlyTotals(ledgerId: ledgerId, month: month);
  }
}

/// 验证本机写入按受影响业务表刷新，手动重查仍可显式强制刷新。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final month = DateTime(2026, 10);
  late SesameDatabase db;
  late _CountingRepository repo;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<double>> subscription;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = _CountingRepository(db);
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

  for (final fails in [false, true]) {
    test('备忘事务${fails ? '回滚' : '提交'}不重新读取财务汇总', () async {
      try {
        final before = repo.monthlyReads;
        final write = container
            .read(syncCoordinatorProvider)
            .runDataMutation(
              () => db.transaction(() async {
                await db
                    .into(db.memoBooks)
                    .insert(
                      MemoBooksCompanion.insert(
                        id: 'memo-book',
                        name: '备忘',
                        type: 'normal',
                        createdAt: DateTime.utc(2026),
                        updatedAt: DateTime.utc(2026),
                      ),
                    );
                if (fails) throw StateError('模拟备忘事务回滚');
              }),
            );
        if (fails) {
          await expectLater(write, throwsA(isA<StateError>()));
        } else {
          await write;
        }
        expect(await settleTotals(), 0);
        expect(repo.monthlyReads, before, reason: '无财务表变化时不能通过全局刷新旁路重查');
      } catch (error, stackTrace) {
        logger.error('AccountingRefreshTest', '跨业务刷新隔离验证失败', error, stackTrace);
        rethrow;
      }
    });
  }

  test('记账提交仍更新真实汇总，手动刷新仍能重新读取', () async {
    try {
      final before = repo.monthlyReads;
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
      expect(repo.monthlyReads, greaterThan(before));
      final afterWrite = repo.monthlyReads;
      container.read(manualDataRefreshProvider.notifier).tick();
      expect(await settleTotals(), 12.34);
      expect(repo.monthlyReads, greaterThan(afterWrite));
    } catch (error, stackTrace) {
      logger.error('AccountingRefreshTest', '财务写入及显式刷新验证失败', error, stackTrace);
      rethrow;
    }
  });
}
