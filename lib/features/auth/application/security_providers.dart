import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// AppLockService 的 provider 门面：页面只依赖 providers 层，便于测试替换。
final appLockServiceProvider = Provider<AppLockServiceFacade>(
  (ref) => const AppLockServiceFacade(),
);

/// AppLockService 静态方法集合的实例门面。
class AppLockServiceFacade {
  const AppLockServiceFacade();

  Future<void> setPin(String pin) => AppLockService.setPin(pin);

  Future<bool> verifyPin(String pin) => AppLockService.verifyPin(pin);

  /// 查询已持久化的 PIN，存储异常由调用方阻断安全初始化。
  Future<bool> hasPin() => AppLockService.hasPin();

  Future<bool> canUseBiometrics() => AppLockService.canUseBiometrics();

  Future<bool> isBiometricEnabled() => AppLockService.isBiometricEnabled();

  Future<bool> authenticateWithBiometrics({required String reason}) =>
      AppLockService.authenticateWithBiometrics(reason: reason);

  /// 清除 PIN 与关联的应用锁设置。
  Future<void> clearPin() => AppLockService.clearPin();

  /// 只持久化应用锁开关，PIN 的复合设置由独立动作完成。
  Future<void> setEnabled(bool enabled) => AppLockService.setEnabled(enabled);

  /// 持久化生物识别开关。
  Future<void> setBiometricEnabled(bool enabled) =>
      AppLockService.setBiometricEnabled(enabled);

  /// 持久化自动上锁超时秒数。
  Future<void> setTimeoutSeconds(int seconds) =>
      AppLockService.setTimeoutSeconds(seconds);

  void recordUnlock() => AppLockService.recordUnlock();
}

// 应用是否处于锁定状态
final isAppLockedProvider = NotifierProvider<SimpleStateNotifier<bool>, bool>(
  () => SimpleStateNotifier((ref) => false),
);

// 隐私模糊屏是否显示（多任务切换时）
final showPrivacyScreenProvider =
    NotifierProvider<SimpleStateNotifier<bool>, bool>(
      () => SimpleStateNotifier((ref) => false),
    );

/// 应用锁或后台隐私屏任一成立时，业务内容必须同时退出交互与辅助语义树。
bool shouldHideAppContent({
  required bool locked,
  required bool privacyScreen,
}) => locked || privacyScreen;

/// 持久化设置共用串行写入边界，成功落盘后才向页面发布状态。
abstract class AppLockSettingNotifier<T> extends Notifier<T> {
  Future<void>? _pendingWrite;

  /// 只同步已确认的存储事实，不产生新的平台写入。
  void load(T value) => state = value;

  /// 各设置通过同一服务门面执行实际存储写入。
  Future<void> _persist(T value);

  /// 调用方等待本次落盘，失败保留原状态并收到可重试异常。
  Future<void> set(T value) {
    final next = (_pendingWrite ?? Future<void>.value()).then((_) async {
      try {
        if (!ref.mounted) throw StateError('应用锁设置已失效，请重新操作');
        await _persist(value);
        if (ref.mounted) load(value);
      } catch (error, stackTrace) {
        logger.error('AppLock', '应用锁设置保存失败', error, stackTrace);
        rethrow;
      }
    });
    // 当前调用保留失败结果，队列仍可接受用户的下一次重试。
    late final Future<void> settled;
    settled = next.catchError((Object _) {}).whenComplete(() {
      if (identical(_pendingWrite, settled)) _pendingWrite = null;
    });
    _pendingWrite = settled;
    return next;
  }
}

/// 应用锁开关的持久化状态，不隐式创建或清除 PIN。
class AppLockEnabledNotifier extends AppLockSettingNotifier<bool> {
  /// PIN 保存由应用状态持有，页面关闭不会丢失成功写入后的开关更新。
  Future<void> createPin(String pin) async {
    try {
      await ref.read(appLockServiceProvider).setPin(pin);
      if (ref.mounted) load(true);
    } catch (error, stackTrace) {
      logger.error('AppLock', 'PIN 设置未完成', safeErrorSummary(error), stackTrace);
      rethrow;
    }
  }

  /// 清除 PIN 的复合操作成功后，同时发布应用锁与生物识别关闭状态。
  Future<void> clearPin() async {
    try {
      await ref.read(appLockServiceProvider).clearPin();
      if (!ref.mounted) return;
      load(false);
      ref.read(appLockBiometricEnabledProvider.notifier).load(false);
    } catch (error, stackTrace) {
      logger.error(
        'AppLock',
        '清除 PIN 未完成',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  bool build() => false;

  @override
  Future<void> _persist(bool value) =>
      ref.read(appLockServiceProvider).setEnabled(value);
}

/// 生物识别开关在平台写入完成后生效。
class AppLockBiometricNotifier extends AppLockSettingNotifier<bool> {
  @override
  bool build() => false;

  @override
  Future<void> _persist(bool value) =>
      ref.read(appLockServiceProvider).setBiometricEnabled(value);
}

/// 自动上锁超时以秒保存，页面与恢复前台读取同一存储值。
class AppLockTimeoutNotifier extends AppLockSettingNotifier<int> {
  @override
  int build() => 0;

  @override
  Future<void> _persist(int value) =>
      ref.read(appLockServiceProvider).setTimeoutSeconds(value);
}

/// 应用锁是否启用。
final appLockEnabledProvider = NotifierProvider<AppLockEnabledNotifier, bool>(
  AppLockEnabledNotifier.new,
);

/// 生物识别是否启用。
final appLockBiometricEnabledProvider =
    NotifierProvider<AppLockBiometricNotifier, bool>(
      AppLockBiometricNotifier.new,
    );

/// 超时时间：0 为立即，60/300/900 分别为 1/5/15 分钟。
final appLockTimeoutProvider = NotifierProvider<AppLockTimeoutNotifier, int>(
  AppLockTimeoutNotifier.new,
);

/// 确认完整的应用锁状态后再开放业务；读取失败保留错误并阻断初始化。
final securityInitProvider = FutureProvider<void>((ref) async {
  try {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    var enabled = prefs.getBool(AppLockService.prefsKeyEnabled) ?? false;
    final biometric =
        prefs.getBool(AppLockService.prefsKeyBiometricEnabled) ?? false;
    final timeout = prefs.getInt(AppLockService.prefsKeyTimeoutSeconds) ?? 0;
    // 只在查询确认为没有 PIN 时修复设置；存储不可读取不能视为 PIN 不存在。
    if (enabled && !(await ref.read(appLockServiceProvider).hasPin())) {
      await ref.read(appLockServiceProvider).setEnabled(false);
      enabled = false;
    }
    if (!ref.mounted) return;
    // 所有必需读取与修复成功后再一起发布，避免 UI 消费半初始化的安全状态。
    ref.read(appLockEnabledProvider.notifier).load(enabled);
    ref.read(appLockBiometricEnabledProvider.notifier).load(biometric);
    ref.read(appLockTimeoutProvider.notifier).load(timeout);
    ref.read(isAppLockedProvider.notifier).set(enabled);
  } catch (error, stackTrace) {
    logger.error(
      'AppLock',
      '安全设置暂时无法读取，请重试',
      safeErrorSummary(error),
      stackTrace,
    );
    rethrow;
  }
});
