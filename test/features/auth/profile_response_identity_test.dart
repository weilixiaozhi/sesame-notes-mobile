import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/infrastructure/account/profile_service.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/application/account_providers.dart';
import '../../helpers/test_isolation.dart';

class _Profiles extends Mock implements ProfileService {}

/// 资料与头像响应不能越过发起它们的账号生命周期。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState(initialPrefs: {}));
  for (final switched in [false, true]) {
    for (final avatar in [false, true]) {
      test('${switched ? '换号' : '退出'}后拒绝迟到${avatar ? '头像' : '资料'}', () async {
        final service = _Profiles();
        final response = Completer<CloudProfile>();
        final upload = Completer<({String url, int version})>();
        when(service.getMe).thenAnswer((_) => response.future);
        when(
          () => service.uploadAvatar(contentType: 'image/png', bytes: [1]),
        ).thenAnswer((_) => upload.future);
        final cache = CloudProfileCache(await SharedPreferences.getInstance());
        final container = ProviderContainer(
          overrides: [
            profileServiceProvider.overrideWithValue(service),
            cloudProfileCacheProvider.overrideWithValue(cache),
          ],
        );
        try {
          const a = CloudProfile(userId: 'A', phone: 'private-A');
          container.read(accountStateProvider.notifier).restoreFromCache(a);
          final action = container.read(authActionsProvider);
          final pending = avatar
              ? action.uploadAvatar(contentType: 'image/png', bytes: [1])
              : action.refreshProfile();
          final assertion = expectLater(pending, throwsStateError);
          container.read(accountStateProvider.notifier).signOut();
          if (switched) {
            container
                .read(accountStateProvider.notifier)
                .restoreFromCache(
                  const CloudProfile(userId: 'B', phone: 'private-B'),
                );
          }
          if (avatar) {
            upload.complete((url: 'https://example.invalid/A.png', version: 2));
          } else {
            response.complete(a);
          }
          await assertion;
          expect(
            container.read(accountStateProvider).profile?.userId,
            switched ? 'B' : null,
          );
          expect(
            container.read(accountStateProvider).profile?.avatarUrl,
            isNull,
          );
          expect(cache.read('A'), isNull);
        } finally {
          container.dispose();
        }
      });
    }
  }
}
