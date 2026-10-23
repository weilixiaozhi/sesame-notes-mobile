library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'webdav_errors.dart';
import 'webdav_storage_service.dart';

/// WebDAV implementation of [CloudProvider].
///
/// This provider uses WebDAV protocol for cloud storage.
/// WebDAV uses Basic Auth for authentication.
///
/// Required configuration keys:
/// - `url`: WebDAV server URL
/// - `username`: Username for authentication
/// - `password`: Password for authentication
/// - `remotePath`: Remote path prefix (optional, defaults to '/')
///
/// Example:
/// ```dart
/// final provider = WebDAVProvider();
/// await provider.initialize({
///   'url': 'https://webdav.example.com',
///   'username': 'your-username',
///   'password': 'your-password',
///   'remotePath': '/sync/', // optional
/// });
/// ```
class WebDAVProvider implements CloudProvider {
  final CloudSyncLogger? _logger;

  /// 为目录和元数据请求设置有界等待，宿主日志回调沿用到存储服务。
  WebDAVProvider({
    CloudSyncLogger? logger,
    Duration requestTimeout = const Duration(seconds: 30),
  })  : _logger = logger,
        _requestTimeout = requestTimeout {
    if (requestTimeout.inMilliseconds <= 0) {
      throw ArgumentError.value(requestTimeout, 'requestTimeout', '请求超时必须大于零');
    }
  }

  final Duration _requestTimeout;
  int _generation = 0;
  webdav.Client? _client;
  WebDAVStorageService? _storageService;

  @override
  CloudStorageService get storage {
    if (_storageService == null) {
      throw CloudConfigurationException(
          'Provider not initialized. Call initialize() first.');
    }
    return _storageService!;
  }

  /// 初始化仅发布当前代次的连接；重新配置和释放都会立即关闭旧请求。
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    if (!validateConfig(config)) {
      throw CloudConfigurationException(
          'Invalid configuration. Required keys: url, username, password');
    }

    final url = config['url'] as String;
    final username = config['username'] as String;
    final password = config['password'] as String;
    final remotePath = config['remotePath'] as String? ?? '/';

    final generation = ++_generation;
    webdav.Client? client;
    try {
      _releaseClient();
      client = webdav.newClient(
        url,
        user: username,
        password: password,
        debug: false,
      );
      client
        ..setConnectTimeout(_requestTimeout.inMilliseconds)
        ..setSendTimeout(_requestTimeout.inMilliseconds)
        ..setReceiveTimeout(_requestTimeout.inMilliseconds);
      _client = client;

      try {
        await client.readDir(remotePath);
      } catch (error) {
        // 只有确定的目录不存在才创建，超时、取消和认证失败直接交给调用方。
        if (generation != _generation || webDavStatusCode(error) != 404) {
          rethrow;
        }
        await client.mkdir(remotePath);
      }
      if (generation != _generation || !identical(_client, client)) {
        throw CloudConfigurationException('备份连接操作已取消，请重试');
      }

      _storageService = WebDAVStorageService(
        client,
        remotePath,
        logger: _logger,
      );
    } catch (error, stackTrace) {
      _logger?.error('WebDAV 初始化失败：${error.runtimeType}\n$stackTrace');
      if (identical(_client, client)) {
        _releaseClient();
      } else {
        // 较早的初始化只能清理自身连接，不能关闭已经开始使用的新配置。
        client?.c.close(force: true);
      }
      throw CloudConfigurationException('备份连接失败，请检查网络和配置后重试', error);
    }
  }

  @override
  bool validateConfig(Map<String, dynamic> config) {
    if (!config.containsKey('url') || config['url'] is! String) {
      return false;
    }
    if (!config.containsKey('username') || config['username'] is! String) {
      return false;
    }
    if (!config.containsKey('password') || config['password'] is! String) {
      return false;
    }
    // remotePath is optional
    if (config.containsKey('remotePath') && config['remotePath'] is! String) {
      return false;
    }
    return true;
  }

  /// 立即中止当前请求并作废在途初始化；重复关闭不影响其他适配器实例。
  @override
  Future<void> dispose() async {
    _generation++;
    try {
      _releaseClient();
    } catch (error, stackTrace) {
      _logger?.error('WebDAV 资源释放失败：${error.runtimeType}\n$stackTrace');
      throw CloudConfigurationException('备份连接关闭失败，请稍后重试', error);
    }
  }

  /// 先摘下已发布的连接与存储引用，再关闭当前网络请求。
  void _releaseClient() {
    final client = _client;
    _client = null;
    _storageService = null;
    client?.c.close(force: true);
  }
}
