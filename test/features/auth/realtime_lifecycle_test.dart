import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';

class _RecordingCoordinator extends RealtimeCoordinator {
  _RecordingCoordinator(super.ref);

  int startCalls = 0;
  int stopCalls = 0;

  /// 记录装配层请求的启动次数。
  @override
  Future<void> start() async {
    startCalls++;
  }

  /// 记录装配层请求的停止次数。
  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('读取账号事实不会隐式启动实时连接', () async {
    final container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        realtimeCoordinatorProvider.overrideWith(_RecordingCoordinator.new),
      ],
    );
    addTearDown(container.dispose);
    container.read(accountStateProvider);
    final coordinator =
        container.read(realtimeCoordinatorProvider) as _RecordingCoordinator;

    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 'at', userId: 'u1', deviceId: 'd1'),
        );
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.startCalls, 0, reason: '实时连接只由常驻装配负责');
    expect(coordinator.stopCalls, 0);
  });

  test('会话建立后启动实时通知，会话清空后停止', () async {
    final container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        realtimeCoordinatorProvider.overrideWith(
          (ref) => _RecordingCoordinator(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 使用与 MainApp 相同的常驻装配，注册会话生命周期监听。
    container.read(appSessionLifecycleProvider);
    final coordinator =
        container.read(realtimeCoordinatorProvider) as _RecordingCoordinator;
    expect(coordinator.startCalls, 0, reason: '未登录不得启动实时通知');
    expect(coordinator.stopCalls, 1, reason: '常驻装配接管未登录状态时必须保持连接停止');

    // 登录：写入内存会话。
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 'at', userId: 'u1', deviceId: 'd1'),
        );
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.startCalls, 1, reason: '登录成功必须启动实时通知');

    // 登出：清空会话。
    container.read(authSessionProvider.notifier).signOut();
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.stopCalls, 2, reason: '登出必须再次停止已启动的实时通知');
  });

  test('常驻装配接管首帧之前已经恢复的会话', () async {
    final container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        realtimeCoordinatorProvider.overrideWith(_RecordingCoordinator.new),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 'at', userId: 'u1', deviceId: 'd1'),
        );
    final coordinator =
        container.read(realtimeCoordinatorProvider) as _RecordingCoordinator;
    expect(coordinator.startCalls, 0);

    container.read(appSessionLifecycleProvider);
    await Future<void>.delayed(Duration.zero);

    expect(coordinator.startCalls, 1, reason: '启动恢复不能依赖未来的会话变化');
    container.read(authSessionProvider.notifier).signOut();
    await Future<void>.delayed(Duration.zero);
    expect(coordinator.stopCalls, 1);
  });
}
