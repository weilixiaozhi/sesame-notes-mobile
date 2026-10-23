import 'storage_service.dart';

/// 云服务提供方抽象接口。
///
/// 每个云服务（Supabase、WebDAV、S3 等）实现本接口，
/// 使用各自配置的凭据初始化连接，并统一提供文件存储能力。
abstract class CloudProvider {
  /// 存储服务实例。
  CloudStorageService get storage;

  /// 使用配置初始化提供方。
  ///
  /// [config] - 配置参数（提供方特有）。
  ///
  /// 不同提供方需要不同配置：
  /// - Supabase: {'url': String, 'anonKey': String, 'bucket': String?}
  /// - WebDAV: {'url': String, 'username': String, 'password': String, 'remotePath': String?}
  /// - S3: {'region': String, 'accessKey': String, 'secretKey': String, 'bucket': String}
  ///
  /// 配置无效时抛出 [CloudConfigurationException]。
  Future<void> initialize(Map<String, dynamic> config);

  /// 初始化前校验配置。
  ///
  /// 在 [initialize] 之前调用可避免运行时错误。
  ///
  /// 配置有效返回 true，否则返回 false。
  bool validateConfig(Map<String, dynamic> config);

  /// 释放资源。
  ///
  /// 关闭连接、清理缓存等；切换提供方或应用退出时应调用。
  Future<void> dispose();
}
