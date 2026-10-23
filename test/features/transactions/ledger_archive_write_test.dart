import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late String ledgerId;
  late String transactionId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(name: '测试账本', storageMode: 'local');
    transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    await db
        .update(db.ledgers)
        .write(LedgersCompanion(archivedAt: d.Value(DateTime.utc(2026, 9, 6))));
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('归档后拒绝手动新增、修改与删除，原记录保持不变', () async {
    final actions = container.read(transactionActionsProvider);
    await expectLater(
      actions.add(
        ledgerId: ledgerId,
        type: 'expense',
        amount: '9',
        happenedAt: DateTime.utc(2026, 9, 7),
      ),
      throwsStateError,
    );
    await expectLater(
      actions.edit(
        id: transactionId,
        type: 'expense',
        amount: '10',
        historySummary: '编辑',
      ),
      throwsStateError,
    );
    await expectLater(actions.delete(transactionId), throwsStateError);
    final records = await repo.getTransactionsByLedger(ledgerId);
    expect(records, hasLength(1));
    expect(records.single.amount, '8');
  });

  test('归档后手动导入提交被拒绝', () async {
    await expectLater(
      container
          .read(importActionsProvider)
          .import(
            target: (
              bookId: ledgerId,
              accountId: container.read(currentAccountIdProvider),
              generation: container.read(authIdentityGenerationProvider),
              syncId: null,
            ),
            data: ImportData(categories: [], transactions: []),
          ),
      throwsStateError,
    );
  });

  test('归档保留后台仓储写入通道', () async {
    await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '9',
      happenedAt: DateTime.utc(2026, 9, 7),
    );
    expect(await repo.getTransactionsByLedger(ledgerId), hasLength(2));
  });

  test('已打开的周期单在归档后不能启停或删除', () async {
    final id = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      frequency: 'daily',
      interval: 1,
      startDate: DateTime.utc(2026, 9, 6),
    );
    final actions = container.read(transactionActionsProvider);
    await expectLater(
      actions.updateRecurring(
        id: id,
        ledgerId: ledgerId,
        type: 'expense',
        amount: '8',
        frequency: 'daily',
        interval: 1,
        startDate: DateTime.utc(2026, 9, 6),
        enabled: false,
      ),
      throwsStateError,
    );
    await expectLater(actions.deleteRecurring(id), throwsStateError);
    expect(await repo.getRecurringTransactionsByLedger(ledgerId), hasLength(1));
  });
}
