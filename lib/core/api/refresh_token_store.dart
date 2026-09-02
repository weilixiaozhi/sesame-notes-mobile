import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Refresh Token 存储端口：抽象安全存储，便于测试注入内存实现。
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> delete();
}

/// 基于 flutter_secure_storage 的实现（Refresh Token 属敏感凭证）。
class SecureTokenStore implements TokenStore {
  static const _key = 'sesame_notes_refresh_token';

  final FlutterSecureStorage _storage;

  SecureTokenStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// Refresh Token 存取门面：统一 save/load/clear 语义。
///
/// 设计意图：契约要求 Refresh Token 只入系统安全存储（iOS Keychain /
/// Android Keystore），每次使用轮换后覆盖写入；登出时清除。
class RefreshTokenStore {
  final TokenStore store;

  RefreshTokenStore(this.store);

  /// 保存（含轮换覆盖）。
  Future<void> save(String token) => store.write(token);

  /// 读取；未保存返回 null。
  Future<String?> load() => store.read();

  /// 登出清除。
  Future<void> clear() => store.delete();
}
