/// Sesame Notes 云备份核心协议。
///
/// 只定义可插拔后端提供方的抽象接口与注册机制，不绑定任何具体后端：
/// - 提供方抽象：[CloudProvider] / [CloudAuthService] / [CloudStorageService]；
/// - 配置与装配：[CloudBackend] / [CloudServiceConfig] / [CloudServiceStore] /
///   [CloudProviderRegistry] / [createCloudServices]；
/// - 后端注册：各 adapter 包在自己的库入口暴露 `register*Backend()`，
///   由主工程在 Composition Root（main.dart）显式调用完成自注册。
library;

// Core interfaces
export 'src/core/auth_service.dart' show CloudUser, CloudAuthService;
export 'src/core/cloud_provider.dart' show CloudProvider;
export 'src/core/exceptions.dart'
    show
        CloudSyncException,
        CloudNotAuthenticatedException,
        CloudConfigurationException,
        CloudStorageException,
        CloudAuthException;

// 只暴露存储接口契约，内部 Noop 实现类不对外导出
export 'src/core/storage_service.dart' show CloudStorageService, CloudFile;

// Configuration
export 'src/config/cloud_backend.dart'
    show CloudBackend, CloudConfigField, CloudConfigFieldKind;
export 'src/config/cloud_service_config.dart' show CloudServiceConfig;
export 'src/config/cloud_credential_storage.dart' show CloudCredentialStorage;
export 'src/config/cloud_service_store.dart' show CloudServiceStore;
export 'src/config/cloud_provider_registry.dart'
    show CloudServices, CloudServicesBuilder, CloudProviderRegistry;
export 'src/config/provider_factory.dart' show createCloudServices;

// Utilities
export 'src/utils/logger.dart' show CloudSyncLogger;
export 'src/utils/path_helper.dart' show PathHelper;
