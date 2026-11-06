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
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/theme/app_theme.dart';

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

/// 用本地身份挂载自动保存持有者，保存操作由可控替身收集。
Future<_MemoActions> _openEditor(
  WidgetTester tester, {
  bool withBackStack = false,
  _MemoActions? actions,
}) async {
  try {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    const bookId = '11111111-1111-4111-8111-111111111111';
    const entryId = '33333333-3333-4333-8333-333333333333';
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
              id: bookId,
              name: '笔记本',
              type: 'normal',
              createdAt: now,
              updatedAt: now,
            ),
            target: (
              bookId: bookId,
              accountId: null,
              syncId: null,
              generation: 0,
            ),
            entryId: entryId,
            entry: null,
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

/// 覆盖自动保存防抖、串行写入、失败草稿保护和退出前保存。
void main() {
  setUp(resetGlobalTestState);

  testWidgets('连续正文变更防抖只保存最新内容，组合区提交不重复保存', (tester) async {
    final actions = await _openEditor(tester);

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

    // 提交组合区只改变输入法状态，不重复保存没有变化的正文。
    await _typeText(tester, '备忘录');
    await tester.pump(const Duration(milliseconds: 500));
    expect(actions.attempts, hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('自动保存中继续输入串行保存最新版本', (tester) async {
    final firstWrite = Completer<void>();
    final actions = _MemoActions();
    actions.beforeSave = (_) async {
      if (actions.attempts.length == 1) await firstWrite.future;
    };
    await _openEditor(tester, actions: actions);

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
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('自动保存失败保护草稿，继续输入后重试最新版本', (tester) async {
    final actions = _MemoActions()..failuresRemaining = 1;
    await _openEditor(tester, actions: actions);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MemoEditorPage)),
      listen: false,
    );
    await _typeText(tester, '保存失败也要保留');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(actions.saved, isEmpty);
    expect(container.read(memoProtectedDraftsProvider).values.map(_savedText), [
      '保存失败也要保留\n',
    ]);
    await tester.pump(const Duration(seconds: 1));
    expect(actions.attempts, hasLength(1));

    await _typeText(tester, '保存失败也要保留，继续写');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(actions.saved.map(_savedText), ['保存失败也要保留，继续写\n']);
    expect(actions.attempts, hasLength(2));
    expect(container.read(memoProtectedDraftsProvider), isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('切到后台和返回列表会立即保存尚未到防抖期限的最新正文', (tester) async {
    final actions = await _openEditor(tester, withBackStack: true);
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
    expect(actions.saved.map(_savedText), ['后台前输入\n', '返回前继续输入\n']);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
