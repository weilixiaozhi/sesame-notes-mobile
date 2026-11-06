import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/auth/presentation/auth_fields.dart';
import 'package:sesame_notes/features/auth/presentation/login_page.dart';
import 'package:sesame_notes/features/auth/presentation/register_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';

import '../../helpers/test_isolation.dart';

/// 在手机和宽屏视口中打开实际认证页面，并放大系统文字。
Future<void> _open(
  WidgetTester tester, {
  required double width,
  required bool register,
}) async {
  tester.view.physicalSize = Size(width, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.3)),
          child: child!,
        ),
        home: register ? const RegisterPage() : const AuthPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 验证共用外框的可达性，以及字段重建和选择弹层不会丢失草稿。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  for (final register in [false, true]) {
    for (final width in [320.0, 800.0]) {
      testWidgets('${register ? '注册' : '登录'}在$width宽度和键盘弹出后仍可输入及校验', (
        tester,
      ) async {
        await _open(tester, width: width, register: register);
        final phone = find.descendant(
          of: find.byType(AuthPhoneField),
          matching: find.byType(TextField),
        );
        final passwordGroup = find.byType(AuthPasswordField).first;
        final password = find.descendant(
          of: passwordGroup,
          matching: find.byType(TextField),
        );
        final l10n = AppLocalizations.of(tester.element(phone));
        expect(find.text(l10n.authPhone), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(register ? 3 : 2));
        expect(
          tester.getSize(phone).width,
          closeTo(
            width == 320
                ? width - 2 * AppDimens.p20
                : AppDimens.authFormMaxWidth,
            0.01,
          ),
        );

        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.ensureVisible(password);
        await tester.pumpAndSettle();
        await tester.enterText(password, 'secret123');
        await tester.pumpAndSettle();
        final showPassword = find.descendant(
          of: passwordGroup,
          matching: find.text(l10n.authPasswordShow),
        );
        await tester.ensureVisible(showPassword);
        await tester.pumpAndSettle();
        await tester.tap(showPassword);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(password).obscureText, isFalse);
        expect(
          tester.widget<TextField>(password).controller!.text,
          'secret123',
        );

        await tester.ensureVisible(phone);
        await tester.pumpAndSettle();
        await tester.tap(find.text('+86'));
        await tester.pumpAndSettle();
        expect(find.byType(AppSheet), findsOneWidget);
        // 区号列表按需创建条目，先滚动到目标行，再执行实际选择。
        await tester.scrollUntilVisible(
          find.text('+1'),
          80,
          scrollable: find.descendant(
            of: find.byType(AppSheet),
            matching: find.byType(Scrollable),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('+1').hitTestable(), findsOneWidget);
        await tester.tap(find.text('+1'));
        await tester.pumpAndSettle();
        expect(find.byType(AppSheet), findsNothing);
        expect(find.text('+1'), findsOneWidget);
        expect(
          tester.widget<TextField>(password).controller!.text,
          'secret123',
        );

        // 手机号为空时只触发表单校验，不发起账号网络请求。
        final submit = find.byType(AppPrimaryButton);
        await tester.ensureVisible(submit);
        // 滚动定位后等待布局帧完成，点击实际可见的按钮。
        await tester.pumpAndSettle();
        expect(submit.hitTestable(), findsOneWidget);
        await tester.tap(submit);
        await tester.pumpAndSettle();
        expect(find.text(l10n.authInvalidPhone), findsOneWidget);
        expect(
          tester.widget<TextField>(password).controller!.text,
          'secret123',
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
