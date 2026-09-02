// 登录页（AuthPage）交互测试。
//
// 锚点（手机号认证模式）：
//   - 空手机号/空密码 → 提示对应文案并停留在本页，不发起请求；
//   - 手机号+密码完整 → AuthService.login 返回候选会话，由协调器原子提交；
//   - 提交成功后返回来源页（push<bool> 语义）；
//   - 认证失败 → 显示错误文案并停留在本页；
//   - 密码可见性切换。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/auth/presentation/login_page.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_service.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/app_logo.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../helpers/realtime_test_stub.dart';

class MockAuthService extends Mock implements AuthService {}

class MockSyncCoordinator extends Mock implements SyncCoordinator {}

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
  late MockSyncCoordinator sync;
  late SesameDatabase db;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = MockAuthService();
    sync = MockSyncCoordinator();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        syncCoordinatorProvider.overrideWithValue(sync),
        databaseProvider.overrideWithValue(db),
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
    addTearDown(db.close);
  });

  /// 打开登录页；可指定视口以验证目标手机尺寸下的布局。
  Future<void> pumpLogin(
    WidgetTester tester, {
    Size size = const Size(800, 1400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // 登录页经 GoRouter push 打开（页面使用 go_router 的 pop/push 语义）
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => context.push('/auth/login'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: '/auth/register',
          builder: (context, state) => const Scaffold(),
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

  /// 配置 mock：登录成功返回候选会话，reconnect 成功。
  void stubSuccess() {
    when(
      () => auth.login(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) async => CandidateSession(
        session: const AuthSession(
          accessToken: 'access-token',
          userId: 'user-1',
          deviceId: 'device-1',
        ),
        refreshToken: 'refresh-1',
        profile: const CloudProfile(
          userId: 'user-1',
          sesameNumber: '123456789',
        ),
      ),
    );
    when(() => sync.reconnect()).thenAnswer(
      (_) async => const ReconnectReport(refreshed: [], stale: [], gone: []),
    );
  }

  testWidgets('页面渲染手机号/密码输入框与登录按钮', (tester) async {
    await pumpLogin(tester);

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
  });

  testWidgets('页面布局：顶部使用 Logo 资源，字段标签外置且手机号同框排布', (tester) async {
    await pumpLogin(tester, size: const Size(390, 844));

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byIcon(AppIcons.login), findsNothing);
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('+86'), findsOneWidget);
    expect(find.text('显示'), findsOneWidget);
    expect(find.byIcon(AppIcons.visibility), findsNothing);

    final logoRect = tester.getRect(find.byType(AppLogo));
    final titleRect = tester.getRect(find.text('欢迎回来'));
    final phoneLabelRect = tester.getRect(find.text('手机号'));
    final phoneFieldRect = tester.getRect(find.byType(TextField).at(0));
    final regionRect = tester.getRect(find.text('+86'));
    final passwordLabelRect = tester.getRect(find.text('密码'));
    final passwordFieldRect = tester.getRect(find.byType(TextField).at(1));
    final loginButtonRect = tester.getRect(
      find.widgetWithText(FilledButton, '登录'),
    );
    final registerRect = tester.getRect(find.text('还没有账号？立即注册'));

    expect(logoRect.center.dx, moreOrLessEquals(195));
    expect(titleRect.top, greaterThan(logoRect.bottom));
    expect(phoneLabelRect.bottom, lessThan(phoneFieldRect.top));
    expect(regionRect.center.dy, moreOrLessEquals(phoneFieldRect.center.dy));
    expect(passwordLabelRect.bottom, lessThan(passwordFieldRect.top));
    expect(loginButtonRect.top, greaterThan(passwordFieldRect.bottom));
    expect(registerRect.top, greaterThan(loginButtonRect.bottom));
  });

  testWidgets('空手机号点登录 → 提示且不发起请求', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    expect(find.text('请输入有效的手机号'), findsOneWidget);
    // 未触发认证调用
    verifyNever(
      () => auth.login(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('密码可见性切换', (tester) async {
    await pumpLogin(tester);

    final pwdField = find.byType(TextField).at(1);
    expect(tester.widget<TextField>(pwdField).obscureText, isTrue);

    await tester.tap(find.text('显示'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(pwdField).obscureText, isFalse);
    expect(find.text('隐藏'), findsOneWidget);
  });

  testWidgets('手机号+密码完整 → 登录成功：协调器提交候选凭证后关闭登录页', (tester) async {
    await pumpLogin(tester);
    stubSuccess();

    await tester.enterText(find.byType(TextField).at(0), '13800138000');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    // 真实认证路径：login 带区号/手机号 + reconnect
    verify(
      () => auth.login(
        countryCode: '+86',
        phone: '13800138000',
        password: 'secret123',
      ),
    ).called(1);
    verify(() => sync.reconnect()).called(1);
    // 协调器原子提交：会话注入 + 凭证落盘 + 账号状态 authenticated
    final session = container.read(authSessionProvider);
    expect(session?.accessToken, 'access-token');
    expect(session?.deviceId, 'device-1');
    expect(container.read(accountStateProvider).isAuthenticated, isTrue);
    final stored = await container.read(secureAccountStoreProvider).load();
    expect(stored?.refreshToken, 'refresh-1');
    // 登录页已关闭（返回来源页）
    expect(find.text('open'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('认证失败 → 显示错误文案并停留在登录页', (tester) async {
    await pumpLogin(tester);
    when(
      () => auth.login(
        countryCode: any(named: 'countryCode'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ).thenThrow(Exception('bad credentials'));

    await tester.enterText(find.byType(TextField).at(0), '13800138000');
    await tester.enterText(find.byType(TextField).at(1), 'secret123');
    await tester.tap(find.widgetWithText(FilledButton, '登录'));
    await tester.pumpAndSettle();

    // 失败文案出现、登录页保持打开、会话保持未登录
    expect(find.text('操作失败，请稍后重试'), findsOneWidget);
    expect(container.read(authSessionProvider), isNull);
    expect(container.read(accountStateProvider).isAuthenticated, isFalse);
    expect(find.text('open'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });
}
