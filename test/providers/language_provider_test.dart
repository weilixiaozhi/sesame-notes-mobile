import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';

/// 在平台写入处控制等待与失败，检验实际语言和地区的持久化组合。
class _LanguageStore extends InMemorySharedPreferencesStore {
  _LanguageStore() : super.withData({'flutter.selected_language': 'en'});
  Completer<void>? firstWrite;
  final started = Completer<void>();
  bool rejectCountryOnce = false;

  /// 延迟首个语言写入，或拒绝一次地区写入；后续回滚与重试正常执行。
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == 'flutter.selected_language' &&
        value == 'zh' &&
        firstWrite != null) {
      if (!started.isCompleted) started.complete();
      await firstWrite!.future;
    }
    if (key == 'flutter.selected_language_country' && rejectCountryOnce) {
      rejectCountryOnce = false;
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}

/// 语言写入按用户意图排序，失败的半份偏好不能在重启后生效。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _LanguageStore store;
  late ProviderContainer container;
  late SharedPreferencesStorePlatform previous;

  setUp(() {
    previous = SharedPreferencesStorePlatform.instance;
    SharedPreferences.resetStatic();
    store = _LanguageStore();
    SharedPreferencesStorePlatform.instance = store;
    container = ProviderContainer();
  });
  tearDown(() async {
    container.dispose();
    await logger.clear();
    SharedPreferencesStorePlatform.instance = previous;
    SharedPreferences.resetStatic();
  });

  test('并发选择繁体与英文后保持最新完整语言和地区组合', () async {
    store.firstWrite = Completer<void>();
    final notifier = container.read(languageProvider.notifier);
    final first = notifier.setLanguage(const Locale('zh', 'TW'));
    await store.started.future;
    final latest = notifier.setLanguage(const Locale('en'));
    store.firstWrite!.complete();
    await Future.wait([first, latest]);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getString('selected_language'), 'en');
    expect(prefs.getString('selected_language_country'), isNull);
    expect(container.read(languageProvider), const Locale('en'));
  });

  test('地区写入失败向页面报错并恢复原语言，后续选择仍可成功', () async {
    store.rejectCountryOnce = true;
    final notifier = container.read(languageProvider.notifier);
    await expectLater(
      notifier.setLanguage(const Locale('zh', 'TW')),
      throwsStateError,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getString('selected_language'), 'en');
    expect(prefs.getString('selected_language_country'), isNull);
    expect(container.read(languageProvider), const Locale('en'));
    await notifier.setLanguage(const Locale('zh', 'TW'));
    expect(container.read(languageProvider), const Locale('zh', 'TW'));
  });
}
