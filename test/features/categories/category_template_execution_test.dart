import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';

/// 模板条目的确定性 id（与 seed / 模板「已添加」判定同源）。
String _sid(int level, String key) =>
    SeedService.deterministicCategorySyncId(level: level, key: key);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.SesameDatabase database;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
    database = db.SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  /// 读取分类表现有内容（既是写入计划的入参，也是落库断言的数据源）。
  Future<List<CategoryDisplay>> existingCategories() async =>
      (await repo.categoryStore.getAllCategories())
          .map((row) => row.toDisplay())
          .toList(growable: false);

  /// 构造「已添加」判定索引。
  ExistingCategoryIndex indexOf(List<CategoryDisplay> rows) =>
      ExistingCategoryIndex([
        for (final row in rows)
          (
            id: row.id,
            name: row.name,
            level: row.level,
            parentId: row.parentId,
          ),
      ]);

  /// 直接落一条指定主键的分类，模拟 seed 或用户手动创建的既有分类。
  Future<void> insertCategory({
    required String id,
    required String name,
    int level = 1,
    String? parentId,
  }) async {
    await database
        .into(database.categories)
        .insert(
          db.CategoriesCompanion.insert(
            id: id,
            name: name,
            kind: 'expense',
            level: level,
            parentId: drift.Value(parentId),
            icon: const drift.Value('utensils'),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }

  /// 扁平化 hierarchical 模板条目（生成写入计划用）。
  List<CategoryTemplateItem> flatten(List<CategoryTemplateGroup> groups) => [
    for (final group in groups) ...[group.parent, ...group.children],
  ];

  group('flat 模板写入计划', () {
    test('二次确认后按计划写入，写入条目随即变为已添加', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final items = buildFlatTemplateItems(l10n, ExistingCategoryIndex([]));
      final plan = buildInsertPlan(allItems: items, selectedKeys: {'dining'});

      expect(plan.total, 1, reason: '二次确认弹窗按写入计划计数');
      expect(
        await repo.categoryStore.getAllCategories(),
        isEmpty,
        reason: '确认前零写入',
      );

      final inserted = await executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        existingCategories: const [],
      );

      expect(inserted.created, 1);
      final rows = await existingCategories();
      expect(rows, hasLength(1));
      expect(rows.single.name, '餐饮');
      expect(rows.single.kind, 'expense');
      expect(rows.single.icon, 'utensils', reason: '模板条目图标透传落库');
      expect(rows.single.level, 1);
      expect(rows.single.sortOrder, 1, reason: '空表 topSort=0，新父分类追加到 1');

      // 写入后条目经 stream 变「已添加」：本次勾选自动清空且不再可选
      final refreshed = buildFlatTemplateItems(l10n, indexOf(rows));
      expect(
        refreshed.firstWhere((e) => e.key == 'dining').alreadyAdded,
        isTrue,
      );
      expect(refreshed.where((e) => e.alreadyAdded), hasLength(1));
    });
  });

  group('hierarchical 模板写入计划', () {
    test('父已在表（确定性 id 命中）时子类挂已有父 id，不新建父', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final parentId = _sid(1, 'dining');
      await insertCategory(id: parentId, name: '餐饮');
      final rows = await existingCategories();

      final groups = buildHierarchicalTemplateGroups(l10n, indexOf(rows));
      expect(
        computeHierarchicalSelectAll(groups),
        isNot(contains('dining')),
        reason: '父已在表时父分类不可重复选择',
      );
      final plan = buildInsertPlan(
        allItems: flatten(groups),
        selectedKeys: {'dining_breakfast'},
      );
      expect(plan.total, 1, reason: '父已在表，写入计划只有子分类');

      final inserted = await executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        existingCategories: rows,
      );

      expect(inserted.created, 1);
      final after = await existingCategories();
      expect(
        after.where((row) => row.level == 1),
        hasLength(1),
        reason: '不新建父分类',
      );
      final breakfast = after.singleWhere((row) => row.level == 2);
      expect(breakfast.name, '早餐');
      expect(breakfast.parentId, parentId, reason: '挂到已在表的父 id');
      expect(breakfast.sortOrder, 0, reason: '父下无既有子分类，从 0 起');
    });

    test('同名自定义父保持原身份，模板整分支跳过', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await insertCategory(id: 'random-v4-sync-id', name: '餐饮');
      final rows = await existingCategories();
      final storedBefore = await database.select(database.categories).get();
      final groups = buildHierarchicalTemplateGroups(l10n, indexOf(rows));
      final group = groups.firstWhere((g) => g.parent.key == 'dining');
      expect(group.parent.alreadyAdded, isFalse);
      expect(
        group.parent.blockedReason,
        CategoryTemplateBlockReason.duplicateName,
      );
      expect(group.children.every((child) => !child.canAdd), isTrue);
      final plan = buildInsertPlan(
        allItems: flatten(groups),
        selectedKeys: {'dining_breakfast'},
      );
      expect(plan.total, 0);
      final result = await executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        existingCategories: rows,
      );
      expect(result.created, 0);
      expect(result.restored, 0);
      expect(await database.select(database.categories).get(), storedBefore);
    });

    test('父未添加时计划自动补父，写入先建父再建子', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final groups = buildHierarchicalTemplateGroups(
        l10n,
        ExistingCategoryIndex([]),
      );
      final plan = buildInsertPlan(
        allItems: flatten(groups),
        selectedKeys: {'dining_breakfast'},
      );

      expect(plan.total, 2, reason: '父未在表时写入计划自动补父，确认数为父+子');
      expect(
        await repo.categoryStore.getAllCategories(),
        isEmpty,
        reason: '确认前零写入',
      );

      final inserted = await executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        existingCategories: const [],
      );

      expect(inserted.created, 2);
      final after = await existingCategories();
      final parent = after.singleWhere((row) => row.level == 1);
      final child = after.singleWhere((row) => row.level == 2);
      expect(parent.name, '餐饮');
      expect(child.name, '早餐');
      expect(child.parentId, parent.id, reason: '父先落库拿到 id，子类再挂到该 id');
      expect(child.sortOrder, 0);
    });
  });
  test('中文模板创建后切英文应用沿用固定ID，保留改名和旧随机分类', () async {
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final first = buildInsertPlan(
      allItems: buildFlatTemplateItems(zh, ExistingCategoryIndex([])),
      selectedKeys: {'dining'},
    );
    await executeTemplateInsertPlan(
      repo: repo,
      plan: first,
      existingCategories: [],
    );
    expect((await existingCategories()).single.id, _sid(1, 'dining'));
    await repo.updateCategory(_sid(1, 'dining'), name: '我的餐饮', icon: 'star');
    await insertCategory(id: 'old-random', name: 'Dining');
    final before = await existingCategories();
    final storedBefore = await database.select(database.categories).get();
    final english = buildFlatTemplateItems(en, indexOf(before));
    expect(
      english.firstWhere((item) => item.key == 'dining').alreadyAdded,
      isTrue,
    );
    final second = buildInsertPlan(allItems: english, selectedKeys: {'dining'});
    expect(second.total, 0);
    final result = await executeTemplateInsertPlan(
      repo: repo,
      plan: second,
      existingCategories: before,
    );
    expect(result.created, 0);
    expect(await database.select(database.categories).get(), storedBefore);
  });

  test('计划产生后父层级改变，仓储拒绝新子项且不写随机副本', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final parent = _sid(1, 'dining');
    await insertCategory(id: parent, name: '餐饮');
    final before = await existingCategories();
    final plan = buildInsertPlan(
      allItems: flatten(buildHierarchicalTemplateGroups(l10n, indexOf(before))),
      selectedKeys: {'dining_breakfast'},
    );
    await insertCategory(id: 'other', name: '其他');
    await (database.update(
      database.categories,
    )..where((row) => row.id.equals(parent))).write(
      const db.CategoriesCompanion(
        level: drift.Value(2),
        parentId: drift.Value('other'),
      ),
    );
    final result = await executeTemplateInsertPlan(
      repo: repo,
      plan: plan,
      existingCategories: before,
    );
    expect(result.created, 0);
    expect(result.skipped, 1);
    expect(
      await repo.categoryStore.getCategoryById(_sid(2, 'dining_breakfast')),
      isNull,
    );
    expect(
      (await existingCategories()).map((row) => row.id),
      containsAll([parent, 'other']),
    );
  });

  test('本地墓碑先确认再恢复原ID，保留原名称图标排序', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final id = _sid(1, 'dining');
    await insertCategory(id: id, name: '保留原名称');
    await (database.update(
      database.categories,
    )..where((row) => row.id.equals(id))).write(
      db.CategoriesCompanion(
        icon: const drift.Value('star'),
        sortOrder: const drift.Value(23),
        deletedAt: drift.Value(DateTime.utc(2026, 1, 2)),
      ),
    );
    final plan = buildInsertPlan(
      allItems: buildFlatTemplateItems(l10n, ExistingCategoryIndex([])),
      selectedKeys: {'dining'},
    );
    final first = await executeTemplateInsertPlan(
      repo: repo,
      plan: plan,
      existingCategories: [],
    );
    expect(first.created, 0);
    expect(first.restored, 0);
    expect(first.localRestoreRequired.map((item) => item.syncId), [id]);
    expect(await repo.categoryStore.getCategoryById(id), isNull);
    final confirmed = await executeTemplateInsertPlan(
      repo: repo,
      plan: plan,
      existingCategories: [],
      restoreLocalDeletedIds: {id},
    );
    expect(confirmed.created, 0);
    expect(confirmed.restored, 1);
    expect(confirmed.localRestoreRequired, isEmpty);
    final after = (await existingCategories()).single;
    expect(after.id, id);
    expect(after.name, '保留原名称');
    expect(after.icon, 'star');
    expect(after.sortOrder, 23);
  });

  test('执行中会话失效在同一事务回滚父子创建', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final plan = buildInsertPlan(
      allItems: flatten(
        buildHierarchicalTemplateGroups(l10n, ExistingCategoryIndex([])),
      ),
      selectedKeys: {'dining_breakfast'},
    );
    var checks = 0;
    await expectLater(
      executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        existingCategories: [],
        assertCurrent: () {
          if (++checks == 3) {
            throw StateError('CATEGORY_TEMPLATE_SCOPE_CHANGED');
          }
        },
      ),
      throwsStateError,
    );
    expect(await existingCategories(), isEmpty);
    expect(await database.select(database.syncChanges).get(), isEmpty);
  });
}
