import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';

final _sourceVersion = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 0),
);

/// 在没有界面监听的冷启动期间，必需预加载的依赖变化必须自动重建并结束等待。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('未挂载界面时预加载依赖更新，启动等待当前版本完成', () async {
    final first = Completer<void>();
    final second = Completer<void>();
    final builds = <int>[];
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        accountBootstrapProvider.overrideWith((ref) async {}),
        welcomeCheckProvider.overrideWith((ref) async => false),
        appSplashInitProvider.overrideWith((ref) async {
          final version = ref.watch(_sourceVersion);
          builds.add(version);
          await (version == 0 ? first : second).future;
          if (ref.mounted) {
            ref.read(appInitStateProvider.notifier).set(AppInitState.ready);
          }
        }),
      ],
    );
    Future<void>? startup;
    var startupFinished = false;
    try {
      startup = initializeLocalApp(
        container,
      ).then((_) => startupFinished = true);
      await _waitUntil(() => builds.isNotEmpty);
      expect(builds, [0]);
      // 只更新真实依赖，不读取预加载provider，避免断言本身替启动恢复失效依赖。
      container.read(_sourceVersion.notifier).set(1);
      first.complete();
      await _waitUntil(() => builds.contains(1));
      expect(startupFinished, isFalse, reason: '旧版本结束不能提前结束初始化等待');
      second.complete();
      await startup.timeout(const Duration(seconds: 2));
      expect(builds, [0, 1]);
      expect(container.read(appInitStateProvider), AppInitState.ready);
    } catch (error, stack) {
      printOnFailure('冷启动预加载未收敛：$error\n$stack\nbuilds=$builds');
      rethrow;
    } finally {
      startup?.ignore();
      if (!first.isCompleted) first.complete();
      if (!second.isCompleted) second.complete();
      container.dispose();
    }
  });

  test('必需预加载失败仍抛错并保持失败状态', () async {
    final failure = StateError('synthetic startup dependency failure');
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        accountBootstrapProvider.overrideWith((ref) async {}),
        welcomeCheckProvider.overrideWith((ref) async => false),
        appSplashInitProvider.overrideWith((ref) async => throw failure),
      ],
    );
    try {
      await expectLater(initializeLocalApp(container), throwsA(same(failure)));
      expect(container.read(appInitStateProvider), AppInitState.failed);
    } catch (error, stack) {
      printOnFailure('启动失败状态验收未完成：$error\n$stack');
      rethrow;
    } finally {
      container.dispose();
    }
  });
}

/// 仅等待外部观察到的运行事实，不刷新或订阅被测provider。
Future<void> _waitUntil(bool Function() completed) async {
  try {
    final deadline = Stopwatch()..start();
    while (!completed()) {
      if (deadline.elapsed > const Duration(seconds: 2)) {
        throw TimeoutException('必需预加载没有在依赖更新后继续运行');
      }
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  } catch (error, stack) {
    printOnFailure('等待启动阶段失败：$error\n$stack');
    rethrow;
  }
}
