import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_library_pages.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_detail_pages.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_official_plan_detail_page.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_plan_edit_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/providers/fitness_library_provider.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';

import '../../helpers/test_isolation.dart';

const _personalId = '33333333-3333-4333-8333-333333333333';
const _target = (
  bookId: '44444444-4444-4444-8444-444444444444',
  accountId: null,
  syncId: null,
  generation: 0,
);

/// 记录页面最终确认的内容；数据库原子性由仓储测试覆盖。
class _RecordingActions extends Mock implements FitnessActions {
  FitnessPlan? submitted;
  Map<String, FitnessTemplate> submittedOfficial = {};

  @override
  PrivateBookTarget get target => _target;

  /// 模拟成功回执，保留名称、模板快照和启用状态供页面断言。
  @override
  Future<FitnessPlan> savePlan(
    FitnessPlan plan, {
    String? restartDate,
    Map<String, FitnessTemplate> officialTemplates = const {},
  }) async {
    submitted = plan;
    submittedOfficial = Map.of(officialTemplates);
    return plan.copyWith(createdAt: DateTime.now(), updatedAt: DateTime.now());
  }
}

/// 测试只使用本地官方资料与示例个人模板，不读取真实账号内容。
class _PlanTestHarness {
  _PlanTestHarness(
    this.library,
    this.catalog,
    this.personal, {
    this.savedPlans = const [],
    this.personalTemplates,
  });

  final FitnessLibrary library;
  final List<FitnessExerciseDefinition> catalog;
  final FitnessTemplate personal;
  final List<FitnessPlan> savedPlans;
  final List<FitnessTemplate>? personalTemplates;
  final actions = _RecordingActions();
  final boundary = GlobalKey();
  final screenshot = Platform.environment['FITNESS_PLAN_SCREENSHOT'] == '1';

  /// 导入页与列表页使用同一份官方快照和固定空间归属。
  FitnessPlanImportDraft get importDraft => createFitnessPlanImportDraft(
    library: library,
    officialPlan: library.plans.first,
    locale: const Locale('zh'),
    startDate: DateTime.now(),
    target: _target,
  );

  /// 固定手机视口，并按需载入真实中文字形和图标字形用于验收截图。
  Future<void> open(
    WidgetTester tester,
    Widget page, {
    double width = 390,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    if (screenshot) {
      await tester.runAsync(() async {
        try {
          final path = Platform.environment['FITNESS_PLAN_FONT'];
          if (path != null) {
            for (final family in ['UiPreview', 'Roboto', 'NotoSans']) {
              final loader = FontLoader(family)
                ..addFont(File(path).readAsBytes().then(ByteData.sublistView));
              await loader.load();
            }
          }
          await (FontLoader('packages/lucide_icons_flutter/Lucide')..addFont(
                rootBundle.load(
                  'packages/lucide_icons_flutter/assets/lucide.ttf',
                ),
              ))
              .load();
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
        } catch (error, stack) {
          stderr.writeln('计划验收字体载入失败：$error\n$stack');
          rethrow;
        }
      });
    }
    final analytics = ProductAnalyticsController(
      writer: () async => throw StateError('当前测试不启用统计上传'),
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity(null, 0),
        enabled: false,
      ),
    );
    addTearDown(analytics.dispose);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute<void>(builder: (_) => page)),
              child: const Text('打开页面'),
            ),
          ),
        ),
        GoRoute(
          path: Routes.fitnessPlanEdit,
          name: Routes.fitnessPlanEdit,
          builder: (context, state) => state.extra is FitnessPlanImportDraft
              ? FitnessPlanEditPage(
                  importDraft: state.extra as FitnessPlanImportDraft,
                )
              : FitnessPlanEditPage(plan: state.extra as FitnessPlan?),
        ),
        GoRoute(
          path: Routes.fitnessPlans,
          name: Routes.fitnessPlans,
          builder: (context, state) => const Scaffold(body: Text('我的计划')),
        ),
      ],
    );
    addTearDown(router.dispose);
    final theme = AppTheme.lightTheme();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fitnessActionsProvider.overrideWithValue(actions),
          fitnessLibraryProvider.overrideWith((ref) async => library),
          fitnessCatalogProvider.overrideWith((ref) async => catalog),
          fitnessTemplatesProvider.overrideWith(
            (ref) => Stream.value(personalTemplates ?? [personal]),
          ),
          fitnessPlansProvider.overrideWith((ref) => Stream.value(savedPlans)),
          fitnessPreferencesProvider.overrideWith(
            (ref) => Stream.value(const FitnessPreferences()),
          ),
          productAnalyticsControllerProvider.overrideWithValue(analytics),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('zh'),
          theme: screenshot
              ? theme.copyWith(
                  textTheme: theme.textTheme.apply(fontFamily: 'UiPreview'),
                )
              : theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => RepaintBoundary(
            key: boundary,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('打开页面'));
    await tester.pumpAndSettle();
  }

  /// 将真实 Flutter 页面输出到仓库临时目录，用于手机截图验收。
  Future<void> snapshot(WidgetTester tester, String name) async {
    if (!screenshot) return;
    await tester.runAsync(() async {
      try {
        final render =
            boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await render.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final dir = Directory('Temp/fitness-plan-implementation/screenshots');
        await dir.create(recursive: true);
        await File(
          '${dir.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      } catch (error, stack) {
        stderr.writeln('计划验收截图失败：$name\n$error\n$stack');
        rethrow;
      }
    });
  }
}

