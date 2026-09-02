import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/features/auth/presentation/edit_profile_pages.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class _AuthenticatedAccountStateNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(userId: 'user-1', displayName: '芝麻仔382716'),
  );
}

void main() {
  /// 以设计稿手机视口渲染编辑昵称页。
  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountStateProvider.overrideWith(
            _AuthenticatedAccountStateNotifier.new,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditNicknamePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('编辑昵称页：保存位于头部，输入框内展示计数与清空按钮', (tester) async {
    await pumpPage(tester);

    expect(find.byType(PrimaryHeader), findsOneWidget);
    expect(find.byType(HeaderTextAction), findsOneWidget);
    expect(find.widgetWithText(HeaderTextAction, '保存'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.text('9 / 20'), findsOneWidget);
    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(find.text('昵称无唯一要求，可与其他人重名。支持中文、英文、数字和 Emoji。'), findsOneWidget);

    final header = tester.getRect(find.byType(PrimaryHeader));
    final field = tester.getRect(find.byType(TextField));
    final hint = tester.getRect(find.textContaining('昵称无唯一要求'));
    expect(field.top, greaterThan(header.bottom));
    expect(field.height, 54);
    expect(hint.top, greaterThan(field.bottom));
  });

  testWidgets('昵称最多输入 20 个字符，清空按钮同步清空内容与计数', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), '123456789012345678901');
    await tester.pump();
    expect(find.text('20 / 20'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text.length,
      20,
    );

    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pump();
    expect(find.text('0 / 20'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      isEmpty,
    );
  });
}
