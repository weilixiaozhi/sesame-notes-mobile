import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late LocalRepository repo;
  late List<CategoryTemplateGroup> groups;
  setUp(() async {
    resetGlobalTestState();
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(database);
    groups = buildCategoryTemplateGroups(
      await AppLocalizations.delegate.load(const Locale('zh')),
    );
  });
  tearDown(() => database.close());

  test('同一计划重试不重复，第二次主动添加新建同名独立父子', () async {
    final first = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
    );
    expect(await executeTemplateInsertPlan(repo: repo, plan: first), 2);
    expect(await executeTemplateInsertPlan(repo: repo, plan: first), 0);
    final second = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
    );
    expect(await executeTemplateInsertPlan(repo: repo, plan: second), 2);
    final rows = await repo.categoryStore.getAllCategories();
    expect(rows, hasLength(4));
    expect(rows.where((row) => row.name == '餐饮'), hasLength(2));
    expect(
      rows.map((row) => row.id),
      isNot(contains(defaultCategoryId(level: 1, key: 'dining'))),
    );
  });

  test('添加到明确父分类不认领同名父或生成新的父', () async {
    final first = await repo.createCategory(
      name: '餐饮',
      kind: 'expense',
      icon: 'utensils',
    );
    final target = await repo.createCategory(
      name: '餐饮',
      kind: 'expense',
      icon: 'coffee',
    );
    final plan = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
      targetParentId: target,
    );
    expect(await executeTemplateInsertPlan(repo: repo, plan: plan), 1);
    final rows = await repo.categoryStore.getAllCategories();
    expect(rows.where((row) => row.level == 1), hasLength(2));
    expect(rows.singleWhere((row) => row.level == 2).parentId, target);
    expect(rows.singleWhere((row) => row.id == first).icon, 'utensils');
  });

  test('会话在写入后失效时原子回滚分类与写入', () async {
    var checks = 0;
    final plan = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
    );
    await expectLater(
      executeTemplateInsertPlan(
        repo: repo,
        plan: plan,
        assertCurrent: () {
          if (++checks == 2) throw StateError('scope changed');
        },
      ),
      throwsStateError,
    );
    expect(await repo.categoryStore.getAllCategories(), isEmpty);
  });

  test('目标已移动成二级时整批拒绝，不创建漂浮子项', () async {
    final parent = await repo.createCategory(name: '生活', kind: 'expense');
    final target = await repo.createSubCategory(
      parentId: parent,
      name: '餐饮',
      kind: 'expense',
    );
    final plan = buildInsertPlan(
      groups: groups,
      selectedKeys: {'dining_lunch'},
      targetParentId: target,
    );
    await expectLater(
      executeTemplateInsertPlan(repo: repo, plan: plan),
      throwsA(isA<CategoryParentUnavailableException>()),
    );
    expect(await repo.categoryStore.getAllCategories(), hasLength(2));
  });
}
