import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 基于系统安全存储的 PKCE code verifier 存储。
///
/// 设计意图：PKCE verifier 虽为一次性短时效值，但同样属于认证材料；
/// 与会话存储统一走安全通道，避免任何认证数据落入明文持久化。
class SecureSupabaseGotrueAsyncStorage extends GotrueAsyncStorage {
  SecureSupabaseGotrueAsyncStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);
}
