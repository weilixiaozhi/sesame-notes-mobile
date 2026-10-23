import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/services/seed_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // seed 过程中 logger 会把日志持久化到 SharedPreferences，测试环境需 mock 掉。
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  const locales = [Locale('zh'), Locale('zh', 'TW'), Locale('en')];
  // seed 解析失败会 `return key`（snake_case），正常分类名不会是全小写下划线串。
  final fallbackPattern = RegExp(r'^[a-z][a-z_]*$');

  /// 期望的确定性 id 集合：遍历 hybridCategoryTemplate 单一有序清单生成，
  /// `children == null` 为独立一级（仅 sid(1)），否则为父子组（sid(1) + 各子 sid(2)）。
  /// 合计 20 一级 + 41 二级 = 61 条确定性 id。
  Set<String> expectedSyncIds() {
    String sid(int level, String key) =>
        SeedService.deterministicCategorySyncId(level: level, key: key);
    return {
      for (final entry in SeedService.hybridCategoryTemplate) ...[
        sid(1, entry.key),
        if (entry.children != null)
          for (final childKey in entry.children!) sid(2, childKey),
      ],
    };
  }

  for (final locale in locales) {
    final tag = locale.toLanguageTag();
    test('hybrid seed 结构/挂接/确定性 id 正确、无重复和 fallback [$tag]', () async {
      final l10n = await AppLocalizations.delegate.load(locale);
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      try {
        await SeedService.createHybridCategories(db, l10n);
        final cats = await db.select(db.categories).get();

        // ① 条目数：一级 20、二级 41、总计 61
        final level1 = cats.where((c) => c.level == 1).toList();
        final level2 = cats.where((c) => c.level == 2).toList();
        expect(level1, hasLength(20), reason: '一级分类应为 20 个（9 独立 + 11 父）');
        expect(level2, hasLength(41), reason: '二级分类应为 41 个');
        expect(cats, hasLength(61));
        expect(
          cats.every((c) => c.updatedAt.millisecondsSinceEpoch == 0),
          isTrue,
          reason: '新安装系统默认分类使用epoch，不能伪装成用户较新编辑',
        );

        // ② id 确定性：实际集合与期望集合完全一致（无缺失、无多余）。
        // 分类 id 使用 deterministicCategorySyncId 生成的确定性 UUID。
        final actualSyncIds = {for (final c in cats) c.id};
        expect(actualSyncIds, expectedSyncIds());

        // ③ 层级挂接：按确定性 id 反推 key，子的父必须是 hybridCategoryTemplate 中
        //    该父子组声明的父（children != null 的条目）
        String sidOf(int level, String key) =>
            SeedService.deterministicCategorySyncId(level: level, key: key);
        final byId = {for (final c in cats) c.id: c};
        for (final entry in SeedService.hybridCategoryTemplate) {
          final children = entry.children;
          if (children == null) continue; // 独立一级无子分类，跳过挂接校验
          final parentSid = sidOf(1, entry.key);
          for (final childKey in children) {
            final child = cats.firstWhere((c) => c.id == sidOf(2, childKey));
            expect(child.level, 2);
            expect(child.parentId, isNotNull, reason: '子分类 $childKey 必须挂父');
            final parent = byId[child.parentId];
            expect(parent, isNotNull, reason: '子分类 $childKey 的父必须存在');
            expect(
              parent!.id,
              parentSid,
              reason: '子分类 $childKey 应挂在父 ${entry.key} 下',
            );
          }
        }
        // 独立一级分类不得有 parentId
        for (final c in cats) {
          if (c.level == 1) expect(c.parentId, isNull);
        }

        // ④ 同父级下的名称与收支类型组合唯一，跨父级允许同名。
        final seen = <String>{};
        final dups = <String>[];
        for (final c in cats) {
          if (!seen.add('${c.parentId}|${c.name}|${c.kind}')) {
            dups.add('${c.name}|${c.kind} (L${c.level}, parent=${c.parentId})');
          }
        }
        expect(dups, isEmpty, reason: '同父级下重复分类: $dups');

        // ⑤ 无 fallback（段数错位会让名字 fallback 成 snake_case key）
        final fallbacks = cats
            .where((c) => fallbackPattern.hasMatch(c.name))
            .map((c) => c.name)
            .toList();
        expect(fallbacks, isEmpty, reason: 'fallback 成 key（段数错位）: $fallbacks');
      } finally {
        await db.close();
      }
    });
  }

  test('再次seed不覆盖用户改名、图标和墓碑，真实用户编辑仍推进同步时间', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await SeedService.createHybridCategories(
      db,
      l10n,
      scopeAccountId: 'test-account',
    );
    final id = SeedService.deterministicCategorySyncId(level: 1, key: 'dining');
    final deletedId = SeedService.deterministicCategorySyncId(
      level: 2,
      key: 'dining_breakfast',
    );
    final webTime = DateTime.utc(2024, 1, 2);
    await (db.update(db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        name: const d.Value('Web修改过的餐饮'),
        icon: const d.Value('star'),
        updatedAt: d.Value(webTime),
      ),
    );
    await (db.update(
      db.categories,
    )..where((c) => c.id.equals(deletedId))).write(
      CategoriesCompanion(
        updatedAt: d.Value(webTime),
        deletedAt: d.Value(webTime),
      ),
    );
    final before = await db.select(db.categories).get();
    await SeedService.createHybridCategories(
      db,
      l10n,
      scopeAccountId: 'test-account',
    );
    expect(await db.select(db.categories).get(), before);
    final repo = LocalRepository(
      db,
      accountIdGetter: () => 'test-account',
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => 'test-account',
      ),
    );
    await repo.updateCategory(id, name: '手机用户实际改名');
    final change = (await db.select(db.syncChanges).get()).single;
    final payload = jsonDecode(change.payload) as Map;
    expect(payload['name'], '手机用户实际改名');
    expect(change.updatedAt.toUtc().isAfter(webTime), isTrue);
    expect(
      DateTime.parse(payload['updated_at'] as String).isAfter(webTime),
      isTrue,
    );
    expect(
      (await (db.select(
        db.categories,
      )..where((c) => c.id.equals(deletedId))).getSingle()).deletedAt?.toUtc(),
      webTime,
    );
  });

  test('housing 组翻译顺序（zh：水电煤→物业费→房租→房贷→宽带）', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    try {
      await SeedService.createHybridCategories(db, l10n);
      final cats = await db.select(db.categories).get();

      final housingSid = SeedService.deterministicCategorySyncId(
        level: 1,
        key: 'housing',
      );
      final housing = cats.firstWhere((c) => c.id == housingSid);
      // 子类按 sortOrder 升序即为 seed 写入顺序
      final children = cats.where((c) => c.parentId == housing.id).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      expect(children.map((c) => c.name).toList(), [
        '水电煤',
        '物业费',
        '房租',
        '房贷',
        '宽带',
      ]);
    } finally {
      await db.close();
    }
  });

  test('hybrid 与 flat/hierarchical 模板的子集契约（翻译下标对齐前提）', () {
    // 模板库"已添加"判定依赖：同一 key 同 level 的确定性 id 跨模板相同，
    // 该契约由 category_template_logic.templateItemSyncId 与 seed 共用
    // deterministicCategorySyncId 保证（纯函数侧另有测试覆盖）。
    // 本测试锁定 hybrid 模板与 flat/hierarchical 常量的子集关系：
    // hybrid 独立一级 ⊂ flat 一级（翻译复用 getTranslatedCategoryName 的前提）
    for (final entry in SeedService.hybridCategoryTemplate) {
      if (entry.children != null) continue; // 父子组不走 flat 翻译
      expect(
        SeedService.flatExpenseCategoryKeys.contains(entry.key),
        isTrue,
        reason: 'hybrid 独立一级 ${entry.key} 必须存在于 flat 清单（翻译/图标复用契约）',
      );
    }
    // hybrid 父子组 ⊂ hierarchical（父 key 与子 key 都必须存在于 hierarchical
    // 清单：翻译按 key 在 hierarchical map 中的真实下标查找，查不到会 fallback
    // 成 snake_case key）。hybrid 内部顺序只决定 seed 的 sortOrder，不影响翻译。
    for (final entry in SeedService.hybridCategoryTemplate) {
      final children = entry.children;
      if (children == null) continue; // 独立一级不走 hierarchical 翻译
      final hierChildren = SeedService.hierarchicalExpenseCategories[entry.key];
      expect(
        hierChildren,
        isNotNull,
        reason: 'hybrid 父 ${entry.key} 必须存在于 hierarchical 清单',
      );
      for (final childKey in children) {
        expect(
          hierChildren!.contains(childKey),
          isTrue,
          reason:
              'hybrid 子 $childKey 必须存在于 '
              'hierarchical[${entry.key}]（翻译下标查找前提）',
        );
      }
    }
  });
  for (final tombstone in [false, true]) {
    test('已有目录不被补种：tombstone=$tombstone', () async {
      final database = SesameDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(database.close);
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      final id = tombstone
          ? SeedService.deterministicCategorySyncId(level: 1, key: 'dining')
          : 'custom-category';
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: '用户目录',
              kind: 'expense',
              level: 1,
              updatedAt: DateTime.utc(2026, 1, 1),
              deletedAt: d.Value(tombstone ? DateTime.utc(2026, 1, 2) : null),
            ),
          );
      final before = await database.select(database.categories).get();
      await SeedService.createHybridCategories(database, l10n);
      expect(await database.select(database.categories).get(), before);
      expect(await database.select(database.syncChanges).get(), isEmpty);
    });
  }

  test('两个首次初始化并发仅产生一套61身份', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(database.close);
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await Future.wait([
      SeedService.createHybridCategories(database, l10n),
      SeedService.createHybridCategories(database, l10n),
    ]);
    final rows = await database.select(database.categories).get();
    expect(rows, hasLength(61));
    expect(rows.map((row) => row.id).toSet(), expectedSyncIds());
  });
}
