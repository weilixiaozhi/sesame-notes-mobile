// categoryPickerTreeProvider 测试
//
// 验证内容：
//   1. 主表路径：首发即为合并后的分类树（一级排序 + 二级分组）
//   2. 零手动 invalidate：写 categories 表后 provider 自动重发新树
//   3. 共享账本 Editor 路径：主表内容整体丢弃，替换为
//      SharedLedgerCategories 的分类树（id 即 Owner 分类 UUID）

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

/// 插库分类 id 自增序列（主键为 UUID 字符串，需保证同文件内唯一）。
var _catSeq = 0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // 默认值已改为哨兵 ''（表示「未选中」），此处显式指定 'led-1' 以匹配插入的账本 id。
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => 'led-1'),
      ],
    );
    // currentLedgerIdProvider 初值为 'led-1'，插入对应账本供 picker 上下文解析
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'led-1',
            name: '默认账本',
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 向主表插入一级支出分类，返回其 id（UUID 字符串）
  Future<String> addTopCategory(String name, {int sortOrder = 0}) async {
    // insertReturning 拿回整行，取其文本主键（insert 本身只返回 rowid int）。
    final cat = await db
        .into(db.categories)
        .insertReturning(
          CategoriesCompanion.insert(
            id: 'cat-${_catSeq++}',
            name: name,
            kind: 'expense',
            level: 1,
            sortOrder: d.Value(sortOrder),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    return cat.id;
  }

  /// 轮询等待条件成立（Drift 表变更通知经 isolate 异步到达，
  /// 不能用 pumpEventQueue 假定时序），超时即失败。
  Future<void> waitFor(bool Function() cond, String reason) async {
    for (var i = 0; i < 200; i++) {
      if (cond()) return;
      await Future.delayed(const Duration(milliseconds: 10));
    }
    fail('等待超时: $reason');
  }

  test('主表路径：首发即为合并后的分类树', () async {
    final foodId = await addTopCategory('餐饮', sortOrder: 1);
    await addTopCategory('交通', sortOrder: 0);
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat-child-1',
            name: '早餐',
            kind: 'expense',
            level: 2,
            parentId: d.Value(foodId),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );

    final tree = await readProviderFutureFromContainer(
      container,
      categoryPickerTreeProvider('expense').future,
    );

    expect(tree.topLevel.map((c) => c.name), ['交通', '餐饮']);
    expect(tree.children[foodId]!.single.name, '早餐');
  });

  test('写 categories 表后自动重发新树（零手动 invalidate）', () async {
    await addTopCategory('餐饮');
    final first = await readProviderFutureFromContainer(
      container,
      categoryPickerTreeProvider('expense').future,
    );
    expect(first.topLevel.single.name, '餐饮');

    final emissions = <String>[];
    final sub = container.listen(categoryPickerTreeProvider('expense'), (
      prev,
      next,
    ) {
      final v = next.value;
      if (v != null) {
        emissions.add(v.topLevel.map((c) => c.name).join(','));
      }
    }, fireImmediately: true);

    await addTopCategory('交通');
    await waitFor(
      () => emissions.isNotEmpty && emissions.last.contains('交通'),
      'categories 表写入后 provider 应自动重发包含新分类的树',
    );
    sub.close();
  });

  test('共享账本 Editor 路径：整树替换为共享分类', () async {
    // 主表数据在 Editor 视角应被整体丢弃
    await addTopCategory('本地分类');
    // 当前账本设为共享账本 Editor（memberCount>1 且 role=editor）
    await (db.update(db.ledgers)..where((t) => t.id.equals('led-1'))).write(
      const LedgersCompanion(
        memberCount: d.Value(2),
        role: d.Value('editor'),
        storageMode: d.Value('cloud'),
      ),
    );
    // Owner 侧共享分类：一父一子（父子链用 parentId 直连）
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: 'led-1',
            categoryId: 'c1',
            name: '共享餐饮',
            kind: 'expense',
            updatedAt: DateTime(2026, 8, 8),
          ),
        );
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: 'led-1',
            categoryId: 'c2',
            name: '共享早餐',
            kind: 'expense',
            level: const d.Value(2),
            parentId: const d.Value('c1'),
            updatedAt: DateTime(2026, 8, 8),
          ),
        );

    final tree = await readProviderFutureFromContainer(
      container,
      categoryPickerTreeProvider('expense').future,
    );

    // 树节点 id 直接用 Owner 分类 UUID（categoryId），不再有 synthetic id。
    expect(tree.topLevel.map((c) => c.id), ['c1']);
    expect(tree.topLevel.single.name, '共享餐饮');
    expect(tree.children['c1']!.single.id, 'c2');
    expect(tree.children['c1']!.single.name, '共享早餐');
    // 主表分类不出现（Editor 视角整体替换）
    expect(tree.topLevel.any((c) => c.name == '本地分类'), false);
  });
}
