import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/features/auth/application/app_lock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('hashPin 加盐：同 PIN 两次哈希不同，verifyPin 仍可验证', () async {
    await AppLockService.setPin('1234');
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_lock_pin_hash')!;
    expect(saved, startsWith('pbkdf2_sha256\$'));
    expect(
      saved,
      isNot(AppLockService.hashPin('1234')),
      reason: '每次设置应生成新盐，同 PIN 哈希不能相同',
    );
    expect(await AppLockService.verifyPin('1234'), isTrue);
    expect(prefs.getString(AppLockService.prefsKeyPinHash), saved);
    expect(await AppLockService.verifyPin('0000'), isFalse);
  });

  test('无盐 SHA-256 哈希即使 PIN 正确也拒绝，且不改写存储', () async {
    // 固定的 SHA-256("1234") 值，用于验证非 PBKDF2 格式会被拒绝。
    const saved =
        '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4';
    SharedPreferences.setMockInitialValues({
      AppLockService.prefsKeyPinHash: saved,
      AppLockService.prefsKeyEnabled: true,
    });

    final verified = await AppLockService.verifyPin('1234');
    final prefs = await SharedPreferences.getInstance();
    expect(verified, isFalse);
    expect(prefs.getString(AppLockService.prefsKeyPinHash), saved);
    expect(prefs.getInt(AppLockService.prefsKeyFailedAttempts), 1);
  });

  test('PBKDF2 哈希格式损坏时安全拒绝，且不改写存储', () async {
    for (final saved in [
      'pbkdf2_sha256\$100000',
      'pbkdf2_sha256\$0\$c2FsdA==\$aGFzaA==',
      'pbkdf2_sha256\$100000\$%\$aGFzaA==',
    ]) {
      SharedPreferences.setMockInitialValues({
        AppLockService.prefsKeyPinHash: saved,
      });
      expect(await AppLockService.verifyPin('1234'), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(AppLockService.prefsKeyPinHash), saved);
    }
  });

  test('连续输错 5 次后进入锁定窗口，锁定期内正确 PIN 也拒绝', () async {
    await AppLockService.setPin('1234');
    for (var i = 0; i < 5; i++) {
      expect(await AppLockService.verifyPin('0000'), isFalse);
    }

    expect(await AppLockService.isLocked(), isTrue);
    expect(
      await AppLockService.verifyPin('1234'),
      isFalse,
      reason: '锁定窗口内应拒绝任何输入',
    );

    // 模拟锁定窗口结束（直接把持久化的截止时间改到过去）。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'app_lock_locked_until',
      DateTime.now().millisecondsSinceEpoch - 1000,
    );
    expect(await AppLockService.isLocked(), isFalse);
    expect(await AppLockService.verifyPin('1234'), isTrue);
  });
}
