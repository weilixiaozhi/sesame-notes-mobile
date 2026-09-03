import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/profile_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';

class _MockProfileService extends Mock implements ProfileService {}

void main() {
  // LoggerService 单例构造时注册原生日志桥,必须存在平台消息通道
  TestWidgetsFlutterBinding.ensureInitialized();

  test('读取服务端本人资料后同步内存状态与离线缓存', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = _MockProfileService();
    const oldProfile = CloudProfile(userId: 'u1', displayName: '旧昵称');
    const refreshed = CloudProfile(
      userId: 'u1',
      displayName: '跨端新昵称',
      avatarUrl: 'https://example.com/new.png',
      avatarVersion: 2,
    );
    when(service.getMe).thenAnswer((_) async => refreshed);

    final cache = CloudProfileCache(prefs);
    final container = ProviderContainer(
      overrides: [
        profileServiceProvider.overrideWithValue(service),
        cloudProfileCacheProvider.overrideWithValue(cache),
      ],
    );
    addTearDown(container.dispose);
    container.read(accountStateProvider.notifier).restoreFromCache(oldProfile);

    await container.read(authActionsProvider).refreshProfile();

    expect(container.read(accountStateProvider).profile?.displayName, '跨端新昵称');
    expect(cache.read('u1')?.avatarVersion, 2);
    verify(service.getMe).called(1);
  });
}
