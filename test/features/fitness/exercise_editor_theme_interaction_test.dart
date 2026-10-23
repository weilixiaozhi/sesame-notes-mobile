import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_exercise_editor.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';

const _exerciseInstanceId = 'theme-editor-exercise';
const _setId = 'theme-editor-set';

/// 独立编辑会话持有草稿，媒体使用随包目录，不创建账号、仓库或云端查询。
class _EditorHarness extends StatefulWidget {
  const _EditorHarness({
    super.key,
    required this.definition,
    required this.preset,
    required this.dark,
    this.readOnly = false,
    this.preferences = const FitnessPreferences(),
    this.initialExercises,
    this.enableWeightModeChange = false,
  });

  final FitnessExerciseDefinition definition;
  final AppThemePreset preset;
  final bool dark;
  final bool readOnly;
  final FitnessPreferences preferences;
  final List<FitnessExercise>? initialExercises;
  final bool enableWeightModeChange;

  /// 状态跨外观变化保留同一个编辑会话。
  @override
  State<_EditorHarness> createState() => _EditorHarnessState();
}

class _EditorHarnessState extends State<_EditorHarness> {
  late AppThemePreset _preset;
  late bool _dark;
  bool _adjustedGeometry = false;
  late List<FitnessExercise> exercises;
  int editCalls = 0;
  int completionCalls = 0;
  String? completedSetId;
  bool failNextWeightMode = false;
  late FitnessPreferences preferences;

  /// 使用一组合法成绩，避免主题验证依赖持久化或额外初始化。
  @override
  void initState() {
    super.initState();
    _preset = widget.preset;
    _dark = widget.dark;
    preferences = widget.preferences;
    exercises =
        widget.initialExercises ??
        [
          FitnessExercise(
            id: _exerciseInstanceId,
            exerciseId: widget.definition.id,
            sets: const [FitnessSet(id: _setId, weight: '20', reps: 8)],
          ),
        ];
  }

  /// 接收编辑器公开回调并回显，验证输入和新增不会额外提交同一次操作。
  void _change(List<FitnessExercise> next) {
    setState(() {
      editCalls++;
      exercises = next;
    });
  }

  /// 按真实回执语义模拟成功转换和失败保留，校验输入会话的口径切换。
  Future<bool> _changeWeightMode(String instanceId, bool side) async {
    if (failNextWeightMode) {
      failNextWeightMode = false;
      return false;
    }
    final exercise = exercises.singleWhere((item) => item.id == instanceId);
    setState(() {
      preferences = preferences.copyWith(
        exerciseWeightModes: {
          ...preferences.exerciseWeightModes,
          exercise.exerciseId: side,
        },
      );
      exercises = fitnessSetExerciseWeightMode(
        exercises,
        exerciseId: exercise.exerciseId,
        sideWeight: side,
      );
    });
    return true;
  }

