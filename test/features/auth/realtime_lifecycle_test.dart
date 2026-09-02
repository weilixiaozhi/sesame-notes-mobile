// 实时通知生命周期测试：会话建立/清空必须启停 WS。
//
// 需求锚点：
// - 登录成功（authSession 非空）后 RealtimeCoordinator.start() 必须被调用；
// - 登出/认证失效（authSession 为 null）后 RealtimeCoordinator.stop() 必须被调用；
// - 重复触发幂等（RealtimeCoordinator 内部已有 _running 守卫，此处只记录调用次数）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';

class _RecordingCoordinator extends RealtimeCoordinator {
  _RecordingCoordinator(super.ref);

  int startCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> start() async {
    startCalls++;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

void main() {
  test('会话建立后启动实时通知，会话清空后停止', () async {
    final container = ProviderContainer(
      overrides: [
        realtimeCoordinatorProvider.overrideWith(
          (ref) => _RecordingCoordinator(ref),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 激活账号状态提供者，注册会话监听。
    container.read(accountStateProvider);
    final coordinator =
        container.read(realtimeCoordinatorProvider) as _RecordingCoordinator;
    expect(coordinator.startCalls, 0, reason: '未登录不得启动实时通知');

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

    expect(
      coordinator.stopCalls,
      greaterThanOrEqualTo(1),
      reason: '登出必须停止实时通知',
    );
  });
}
