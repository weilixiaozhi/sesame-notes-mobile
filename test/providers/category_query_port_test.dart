import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_row_tree.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

import '../helpers/test_isolation.dart';

/// 只模拟分类读取端口，未声明写入、事务或其他业务域能力。
class _Queries extends Mock implements CategoryQueryRepository {}

final _account = NotifierProvider<SimpleStateNotifier<String?>, String?>(
  () => SimpleStateNotifier((ref) => 'account-a'),
);
final _generation = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 1),
);

/// 构造相同分类身份在不同会话中的快照，方便发现迟到正文串入。
CategorySnapshot _category(String name, {String account = 'account-a'}) =>
    CategorySnapshot(
      id: 'category',
      name: name,
      kind: 'expense',
      level: 1,
      sortOrder: 0,
      scopeAccountId: account,
      updatedAt: DateTime.utc(2026, 10, 16),
    );

/// 小接口测试隔离手工刷新信号，读取不应触达组合仓储或数据库。
ProviderContainer _queryContainer(CategoryQueryRepository queries) =>
    ProviderContainer(
      overrides: [
        categoryQueriesProvider.overrideWithValue(queries),
        repositoryProvider.overrideWith((ref) {
          throw StateError('分类纯查询不应读取组合仓储');
        }),
        databaseProvider.overrideWith((ref) {
          throw StateError('分类纯查询不应直接打开数据库');
        }),
        accountingDataChangeSignalProvider.overrideWith(
          (ref) => const Stream.empty(),
        ),
        currentAccountIdProvider.overrideWith((ref) => ref.watch(_account)),
        authIdentityGenerationProvider.overrideWith(
          (ref) => ref.watch(_generation),
        ),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => 'ledger'),
      ],
    );

/// 切号和同账号重新登录都必须令已经发出的读取失效。
void _changeIdentity(ProviderContainer container, {required bool relogin}) {
  if (!relogin) container.read(_account.notifier).set('account-b');
  container.read(_generation.notifier).set(2);
}

/// 保留用例名称与堆栈，失败信息直接指出对应的读取边界。
void _queryTest(String name, Future<void> Function() verify) {
  test(name, () async {
    try {
      await verify();
    } catch (error, stack) {
      debugPrint('$name：$error\n$stack');
      rethrow;
    }
  });
}

/// 共享镜像与本人同 UUID 分类并存，两个根及子分类按排序字段保存。
Future<void> _seedPickerCatalog(SesameDatabase database) async {
  try {
    final now = DateTime.utc(2026, 10, 16);
    await database
        .into(database.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'shared',
            name: '共享账本',
            storageMode: const drift.Value('cloud'),
            scopeAccountId: const drift.Value('account-a'),
            ownerAccountId: const drift.Value('owner'),
            role: const drift.Value('editor'),
            updatedAt: now,
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'category',
            name: '本人同 UUID 分类',
            kind: 'expense',
            level: 1,
            scopeAccountId: const drift.Value('account-a'),
            updatedAt: now,
          ),
        );
    for (final row in [
      (id: 'category', name: '共享餐饮', parent: null, order: 20),
      (id: 'first', name: '共享交通', parent: null, order: 10),
      (id: 'child-late', name: '晚餐', parent: 'category', order: 30),
      (id: 'child-first', name: '早餐', parent: 'category', order: 5),
    ]) {
      await database
          .into(database.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: 'shared',
              categoryId: row.id,
              name: row.name,
              kind: 'expense',
              level: drift.Value(row.parent == null ? 1 : 2),
              parentId: drift.Value(row.parent),
              sortOrder: drift.Value(row.order),
              updatedAt: now,
            ),
          );
    }
  } catch (error, stack) {
    debugPrint('建立分类选择树镜像夹具失败：$error\n$stack');
    rethrow;
  }
}

