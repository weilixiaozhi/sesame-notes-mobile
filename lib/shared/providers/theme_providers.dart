import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';

export 'package:sesame_notes/theme/app_visual_theme.dart' show AppThemePreset;

/// 显示模式与视觉风格分别持有状态，改变任一项都不重建业务状态。
final themeModeProvider =
    NotifierProvider<SimpleStateNotifier<ThemeMode>, ThemeMode>(
      () => SimpleStateNotifier((ref) => ThemeMode.system),
    );

/// 视觉风格默认经典蓝，持久化键与显示模式偏好完全独立。
final themePresetProvider =
    NotifierProvider<SimpleStateNotifier<AppThemePreset>, AppThemePreset>(
      () => SimpleStateNotifier((ref) => AppThemePreset.classic),
    );

/// 保存失败时保留当前视觉效果，设置页通过递增版本展示可重试提示。
final themePreferenceFailureProvider =
    NotifierProvider<SimpleStateNotifier<int>, int>(
      () => SimpleStateNotifier((ref) => 0),
    );

/// 尚未成功保存的偏好按键记录，成功写入只清除对应项。
final themePreferenceUnsavedProvider =
    NotifierProvider<SimpleStateNotifier<Set<String>>, Set<String>>(
      () => SimpleStateNotifier((ref) => const <String>{}),
    );

/// 显式重试期间阻止重复点击，用户仍可继续选择其他外观。
final themePreferenceRetryingProvider =
    NotifierProvider<SimpleStateNotifier<bool>, bool>(
      () => SimpleStateNotifier((ref) => false),
    );

/// 正常选择与显式重试共享同一写入队列。
final _themePreferenceWriterProvider = Provider<_ThemePreferenceWriter>(
  _ThemePreferenceWriter.new,
);

/// 界面可等待本次选择的持久化结果，共享偏好层不决定如何记录用户行为。
final themePreferenceWriteResultProvider = Provider<Future<bool> Function()>(
  (ref) =>
      () => ref.read(_themePreferenceWriterProvider).lastResult,
);

/// 保存当前正在显示的偏好，无需先切到其他主题再切回来。
final retryThemePreferencesProvider = Provider<Future<bool> Function()>((ref) {
  var disposed = false;
  ref.onDispose(() => disposed = true);
  return () async {
    if (ref.read(themePreferenceRetryingProvider)) return false;
    final keys = Set<String>.of(ref.read(themePreferenceUnsavedProvider));
    if (keys.isEmpty) return false;
    ref.read(themePreferenceRetryingProvider.notifier).set(true);
    try {
      final writer = ref.read(_themePreferenceWriterProvider);
      // 重试取点击瞬间的当前选择；之后的新选择进入同一队列，最终覆盖旧重试。
      final saved = await Future.wait([
        if (keys.contains('appVisualTheme'))
          writer.enqueue('appVisualTheme', ref.read(themePresetProvider).name),
        if (keys.contains('themeMode'))
          writer.enqueue('themeMode', ref.read(themeModeProvider).name),
      ]);
      return saved.isNotEmpty && saved.every((value) => value);
    } catch (error, stackTrace) {
      logger.error('ThemePreferences', '重试保存外观偏好失败', error, stackTrace);
      if (!disposed) _reportPreferenceFailure(ref);
      return false;
    } finally {
      if (!disposed) {
        ref.read(themePreferenceRetryingProvider.notifier).set(false);
      }
    }
  };
});

/// 队列只串行写入已确定的键值，不负责改变正在显示的主题状态。
class _ThemePreferenceWriter {
  /// 写入结束前容器若已销毁，只结束持久化，不再发布界面通知。
  _ThemePreferenceWriter(this.ref) {
    ref.onDispose(() => _disposed = true);
  }

  final Ref ref;
  Future<void> _tail = Future<void>.value();
  Future<bool> lastResult = Future.value(true);
  bool _disposed = false;

  /// 每次重试和选择都排在前一笔写入之后，失败不会中断后续队列。
  Future<bool> enqueue(String key, String value) {
    final result = _tail.then((_) async {
      if (_disposed) return false;
      try {
        final prefs = await ref.read(sharedPreferencesProvider.future);
        final saved = await prefs.setString(key, value);
        if (!saved) throw StateError('Preference write returned false: $key');
        if (!_disposed) {
          final pending = Set<String>.of(
            ref.read(themePreferenceUnsavedProvider),
          )..remove(key);
          ref.read(themePreferenceUnsavedProvider.notifier).set(pending);
        }
        return true;
      } catch (error, stackTrace) {
        logger.error('ThemePreferences', '保存外观偏好失败：$key', error, stackTrace);
        if (!_disposed) {
          final pending = Set<String>.of(
            ref.read(themePreferenceUnsavedProvider),
          )..add(key);
          ref.read(themePreferenceUnsavedProvider.notifier).set(pending);
          _reportPreferenceFailure(ref);
        }
        return false;
      }
    });
    lastResult = result;
    _tail = result.then<void>((_) {});
    return result;
  }
}

/// 恢复已有显示模式；未知值回落到系统模式。
final themeModeInitProvider = FutureProvider<void>(
  (ref) => _initializePreference<ThemeMode>(
    ref,
    key: 'themeMode',
    provider: themeModeProvider,
    decode: (value) =>
        ThemeMode.values.where((mode) => mode.name == value).firstOrNull ??
        ThemeMode.system,
    encode: (value) => value.name,
    apply: (value) => ref.read(themeModeProvider.notifier).set(value),
  ),
);

/// 恢复视觉风格；未知风格仅回落当前风格，不修改显示模式。
final themePresetInitProvider = FutureProvider<void>(
  (ref) => _initializePreference<AppThemePreset>(
    ref,
    key: 'appVisualTheme',
    provider: themePresetProvider,
    decode: AppThemePreset.parse,
    encode: (value) => value.name,
    apply: (value) => ref.read(themePresetProvider.notifier).set(value),
  ),
);

/// 先订阅后读取，避免冷启动期间的新选择被磁盘旧值覆盖；写入按选择顺序串行。
Future<void> _initializePreference<T>(
  Ref ref, {
  required String key,
  required NotifierProvider<SimpleStateNotifier<T>, T> provider,
  required T Function(String?) decode,
  required String Function(T) encode,
  required void Function(T) apply,
}) async {
  var disposed = false;
  var restoring = false;
  var changed = false;
  final writer = ref.read(_themePreferenceWriterProvider);
  final preferences = ref.read(sharedPreferencesProvider.future);
  ref.onDispose(() => disposed = true);
  ref.listen<T>(provider, (previous, next) {
    if (restoring) return;
    changed = true;
    unawaited(writer.enqueue(key, encode(next)));
  });
  try {
    final prefs = await preferences;
    if (disposed || changed) return;
    restoring = true;
    apply(decode(prefs.getString(key)));
  } catch (error, stackTrace) {
    logger.error('ThemePreferences', '读取外观偏好失败：$key', error, stackTrace);
    if (!disposed) _reportPreferenceFailure(ref);
  } finally {
    restoring = false;
  }
}

/// 错误状态只驱动提示，不回滚用户已经看到的主题。
void _reportPreferenceFailure(Ref ref) {
  final previous = ref.read(themePreferenceFailureProvider);
  ref.read(themePreferenceFailureProvider.notifier).set(previous + 1);
}
