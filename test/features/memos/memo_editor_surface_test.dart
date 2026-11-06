import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/memos/presentation/memo_editor_surface.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 记录编辑器实际注册的系统观察者，检查已卸载实例是否继续驻留。
class _EditorTestBinding extends AutomatedTestWidgetsFlutterBinding {
  final editorObservers = <WidgetsBindingObserver>[];

  /// 与真实绑定保持相同注册语义，重复注册也逐条记录。
  @override
  void addObserver(WidgetsBindingObserver observer) {
    super.addObserver(observer);
    if (observer is QuillRawEditorState) editorObservers.add(observer);
  }

  /// 每次移除只消耗一个注册项，避免集合去重掩盖监听积累。
  @override
  bool removeObserver(WidgetsBindingObserver observer) {
    editorObservers.remove(observer);
    return super.removeObserver(observer);
  }
}

/// 为已释放的通知器提供一个不会产生其他副作用的监听函数。
void _listener() {}

/// 构建真实编辑器，模式变化与普通页面重建使用不同的通知源。
Future<void> _mountSurface(
  WidgetTester tester, {
  required QuillController controller,
  required MemoEditorScrollState scrollState,
  required ValueNotifier<bool> readOnly,
  required ValueNotifier<int> revision,
}) async {
  try {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        locale: const Locale('zh'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: revision,
            builder: (context, _, _) => ValueListenableBuilder<bool>(
              valueListenable: readOnly,
              builder: (context, mode, _) {
                controller.readOnly = mode;
                return MemoEditorSurface(
                  key: ValueKey(mode),
                  controller: controller,
                  scrollState: scrollState,
                  readOnly: mode,
                  onTapUp: (_, _) => false,
                  contextMenuBuilder: (_, _) => const SizedBox.shrink(),
                  onEditError: () => fail('编辑器不应报告输入错误'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } catch (error, stackTrace) {
    debugPrint('编辑器生命周期测试初始化失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 读取当前挂载的编辑器控件，持有的焦点和滚动控制器必须属于当前实例。
QuillEditor _editor(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor));

/// 确认重建不会累积监听，并保持正常输入期间的编辑器实例稳定。
void main() {
  final binding = _EditorTestBinding();

  tearDown(() {
    // 失败用例也清理自身记录，避免后续断言被上一例的观察者污染。
    for (final observer in List.of(binding.editorObservers)) {
      binding.removeObserver(observer);
    }
  });

  testWidgets('反复切换模式释放旧焦点和滚动监听，退出不残留系统观察者', (tester) async {
    final controller = QuillController(
      document: Document.fromJson([
        {'insert': '标题\n正文输入验证\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 3),
      readOnly: true,
    );
    final document = controller.document;
    final readOnly = ValueNotifier(true);
    final revision = ValueNotifier(0);
    addTearDown(controller.dispose);
    addTearDown(readOnly.dispose);
    addTearDown(revision.dispose);
    await _mountSurface(
      tester,
      controller: controller,
      scrollState: MemoEditorScrollState(),
      readOnly: readOnly,
      revision: revision,
    );

    for (var cycle = 0; cycle < 10; cycle++) {
      for (final mode in [false, true]) {
        final oldEditor = _editor(tester);
        final oldScroll = oldEditor.scrollController;
        final oldFocus = oldEditor.focusNode;
        readOnly.value = mode;
        await tester.pumpAndSettle();

        expect(_editor(tester).controller, same(controller));
        expect(controller.document, same(document));
        expect(controller.document.toPlainText(), '标题\n正文输入验证\n');
        expect(() => oldScroll.addListener(_listener), throwsFlutterError);
        expect(() => oldFocus.addListener(_listener), throwsFlutterError);
        expect(tester.testTextInput.hasAnyClients, !mode);
        expect(
          binding.editorObservers.where(
            (observer) => !(observer as QuillRawEditorState).mounted,
          ),
          isEmpty,
          reason: '已卸载编辑器不能继续保留系统观察者',
        );
        expect(binding.editorObservers.length, lessThanOrEqualTo(1));
      }
    }

    readOnly.value = false;
    await tester.pumpAndSettle();
    expect(binding.editorObservers, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(binding.editorObservers, isEmpty);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('普通页面重建和键盘高度变化复用输入实例，不重复连接键盘', (tester) async {
    final controller = QuillController(
      document: Document.fromJson([
        {'insert': '标题\n正文输入验证\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 3),
    );
    final readOnly = ValueNotifier(false);
    final revision = ValueNotifier(0);
    addTearDown(controller.dispose);
    addTearDown(readOnly.dispose);
    addTearDown(revision.dispose);
    await _mountSurface(
      tester,
      controller: controller,
      scrollState: MemoEditorScrollState(),
      readOnly: readOnly,
      revision: revision,
    );
    final editor = _editor(tester);
    final rawState = tester.state<QuillRawEditorState>(
      find.byType(QuillRawEditor),
    );
    tester.testTextInput.log.clear();

    for (var iteration = 0; iteration < 12; iteration++) {
      revision.value++;
      tester.view.viewInsets = FakeViewPadding(
        bottom: iteration.isEven ? 300 : 0,
      );
      await tester.pump();
      expect(_editor(tester).focusNode, same(editor.focusNode));
      expect(_editor(tester).scrollController, same(editor.scrollController));
      expect(
        tester.state<QuillRawEditorState>(find.byType(QuillRawEditor)),
        same(rawState),
      );
      expect(_editor(tester).focusNode.hasFocus, isTrue);
      expect(tester.testTextInput.hasAnyClients, isTrue);
    }

    expect(
      tester.testTextInput.log.where(
        (call) =>
            call.method == 'TextInput.setClient' ||
            call.method == 'TextInput.clearClient',
      ),
      isEmpty,
    );
    expect(binding.editorObservers, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(binding.editorObservers, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('中文组合输入失焦后保持失焦，再次点击可以继续输入', (tester) async {
    final controller = QuillController(
      document: Document.fromJson([
        {'insert': '正文\n'},
      ]),
      selection: const TextSelection.collapsed(offset: 2),
    );
    final readOnly = ValueNotifier(false);
    final revision = ValueNotifier(0);
    addTearDown(controller.dispose);
    addTearDown(readOnly.dispose);
    addTearDown(revision.dispose);
    await _mountSurface(
      tester,
      controller: controller,
      scrollState: MemoEditorScrollState(),
      readOnly: readOnly,
      revision: revision,
    );
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '正文输入\n',
        selection: TextSelection.collapsed(offset: 4),
        composing: TextRange(start: 2, end: 4),
      ),
    );
    await tester.pump();
    FocusScope.of(tester.element(find.byType(QuillEditor))).unfocus();
    await tester.pumpAndSettle();
    expect(_editor(tester).focusNode.hasFocus, isFalse);
    expect(tester.testTextInput.hasAnyClients, isFalse);
    expect(controller.document.toPlainText(), '正文输入\n');

    await tester.tapAt(
      tester.getTopLeft(find.byType(QuillEditor)) + const Offset(30, 24),
    );
    await tester.pumpAndSettle();
    expect(_editor(tester).focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue);
    expect(controller.document.toPlainText(), '正文输入\n');
    await tester.pumpWidget(const SizedBox.shrink());
    expect(binding.editorObservers, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('输入尚未绘制时切只读或直接退出，迟到焦点回调不触碰已卸载实例', (tester) async {
    for (final directlyUnmount in [false, true]) {
      final controller = QuillController(
        document: Document.fromJson([
          {'insert': '标题\n正文输入验证\n'},
        ]),
        selection: const TextSelection.collapsed(offset: 3),
      );
      final readOnly = ValueNotifier(false);
      final revision = ValueNotifier(0);
      addTearDown(controller.dispose);
      addTearDown(readOnly.dispose);
      addTearDown(revision.dispose);
      await _mountSurface(
        tester,
        controller: controller,
        scrollState: MemoEditorScrollState(),
        readOnly: readOnly,
        revision: revision,
      );
      final rawState = tester.state<QuillRawEditorState>(
        find.byType(QuillRawEditor),
      );

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '标题\n新增正文输入验证\n',
          selection: TextSelection.collapsed(offset: 5),
          composing: TextRange(start: 3, end: 5),
        ),
      );
      expect(controller.document.toPlainText(), '标题\n新增正文输入验证\n');
      expect(rawState.dirty, isTrue);
      // 输入已到达文档但尚未绘制，分别覆盖主动保存与聚焦页面直接退出。
      if (directlyUnmount) {
        await tester.pumpWidget(const SizedBox.shrink());
      } else {
        FocusScope.of(tester.element(find.byType(QuillEditor))).unfocus();
        readOnly.value = true;
        await tester.pump();
        expect(_editor(tester).controller.readOnly, isTrue);
      }

      // 覆盖焦点的下一帧回调，以及依赖中等待键盘出现的延迟回调。
      await tester.pump(const Duration(milliseconds: 500));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump(const Duration(milliseconds: 500));
      expect(rawState.mounted, isFalse);
      expect(binding.editorObservers, isEmpty);
      expect(tester.testTextInput.hasAnyClients, isFalse);
      expect(tester.takeException(), isNull);
      expect(controller.document.toPlainText(), '标题\n新增正文输入验证\n');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.view.resetViewInsets();
    }
  });
}
