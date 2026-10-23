import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

import '../helpers/test_isolation.dart';

final _account = NotifierProvider<SimpleStateNotifier<String?>, String?>(
  () => SimpleStateNotifier((ref) => 'account-a'),
);
final _generation = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 1),
);

/// 固定上下文读取与当前首页并存，两者共用原仓储聚合与权限规则。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repository;
  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState(
      initialPrefs: {
        visibleCurrenciesKeyFor('a'): 'CNY,USD,JPY',
        visibleCurrenciesKeyFor('b'): 'USD,EUR',
      },
    );
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = LocalRepository(
      db,
      accountIdGetter: () => container.read(_account),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repository),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => 'a'),
        currentAccountIdProvider.overrideWith((ref) => ref.watch(_account)),
        authIdentityGenerationProvider.overrideWith(
          (ref) => ref.watch(_generation),
        ),
        unpublishedCloudLedgersProvider.overrideWith((ref) async => <String>{}),
      ],
    );
    final now = DateTime(2026, 10, 9);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'a',
            name: 'A 人民币账本',
            currency: const d.Value('CNY'),
            aaEnabled: const d.Value(true),
            updatedAt: now,
          ),
        );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'b',
            name: 'B 美元账本',
            currency: const d.Value('USD'),
            aaEnabled: const d.Value(false),
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            ownerAccountId: const d.Value('shared-owner'),
            memberCount: const d.Value(2),
            role: const d.Value('editor'),
            updatedAt: now,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'local-food',
            name: 'A 餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: 'b',
            categoryId: 'shared-food',
            name: 'B 共享餐饮',
            kind: 'expense',
            updatedAt: now,
          ),
        );
    await repository.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-10-09',
      rates: {'USD': '7.1'},
      source: 'test',
      fetchedAt: now,
    );
    await repository.upsertAutoRates(
      base: 'USD',
      rateDate: '2026-10-09',
      rates: {'CNY': '0.14'},
      source: 'test',
      fetchedAt: now,
    );
    await repository.setOverride(base: 'CNY', quote: 'USD', rate: '7.2');
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('首页从A切B后，固定A的本名、AA、分类、展示币种与汇率仍属于A', () async {
    const query = (ledgerId: 'a', type: 'expense');
    final fixedTree = categoryPickerTreeForLedgerProvider(query);
    final subscriptions = [
      container.listen(ledgerDisplayByIdProvider('a'), (_, _) {}),
      container.listen(fixedTree, (_, _) {}),
      container.listen(visibleCurrenciesForLedgerProvider('a'), (_, _) {}),
      container.listen(effectiveRatesForBaseProvider('CNY'), (_, _) {}),
    ];
    addTearDown(() {
      for (final subscription in subscriptions) {
        subscription.close();
      }
    });
    await readProviderFutureFromContainer(container, fixedTree.future);
    await readProviderFutureFromContainer(
      container,
      visibleCurrenciesForLedgerProvider('a').future,
    );
    await readProviderFutureFromContainer(
      container,
      effectiveRatesForBaseProvider('CNY').future,
    );
    container.read(currentLedgerIdProvider.notifier).set('b');
    await readProviderFutureFromContainer(
      container,
      currentLedgerProvider.future,
    );
    final currentTree = await readProviderFutureFromContainer(
      container,
      categoryPickerTreeProvider('expense').future,
    );
    final currentRates = await readProviderFutureFromContainer(
      container,
      effectiveRatesForLedgerProvider.future,
    );
    expect(container.read(currentLedgerCurrencyProvider), 'USD');
    expect(currentTree.topLevel.single.name, 'B 共享餐饮');
    expect(currentRates['CNY']!.rate, '0.14');
    final fixed = container.read(ledgerDisplayByIdProvider('a')).value!;
    expect(
      (fixed.id, fixed.name, fixed.currency, fixed.aaEnabled),
      ('a', 'A 人民币账本', 'CNY', true),
    );
    expect(container.read(fixedTree).value!.topLevel.single.name, 'A 餐饮');
    expect(container.read(visibleCurrenciesForLedgerProvider('a')).value, {
      'CNY',
      'USD',
      'JPY',
    });
    expect(
      container.read(effectiveRatesForBaseProvider('CNY')).value!['USD']!.rate,
      '7.2',
    );
    expect(
      await readProviderFutureFromContainer(
        container,
        visibleCurrenciesForLedgerProvider('b').future,
      ),
      {'USD', 'EUR'},
    );
  });

  test('固定base继续响应原汇率刷新信号，手工覆盖优先规则不变', () async {
    final provider = effectiveRatesForBaseProvider('CNY');
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    expect(
      (await readProviderFutureFromContainer(
        container,
        provider.future,
      ))['USD']!.rate,
      '7.2',
    );
    container.read(currentLedgerIdProvider.notifier).set('b');
    await repository.setOverride(base: 'CNY', quote: 'USD', rate: '7.35');
    container.read(rateRefreshTickProvider.notifier).tick();
    expect(
      (await readProviderFutureFromContainer(
        container,
        provider.future,
      ))['USD']!.rate,
      '7.35',
    );
  });

  test('可见币种写回A后固定读取立即刷新，切到B不借用A的集合', () async {
    await readProviderFutureFromContainer(
      container,
      currentLedgerProvider.future,
    );
    await readProviderFutureFromContainer(
      container,
      visibleCurrenciesInitProvider.future,
    );
    final visible = visibleCurrenciesForLedgerProvider('a');
    final sub = container.listen(visible, (_, _) {});
    addTearDown(sub.close);
    expect(
      (await readProviderFutureFromContainer(
        container,
        visible.future,
      )).contains('JPY'),
      isTrue,
    );
    await toggleCurrencyVisibility(container.read, 'JPY');
    expect(await readProviderFutureFromContainer(container, visible.future), {
      'CNY',
      'USD',
    });
    container.read(currentLedgerIdProvider.notifier).set('b');
    expect(
      await readProviderFutureFromContainer(
        container,
        visibleCurrenciesForLedgerProvider('b').future,
      ),
      {'USD', 'EUR'},
    );
    expect(await readProviderFutureFromContainer(container, visible.future), {
      'CNY',
      'USD',
    });
  });

  test('A归档后保留其状态，但分类与展示币种读取拒绝继续作为可编辑本', () async {
    await (db.update(db.ledgers)..where((row) => row.id.equals('a'))).write(
      LedgersCompanion(archivedAt: d.Value(DateTime(2026, 10, 9))),
    );
    await readProviderFutureFromContainer(
      container,
      ledgerByIdProvider('a').future,
    );
    expect(
      container.read(ledgerDisplayByIdProvider('a')).value!.isArchived,
      isTrue,
    );
    await expectLater(
      readProviderFutureFromContainer(
        container,
        categoryPickerTreeForLedgerProvider((
          ledgerId: 'a',
          type: 'expense',
        )).future,
      ),
      throwsStateError,
    );
    await expectLater(
      readProviderFutureFromContainer(
        container,
        visibleCurrenciesForLedgerProvider('a').future,
      ),
      throwsStateError,
    );
  });

  test('账号切换后固定云本不可见，不能读取原账号分类与币种偏好', () async {
    final provider = ledgerDisplayByIdProvider('b');
    final sub = container.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await readProviderFutureFromContainer(
      container,
      ledgerByIdProvider('b').future,
    );
    expect(container.read(provider).value?.id, 'b');
    container.read(_account.notifier).set('account-b');
    container.read(_generation.notifier).set(2);
    expect(
      await readProviderFutureFromContainer(
        container,
        ledgerByIdProvider('b').future,
      ),
      isNull,
    );
    expect(container.read(provider).value, isNull);
    await expectLater(
      readProviderFutureFromContainer(
        container,
        categoryPickerTreeForLedgerProvider((
          ledgerId: 'b',
          type: 'expense',
        )).future,
      ),
      throwsStateError,
    );
    await expectLater(
      readProviderFutureFromContainer(
        container,
        visibleCurrenciesForLedgerProvider('b').future,
      ),
      throwsStateError,
    );
  });
}
