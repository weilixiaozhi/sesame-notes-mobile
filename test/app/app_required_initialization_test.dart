import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/auth/application/welcome_onboarding.dart';
import 'package:sesame_notes/features/auth/presentation/welcome_page.dart';
import 'package:sesame_notes/features/days/application/day_reminder_lifecycle.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/main.dart';
import 'package:sesame_notes/providers/app_composition.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_connection_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/services/reminder_monitor_service.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/shell/app_shell.dart';
import 'package:timezone/timezone.dart' as tz;

import '../helpers/test_isolation.dart';

/// 失败发生在安全存储端口，真实 SecureAccountStore 与 bootstrap 均参与验证。
class _RecoverableSecureStore implements SecureStore {
  bool unreadable = false;
  int reads = 0;
  String? value;

  /// 模拟系统钥匙串暂时不可读，修复后仍使用同一个存储实例。
  @override
  Future<String?> read() async {
    reads++;
    if (unreadable) throw StateError('injected secure storage failure');
    return value;
  }

  /// 保留真实门面对同一存储槽的写入语义。
  @override
  Future<void> write(String next) async => value = next;

  /// 空槽与不可读是不同状态。
  @override
  Future<void> delete() async => value = null;
}

class _NoopAutoSync extends Fake implements AutoSyncCoordinator {}

/// 主提醒使用真实恢复服务，仅把系统通知登记替换为时区与顺序记录。
class _ResumeNotifications extends Fake implements NotificationUtil {
  final List<String> events;

  /// 与纪念日恢复回调共享执行记录，验证实际前后台入口的顺序。
  _ResumeNotifications(this.events);

  /// 记录系统登记时读取到的当前时区。
  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    events.add('main:${tz.local.name}');
  }
}

/// 统计文案配置和系统恢复的实际时刻，不调用宿主平台插件。
class _RecordingReminderMonitor extends Fake implements ReminderMonitorService {
  int starts = 0;
  int restores = 0;
  int stops = 0;

  /// 只在必需初始化确认之后提供提醒文案。
  @override
  void configureTexts({
    required ({String title, String body}) Function() textsProvider,
  }) {
    starts++;
  }

  /// 容器释放时文案回调一并清理。
  @override
  void clearTexts() => stops++;

  /// 系统调度作为可降级后台任务，使用独立计数证明不会抢跑。
  @override
  Future<bool> restoreReminder() async {
    restores++;
    return true;
  }
}

/// 已有 PIN 的读取次数用于证明欢迎重跑不会重新锁住已经解锁的界面。
class _ExistingPinService extends AppLockServiceFacade {
  int pinReads = 0;

  /// 只提供确定的本地安全事实，不发起生物识别或持久化。
  @override
  Future<bool> hasPin() async {
    pinReads++;
    return true;
  }
}

/// 只延迟真实后台时间的持久化回执，其他初始化偏好使用正常内存平台实现。
class _DelayedBackgroundStore extends InMemorySharedPreferencesStore {
  /// 失败场景使用非零宽限，证明锁定来自保存失败而不是立即锁配置。
  _DelayedBackgroundStore({required bool failure})
    : super.withData({
        'flutter.welcome_shown': true,
        'flutter.auto_backup': false,
        'flutter.${AppLockService.prefsKeyEnabled}': true,
        'flutter.${AppLockService.prefsKeyTimeoutSeconds}': failure ? 60 : 0,
      });

  final started = Completer<void>();
  final release = Completer<bool>();

  /// 保留平台拒绝写入的原始返回值，不让插件乐观缓存替代落盘确认。
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == 'flutter.${AppLockService.prefsKeyLastBackgroundTime}') {
      if (!started.isCompleted) started.complete();
      if (!await release.future) return false;
    }
    return super.setValue(valueType, key, value);
  }
}

