// 注册页（RegisterPage）交互测试。
//
// 锚点：
//   - 三字段（手机号/密码/确认密码）+ 登录入口；无验证码/忘记密码/协议入口；
//   - 确认密码不一致 → 不发请求（不调用 AuthService.register）；
//   - 提交期间按钮禁用（busy 防重复提交）；
//   - 注册成功 → 协调器提交候选凭证并 pop 返回。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/features/auth/presentation/register_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/widgets/app_logo.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../helpers/realtime_test_stub.dart';

class MockAuthService extends Mock implements AuthService {}

class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockAuthService auth;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = MockAuthService();
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        realtimeNoopOverride,
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            _MemorySecureStore(),
            pendingStore: _MemorySecureStore(),
            logoutMarkerStore: _MemorySecureStore(),
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(
          CloudProfileCache(await SharedPreferences.getInstance()),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  /// 以指定视口打开注册页，便于同时验证交互和手机端布局。
  Future<void> pumpRegister(
    WidgetTester tester, {
    Size size = const Size(800, 1600),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/auth/register'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('页面渲染手机号/密码/确认密码三字段与注册/登录入口；无协议与验证码入口', (tester) async {
    await pumpRegister(tester);

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.widgetWithText(FilledButton, '注册'), findsOneWidget);
    expect(find.text('已有账号？立即登录'), findsOneWidget);
    // 一期不提供验证码/忘记密码/用户协议入口
    expect(find.textContaining('验证码'), findsNothing);
    expect(find.textContaining('忘记密码'), findsNothing);
    expect(find.textContaining('协议'), findsNothing);
    expect(find.textContaining('隐私政策'), findsNothing);
  });

  testWidgets('页面布局：顶部使用 Logo 资源，字段标签外置且手机号同框排布', (tester) async {
    await pumpRegister(tester, size: const Size(390, 844));

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byIcon(AppIcons.visibility), findsNothing);
    expect(find.text('创建账号'), findsNothing);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('确认密码'), findsOneWidget);
    expect(find.text('+86'), findsOneWidget);
    expect(find.text('显示'), findsNWidgets(2));

    final logo = tester.getRect(find.byType(AppLogo));
    final phoneLabel = tester.getRect(find.text('手机号'));
    final phoneField = tester.getRect(find.byType(TextField).at(0));
    final region = tester.getRect(find.text('+86'));
    final registerButton = tester.getRect(
      find.widgetWithText(FilledButton, '注册'),
    );
    final loginLink = tester.getRect(find.text('已有账号？立即登录'));

    expect(logo.center.dx, closeTo(195, 1));
    expect(phoneLabel.top, greaterThan(logo.bottom));
    expect(phoneLabel.bottom, lessThan(phoneField.top));
    expect(region.center.dy, closeTo(phoneField.center.dy, 1));
    expect(
      registerButton.top,
      greaterThan(tester.getRect(find.byType(TextField).at(2)).bottom),
    );
    expect(loginLink.top, greaterThan(registerButton.bottom));
  });

  testWidgets('确认密码不一致 → 不发请求（AuthService.register 不被调用）', (tester) async {
    await pumpRegister(tester);

    await tester.enterText(find.byType(TextField).at(0), '13800138000');
    await tester.enterText(find.byType(TextField).at(1), 'pass-1');
    await tester.enterText(find.byType(TextField).at(2), 'pass-2');
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pumpAndSettle();

    expect(find.text('两次输入的密码不一致'), findsOneWidget);
    verifyNever(
      () => auth.register(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('注册成功：协调器提交候选凭证后返回来源页', (tester) async {
    await pumpRegister(tester);
    when(
      () => auth.register(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => CandidateSession(
        session: const AuthSession(
          accessToken: 't',
          userId: 'user-1',
          deviceId: 'd',
        ),
        refreshToken: 'rt',
        profile: const CloudProfile(userId: 'user-1'),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), '13800138000');
    await tester.enterText(find.byType(TextField).at(1), 'pass-1');
    await tester.enterText(find.byType(TextField).at(2), 'pass-1');
    await tester.tap(find.widgetWithText(FilledButton, '注册'));
    await tester.pumpAndSettle();

    verify(
      () => auth.register(
        countryCode: '+86',
        phone: '13800138000',
        password: 'pass-1',
      ),
    ).called(1);
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
    // 返回来源页
    expect(find.text('open'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
