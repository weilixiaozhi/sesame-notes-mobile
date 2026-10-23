import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/providers/book_selection_actions.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';

import '../../helpers/test_isolation.dart';
import '../../helpers/bound_ledger_seed.dart';

/// 前台选择只接受已发布内容，后台任务不成为手动下载入口。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late String localId;

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db, accountIdGetter: () => 'account');
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWithValue('account'),
      ],
    );
    localId = await repo.createLedger(name: '本机账本', storageMode: 'local');
    await seedBoundLedger(
      db,
      accountId: 'account',
      id: 'unpublished',
      name: '未确认的云端元数据',
    );
    await container
        .read(cloudLedgerDownloadStoreProvider)
        .markPending('account', 'unpublished');
    container.read(currentLedgerIdProvider.notifier).set(localId);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await logger.clear();
  });

  test('首次内容未发布时，显式选择拒绝且保持当前账本和页面', () async {
    container.read(currentModeProvider.notifier).set(AppMode.days);
    container.read(bottomTabIndexProvider.notifier).set(3);
    await expectLater(
      selectBook(
        container.read,
        mode: AppMode.bookkeeping,
        bookId: 'unpublished',
      ),
      throwsStateError,
    );
    expect(container.read(currentLedgerIdProvider), localId);
    expect(container.read(currentModeProvider), AppMode.days);
    expect(container.read(bottomTabIndexProvider), 3);
    expect(
      await container.read(ledgerActionsProvider).getById('unpublished'),
      isNull,
    );
    expect(
      await container.read(cloudLedgerDownloadStoreProvider).pending('account'),
      {'unpublished'},
    );
  });

  test('后台重下载中的完整空账本仍可离线选择', () async {
    final complete = await repo.createLedger(
      name: '完整空账本',
      storageMode: 'cloud',
    );
    await container
        .read(cloudLedgerDownloadStoreProvider)
        .markPending('account', complete, hasLocalSnapshot: true);
    await selectBook(
      container.read,
      mode: AppMode.bookkeeping,
      bookId: complete,
    );
    expect(container.read(currentLedgerIdProvider), complete);
    expect(
      (await container.read(ledgerActionsProvider).getById(complete))?.id,
      complete,
    );
    expect(
      (await readProviderFutureFromContainer(
        container,
        currentLedgerProvider.future,
      ))?.id,
      complete,
    );
    expect(await repo.getTransactionsByLedger(complete), isEmpty);
  });

  test('归档当前本后不会回退到未发布账本', () async {
    await container.read(ledgerActionsProvider).setArchived(localId, true);
    expect(container.read(currentLedgerIdProvider), isEmpty);
    expect(await container.read(ledgerActionsProvider).getAll(), isEmpty);
    expect(await repo.getLedgerById('unpublished'), isNotNull);
  });

  test('恢复未发布本不会使它成为当前本', () async {
    await repo.setLedgerArchived('unpublished', true);
    container.read(currentLedgerIdProvider.notifier).set('');
    await expectLater(
      container.read(ledgerActionsProvider).setArchived('unpublished', false),
      throwsStateError,
    );
    expect(container.read(currentLedgerIdProvider), isEmpty);
  });

  for (final hasFallback in [false, true]) {
    test('启动恢复跳过未发布的保存选择 fallback=$hasFallback', () async {
      if (!hasFallback) await repo.purgeLedger(localId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_ledger_id', 'unpublished');
      container.read(currentLedgerIdProvider.notifier).set('');
      final subscription = container.listen(
        currentLedgerPersistProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);
      await container.read(currentLedgerPersistProvider.future);
      expect(
        container.read(currentLedgerIdProvider),
        hasFallback ? localId : '',
      );
      expect(
        (await readProviderFutureFromContainer(
          container,
          currentLedgerProvider.future,
        ))?.id,
        hasFallback ? localId : null,
      );
    });
  }

  test('首次下载只有后台任务时，不能生成可选择的空账本', () async {
    await container
        .read(cloudLedgerDownloadStoreProvider)
        .markPending('account', 'only-task');
    expect(await repo.getLedgerById('only-task'), isNull);
    await expectLater(
      selectPublishedLedger(container.read, 'only-task'),
      throwsStateError,
    );
    expect(container.read(currentLedgerIdProvider), localId);
  });
}
