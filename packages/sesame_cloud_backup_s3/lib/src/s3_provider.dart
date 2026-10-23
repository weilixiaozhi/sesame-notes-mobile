import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 's3_client.dart';
import 's3_storage_service.dart';

/// S3 Provider 实现
///
/// 支持所有 S3 兼容存储服务：
/// - AWS S3
/// - Cloudflare R2
/// - Backblaze B2
/// - MinIO (自托管)
/// - 阿里云 OSS
/// - 腾讯云 COS
/// - 七牛云 Kodo
class S3Provider implements CloudProvider {
  /// 后端诊断统一接入宿主日志，默认不输出到控制台。
  S3Provider({CloudSyncLogger? logger}) : _logger = logger;

  final CloudSyncLogger? _logger;
  S3Client? _client;
  S3StorageService? _storageService;
  int _generation = 0;

  @override
  CloudStorageService get storage {
    if (_storageService == null) {
      throw CloudConfigurationException(
          'S3Provider not initialized. Call initialize() first.');
    }
    return _storageService!;
  }

  /// 连接探测通过后才发布存储服务，过期初始化不能覆盖新的连接。
  @override
  Future<void> initialize(Map<String, dynamic> config) async {
    // 与接口契约一致：先校验再解析，避免缺失 key 直接抛 TypeError。
    if (!validateConfig(config)) {
      throw CloudConfigurationException(
        'Invalid S3 configuration. '
        'Required keys: endpoint, accessKey, secretKey, bucket',
      );
    }

    // 解析配置
    final rawEndpoint = config['endpoint'] as String;
    final region = config['region'] as String? ?? 'us-east-1';
    final accessKey = config['accessKey'] as String;
    final secretKey = config['secretKey'] as String;
    final bucket = config['bucket'] as String;
    final useSSL = config['useSSL'] as bool? ?? true;
    final port = config['port'] as int?;

    final generation = ++_generation;
    S3Client? client;
    try {
      _releaseClient();
      final (host, finalPort) = _parseEndpoint(rawEndpoint, port);
      client = S3Client(
        endpoint: host,
        region: region,
        accessKey: accessKey,
        secretKey: secretKey,
        useSSL: useSSL,
        port: finalPort,
      );
      _client = client;
      await client.listObjects(bucket: bucket);
      if (generation != _generation || !identical(_client, client)) {
        throw CloudConfigurationException('备份连接操作已取消，请重试');
      }
      _storageService = S3StorageService(client, bucket, logger: _logger);
    } catch (error, stackTrace) {
      // 只释放本次连接，较早操作失败时不能关闭已经生效的新连接。
      if (identical(_client, client)) {
        _releaseClient();
      } else {
        client?.dispose();
      }
      try {
        _logger?.error('S3 初始化失败：${error.runtimeType}\n$stackTrace');
      } catch (_) {
        // 日志接收器异常不能覆盖连接失败。
      }
      Error.throwWithStackTrace(
        CloudConfigurationException('备份连接失败，请检查网络、存储桶和凭据后重试', error),
        stackTrace,
      );
    }
  }

  /// 解析 endpoint 为 host + port。
  ///
  /// 支持：
  /// - `s3.example.com` / `s3.example.com:9000`
  /// - `http://s3.example.com:9000`（协议前缀会被剥离，scheme 由 [useSSL] 决定）
  /// - `[::1]:9000` 这类 IPv6 字面量（只在最后一个冒号后是数字时拆端口）
  (String, int?) _parseEndpoint(String endpoint, int? port) {
    if (endpoint.contains('://')) {
      final uri = Uri.parse(endpoint);
      return (uri.host, uri.hasPort ? uri.port : port);
    }

    final colonIndex = endpoint.lastIndexOf(':');
    final afterColon =
        colonIndex >= 0 ? endpoint.substring(colonIndex + 1) : '';
    final parsedPort = int.tryParse(afterColon);
    if (colonIndex > 0 && parsedPort != null) {
      return (endpoint.substring(0, colonIndex), parsedPort);
    }
    return (endpoint, port);
  }

  /// 必需文本与可选参数按实际类型校验，错误配置返回 false。
  @override
  bool validateConfig(Map<String, dynamic> config) {
    // 必需字段验证
    if (!config.containsKey('endpoint') ||
        !config.containsKey('accessKey') ||
        !config.containsKey('secretKey') ||
        !config.containsKey('bucket')) {
      return false;
    }

    // 非空验证
    final endpoint = config['endpoint'];
    final accessKey = config['accessKey'];
    final secretKey = config['secretKey'];
    final bucket = config['bucket'];

    return endpoint is String &&
        endpoint.isNotEmpty &&
        accessKey is String &&
        accessKey.isNotEmpty &&
        secretKey is String &&
        secretKey.isNotEmpty &&
        bucket is String &&
        bucket.isNotEmpty &&
        (config['region'] == null || config['region'] is String) &&
        (config['useSSL'] == null || config['useSSL'] is bool) &&
        (config['port'] == null ||
            config['port'] is int &&
                (config['port'] as int) > 0 &&
                (config['port'] as int) <= 65535);
  }

  /// 作废在途初始化并释放当前连接，重复释放安全。
  @override
  Future<void> dispose() async {
    _generation++;
    _releaseClient();
  }

  /// 先清除公开引用，再关闭网络连接。
  void _releaseClient() {
    final client = _client;
    _client = null;
    _storageService = null;
    client?.dispose();
  }
}
