import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';

/// 独立创建只按身份和所属目录处理，名称、图标及旧模板身份均不参与复用。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalCategoryRepository repo;
  const parentA = '00000000-0000-4000-8000-000000000101';
  const parentB = '00000000-0000-4000-8000-000000000102';
  const childA = '00000000-0000-4000-8000-000000000201';
  const childB = '00000000-0000-4000-8000-000000000202';

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalCategoryRepository(db);
  });
  tearDown(() => db.close());

  test('创建与移动只提交父关系即可派生兼容层级，始终限制一层子分类', () async {
    final parent = await repo.createCategory(name: '餐饮', kind: 'expense');
    final child = await repo.createCategory(
      name: '午餐',
      kind: 'expense',
      parentId: parent,
    );
    expect((await repo.getCategoryById(child))!.level, 2);
    await repo.updateCategory(child, parentId: '');
    expect((await repo.getCategoryById(child))!.level, 1);
    await repo.updateCategory(child, parentId: parent);
    expect((await repo.getCategoryById(child))!.level, 2);
    await expectLater(
      repo.createCategory(
        name: '无效',
        kind: 'expense',
        level: 1,
        parentId: parent,
      ),
      throwsStateError,
    );
    await expectLater(
      repo.createCategory(name: '第三层', kind: 'expense', parentId: child),
      throwsA(isA<CategoryParentUnavailableException>()),
    );
    await expectLater(
      repo.updateCategory(parent, parentId: child),
      throwsStateError,
    );
    expect(await repo.getAllCategories(), hasLength(2));
  });

  test('同名同图标父子独立保存，冻结身份重试不增加记录或覆盖编辑', () async {
    const batch = [
      CategoryCreateDraft(id: parentA, name: '餐饮', icon: 'utensils'),
      CategoryCreateDraft(id: parentB, name: '餐饮', icon: 'utensils'),
      CategoryCreateDraft(id: childA, name: '午餐', parentId: parentA),
      CategoryCreateDraft(id: childB, name: '午餐', parentId: parentA),
    ];
    expect(await repo.createCategoryBatch(items: batch), 4);
    await repo.updateCategory(childA, name: '我的午餐');
    expect(await repo.createCategoryBatch(items: batch), 0);
    expect(await repo.getAllCategories(), hasLength(4));
    expect((await repo.getCategoryById(childA))!.name, '我的午餐');
    expect((await repo.getCategoryById(childB))!.parentId, parentA);
  });

  test('明确目标父身份只在指定同名父下添加，父移动无效时整批回滚', () async {
    await repo.createCategoryBatch(
      items: const [
        CategoryCreateDraft(id: parentA, name: '餐饮'),
        CategoryCreateDraft(id: parentB, name: '餐饮'),
      ],
    );
    await repo.createCategoryBatch(
      items: const [
        CategoryCreateDraft(id: childA, name: '午餐', parentId: parentB),
      ],
    );
    expect(await repo.getSubCategories(parentA), isEmpty);
    expect((await repo.getSubCategories(parentB)).single.id, childA);
    await expectLater(
      repo.createCategoryBatch(
        items: const [
          CategoryCreateDraft(id: childB, name: '点心', parentId: childA),
        ],
      ),
      throwsA(isA<CategoryParentUnavailableException>()),
    );
    expect(await repo.getCategoryById(childB), isNull);
  });

  test('共享目录读取不复制进个人目录，显式共享写入被所有者守卫阻断', () async {
    final now = DateTime.utc(2026, 10, 29);
    final personal = LocalCategoryRepository(
      db,
      accountIdGetter: () => 'viewer',
    );
    await personal.createCategoryBatch(
      items: const [
        CategoryCreateDraft(id: parentA, name: '餐饮', icon: 'coffee'),
      ],
      recordChanges: false,
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'shared',
            name: '共享',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('viewer'),
            ownerAccountId: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: 'shared',
            categoryId: parentA,
            name: '餐饮',
            kind: 'expense',
            level: const d.Value(1),
            icon: const d.Value('utensils'),
            updatedAt: now,
          ),
        );
    for (var i = 0; i < 3; i++) {
      expect(
        (await personal.getAllCategories(ledgerId: 'shared')).single.icon,
        'utensils',
      );
      expect((await personal.getAllCategories()).single.icon, 'coffee');
    }
    await expectLater(
      personal.createCategoryBatch(
        items: const [CategoryCreateDraft(id: parentB, name: '餐饮')],
        ledgerId: 'shared',
        recordChanges: false,
      ),
      throwsStateError,
    );
    expect(await personal.getAllCategories(), hasLength(1));
  });
}
