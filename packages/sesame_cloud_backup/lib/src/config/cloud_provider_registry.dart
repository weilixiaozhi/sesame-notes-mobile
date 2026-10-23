import '../core/cloud_provider.dart';
import 'cloud_backend.dart';
import 'cloud_service_config.dart';

/// 按配置创建并完成连接与凭据初始化，调用方只接收可用的后端提供方。
typedef CloudProviderBuilder = Future<CloudProvider?> Function(
  CloudServiceConfig config,
);

/// 注册表条目：描述符 + 构建器。
typedef _BackendEntry = ({
  CloudBackend backend,
  CloudProviderBuilder builder,
});

/// 云后端注册表（插件化核心）。
///
/// 设计意图：注册表键是后端 ID 字符串，核心包不枚举任何后端，也不依赖任何
/// adapter 包；各 adapter 包在自己的库入口调用 [register] 提交
/// [CloudBackend] 描述符与构建器，由主工程 Composition Root（main.dart）
/// 显式触发。依赖方向为 adapter → 核心 ← 主工程，单向无环。
class CloudProviderRegistry {
  CloudProviderRegistry._();

  static final Map<String, _BackendEntry> _entries = {};

  /// 注册后端；重复注册时后者覆盖前者（测试可借此替换 mock）。
  static void register(CloudBackend backend, CloudProviderBuilder builder) {
    _entries[backend.id] = (backend: backend, builder: builder);
  }

  /// 注销后端（主要供测试清理用）。
  static void unregister(String backendId) => _entries.remove(backendId);

  /// 取后端构建器；未注册时返回 null。
  static CloudProviderBuilder? builderFor(String backendId) =>
      _entries[backendId]?.builder;

  /// 取后端描述符；未注册时返回 null。
  static CloudBackend? backendOf(String backendId) =>
      _entries[backendId]?.backend;

  /// 已注册后端描述符（按注册顺序），供 UI 列举可配置后端。
  static List<CloudBackend> get backends =>
      [for (final entry in _entries.values) entry.backend];

  /// 配置是否可用：本地后端恒可用，其余交回 adapter 声明的校验规则。
  ///
  /// 后端未注册时判定为不可用——此时无从校验字段完整性，也不该被激活。
  static bool isConfigValid(CloudServiceConfig config) {
    if (config.isLocal) return true;
    final backend = backendOf(config.backendId);
    return backend != null && backend.validateSettings(config.settings);
  }
}
