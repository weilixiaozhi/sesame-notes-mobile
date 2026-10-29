import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';

import '../helpers/test_isolation.dart';

const _a = '10000000-0000-4000-8000-000000000001';
const _b = '10000000-0000-4000-8000-000000000002';
const _parent = '20000000-0000-4000-8000-000000000001';
const _child = '20000000-0000-4000-8000-000000000002';
const _other = '20000000-0000-4000-8000-000000000003';

/// 验证种子身份稳定及显式复制的原子性，避免同账号出现随机替代分类。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  /// 夹具始终明确目录和父身份，毫秒经过真实 SQLite 编解码。
  Future<void> insert(
    String id,
    String name,
    String? scope, {
    String? parent,
    bool registered = false,
  }) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          name: name,
          kind: 'expense',
          level: parent == null ? 1 : 2,
          parentId: d.Value(parent),
          scopeAccountId: d.Value(scope),
          cloudRegistered: d.Value(registered),
          updatedAt: DateTime.utc(2026, 10, 11, 1, 2, 3, 980),
        ),
      );

  /// 读取指定目录的全部行，包括墓碑，作为初始化与复制结果的证据。
  Future<List<Category>> rows(String? scope) => (db.select(
    db.categories,
  )..where((c) => categoryScopePredicate(c, scope))).get();

  test('每账号正式种子采用固定UUID；重复初始化和另一账号编辑都不能新增餐饮身份', () async {
    await SeedService.ensureAccountSeed(db, _a);
    final dining = defaultCategoryId(level: 1, key: 'dining');
    await (db.update(db.categories)
          ..where((c) => c.id.equals(dining) & categoryScopePredicate(c, _a)))
        .write(const CategoriesCompanion(name: d.Value('A自定义餐饮')));
    await SeedService.ensureAccountSeed(db, _b);
    final before = await rows(_b);
    await SeedService.ensureAccountSeed(db, _b);
    final after = await rows(_b);
    expect(after, before);
    expect(after.length, 61);
    expect(after.where((c) => c.name == '餐饮').map((c) => c.id), [dining]);
    expect(
      after.map((c) => c.id).toSet(),
      (await rows(_a)).map((c) => c.id).toSet(),
    );
    expect(after.every((c) => !c.cloudRegistered), isTrue);
    expect((await rows(_a)).singleWhere((c) => c.id == dining).name, 'A自定义餐饮');
  });

  test('部分目录或墓碑说明已经初始化，固定模板不能补种或复活原实体', () async {
    await insert(_parent, '用户自有分类', _a);
    await (db.update(db.categories)
          ..where((c) => categoryScopePredicate(c, _a)))
        .write(CategoriesCompanion(deletedAt: d.Value(DateTime.utc(2026))));
    final before = await rows(_a);
    await SeedService.ensureAccountSeed(db, _a);
    expect(await rows(_a), before);
    expect((await rows(_a)).single.id, _parent);
  });

  test('明确本地引用复制祖先且保留源目录；重复复制复用同UUID并清除新域云登记身份', () async {
    await insert(_parent, '餐饮', null, registered: true);
    await insert(_child, '早餐', null, parent: _parent, registered: true);
    await insert(_other, '他人私有', _a);
    final original = await rows(null);
    final copied = await cloneCategoryReferences(
      source: db,
      target: db,
      categoryIds: [_child],
      sourceAccountId: null,
      targetAccountId: _b,
    );
    expect(copied, {_parent: _parent, _child: _child});
    expect(await rows(null), original);
    final target = await rows(_b);
    expect(target.map((c) => c.id).toSet(), {_parent, _child});
    expect(target.every((c) => !c.cloudRegistered), isTrue);
    expect(target.every((c) => c.updatedAt.millisecond == 980), isTrue);
    await cloneCategoryReferences(
      source: db,
      target: db,
      categoryIds: [_child],
      sourceAccountId: null,
      targetAccountId: _b,
    );
    expect(await rows(_b), target);
    expect((await rows(_a)).single.id, _other);
  });

  test('同级同名不同UUID可独立复制，保留目标原分类及来源引用', () async {
    await insert(_parent, '餐饮', _a);
    await insert(_child, '早餐', _a, parent: _parent);
    await insert(_parent, '餐饮', _b);
    await insert(_other, ' 早餐 ', _b, parent: _parent);
    final before = await rows(_b);
    final mapping = await cloneCategoryReferences(
      source: db,
      target: db,
      categoryIds: [_child],
      sourceAccountId: _a,
      targetAccountId: _b,
    );
    expect(mapping[_child], _child);
    final after = await rows(_b);
    expect(after, containsAll(before));
    expect(after.where((c) => c.id == _child).single.parentId, _parent);
    expect(after.where((c) => c.parentId == _parent), hasLength(2));
    expect(
      (await rows(_a)).singleWhere((c) => c.id == _child).parentId,
      _parent,
    );
  });

  test('来源同UUID不同内容拒绝覆盖；另一账号同UUID不能作为缺失本地来源', () async {
    await insert(_parent, 'A餐饮', _a);
    await insert(_parent, 'B餐饮', _b);
    final before = await db.select(db.categories).get();
    await expectLater(
      cloneCategoryReferences(
        source: db,
        target: db,
        categoryIds: [_parent],
        sourceAccountId: _a,
        targetAccountId: _b,
      ),
      throwsA(isA<CategoryCloneConflict>()),
    );
    await expectLater(
      cloneCategoryReferences(
        source: db,
        target: db,
        categoryIds: [_parent],
        sourceAccountId: null,
        targetAccountId: _b,
      ),
      throwsStateError,
    );
    expect(await db.select(db.categories).get(), before);
  });
}
