import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shell/app_shell.dart';
import 'package:go_router/go_router.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'shared/services/notification/notification_factory.dart';
import 'shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/features/auth/presentation/welcome_page.dart';
import 'package:sesame_notes/features/auth/presentation/app_lock_screen.dart';
import 'shared/services/system/reminder_monitor_service.dart';
import 'core/logging/logger_service.dart';
import 'l10n/app_localizations.dart';
import 'dart:ui';

import 'dart:async';
import 'theme/icons/app_icons.dart';

/// 全局 navigator key — 给 service 层(没有 BuildContext)push 路由使用。
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Composition Root：注册云同步 adapter 后端（插件化自注册）。
  // 云备份核心包不感知任何 adapter；必须在使用
  // createCloudServices 之前完成注册，否则对应后端会抛 StateError。
  registerSupabaseBackend();
  registerWebDavBackend();
  registerS3Backend();

  // Edge-to-edge:让 Flutter 自己把内容(PrimaryHeader/皮肤)画到状态栏底下,
  // 而不是请求系统给状态栏刷色 —— 后者在部分 OEM(华为 EMUI/鸿蒙)上会被无视,
  // 导致 header 背景无法渗透到状态栏。iOS 本来就是全屏布局,不受影响。
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 初始化日志系统（确保原生日志桥接就绪）
  logger.info('App', '应用启动，日志系统已初始化');

  // 初始化时区（必须在通知服务之前完成）
  try {
    NotificationFactory.initializeTimeZone();
  } catch (e) {
    logger.warning('App', '时区初始化失败（可能在不支持的平台上运行）: $e');
  }

  // 初始化通知服务
  try {
    final notificationUtil = NotificationFactory.getInstance();
    await notificationUtil.initialize();
  } catch (e) {
    logger.warning('App', '通知服务初始化失败（可能在不支持的平台上运行）: $e');
  }

  // 恢复用户的记账提醒设置（应用重启后自动恢复提醒）
  await _restoreUserReminder();

  // 启动提醒监控服务（监听应用生命周期，自动恢复丢失的提醒）
  try {
    ReminderMonitorService().startMonitoring(
      textsProvider: () {
        // 文案生成留在 Composition Root：优先取当前导航上下文（跟随语言），
        // 拿不到时按系统语言解析兜底。
        final ctx = globalNavigatorKey.currentContext;
        final l10n = (ctx != null && ctx.mounted)
            ? AppLocalizations.of(ctx)
            : lookupAppLocalizations(PlatformDispatcher.instance.locale);
        return (title: l10n.reminderTitle, body: l10n.reminderBody);
      },
    );
  } catch (e) {
    logger.warning('App', '提醒监控服务启动失败（可能在不支持的平台上运行）: $e');
  }

  // 创建全局ProviderContainer（需要在周期交易生成之前创建，因为需要使用 repositoryProvider）
  // 关闭 Riverpod 3.0 的自动重试：沿用 2.x 行为，provider 失败后展示错误由用户手动重试，
  // 避免云同步类 provider 在离线场景下持续后台重试并反复刷新 UI。
  final container = ProviderContainer(
    retry: (retryCount, error) => null,
    overrides: [
      // 依赖倒置：启屏预加载的实现位于顶层聚合模块（依赖 features/*/application），
      // 这里注入到 shared 的抽象入口，使 UI 只依赖契约、不反向依赖聚合模块。
      splashPreloadRunnerProvider.overrideWith(buildSplashPreloadRunner),
    ],
  );

  // 后台静默预加载：在 runApp 之前完成数据加载
  // 原生启动图覆盖整个加载过程，用户无感知
  // runApp 后 appInitState 已是 ready，闸门直接放行，首页首次渲染即有数据
  await Future.wait([
    container.read(welcomeCheckProvider.future),
    container.read(appSplashInitProvider.future),
    // 启动账号恢复：读凭证 + 缓存资料恢复已登录身份，后台刷新不阻塞首帧
    container.read(accountBootstrapProvider.future),
    // 启动恢复收尾：登出标记撤销 + pending_local_move 隐藏 Fork 发布
    container.read(accountRecoveryProvider.future),
  ]);

  runApp(
    UncontrolledProviderScope(container: container, child: const MainApp()),
  );
}

