import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_plan_edit_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/providers/fitness_repository_provider.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/theme/app_theme.dart';

import '../../helpers/fitness_space_fixture.dart';

const _longTemplate = FitnessTemplate(
  id: '11111111-1111-4111-8111-111111111111',
  name: '包含热身与拉伸的全身力量训练长名称模板',
  exercises: [
    FitnessExercise(
      id: '33333333-3333-4333-8333-333333333333',
      exerciseId: '0025',
      sets: [
        FitnessSet(
          id: '44444444-4444-4444-8444-444444444444',
          weight: '20',
          reps: 8,
        ),
      ],
    ),
  ],
);
const _otherTemplate = FitnessTemplate(
  id: '22222222-2222-4222-8222-222222222222',
  name: '另一套训练',
);

/// 只延迟保存完成，目标身份和其他操作仍由真实仓储提供。
class _WaitingPlanActions extends FitnessActions {
  /// 页面通过应用操作提交草稿，测试在同一边界观察提交次数与安排结果。
  _WaitingPlanActions(FitnessRepository repository)
    : super(
        queryPort: repository,
        workoutPort: repository,
        libraryPort: repository,
        preferencesPort: repository,
      );

  final completed = Completer<FitnessPlan>();
  final submitted = <FitnessPlan>[];

  /// 保持保存悬而未决，让真实页面进入忙碌状态并接受重复点击验证。
  @override
  Future<FitnessPlan> savePlan(FitnessPlan plan, {String? restartDate}) {
    try {
      submitted.add(plan);
      return completed.future;
    } catch (error, stack) {
      debugPrint('记录计划保存请求失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }
}

/// 文字需位于真实可点击底板内，并保留输入主题规定的上下留白。
void _expectTemplateInsideSurface(WidgetTester tester, Finder entry) {
  try {
    final surface = find.descendant(
      of: entry,
      matching: find.byType(AppInputSurface),
    );
    final tapTarget = find.descendant(
      of: surface,
      matching: find.byType(InkWell),
    );
    final label = find.descendant(of: surface, matching: find.byType(Text));
    expect(surface, findsOneWidget);
    expect(tapTarget, findsOneWidget);
    expect(label, findsOneWidget);
    final labelRect = tester.getRect(label);
    final targetRect = tester.getRect(tapTarget);
    final context = tester.element(surface);
    final padding = InputDecorationTheme.of(
      context,
    ).contentPadding?.resolve(Directionality.of(context));
    expect(labelRect.left, greaterThanOrEqualTo(targetRect.left));
    expect(labelRect.right, lessThanOrEqualTo(targetRect.right));
    expect(
      labelRect.top - targetRect.top,
      greaterThanOrEqualTo((padding?.top ?? 0) - 0.1),
      reason: '大字号模板名称应自然撑高底板，保留主题上内边距',
    );
    expect(
      targetRect.bottom - labelRect.bottom,
      greaterThanOrEqualTo((padding?.bottom ?? 0) - 0.1),
      reason: '大字号模板名称不能侵占主题下内边距或超出点击区域',
    );
  } catch (error, stack) {
    debugPrint('检查计划模板入口文字与点击底板布局失败：$error');
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
}

/// 页面列表按需构建屏幕外条目，先通过真实上滑加载并显示模板入口。
Future<void> _scrollToTemplate(WidgetTester tester, Finder entry) async {
  try {
    final pageList = find.descendant(
      of: find.byType(FitnessPlanEditPage),
      matching: find.byType(ListView),
    );
    expect(pageList, findsOneWidget);
    for (var attempt = 0; attempt < 40; attempt++) {
      if (entry.hitTestable().evaluate().isNotEmpty) return;
      await tester.drag(pageList, const Offset(0, -120));
      await tester.pumpAndSettle();
    }
    expect(
      entry.hitTestable(),
      findsOneWidget,
      reason: '用户应能通过上滑计划表单找到并点击模板入口',
    );
  } catch (error, stack) {
    debugPrint('滚动真实计划页以显示模板入口失败：$error');
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
}

/// 使用真实编辑页验证短屏大字号布局、单次安排与保存阶段的交互阻断。
void main() {
  for (final dark in [false, true]) {
    testWidgets('深色=$dark：短屏大字号模板入口保持两列、单次安排及保存禁用', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      final analytics = ProductAnalyticsController(
        writer: () async => throw StateError('本测试关闭采集，不应创建上传器'),
        runtime: () => const ProductAnalyticsRuntime(
          identity: ProductAnalyticsIdentity(null, 0),
          enabled: false,
        ),
      );
      addTearDown(analytics.dispose);
      _WaitingPlanActions? actions;
      try {
        // 真实空间固定操作目标，模板流仅隔离与本次布局无关的订阅时序。
        late FitnessRepository repository;
        await tester.runAsync(() async {
          repository = await createFitnessTestRepository(db);
        });
        final waitingActions = _WaitingPlanActions(repository);
        actions = waitingActions;
        final draft = FitnessPlan(
          name: '短屏回归计划',
          startDate: '2026-10-16',
          cycleDays: 3,
          days: List.generate(3, (index) => FitnessPlanDay(dayIndex: index)),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              ...fitnessSpaceFixtureOverrides(repository),
              fitnessRepositoryProvider.overrideWithValue(repository),
              fitnessActionsProvider.overrideWithValue(waitingActions),
              fitnessTemplatesProvider.overrideWith(
                (ref) => Stream.value([_longTemplate, _otherTemplate]),
              ),
              productAnalyticsControllerProvider.overrideWithValue(analytics),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
              locale: const Locale('zh'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, page) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(2)),
                child: page!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => FitnessPlanEditPage(plan: draft),
                      ),
                    ),
                    child: const Text('打开计划'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('打开计划'));
        await tester.pumpAndSettle();
        final entry = find.byKey(
          ValueKey('fitness-plan-template-${_longTemplate.id}'),
        );
        final otherEntry = find.byKey(
          ValueKey('fitness-plan-template-${_otherTemplate.id}'),
        );
        await _scrollToTemplate(tester, entry);
        expect(entry.hitTestable(), findsOneWidget);
        _expectTemplateInsideSurface(tester, entry);
        _expectTemplateInsideSurface(tester, otherEntry);
        final firstRect = tester.getRect(entry);
        final secondRect = tester.getRect(otherEntry);
        expect(firstRect.top, closeTo(secondRect.top, 0.1));
        expect(firstRect.width, closeTo(secondRect.width, 0.1));
        expect(firstRect.right, lessThan(secondRect.left));
        expect(tester.takeException(), isNull);

        await tester.tap(entry);
        await tester.pumpAndSettle();
        final save = find.descendant(
          of: find.byType(AppEditorFooter),
          matching: find.byType(FilledButton),
        );
        await tester.tap(save);
        await tester.pump();
        expect(waitingActions.submitted, hasLength(1));
        final saved = waitingActions.submitted.single;
        expect(saved.days.where((day) => day.slot != null), hasLength(1));
        expect(saved.days.first.slot?.sourceTemplateId, _longTemplate.id);
        expect(
          saved.days.skip(1).every((day) => day.slot == null),
          isTrue,
          reason: '一次模板点击只能安排当前一天，不能重复推进到下一天',
        );
        expect(tester.widget<FilledButton>(save).onPressed, isNull);
        expect(
          tester
              .widget<AbsorbPointer>(
                find.descendant(
                  of: find.byType(FitnessPlanEditPage),
                  matching: find.byType(AbsorbPointer),
                ),
              )
              .absorbing,
          isTrue,
        );
        // 保存尚未完成时，模板和底部保存均不能响应新的业务操作。
        await tester.tap(entry, warnIfMissed: false);
        await tester.tap(save);
        await tester.pump();
        expect(waitingActions.submitted, hasLength(1));
        waitingActions.completed.complete(saved);
        await tester.pumpAndSettle();
        expect(find.byType(FitnessPlanEditPage), findsNothing);
        expect(find.text('打开计划'), findsOneWidget);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('真实计划页模板入口交互回归失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      } finally {
        // 提前失败时也释放等待中的保存请求，避免测试残留异步任务。
        if (actions != null && !actions.completed.isCompleted) {
          actions.completed.complete(
            actions.submitted.isEmpty
                ? const FitnessPlan(name: '清理草稿', cycleDays: 1)
                : actions.submitted.last,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }
}
