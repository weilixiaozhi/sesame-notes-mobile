import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/providers/app_composition.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_rest_completion_listener.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/features/settings/presentation/app_update_lifecycle_listener.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter/services.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell/app_shell.dart';
import 'shell/product_analytics_listener.dart';
import 'shell/notification_navigation_listener.dart';
import 'shell/reminder_lifecycle_listener.dart';
import 'shell/database_unavailable_app.dart';
import 'shell/app_initialization_gate.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';

import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_connection_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'shared/widgets/app_content_shield.dart';
import 'shared/widgets/primary_header.dart';
import 'package:sesame_notes/features/auth/presentation/welcome_page.dart';
import 'package:sesame_notes/features/auth/presentation/app_lock_screen.dart';
import 'core/logging/logger_service.dart';
import 'core/logging/cloud_backup_logger.dart';
import 'l10n/app_localizations.dart';
import 'dart:ui';

import 'dart:async';
import 'theme/icons/app_icons.dart';

/// 全局 navigator key — 给 service 层(没有 BuildContext)push 路由使用。
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

/// 校验构建配置并完成应用依赖初始化，再显示业务界面。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AppEnvironment.validate();
  } catch (error, stackTrace) {
    logger.error('App', '构建配置无效，请检查环境与服务地址后重新构建', error, stackTrace);
    rethrow;
  }
  // Composition Root：注册云同步 adapter 后端（插件化自注册）。
  // 云备份核心包不感知任何 adapter；必须在使用
  // 创建云提供方之前完成注册，否则对应后端会抛 StateError。
  registerSupabaseBackend(logger: cloudBackupLogger);
  registerWebDavBackend(logger: cloudBackupLogger);
  registerS3Backend(logger: cloudBackupLogger);

  // Edge-to-edge:让 Flutter 自己把内容(PrimaryHeader/皮肤)画到状态栏底下,
  // 而不是请求系统给状态栏刷色 —— 后者在部分 OEM(华为 EMUI/鸿蒙)上会被无视,
  // 导致 header 背景无法渗透到状态栏。iOS 本来就是全屏布局,不受影响。
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 初始化应用日志队列与持久化读取。
  logger.info('App', '应用启动，日志系统已初始化');

  // 创建全局ProviderContainer（需要在周期交易生成之前创建，因为需要使用 repositoryProvider）
  // Provider 失败后展示错误并由用户手动重试，
  // 避免云同步类 provider 在离线场景下持续后台重试并反复刷新 UI。
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: applicationOverrides(),
  );

  // 预加载和账号恢复前只读打开数据库；结构不符时保留原文件并停在独立错误界面。
  try {
    await container.read(databaseProvider).customSelect('SELECT 1').get();
  } catch (error, stackTrace) {
    logger.error('App', '启动数据库检查失败，业务入口已停止', error, stackTrace);
    container.dispose();
    runApp(const DatabaseUnavailableApp());
    return;
  }

  // 先恢复本地身份与安全状态；失败也挂载初始化界面，提供明确的重试入口。
  try {
    await initializeLocalApp(container);
  } catch (error, stackTrace) {
    logger.error('App', '启动尚未完成，等待用户重试', safeErrorSummary(error), stackTrace);
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

class NoGlowScrollBehavior extends MaterialScrollBehavior {
  const NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // 去除 Android 上的发光效果，避免顶部出现一抹红
  }
}

/// 锁屏仅在正常业务入口展示，与欢迎和初始化门槛共用同一判断。
final _appLockVisibleProvider = Provider<bool>(
  (ref) =>
      ref.watch(isAppLockedProvider) &&
      !ref.watch(shouldShowWelcomeProvider) &&
      ref.watch(appInitStateProvider) == AppInitState.ready,
);

/// 返回分发器由 Router 管理注册生命周期，保护期间不调用业务路由的 pop。
final _appBackButtonDispatcherProvider = Provider<RootBackButtonDispatcher>(
  (ref) => _AppBackButtonDispatcher(
    () => shouldHideAppContent(
      locked: ref.read(_appLockVisibleProvider),
      privacyScreen: ref.read(showPrivacyScreenProvider),
    ),
  ),
);

/// 在路由接收平台返回前检查共同保护边界，解锁后保留原有返回处理。
class _AppBackButtonDispatcher extends RootBackButtonDispatcher {
  _AppBackButtonDispatcher(this.isProtected);

  final bool Function() isProtected;

