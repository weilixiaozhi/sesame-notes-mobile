import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late ProviderContainer container;
  var account = 'account-a';

  setUp(() {
    resetGlobalTestState();
    account = 'account-a';
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(database);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        categoryDataAccessProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWith((ref) => account),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await database.close();
  });

  /// 只构造账号级队列，不执行任何联网同步。
  Future<void> queued(
    String id, {
    String owner = 'account-a',
    bool base = false,
  }) => database
      .into(database.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: 'category',
          entityId: id,
          accountId: d.Value(owner),
          action: 'upsert',
          payload: jsonEncode({'name': '模板', if (base) 'base_token': 'cloud'}),
          updatedAt: DateTime.utc(2026, 1, 1),
          mutationId: 'mutation-$id$owner',
        ),
      );

  /// 模拟页面的活跃 watch，Riverpod 3 会暂停没有监听者的 StreamProvider。
  Future<Set<String>> readPending() async {
    final subscription = container.listen(
      categoryTemplatePendingIdsProvider,
      (_, _) {},
    );
    try {
      return await container.read(categoryTemplatePendingIdsProvider.future);
    } finally {
      subscription.close();
    }
  }

  test('墓碑与缺行恢复意图持久可读，普通活跃新建和其他账号不会显示候选', () async {
    final tombstone = defaultCategoryId(level: 1, key: 'dining');
    final missing = defaultCategoryId(level: 1, key: 'transport');
    final active = defaultCategoryId(level: 1, key: 'shopping');
    final other = defaultCategoryId(level: 1, key: 'medical');
    final withBase = defaultCategoryId(level: 1, key: 'sports');
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: tombstone,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('account-a'),
            updatedAt: DateTime.utc(2026, 1, 1),
            deletedAt: d.Value(DateTime.utc(2026, 1, 2)),
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: active,
            name: '购物',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('account-a'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await queued(tombstone);
    await queued(missing);
    await queued(active);
    await queued(other, owner: 'account-b');
    await queued(withBase, base: true);
    await queued('custom-random-id');
    expect(await readPending(), {tombstone, missing});
    container.invalidate(categoryTemplatePendingIdsProvider);
    expect(await readPending(), {tombstone, missing});
  });

  test('同UUID另一账号的活跃行或墓碑不能改变本人模板恢复候选', () async {
    try {
      final active = defaultCategoryId(level: 1, key: 'dining');
      final missing = defaultCategoryId(level: 1, key: 'transport');
      final deleted = defaultCategoryId(level: 1, key: 'shopping');
      for (final item in [
        (active, 'account-a', false),
        (active, 'account-b', true),
        (missing, 'account-b', false),
        (deleted, 'account-a', true),
        (deleted, 'account-b', false),
      ]) {
        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: item.$1,
                name: '账号自己的模板分类',
                kind: 'expense',
                level: 1,
                scopeAccountId: d.Value(item.$2),
                updatedAt: DateTime.utc(2026, 1, 1),
                deletedAt: d.Value(item.$3 ? DateTime.utc(2026, 1, 2) : null),
              ),
            );
      }
      for (final id in [active, missing, deleted]) {
        await queued(id);
      }
      expect(await readPending(), {missing, deleted});
    } catch (error, stack) {
      debugPrint('本人模板恢复候选被其他账号同UUID污染：$error\n$stack');
      rethrow;
    }
  });

  test('服务端OPEN候选包含活跃官方分类，已解决和其他账号候选不混入', () async {
    final open = defaultCategoryId(level: 1, key: 'dining');
    final resolved = defaultCategoryId(level: 1, key: 'shopping');
    final other = defaultCategoryId(level: 1, key: 'medical');
    for (final entry in [
      (open, 'account-a', 'OPEN'),
      (resolved, 'account-a', 'RESOLVED_LOCAL'),
      (other, 'account-b', 'OPEN'),
    ]) {
      await database
          .into(database.syncConflicts)
          .insert(
            SyncConflictsCompanion.insert(
              id: entry.$1,
              accountId: d.Value(entry.$2),
              entityType: 'category',
              entityId: entry.$1,
              localPayload: '{}',
              remotePayload: '{}',
              baseRevision: 0,
              remoteRevision: 0,
              localMutationId: 'mutation',
              status: d.Value(entry.$3),
            ),
          );
    }
    expect(await readPending(), {open});
    account = 'account-b';
    container.invalidate(currentAccountIdProvider);
    expect(await readPending(), {other});
  });

  test('明确恢复确认期间换号阻止旧计划执行，同号退出也失效', () {
    final captured = captureTemplateInsertSession(container.read);
    captured.assertCurrent();
    account = 'account-b';
    container.invalidate(currentAccountIdProvider);
    expect(captured.assertCurrent, throwsStateError);
    account = 'account-a';
    container.invalidate(currentAccountIdProvider);
    final recaptured = captureTemplateInsertSession(container.read);
    recaptured.assertCurrent();
    container.read(authSessionProvider.notifier).signOut();
    expect(recaptured.assertCurrent, throwsStateError);
  });
}
