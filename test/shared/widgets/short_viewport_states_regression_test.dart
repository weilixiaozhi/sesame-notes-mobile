import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/theme/app_theme.dart';

const _viewportKey = ValueKey('短屏状态区域');
const _longMessage =
    '当前暂时无法读取此页面的数据，请检查网络连接后再次尝试，'
    '也可以稍后重新打开此页面继续完成操作。';

/// 在实际页面中保留狭小状态区域，模拟标题和表单占用后的剩余空间。
Future<void> _pumpState(
  WidgetTester tester, {
  required Widget child,
  required double scale,
  double height = 120,
}) async {
  tester.view.physicalSize = const Size(320, 480);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, page) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: page!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            key: _viewportKey,
            width: double.infinity,
            height: height,
            child: child,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 真实上滑内容以显示操作入口，避免仅用程序定位掩盖不可滚动的问题。
Future<void> _revealAction(WidgetTester tester, Finder action) async {
  for (var attempt = 0; attempt < 12; attempt++) {
    if (action.hitTestable().evaluate().isNotEmpty) return;
    await tester.drag(find.byKey(_viewportKey), const Offset(0, -80));
    await tester.pumpAndSettle();
  }
  expect(action.hitTestable(), findsOneWidget, reason: '状态内容必须能够滚动到操作入口');
}

/// 短视口和大字号不能隐藏重试或空态操作，也不能拦截空列表的下拉刷新。
void main() {
  for (final scale in [1.6, 2.0]) {
    for (final scrollable in [false, true]) {
      testWidgets('字号=$scale，可刷新列表=$scrollable：短屏错误提示能滚动并重试一次', (tester) async {
        var retries = 0;
        try {
          await _pumpState(
            tester,
            scale: scale,
            child: AppLoadError(
              message: _longMessage,
              scrollable: scrollable,
              onRetry: () => retries++,
            ),
          );
          expect(tester.takeException(), isNull, reason: '长错误文案不能挤出短屏状态区域');
          expect(find.text(_longMessage), findsOneWidget);
          final retry = find.text('重试');
          await _revealAction(tester, retry);
          await tester.tap(retry);
          await tester.pumpAndSettle();
          expect(retries, 1, reason: '一次重试点击只能调用一次业务回调');
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint('短屏错误态回归失败：字号=$scale，可刷新列表=$scrollable，$error');
          debugPrintStack(stackTrace: stack);
          rethrow;
        }
      });
    }

    testWidgets('字号=$scale：短屏空态能滚动到原有操作入口', (tester) async {
      var actions = 0;
      try {
        await _pumpState(
          tester,
          scale: scale,
          child: AppEmpty(
            text: '这里暂时还没有记录',
            subtext: _longMessage,
            action: TextButton(
              onPressed: () => actions++,
              child: const Text('添加记录'),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '空态说明和操作不能超出短屏状态区域');
        final action = find.text('添加记录');
        await _revealAction(tester, action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(actions, 1);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('短屏空态回归失败：字号=$scale，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });
  }

  testWidgets('常规高度下简短空态仍在可视区域垂直居中', (tester) async {
    try {
      await _pumpState(
        tester,
        scale: 1.6,
        height: 320,
        child: const AppEmpty(text: '暂无记录'),
      );
      final viewport = tester.getRect(find.byKey(_viewportKey));
      final message = tester.getRect(find.text('暂无记录'));
      expect(message.center.dy, closeTo(viewport.center.dy, 1));
      expect(message.center.dx, closeTo(viewport.center.dx, 1));
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('常规空态居中回归失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });

  testWidgets('短屏空列表仍可通过外层下拉刷新', (tester) async {
    var refreshes = 0;
    try {
      await _pumpState(
        tester,
        scale: 1.6,
        child: RefreshIndicator(
          onRefresh: () async {
            refreshes++;
          },
          child: const ScrollableEmpty(child: AppEmpty(text: '暂无记录')),
        ),
      );
      expect(tester.takeException(), isNull);
      final viewport = tester.getRect(find.byKey(_viewportKey));
      final gesture = await tester.startGesture(
        Offset(viewport.center.dx, viewport.top + 10),
      );
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(refreshes, 1, reason: '空态适应短屏后仍须保留外层下拉刷新手势');
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('短屏空列表下拉刷新回归失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });
}
