import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/features/auth/presentation/change_password_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/api/profile_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class _MockProfileService extends Mock implements ProfileService {}

void main() {
  late _MockProfileService profileService;

  setUp(() {
    profileService = _MockProfileService();
  });

  /// 以设计稿手机视口渲染修改密码页。
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [profileServiceProvider.overrideWithValue(profileService)],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChangePasswordPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('修改密码页：顶部保存，三个字段标签外置并使用文字显隐按钮', (tester) async {
    await pumpPage(tester);

    expect(find.byType(PrimaryHeader), findsOneWidget);
    expect(find.widgetWithText(HeaderTextAction, '保存'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('当前密码'), findsOneWidget);
    expect(find.text('新密码'), findsOneWidget);
    expect(find.text('确认新密码'), findsOneWidget);
    expect(find.text('输入当前密码'), findsOneWidget);
    expect(find.text('设置新密码'), findsOneWidget);
    expect(find.text('再次输入新密码'), findsOneWidget);
    expect(find.text('显示'), findsNWidgets(3));
    expect(find.byIcon(AppIcons.visibility), findsNothing);
    expect(find.text('密码需为 8-20 位，包含字母和数字。修改后需使用新密码重新登录。'), findsOneWidget);

    final labels = ['当前密码', '新密码', '确认新密码'];
    for (var index = 0; index < labels.length; index++) {
      final label = tester.getRect(find.text(labels[index]));
      final field = tester.getRect(find.byType(TextField).at(index));
      expect(label.bottom, lessThan(field.top));
      expect(field.height, 54);
    }
  });

  testWidgets('三个密码字段均可切换显示和隐藏', (tester) async {
    await pumpPage(tester);

    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .every((field) => field.obscureText),
      isTrue,
    );
    await tester.tap(find.text('显示').first);
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).obscureText,
      isFalse,
    );
    expect(find.text('隐藏'), findsOneWidget);
  });

  testWidgets('新密码不满足 8-20 位且包含字母和数字时不提交', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField).at(0), 'old-pass-1');
    await tester.enterText(find.byType(TextField).at(1), 'abcdefgh');
    await tester.enterText(find.byType(TextField).at(2), 'abcdefgh');
    await tester.tap(find.widgetWithText(HeaderTextAction, '保存'));
    await tester.pump();

    expect(find.text('密码需为 8-20 位，且必须同时包含字母和数字'), findsOneWidget);
    verifyNever(
      () => profileService.changePassword(
        currentPassword: any(named: 'currentPassword'),
        newPassword: any(named: 'newPassword'),
      ),
    );
  });
}