/// 主应用使用真实必需初始化及欢迎装配，只替换网络和系统副作用。
class _StartupFixture {
  /// 真实本地初始化与系统副作用替身共用同一个应用容器。
  _StartupFixture({
    this.pinService,
    this.router,
    ReminderMonitorService? reminderService,
    Future<void> Function()? restoreDays,
  }) {
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        ...applicationOverrides(),
        databaseProvider.overrideWithValue(database),
        apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            store,
            pendingStore: _RecoverableSecureStore(),
            logoutMarkerStore: _RecoverableSecureStore(),
          ),
        ),
        if (pinService != null)
          appLockServiceProvider.overrideWithValue(pinService!),
        if (router != null) appRouterProvider.overrideWithValue(router!),
        monthlyTotalsProvider.overrideWith((ref, params) async {
          statisticsLoads++;
          throw StateError('optional statistics unavailable');
        }),
        autoSyncCoordinatorProvider.overrideWith((ref) {
          businessLifecycles++;
          return _NoopAutoSync();
        }),
        cloudConnectionSyncProvider.overrideWith((ref) => businessLifecycles++),
        appSessionLifecycleProvider.overrideWith((ref) => businessLifecycles++),
        accountRecoveryLifecycleProvider.overrideWith(
          (ref) => businessLifecycles++,
        ),
        currentBookSelectionLifecycleProvider.overrideWith(
          (ref) => businessLifecycles++,
        ),
        appReminderMonitorProvider.overrideWithValue(
          reminderService ?? monitor,
        ),
        if (restoreDays != null)
          dayReminderLifecycleProvider.overrideWithValue(restoreDays),
        startupNotificationRestoreProvider.overrideWith(
          (ref) => () async {
            notificationRestores++;
          },
        ),
        accountStartupRefreshProvider.overrideWith((ref) async {
          credentialRefreshes++;
        }),
      ],
    );
  }

  final database = SesameDatabase.withExecutor(NativeDatabase.memory());
  final store = _RecoverableSecureStore();
  final monitor = _RecordingReminderMonitor();
  final _ExistingPinService? pinService;
  final GoRouter? router;
  late final ProviderContainer container;
  int businessLifecycles = 0;
  int statisticsLoads = 0;
  int notificationRestores = 0;
  int credentialRefreshes = 0;

  /// 当前初始化轮次结束后返回状态，避免靠固定延迟判断异步 IO。
  Future<AppInitState> waitUntilSettled() async {
    final completed = Completer<AppInitState>();
    final subscription = container.listen(appInitStateProvider, (_, state) {
      if ((state == AppInitState.ready || state == AppInitState.failed) &&
          !completed.isCompleted) {
        completed.complete(state);
      }
    }, fireImmediately: true);
    try {
      return await completed.future.timeout(const Duration(seconds: 5));
    } finally {
      subscription.close();
    }
  }

  /// 解除真实容器和数据库，后台日志也在测试结束前清空。
  Future<void> dispose() async {
    try {
      container.dispose();
      router?.dispose();
      await database.close();
      await logger.clear();
    } catch (error, stackTrace) {
      fail('启动夹具清理失败：$error\n$stackTrace');
    }
  }
}

