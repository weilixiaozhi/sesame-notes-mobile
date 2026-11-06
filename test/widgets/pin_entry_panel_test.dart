import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/widgets/pin_entry_pad.dart';
import 'package:sesame_notes/shared/widgets/pin_input_controller.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../helpers/test_isolation.dart';

/// 使用手机视口检查公共 PIN 面板实际输入与操作入口。
Future<void> _open(WidgetTester tester, Widget panel) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(body: SafeArea(child: panel)),
    ),
  );
  await tester.pumpAndSettle();
}

/// 通过可见数字输入，确认布局复用没有改变提交与删除动作。
Future<void> _digit(WidgetTester tester, String digit) async {
  await tester.tap(find.text(digit));
  await tester.pumpAndSettle();
}

/// 验证共享面板的输入互斥及生物识别可用性变化。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  testWidgets('删除与完整 PIN 提交仍沿用控制器，等待期间连点不重复提交', (tester) async {
    final controller = PinInputController();
    addTearDown(controller.dispose);
    final submissions = <String>[];
    await _open(
      tester,
      PinEntryPanel(
        title: '输入 PIN',
        controller: controller,
        onNumberTap: (digit) {
          final completed = controller.addDigit(digit);
          if (completed != null) submissions.add(completed);
        },
      ),
    );

    await _digit(tester, '1');
    await _digit(tester, '2');
    await tester.tap(find.byIcon(AppIcons.backspace));
    await tester.pumpAndSettle();
    expect(controller.length, 1);
    for (final digit in ['3', '4', '5']) {
      await _digit(tester, digit);
    }
    expect(submissions, ['1345']);
    expect(controller.length, 0);
    await _digit(tester, '6');
    await tester.tap(find.byIcon(AppIcons.backspace));
    await tester.pumpAndSettle();
    expect(submissions, ['1345']);
    expect(controller.length, 0);
    controller.finishSubmission();
    await _digit(tester, '7');
    expect(controller.length, 1);
    expect(find.byIcon(AppIcons.fingerprint), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('生物识别入口随可用性变化，更新标题时保留已输入草稿', (tester) async {
    final controller = PinInputController();
    addTearDown(controller.dispose);
    var biometricAvailable = true;
    var biometricCalls = 0;
    late StateSetter update;
    await _open(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return PinEntryPanel(
            title: biometricAvailable ? '输入 PIN' : '再次输入 PIN',
            controller: controller,
            leading: const Icon(AppIcons.lock, size: AppDimens.authLogoSize),
            onNumberTap: controller.addDigit,
            onBiometric: biometricAvailable ? () => biometricCalls++ : null,
          );
        },
      ),
    );
    await _digit(tester, '1');
    await tester.tap(find.byIcon(AppIcons.fingerprint));
    await tester.pumpAndSettle();
    expect(biometricCalls, 1);
    expect(controller.length, 1);

    update(() => biometricAvailable = false);
    await tester.pumpAndSettle();
    expect(find.byIcon(AppIcons.fingerprint), findsNothing);
    expect(find.text('再次输入 PIN'), findsOneWidget);
    await _digit(tester, '2');
    expect(controller.length, 2);
    expect(biometricCalls, 1);
    expect(tester.takeException(), isNull);
  });
}
