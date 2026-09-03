/// 云备份插件类型门面。
///
/// 设计意图：settings 页（cloud_service_page / cloud_backup_config_page）与
/// 路由层需要引用备份后端的描述符/存储类型，但 UI 不应直接感知第三方备份
/// 实现包（UI 层不直连本地包）。本门面把用到的符号从插件核心包
/// re-export，业务层只依赖本文件，插件包的具体实现细节仍被隔离。
library;

export 'package:sesame_cloud_backup/sesame_cloud_backup.dart'
    show
        CloudAuthService,
        CloudBackend,
        CloudConfigField,
        CloudConfigFieldKind,
        CloudFile,
        CloudProvider,
        CloudProviderRegistry,
        CloudServiceStore,
        CloudServiceConfig,
        CloudServices,
        CloudStorageService,
        CloudUser,
        createCloudServices;
