import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_number_keypad.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction_amount_keypad.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/press_key.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../helpers/test_isolation.dart';

/// 使用真实业务键盘和手机宽度，检查公共布局中的实际触摸区域。
Future<void> _open(
  WidgetTester tester,
  Widget keypad, {
  double width = 320,
  double height = 220,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: width, height: height, child: keypad),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 从按键内部的文字或图标定位整块可点击区域。
Finder _keyFor(Finder content) =>
    find.ancestor(of: content, matching: find.byType(PressKey)).first;

/// 点击右侧中部的边缘留白，验证圆角内可见按键区域的实际响应。
Future<void> _tapEdge(WidgetTester tester, Finder key) async {
  final rect = tester.getRect(key);
  await tester.tapAt(Offset(rect.right - 1, rect.center.dy));
  await tester.pumpAndSettle();
}

/// 验证公共布局保持两个业务键盘各自的顺序、禁用规则和提交时机。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  for (final size in [(320.0, 220.0), (390.0, 280.0)]) {
    testWidgets('训练数字与操作边缘可点，小数点禁用且底行顺序保持 ${size.$1}', (tester) async {
      final input = <String>[];
      final actions = <int>[];
      var deleted = 0;
      var submitted = 0;
      await _open(
        tester,
        FitnessNumberKeypad(
          onAppend: input.add,
          onSubmit: () => submitted++,
          onBackspace: () => deleted++,
          onClear: () {},
          allowDecimal: false,
          actions: [
            for (var index = 0; index < 4; index++)
              (
                label: ['加组', '向上填', '向下填', '下一项'][index],
                subtitle: null,
                onPressed: () => actions.add(index),
              ),
          ],
        ),
        width: size.$1,
        height: size.$2,
      );
      final decimal = _keyFor(find.text('.'));
      final zero = _keyFor(find.text('0'));
      final backspace = _keyFor(find.byIcon(AppIcons.backspace));
      final done = _keyFor(find.byIcon(AppIcons.keyboardReturn));
      final keys = [decimal, zero, backspace, done];
      for (var index = 1; index < keys.length; index++) {
        expect(
          tester.getRect(keys[index]).left,
          greaterThan(tester.getRect(keys[index - 1]).right),
        );
      }
      await _tapEdge(tester, _keyFor(find.text('1')));
      await _tapEdge(tester, _keyFor(find.text('9')));
      await _tapEdge(tester, decimal);
      await _tapEdge(tester, zero);
      await _tapEdge(tester, backspace);
      await _tapEdge(tester, done);
      await _tapEdge(tester, _keyFor(find.text('下一项')));
      expect(input, ['1', '9', '0']);
      expect(deleted, 1);
      expect(submitted, 1);
      expect(actions, [3]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('记账底行保留日期、零、小数点和完成，边缘点击回传原业务动作', (tester) async {
    final input = <String>[];
    final operators = <String>[];
    var pickedDate = 0;
    var submitted = 0;
    await _open(
      tester,
      TransactionAmountKeypad(
        date: DateTime(2026, 11, 6, 12, 30),
        calculating: false,
        isDoneEnabled: true,
        onAppend: input.add,
        onOperator: operators.add,
        onEquals: () {},
        onPickDate: () => pickedDate++,
        onSubmit: () => submitted++,
        onRollback: () {},
      ),
    );
    final keys = [
      find.byKey(const ValueKey('editor_date')),
      find.byKey(const ValueKey('transaction_digit_0')),
      find.byKey(const ValueKey('transaction_digit_dot')),
      find.byKey(const ValueKey('transaction_done')),
    ];
    for (var index = 1; index < keys.length; index++) {
      expect(
        tester.getRect(keys[index]).left,
        greaterThan(tester.getRect(keys[index - 1]).right),
      );
    }
    await _tapEdge(tester, find.byKey(const ValueKey('transaction_digit_1')));
    await _tapEdge(tester, find.byKey(const ValueKey('transaction_digit_9')));
    for (final key in keys) {
      await _tapEdge(tester, key);
    }
    await _tapEdge(
      tester,
      find.byKey(const ValueKey('transaction_operator_divide')),
    );
    expect(input, ['1', '9', '0', '.']);
    expect(operators, ['÷']);
    expect(pickedDate, 1);
    expect(submitted, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('等号按下后切换完成状态，同一次手势松手不会误保存', (tester) async {
    var calculating = true;
    var calculated = 0;
    var submitted = 0;
    await _open(
      tester,
      StatefulBuilder(
        builder: (context, setState) => TransactionAmountKeypad(
          date: DateTime(2026, 11, 6),
          calculating: calculating,
          isDoneEnabled: true,
          onAppend: (_) {},
          onOperator: (_) {},
          onEquals: () {
            calculated++;
            setState(() => calculating = false);
          },
          onPickDate: () {},
          onSubmit: () => submitted++,
          onRollback: () {},
        ),
      ),
    );
    final done = find.byKey(const ValueKey('transaction_done'));
    final gesture = await tester.startGesture(tester.getCenter(done));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(calculated, 1);
    expect(find.text('='), findsNothing);
    expect(submitted, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(submitted, 0);
    await _tapEdge(tester, done);
    expect(submitted, 1);
    expect(tester.takeException(), isNull);
  });
}
