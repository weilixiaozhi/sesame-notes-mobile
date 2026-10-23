import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 云服务凭据存储抽象（可插拔）。
///
/// 用于存放各后端声明为 [CloudConfigFieldKind.secret] 的配置项
/// （WebDAV 密码、S3 访问密钥等）。默认实现
/// [FlutterSecureCredentialStorage] 走系统安全存储（Android Keystore /
/// iOS Keychain / Windows DPAPI / macOS Keychain）；
/// [SharedPreferencesCredentialStorage] 仅用于测试注入，
/// 生产路径不得选用。
abstract class CloudCredentialStorage {
  /// 读取指定后端的凭据 JSON。
  Future<String?> read(String backendId);

  /// 写入指定后端的凭据 JSON。
  Future<void> write(String backendId, String value);

  /// 删除指定后端的凭据。
  Future<void> delete(String backendId);
}

/// 基于 flutter_secure_storage 的默认安全存储实现。
///
/// 设计意图：WebDAV / S3 密钥属于长期有效凭证，不能明文写入
/// SharedPreferences（Android 侧为明文 XML，且可能随系统备份带走）。
/// 各平台的加密与密钥保存使用 flutter_secure_storage 的默认配置。
class FlutterSecureCredentialStorage implements CloudCredentialStorage {
  static const _keyPrefix = 'cloud_credential_';

  final FlutterSecureStorage _storage;

  FlutterSecureCredentialStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static String _key(String backendId) => '$_keyPrefix$backendId';

  @override
  Future<String?> read(String backendId) => _storage.read(key: _key(backendId));

  @override
  Future<void> write(String backendId, String value) =>
      _storage.write(key: _key(backendId), value: value);

  @override
  Future<void> delete(String backendId) =>
      _storage.delete(key: _key(backendId));
}

/// SharedPreferences 明文实现（仅测试注入）。
///
/// 设计意图：单测环境没有平台安全存储通道，需要可注入的确定性实现；
/// 该实现不加密，注释明确标记风险，防止被误用于生产。
class SharedPreferencesCredentialStorage implements CloudCredentialStorage {
  static const _keyPrefix = 'cloud_credential_';

  static String _key(String backendId) => '$_keyPrefix$backendId';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> read(String backendId) async {
    final sp = await _prefs;
    return sp.getString(_key(backendId));
  }

  @override
  Future<void> write(String backendId, String value) async {
    final sp = await _prefs;
    await sp.setString(_key(backendId), value);
  }

  @override
  Future<void> delete(String backendId) async {
    final sp = await _prefs;
    await sp.remove(_key(backendId));
  }
}
