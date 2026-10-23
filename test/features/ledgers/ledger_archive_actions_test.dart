import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

/// 归档状态机的逻辑层用例：统计保留、不可作为当前账本、恢复与删除。
///
/// 角色化的云端删除/退出与失败重试已由
/// test/data/repositories/local_ledger_archive_test.dart 在 application 层覆盖。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late LedgerActions actions;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => container.read(authSessionProvider)?.userId,
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(authSessionProvider)?.userId,
      ),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    actions = container.read(ledgerActionsProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedLedger(String name) => repo.createLedger(
    name: name,
    storageMode: 'local',
    localSelfId: 'device-self',
  );

  /// 归档账本，返回其 id；归档前先写入一笔 12.5 支出用于核对统计。
  Future<String> seedArchivedLedger(String name) async {
    final id = await seedLedger(name);
    await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '12.5',
      happenedAt: DateTime(2026, 9, 6),
    );
    await actions.setArchived(id, true);
    return id;
  }

  test('归档账本保留真实统计，且不再出现在使用中列表', () async {
    final active = await seedLedger('日常生活');
    final archived = await seedArchivedLedger('去年旅行');

    final archivedItems = await actions.getAllWithStats(archived: true);
    expect(archivedItems, hasLength(1));
    expect(archivedItems.single.id, archived);
    expect(
      archivedItems.single.transactionCount,
      1,
      reason: '归档账本的统计仍按其真实记录计算',
    );
    expect(archivedItems.single.expenseTotal, 12.5);

    final activeItems = await actions.getAllWithStats();
    expect(activeItems.map((item) => item.id), [
      active,
    ], reason: '归档账本不得留在使用中列表');
    expect(activeItems.single.transactionCount, 0);
  });

  test('恢复使用：清除归档时间，当前账本保持不变', () async {
    final active = await seedLedger('日常生活');
    final archived = await seedArchivedLedger('去年旅行');
    container.read(currentLedgerIdProvider.notifier).set(active);

    await actions.setArchived(archived, false);

    expect((await repo.getLedgerById(archived))!.archivedAt, isNull);
    expect(container.read(currentLedgerIdProvider), active);
    expect((await actions.getAll()).map((item) => item.id), contains(archived));
  });

  test('归档非当前账本：写入归档时间且不切换当前账本', () async {
    final active = await seedLedger('日常生活');
    final other = await seedLedger('临时账本');
    container.read(currentLedgerIdProvider.notifier).set(active);

    await actions.setArchived(other, true);

    expect((await repo.getLedgerById(other))!.archivedAt, isNotNull);
    expect(
      container.read(currentLedgerIdProvider),
      active,
      reason: '归档其他账本不得改动当前选择',
    );
    expect((await actions.getAll()).map((item) => item.id), [active]);
  });

  test('删除归档个人账本：账本与其记录一并清除，当前账本不变', () async {
    final active = await seedLedger('日常生活');
    final archived = await seedArchivedLedger('去年旅行');
    container.read(currentLedgerIdProvider.notifier).set(active);

    final txId = (await repo.getTransactionsByLedger(archived)).single.id;

    await actions.delete(archived);

    expect(await repo.getLedgerById(archived), isNull);
    expect(await repo.getTransactionsByLedger(archived), isEmpty);
    expect(await repo.getTransactionById(txId), isNull);
    expect((await db.select(db.ledgers).get()).map((row) => row.id), [active]);
    expect(container.read(currentLedgerIdProvider), active);
  });
}
