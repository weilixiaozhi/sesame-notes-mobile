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
