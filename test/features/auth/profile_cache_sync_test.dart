import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart'
    show AccountStatus;

import '../../helpers/test_isolation.dart';

void main() {
  setUp(() => resetGlobalTestState(initialPrefs: {}));

  CloudProfile profile(String name) => CloudProfile(
    userId: 'user-1',
    displayName: name,
    sesameNumber: '123456789',
    gender: 'UNSPECIFIED',
  );

  test('已登录时缓存写入后，内存展示状态同步为最新资料', () async {
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 共享偏好就绪（云资料缓存依赖），并初始化常驻桥接
    await container.read(sharedPreferencesProvider.future);
    container.read(profileCacheSyncBridgeProvider);
    // 已登录旧资料态（模拟启动恢复路径）
    container
        .read(accountStateProvider.notifier)
        .restoreFromCache(profile('旧昵称'));

    // 拦截器刷新路径：只写磁盘缓存，不直接提交内存状态
    await container.read(cloudProfileCacheProvider).write(profile('新昵称'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(accountStateProvider);
    expect(state.profile?.displayName, '新昵称');
  });

  test('未登录时缓存写入不改变账号状态', () async {
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sharedPreferencesProvider.future);
    container.read(profileCacheSyncBridgeProvider);
    container.read(accountStateProvider.notifier).signOut();

    await container.read(cloudProfileCacheProvider).write(profile('无关写入'));
    await Future<void>.delayed(Duration.zero);

    final state = container.read(accountStateProvider);
    expect(state.status, AccountStatus.local);
    expect(state.profile, isNull);
  });
}
