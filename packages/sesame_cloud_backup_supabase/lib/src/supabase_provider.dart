library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'supabase_auth_service.dart';
import 'supabase_storage_service.dart';
import 'supabase_secure_local_storage.dart';

/// Supabase implementation of [CloudProvider].
///
/// This provider uses Supabase for cloud storage and authentication.
///
/// Required configuration keys:
/// - `url`: Supabase project URL
/// - `anonKey`: Supabase anonymous key
/// - `bucket`: Storage bucket name (optional, defaults to 'storage')
///
/// Example:
/// ```dart
/// final provider = SupabaseProvider();
/// await provider.initialize({
///   'url': 'https://your-project.supabase.co',
///   'anonKey': 'your-anon-key',
///   'bucket': 'user-data',
/// });
/// ```
///
/// 注意：supabase_flutter 使用进程级全局单例，同一进程仅允许一个 Supabase
/// 后端；切换配置前必须先 dispose 旧实例，避免静态初始化状态互相污染。
class SupabaseProvider implements CloudProvider {
  supabase.SupabaseClient? _client;
  SupabaseAuthService? _authService;
  SupabaseStorageService? _storageService;
  String _bucketName = 'storage';
  String? _pathPrefix;

  // Track current configuration to detect changes
  static String? _currentUrl;
  static String? _currentAnonKey;
  static bool _isInitialized = false;

  @override
  String get providerId => 'supabase';

  @override
  String get providerName => 'Supabase';

  @override
  CloudAuthService get auth {
    if (_authService == null) {
      throw CloudConfigurationException(
          'Provider not initialized. Call initialize() first.');
    }
    return _authService!;
  }

  @override
  CloudStorageService get storage {
    if (_storageService == null) {
      throw CloudConfigurationException(
          'Provider not initialized. Call initialize() first.');
    }
    return _storageService!;
  }

  /// Supabase client instance
  supabase.SupabaseClient? get client => _client;

  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      throw CloudConfigurationException(
          'Invalid configuration. Required keys: url, anonKey');
    }

    final url = config['url'] as String;
    final anonKey = config['anonKey'] as String;
    _bucketName = config['bucket'] as String? ?? 'storage';
    _pathPrefix = config['pathPrefix'] as String?;

    try {
      // Check if Supabase is already initialized with the same config
      final configChanged = _currentUrl != url || _currentAnonKey != anonKey;

      if (_isInitialized && configChanged) {
        // Configuration changed, need to sign out and reinitialize
        try {
          await supabase.Supabase.instance.client.auth.signOut();
        } catch (_) {
          // Ignore signout errors
        }
        _isInitialized = false;
      }

      if (!_isInitialized) {
        // Initialize Supabase client (only once per configuration)
        await supabase.Supabase.initialize(
          url: url,
          // supabase_flutter 2.x 已将 anonKey 重命名为 publishableKey，原参数已 deprecated
          // 内部变量名 anonKey 为业务自定义，无需改动，仅替换传给 SDK 的参数名
          publishableKey: anonKey,
          authOptions: supabase.FlutterAuthClientOptions(
            authFlowType: supabase.AuthFlowType.pkce,
            // 会话与 PKCE verifier 统一走系统安全存储，避免 refresh token
            // 明文落在 SharedPreferences（Android 明文 XML / 备份可读）。
            localStorage: SecureSupabaseLocalStorage(),
            pkceAsyncStorage: SecureSupabaseGotrueAsyncStorage(),
          ),
        );
        _isInitialized = true;
        _currentUrl = url;
        _currentAnonKey = anonKey;
      }

      _client = supabase.Supabase.instance.client;

      // Create service instances
      _authService = SupabaseAuthService(_client!);
      _storageService =
          SupabaseStorageService(_client!, _bucketName, _pathPrefix);
    } catch (e) {
      // If initialization fails due to already initialized, try to use existing instance
      if (e.toString().contains('already initialized') ||
          e.toString().contains('LateInitializationError')) {
        _client = supabase.Supabase.instance.client;
        _authService = SupabaseAuthService(_client!);
        _storageService =
            SupabaseStorageService(_client!, _bucketName, _pathPrefix);
        _isInitialized = true;
        _currentUrl = url;
        _currentAnonKey = anonKey;
      } else {
        throw CloudConfigurationException(
            'Failed to initialize Supabase: $e', e);
      }
    }
  }

  @override
  bool validateConfig(Map<String, dynamic> config) {
    if (!config.containsKey('url') || config['url'] is! String) {
      return false;
    }
    if (!config.containsKey('anonKey') || config['anonKey'] is! String) {
      return false;
    }
    // bucket is optional
    if (config.containsKey('bucket') && config['bucket'] is! String) {
      return false;
    }
    return true;
  }

  @override
  Future<void> dispose() async {
    _authService = null;
    _storageService = null;
    _client = null;
    // 复位进程级静态状态，保证下次 initialize 能按新配置重建。
    _isInitialized = false;
    _currentUrl = null;
    _currentAnonKey = null;
  }
}
