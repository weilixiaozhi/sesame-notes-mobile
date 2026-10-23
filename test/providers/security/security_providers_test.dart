import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import '../../helpers/test_isolation.dart';

/// 控制 PIN 存储读取失败，区分不可读取与确认为空的两种状态。
class _UnreadablePinService extends AppLockServiceFacade {
  /// 读取错误不能被解释为用户未设置 PIN。
  @override
  Future<bool> hasPin() async => throw StateError('injected pin read failure');
}

/// 在插件平台存储层统计真实设置写入，并控制完成时刻与拒绝结果。
class _RecordingPreferencesStore extends InMemorySharedPreferencesStore {
  _RecordingPreferencesStore(Map<String, Object> values)
    : super.withData({
        for (final entry in values.entries) 'flutter.${entry.key}': entry.value,
      });

  final writes = <String>[];
  bool rejectWrites = false;
  Completer<void>? writeBarrier;

  /// 只统计应用锁设置，日志保存等其他偏好不影响验收结果。
  List<String> get settingWrites =>
      writes.where((key) => key.startsWith('app_lock_')).toList();

  /// 写入可暂缓或返回 false，模拟插件实际的异步提交与存储失败。
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes.add(key.replaceFirst('flutter.', ''));
    if (key.startsWith('flutter.app_lock_')) {
      await writeBarrier?.future;
      if (rejectWrites) return false;
    }
    return super.setValue(valueType, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  /// 替换插件平台存储；每项测试结束恢复静态实例和偏好缓存。
  _RecordingPreferencesStore installStore(Map<String, Object> values) {
    final previous = SharedPreferencesStorePlatform.instance;
    final store = _RecordingPreferencesStore(values);
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = store;
    addTearDown(() {
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    });
    return store;
  }

  group('securityInitProvider', () {
    test('PIN 读取失败不禁用已保存的应用锁，也不发布部分安全状态', () async {
      SharedPreferences.setMockInitialValues({
        AppLockService.prefsKeyEnabled: true,
      });
      final scope = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          appLockServiceProvider.overrideWithValue(_UnreadablePinService()),
        ],
      );
      addTearDown(scope.dispose);
      try {
        await expectLater(
          scope.read(securityInitProvider.future),
          throwsA(anything),
        );
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AppLockService.prefsKeyEnabled), isTrue);
        expect(
          scope.read(appLockEnabledProvider),
          isFalse,
          reason: '读取未确认前不发布半初始化状态',
        );
        expect(
          logger.logs.any((entry) => entry.message.contains('安全设置暂时无法读取')),
          isTrue,
        );
      } catch (error, stackTrace) {
        fail('PIN 读取失败边界回归失败：$error\n$stackTrace');
      }
    });

    test('空 prefs → 默认关闭、不锁定', () async {
      await container.read(securityInitProvider.future);

      expect(container.read(appLockEnabledProvider), isFalse);
      expect(container.read(appLockBiometricEnabledProvider), isFalse);
      expect(container.read(appLockTimeoutProvider), 0);
      expect(container.read(isAppLockedProvider), isFalse);
    });

    test('已启用且有 PIN → 启动即锁定', () async {
      await AppLockService.setPin('1234');
      await container.read(securityInitProvider.future);

      expect(container.read(appLockEnabledProvider), isTrue);
      expect(
        container.read(isAppLockedProvider),
        isTrue,
        reason: '启用应用锁时启动应进入锁定态',
      );
    });

    test('启用了但无 PIN（脏状态）→ 自动禁用并写回 prefs', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppLockService.prefsKeyEnabled, true);

      await container.read(securityInitProvider.future);

      expect(
        container.read(appLockEnabledProvider),
        isFalse,
        reason: '有锁无 PIN 属于脏状态，应自动禁用',
      );
      expect(prefs.getBool(AppLockService.prefsKeyEnabled), isFalse);
    });

    test('直接设置 provider 并等待持久化完成', () async {
      await container.read(securityInitProvider.future);
      final prefs = await SharedPreferences.getInstance();

      await container.read(appLockEnabledProvider.notifier).set(true);
      await container.read(appLockTimeoutProvider.notifier).set(300);
      await container.read(appLockBiometricEnabledProvider.notifier).set(true);
      expect(prefs.getBool(AppLockService.prefsKeyEnabled), isTrue);
      expect(prefs.getInt(AppLockService.prefsKeyTimeoutSeconds), 300);
      expect(prefs.getBool(AppLockService.prefsKeyBiometricEnabled), isTrue);
    });
  });

  group('应用锁设置持久化所有权', () {
    test('初始化和内存同步不写平台，每个直接 set 只写一次', () async {
      final store = installStore({});
      await container.read(securityInitProvider.future);
      container.read(appLockEnabledProvider.notifier).load(false);
      container.read(appLockBiometricEnabledProvider.notifier).load(false);
      container.read(appLockTimeoutProvider.notifier).load(0);
      expect(store.settingWrites, isEmpty);

      await container.read(appLockEnabledProvider.notifier).set(true);
      await container.read(appLockBiometricEnabledProvider.notifier).set(true);
      await container.read(appLockTimeoutProvider.notifier).set(300);
      await Future<void>.delayed(Duration.zero);
      expect(store.settingWrites, [
        AppLockService.prefsKeyEnabled,
        AppLockService.prefsKeyBiometricEnabled,
        AppLockService.prefsKeyTimeoutSeconds,
      ]);
    });

    test('平台提交未完成时状态保持原值，set 等待成功后才生效', () async {
      final store = installStore({});
      await container.read(securityInitProvider.future);
      store.writeBarrier = Completer<void>();
      final pending = container.read(appLockEnabledProvider.notifier).set(true);
      await Future<void>.delayed(Duration.zero);
      expect(store.settingWrites, [AppLockService.prefsKeyEnabled]);
      expect(container.read(appLockEnabledProvider), isFalse);
      store.writeBarrier!.complete();
      await pending;
      expect(container.read(appLockEnabledProvider), isTrue);
    });

    for (final setting in ['enabled', 'biometric', 'timeout']) {
      test('$setting 平台拒绝写入时不发布新状态，并允许下一次重试', () async {
        final store = installStore({
          AppLockService.prefsKeyEnabled: false,
          AppLockService.prefsKeyBiometricEnabled: false,
          AppLockService.prefsKeyTimeoutSeconds: 0,
        });
        await container.read(securityInitProvider.future);

        /// 发起同一设置动作，失败后再次调用仍走相同公开入口。
        Future<void> save() => switch (setting) {
          'enabled' =>
            container.read(appLockEnabledProvider.notifier).set(true),
          'biometric' =>
            container.read(appLockBiometricEnabledProvider.notifier).set(true),
          _ => container.read(appLockTimeoutProvider.notifier).set(300),
        };

        store.rejectWrites = true;
        await expectLater(save(), throwsStateError);
        expect(container.read(appLockEnabledProvider), isFalse);
        expect(container.read(appLockBiometricEnabledProvider), isFalse);
        expect(container.read(appLockTimeoutProvider), 0);
        // 插件可能先写内存缓存，失败后重读确保恢复前台也看到真实旧设置。
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AppLockService.prefsKeyEnabled), isFalse);
        expect(prefs.getBool(AppLockService.prefsKeyBiometricEnabled), isFalse);
        expect(prefs.getInt(AppLockService.prefsKeyTimeoutSeconds), 0);
        expect(
          logger.logs
              .where((entry) => entry.tag == 'AppLock')
              .map((entry) => entry.message),
          contains('应用锁设置保存失败'),
        );

        store.rejectWrites = false;
        await save();
        expect(store.settingWrites.length, 2);
        expect(switch (setting) {
          'enabled' => container.read(appLockEnabledProvider),
          'biometric' => container.read(appLockBiometricEnabledProvider),
          _ => container.read(appLockTimeoutProvider) == 300,
        }, isTrue);
      });
    }

    test('PIN 复合动作后的 load 只同步内存，不重复写入开关', () async {
      final store = installStore({});
      await container.read(securityInitProvider.future);
      final facade = container.read(appLockServiceProvider);
      await facade.setPin('1234');
      container.read(appLockEnabledProvider.notifier).load(true);
      expect(
        store.settingWrites.where(
          (key) => key == AppLockService.prefsKeyEnabled,
        ),
        hasLength(1),
      );

      await facade.clearPin();
      container.read(appLockEnabledProvider.notifier).load(false);
      container.read(appLockBiometricEnabledProvider.notifier).load(false);
      expect(
        store.settingWrites.where(
          (key) => key == AppLockService.prefsKeyEnabled,
        ),
        hasLength(2),
      );
      expect(
        store.settingWrites.where(
          (key) => key == AppLockService.prefsKeyBiometricEnabled,
        ),
        hasLength(1),
      );
    });
  });

  group('AppLockServiceFacade', () {
    test('setPin / verifyPin / hasPin / recordUnlock', () async {
      final facade = container.read(appLockServiceProvider);

      expect(await AppLockService.hasPin(), isFalse);
      await facade.setPin('1234');
      expect(await AppLockService.hasPin(), isTrue);
      expect(await facade.verifyPin('1234'), isTrue);
      expect(await facade.verifyPin('0000'), isFalse);
      facade.recordUnlock();
    });
  });
}
