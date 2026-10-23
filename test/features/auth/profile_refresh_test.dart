import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/profile_service.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

class _MockProfileService extends Mock implements ProfileService {}

class _MockAccountLedgerRepository extends Mock
    implements AccountLedgerRepository {}

void main() {
  // 偏好缓存通过测试平台通道读写。
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

  test('恢复默认头像清空内存与离线缓存的 URL，并同步成员展示快照', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = _MockProfileService();
    final repository = _MockAccountLedgerRepository();
    const profile = CloudProfile(
      userId: 'u1',
      displayName: '昵称',
      avatarUrl: 'https://example.invalid/old.png',
      avatarVersion: 7,
      phone: '+8613800138000',
      gender: 'MALE',
    );
    when(service.deleteAvatar).thenAnswer((_) async {});
    when(
      () => repository.refreshMemberDisplayByAccount(
        userId: 'u1',
        displayName: '昵称',
        avatarUrl: null,
        avatarVersion: 0,
      ),
    ).thenAnswer((_) async => 0);
    final cache = CloudProfileCache(prefs);
    await cache.write(profile);
    final container = ProviderContainer(
      overrides: [
        profileServiceProvider.overrideWithValue(service),
        cloudProfileCacheProvider.overrideWithValue(cache),
        accountDataAccessProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    container.read(accountStateProvider.notifier).restoreFromCache(profile);

    await container.read(authActionsProvider).restoreDefaultAvatar();

    final current = container.read(accountStateProvider).profile!;
    expect(current.avatarUrl, isNull);
    expect(current.avatarVersion, 0);
    expect(current.phone, profile.phone);
    expect(current.displayName, profile.displayName);
    expect(current.gender, profile.gender);
    expect(cache.read('u1')?.avatarUrl, isNull);
    expect(cache.read('u1')?.avatarVersion, 0);
    expect(cache.read('u1')?.phone, profile.phone);
    verify(service.deleteAvatar).called(1);
    verify(
      () => repository.refreshMemberDisplayByAccount(
        userId: 'u1',
        displayName: '昵称',
        avatarUrl: null,
        avatarVersion: 0,
      ),
    ).called(1);
  });
}
