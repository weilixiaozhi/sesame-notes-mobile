import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/features/auth/presentation/profile_page.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';

/// 为资料页提供稳定的已登录资料，避免测试依赖真实会话与网络。
class _AuthenticatedAccountStateNotifier extends AccountStateNotifier {
  @override
  AccountState build() => const AccountState(
    status: AccountStatus.authenticated,
    profile: CloudProfile(
      userId: 'user-1',
      displayName: '芝麻仔382716',
      sesameNumber: '583271946',
      phoneMasked: '+86 138****5678',
    ),
  );
}

class _MockAuthActions extends Mock implements AuthActions {}

/// 构建中文资料页测试宿主，仅覆盖页面渲染所需依赖。
Widget _buildHarness({AuthActions? actions}) {
  return ProviderScope(
    overrides: [
      accountStateProvider.overrideWith(_AuthenticatedAccountStateNotifier.new),
      if (actions != null) authActionsProvider.overrideWithValue(actions),
    ],
    child: const MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale('zh'),
      home: ProfilePage(),
    ),
  );
}

void main() {
  testWidgets('进入资料页会刷新服务端本人资料', (tester) async {
    final actions = _MockAuthActions();
    when(actions.refreshProfile).thenAnswer(
      (_) async => const CloudProfile(userId: 'user-1', displayName: '新昵称'),
    );

    await tester.pumpWidget(_buildHarness(actions: actions));
    await tester.pump();

    verify(actions.refreshProfile).called(1);
  });

  testWidgets('资料页：头像居中独立展示，资料按三组左右排布', (tester) async {
    final actions = _MockAuthActions();
    when(
      actions.refreshProfile,
    ).thenAnswer((_) async => const CloudProfile(userId: 'user-1'));
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_buildHarness(actions: actions));
    await tester.pumpAndSettle();

    expect(find.text('点击更换头像'), findsOneWidget);
    expect(find.text('头像'), findsNothing);
    expect(find.text('基本资料'), findsOneWidget);
    expect(find.text('账号信息'), findsOneWidget);
    expect(find.text('安全'), findsOneWidget);
    expect(find.byType(SectionCard), findsNWidgets(3));

    final avatarRect = tester.getRect(find.byType(CircleAvatar));
    final avatarHintRect = tester.getRect(find.text('点击更换头像'));
    final basicInfoRect = tester.getRect(find.text('基本资料'));
    final nicknameRect = tester.getRect(find.text('昵称'));
    final nicknameValueRect = tester.getRect(find.text('芝麻仔382716'));
    final genderRect = tester.getRect(find.text('性别'));
    final genderValueRect = tester.getRect(find.text('未设置'));

    expect(avatarRect.center.dx, moreOrLessEquals(195));
    expect(avatarHintRect.top, greaterThan(avatarRect.bottom));
    expect(basicInfoRect.top, greaterThan(avatarHintRect.bottom));
    expect(nicknameValueRect.left, greaterThan(nicknameRect.right));
    expect(
      nicknameValueRect.center.dy,
      moreOrLessEquals(nicknameRect.center.dy),
    );
    expect(genderValueRect.left, greaterThan(genderRect.right));
    expect(genderValueRect.center.dy, moreOrLessEquals(genderRect.center.dy));
  });
}