/// 点击可滚动区域中的明确操作，避免屏幕外组件造成误报。
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// 比较原生按钮的实际点击区域，包装组件的宽度不能替代按钮尺寸。
void _expectMatchingButtons(
  WidgetTester tester,
  Finder firstOwner,
  Finder secondOwner,
) {
  final first = _nativeButton(firstOwner);
  final second = _nativeButton(secondOwner);
  expect(first, findsOneWidget);
  expect(second, findsOneWidget);
  final firstSize = tester.getSize(first);
  final secondSize = tester.getSize(second);
  expect(firstSize.width, closeTo(secondSize.width, 0.01));
  expect(firstSize.height, closeTo(secondSize.height, 0.01));
  expect(
    firstSize.height,
    greaterThanOrEqualTo(AppDimens.actionButtonMinHeight),
  );
}

/// 按钮键可能挂在公共包装或原生按钮上，两种情况都定位同一点击目标。
Finder _nativeButton(Finder owner) => find.descendant(
  of: owner,
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  matchRoot: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FitnessLibrary library;
  late List<FitnessExerciseDefinition> catalog;
  late FitnessTemplate personal;
  setUpAll(() async {
    try {
      library = FitnessLibrary.fromJson(
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>,
      );
      final data =
          jsonDecode(await File('assets/fitness/exercises.json').readAsString())
              as Map<String, dynamic>;
      catalog = (data['exercises'] as List)
          .map(
            (item) => FitnessExerciseDefinition.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      final original = library.templates.first.toFitnessTemplate(
        const Locale('zh'),
        id: _personalId,
      );
      personal = original.copyWith(
        name: '我的胸三头',
        exercises: original.exercises.take(3).toList(),
      );
    } catch (error, stack) {
      stderr.writeln('计划页面测试资料载入失败：$error\n$stack');
      rethrow;
    }
  });
  setUp(resetGlobalTestState);

  testWidgets('计划库与官方详情只展示周期，统一进入周期编排', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(tester, const FitnessPlanLibraryPage());
    expect(find.text('选一套训练安排'), findsOneWidget);
    expect(find.text('自己编排一个计划'), findsNothing);
    expect(find.text('新建'), findsNothing);
    expect(find.text('全身增肌'), findsNothing);
    await harness.snapshot(tester, '01-library');
    await _tap(tester, find.text('常规三分化训练').first);
    expect(find.byType(FitnessOfficialPlanDetailPage), findsOneWidget);
    expect(find.text('使用这个计划'), findsNothing);
    expect(find.byKey(const ValueKey('fitness-plan-day-3')), findsOneWidget);
    await harness.snapshot(tester, '02-library-detail');
    await _tap(tester, find.text('调整后使用'));
    expect(find.byKey(const ValueKey('fitness-plan-step-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('fitness-plan-previous')), findsOneWidget);
    await harness.snapshot(tester, '03-library-schedule');
    expect(tester.takeException(), isNull);
  });

  testWidgets('新建逐天选择、清空、回退和确认保存都采用已选模板', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(tester, const FitnessPlanEditPage());
    expect(find.byKey(const ValueKey('fitness-plan-step-1')), findsOneWidget);
    await harness.snapshot(tester, '04-new-basic');
    await tester.enterText(
      find.byKey(const ValueKey('fitness-plan-name')),
      '我的训练计划',
    );
    await _tap(tester, find.text('4天'));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(find.byKey(const ValueKey('fitness-plan-step-2')), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    expect(find.text('清空当天'), findsNothing);
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-select-template-$_personalId')),
    );
    expect(find.text('我的胸三头'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    expect(
      find.byKey(const ValueKey('fitness-plan-clear-day')),
      findsOneWidget,
    );
    expect(find.byTooltip('关闭'), findsNothing);
    expect(find.text('复制当天安排'), findsNothing);
    await harness.snapshot(tester, '05-day-picker');
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-clear-day')));
    expect(find.text('我的胸三头'), findsNothing);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-select-template-$_personalId')),
    );
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-rest-remaining')),
    );
    await _tap(tester, find.text('确定').last);
    await harness.snapshot(tester, '06-new-schedule');
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(find.byKey(const ValueKey('fitness-plan-step-3')), findsOneWidget);
    expect(find.text('确认训练内容'), findsNothing);
    expect(find.text('我的胸三头'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-previous')));
    expect(find.text('我的胸三头'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-disabled')));
    final scrollable = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollable.position.jumpTo(0);
    await tester.pumpAndSettle();
    await harness.snapshot(tester, '07-new-confirm');
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(harness.actions.submitted?.name, '我的训练计划');
    expect(harness.actions.submitted?.status, 'closed');
    expect(
      harness.actions.submitted?.days.first.slot?.sourceTemplateId,
      _personalId,
    );
    expect(harness.actions.submitted?.days.first.slot?.exercises.length, 3);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('fitness-plan-content-success')),
        matching: find.text('计划已创建'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('fitness-plan-day-3')), findsOneWidget);
    await harness.snapshot(tester, '08-created-complete-cycle');
    expect(tester.takeException(), isNull);
  });

  testWidgets('新建退出先确认，继续编辑保留输入，退出不保存', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(tester, const FitnessPlanEditPage());
    await tester.enterText(
      find.byKey(const ValueKey('fitness-plan-name')),
      '未保存计划',
    );
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-exit')));
    expect(find.text('退出新建计划？'), findsOneWidget);
    expect(find.text('退出后，本次填写的内容不会保存。'), findsOneWidget);
    await harness.snapshot(tester, '09-exit-confirm');
    await _tap(tester, find.text('继续编辑'));
    expect(find.text('未保存计划'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-exit')));
    await _tap(tester, find.text('退出，不保存'));
    expect(find.text('打开页面'), findsOneWidget);
    expect(harness.actions.submitted, isNull);
    await _tap(tester, find.text('打开页面'));
    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('fitness-plan-name')),
        matching: find.byType(EditableText),
      ),
    );
    expect(field.controller.text, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('官方计划更换个人模板后沿用个人快照，其他库日程保持原版', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(
      tester,
      FitnessPlanEditPage(importDraft: harness.importDraft),
    );
    expect(find.byKey(const ValueKey('fitness-plan-step-2')), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-select-template-$_personalId')),
    );
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(find.text('我的胸三头'), findsOneWidget);
    expect(find.text('确认训练内容'), findsNothing);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    final days = harness.actions.submitted!.days;
    expect(days.first.slot?.sourceTemplateId, _personalId);
    expect(days.first.slot?.exercises.length, 3);
    expect(days[1].slot?.sourceTemplateId, library.templates[1].id);
    expect(days[1].slot?.name, '三分化·背二头');
    expect(tester.takeException(), isNull);
  });

  testWidgets('个人计划详情完整只读展示，并从独立入口进入编辑流程', (tester) async {
    final stored = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: DateTime.now(),
      target: _target,
    ).plan.copyWith(name: '我的三分化计划', createdAt: DateTime.now());
    final harness = _PlanTestHarness(
      library,
      catalog,
      personal,
      savedPlans: [stored],
    );
    await harness.open(
      tester,
      FitnessPlanDetailPage(
        planId: stored.id,
        editorBuilder: (plan, target) =>
            FitnessPlanEditPage(plan: plan, owner: target),
      ),
    );
    expect(find.text('完整周期安排'), findsOneWidget);
    expect(find.byKey(const ValueKey('fitness-plan-day-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('fitness-plan-name')), findsNothing);
    await harness.snapshot(tester, '10-personal-detail');
    await _tap(tester, find.text('编辑计划'));
    expect(
      find.byKey(const ValueKey('fitness-plan-content-1')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('fitness-plan-name')), findsNothing);
    await harness.snapshot(tester, '11-personal-edit');
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-previous')));
    expect(find.byKey(const ValueKey('fitness-plan-name')), findsOneWidget);
    await harness.snapshot(tester, '12-personal-settings');
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-exit')));
    expect(find.text('退出编辑计划？'), findsOneWidget);
    await _tap(tester, find.text('退出，不保存'));
    expect(find.byKey(const ValueKey('fitness-plan-name')), findsNothing);
    expect(find.text('我的三分化计划'), findsOneWidget);
    expect(harness.actions.submitted, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320窄屏和1.3倍字号的基本设置与底部步骤保持可操作', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(
      tester,
      const FitnessPlanEditPage(),
      width: 320,
      textScale: 1.3,
    );
    final custom = tester.renderObject<RenderParagraph>(find.text('自定义'));
    final lines = custom
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 3),
        )
        .map((box) => box.top)
        .toSet();
    expect(lines.length, 1, reason: '窄屏放大字号时周期按钮仍需保持单行');
    await harness.snapshot(tester, '13-narrow-basic-large-text');
    await tester.enterText(
      find.byKey(const ValueKey('fitness-plan-name')),
      '手机计划',
    );
    await _tap(tester, find.text('4天'));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(find.byKey(const ValueKey('fitness-plan-day-3')), findsOneWidget);
    expect(find.byKey(const ValueKey('fitness-plan-previous')), findsOneWidget);
    expect(find.byKey(const ValueKey('fitness-plan-next')), findsOneWidget);
    await harness.snapshot(tester, '14-narrow-schedule-large-text');
    expect(tester.takeException(), isNull);
  });

  for (final layout in [(390.0, 1.0), (320.0, 1.3)]) {
    testWidgets('步骤与退出按钮等宽等高且整个区域可点击 ${layout.$1}/${layout.$2}', (
      tester,
    ) async {
      final harness = _PlanTestHarness(library, catalog, personal);
      await harness.open(
        tester,
        const FitnessPlanEditPage(),
        width: layout.$1,
        textScale: layout.$2,
      );
      await tester.enterText(
        find.byKey(const ValueKey('fitness-plan-name')),
        '尺寸验收计划',
      );
      await _tap(tester, find.text('4天'));
      await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
      final previous = find.byKey(const ValueKey('fitness-plan-previous'));
      final next = find.byKey(const ValueKey('fitness-plan-next'));
      _expectMatchingButtons(tester, previous, next);
      final previousRect = tester.getRect(_nativeButton(previous));
      await tester.tapAt(
        Offset(previousRect.left + AppDimens.p4, previousRect.center.dy),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('fitness-plan-content-0')),
        findsOneWidget,
      );
      final nextRect = tester.getRect(_nativeButton(next));
      await tester.tapAt(
        Offset(nextRect.right - AppDimens.p4, nextRect.center.dy),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('fitness-plan-content-1')),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
      await _tap(
        tester,
        find.byKey(const ValueKey('fitness-plan-select-template-$_personalId')),
      );
      await _tap(
        tester,
        find.byKey(const ValueKey('fitness-plan-rest-remaining')),
      );
      await _tap(tester, find.text('确定').last);
      _expectMatchingButtons(tester, previous, next);
      expect(
        find.descendant(
          of: find.byType(AppEditorFooter),
          matching: find.textContaining(RegExp('训练|休息|已全部安排')),
        ),
        findsNothing,
      );
      await harness.snapshot(
        tester,
        '15-equal-schedule-buttons-${layout.$1.toInt()}',
      );
      await _tap(tester, next);
      _expectMatchingButtons(tester, previous, next);
      await harness.snapshot(
        tester,
        '16-equal-confirm-buttons-${layout.$1.toInt()}',
      );
      await _tap(tester, find.byKey(const ValueKey('fitness-plan-exit')));
      final dialog = find.byType(AppContentDialog);
      final continueEditing = find.descendant(
        of: dialog,
        matching: find.text('继续编辑'),
      );
      final discard = find.descendant(
        of: dialog,
        matching: find.text('退出，不保存'),
      );
      final continueButton = find.ancestor(
        of: continueEditing,
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      );
      final discardButton = find.ancestor(
        of: discard,
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      );
      _expectMatchingButtons(tester, continueButton, discardButton);
      await harness.snapshot(
        tester,
        '17-equal-exit-buttons-${layout.$1.toInt()}',
      );
      final continueRect = tester.getRect(continueButton);
      await tester.tapAt(
        Offset(continueRect.left + AppDimens.p4, continueRect.center.dy),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppContentDialog), findsNothing);
      expect(
        find.byKey(const ValueKey('fitness-plan-content-2')),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(const ValueKey('fitness-plan-exit')));
      final discardRect = tester.getRect(discardButton);
      await tester.tapAt(
        Offset(discardRect.right - AppDimens.p4, discardRect.center.dy),
      );
      await tester.pumpAndSettle();
      expect(find.text('打开页面'), findsOneWidget);
      expect(harness.actions.submitted, isNull);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('没有个人模板只显示空态，仍可从相邻页签选择官方模板', (tester) async {
    final harness = _PlanTestHarness(
      library,
      catalog,
      personal,
      personalTemplates: const [],
    );
    await harness.open(tester, const FitnessPlanEditPage());
    await tester.enterText(
      find.byKey(const ValueKey('fitness-plan-name')),
      '空模板验收',
    );
    await _tap(tester, find.text('4天'));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    expect(find.byType(AppEmpty), findsOneWidget);
    expect(find.text('去模板库选择'), findsNothing);
    expect(find.text('模板库'), findsOneWidget);
    await harness.snapshot(tester, '18-empty-personal-templates');
    await _tap(tester, find.text('模板库'));
    final official = library.templates.first;
    expect(
      find.byKey(ValueKey('fitness-plan-select-template-${official.id}')),
      findsOneWidget,
    );
    await _tap(
      tester,
      find.byKey(ValueKey('fitness-plan-select-template-${official.id}')),
    );
    expect(
      find.text(official.name.resolve(const Locale('zh'))),
      findsOneWidget,
    );
    expect(find.byType(AppSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('长周期重复校验都会重新定位仍未安排的首日', (tester) async {
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(tester, const FitnessPlanEditPage());
    await tester.enterText(
      find.byKey(const ValueKey('fitness-plan-name')),
      '十四天计划',
    );
    await _tap(tester, find.text('14天'));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-select-template-$_personalId')),
    );
    await _tap(
      tester,
      find.byKey(const ValueKey('fitness-plan-rest-remaining')),
    );
    await _tap(tester, find.text('确定').last);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-day-0')));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-clear-day')));
    for (var attempt = 0; attempt < 2; attempt++) {
      await _tap(tester, find.text('下一段'));
      expect(find.byKey(const ValueKey('fitness-plan-day-7')), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
      expect(find.byKey(const ValueKey('fitness-plan-day-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('fitness-plan-day-7')), findsNothing);
      expect(find.text('还有 1 天待安排'), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('已保存未启用的过期计划先确认日期，取消不启用', (tester) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final stored = createFitnessPlanImportDraft(
      library: library,
      officialPlan: library.plans.first,
      locale: const Locale('zh'),
      startDate: yesterday,
      target: _target,
    ).plan.copyWith(status: 'closed', createdAt: DateTime.now());
    final harness = _PlanTestHarness(library, catalog, personal);
    await harness.open(tester, FitnessPlanEditPage(plan: stored));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-enabled')));
    expect(
      find.byKey(const ValueKey('wheel_date_picker_sheet')),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('wheel_date_picker_sheet')), findsNothing);
    expect(
      tester.widget<RadioGroup<bool>>(find.byType(RadioGroup<bool>)).groupValue,
      isFalse,
    );
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-enabled')));
    await _tap(tester, find.text('完成'));
    expect(
      tester.widget<RadioGroup<bool>>(find.byType(RadioGroup<bool>)).groupValue,
      isTrue,
    );
    expect(find.text(date), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('fitness-plan-next')));
    expect(harness.actions.submitted?.status, 'in_progress');
    expect(harness.actions.submitted?.startDate, date);
    expect(tester.takeException(), isNull);
  });
}
