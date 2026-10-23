import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/features/auth/application/app_lock_service.dart';

/// 模拟安全状态写入被平台拒绝，其他偏好仍可正常保存。
class _RejectingStore extends InMemorySharedPreferencesStore {
  /// 在已有失败计数基础上，仅拒绝指定的安全字段。
  _RejectingStore(this.rejectedKey, int attempts)
    : super.withData({
        'flutter.${AppLockService.prefsKeyPinHash}': 'invalid-pin-hash',
        'flutter.${AppLockService.prefsKeyFailedAttempts}': attempts,
      });

  final String rejectedKey;

  /// 返回平台的实际保存结果，不把内存缓存视为持久化成功。
  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == 'flutter.$rejectedKey') return false;
    return super.setValue(valueType, key, value);
  }
}

/// 验证安全计数和锁定期限的保存失败会交给界面的错误边界处理。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final entry in {
    AppLockService.prefsKeyFailedAttempts: 0,
    AppLockService.prefsKeyLockedUntil: 4,
    AppLockService.prefsKeyLastBackgroundTime: 0,
  }.entries) {
    test('${entry.key} 保存失败不能被当作普通 PIN 错误', () async {
      final previous = SharedPreferencesStorePlatform.instance;
      SharedPreferences.resetStatic();
      SharedPreferencesStorePlatform.instance = _RejectingStore(
        entry.key,
        entry.value,
      );
      try {
        await expectLater(
          entry.key == AppLockService.prefsKeyLastBackgroundTime
              ? AppLockService.recordBackgroundTime()
              : AppLockService.verifyPin('0000'),
          throwsA(isA<StateError>()),
        );
      } finally {
        SharedPreferencesStorePlatform.instance = previous;
        SharedPreferences.resetStatic();
      }
    });
  }
}
