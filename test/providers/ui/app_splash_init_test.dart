// appSplashInitProvider 启动预加载流程测试。
//
// 需求锚点：
//   1. 依次完成基础配置初始化（主题/应用锁/显示名/可见币种等）；
//   2. 按当前账本预加载月度统计与最近交易，并写入缓存 provider；
//   3. 完成后切换 appInitState 为 ready；任一步失败不阻断完成；
//   4. 冷启动必须等待当前账本恢复解析收敛后再预加载：prefs 保存的非首个
//      账本即使在慢 IO 下也必须作为首屏查询的账本，不得用哨兵空串抢跑。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  setUp(() {
    resetGlobalTestState();
    repo = _MockRepo();

    when(() => repo.getAllLedgers()).thenAnswer((_) async => <db.Ledger>[]);
    when(() => repo.getLedgerById(any())).thenAnswer((_) async => null);
    when(
      () => repo.monthlyTotals(
        ledgerId: any(named: 'ledgerId'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) async => 0.0);
    when(
      () => repo.getRecentTransactionsWithCategory(
        ledgerId: any(named: 'ledgerId'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) async => <({db.Transaction t, db.Category? category})>[]);
    when(
      () => repo.getCountsForLedger(ledgerId: any(named: 'ledgerId')),
    ).thenAnswer((_) async => (dayCount: 0, txCount: 0));
    when(
      () => repo.getRecurringTransactionsByLedger(any()),
    ).thenAnswer((_) async => <db.RecurringTransaction>[]);
  });

  test('预加载完成并切换到 ready', () async {
    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<db.Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(appInitStateProvider), AppInitState.splash);

    await readProviderFutureFromContainer(
      container,
      appSplashInitProvider.future,
    );
    // 让 fire-and-forget 微任务（统计/周期生成）跑完。
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    expect(container.read(appInitStateProvider), AppInitState.ready);
    verify(
      () => repo.getRecentTransactionsWithCategory(ledgerId: '', limit: 20),
    ).called(1);
  });

  test('基础 provider 异常不阻断 ready', () async {
    when(
      () => repo.monthlyTotals(
        ledgerId: any(named: 'ledgerId'),
        month: any(named: 'month'),
      ),
    ).thenThrow(Exception('db down'));

    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<db.Ledger?>.value(null),
        ),
      ],
    );
    addTearDown(container.dispose);

    await readProviderFutureFromContainer(
      container,
      appSplashInitProvider.future,
    );
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    expect(
      container.read(appInitStateProvider),
      AppInitState.ready,
      reason: '预加载失败也要切换主应用，不卡启动',
    );
    await logger.clear();
  });

  test('冷启动慢 IO：保存的非首个账本在首屏预加载前生效，查询不得抢跑', () async {
    // 本地两个账本，prefs 保存的是第二个（非首个）；恢复解析刻意放慢，
    // 模拟冷启动磁盘 IO 与数据库校验的真实耗时。
    const firstId = 'ledger-first';
    const savedId = 'ledger-saved';
    db.Ledger ledger(String id, String name) => db.Ledger(
      id: id,
      name: name,
      currency: 'CNY',
      role: 'owner',
      memberCount: 1,
      monthStartDay: 1,
      storageMode: 'local',
      aaEnabled: false,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    when(() => repo.getAllLedgers()).thenAnswer(
      (_) async => <db.Ledger>[
        ledger(firstId, '首个账本'),
        ledger(savedId, '保存账本'),
      ],
    );
    // 恢复解析的存在性校验延迟 300ms：只有显式等待恢复收敛，首屏才能拿到它。
    when(() => repo.getLedgerById(savedId)).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return ledger(savedId, '保存账本');
    });
    SharedPreferences.setMockInitialValues({'current_ledger_id': savedId});

    final container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<db.Ledger?>.value(null),
        ),
        // prefs 延迟 100ms 到位：恢复解析整体落在首屏预加载时间窗之后。
        sharedPreferencesProvider.overrideWith((ref) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return SharedPreferences.getInstance();
        }),
      ],
    );
    addTearDown(container.dispose);

    await readProviderFutureFromContainer(
      container,
      appSplashInitProvider.future,
    );
    // 让 fire-and-forget 微任务（统计/周期生成）跑完。
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    expect(container.read(appInitStateProvider), AppInitState.ready);
    expect(
      container.read(currentLedgerIdProvider),
      savedId,
      reason: '首屏预加载启动前，保存的账本必须已恢复生效',
    );
    verify(
      () =>
          repo.getRecentTransactionsWithCategory(ledgerId: savedId, limit: 20),
    ).called(1);
    verify(
      () => repo.monthlyTotals(
        ledgerId: savedId,
        month: any(named: 'month'),
      ),
    ).called(1);
    verifyNever(
      () => repo.getRecentTransactionsWithCategory(ledgerId: '', limit: 20),
    );
  });
}