/// 纯查询可以独立替换，异步结果及监听仍受完整会话身份约束。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);
  tearDown(() async {
    try {
      await logger.clear();
    } catch (error, stack) {
      debugPrint('释放分类查询测试日志失败：$error\n$stack');
      rethrow;
    }
  });

  for (final relogin in [false, true]) {
    _queryTest('同号重登=$relogin：迟到的分类列表与单项不能覆盖新会话', () async {
      final queries = _Queries();
      final firstList = Completer<List<CategorySnapshot>>();
      final secondList = Completer<List<CategorySnapshot>>();
      final firstRow = Completer<CategorySnapshot?>();
      final secondRow = Completer<CategorySnapshot?>();
      var listCalls = 0;
      var rowCalls = 0;
      when(() => queries.getAllCategories()).thenAnswer(
        (_) => listCalls++ == 0 ? firstList.future : secondList.future,
      );
      when(
        () => queries.getCategoryById('category'),
      ).thenAnswer((_) => rowCalls++ == 0 ? firstRow.future : secondRow.future);
      final container = _queryContainer(queries);
      final seen = <String>[];
      final listSub = container.listen(categoriesProvider, (_, next) {
        if (next.hasValue) seen.add(next.value!.single.name);
      });
      final rowSub = container.listen(categoryByIdProvider('category'), (
        _,
        next,
      ) {
        if (next.hasValue && next.value != null) seen.add(next.value!.name);
      });
      try {
        expect((listCalls, rowCalls), (1, 1));
        _changeIdentity(container, relogin: relogin);
        await container.pump();
        expect((listCalls, rowCalls), (2, 2));
        final fresh = _category(
          '新会话正文',
          account: relogin ? 'account-a' : 'account-b',
        );
        secondList.complete([fresh]);
        secondRow.complete(fresh);
        expect(
          (await container.read(categoriesProvider.future)).single.name,
          '新会话正文',
        );
        expect(
          (await container.read(categoryByIdProvider('category').future))?.name,
          '新会话正文',
        );
        firstList.complete([_category('旧会话迟到正文')]);
        firstRow.complete(_category('旧会话迟到正文'));
        await container.pump();
        expect(container.read(categoriesProvider).value!.single.name, '新会话正文');
        expect(
          container.read(categoryByIdProvider('category')).value?.name,
          '新会话正文',
        );
        expect(seen, isNot(contains('旧会话迟到正文')));
      } finally {
        if (!firstList.isCompleted) firstList.complete([]);
        if (!secondList.isCompleted) secondList.complete([]);
        if (!firstRow.isCompleted) firstRow.complete(null);
        if (!secondRow.isCompleted) secondRow.complete(null);
        listSub.close();
        rowSub.close();
        container.dispose();
      }
    });

    _queryTest('同号重登=$relogin：计数和选择树取消旧流并订阅新会话', () async {
      final queries = _Queries();
      var countCancels = 0;
      var pickerCancels = 0;
      final oldCounts =
          StreamController<
            List<({CategorySnapshot category, int transactionCount})>
          >(onCancel: () => countCancels++);
      final newCounts =
          StreamController<
            List<({CategorySnapshot category, int transactionCount})>
          >();
      final oldPicker = StreamController<CategoryRowTree>(
        onCancel: () => pickerCancels++,
      );
      final newPicker = StreamController<CategoryRowTree>();
      var countCalls = 0;
      var pickerCalls = 0;
      when(() => queries.watchCategoriesWithCount()).thenAnswer(
        (_) => countCalls++ == 0 ? oldCounts.stream : newCounts.stream,
      );
      when(
        () => queries.watchCategoryPickerTree(
          ledgerId: 'ledger',
          kind: 'expense',
        ),
      ).thenAnswer(
        (_) => pickerCalls++ == 0 ? oldPicker.stream : newPicker.stream,
      );
      final container = _queryContainer(queries);
      final countsSub = container.listen(
        categoriesWithCountProvider,
        (_, _) {},
      );
      final pickerSub = container.listen(
        categoryPickerTreeProvider('expense'),
        (_, _) {},
      );
      try {
        final old = _category('旧会话餐饮');
        oldCounts.add([(category: old, transactionCount: 1)]);
        oldPicker.add(CategoryRowTree(topLevel: [old], children: {}));
        await container.read(categoriesWithCountProvider.future);
        await container.read(categoryPickerTreeProvider('expense').future);
        _changeIdentity(container, relogin: relogin);
        await container.pump();
        expect((countCalls, pickerCalls), (2, 2));
        expect((countCancels, pickerCancels), (1, 1));
        final fresh = _category(
          '新会话餐饮',
          account: relogin ? 'account-a' : 'account-b',
        );
        newCounts.add([(category: fresh, transactionCount: 7)]);
        newPicker.add(CategoryRowTree(topLevel: [fresh], children: {}));
        final counted = await container.read(
          categoriesWithCountProvider.future,
        );
        final tree = await container.read(
          categoryPickerTreeProvider('expense').future,
        );
        expect(
          (counted.single.category.name, counted.single.transactionCount),
          ('新会话餐饮', 7),
        );
        expect(tree.topLevel.single.name, '新会话餐饮');
        oldCounts.add([(category: old, transactionCount: 999)]);
        oldPicker.add(CategoryRowTree(topLevel: [old], children: {}));
        await container.pump();
        expect(
          container
              .read(categoriesWithCountProvider)
              .value!
              .single
              .transactionCount,
          7,
        );
        expect(
          container
              .read(categoryPickerTreeProvider('expense'))
              .value!
              .topLevel
              .single
              .name,
          '新会话餐饮',
        );
      } finally {
        countsSub.close();
        pickerSub.close();
        container.dispose();
        await Future.wait([
          oldCounts.close(),
          newCounts.close(),
          oldPicker.close(),
          newPicker.close(),
        ]);
      }
    });

    _queryTest('同号重登=$relogin：Actions拒绝等待期间已失效的只读结果', () async {
      final queries = _Queries();
      final response = Completer<CategorySnapshot?>();
      when(
        () => queries.getCategoryById('category'),
      ).thenAnswer((_) => response.future);
      final container = _queryContainer(queries);
      try {
        final actions = container.read(categoryActionsProvider);
        final rejected = expectLater(
          actions.getById('category'),
          throwsA(isA<CategorySessionChangedException>()),
        );
        _changeIdentity(container, relogin: relogin);
        response.complete(_category('旧页面结果'));
        await rejected;
      } finally {
        if (!response.isCompleted) response.complete(null);
        container.dispose();
      }
    });
  }

  _queryTest('默认查询端口读取同一事务，回滚同步意图后仍能正常提交', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        currentAccountIdProvider.overrideWith((ref) => 'account-a'),
      ],
    );
    try {
      final repository = container.read(repositoryProvider);
      final queries = container.read(categoryQueriesProvider);
      late String rolledBackId;
      await expectLater(
        repository.runInTransaction(() async {
          rolledBackId = await repository.createCategory(
            name: '回滚餐饮',
            kind: 'expense',
          );
          expect((await queries.getCategoryById(rolledBackId))?.name, '回滚餐饮');
          throw StateError('模拟事务末尾失败');
        }),
        throwsStateError,
      );
      expect(await queries.getCategoryById(rolledBackId), isNull);
      expect(await database.select(database.syncChanges).get(), isEmpty);
      final committedId = await repository.runInTransaction(
        () => repository.createCategory(name: '提交餐饮', kind: 'expense'),
      );
      expect((await queries.getAllCategories()).single.id, committedId);
      final queued = await database.select(database.syncChanges).get();
      expect(queued, hasLength(1));
      expect(
        (queued.single.entityId, queued.single.accountId),
        (committedId, 'account-a'),
      );
    } finally {
      container.dispose();
      await database.close();
    }
  });

  _queryTest('缺失或已删除账本的选择树保持为空', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      final CategoryQueryRepository queries = LocalCategoryRepository(database);
      final missing = await queries
          .watchCategoryPickerTree(ledgerId: 'missing', kind: 'expense')
          .first;
      expect(missing.topLevel, isEmpty);
      expect(missing.children, isEmpty);
      await database
          .into(database.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'deleted',
              name: '已删除账本',
              storageMode: const drift.Value('local'),
              updatedAt: DateTime.utc(2026, 10, 16),
              deletedAt: drift.Value(DateTime.utc(2026, 10, 16)),
            ),
          );
      final deleted = await queries
          .watchCategoryPickerTree(ledgerId: 'deleted', kind: 'expense')
          .first;
      expect(deleted.topLevel, isEmpty);
      expect(deleted.children, isEmpty);
    } finally {
      await database.close();
    }
  });

  _queryTest('真实选择树保留共享镜像、父子归属及排序值，并响应镜像和账本归属变化', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    StreamIterator<CategoryRowTree>? iterator;
    try {
      await _seedPickerCatalog(database);
      final CategoryQueryRepository queries = LocalCategoryRepository(
        database,
        accountIdGetter: () => 'account-a',
      );
      iterator = StreamIterator(
        queries.watchCategoryPickerTree(ledgerId: 'shared', kind: 'expense'),
      );
      expect(
        await iterator.moveNext().timeout(const Duration(seconds: 2)),
        isTrue,
      );
      expect(
        iterator.current.topLevel.map((row) => (row.name, row.sortOrder)),
        unorderedEquals([('共享交通', 10), ('共享餐饮', 20)]),
      );
      expect(
        iterator.current.children['category']!.map(
          (row) => (row.name, row.sortOrder, row.parentId),
        ),
        unorderedEquals([('早餐', 5, 'category'), ('晚餐', 30, 'category')]),
      );
      await (database.update(database.sharedLedgerCategories)..where(
            (row) =>
                row.ledgerId.equals('shared') &
                row.categoryId.equals('category'),
          ))
          .write(
            const SharedLedgerCategoriesCompanion(
              name: drift.Value('共享Owner改名'),
            ),
          );
      expect(
        await iterator.moveNext().timeout(const Duration(seconds: 2)),
        isTrue,
      );
      expect(
        iterator.current.topLevel
            .singleWhere((row) => row.id == 'category')
            .name,
        '共享Owner改名',
      );
      await (database.update(
        database.ledgers,
      )..where((row) => row.id.equals('shared'))).write(
        const LedgersCompanion(ownerAccountId: drift.Value('account-a')),
      );
      expect(
        await iterator.moveNext().timeout(const Duration(seconds: 2)),
        isTrue,
      );
      expect(iterator.current.topLevel.single.name, '本人同 UUID 分类');
      expect(iterator.current.children, isEmpty);
    } finally {
      await iterator?.cancel();
      await database.close();
    }
  });

  _queryTest('真实选择树旧流切号后报错，新账号不能订阅原账号共享账本', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    StreamIterator<CategoryRowTree>? iterator;
    var account = 'account-a';
    try {
      await _seedPickerCatalog(database);
      final CategoryQueryRepository queries = LocalCategoryRepository(
        database,
        accountIdGetter: () => account,
      );
      iterator = StreamIterator(
        queries.watchCategoryPickerTree(ledgerId: 'shared', kind: 'expense'),
      );
      expect(
        await iterator.moveNext().timeout(const Duration(seconds: 2)),
        isTrue,
      );
      account = 'account-b';
      final rejected = expectLater(
        iterator.moveNext().timeout(const Duration(seconds: 2)),
        throwsStateError,
      );
      await (database.update(database.sharedLedgerCategories)..where(
            (row) =>
                row.ledgerId.equals('shared') &
                row.categoryId.equals('category'),
          ))
          .write(
            const SharedLedgerCategoriesCompanion(name: drift.Value('A共享新正文')),
          );
      await rejected;
      await expectLater(
        queries
            .watchCategoryPickerTree(ledgerId: 'shared', kind: 'expense')
            .first,
        throwsStateError,
      );
      account = 'account-a';
      final restored = await queries
          .watchCategoryPickerTree(ledgerId: 'shared', kind: 'expense')
          .first;
      expect(
        restored.topLevel.singleWhere((row) => row.id == 'category').name,
        'A共享新正文',
      );
    } finally {
      await iterator?.cancel();
      await database.close();
    }
  });
}