/// 验证真实 MainApp、必需存储失败与就绪后的可降级欢迎流程。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  for (final scenario in ['delayed', 'failed', 'superseded']) {
    testWidgets('前台锁检查 $scenario：等待后台回执且旧恢复不能移除新遮罩', (tester) async {
      final previous = SharedPreferencesStorePlatform.instance;
      SharedPreferences.resetStatic();
      final store = _DelayedBackgroundStore(failure: scenario == 'failed');
      SharedPreferencesStorePlatform.instance = store;
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const SesameNotesApp())],
      );
      final fixture = _StartupFixture(
        router: router,
        pinService: _ExistingPinService(),
        restoreDays: () async {},
      );
      try {
        await tester.runAsync(() => initializeLocalApp(fixture.container));
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: fixture.container,
            child: const MainApp(),
          ),
        );
        await tester.pumpAndSettle();
        fixture.container.read(isAppLockedProvider.notifier).set(false);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump();
        expect(store.started.isCompleted, isTrue);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(
          fixture.container.read(showPrivacyScreenProvider),
          isTrue,
          reason: '后台时间尚未确认，恢复不能提前展示业务内容',
        );
        expect(
          fixture.container.read(isAppLockedProvider),
          isFalse,
          reason: '锁定判断等待真实后台写入回执',
        );

        if (scenario == 'superseded') {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
        }
        store.release.complete(scenario != 'failed');
        if (scenario == 'superseded') {
          // 推进旧回执的微任务，直接验证新一轮 inactive 的遮罩仍由它自己持有。
          await tester.pump();
          expect(
            fixture.container.read(showPrivacyScreenProvider),
            isTrue,
            reason: '旧 resumed 的回执不能解除随后 inactive 设置的遮罩',
          );
          expect(fixture.container.read(isAppLockedProvider), isFalse);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
        }
        // 前台刷新会同时启动业务查询；验证锁状态，不等待无关页面加载动画结束。
        for (
          var frame = 0;
          frame < 20 &&
              (!fixture.container.read(isAppLockedProvider) ||
                  fixture.container.read(showPrivacyScreenProvider));
          frame++
        ) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(
          fixture.container.read(isAppLockedProvider),
          isTrue,
          reason: '立即锁定或后台写入失败都必须在解除遮罩之前确认锁定',
        );
        expect(fixture.container.read(showPrivacyScreenProvider), isFalse);
        expect(tester.takeException(), isNull);
      } catch (error, stackTrace) {
        fail('实际生命周期锁定回归失败：$scenario，$error\n$stackTrace');
      } finally {
        if (!store.release.isCompleted) store.release.complete(true);
        await tester.pumpWidget(const SizedBox.shrink());
        fixture.container.dispose();
        fixture.router?.dispose();
        await tester.pumpAndSettle();
        await tester.runAsync(fixture.database.close);
        await tester.pumpAndSettle();
        await tester.runAsync(logger.clear);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        NotificationFactory.reset();
        SharedPreferencesStorePlatform.instance = previous;
        SharedPreferences.resetStatic();
      }
    });
  }

  testWidgets('真实应用恢复前台只读取一次设备时区，先恢复主提醒再核对纪念日', (tester) async {
    SharedPreferences.setMockInitialValues({
      'welcome_shown': true,
      'auto_backup': false,
      AppLockService.prefsKeyEnabled: true,
      AppLockService.prefsKeyTimeoutSeconds: 0,
      ReminderPrefs.notificationsEnabled: true,
      ReminderPrefs.enabled: true,
    });
    var deviceZone = 'Asia/Shanghai';
    var zoneReads = 0;
    final events = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('notification_channel'), (
          call,
        ) async {
          if (call.method != 'getTimeZone') return null;
          zoneReads++;
          return deviceZone;
        });
    NotificationFactory.setInstanceForTesting(_ResumeNotifications(events));
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const SesameNotesApp())],
    );
    final fixture = _StartupFixture(
      router: router,
      pinService: _ExistingPinService(),
      reminderService: ReminderMonitorService(),
      restoreDays: () async => events.add('days:${tz.local.name}'),
    );
    try {
      await tester.runAsync(() => initializeLocalApp(fixture.container));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: fixture.container,
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();
      fixture.container.read(isAppLockedProvider.notifier).set(false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      deviceZone = 'Asia/Tokyo';
      events.clear();
      zoneReads = 0;

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(
        fixture.container.read(showPrivacyScreenProvider),
        isTrue,
        reason: '异步锁定检查完成前保持隐私遮罩，业务内容不可短暂暴露',
      );
      await tester.pumpAndSettle();

      expect(fixture.container.read(isAppLockedProvider), isTrue);
      expect(fixture.container.read(showPrivacyScreenProvider), isFalse);

      expect(zoneReads, 1);
      expect(events, ['main:Asia/Tokyo', 'days:Asia/Tokyo']);
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      fail('实际前台恢复提醒顺序回归失败：$error\n$stack');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      // Drift 流由虚拟时钟区域订阅，先在同一区域释放并完成取消，真实 IO 区域
      // 随后才关闭数据库，避免 close 等待无法在 runAsync 内推进的流收尾任务。
      fixture.container.dispose();
      fixture.router?.dispose();
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await fixture.database.close();
      });
      // 数据库关闭可能完成界面查询的错误回执；先排空其虚拟区域回调，再清日志计时器。
      await tester.pumpAndSettle();
      await tester.runAsync(logger.clear);
      NotificationFactory.reset();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('notification_channel'),
            null,
          );
    }
  });

  test('严格凭证读取保留原始失败堆栈，宽松读取及损坏JSON保持原语义', () async {
    final raw = _RecoverableSecureStore()..unreadable = true;
    final store = SecureAccountStore(raw);
    expect(await store.load(), isNull);
    expect(store.lastError, isNotNull);
    try {
      await store.load(requireReadable: true);
      fail('必需凭证读取不能把系统存储失败当作无凭证');
    } on StateError catch (error, stackTrace) {
      expect(error.message, contains('当前账号信息暂时无法读取'));
      expect(stackTrace.toString(), contains('_RecoverableSecureStore.read'));
    }
    raw.unreadable = false;
    raw.value = 'invalid-json';
    expect(await store.load(requireReadable: true), isNull);
    expect(store.lastError, isNull);
  });

  testWidgets('真实安全存储失败停留启动失败页，点击重试后才启动业务和后台任务', (tester) async {
    var businessBuilds = 0;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) {
            businessBuilds++;
            return const Scaffold(body: Text('business-route'));
          },
        ),
      ],
    );
    final fixture = _StartupFixture(router: router)..store.unreadable = true;
    try {
      await tester.runAsync(() async {
        await expectLater(
          initializeLocalApp(fixture.container),
          throwsStateError,
        );
      });
      expect(fixture.container.read(appInitStateProvider), AppInitState.failed);
      expect(fixture.container.exists(appSplashInitProvider), isFalse);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: fixture.container,
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(businessBuilds, 0);
      expect(fixture.businessLifecycles, 0);
      expect(fixture.monitor.starts, 0);
      expect(fixture.notificationRestores, 0);
      expect(fixture.credentialRefreshes, 0);
      fixture.store.unreadable = false;
      await tester.tap(find.byType(FilledButton));
      await tester.runAsync(() async {
        expect(await fixture.waitUntilSettled(), AppInitState.ready);
      });
      await tester.pumpAndSettle();
      expect(fixture.store.reads, 2);
      expect(businessBuilds, greaterThan(0));
      expect(fixture.monitor.starts, 1);
      expect(fixture.monitor.restores, 1);
      expect(fixture.notificationRestores, 1);
      expect(fixture.credentialRefreshes, 1);
      fixture.container.read(themeModeProvider.notifier).set(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(fixture.monitor.starts, 1);
      expect(fixture.credentialRefreshes, 1);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      fail('真实存储失败与启动重试回归失败：$error\n$stackTrace');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(fixture.dispose);
    }
  });

  testWidgets('直接挂载MainApp的splash入口等待真实欢迎读取，失败不抢跑安全预加载', (tester) async {
    SharedPreferences.setMockInitialValues({'welcome_shown': 'wrong-type'});
    final fixture = _StartupFixture();
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: fixture.container,
          child: const MainApp(),
        ),
      );
      await tester.runAsync(() async {
        expect(await fixture.waitUntilSettled(), AppInitState.failed);
      });
      await tester.pumpAndSettle();
      expect(fixture.store.reads, 1);
      expect(fixture.container.exists(appSplashInitProvider), isFalse);
      expect(fixture.statisticsLoads, 0);
      expect(fixture.businessLifecycles, 0);
      expect(fixture.monitor.starts, 0);
      expect(fixture.credentialRefreshes, 0);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      fail('MainApp必需初始化入口回归失败：$error\n$stackTrace');
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(fixture.dispose);
    }
  });

  testWidgets('真实欢迎装配在ready后重跑缓存，统计失败不卸载欢迎也不重复上锁或启动后台', (tester) async {
    SharedPreferences.setMockInitialValues({
      AppLockService.prefsKeyEnabled: true,
    });
    final security = _ExistingPinService();
    final fixture = _StartupFixture(pinService: security);
    final transitions = <AppInitState>[];
    ProviderSubscription<AppInitState>? subscription;
    try {
      await tester.runAsync(() => initializeLocalApp(fixture.container));
      expect(fixture.container.read(appInitStateProvider), AppInitState.ready);
      expect(security.pinReads, 1);
      fixture.container.read(isAppLockedProvider.notifier).set(false);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: fixture.container,
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
      final welcome = tester.element(find.byType(WelcomePage));
      subscription = fixture.container.listen(appInitStateProvider, (_, value) {
        transitions.add(value);
      });
      final firstStatisticsLoads = fixture.statisticsLoads;
      await tester.runAsync(() async {
        final completed = await fixture.container
            .read(welcomeOnboardingProvider)
            .complete(l10n: lookupAppLocalizations(const Locale('zh')));
        expect(completed, isTrue);
      });
      expect(welcome.mounted, isTrue, reason: '重跑没有切回loading导致原欢迎页面提前销毁');
      expect(
        transitions.where((state) => state != AppInitState.ready),
        isEmpty,
      );
      expect(fixture.container.read(appInitStateProvider), AppInitState.ready);
      expect(fixture.container.read(shouldShowWelcomeProvider), isFalse);
      expect(fixture.container.read(isAppLockedProvider), isFalse);
      expect(security.pinReads, 1);
      expect(
        fixture.statisticsLoads,
        greaterThanOrEqualTo(firstStatisticsLoads),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('welcome_shown'), isTrue);
      expect(fixture.monitor.starts, 1);
      expect(fixture.credentialRefreshes, 1);
      expect(tester.takeException(), isNull);
    } catch (error, stackTrace) {
      fail('真实欢迎流程重跑回归失败：$error\n$stackTrace');
    } finally {
      subscription?.close();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(fixture.dispose);
    }
  });
}