  /// 完成回调仅更新指定组，错误日志保留动作和组身份便于定位交互失败。
  Future<void> _complete(
    FitnessExercise exercise,
    FitnessSet set,
    bool completed,
  ) async {
    try {
      setState(() {
        completionCalls++;
        completedSetId = set.id;
        exercises = [
          for (final current in exercises)
            if (current.id == exercise.id)
              current.copyWith(
                sets: [
                  for (final item in current.sets)
                    item.id == set.id
                        ? item.copyWith(completed: completed)
                        : item,
                ],
              )
            else
              current,
        ];
      });
    } catch (error, stack) {
      debugPrint('训练完成回调失败：动作=${exercise.id}，组=${set.id}，$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  /// 外观操作保留编辑器在组件树中的位置，使焦点与输入控制器继续属于原草稿。
  void _switchTheme() {
    setState(() {
      _preset = AppThemePreset
          .values[(_preset.index + 1) % AppThemePreset.values.length];
      _dark = !_dark;
    });
  }

  /// 只改变几何令牌，颜色保持不变，覆盖虚线轮廓的独立重绘条件。
  void _adjustGeometry() =>
      setState(() => _adjustedGeometry = !_adjustedGeometry);

  /// 标准输入框直接编辑本地草稿，测试无需加载页面级数字键盘和数据服务。
  @override
  Widget build(BuildContext context) {
    var theme = _dark
        ? AppTheme.darkTheme(preset: _preset)
        : AppTheme.lightTheme(preset: _preset);
    if (_adjustedGeometry) {
      final visual = theme.extension<AppVisualTheme>()!;
      theme = theme.copyWith(
        extensions: [
          visual.copyWith(
            radii: {
              ...visual.radii,
              AppThemeRadius.input: visual.radius(AppThemeRadius.input) + 2,
              AppThemeRadius.button: visual.radius(AppThemeRadius.button) + 2,
            },
          ),
        ],
      );
    }
    return MaterialApp(
      theme: theme,
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(onPressed: _switchTheme, child: const Text('切换外观')),
            TextButton(onPressed: _adjustGeometry, child: const Text('调整圆角')),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            FitnessExerciseEditor(
              exercises: exercises,
              catalog: [widget.definition],
              preferences: preferences,
              readOnly: widget.readOnly,
              execution: !widget.readOnly,
              onChanged: _change,
              onCompleted: widget.readOnly ? null : _complete,
              onWeightModeRequested: widget.enableWeightModeChange
                  ? _changeWeightMode
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 保持输入行有正常可触达宽度，避免测试视口把真实交互藏在滚动区域外。
Future<void> _pumpEditor(
  WidgetTester tester, {
  required GlobalKey<_EditorHarnessState> session,
  required FitnessExerciseDefinition definition,
  required AppThemePreset preset,
  required bool dark,
  bool readOnly = false,
  FitnessPreferences preferences = const FitnessPreferences(),
  List<FitnessExercise>? initialExercises,
  bool enableWeightModeChange = false,
}) async {
  tester.view.physicalSize = const Size(600, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    _EditorHarness(
      key: session,
      definition: definition,
      preset: preset,
      dark: dark,
      readOnly: readOnly,
      preferences: preferences,
      initialExercises: initialExercises,
      enableWeightModeChange: enableWeightModeChange,
    ),
  );
  await tester.pumpAndSettle();
}

/// 通过组和字段身份定位实际文本输入，避免依赖页面内其他数字标签。
Finder _input(String field) => find.descendant(
  of: find.byKey(ValueKey('$_setId:$field:kg')),
  matching: find.byType(TextFormField),
);

/// 只读约束由实际文本编辑入口执行，不能只验证外层编辑器的配置值。
EditableText _editableInput(WidgetTester tester, String field) =>
    tester.widget<EditableText>(
      find.descendant(of: _input(field), matching: find.byType(EditableText)),
    );

/// 提取输入所在的外层轮廓，验证外观变化后仍使用当前会话的输入底板。
BoxDecoration _inputSurface(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.byKey(const ValueKey('$_setId:weight:kg')),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

/// 新增操作的可见虚线由前景绘制，保持公开绘制契约即可判断是否需要刷新。
CustomPainter _addSetBorder(WidgetTester tester) => tester
    .widget<CustomPaint>(
      find
          .ancestor(
            of: find.text('添加训练组'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint && widget.foregroundPainter != null,
            ),
          )
          .first,
    )
    .foregroundPainter!;

/// 主题切换只改变外观，训练成绩、组身份与提交次数由真实交互验证。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FitnessExerciseDefinition definition;
  setUpAll(() async {
    try {
      final json =
          jsonDecode(
                await rootBundle.loadString('assets/fitness/exercises.json'),
              )
              as Map<String, dynamic>;
      final entry = (json['exercises'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere((item) => item['id'] == '0025');
      definition = FitnessExerciseDefinition.fromJson(entry);
    } catch (error, stack) {
      debugPrint('读取内置训练目录失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  testWidgets('空间偏好变化后历史重量可见，重复动作的空白实例跟随已有成绩', (tester) async {
    final session = GlobalKey<_EditorHarnessState>();
    try {
      await _pumpEditor(
        tester,
        session: session,
        definition: definition,
        preset: AppThemePreset.classic,
        dark: false,
        preferences: const FitnessPreferences(
          exerciseWeightModes: {'0025': true},
        ),
        initialExercises: [
          FitnessExercise(
            id: _exerciseInstanceId,
            exerciseId: definition.id,
            sets: const [FitnessSet(id: _setId, weight: '20', reps: 8)],
          ),
          FitnessExercise(
            id: 'blank-instance',
            exerciseId: definition.id,
            sets: const [FitnessSet(id: 'blank-set', reps: 8)],
          ),
        ],
      );
      await tester.tap(
        find.byKey(const ValueKey('fitness-drag-$_exerciseInstanceId')),
      );
      await tester.pumpAndSettle();
      expect(_input('weight'), findsOneWidget);
      expect(_input('weight_left'), findsNothing);
      await tester.enterText(_input('weight'), '22');
      await tester.pump();
      expect(session.currentState!.exercises.first.sets.single.weight, '22');
      expect(session.currentState!.exercises.last.sets.single.weight, isNull);
      await tester.tap(
        find.byKey(const ValueKey('fitness-drag-blank-instance')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('blank-set:weight:kg')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('blank-set:weight_left:kg')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('历史训练重量口径验证失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  testWidgets('只读官方动作不能通过长按拖动改变顺序', (tester) async {
    final session = GlobalKey<_EditorHarnessState>();
    try {
      await _pumpEditor(
        tester,
        session: session,
        definition: definition,
        preset: AppThemePreset.classic,
        dark: false,
        readOnly: true,
        initialExercises: [
          FitnessExercise(id: 'first', exerciseId: definition.id),
          FitnessExercise(id: 'second', exerciseId: definition.id),
        ],
      );
      final first = find.byKey(const ValueKey('fitness-drag-first'));
      final second = find.byKey(const ValueKey('fitness-drag-second'));
      final gesture = await tester.startGesture(tester.getCenter(first));
      await tester.pump(const Duration(seconds: 1));
      await gesture.moveTo(tester.getCenter(second) + const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 300));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(session.currentState!.editCalls, 0);
      expect(session.currentState!.exercises.map((item) => item.id), [
        'first',
        'second',
      ]);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      debugPrint('只读动作拖动测试失败：${error.runtimeType}\n$stackTrace');
      rethrow;
    }
  });

  testWidgets('清空最后一个重量保持口径，切换失败保留输入，成功回执才切换', (tester) async {
    final session = GlobalKey<_EditorHarnessState>();
    try {
      await _pumpEditor(
        tester,
        session: session,
        definition: definition,
        preset: AppThemePreset.classic,
        dark: false,
        preferences: const FitnessPreferences(
          exerciseWeightModes: {'0025': true},
        ),
        enableWeightModeChange: true,
      );
      await tester.enterText(_input('weight'), '');
      await tester.pump();
      expect(_input('weight'), findsOneWidget);
      expect(_input('weight_left'), findsNothing);
      session.currentState!.failNextWeightMode = true;
      await tester.tap(
        find.byKey(const ValueKey('$_exerciseInstanceId:side-weight')),
      );
      await tester.pumpAndSettle();
      expect(_input('weight'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('$_exerciseInstanceId:side-weight')),
      );
      await tester.pumpAndSettle();
      expect(_input('weight'), findsNothing);
      expect(_input('weight_left'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('$_exerciseInstanceId:side-weight')),
      );
      await tester.pumpAndSettle();
      expect(_input('weight'), findsOneWidget);
      expect(_input('weight_left'), findsNothing);
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('清空重量后的口径切换验证失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  for (final preset in AppThemePreset.values) {
    for (final dark in [false, true]) {
      testWidgets('${preset.name}深色=$dark：主题往返保留草稿，编辑新增完成各提交一次', (
        tester,
      ) async {
        final session = GlobalKey<_EditorHarnessState>();
        final semantics = tester.ensureSemantics();
        try {
          await _pumpEditor(
            tester,
            session: session,
            definition: definition,
            preset: preset,
            dark: dark,
          );
          await tester.enterText(_input('weight'), '25.');
          await tester.pump();
          expect(session.currentState!.editCalls, 1);
          expect(find.text('25.'), findsOneWidget);

          await tester.tap(find.text('切换外观'));
          await tester.pumpAndSettle();
          expect(find.text('25.'), findsOneWidget, reason: '切换主题不能丢弃未输完的小数');
          expect(session.currentState!.editCalls, 1);

          await tester.enterText(_input('weight'), '25.5');
          await tester.pump();
          await tester.enterText(_input('reps'), '10');
          await tester.pump();
          expect(session.currentState!.editCalls, 3);
          final original = session.currentState!.exercises.single.sets.single;
          expect(original.weight, '25.5');
          expect(original.reps, 10);

          await tester.tap(find.text('添加训练组'));
          await tester.pumpAndSettle();
          final sets = session.currentState!.exercises.single.sets;
          expect(session.currentState!.editCalls, 4);
          expect(sets, hasLength(2));
          expect(sets.last.id, isNot(original.id));
          expect(sets.last.weight, '25.5');
          expect(sets.last.reps, 10);
          expect(sets.last.completed, isFalse);

          await tester.tap(find.bySemanticsLabel('确定 1'));
          await tester.pumpAndSettle();
          expect(session.currentState!.completionCalls, 1);
          expect(session.currentState!.completedSetId, _setId);
          expect(
            session.currentState!.exercises.single.sets.first.completed,
            isTrue,
          );
          expect(session.currentState!.editCalls, 4);
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint('训练编辑主题交互验证失败：${preset.name}，深色=$dark，$error');
          debugPrintStack(stackTrace: stack);
          rethrow;
        } finally {
          semantics.dispose();
        }
      });
    }
  }

  testWidgets('仅圆角变化仍更新输入底板和新增虚线，保留已编辑成绩', (tester) async {
    final session = GlobalKey<_EditorHarnessState>();
    try {
      await _pumpEditor(
        tester,
        session: session,
        definition: definition,
        preset: AppThemePreset.classic,
        dark: false,
      );
      await tester.enterText(_input('weight'), '32.5');
      await tester.pump();
      final before = _inputSurface(tester);
      final oldBorder = _addSetBorder(tester);
      await tester.tap(find.text('调整圆角'));
      await tester.pumpAndSettle();
      final after = _inputSurface(tester);
      expect(after.color, before.color, reason: '此次外观调整仅改变轮廓');
      expect(after.borderRadius, isNot(before.borderRadius));
      expect(_addSetBorder(tester).shouldRepaint(oldBorder), isTrue);
      expect(find.text('32.5'), findsOneWidget);
      expect(session.currentState!.exercises.single.sets.single.weight, '32.5');
      expect(session.currentState!.editCalls, 1);
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('训练编辑圆角刷新验证失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  testWidgets('只读预览切换三主题亮暗后仍不能修改成绩或新增训练组', (tester) async {
    final session = GlobalKey<_EditorHarnessState>();
    try {
      await _pumpEditor(
        tester,
        session: session,
        definition: definition,
        preset: AppThemePreset.classic,
        dark: false,
        readOnly: true,
      );
      for (var index = 0; index < AppThemePreset.values.length * 2; index++) {
        expect(_editableInput(tester, 'weight').readOnly, isTrue);
        expect(_editableInput(tester, 'reps').readOnly, isTrue);
        expect(find.text('添加训练组'), findsNothing);
        await tester.tap(_input('weight'));
        await tester.tap(find.byKey(const ValueKey('$_setId:kind')));
        await tester.pump();
        expect(session.currentState!.editCalls, 0);
        expect(session.currentState!.completionCalls, 0);
        final set = session.currentState!.exercises.single.sets.single;
        expect(set.weight, '20');
        expect(set.reps, 8);
        expect(set.kind, 'working');
        expect(set.completed, isFalse);
        await tester.tap(find.text('切换外观'));
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('训练编辑只读交互验证失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });
}
