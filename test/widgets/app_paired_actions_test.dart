import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';

import '../helpers/test_isolation.dart';

const _primaryKey = ValueKey('paired-primary');
const _secondaryKey = ValueKey('paired-secondary');

/// 从公共包装中定位原生按钮，检查实际点击区域而非外层占位。
Finder _button(Key key) => find.descendant(
  of: find.byKey(key),
  matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  matchRoot: true,
);

/// 使用项目主题和手机视口，模拟主次操作在长文案与字号变化下的真实布局。
Future<void> _open(
  WidgetTester tester, {
  required double width,
  required double scale,
  required VoidCallback onPrimary,
  required VoidCallback onSecondary,
  bool busy = false,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppDimens.p16),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AppPairedActions(
              primaryLabel: '下一步：确认创建',
              onPrimaryPressed: onPrimary,
              secondaryLabel: '上一步',
              onSecondaryPressed: onSecondary,
              primaryButtonKey: _primaryKey,
              secondaryButtonKey: _secondaryKey,
              busy: busy,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// 验证手机布局中的等大操作区域及提交期间的交互保护。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  for (final layout in [(390.0, 1.0), (320.0, 1.3)]) {
    testWidgets('主次操作尺寸一致且内边缘可以点击 ${layout.$1}/${layout.$2}', (tester) async {
      var primaryPressed = 0;
      var secondaryPressed = 0;
      await _open(
        tester,
        width: layout.$1,
        scale: layout.$2,
        onPrimary: () => primaryPressed++,
        onSecondary: () => secondaryPressed++,
      );
      final primary = _button(_primaryKey);
      final secondary = _button(_secondaryKey);
      expect(primary, findsOneWidget);
      expect(secondary, findsOneWidget);
      final first = tester.getRect(primary);
      final second = tester.getRect(secondary);
      expect(first.width, closeTo(second.width, 0.01));
      expect(first.height, closeTo(second.height, 0.01));
      expect(
        first.height,
        greaterThanOrEqualTo(AppDimens.actionButtonMinHeight),
      );
      expect(first.left, greaterThanOrEqualTo(0));
      expect(first.right, lessThanOrEqualTo(layout.$1));
      expect(second.left, greaterThanOrEqualTo(0));
      expect(second.right, lessThanOrEqualTo(layout.$1));
      await tester.tapAt(Offset(first.right - AppDimens.p4, first.center.dy));
      await tester.tapAt(Offset(second.left + AppDimens.p4, second.center.dy));
      expect(primaryPressed, 1);
      expect(secondaryPressed, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('忙碌状态同时禁用两个操作，防止重复提交和提前返回', (tester) async {
    var calls = 0;
    await _open(
      tester,
      width: 320,
      scale: 1.3,
      busy: true,
      onPrimary: () => calls++,
      onSecondary: () => calls++,
    );
    final primary = _button(_primaryKey);
    final secondary = _button(_secondaryKey);
    expect(tester.widget<ButtonStyleButton>(primary).onPressed, isNull);
    expect(tester.widget<ButtonStyleButton>(secondary).onPressed, isNull);
    await tester.tap(primary);
    await tester.tap(secondary);
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });
}
