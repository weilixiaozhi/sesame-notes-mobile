import '../core/auth_service.dart';
import '../core/cloud_provider.dart';
import 'cloud_provider_registry.dart';
import 'cloud_service_config.dart';

/// 根据 CloudServiceConfig 创建对应的 CloudProvider 和 CloudAuthService。
///
/// 返回 (CloudProvider, CloudAuthService) 元组。
///
/// 分派规则（核心包零 adapter 知识）：
/// - 本地后端 [CloudServiceConfig.local] 是核心包原生空服务，直接返回 (null, null)；
/// - 其余后端一律经 [CloudProviderRegistry] 按后端 ID 分发：各 adapter 包
///   在自身入口暴露 `register*Backend()`（主工程在 main.dart 调用完成自注册），
///   核心包不 import 任何 adapter，也不列举后端——新增后端只需 adapter 自带
///   [CloudBackend] 描述符，核心包零改动。
///
/// 未注册的 adapter 后端会抛 [StateError]，提示在 Composition Root 完成注册。
Future<({CloudProvider? provider, CloudAuthService? auth})> createCloudServices(
  CloudServiceConfig config,
) async {
  if (config.isLocal) {
    return (provider: null, auth: null);
  }

  // 先查注册再校验完整性：未注册是装配错误（必须抛错提示 Composition Root），
  // 配置不完整只是不可用（返回空服务）。两者不能混为一谈。
  final builder = CloudProviderRegistry.builderFor(config.backendId);
  if (builder == null) {
    throw StateError(
      '后端 ${config.backendId} 的 adapter 尚未注册。'
      '请在应用入口（main.dart）调用对应 adapter 包的 register*Backend() '
      '完成注册后再使用云同步功能。',
    );
  }
  if (!CloudProviderRegistry.isConfigValid(config)) {
    return (provider: null, auth: null);
  }
  return builder(config);
}
