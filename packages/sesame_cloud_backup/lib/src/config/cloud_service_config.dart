import 'dart:convert';

/// 云服务配置：后端 ID + 该后端自有的不透明配置。
///
/// 核心包不认识任何具体后端，也不认识 [settings] 里的键：字段 schema、校验
/// 与序列化迁移全部由 adapter 注册的 [CloudBackend] 提供（见 cloud_backend.dart）。
/// 新增后端只需新增 adapter 包，核心零改动。
class CloudServiceConfig {
  /// 本地存储后端 ID：核心原生空服务，不由 adapter 提供。
  static const localBackendId = 'local';

  const CloudServiceConfig({
    required this.backendId,
    this.settings = const {},
  });

  /// 后端 ID：与 [CloudBackend.id] 一致，同时作为持久化键后缀。
  final String backendId;

  /// adapter 自有的配置；核心只负责搬运，不解释键名与取值。
  final Map<String, dynamic> settings;

  /// 本地存储配置（未配置第三方后端时的默认值）。
  static const local = CloudServiceConfig(backendId: localBackendId);

  /// 是否未配置第三方后端（仅本地备份）。
  bool get isLocal => backendId == localBackendId;

  Map<String, dynamic> toJson() => {
        'backendId': backendId,
        'settings': settings,
      };

  factory CloudServiceConfig.fromJson(Map<String, dynamic> json) =>
      CloudServiceConfig(
        backendId: json['backendId'] as String? ?? localBackendId,
        settings: Map<String, dynamic>.from((json['settings'] as Map?) ?? {}),
      );

  @override
  String toString() =>
      'CloudServiceConfig($backendId, ${settings.keys.toList()})';
}

/// 配置 → JSON 字符串。
String encodeCloudConfig(CloudServiceConfig c) => jsonEncode(c.toJson());

/// JSON 字符串 → 配置。
CloudServiceConfig decodeCloudConfig(String raw) =>
    CloudServiceConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
