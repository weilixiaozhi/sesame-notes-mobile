import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/shared_preferences_provider.dart';

// 主题模式Provider（默认跟随系统）
final themeModeProvider =
    NotifierProvider<SimpleStateNotifier<ThemeMode>, ThemeMode>(
      () => SimpleStateNotifier((ref) => ThemeMode.system),
    );

// 主题模式持久化初始化
final themeModeInitProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final saved = prefs.getString('themeMode');
  if (saved != null) {
    switch (saved) {
      case 'light':
        ref.read(themeModeProvider.notifier).set(ThemeMode.light);
        break;
      case 'dark':
        ref.read(themeModeProvider.notifier).set(ThemeMode.dark);
        break;
      default:
        ref.read(themeModeProvider.notifier).set(ThemeMode.system);
    }
  }
  ref.listen<ThemeMode>(themeModeProvider, (prev, next) async {
    String value;
    switch (next) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString('themeMode', value);
  });
});
