/// 备份安全存储：备份密码 / Recovery Key / 设备密钥的持久化。
///
/// - 密码本身不落盘；prefs 只存快速校验哈希（仅设置页验证输入，不承载保密性——
///   保密性由 Envelope 的 AEAD + 各 key slot 保证）；
/// - 恢复词 16 组（128 bit 熵）：**明文存系统钥匙串**（Multi-Key-Slot
///   要求：自动备份/改密码时必须能读取恢复词以写 RECOVERY slot——仅存哈希的旧设计
///   导致恢复词永远无法解开任何 DEK）；prefs 另存哈希用于重置验证；
/// - 设备密钥（localSelfId 派生）仅本机自动备份兜底（DEVICE_LOCAL slot）；
/// - 明文恢复词/密码不得写入 SharedPreferences（Android 为明文 XML）。
library;

import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';

/// 自动备份密钥存储端口（抽象钥匙串，测试注入内存实现）。
abstract class BackupKeyStore {
  /// 读取指定键的值；未设置返回 null。
  Future<String?> read(String key);

  /// 写入指定键。
  Future<void> write(String key, String value);

  /// 删除指定键。
  Future<void> delete(String key);
}

/// 生产实现：系统钥匙串（Keychain / Keystore / DPAPI）。
class SecureBackupKeyStore implements BackupKeyStore {
  final FlutterSecureStorage _storage;

  SecureBackupKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// 测试用内存实现（生产不引用）。
class InMemoryBackupKeyStore implements BackupKeyStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// 备份安全配置存储（唯一写入口）。
class BackupSecurityStore {
  /// SharedPreferences：密码校验哈希 key。
  static const prefsKeyPasswordVerifier = 'backup_password_verifier';

  /// SharedPreferences：恢复词哈希 key。
  static const prefsKeyRecoveryKeyHash = 'backup_recovery_key_hash';

  /// 系统钥匙串：恢复词明文（写 RECOVERY slot 必需）。
  static const keyStoreRecoveryKey = 'sesame_notes_backup_recovery_key';

  final BackupKeyStore _keyStore;

  BackupSecurityStore({BackupKeyStore? keyStore})
    : _keyStore = keyStore ?? _defaultKeyStore();

  /// 默认钥匙串实现：测试环境（flutter test 无平台通道）回退内存实现。
  static BackupKeyStore _defaultKeyStore() {
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return InMemoryBackupKeyStore();
    }
    return SecureBackupKeyStore();
  }

  /// 是否已配置备份密码。
  Future<bool> hasPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsKeyPasswordVerifier) != null;
  }

  /// 首次设置备份密码：生成 16 组恢复词（128 bit 熵），恢复词明文存钥匙串
  /// （自动备份写 RECOVERY slot 用），prefs 存校验哈希；返回恢复词（仅展示一次）。
  Future<List<String>> setPassword({required String password}) async {
    final recoveryWords = BackupCrypto.generateRecoveryKeyWords();
    final recoveryKey = recoveryWords.join(' ');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      prefsKeyPasswordVerifier,
      BackupCrypto.hashPasswordVerifier(password),
    );
    await prefs.setString(
      prefsKeyRecoveryKeyHash,
      BackupCrypto.hashRecoveryKey(recoveryKey),
    );
    await _keyStore.write(keyStoreRecoveryKey, recoveryKey);
    return recoveryWords;
  }

  /// 忘记密码：凭恢复词验证后重置为新密码（生成新恢复词，旧恢复词作废；
  /// 历史备份仍可用旧恢复词打开——打开备份不依赖本地哈希）。
  Future<List<String>> resetPassword({
    required String recoveryKey,
    required String newPassword,
  }) async {
    if (!await verifyRecoveryKey(recoveryKey)) {
      throw StateError('恢复词验证失败');
    }
    return setPassword(password: newPassword);
  }

  /// 读取恢复词明文（写 RECOVERY slot 用）；未配置返回 null。
  Future<String?> loadRecoveryKey() async {
    if (!await hasPassword()) return null;
    return _keyStore.read(keyStoreRecoveryKey);
  }

  /// 校验密码输入是否正确（未设置时恒 false）。
  Future<bool> verifyPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final expected = prefs.getString(prefsKeyPasswordVerifier);
    if (expected == null || expected.isEmpty) return false;
    return BackupCrypto.verifyPasswordVerifier(password, expected);
  }

  /// 校验恢复词输入（忘记密码重置路径）。
  Future<bool> verifyRecoveryKey(String recoveryKey) async {
    final prefs = await SharedPreferences.getInstance();
    final expected = prefs.getString(prefsKeyRecoveryKeyHash);
    if (expected == null || expected.isEmpty) return false;
    return BackupCrypto.verifyRecoveryKey(recoveryKey, expected);
  }

  /// 清除密码与关联密钥（不删除已有备份文件）。
  Future<void> clearPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKeyPasswordVerifier);
    await prefs.remove(prefsKeyRecoveryKeyHash);
    await _keyStore.delete(keyStoreRecoveryKey);
  }
}
