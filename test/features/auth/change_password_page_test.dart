import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/change_password_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 仅替代网络用例，保留页面真实输入与校验流程。
class _MockAuthActions extends Mock implements AuthActions {}

void main() {
  for (final password in ['1', 'a' * 128]) {
    testWidgets('修改密码页完整提交 ${password.length} 字符的新密码', (tester) async {
      final actions = _MockAuthActions();
      when(
        () => actions.changePassword(
          currentPassword: 'current-password',
          newPassword: password,
        ),
      ).thenAnswer((_) async {});
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authActionsProvider.overrideWithValue(actions)],
          child: const MaterialApp(
            locale: Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ChangePasswordPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'current-password');
      await tester.enterText(fields.at(1), password);
      await tester.enterText(fields.at(2), password);
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      // 成功提示定时关闭，测试退出前推进到提示完成，避免残留计时器。
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      verify(
        () => actions.changePassword(
          currentPassword: 'current-password',
          newPassword: password,
        ),
      ).called(1);
      expect(tester.takeException(), isNull);
    });
  }
}
