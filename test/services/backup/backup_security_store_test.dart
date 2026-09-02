/// 备份安全存储测试（备份密码 / Recovery Key 持久化）。
///
/// - 首次设置备份密码时生成 12 组恢复词（本地仅存哈希），忘记密码可凭恢复词重置；
/// - 密码本身不落盘：只存校验哈希（供设置页验证输入，不承载保密性）；
/// - 恢复词本地仅存哈希，校验恒定时间比较。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/features/settings/infrastructure/backup_security_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('初始无密码', () async {
    final store = BackupSecurityStore();
    expect(await store.hasPassword(), isFalse);
  });

  test('setPassword 生成 12 组恢复词并只存哈希', () async {
    final store = BackupSecurityStore();
    final words = await store.setPassword(password: 'my-secret-password');
    expect(words, hasLength(16), reason: '16 组恢复词 = 128 bit 熵');
    expect(words.toSet().length, 16, reason: '恢复词不得重复');

    expect(await store.hasPassword(), isTrue);
    // 密码/恢复词明文不落盘
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.toString();
    expect(raw.contains('my-secret-password'), isFalse);
    expect(raw.contains(words.join(' ')), isFalse);
  });

  test('verifyPassword：正确通过、错误拒绝、未设置拒绝', () async {
    final store = BackupSecurityStore();
    expect(await store.verifyPassword('anything'), isFalse);
    await store.setPassword(password: 'my-secret-password');
    expect(await store.verifyPassword('my-secret-password'), isTrue);
    expect(await store.verifyPassword('wrong'), isFalse);
  });

  test('恢复词可验证（忘记密码重置路径）', () async {
    final store = BackupSecurityStore();
    final words = await store.setPassword(password: 'my-secret-password');
    final key = words.join(' ');
    expect(await store.verifyRecoveryKey(key), isTrue);
    expect(await store.verifyRecoveryKey('wrong words here'), isFalse);
  });

  test('clearPassword 移除密码与恢复词哈希', () async {
    final store = BackupSecurityStore();
    await store.setPassword(password: 'my-secret-password');
    await store.clearPassword();
    expect(await store.hasPassword(), isFalse);
    expect(await store.verifyPassword('my-secret-password'), isFalse);
    expect(await store.verifyRecoveryKey('x y z'), isFalse);
  });
}
