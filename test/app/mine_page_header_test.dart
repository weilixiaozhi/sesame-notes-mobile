// 我的页头部（MinePageHeader）双态测试（账号一期）。
//
// 锚点：
//   1. 未登录：默认头像 + 单机芝麻仔（我）+ 本地使用 · 未登录 + 登录/注册按钮；
//      头像与昵称不可编辑，点击头像不进入预览；
//   2. 已登录：云昵称 + 芝麻号 + 进入箭头，点击整卡进入个人资料。
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/mine_page_header.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../helpers/realtime_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  /// 构建测试宿主：accountStateProvider 决定双态；登录态点击整卡走 stub 路由。
  Widget buildHarness(
    AccountState state, {
    GoRouter? router,
    ProviderContainer? container,
  }) {
    final effectiveRouter =
        router ??
        GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder: (context, s) => Scaffold(body: MinePageHeader()),
            ),
            GoRoute(
              path: '/profile',
              name: '/profile',
              builder: (context, s) =>
                  const Scaffold(body: Text('profile-stub')),
            ),
            GoRoute(
              path: '/auth/login',
              name: '/auth/login',
              builder: (context, s) => const Scaffold(body: Text('login-stub')),
            ),
          ],
        );
    return UncontrolledProviderScope(
      container: container!,
      child: MaterialApp.router(
        routerConfig: effectiveRouter,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
      ),
    );
  }

  testWidgets('未登录：默认头像 + 单机芝麻仔 + 本地使用说明 + 登录/注册按钮', (tester) async {
    final container = ProviderContainer(
      overrides: [
        accountStateProvider.overrideWith(AccountStateNotifier.new),
        realtimeNoopOverride,
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      buildHarness(AccountState.local, container: container),
    );
    await tester.pumpAndSettle();

    expect(find.text('单机芝麻仔（我）'), findsOneWidget);
    expect(find.text('本地使用 · 未登录'), findsOneWidget);
    expect(find.text('登录 / 注册'), findsOneWidget);
    expect(find.text('登录后可使用云账本和共享功能'), findsOneWidget);
    // 默认头像资产
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('未登录：身份与登录操作横向排布，功能提示独占下一行', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 260));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      overrides: [
        accountStateProvider.overrideWith(AccountStateNotifier.new),
        realtimeNoopOverride,
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      buildHarness(AccountState.local, container: container),
    );
    await tester.pumpAndSettle();

    final avatarRect = tester.getRect(find.byType(CircleAvatar));
    final titleRect = tester.getRect(find.text('单机芝麻仔（我）'));
    final subtitleRect = tester.getRect(find.text('本地使用 · 未登录'));
    final loginRect = tester.getRect(
      find.widgetWithText(FilledButton, '登录 / 注册'),
    );
    final hintRect = tester.getRect(find.text('登录后可使用云账本和共享功能'));

    expect(find.byType(SectionCard), findsOneWidget);
    expect(find.byIcon(AppIcons.info), findsOneWidget);
    expect(find.text('我的 · 未登录'), findsNothing);
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('单机芝麻仔（我）'))
          .didExceedMaxLines,
      isFalse,
    );
    expect(avatarRect.center.dx, lessThan(titleRect.left));
    expect(titleRect.left, moreOrLessEquals(subtitleRect.left));
    expect(loginRect.left, greaterThan(titleRect.right));
    expect(loginRect.center.dy, moreOrLessEquals(avatarRect.center.dy));
    expect(
      avatarRect.center.dy,
      inInclusiveRange(titleRect.top, subtitleRect.bottom),
    );
    expect(hintRect.top, greaterThan(avatarRect.bottom));
    expect(hintRect.top, greaterThan(loginRect.bottom));
  });

  testWidgets('未登录：点登录/注册进入登录页', (tester) async {
    final container = ProviderContainer(
      overrides: [
        accountStateProvider.overrideWith(AccountStateNotifier.new),
        realtimeNoopOverride,
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      buildHarness(AccountState.local, container: container),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('登录 / 注册'));
    await tester.pumpAndSettle();
    expect(find.text('login-stub'), findsOneWidget);
  });

  testWidgets('已登录：云昵称 + 芝麻号 + 进入箭头，点击进入个人资料', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 240));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      overrides: [
        accountStateProvider.overrideWith(AccountStateNotifier.new),
        realtimeNoopOverride,
      ],
    );
    addTearDown(container.dispose);
    container
        .read(accountStateProvider.notifier)
        .signIn(
          session: const AuthSession(
            accessToken: 't',
            userId: 'user-1',
            deviceId: 'd',
          ),
          credential: const ActiveCredential(
            userId: 'user-1',
            deviceId: 'd',
            refreshToken: 'rt',
          ),
          profile: const CloudProfile(
            userId: 'user-1',
            sesameNumber: '123456789',
            displayName: '云昵称',
          ),
        );
    const state = AccountState(
      status: AccountStatus.authenticated,
      profile: CloudProfile(
        userId: 'user-1',
        sesameNumber: '123456789',
        displayName: '云昵称',
      ),
    );
    await tester.pumpWidget(buildHarness(state, container: container));
    await tester.pumpAndSettle();

    expect(find.text('云昵称'), findsOneWidget);
    expect(find.text('芝麻号 123456789'), findsOneWidget);
    expect(find.text('我的 · 已登录'), findsNothing);
    expect(find.byType(SectionCard), findsOneWidget);
    expect(find.byIcon(AppIcons.info), findsNothing);

    final avatarRect = tester.getRect(find.byType(CircleAvatar));
    final nameRect = tester.getRect(find.text('云昵称'));
    final numberRect = tester.getRect(find.text('芝麻号 123456789'));
    final chevronRect = tester.getRect(find.byIcon(AppIcons.chevronRight));

    expect(avatarRect.center.dx, lessThan(nameRect.left));
    expect(nameRect.left, moreOrLessEquals(numberRect.left));
    expect(chevronRect.left, greaterThan(nameRect.right));
    expect(chevronRect.center.dy, moreOrLessEquals(avatarRect.center.dy));
    expect(
      avatarRect.center.dy,
      inInclusiveRange(nameRect.top, numberRect.bottom),
    );

    await tester.tap(find.byType(SectionCard));
    await tester.pumpAndSettle();
    expect(find.text('profile-stub'), findsOneWidget);
  });

  testWidgets('已登录无昵称：显示空昵称与芝麻号（不显示单机芝麻仔）', (tester) async {
    final container = ProviderContainer(
      overrides: [
        accountStateProvider.overrideWith(AccountStateNotifier.new),
        realtimeNoopOverride,
      ],
    );
    addTearDown(container.dispose);
    container
        .read(accountStateProvider.notifier)
        .signIn(
          session: const AuthSession(
            accessToken: 't',
            userId: 'user-1',
            deviceId: 'd',
          ),
          credential: const ActiveCredential(
            userId: 'user-1',
            deviceId: 'd',
            refreshToken: 'rt',
          ),
          profile: const CloudProfile(
            userId: 'user-1',
            sesameNumber: '987654321',
          ),
        );
    const state = AccountState(
      status: AccountStatus.authenticated,
      profile: CloudProfile(userId: 'user-1', sesameNumber: '987654321'),
    );
    await tester.pumpWidget(buildHarness(state, container: container));
    await tester.pumpAndSettle();

    expect(find.text('单机芝麻仔（我）'), findsNothing);
    expect(find.text('芝麻号 987654321'), findsOneWidget);
  });
}
