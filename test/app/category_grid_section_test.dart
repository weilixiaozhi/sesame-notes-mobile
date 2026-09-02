/// 记账页分类网格（CategoryGridSection）测试。
///
/// 缓存化改造后的核心行为：
///   1. 分类树来自 categoryPickerTreeProvider，数据就绪即同步渲染
///      （无"空白 → 出现"的多帧跳变）；
///   2. 新建模式：首个数据帧后默认选中第一个一级分类并自动展开其子分类；
///   3. 点击一级分类：上报选中，含子分类的展开、无子分类的收起；
///   4. 编辑模式（initialSelectedId 为二级分类）：首帧即展开其父分类；
///   5. 空树：显示空态与「编辑分类」入口；
///   6. 共享账本 Editor：编辑入口置灰（只读文案、点击不跳转）；
///      Owner / 个人账本：入口保持可点并跳转分类管理页。
///
/// provider 用 override 直接注入内存树，与 db 的集成由
/// test/providers/category_picker_tree_provider_test.dart 覆盖。
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 构造测试分类（名称不含 '_'，避开 CategoryUtils 的 key 翻译路径，
  /// 保证显示名与传入名一致）。
  CategoryDisplay cat(
    String id,
    String name, {
    String? parentId,
    int level = 1,
  }) {
    return CategoryDisplay(
      id: id,
      name: name,
      kind: 'expense',
      sortOrder: 0,
      parentId: parentId,
      level: level,
    );
  }

  /// 两个一级分类（餐饮含一个二级"早餐"），用于多数用例。
  final tree = CategoryPickerTree(
    topLevel: [cat('c1', '测试餐饮'), cat('c2', '测试交通')],
    children: {
      'c1': [cat('c11', '测试早餐', parentId: 'c1', level: 2)],
    },
  );

  /// 构造测试账本（只填角色/共享标记关心字段，其余给固定值）。
  ///
  /// 共享账本 Editor 判定 = memberCount > 1 且 role != owner；
  /// 个人账本 = memberCount == 1。
  Ledger ledger({int memberCount = 1, String role = 'owner'}) => Ledger(
    id: 'ledger-1',
    name: '测试账本',
    currency: 'CNY',
    role: role,
    memberCount: memberCount,
    monthStartDay: 1,
    storageMode: 'cloud',
    aaEnabled: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  /// 分类管理页路由标记：跳转成功即渲染该文本。
  Widget manageMarker(BuildContext context) =>
      const Scaffold(body: Text('MANAGE_MARKER'));

  /// 构建测试宿主：注入分类树 provider override + 本地化上下文。
  ///
  /// [ledger] 为当前账本 override（null 表示未加载到账本），
  /// 用于覆盖共享账本 Editor/Owner 两种角色下的「编辑分类」入口行为；
  /// 注册 Routes.categoryManage 命名的 marker 路由，验证入口点击是否跳转。
  Widget buildHarness({
    required CategoryPickerTree injected,
    required ValueChanged<CategoryDisplay> onCategorySelected,
    String? initialSelectedId,
    Ledger? ledger,
  }) {
    return ProviderScope(
      overrides: [
        categoryPickerTreeProvider(
          'expense',
        ).overrideWith((ref) => Stream.value(injected)),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(ledger),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        // go_router stubs：categoryManage 命中桩页面，验证入口点击跳转。
        routerConfig: createAppRouter(
          home: () => Scaffold(
            body: CategoryGridSection(
              kind: 'expense',
              initialSelectedId: initialSelectedId,
              onCategorySelected: onCategorySelected,
            ),
          ),
          stubs: {Routes.categoryManage: manageMarker},
        ),
      ),
    );
  }

  testWidgets('数据就绪即渲染网格；新建模式默认选中第一个分类并展开其子分类', (tester) async {
    final selected = <CategoryDisplay>[];
    await tester.pumpWidget(
      buildHarness(injected: tree, onCategorySelected: selected.add),
    );
    // Stream.value 首个事件 + postFrame 默认选中，各需一帧
    await tester.pump();
    await tester.pump();

    expect(find.text('测试餐饮'), findsOneWidget);
    expect(find.text('测试交通'), findsOneWidget);
    // 默认选中第一个一级分类（含子分类 → 子分类卡片同帧展开）
    expect(selected.map((c) => c.id), ['c1']);
    expect(find.text('测试早餐'), findsOneWidget);
  });

  testWidgets('父/子分类名称统一 12px label', (tester) async {
    await tester.pumpWidget(
      buildHarness(injected: tree, onCategorySelected: (_) {}),
    );
    await tester.pump();
    await tester.pump();

    for (final name in ['测试餐饮', '测试早餐']) {
      final style = tester.widget<Text>(find.text(name)).style;
      expect(style?.fontSize, 12, reason: '$name 字号应为 12px label');
    }
  });

  testWidgets('点击无子分类的一级分类：上报选中并收起子分类卡片', (tester) async {
    final selected = <CategoryDisplay>[];
    await tester.pumpWidget(
      buildHarness(injected: tree, onCategorySelected: selected.add),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('测试交通'));
    await tester.pump();

    expect(selected.last.id, 'c2');
    // 无子分类 → 展开区收起
    expect(find.text('测试早餐'), findsNothing);
  });

  testWidgets('编辑模式：初始二级分类首帧即展开其父分类', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        injected: tree,
        initialSelectedId: 'c11',
        onCategorySelected: (_) {},
      ),
    );
    await tester.pump();

    // 父分类子卡片展开，二级分类可见（无需再点父分类）
    expect(find.text('测试早餐'), findsOneWidget);
  });

  testWidgets('空树：显示空态与编辑分类入口', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        injected: CategoryPickerTree.empty,
        onCategorySelected: (_) {},
      ),
    );
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.categoryEmpty), findsOneWidget);
    expect(find.text(l10n.txEditCategory), findsOneWidget);
  });

  testWidgets('共享账本 Editor：编辑入口置灰，文案只读提示，点击不跳转', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        injected: tree,
        onCategorySelected: (_) {},
        ledger: ledger(memberCount: 2, role: 'editor'),
      ),
    );
    await tester.pump();
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    // 文案切换为只读提示（「编辑分类」入口不出现）
    expect(find.text(l10n.txEditCategoryReadOnly), findsOneWidget);
    expect(find.text(l10n.txEditCategory), findsNothing);

    // 置灰态 onTap 为 null：点击不跳转分类管理页
    await tester.tap(find.text(l10n.txEditCategoryReadOnly));
    await tester.pumpAndSettle();
    expect(find.text('MANAGE_MARKER'), findsNothing);
  });

  testWidgets('共享账本 Owner：编辑入口保持可点，点击跳转分类管理页', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        injected: tree,
        onCategorySelected: (_) {},
        ledger: ledger(memberCount: 2),
      ),
    );
    await tester.pump();
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.txEditCategory), findsOneWidget);

    await tester.tap(find.text(l10n.txEditCategory));
    await tester.pumpAndSettle();
    expect(find.text('MANAGE_MARKER'), findsOneWidget);
  });

  testWidgets('个人账本：编辑入口保持可点，文案为编辑分类', (tester) async {
    await tester.pumpWidget(
      buildHarness(
        injected: tree,
        onCategorySelected: (_) {},
        ledger: ledger(),
      ),
    );
    await tester.pump();
    await tester.pump();

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    expect(find.text(l10n.txEditCategory), findsOneWidget);
    expect(find.text(l10n.txEditCategoryReadOnly), findsNothing);
  });
}
