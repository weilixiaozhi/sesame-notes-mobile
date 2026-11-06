import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/memo_editor_page.dart';
import 'package:sesame_notes/features/memos/presentation/memo_editor_surface.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../helpers/test_isolation.dart';

/// 保存替身只收集页面生成的快照，不读取真实数据库或账号配置。
class _MemoActions extends Fake implements MemoActions {
  final saved = <MemoEntry>[];
  final attempts = <MemoEntry>[];
  Future<void> Function(MemoEntry)? beforeSave;
  var failuresRemaining = 0;
  var activeWrites = 0;
  var maxActiveWrites = 0;

  /// 控制写入延迟与失败，区分已请求的快照和真正完成保存的快照。
  @override
  Future<void> saveEntry(MemoEntry entry, PrivateBookTarget target) async {
    attempts.add(entry);
    activeWrites++;
    if (activeWrites > maxActiveWrites) maxActiveWrites = activeWrites;
    try {
      await beforeSave?.call(entry);
      if (failuresRemaining > 0) {
        failuresRemaining--;
        throw StateError('MEMO_TEST_SAVE_FAILURE');
      }
      saved.add(entry);
    } finally {
      activeWrites--;
    }
  }
}

/// 用真实路由和本地身份打开笔记，测试覆盖编辑器与输入法的实际连接。
Future<_MemoActions> _openEditor(
  WidgetTester tester, {
  int additionalLines = 0,
  bool newNote = false,
  bool withBackStack = false,
  _MemoActions? actions,
}) async {
  try {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    actions ??= _MemoActions();
    final analytics = ProductAnalyticsController(
      writer: () async => throw StateError('测试不应发送统计'),
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity(null, 0),
        enabled: false,
      ),
    );
    addTearDown(analytics.dispose);
    final now = DateTime.utc(2026, 11, 6);
    final entry = MemoEntry(
      id: '33333333-3333-4333-8333-333333333333',
      memoBookId: '11111111-1111-4111-8111-111111111111',
      bookType: 'normal',
      title: '编辑检查',
      createdAt: now,
      updatedAt: now,
      bodyJson: jsonEncode({
        'ops': [
          {
            'insert':
                '编辑检查\n第一行正文用于点击定位\n第二行正文用于输入\n'
                '${List.generate(additionalLines, (index) => '正文第${index + 3}行继续记录').join('\n')}'
                '${additionalLines > 0 ? '\n' : ''}',
          },
        ],
      }),
    );
    final router = GoRouter(
      initialLocation: withBackStack ? '/list' : '/',
      routes: [
        GoRoute(
          path: '/list',
          builder: (context, state) => const Scaffold(body: Text('测试笔记列表')),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => MemoEditorPage(
            book: MemoBook(
              id: entry.memoBookId,
              name: '笔记本',
              type: 'normal',
              createdAt: now,
              updatedAt: now,
            ),
            target: (
              bookId: entry.memoBookId,
              accountId: null,
              syncId: null,
              generation: 0,
            ),
            entryId: entry.id,
            entry: newNote ? null : entry,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memoActionsProvider.overrideWithValue(actions),
          productAnalyticsControllerProvider.overrideWithValue(analytics),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (withBackStack) {
      unawaited(router.push<void>('/'));
      await tester.pumpAndSettle();
    }
    return actions;
  } catch (error, stackTrace) {
    debugPrint('备忘录页面测试初始化失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 读取当前页面真实持有的编辑器，避免操作复制出来的控制器状态。
QuillEditor _editor(WidgetTester tester) =>
    tester.widget<QuillEditor>(find.byType(QuillEditor));

/// 通过真实输入通道提交正文和组合区，等待文档事件进入自动保存链路。
Future<void> _typeText(
  WidgetTester tester,
  String text, {
  TextRange composing = TextRange.empty,
}) async {
  tester.testTextInput.updateEditingValue(
    TextEditingValue(
      text: '$text\n',
      selection: TextSelection.collapsed(offset: text.length),
      composing: composing,
    ),
  );
  await tester.pump();
}

/// 还原测试使用的纯文本 Delta，检查保存的是完整最新内容。
String _savedText(MemoEntry entry) {
  final body = jsonDecode(entry.bodyJson!) as Map<String, dynamic>;
  return (body['ops'] as List)
      .map((operation) => (operation as Map)['insert'] as String)
      .join();
}

/// 点击正文第二行，验证模式切换保留用户点击位置而非重置到文首。
Future<void> _enterEditing(WidgetTester tester) async {
  final topLeft = tester.getTopLeft(find.byType(QuillEditor));
  tester.testTextInput.log.clear();
  await tester.tapAt(topLeft + const Offset(70, 48));
  expect(
    tester.testTextInput.hasAnyClients,
    isFalse,
    reason: '正文和工具栏尚未完成编辑布局时，不创建输入连接',
  );
  expect(
    tester.testTextInput.log.where(
      (call) =>
          call.method == 'TextInput.show' ||
          call.method == 'TextInput.setClient',
    ),
    isEmpty,
    reason: '只读编辑器的点击回调不向系统提前请求键盘',
  );
  await tester.pump();
  expect(
    tester.widget<QuillRawEditor>(find.byType(QuillRawEditor)).config.readOnly,
    isFalse,
  );
  await tester.pumpAndSettle();
}

/// 提取实际渲染的输入法组合下划线，不用控制器内部值代替界面反馈。
List<String> _composingText(WidgetTester tester) {
  final result = <String>[];
  final richText = find.descendant(
    of: find.byType(QuillEditor),
    matching: find.byType(RichText),
  );
  for (final widget in tester.widgetList<RichText>(richText)) {
    widget.text.visitChildren((span) {
      if (span is TextSpan &&
          (span.style?.decoration?.contains(TextDecoration.underline) ??
              false)) {
        result.add(span.text ?? '');
      }
      return true;
    });
  }
  return result;
}

/// 覆盖只读切编辑、键盘视口变化，以及保存后的再次编辑。
void main() {
  setUp(resetGlobalTestState);

  testWidgets('连续正文输入复用编辑器外壳，工具栏和页头独立更新', (tester) async {
    try {
      final actions = await _openEditor(tester);
      await _enterEditing(tester);
      final surface = tester.widget<MemoEditorSurface>(
        find.byType(MemoEditorSurface),
      );
      for (var index = 0; index < 20; index++) {
        await _typeText(tester, '编辑检查\n连续正文输入$index');
        expect(
          tester.widget<MemoEditorSurface>(find.byType(MemoEditorSurface)),
          same(surface),
          reason: '正文输入应由Quill自身监听，不能逐字重建页面外壳',
        );
      }
      final controller = _editor(tester).controller;
      final typed = controller.document.toPlainText();
      final undo = find.widgetWithIcon(IconButton, AppIcons.undo);
      final redo = find.widgetWithIcon(IconButton, AppIcons.redo);
      expect(tester.widget<IconButton>(undo).onPressed, isNotNull);
      await tester.tap(undo);
      await tester.pump();
      expect(controller.document.toPlainText(), isNot(typed));
      expect(tester.widget<IconButton>(redo).onPressed, isNotNull);
      await tester.tap(redo);
      await tester.pump();
      expect(controller.document.toPlainText(), typed);

      final bold = find.byWidgetPredicate(
        (widget) =>
            widget is QuillToolbarToggleStyleButton &&
            widget.attribute == Attribute.bold,
      );
      controller.updateSelection(
        const TextSelection(baseOffset: 5, extentOffset: 8),
        ChangeSource.local,
      );
      await tester.pump();
      expect(
        tester.state<QuillToolbarToggleStyleButtonState>(bold).currentValue,
        isFalse,
      );
      await tester.tap(bold);
      await tester.pump();
      expect(
        tester.state<QuillToolbarToggleStyleButtonState>(bold).currentValue,
        isTrue,
      );
      controller.updateSelection(
        const TextSelection.collapsed(offset: 0),
        ChangeSource.local,
      );
      await tester.pump();
      expect(
        tester.state<QuillToolbarToggleStyleButtonState>(bold).currentValue,
        isFalse,
        reason: '选区变化应更新格式按钮，无需页面整体重建',
      );
      expect(
        tester.widget<MemoEditorSurface>(find.byType(MemoEditorSurface)),
        same(surface),
      );
      controller.replaceText(
        0,
        4,
        '新标题',
        const TextSelection.collapsed(offset: 3),
      );
      await tester.pump();
      expect(
        tester.widget<PrimaryHeader>(find.byType(PrimaryHeader)).title,
        '新标题',
      );
      await tester.pump(const Duration(milliseconds: 450));
      expect(actions.saved, isNotEmpty);
      expect(_savedText(actions.saved.last), controller.document.toPlainText());
    } catch (error, stackTrace) {
      debugPrint('备忘输入局部刷新回归失败：$error\n$stackTrace');
      rethrow;
    }
  });

  testWidgets('点击正文进入编辑保留选区，保存后可以再次连接键盘输入', (tester) async {
    final actions = await _openEditor(tester);
    expect(_editor(tester).controller.readOnly, isTrue);
    expect(tester.testTextInput.hasAnyClients, isFalse);

    tester.testTextInput.log.clear();
    await _enterEditing(tester);
    expect(_editor(tester).controller.readOnly, isFalse);
    expect(_editor(tester).focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue);
    expect(_editor(tester).controller.selection.baseOffset, greaterThan(5));
    final connections = tester.testTextInput.log.where(
      (call) => call.method == 'TextInput.setClient',
    );
    expect(connections, hasLength(1));

    final selection = _editor(tester).controller.selection;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(_editor(tester).controller.selection, selection);
    expect(tester.getBottomLeft(find.byType(QuillEditor)).dy, lessThan(544));

    await tester.tap(find.byType(HeaderTextAction));
    await tester.pump();
    await tester.pump();
    expect(_editor(tester).controller.readOnly, isTrue);
    expect(actions.saved, hasLength(1));
    expect(tester.testTextInput.hasAnyClients, isFalse);

    await tester.pump(const Duration(milliseconds: 350));
    await _enterEditing(tester);
    expect(tester.testTextInput.hasAnyClients, isTrue);
    expect(_editor(tester).controller.readOnly, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('切入编辑后仅更新输入法组合范围也会刷新正文下划线', (tester) async {
    await _openEditor(tester);
    await _enterEditing(tester);
    final raw = tester.state<QuillRawEditorState>(find.byType(QuillRawEditor));
    final value = raw.currentTextEditingValue!;
    expect(_composingText(tester), isEmpty);

    // Android 输入法可以单独提交组合范围，正文和选区保持原值。
    tester.testTextInput.updateEditingValue(
      value.copyWith(composing: const TextRange(start: 5, end: 8)),
    );
    await tester.pump();
    expect(_composingText(tester), contains('第一行'));

    tester.testTextInput.updateEditingValue(
      value.copyWith(composing: TextRange.empty),
    );
    await tester.pump();
    expect(_composingText(tester), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('长文滚动后切换编辑和保存保持正文、选区及可视位置', (tester) async {
    final actions = await _openEditor(tester, additionalLines: 80);
    final controller = _editor(tester).controller;
    final document = controller.document;
    final originalText = document.toPlainText();
    final scroll = _editor(tester).scrollController;
    scroll.jumpTo(400);
    await tester.pump();
    final position = scroll.offset;

    await _enterEditing(tester);
    expect(_editor(tester).controller, same(controller));
    expect(controller.document, same(document));
    expect(_editor(tester).scrollController.offset, closeTo(position, 1));
    expect(controller.selection.baseOffset, greaterThan(100));

    final originalSelection = controller.selection;
    final value = controller.plainTextEditingValue;
    const inserted = '新内容';
    final offset = value.selection.baseOffset;
    final edited = value.text.replaceRange(offset, offset, inserted);
    tester.testTextInput.updateEditingValue(
      value.copyWith(
        text: edited,
        selection: TextSelection.collapsed(offset: offset + inserted.length),
      ),
    );
    await tester.pump();
    expect(document.toPlainText(), edited);
    expect(document.toPlainText(), isNot(originalText));
    expect(controller.selection.baseOffset, originalSelection.baseOffset + 3);

    final savedPosition = _editor(tester).scrollController.offset;
    await tester.tap(find.byType(HeaderTextAction));
    await tester.pump();
    await tester.pump();
    expect(controller.readOnly, isTrue);
    expect(_editor(tester).scrollController.offset, closeTo(savedPosition, 1));
    expect(actions.saved, hasLength(1));
    expect(actions.saved.single.bodyJson, contains(inserted));
    expect(document.toPlainText(), edited);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('新建笔记自动进入编辑并接收首次输入，保存后保留完整正文', (tester) async {
    final actions = await _openEditor(tester, newNote: true);
    final editor = _editor(tester);
    expect(editor.controller.readOnly, isFalse);
    expect(editor.focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.hasAnyClients, isTrue);
    expect(actions.saved, isEmpty);

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '新笔记\n',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    await tester.pump();
    expect(editor.controller.document.toPlainText(), '新笔记\n');
    await tester.tap(find.byType(HeaderTextAction));
    await tester.pumpAndSettle();
    expect(_editor(tester).controller.readOnly, isTrue);
    expect(actions.saved, hasLength(1));
    expect(actions.saved.single.title, '新笔记');
    expect(actions.saved.single.bodyJson, contains('新笔记'));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('连续中文输入防抖只保存最新正文，自动保存不打断组合输入', (tester) async {
    final actions = await _openEditor(tester, newNote: true);
    final surface = tester.state(find.byType(MemoEditorSurface));
    final raw = tester.state<QuillRawEditorState>(find.byType(QuillRawEditor));
    final focus = _editor(tester).focusNode;
    tester.testTextInput.log.clear();

    await _typeText(tester, '备');
    await tester.pump(const Duration(milliseconds: 250));
    await _typeText(tester, '备忘');
    await tester.pump(const Duration(milliseconds: 250));
    await _typeText(
      tester,
      '备忘录',
      composing: const TextRange(start: 0, end: 3),
    );
    await tester.pump(const Duration(milliseconds: 399));
    expect(actions.attempts, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(actions.saved.map(_savedText), ['备忘录\n']);
    expect(tester.state(find.byType(MemoEditorSurface)), same(surface));
    expect(tester.state(find.byType(QuillRawEditor)), same(raw));
    expect(_editor(tester).focusNode, same(focus));
    expect(focus.hasFocus, isTrue);
    expect(raw.currentTextEditingValue!.selection.baseOffset, 3);
    expect(
      raw.currentTextEditingValue!.composing,
      const TextRange(start: 0, end: 3),
    );
    expect(_composingText(tester), contains('备忘录'));
    expect(
      tester.testTextInput.log.where(
        (call) =>
            call.method == 'TextInput.setClient' ||
            call.method == 'TextInput.clearClient',
      ),
      isEmpty,
    );

    // 提交组合区只改变输入法状态，不重复保存没有变化的正文。
    await _typeText(tester, '备忘录');
    await tester.pump(const Duration(milliseconds: 500));
    expect(actions.attempts, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('自动保存中继续输入串行保存最新版本，不重置光标或输入连接', (tester) async {
    final firstWrite = Completer<void>();
    final actions = _MemoActions();
    actions.beforeSave = (_) async {
      if (actions.attempts.length == 1) await firstWrite.future;
    };
    await _openEditor(tester, newNote: true, actions: actions);
    final raw = tester.state<QuillRawEditorState>(find.byType(QuillRawEditor));
    tester.testTextInput.log.clear();

    await _typeText(tester, '第一版');
    await tester.pump(const Duration(milliseconds: 400));
    expect(actions.attempts.map(_savedText), ['第一版\n']);
    expect(actions.saved, isEmpty);
    await _typeText(tester, '第一版继续输入');
    await tester.pump(const Duration(milliseconds: 400));
    expect(actions.attempts, hasLength(1));

    firstWrite.complete();
    await tester.pump();
    await tester.pump();
    expect(actions.saved.map(_savedText), ['第一版\n', '第一版继续输入\n']);
    expect(actions.maxActiveWrites, 1);
    expect(tester.state(find.byType(QuillRawEditor)), same(raw));
    expect(_editor(tester).controller.selection.baseOffset, 7);
    expect(_editor(tester).controller.readOnly, isFalse);
    expect(_editor(tester).focusNode.hasFocus, isTrue);
    expect(
      tester.testTextInput.log.where(
        (call) =>
            call.method == 'TextInput.setClient' ||
            call.method == 'TextInput.clearClient',
      ),
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('自动保存失败保留草稿与编辑状态，继续输入后重试最新版本', (tester) async {
    final actions = _MemoActions()..failuresRemaining = 1;
    await _openEditor(tester, newNote: true, actions: actions);
    final surface = tester.state(find.byType(MemoEditorSurface));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MemoEditorPage)),
      listen: false,
    );
    await _typeText(tester, '保存失败也要保留');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    final l = AppLocalizations.of(tester.element(find.byType(MemoEditorPage)));
    expect(find.text(l.memoSaveFailed), findsOneWidget);
    expect(actions.saved, isEmpty);
    expect(container.read(memoProtectedDraftsProvider).values.map(_savedText), [
      '保存失败也要保留\n',
    ]);
    expect(tester.state(find.byType(MemoEditorSurface)), same(surface));
    expect(_editor(tester).controller.readOnly, isFalse);
    expect(_editor(tester).focusNode.hasFocus, isTrue);
    await tester.pump(const Duration(seconds: 1));
    expect(actions.attempts, hasLength(1));

    await _typeText(tester, '保存失败也要保留，继续写');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(actions.saved.map(_savedText), ['保存失败也要保留，继续写\n']);
    expect(actions.attempts, hasLength(2));
    expect(container.read(memoProtectedDraftsProvider), isEmpty);
    expect(find.text(l.memoSaveFailed), findsNothing);
    expect(tester.state(find.byType(MemoEditorSurface)), same(surface));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('切到后台和返回列表会立即保存尚未到防抖期限的最新正文', (tester) async {
    final actions = await _openEditor(
      tester,
      newNote: true,
      withBackStack: true,
    );
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    await _typeText(tester, '后台前输入');
    await tester.pump(const Duration(milliseconds: 100));
    expect(actions.saved, isEmpty);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(actions.saved.map(_savedText), ['后台前输入\n']);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    await _typeText(tester, '返回前继续输入');
    await tester.pump(const Duration(milliseconds: 100));
    expect(actions.saved, hasLength(1));
    final tooltip = MaterialLocalizations.of(
      tester.element(find.byType(MemoEditorPage)),
    ).backButtonTooltip;
    await tester.tap(
      find.descendant(
        of: find.byType(PrimaryHeader),
        matching: find.byTooltip(tooltip),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MemoEditorPage), findsNothing);
    expect(find.text('测试笔记列表'), findsOneWidget);
    expect(actions.saved.map(_savedText), ['后台前输入\n', '返回前继续输入\n']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
