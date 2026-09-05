// 设置类二级页面测试：语言、应用锁、提醒设置、日志中心。
//
// 用 ProviderContainer + 真实 SharedPreferences mock，验证页面渲染、交互后
// provider 状态与持久化落盘，以及页面间导航。

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show PendingNotificationRequest;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/features/auth/presentation/pin_setup_page.dart';
import 'package:sesame_notes/features/settings/presentation/app_lock_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/config_import_export_page.dart';
import 'package:sesame_notes/features/settings/presentation/language_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/reminder_settings_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/settings/application/reminder_providers.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/shared/widgets/wheel_time_picker.dart';

import '../../helpers/test_isolation.dart';

/// 内存假通知实现：不触碰平台通道，仅记录调用。
class _FakeNotificationUtil extends NotificationUtil {
  final List<String> calls = [];

  @override
  Future<void> cancelAllNotifications() async => calls.add('cancelAll');

  @override
  Future<void> cancelNotification(int id) async => calls.add('cancel:$id');

  @override
  Future<bool> checkPermissionStatus() async => true;

  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async =>
      const [];

  @override
  Future<void> initialize() async => calls.add('initialize');

  @override
  Future<bool> requestPermissions() async {
    calls.add('requestPermissions');
    return true;
  }

  @override
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    calls.add('daily:$id');
  }

  @override
  Future<void> scheduleOnceReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    calls.add('once:$id');
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    calls.add('show:$id');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
  });

  tearDown(() async => db.close());

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createAppRouter(home: () => page),
        ),
      ),
    );
    await tester.pump();
  }

  /// 在数字键盘上依次输入 PIN 数字。
  Future<void> enterPinDigits(WidgetTester tester, String pin) async {
    for (final ch in pin.split('')) {
      await tester.tap(find.text(ch));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// 应用锁已开启的初始环境：真实 prefs 写入 PIN，provider 同步为开启。
  Future<void> seedAppLockEnabled() async {
    await AppLockService.setPin('1234');
    container.read(appLockEnabledProvider.notifier).set(true);
  }

  group('LanguageSettingsPage', () {
    testWidgets('渲染全部语言项；选择中文/跟随系统并持久化', (tester) async {
      await pumpPage(tester, const LanguageSettingsPage());

      expect(find.text('简体中文'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);

      // 选择简体中文 → provider 状态 + prefs 落盘
      await tester.tap(find.text('简体中文'));
      await tester.pumpAndSettle();
      expect(container.read(languageProvider), const Locale('zh'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), 'zh');

      // 切回跟随系统
      await tester.tap(find.text('跟随系统'));
      await tester.pumpAndSettle();
      expect(container.read(languageProvider), isNull);
      expect(prefs.getString('selected_language'), isNull);
    });
  });

  group('AppLockSettingsPage', () {
    testWidgets('开启应用锁 → 跳转 PIN 设置页', (tester) async {
      await pumpPage(tester, const AppLockSettingsPage());

      expect(find.text('应用上锁'), findsWidgets);
      // 开关初始关闭；点击开关触发 PIN 设置导航
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(find.byType(PinSetupPage), findsOneWidget);
    });

    testWidgets('开启全流程：设置 PIN 后开启并持久化，展示管理区段', (tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpPage(tester, const AppLockSettingsPage());
      expect(container.read(appLockEnabledProvider), isFalse);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(find.byType(PinSetupPage), findsOneWidget);

      // create 模式：首次输入 + 二次确认
      await enterPinDigits(tester, '1234');
      await tester.pumpAndSettle();
      await enterPinDigits(tester, '1234');
      await tester.pumpAndSettle();

      expect(container.read(appLockEnabledProvider), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppLockService.prefsKeyEnabled), isTrue);
      // 已开启后展示 PIN 管理与超时区段
      expect(find.text('修改密码'), findsOneWidget);
      expect(find.text('自动锁定时间'), findsOneWidget);
      // 冲刷 PIN 设置 toast(1s)与 LoggerService 保存定时器(2s)
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('关闭应用锁：验证当前 PIN 成功后关闭并提示', (tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await seedAppLockEnabled();
      await pumpPage(tester, const AppLockSettingsPage());
      expect(container.read(appLockEnabledProvider), isTrue);

      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(find.text('请输入当前密码'), findsOneWidget);

      // 输错 → 错误态并自动清空
      await enterPinDigits(tester, '0000');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 600));

      // 输入正确 PIN → 关闭成功
      await enterPinDigits(tester, '1234');
      await tester.pumpAndSettle();

      expect(container.read(appLockEnabledProvider), isFalse);
      expect(find.text('应用锁已关闭'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppLockService.prefsKeyPinHash), isNull);
      await tester.pump(const Duration(seconds: 2)); // toast 定时器
    });

    testWidgets('修改密码：跳转 PIN 修改页并可返回', (tester) async {
      tester.view.physicalSize = const Size(600, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await seedAppLockEnabled();
      await pumpPage(tester, const AppLockSettingsPage());

      await tester.tap(find.text('修改密码'));
      await tester.pumpAndSettle();
      expect(find.byType(PinSetupPage), findsOneWidget);

      // PrimaryHeader 自定义返回按钮
      await tester.tap(find.byIcon(AppIcons.back));
      await tester.pumpAndSettle();
      expect(find.text('应用上锁'), findsOneWidget);
      // 冲刷 seedAppLockEnabled 触发的 LoggerService 保存定时器(2s)
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('超时设置：底部弹层选择 1 分钟后并持久化', (tester) async {
      await seedAppLockEnabled();
      await pumpPage(tester, const AppLockSettingsPage());

      await tester.tap(find.text('自动锁定时间'));
      await tester.pumpAndSettle();
      expect(find.text('1分钟后'), findsOneWidget);
      expect(
        find.byType(SheetGrabHandle),
        findsOneWidget,
        reason: '底部弹层应有统一拖拽条',
      );

      await tester.tap(find.text('1分钟后'));
      await tester.pumpAndSettle();

      expect(container.read(appLockTimeoutProvider), 60);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(AppLockService.prefsKeyTimeoutSeconds), 60);
      // 冲刷 seedAppLockEnabled 触发的 LoggerService 保存定时器(2s)
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('ReminderSettingsPage', () {
    testWidgets('开关提醒并持久化；时间行弹出滚轮选择', (tester) async {
      final fakeNotifications = _FakeNotificationUtil();
      NotificationFactory.setInstanceForTesting(fakeNotifications);
      await pumpPage(tester, const ReminderSettingsPage());

      expect(container.read(reminderSettingsProvider).isEnabled, isFalse);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(container.read(reminderSettingsProvider).isEnabled, isTrue);
      expect(fakeNotifications.calls, contains('requestPermissions'));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), isTrue);

      // 时间行 → 滚轮选择器
      await tester.tap(find.text('提醒时间'));
      await tester.pumpAndSettle();
      expect(find.byType(WheelTimePicker), findsOneWidget);
      expect(
        find.byType(SheetGrabHandle),
        findsOneWidget,
        reason: '时间滚轮底部弹层应有统一拖拽条',
      );
    });

    testWidgets('时间滚轮确定后更新并持久化', (tester) async {
      final fakeNotifications = _FakeNotificationUtil();
      NotificationFactory.setInstanceForTesting(fakeNotifications);
      await pumpPage(tester, const ReminderSettingsPage());

      await tester.tap(find.text('提醒时间'));
      await tester.pumpAndSettle();
      expect(find.byType(WheelTimePicker), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt(ReminderPrefs.hour), isNotNull);
      expect(prefs.getInt(ReminderPrefs.minute), isNotNull);
    });

    testWidgets('发送测试通知：调用通知服务并提示', (tester) async {
      final fakeNotifications = _FakeNotificationUtil();
      NotificationFactory.setInstanceForTesting(fakeNotifications);
      await pumpPage(tester, const ReminderSettingsPage());

      await tester.tap(find.text('发送测试通知'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(fakeNotifications.calls, contains('show:9999'));
      expect(find.text('测试通知已发送'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2)); // toast 定时器
    });
  });

  group('ConfigImportExportPage', () {
    testWidgets('导出配置：选项对话框 → 预览 → 取消（不落盘）', (tester) async {
      await pumpPage(tester, const ConfigImportExportPage());

      expect(find.text('导出配置'), findsOneWidget);
      expect(find.text('导入配置'), findsOneWidget);

      // 打开导出选项对话框
      await tester.tap(find.text('导出配置'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('账本'), findsWidgets);

      // 默认全选，直接下一步 → 生成 YAML 预览
      await tester.tap(find.text('下一步'));
      // 导出中 tile 会显示旋转指示器，pumpAndSettle 永不落定，用显式 pump
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('导出预览'), findsOneWidget);
      // 预览区是可选中 YAML 文本
      expect(find.byType(SelectableText), findsOneWidget);

      // 取消导出：不写文件、回到页面
      await tester.tap(find.text('取消'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Dialog), findsNothing);
      expect(find.text('导出配置'), findsOneWidget);
    });

    testWidgets('导入配置：选择文件 → 预览 → 确认 → 成功提示与重启对话框', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      final tempDir = Directory.systemTemp.createTempSync('cfg_import');
      addTearDown(() {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      });
      final yamlFile = File('${tempDir.path}/config.yaml');
      yamlFile.writeAsStringSync(
        'app_id: sesame_notes\n'
        'format_version: 1\n'
        'ledgers:\n  items: []\n'
        'categories:\n  items: []\n'
        'recurring_transactions:\n  items: []\n',
      );

      const pickerChannel = MethodChannel(
        'miguelruivo.flutter.plugins.filepicker',
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pickerChannel,
        // 通道方法名是文件类型（如 custom/any），统一返回所选文件列表
        (call) async => [
          {
            'path': yamlFile.path,
            'name': 'config.yaml',
            'size': 100,
            'identifier': 'f1',
            'type': 'file',
          },
        ],
      );
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pickerChannel,
          null,
        ),
      );

      await pumpPage(tester, const ConfigImportExportPage());
      await tester.ensureVisible(find.text('导入配置'));
      await tester.pump(const Duration(milliseconds: 100));
      // 文件读取是真实 IO，必须在 runAsync 中推进事件循环
      await tester.runAsync(() async {
        await tester.tap(find.text('导入配置'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 导入预览对话框 → 确认导入
      expect(find.text('导入预览'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('确认导入'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('配置导入成功'), findsOneWidget);
      expect(find.text('需要重启'), findsOneWidget);
      await tester.tap(find.text('确定'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3)); // toast + 保存定时器
    });

    testWidgets('导入配置：取消选择文件时不弹预览', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      const pickerChannel = MethodChannel(
        'miguelruivo.flutter.plugins.filepicker',
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pickerChannel,
        (call) async => null,
      );
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pickerChannel,
          null,
        ),
      );

      await pumpPage(tester, const ConfigImportExportPage());
      await tester.ensureVisible(find.text('导入配置'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('导入配置'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('导入预览'), findsNothing);
      expect(find.text('配置导入失败'), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('导入配置：文件无路径时展示导入失败对话框', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      const pickerChannel = MethodChannel(
        'miguelruivo.flutter.plugins.filepicker',
      );
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        pickerChannel,
        // 通道方法名是文件类型（如 custom/any），返回一个无路径文件
        (call) async => [
          {'path': null, 'name': 'config.yaml'},
        ],
      );
      addTearDown(
        () => binding.defaultBinaryMessenger.setMockMethodCallHandler(
          pickerChannel,
          null,
        ),
      );

      await pumpPage(tester, const ConfigImportExportPage());
      await tester.ensureVisible(find.text('导入配置'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await tester.tap(find.text('导入配置'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('配置导入失败'), findsOneWidget);
      await tester.tap(find.text('确定'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('导出配置：确认后走分享通道并提示成功', (tester) async {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      final tempDir = Directory.systemTemp.createTempSync('cfg_export');
      addTearDown(() {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      });
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getTemporaryDirectory') return tempDir.path;
          return null;
        },
      );
      const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        shareChannel,
        (call) async => 'dev.fluttercommunity.plus/share/success',
      );
      addTearDown(() {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          shareChannel,
          null,
        );
      });

      await pumpPage(tester, const ConfigImportExportPage());
      await tester.ensureVisible(find.text('导出配置'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await tester.tap(find.text('导出配置'));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Dialog), findsOneWidget);

      // 默认全选 → 下一步 → 导出预览
      await tester.runAsync(() async {
        await tester.tap(find.text('下一步'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('导出预览'), findsOneWidget);

      // 确认导出 → 写临时文件 + 分享成功 → toast
      await tester.runAsync(() async {
        await tester.tap(find.text('确认导出'));
        await Future<void>.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('配置导出成功'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
