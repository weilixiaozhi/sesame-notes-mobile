import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';

// 语言设置提供者
final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<Locale?> {
  Future<void> _writes = Future<void>.value();
  late Future<void> _loaded;

  /// 首次读取与后续保存共用顺序，加载结果不能覆盖新的语言选择。
  @override
  Locale? build() {
    // 先同步返回 null（跟随系统），再异步加载保存的语言选择。
    _loaded = _loadLanguage();
    return null;
  }

  static const String _languageKey = 'selected_language';

  /// 恢复已保存语言；读取失败时保持系统语言并记录诊断信息。
  Future<void> _loadLanguage() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final languageCode = prefs.getString(_languageKey);
      final countryCode = prefs.getString('${_languageKey}_country');
      if (ref.mounted && languageCode != null) {
        state = Locale(languageCode, countryCode);
      }
    } catch (error, stackTrace) {
      logger.error('LanguageSettings', '读取语言设置失败，继续使用系统语言', error, stackTrace);
    }
  }

  /// 持久化语言成功后才发布选择，写入失败时保留当前语言。
  Future<void> setLanguage(Locale? locale) {
    final saving = _writes.then((_) async {
      await _loaded;
      await _saveLanguage(locale);
    });
    // 错误仍交给本次调用者，后续选择可继续保存。
    _writes = saving.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return saving;
  }

  /// 一次保存完成语言和地区两项，失败时恢复原偏好并由页面展示错误。
  Future<void> _saveLanguage(Locale? locale) async {
    try {
      if (!ref.mounted) return;
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final language = prefs.getString(_languageKey);
      final country = prefs.getString('${_languageKey}_country');
      try {
        await _writePreference(prefs, _languageKey, locale?.languageCode);
        await _writePreference(
          prefs,
          '${_languageKey}_country',
          locale?.countryCode,
        );
      } catch (_) {
        // 两个键分别恢复，某一项恢复失败不能阻止另一项；队列防止与新选择交错。
        for (final entry in {
          _languageKey: language,
          '${_languageKey}_country': country,
        }.entries) {
          try {
            await _writePreference(prefs, entry.key, entry.value);
          } catch (error, stackTrace) {
            logger.error(
              'LanguageSettings',
              '恢复语言偏好失败',
              safeErrorSummary(error),
              stackTrace,
            );
          }
        }
        try {
          await prefs.reload();
        } catch (error, stackTrace) {
          logger.error(
            'LanguageSettings',
            '重读语言偏好失败',
            safeErrorSummary(error),
            stackTrace,
          );
        }
        rethrow;
      }
      if (ref.mounted) state = locale;
    } catch (error, stackTrace) {
      logger.error('LanguageSettings', '保存语言设置失败，当前语言已保留', error, stackTrace);
      rethrow;
    }
  }

  /// 检查平台返回值，避免将失败写入的插件内存缓存当作持久化成功。
  Future<void> _writePreference(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    final saved = value == null
        ? await prefs.remove(key)
        : await prefs.setString(key, value);
    if (!saved) throw StateError('语言设置未成功保存');
  }
}
