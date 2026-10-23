import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/profile_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

class _MockProfileService extends Mock implements ProfileService {}

void main() {
  // 偏好缓存通过测试平台通道读写。
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockProfileService service;
  late CloudProfileCache cache;
  late SesameDatabase db;
  late ProviderContainer container;

  const oldProfile = CloudProfile(userId: 'u1', displayName: '旧昵称');
  const refreshed = CloudProfile(
    userId: 'u1',
    displayName: '跨端新昵称',
    avatarUrl: 'https://example.com/new.png',
    avatarVersion: 2,
  );

  setUp(() async {
    resetGlobalTestState();
    service = _MockProfileService();
    cache = CloudProfileCache(await SharedPreferences.getInstance());
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        profileServiceProvider.overrideWithValue(service),
        cloudProfileCacheProvider.overrideWithValue(cache),
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('进入资料页触发一次服务端刷新，页面重建复用同一次请求', () async {
    when(service.getMe).thenAnswer((_) async => refreshed);
    container.read(accountStateProvider.notifier).restoreFromCache(oldProfile);

    final subscription = container.listen(profileRefreshProvider, (_, _) {});
    await container.read(profileRefreshProvider.future);
    await container.read(profileRefreshProvider.future);

    // verify 会消费已核对的调用，此处断言页面重建不产生第二次请求
    verify(service.getMe).called(1);
    expect(container.read(accountStateProvider).profile?.displayName, '跨端新昵称');
    expect(cache.read('u1')?.avatarVersion, 2);

    // 离开资料页后释放，重新进入会再拉取一次最新资料
    subscription.close();
    await container.pump();
    expect(container.exists(profileRefreshProvider), isFalse);
    final reentry = container.listen(profileRefreshProvider, (_, _) {});
    await container.read(profileRefreshProvider.future);
    verify(service.getMe).called(1);
    reentry.close();
  });

  test('刷新失败不抛出，保留现有缓存资料展示', () async {
    when(service.getMe).thenThrow(Exception('offline'));
    container.read(accountStateProvider.notifier).restoreFromCache(oldProfile);

    final subscription = container.listen(profileRefreshProvider, (_, _) {});
    await container.read(profileRefreshProvider.future);

    expect(container.read(accountStateProvider).profile?.displayName, '旧昵称');
    verify(service.getMe).called(1);
    subscription.close();
  });
}
