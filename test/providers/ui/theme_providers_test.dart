// theme_providers 外观偏好持久化测试。
//
// 需求锚点：themeModeInit 读取 prefs 恢复 light/dark/system；非法值回退 system；
// 后续变更即时落盘。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_isolation.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetGlobalTestState());

  test('themeModeInit：恢复 dark 并落盘后续变更', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'dark'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await readProviderFutureFromContainer(
      container,
      themeModeInitProvider.future,
    );
    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).set(ThemeMode.light);
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'light');
  });

  test('themeModeInit：非法值回退 system', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'garbage'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await readProviderFutureFromContainer(
      container,
      themeModeInitProvider.future,
    );
    expect(container.read(themeModeProvider), ThemeMode.system);
  });
}
