import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import '../../helpers/test_isolation.dart';

class _PausedRepository extends LocalRepository {
  _PausedRepository(super.db);
  final written = Completer<void>(), resume = Completer<void>();
  @override
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) async {
    await super.updateLedger(
      id: id,
      name: name,
      currency: currency,
      monthStartDay: monthStartDay,
      aaEnabled: aaEnabled,
      recordChanges: recordChanges,
    );
    written.complete();
    await resume.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);
  for (final changeAccount in [false, true]) {
    test('账本导入在预览后身份变化时拒绝写入 changeAccount=$changeAccount', () async {
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      final repo = LocalRepository(db);
      final id = await repo.createLedger(name: '原账本', storageMode: 'local');
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          repositoryProvider.overrideWithValue(repo),
          currentAccountIdProvider.overrideWithValue(null),
          authIdentityGenerationProvider.overrideWithValue(0),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final actions = container.read(importActionsProvider);
      final fixed = await actions.target(id);
      container.updateOverrides([
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWithValue(changeAccount ? 'B' : null),
        authIdentityGenerationProvider.overrideWithValue(1),
      ]);
      await expectLater(
        actions.import(
          target: fixed,
          data: const ImportData(ledgerName: '不应保存'),
        ),
        throwsStateError,
      );
      expect((await repo.getLedgerById(id))!.name, '原账本');
    });
  }
  test('账本导入写入中身份变化时整笔事务回滚', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = _PausedRepository(db);
    final id = await repo.createLedger(name: '原账本', storageMode: 'local');
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final actions = container.read(importActionsProvider),
        fixed = await container.read(importActionsProvider).target(id);
    final importing = actions.import(
      target: fixed,
      data: const ImportData(ledgerName: '暂存名称'),
    );
    final rejected = expectLater(importing, throwsStateError);
    await repo.written.future;
    container.updateOverrides([
      databaseProvider.overrideWithValue(db),
      repositoryProvider.overrideWithValue(repo),
      currentAccountIdProvider.overrideWithValue('B'),
      authIdentityGenerationProvider.overrideWithValue(1),
    ]);
    repo.resume.complete();
    await rejected;
    expect((await repo.getLedgerById(id))!.name, '原账本');
  });
  test('账本绑定变化或归档使旧导入目标失效', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(db);
    final id = await repo.createLedger(name: '原账本', storageMode: 'local');
    await repo.updateLedgerSyncId(id: id, syncId: 'binding-1');
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final actions = container.read(importActionsProvider),
        fixed = await container.read(importActionsProvider).target(id);
    await repo.updateLedgerSyncId(id: id, syncId: 'binding-2');
    await expectLater(actions.validateTarget(fixed), throwsStateError);
    final latest = await actions.target(id);
    await repo.setLedgerArchived(id, true);
    await expectLater(actions.validateTarget(latest), throwsStateError);
  });

  for (final restricted in [false, true]) {
    test('导入拒绝预览后被删除的分类 restricted=$restricted', () async {
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      final repo = LocalRepository(db);
      final id = await repo.createLedger(name: '目标账本', storageMode: 'local');
      final categoryId = await repo.createCategory(
        name: '预览分类',
        kind: 'expense',
      );
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          repositoryProvider.overrideWithValue(repo),
          currentAccountIdProvider.overrideWithValue(null),
          authIdentityGenerationProvider.overrideWithValue(0),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final actions = container.read(importActionsProvider);
      final target = await actions.target(id);
      final data = ImportData(
        transactions: [
          ImportTransaction(
            type: 'expense',
            amount: Decimal.parse('12.34'),
            happenedAt: DateTime(2026, 10, 22),
            categoryId: categoryId,
          ),
        ],
      );
      await repo.deleteCategory(categoryId);
      final result = await actions.import(
        target: target,
        data: data,
        allowedCategoryIds: restricted ? {categoryId} : null,
        allowCategoryCreation: !restricted,
      );
      expect(result.inserted, 0);
      expect(result.failed, 1);
      expect(await repo.getTransactionsByLedger(id), isEmpty);
    });
  }
}
