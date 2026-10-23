import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/presentation/reminder_settings_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/providers/reminder_system_status_provider.dart';
import 'package:sesame_notes/shared/services/notification/notification_android.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/wheel_time_picker.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import '../../helpers/test_isolation.dart';

/// 控制保存时机，验证页面等待、成功和失败时的交互状态。
class _ControlledReminderSettings extends ReminderSettingsNotifier {
  /// 使用指定初始配置创建测试设置。
  _ControlledReminderSettings(this.initial);
  final ReminderSettings initial;
  final List<ReminderSettings> requests = [];
  Completer<void>? saveGate;
  bool failSave = false;

  /// 同步提供已加载配置。
  @override
  ReminderSettings build() => initial;

  /// 模拟保存完成前保持旧配置，成功后才提交新值。
  @override
  Future<void> updateSettings(ReminderSettings settings) async {
    try {
      requests.add(settings);
      await saveGate?.future;
      if (failSave) throw StateError('模拟提醒配置保存失败');
      state = settings;
    } catch (_) {
      rethrow;
    }
  }
}

/// 验证窄屏设置布局、系统跳转和保存中的稳定交互。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('notification_channel');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const initial = ReminderSettings(
    isEnabled: true,
    hour: 21,
    minute: 0,
    notificationsEnabled: true,
    daysEnabled: true,
  );
  const info = <String, Map<String, dynamic>?>{
    'accounting_reminder': {
      'isEnabled': true,
      'importance': 'high',
      'sound': true,
      'vibration': true,
      'bypassDnd': false,
    },
    'days_reminder': {
      'isEnabled': false,
      'importance': 'none',
      'sound': false,
      'vibration': false,
      'bypassDnd': true,
    },
    'fitness_rest_alarm_v2': null,
  };
  late List<MethodCall> calls;
  late _ControlledReminderSettings settings;
  late bool autoStartAvailable, failOpen, failBattery, batteryIgnoring;
  late int batteryReads, channelReads;

  setUp(() {
    resetGlobalTestState();
    calls = [];
    settings = _ControlledReminderSettings(initial);
    autoStartAvailable = true;
    failOpen = false;
    failBattery = false;
    batteryIgnoring = false;
    batteryReads = 0;
    channelReads = 0;
    NotificationFactory.setInstanceForTesting(
      AndroidNotificationUtil(FlutterLocalNotificationsPlugin()),
    );
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'getBatteryOptimizationInfo':
          if (failBattery) {
            throw PlatformException(code: 'battery_status_unavailable');
          }
          return <String, dynamic>{
            'isIgnoring': batteryIgnoring,
            'manufacturer': 'Fixture manufacturer',
            'model': 'Fixture model',
            'androidVersion': 'Fixture Android version',
          };
        case 'getNotificationChannelInfo':
          return info[(call.arguments as Map)['channelId']] ??
              {'channelExists': false};
        case 'openAutoStartSettings':
          if (failOpen) throw PlatformException(code: 'settings_unavailable');
          return autoStartAvailable;
        case 'openAppSettings':
        case 'openAppNotificationSettings':
          if (failOpen) throw PlatformException(code: 'settings_unavailable');
          return null;
        default:
          throw StateError(call.method);
      }
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    NotificationFactory.reset();
  });

  /// 渲染真实页面，默认隔离系统诊断，按需验证实际平台通道。
  Future<AppLocalizations> pumpSettings(
    WidgetTester tester, {
    ThemeData? theme,
    double height = 900,
    double textScale = 1,
    bool real = false,
    bool supported = true,
  }) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          reminderSettingsProvider.overrideWith(() => settings),
          reminderSupportedProvider.overrideWithValue(supported),
          exactReminderPermissionProvider.overrideWith((ref) async => true),
          if (!real) ...[
            reminderBatteryInfoProvider.overrideWith((ref) async {
              batteryReads++;
              return {
                'isIgnoring': batteryIgnoring,
                'manufacturer': 'Fixture manufacturer',
                'model': 'Fixture model',
                'androidVersion': 'Fixture Android version',
              };
            }),
            reminderChannelInfoProvider.overrideWith((ref) async {
              channelReads++;
              return info;
            }),
          ],
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const ReminderSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(
      tester.element(find.byType(ReminderSettingsPage)),
    );
  }

  /// 滚动到目标控件后完成动画，适用于紧凑屏幕。
  Future<void> reveal(WidgetTester tester, Finder finder) async {
    final scrollable = find.byType(Scrollable).first;
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(finder, 180, scrollable: scrollable);
    await tester.pumpAndSettle();
  }

  /// 计算居中轨道的可见边界，开关热区的上下留白不计入绘制高度。
  Rect switchTrackBounds(WidgetTester tester, Finder finder) {
    final box = tester.renderObject<RenderBox>(finder);
    // Material 3 的轨道为 52×32，位于较高的点击区域中心。
    final track = Rect.fromCenter(
      center: box.size.center(Offset.zero),
      width: 52,
      height: 32,
    );
    return Rect.fromPoints(
      box.localToGlobal(track.topLeft),
      box.localToGlobal(track.bottomRight),
    );
  }

  /// 检查保存等待不会触发开关或提前日期的禁用样式。
  Future<void> expectEnabled(WidgetTester tester) async {
    for (final key in [
      'notifications-master',
      'notifications-daily',
      'notifications-days',
      'notifications-rest',
    ]) {
      final tile = find.byKey(ValueKey(key));
      await reveal(tester, tile);
      expect(tester.widget<AppSwitchTile>(tile).onChanged, isNotNull);
    }
    await reveal(
      tester,
      find.byKey(const ValueKey('notification-day-offsets')),
    );
    final chips = tester.widgetList<FilterChip>(find.byType(FilterChip));
    expect(chips, hasLength(4));
    for (final chip in chips) {
      expect(chip.onSelected, isNotNull);
    }
  }

  testWidgets('不支持提醒的平台显示原因并禁用全部可提交控件', (tester) async {
    final l = await pumpSettings(tester, supported: false);
    expect(find.text(l.reminderPlatformUnsupported), findsOneWidget);

    for (final key in [
      'notifications-master',
      'notifications-daily',
      'notifications-days',
      'notifications-rest',
    ]) {
      final tile = find.byKey(ValueKey(key));
      await reveal(tester, tile);
      expect(tester.widget<AppSwitchTile>(tile).onChanged, isNull);
    }
    final offsets = find.byKey(const ValueKey('notification-day-offsets'));
    await reveal(tester, offsets);
    for (final chip in tester.widgetList<FilterChip>(
      find.descendant(of: offsets, matching: find.byType(FilterChip)),
    )) {
      expect(chip.onSelected, isNull);
    }
    final daily = find.byKey(const ValueKey('notifications-days-daily'));
    await reveal(tester, daily);
    expect(tester.widget<CheckboxListTile>(daily).onChanged, isNull);
    for (final key in ['notification-daily-time', 'notification-days-time']) {
      final tile = find.byKey(ValueKey(key));
      await reveal(tester, tile);
      expect(tester.widget<AppListTile>(tile).onTap, isNull);
    }
    expect(settings.requests, isEmpty);
    expect(batteryReads, 0);
    expect(channelReads, 0);
    expect(calls, isEmpty);
  });

  for (final dark in [false, true]) {
    testWidgets('紧凑开关右侧缩放且与时间可见右缘对齐，深色=$dark', (tester) async {
      final base = dark ? AppTheme.darkTheme() : AppTheme.lightTheme();
      final theme = dark
          ? base.copyWith(
              listTileTheme: base.listTileTheme.copyWith(
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 18,
                  end: 24,
                ),
              ),
            )
          : base;
      final l = await pumpSettings(
        tester,
        theme: theme,
        textScale: dark ? 1.3 : 1,
      );
      final padding = theme.listTileTheme.contentPadding!.resolve(
        TextDirection.ltr,
      );
      for (final key in [
        'notifications-master',
        'notifications-daily',
        'notifications-days',
        'notifications-rest',
      ]) {
        final tile = find.byKey(ValueKey(key));
        await reveal(tester, tile);
        final card = find
            .ancestor(of: tile, matching: find.byType(SectionCard))
            .first;
        final surface = find
            .descendant(of: card, matching: find.byType(Card))
            .first;
        final rect = tester.getRect(surface);
        final model = tester.widget<AppSwitchTile>(tile);
        final title = find.descendant(
          of: tile,
          matching: find.text(model.title),
        );
        final toggle = find.descendant(of: tile, matching: find.byType(Switch));
        final toggleRect = switchTrackBounds(tester, toggle);
        final scaled = find.descendant(
          of: tile,
          matching: find.byKey(const ValueKey('compact-switch')),
        );
        final transform = tester.widget<Transform>(scaled);
        expect(transform.alignment, Alignment.centerRight);
        expect(transform.transform.entry(0, 0), AppDimens.compactSwitchScale);
        expect(transform.transform.entry(1, 1), AppDimens.compactSwitchScale);
        expect(
          toggleRect.width,
          closeTo(52 * AppDimens.compactSwitchScale, 0.01),
        );
        expect(
          toggleRect.height,
          closeTo(32 * AppDimens.compactSwitchScale, 0.01),
        );
        expect(tester.getSize(tile).height, greaterThanOrEqualTo(48));
        expect(model.subtitle, isNull);
        // 全局卡片绘制边框时不挤占内容，左右对齐只由列表行留白决定。
        expect(
          tester.getRect(title).left - rect.left,
          closeTo(padding.left, 0.01),
        );
        expect(rect.right - toggleRect.right, closeTo(padding.right, 0.01));
        final switchTheme = SwitchTheme.of(tester.element(toggle));
        expect(
          tester.widget<Switch>(toggle).padding ?? switchTheme.padding,
          EdgeInsets.zero,
        );
        expect(switchTheme.trackOutlineWidth?.resolve({}), 0);
        expect(
          switchTheme.trackOutlineWidth?.resolve({WidgetState.disabled}),
          0,
        );
        if (key == 'notifications-daily' || key == 'notifications-days') {
          final timeTitle = key == 'notifications-daily'
              ? l.reminderTimeTitle
              : l.reminderDaysTimeTitle;
          final titleLeft = tester.getRect(title).left;
          final timeKey = key == 'notifications-daily'
              ? 'notification-daily-time'
              : 'notification-days-time';
          final timeTile = find.byKey(ValueKey(timeKey));
          await reveal(tester, timeTile);
          final timeText = find.byKey(ValueKey('$timeKey-value'));
          expect(
            tester.getRect(timeText).right,
            closeTo(toggleRect.right, 0.01),
          );
          expect(
            tester.getRect(find.text(timeTitle)).left,
            closeTo(titleLeft, 0.01),
          );
        }
      }
      for (final tile in tester.widgetList<AppListTile>(
        find.byType(AppListTile),
      )) {
        expect(tile.subtitle, isNull);
      }
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({TargetPlatform.android}));
  }

  testWidgets('四个按钮与四个提前日期各自保持一行，说明常驻', (tester) async {
    final l = await pumpSettings(tester);
    final buttons = find.descendant(
      of: find.byKey(const ValueKey('notification-system-actions')),
      matching: find.byType(OutlinedButton),
    );
    expect(buttons, findsNWidgets(4));
    final buttonRects = [
      for (var i = 0; i < 4; i++) tester.getRect(buttons.at(i)),
    ];
    expect(find.text(l.reminderGlobalTitle), findsOneWidget);
    await reveal(
      tester,
      find.byKey(const ValueKey('notification-day-offsets')),
    );
    final chipRects = [
      for (final day in ReminderSettings.allowedDayOffsets)
        tester.getRect(find.byKey(ValueKey('notification-offset-$day'))),
    ];
    for (final rects in [buttonRects, chipRects]) {
      for (final rect in rects) {
        expect(rect.top, rects.first.top);
        expect(rect.width, closeTo(rects.first.width, 0.01));
        expect(rect.left, greaterThanOrEqualTo(16));
        expect(rect.right, lessThanOrEqualTo(344));
      }
    }
    final unselected = tester.widget<FilterChip>(
      find.byKey(const ValueKey('notification-offset-3')),
    );
    expect(unselected.selected, isFalse);
    expect(unselected.side, BorderSide.none);
    await reveal(tester, find.text(l.reminderSystemSettings));
    expect(find.text(l.reminderSystemSettings), findsOneWidget);
    expect(find.text(l.reminderDescription), findsOneWidget);
    expect(find.byType(ExpansionTile), findsNothing);
    expect(find.text('发送测试通知'), findsNothing);
    expect(find.text('提前提醒（可多选）'), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  for (final dark in [false, true]) {
    testWidgets('渠道状态以五列表格归属分类卡片并保留语义颜色，深色=$dark', (tester) async {
      batteryIgnoring = dark;
      final l = await pumpSettings(
        tester,
        real: true,
        theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
        textScale: dark ? 1.3 : 1,
      );
      final context = tester.element(find.byType(ReminderSettingsPage));
      final success = AppTokens.success(context);
      final warning = AppTokens.warning(context);
      final neutral = AppTokens.textSecondary(context);
      final master = find.byKey(const ValueKey('notification-master-card'));
      expect(
        find.descendant(
          of: master,
          matching: find.text(l.reminderCheckBattery),
        ),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(OutlinedButton, l.reminderCheckBattery),
        findsOneWidget,
      );
      expect(find.text('耗电管理状态'), findsNothing);
      for (final deviceInfo in [
        'Fixture manufacturer',
        'Fixture model',
        'Fixture Android version',
      ]) {
        expect(find.textContaining(deviceInfo), findsNothing);
      }
      final battery = find.descendant(
        of: master,
        matching: find.text(
          dark ? l.reminderBatteryIgnored : l.reminderBatteryNotIgnored,
        ),
      );
      expect(tester.widget<Text>(battery).data, startsWith('耗电管理：'));
      expect(
        tester.widget<Text>(battery).style?.color,
        dark ? success : warning,
      );
      final groups = [
        (
          'daily',
          'accounting_reminder',
          [
            (
              'notification',
              l.reminderStatusNotificationLabel,
              l.reminderStatusOn,
              success,
            ),
            (
              'importance',
              l.reminderStatusImportanceLabel,
              l.reminderImportanceHigh,
              success,
            ),
            ('sound', l.reminderStatusSoundLabel, l.reminderStatusOn, success),
            (
              'vibration',
              l.reminderStatusVibrationLabel,
              l.reminderStatusOn,
              success,
            ),
            (
              'dnd',
              l.reminderStatusDndLabel,
              l.reminderStatusDndFollow,
              neutral,
            ),
          ],
        ),
        (
          'days',
          'days_reminder',
          [
            (
              'notification',
              l.reminderStatusNotificationLabel,
              l.reminderStatusOff,
              warning,
            ),
            (
              'importance',
              l.reminderStatusImportanceLabel,
              l.reminderImportanceNone,
              warning,
            ),
            ('sound', l.reminderStatusSoundLabel, l.reminderStatusOff, warning),
            (
              'vibration',
              l.reminderStatusVibrationLabel,
              l.reminderStatusOff,
              warning,
            ),
            (
              'dnd',
              l.reminderStatusDndLabel,
              l.reminderStatusDndBypass,
              success,
            ),
          ],
        ),
      ];
      for (final (cardName, channelId, cells) in groups) {
        final status = find.byKey(ValueKey('notification-status-$channelId'));
        expect(find.descendant(of: master, matching: status), findsNothing);
        await reveal(tester, status);
        final card = find.byKey(ValueKey('notification-$cardName-card'));
        expect(find.descendant(of: card, matching: status), findsOneWidget);
        final table = find.byKey(
          ValueKey('notification-status-table-$channelId'),
        );
        expect(find.descendant(of: status, matching: table), findsOneWidget);
        expect(
          find.descendant(of: table, matching: find.byType(VerticalDivider)),
          findsNWidgets(4),
        );
        expect(
          find.descendant(of: table, matching: find.byType(Scrollable)),
          findsNothing,
        );
        Rect? first;
        double? previousRight;
        for (final (id, label, value, color) in cells) {
          final cellId = 'notification-status-$channelId-$id';
          final cell = find.byKey(ValueKey(cellId));
          expect(find.descendant(of: table, matching: cell), findsOneWidget);
          expect(
            find.descendant(of: cell, matching: find.text(label)),
            findsOneWidget,
          );
          final valueText = find.byKey(ValueKey('$cellId-value'));
          expect(
            find.descendant(of: cell, matching: valueText),
            findsOneWidget,
          );
          expect(tester.widget<Text>(valueText).data, value);
          expect(tester.widget<Text>(valueText).style?.color, color);
          final rect = tester.getRect(cell);
          first ??= rect;
          expect(rect.top, closeTo(first.top, 0.01));
          expect(rect.width, closeTo(first.width, 0.01));
          if (previousRight != null) {
            expect(rect.left, greaterThan(previousRight));
          }
          expect(rect.right, lessThanOrEqualTo(tester.getRect(table).right));
          previousRight = rect.right;
        }
      }
      final restStatus = find.byKey(
        const ValueKey('notification-status-fitness_rest_alarm_v2'),
      );
      await reveal(tester, restStatus);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('notification-rest-card')),
          matching: restStatus,
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: restStatus,
          matching: find.text(l.reminderChannelNotCreated),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('notification-status-table-fitness_rest_alarm_v2'),
        ),
        findsNothing,
      );
      expect(find.byType(AppContentDialog), findsNothing);
      expect(
        calls
            .where((call) => call.method == 'getNotificationChannelInfo')
            .map((call) => (call.arguments as Map)['channelId']),
        ['accounting_reminder', 'days_reminder', 'fitness_rest_alarm_v2'],
      );
      expect(
        calls.where((call) => call.method == 'getBatteryOptimizationInfo'),
        hasLength(1),
      );
      expect(tester.takeException(), isNull);
    }, variant: TargetPlatformVariant({TargetPlatform.android}));
  }

  testWidgets('两类时间按钮打开各自当前时刻，取消选择不提交设置', (tester) async {
    settings = _ControlledReminderSettings(
      initial.copyWith(hour: 7, minute: 35, daysHour: 13, daysMinute: 20),
    );
    final l = await pumpSettings(tester);
    for (final (category, expected) in [
      ('daily', const TimeOfDay(hour: 7, minute: 35)),
      ('days', const TimeOfDay(hour: 13, minute: 20)),
    ]) {
      final button = find.byKey(ValueKey('notification-$category-time-button'));
      await reveal(tester, button);
      expect(tester.widget<TextButton>(button).onPressed, isNotNull);
      expect(
        tester
            .widget<Tooltip>(
              find.ancestor(of: button, matching: find.byType(Tooltip)).first,
            )
            .message,
        l.commonSelectTime,
      );
      await tester.tap(button);
      await tester.pumpAndSettle();
      final picker = find.byType(WheelTimePicker);
      expect(picker, findsOneWidget);
      expect(tester.widget<WheelTimePicker>(picker).initial, expected);
      Navigator.of(tester.element(picker)).pop();
      await tester.pumpAndSettle();
      expect(picker, findsNothing);
      expect(settings.requests, isEmpty);
    }
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('总开关关闭时四个入口仍直接跳转，通知管理不指定渠道', (tester) async {
    settings = _ControlledReminderSettings(
      initial.copyWith(notificationsEnabled: false),
    );
    final l = await pumpSettings(tester);
    for (final label in [
      l.reminderOpenAppSettings,
      l.reminderAutoStartSettings,
      l.reminderCheckChannel,
      l.reminderCheckBattery,
    ]) {
      await tester.tap(find.widgetWithText(OutlinedButton, label));
      await tester.pumpAndSettle();
      expect(find.byType(AppContentDialog), findsNothing);
    }
    expect(calls.map((call) => call.method), [
      'openAppSettings',
      'openAutoStartSettings',
      'openAppNotificationSettings',
      'openAppSettings',
    ]);
    expect(
      calls
          .singleWhere((call) => call.method == 'openAppNotificationSettings')
          .arguments,
      isNull,
    );
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('无自启动入口时左侧设置右侧确定，确定只关闭指引', (tester) async {
    autoStartAvailable = false;
    final l = await pumpSettings(tester);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.reminderAutoStartSettings),
    );
    await tester.pumpAndSettle();
    final dialog = find.byType(AppContentDialog);
    final open = find.descendant(
      of: dialog,
      matching: find.widgetWithText(TextButton, l.commonSettings),
    );
    final confirm = find.descendant(
      of: dialog,
      matching: find.widgetWithText(TextButton, l.commonConfirm),
    );
    expect(find.text(l.reminderAutoStartAdvice), findsOneWidget);
    expect(find.text(l.commonCancel), findsNothing);
    expect(tester.getCenter(open).dx, lessThan(tester.getCenter(confirm).dx));
    await tester.tap(confirm);
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    expect(calls.map((call) => call.method), ['openAutoStartSettings']);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.reminderAutoStartSettings),
    );
    await tester.pumpAndSettle();
    await tester.tap(open);
    await tester.pumpAndSettle();
    expect(calls.map((call) => call.method), [
      'openAutoStartSettings',
      'openAutoStartSettings',
      'openAppSettings',
    ]);
    expect(dialog, findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('系统跳转失败显示友好提示并释放操作锁', (tester) async {
    failOpen = true;
    final l = await pumpSettings(tester);
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.reminderCheckChannel),
    );
    await tester.pumpAndSettle();
    expect(find.text(l.commonOperationFailed), findsOneWidget);
    expect(find.byType(AppContentDialog), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    failOpen = false;
    await tester.tap(
      find.widgetWithText(OutlinedButton, l.reminderCheckChannel),
    );
    await tester.pumpAndSettle();
    expect(calls.map((call) => call.method), [
      'openAppNotificationSettings',
      'openAppNotificationSettings',
    ]);
    expect(find.text(l.commonOperationFailed), findsNothing);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  testWidgets('系统检测失败就地提示并可重试，不显示错误权限结论', (tester) async {
    failBattery = true;
    final l = await pumpSettings(tester, real: true);
    expect(find.text(l.reminderStatusUnavailable), findsOneWidget);
    expect(find.text(l.reminderBatteryNotIgnored), findsNothing);
    expect(find.byType(AppContentDialog), findsNothing);
    failBattery = false;
    await tester.tap(find.text(l.commonRetry));
    await tester.pumpAndSettle();
    expect(find.text(l.reminderStatusUnavailable), findsNothing);
    expect(find.text(l.reminderBatteryNotIgnored), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
  }, variant: TargetPlatformVariant({TargetPlatform.android}));

  for (final fails in [false, true]) {
    testWidgets('保存等待时开关保持可用并即时预览，失败=$fails', (tester) async {
      settings.saveGate = Completer<void>();
      settings.failSave = fails;
      final l = await pumpSettings(tester);
      final tile = find.byKey(const ValueKey('notifications-daily'));
      await reveal(tester, tile);
      await tester.tap(tile);
      await tester.pump();
      expect(tester.widget<AppSwitchTile>(tile).value, isFalse);
      await expectEnabled(tester);
      await reveal(tester, tile);
      await tester.tap(tile);
      await reveal(tester, find.byKey(const ValueKey('notification-offset-3')));
      await tester.tap(find.byKey(const ValueKey('notification-offset-3')));
      await tester.pump();
      expect(settings.requests, hasLength(1));
      await reveal(tester, tile);
      expect(tester.widget<AppSwitchTile>(tile).value, isFalse);
      expect(batteryReads, 1);
      expect(channelReads, 1);
      settings.saveGate!.complete();
      await tester.pumpAndSettle();
      expect(tester.widget<AppSwitchTile>(tile).value, fails);
      expect(
        find.text(l.commonOperationFailed),
        fails ? findsOneWidget : findsNothing,
      );
      await expectEnabled(tester);
      expect(batteryReads, 1);
      expect(channelReads, 1);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 3));
    }, variant: TargetPlatformVariant({TargetPlatform.android}));
  }

  testWidgets('提前日期即时预览且等待保存时不禁用，失败恢复原选项', (tester) async {
    settings.saveGate = Completer<void>();
    settings.failSave = true;
    final l = await pumpSettings(tester);
    final option = find.byKey(const ValueKey('notification-offset-3'));
    await reveal(tester, option);
    expect(tester.widget<FilterChip>(option).selected, isFalse);
    await tester.tap(option);
    await tester.pump();
    expect(tester.widget<FilterChip>(option).selected, isTrue);
    await expectEnabled(tester);
    await reveal(tester, option);
    await tester.tap(option);
    await tester.pump();
    expect(settings.requests, hasLength(1));
    expect(tester.widget<FilterChip>(option).selected, isTrue);
    settings.saveGate!.complete();
    await tester.pumpAndSettle();
    expect(tester.widget<FilterChip>(option).selected, isFalse);
    expect(find.text(l.commonOperationFailed), findsOneWidget);
    await expectEnabled(tester);
    expect(batteryReads, 1);
    expect(channelReads, 1);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
  }, variant: TargetPlatformVariant({TargetPlatform.android}));
}
