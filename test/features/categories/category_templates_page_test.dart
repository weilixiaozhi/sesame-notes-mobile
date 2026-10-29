import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/presentation/category_templates_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/shared/widgets/category_grid_item.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_selector.dart';
import '../../helpers/test_isolation.dart';

/// 页面测试只记录真实提交意图；数据库原子性由执行器集成测试覆盖。
class _TemplateRepo extends LocalRepository {
  _TemplateRepo(super.db);
  bool rejectParent = true;
  List<CategoryCreateDraft>? submitted;
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
  @override
  Future<int> createCategoryBatch({
    required List<CategoryCreateDraft> items,
    String? ledgerId,
    bool recordChanges = true,
  }) async {
    if (rejectParent) throw const CategoryParentUnavailableException();
    submitted = items;
    return items.length;
  }
}

/// 只读候选保留两个同名不同图标父项，验证选择的是明确实例。
class _TargetActions extends CategoryActions {
  _TargetActions(super.ref);
  @override
  Future<List<CategoryDisplay>> getTopLevel(
    String kind, {
    String? ledgerId,
  }) async => const [
    CategoryDisplay(
      id: 'parent-a',
      name: '餐饮',
      kind: 'expense',
      level: 1,
      sortOrder: 0,
      icon: 'utensils',
    ),
    CategoryDisplay(
      id: 'parent-b',
      name: '餐饮',
      kind: 'expense',
      level: 1,
      sortOrder: 1,
      icon: 'coffee',
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late _TemplateRepo repo;
  setUp(() {
    resetGlobalTestState();
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = _TemplateRepo(database);
  });
  tearDown(() => database.close());

  /// 固定手机宽度验证多选、单组展开、模式切换和大字号布局。
  testWidgets('统一紧凑模板单组展开，并明确切换为平铺追加模式', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    final textScale = ValueNotifier<double>(1);
    addTearDown(textScale.dispose);
    final screenshot = Platform.environment['CATEGORY_UI_SCREENSHOT'] == '1';
    if (screenshot) {
      await tester.runAsync(() async {
        final fontPath = Platform.environment['CATEGORY_UI_FONT'];
        if (fontPath != null) {
          for (final family in ['UiPreview', 'Roboto', 'NotoSans']) {
            final font = FontLoader(family)
              ..addFont(
                File(
                  fontPath,
                ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
              );
            await font.load();
          }
        }
        final icons = FontLoader('packages/lucide_icons_flutter/Lucide')
          ..addFont(
            rootBundle.load('packages/lucide_icons_flutter/assets/lucide.ttf'),
          );
        await icons.load();
        final material = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await material.load();
      });
    }
    final baseTheme = AppTheme.lightTheme();
    final previewTheme = screenshot
        ? baseTheme.copyWith(
            textTheme: baseTheme.textTheme.apply(fontFamily: 'UiPreview'),
          )
        : baseTheme;

    /// 将真实页面渲染输出到项目临时目录，按需执行而非固化平台字体。
    Future<void> snapshot(String name) async {
      if (!screenshot) return;
      await tester.runAsync(() async {
        try {
          final image =
              await (boundary.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('Temp/category-density-implemented');
          await directory.create(recursive: true);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        } catch (error, stack) {
          stderr.writeln('$error\n$stack');
          rethrow;
        }
      });
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryDataAccessProvider.overrideWithValue(repo),
          categoryActionsProvider.overrideWith((ref) => _TargetActions(ref)),
          currentAccountIdProvider.overrideWith((ref) => null),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          theme: previewTheme,
          builder: (context, child) => ValueListenableBuilder<double>(
            valueListenable: textScale,
            builder: (context, scale, _) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: RepaintBoundary(key: boundary, child: child!),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryTemplatesPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('分类模板库'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    final dining = find.byKey(const ValueKey('template-category-dining'));
    final transport = find.byKey(const ValueKey('template-category-transport'));
    expect(tester.getTopLeft(dining).dy, tester.getTopLeft(transport).dy);
    expect(tester.getSize(dining).height, 80);
    final home = find.byKey(const ValueKey('template-category-home'));
    final family = find.byKey(const ValueKey('template-category-family'));
    expect(tester.getSize(home), tester.getSize(family));
    expect(
      tester
          .getTopLeft(
            find.descendant(of: home, matching: find.byType(CategoryGridIcon)),
          )
          .dy,
      tester
          .getTopLeft(
            find.descendant(
              of: family,
              matching: find.byType(CategoryGridIcon),
            ),
          )
          .dy,
    );
    expect(
      tester.getTopLeft(find.text('居家')).dy,
      tester.getTopLeft(find.text('家庭')).dy,
    );
    expect(find.text('已添加'), findsNothing);
    expect(find.text('已有同名分类'), findsNothing);
    await tester.tap(dining);
    await tester.pumpAndSettle();
    expect(find.text('已选 1 项'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('template-children-dining')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('template-child-dining_lunch')));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await snapshot('new-categories');

    // 只展示最近点击分类的子项；重复点击保留展开，无子项点击收起当前内容。
    await tester.tap(transport);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('template-children-dining')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('template-children-transport')),
      findsOneWidget,
    );
    await tester.tap(transport);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('template-children-transport')),
      findsOneWidget,
    );
    await tester.ensureVisible(family);
    await tester.tap(family);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('template-children-transport')),
      findsNothing,
    );

    await tester.tap(find.text('添加到已有分类'));
    await tester.pumpAndSettle();
    expect(find.text('选择已有分类'), findsOneWidget);
    expect(find.text('已选 0 项'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    final flat = find.byKey(const ValueKey('template-flat-grid'));
    expect(
      tester.widget<GridView>(flat).childrenDelegate.estimatedChildCount,
      159,
    );
    expect(
      tester
          .widgetList<CategoryGridIcon>(
            find.descendant(of: flat, matching: find.byType(CategoryGridIcon)),
          )
          .every((icon) => !icon.hasChildren),
      isTrue,
    );
    expect(
      find.byKey(const ValueKey('template-children-dining')),
      findsNothing,
    );
    await tester.tap(find.byKey(const ValueKey('template-target')));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(AppIcons.close), findsNothing);
    final targetA = find.byKey(const ValueKey('category-target-parent-a'));
    final targetB = find.byKey(const ValueKey('category-target-parent-b'));
    expect(tester.getSize(targetA).height, 80);
    expect(tester.getSize(targetA).width, closeTo(83.5, 1));
    expect(tester.getTopLeft(targetA).dx, 16);
    expect(
      tester.getTopLeft(targetB).dx - tester.getTopLeft(targetA).dx,
      closeTo(tester.getSize(targetA).width + 8, 1),
    );
    await tester.tap(targetB);
    await tester.pumpAndSettle();
    await snapshot('choose-target');
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('选择已有分类'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('template-flat-dining_lunch')));
    await tester.pumpAndSettle();
    final flatScrollable = find.descendant(
      of: flat,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('template-flat-travel')),
      300,
      scrollable: flatScrollable,
    );
    await tester.tap(find.byKey(const ValueKey('template-flat-travel')));
    await tester.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);
    await tester.drag(flat, const Offset(0, 4000));
    await tester.pumpAndSettle();
    await snapshot('append-flat');
    tester.view.physicalSize = const Size(320, 700);
    textScale.value = 1.5;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('添加 2 项'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('选择已有分类'), findsOneWidget, reason: '目标失效已回滚，应允许重新选择');
    expect(find.text('已选 2 项'), findsOneWidget, reason: '已选择节点应保留');
    repo.rejectParent = false;
    await tester.tap(find.byKey(const ValueKey('template-target')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('category-target-parent-b')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加 2 项'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(repo.submitted, hasLength(2));
    expect(
      repo.submitted!.every((item) => item.parentId == 'parent-b'),
      isTrue,
      reason: '独立节点全部绑定用户明确选择的ID',
    );
    expect(repo.submitted!.map((item) => item.name).toSet(), {'午餐', '旅行'});
    expect(find.text('已选 0 项'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('迁移分类选择器保留默认搜索与所属关系提示', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        theme: AppTheme.lightTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showCategoryGridSelector(
                context,
                availableCategories: const [
                  (
                    category: CategoryDisplay(
                      id: 'parent',
                      name: '餐饮',
                      kind: 'expense',
                      level: 1,
                      sortOrder: 0,
                    ),
                    transactionCount: 0,
                  ),
                  (
                    category: CategoryDisplay(
                      id: 'child',
                      name: '午餐',
                      kind: 'expense',
                      level: 2,
                      parentId: 'parent',
                      sortOrder: 0,
                    ),
                    transactionCount: 1,
                  ),
                ],
              ),
              child: const Text('打开选择器'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开选择器'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '午餐');
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is Text && widget.data == '午餐'),
      findsOneWidget,
    );
    expect(find.textContaining('餐饮'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('category-compact-target-grid')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