  /// 提前消费返回，避免遮罩下弹出页面或触发未保存确认。
  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) => isProtected()
      ? Future<bool>.value(true)
      : super.invokeCallback(defaultValue);
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  /// 主程序与直接挂载应用时共用同一套必需初始化流程。
  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  /// 首帧之后才写初始化状态，正常 main 已完成初始化时无需重复执行。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || ref.read(appInitStateProvider) != AppInitState.splash) {
        return;
      }
      try {
        await initializeLocalApp(
          ProviderScope.containerOf(context, listen: false),
        );
      } catch (error, stackTrace) {
        logger.error(
          'App',
          '应用初始化未完成，等待用户重试',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    });
  }

  /// 未就绪时只挂载初始化界面，成功后保持稳定路由和业务生命周期。
  @override
  Widget build(BuildContext context) {
    final initState = ref.watch(appInitStateProvider);
    if (initState == AppInitState.ready) {
      // 必需状态就绪后才开启业务生命周期，失败界面不会触发同步或后台数据写入。
      ref.watch(appStartupLifecycleProvider);
      ref.watch(welcomeCheckProvider);
      ref.watch(autoSyncCoordinatorProvider);
      ref.watch(cloudConnectionSyncProvider);
      ref.watch(appSessionLifecycleProvider);
      ref.watch(accountRecoveryLifecycleProvider);
      ref.watch(currentBookSelectionLifecycleProvider);
    }
    final selectedLanguage = ref.watch(languageProvider);

    final platform = Theme.of(context).platform; // 当前平台

    // 亮暗主题均由 AppTheme 统一定义（ColorScheme.fromSeed + 全部子主题内联），
    // main.dart 不做任何 copyWith 覆盖。
    final preset = ref.watch(themePresetProvider);
    final theme = AppTheme.lightTheme(platform: platform, preset: preset);
    final router = ref.watch(appRouterProvider);

    // 不干预系统字体缩放：以手机系统缩放为准。
    return MaterialApp.router(
      routerConfig: RouterConfig(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        backButtonDispatcher: ref.watch(_appBackButtonDispatcherProvider),
      ),
      onGenerateTitle: (context) =>
          AppEnvironment.displayName(AppLocalizations.of(context).appTitle),
      scrollBehavior: const NoGlowScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme(platform: platform, preset: preset),
      themeMode: ref.watch(themeModeProvider), // ⭐ 使用 provider 支持手动切换
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('zh', 'TW')],
      locale: selectedLanguage,
      builder: (context, child) {
        // 字号统一由文字令牌管理，保留系统原始文字缩放。
        final showPrivacy = ref.watch(showPrivacyScreenProvider);
        final isLocked = ref.watch(_appLockVisibleProvider);
        final hideBusinessContent = shouldHideAppContent(
          locked: isLocked,
          privacyScreen: showPrivacy,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: PrimaryHeader.systemOverlayStyle(context),
          child: AppInitializationGate(
            state: initState,
            onRetry: () => retryLocalAppInitialization(
              ProviderScope.containerOf(context, listen: false),
            ),
            child: Stack(
              children: [
                ReminderLifecycleListener(
                  enabled:
                      initState == AppInitState.ready &&
                      !ref.watch(shouldShowWelcomeProvider),
                ),
                NotificationNavigationListener(
                  router: router,
                  ready:
                      initState == AppInitState.ready &&
                      !ref.watch(shouldShowWelcomeProvider) &&
                      !hideBusinessContent,
                ),
                AppUpdateLifecycleListener(
                  navigatorKey: globalNavigatorKey,
                  enabled:
                      initState == AppInitState.ready &&
                      !ref.watch(shouldShowWelcomeProvider) &&
                      !hideBusinessContent,
                ),
                // 导航栈始终保留；锁定和后台遮罩统一隔离全部路由的输入、点击及读屏内容。
                AppContentShield(
                  hidden: hideBusinessContent,
                  child: ProductAnalyticsListener(
                    router: router,
                    enabled:
                        initState == AppInitState.ready &&
                        !ref.watch(shouldShowWelcomeProvider) &&
                        !hideBusinessContent,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
                if (initState == AppInitState.ready &&
                    !ref.watch(shouldShowWelcomeProvider))
                  FitnessRestCompletionListener(
                    navigatorKey: globalNavigatorKey,
                    enabled: !hideBusinessContent,
                  ),
                if (isLocked) const Positioned.fill(child: AppLockScreen()),
                if (showPrivacy)
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        color: AppTokens.overlay(context),
                        alignment: Alignment.center,
                        child: Icon(
                          AppIcons.lock,
                          size: 64,
                          color: AppTokens.textOnPrimary(
                            context,
                          ).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// '/' 根路由门面：按应用状态机决定渲染欢迎页、初始化闸门或主界面。
///
/// GoRouter 实例保持稳定，根页面自行订阅初始化状态，重建应用时保留导航栈。
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 首先检查是否需要显示欢迎页面
    final shouldShowWelcome = ref.watch(shouldShowWelcomeProvider);
    if (shouldShowWelcome) {
      return const WelcomePage();
    }

    // 欢迎页面完成后，根据初始化状态显示对应页面
    // 闸门安全网：正常流程下 appSplashInitProvider 已在 main() 中完成，
    // appInitState 已是 ready，此处不会触发。
    // 仅作为防御性兜底（如 main() 中预加载异常未执行）。
    final initState = ref.watch(appInitStateProvider);
    if (initState != AppInitState.ready) {
      return Scaffold(
        backgroundColor: AppTokens.scaffoldBackground(context),
        body: const SizedBox.shrink(),
      );
    }

    return const SesameNotesApp();
  }
}

/// 全局 GoRouter 实例。
///
/// 设计意图：路由配置不依赖任何 provider 状态（状态判断在 [_RootGate] 内
/// 自完成），故用普通 Provider 单例持有，MainApp rebuild 不重建路由栈；
/// navigatorKey 复用全局 key，service 层（无 BuildContext）仍可取导航器。
final appRouterProvider = Provider<GoRouter>(
  (ref) => createAppRouter(
    home: () => const _RootGate(),
    navigatorKey: globalNavigatorKey,
  ),
);
