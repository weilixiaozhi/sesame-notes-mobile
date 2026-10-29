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

  /// 固定手机宽度验证勾选与展开独立、模式切换和大字号布局。
  testWidgets('统一模板独立选择父与子，并明确切换为已有父模式', (tester) async {
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
          final directory = Directory('Temp/category-model-ui');
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
              child: child!,
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RepaintBoundary(
            key: boundary,
            child: const CategoryTemplatesPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('分类模板库'), findsOneWidget);
    final diningPosition = tester.getTopLeft(
      find.byKey(const ValueKey('template-category-dining')),
    );
    final transportPosition = tester.getTopLeft(
      find.byKey(const ValueKey('template-category-transport')),
    );
    expect(diningPosition.dy, transportPosition.dy);
    expect(transportPosition.dx, greaterThan(diningPosition.dx));
    expect(find.text('已添加'), findsNothing);
    expect(find.text('已有同名分类'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('template-category-dining')));
    await tester.pumpAndSettle();
    expect(find.text('本次已勾选 1 项'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('template-expand-dining')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('午餐'));
    await tester.pumpAndSettle();
    expect(find.text('本次已勾选 2 项'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await snapshot('create-categories');
    await tester.tap(find.text('添加到已有分类'));
    await tester.pumpAndSettle();
    expect(find.text('选择所属分类'), findsOneWidget);
    expect(find.text('本次已勾选 0 项'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    await tester.tap(find.text('选择所属分类'));
    await tester.pumpAndSettle();
    // 最后两个同名项属于选择弹层，明确选择咖啡图标对应的第二个实例。
    await tester.tap(find.text('餐饮').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('选择所属分类'), findsNothing);
    await tester.tap(find.text('午餐'));
    await tester.pumpAndSettle();
    expect(find.text('本次已勾选 1 项'), findsOneWidget);
    await snapshot('append-to-selected-parent');
    tester.view.physicalSize = const Size(320, 700);
    textScale.value = 1.5;
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(find.text('选择所属分类'), findsOneWidget, reason: '目标失效已回滚，应允许重新选择');
    expect(find.text('本次已勾选 1 项'), findsOneWidget, reason: '已选择的子项应保留');
    repo.rejectParent = false;
    await tester.tap(find.text('选择所属分类'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('餐饮').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    expect(repo.submitted, hasLength(1));
    expect(
      repo.submitted!.single.parentId,
      'parent-b',
      reason: '同名目标按用户点击的真实ID提交',
    );
    expect(find.text('本次已勾选 0 项'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
