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

// 支出颜色方案Provider。取值：'red' = 红色表示支出（默认），'green' = 绿色表示支出。
// 全局仅支出模式，所以这里只管「支出」用哪种颜色，不涉及收入配色。
final expenseColorSchemeProvider =
    NotifierProvider<SimpleStateNotifier<String>, String>(
      () => SimpleStateNotifier((ref) => 'red'),
    );

// 支出颜色方案持久化初始化：启动从 prefs 读取，用户修改时写回并同步到云端。
// 复用 appearance JSON 管道（见 _pushAppearanceToCloud），不新增后端字段。
final expenseColorSchemeInitProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final saved = prefs.getString('expenseColorScheme');
  if (saved != null) {
    ref.read(expenseColorSchemeProvider.notifier).set(saved);
  }
  ref.listen<String>(expenseColorSchemeProvider, (prev, next) async {
    // 用户切换方案后落盘（云端外观同步随新认证层接入）。
    await prefs.setString('expenseColorScheme', next);
  });
});
