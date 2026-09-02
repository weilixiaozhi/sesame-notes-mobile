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
    profile: CloudProfile(
      userId: 'user-1',
      displayName: '芝麻仔382716',
      gender: 'UNSPECIFIED',
    ),
  );
}

void main() {
  /// 以设计稿手机视口渲染选择性别页。
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
          home: EditGenderPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('选择性别页：保存位于头部，三行选项下展示隐私说明', (tester) async {
    await pumpPage(tester);

    expect(find.widgetWithText(PrimaryHeader, '性别'), findsOneWidget);
    expect(find.widgetWithText(HeaderTextAction, '保存'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.text('未设置'), findsOneWidget);
    expect(find.text('男'), findsOneWidget);
    expect(find.text('女'), findsOneWidget);
    expect(find.text('性别仅本人可见，不对共享账本其他成员展示。'), findsOneWidget);

    final header = tester.getRect(find.byType(PrimaryHeader));
    final firstRow = tester.getRect(find.byType(ListTile).first);
    final hint = tester.getRect(find.textContaining('性别仅本人可见'));
    expect(firstRow.top, greaterThan(header.bottom));
    expect(firstRow.height, 54);
    expect(hint.top, greaterThan(firstRow.bottom));
  });

  testWidgets('当前选项显示勾选，点击其他选项后勾选随之更新', (tester) async {
    await pumpPage(tester);

    expect(find.byIcon(AppIcons.check), findsOneWidget);
    expect(
      tester.widget<ListTile>(find.byType(ListTile).first).selected,
      isTrue,
    );

    await tester.tap(find.text('女'));
    await tester.pump();

    expect(
      tester.widget<ListTile>(find.byType(ListTile).first).selected,
      isFalse,
    );
    expect(
      tester.widget<ListTile>(find.byType(ListTile).last).selected,
      isTrue,
    );
    expect(find.byIcon(AppIcons.check), findsOneWidget);
  });
}