/// 恢复用户之前设置的记账提醒
///
/// 问题场景：
/// - 应用被系统杀死后，通知任务会丢失
/// - 应用更新后，通知任务会被清除
/// - 手机重启后，通知任务需要重新设置
///
/// 解决方案：
/// - 在应用启动时检查用户是否开启了提醒
/// - 如果开启了，重新设置通知任务
Future<void> _restoreUserReminder() async {
  try {
    logger.info('Reminder', '检查并恢复记账提醒...');
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(ReminderPrefs.enabled) ?? false;

    if (isEnabled) {
      final hour = prefs.getInt(ReminderPrefs.hour) ?? 21;
      final minute = prefs.getInt(ReminderPrefs.minute) ?? 0;
      logger.info(
        'Reminder',
        '发现用户已启用记账提醒: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
      );
      logger.info('Reminder', '正在重新设置提醒任务...');

      try {
        final notificationUtil = NotificationFactory.getInstance();
        // 恢复前先取消旧通知链，再按当前配置重建，避免系统残留旧时间的备用通知。
        await notificationUtil.cancelNotification(
          ReminderPrefs.mainNotificationId,
        );
        // 启动阶段无 BuildContext，按系统语言取提醒文案（统一收敛到 l10n）。
        final l10n = lookupAppLocalizations(PlatformDispatcher.instance.locale);
        await notificationUtil.scheduleDailyReminder(
          id: ReminderPrefs.mainNotificationId,
          title: l10n.reminderTitle,
          body: l10n.reminderBody,
          hour: hour,
          minute: minute,
        );
        logger.info('Reminder', '记账提醒已成功恢复');
      } catch (e) {
        logger.warning('Reminder', '记账提醒设置失败（可能在不支持的平台上运行）: $e');
      }
    } else {
      logger.info('Reminder', '用户未启用记账提醒，跳过恢复');
    }
  } catch (e) {
    logger.warning('Reminder', '恢复记账提醒失败: $e');
    // 不抛出异常，避免影响应用启动
  }
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

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 首先检查是否需要显示欢迎页面
    ref.watch(welcomeCheckProvider);

    // 自动推送编排保持活跃：本地写库登记 sync_changes 后防抖自动同步。
    ref.watch(autoSyncCoordinatorProvider);

    // 检查应用初始化状态
    final initState = ref.watch(appInitStateProvider);
    final selectedLanguage = ref.watch(languageProvider);

    // 如果是启屏状态，启动初始化
    if (initState == AppInitState.splash) {
      ref.watch(appSplashInitProvider);
    }

    // 周期交易生成已统一在 appSplashInitProvider 中处理

    final platform = Theme.of(context).platform; // 当前平台

    // 亮暗主题均由 AppTheme 统一定义（ColorScheme.fromSeed + 全部子主题内联），
    // main.dart 不做任何 copyWith 覆盖。
    final theme = AppTheme.lightTheme(platform: platform);

    // 不干预系统字体缩放：以手机系统缩放为准。
    return MaterialApp.router(
      routerConfig: ref.watch(appRouterProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      scrollBehavior: const NoGlowScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: AppTheme.darkTheme(platform: platform), // ⭐ 暗黑主题
      themeMode: ref.watch(themeModeProvider), // ⭐ 使用 provider 支持手动切换
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('zh'), Locale('zh', 'TW')],
      locale: selectedLanguage,
      builder: (context, child) {
        // 全局文字缩小：以系统缩放为基数再乘 0.85（整体缩 15%）。
        // 设计意图：在系统文字标准（1.0）前提下，用户仍反馈全局偏大，
        // 故统一等比缩小所有文字；用相对式而非绝对值，保留弱视用户
        // 在系统层面调大字体后仍有放大能力，且不会撑爆布局。
        final mq = MediaQuery.of(context);
        final scaled = TextScaler.linear(mq.textScaler.scale(1.0) * 0.85);
        final showPrivacy = ref.watch(showPrivacyScreenProvider);
        return MediaQuery(
          data: mq.copyWith(textScaler: scaled),
          child: Stack(
            children: [
              // 输入框焦点收起交由 Flutter 默认行为（EditableText.onTapOutside）及各处显式 FocusManager.unfocus() 处理。
              child ?? const SizedBox.shrink(),
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
        );
      },
    );
  }
}

/// '/' 根路由门面：按应用状态机决定渲染欢迎页 / 初始化闸门 / 锁屏 / 主界面。
///
/// 设计意图：原 home 参数依赖 build 期 ref 状态，GoRouter 实例必须保持
/// 稳定（不能随 MainApp rebuild 重建，否则导航栈丢失），故把状态判断下沉
/// 到根路由页面内自行 watch，GoRouter 只需渲染本门面一次。
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

    // 检查是否需要显示锁屏
    final isLocked = ref.watch(isAppLockedProvider);
    if (isLocked) {
      return const AppLockScreen();
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
