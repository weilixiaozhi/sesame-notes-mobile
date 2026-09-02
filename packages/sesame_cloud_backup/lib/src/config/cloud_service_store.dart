import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import 'cloud_credential_storage.dart';
import 'cloud_provider_registry.dart';
import 'cloud_service_config.dart';

/// 云服务配置持久化存储（唯一的配置写入口）。
///
/// 设计意图：
/// 1. 配置按后端注册的 [CloudBackend.fields] 拆成两半：凭据字段进可插拔的
///    [CloudCredentialStorage]（默认 Keychain / Keystore / DPAPI），其余字段
///    进 SharedPreferences（Android 侧是明文 XML，不能放凭据）；
/// 2. 后端未注册时无从判断字段敏感度，整份配置进安全存储，
///    SharedPreferences 只留后端 ID，绝不明文落盘；
/// 3. adapter 未声明的键一律丢弃，导入的凭据字段保留本机现有值；
/// 4. 业务层不得直接 `setString` 云配置键，导入 / 修改统一走本类的受控方法。
class CloudServiceStore {
  /// 激活后端 ID 标记键。
  static const activeTypeKey = 'cloud_active_type';

  final CloudCredentialStorage _credentialStorage;
  final CloudSyncLogger? _logger;

  CloudServiceStore({
    CloudCredentialStorage? credentialStorage,
    CloudSyncLogger? logger,
  })  : _credentialStorage = credentialStorage ?? _defaultCredentialStorage(),
        _logger = logger;

  /// 默认凭证存储:生产走系统安全存储;`flutter test` 环境没有平台通道,
  /// 自动回退到 SharedPreferences 测试实现,避免每个测试都手动注入。
  static CloudCredentialStorage _defaultCredentialStorage() {
    // flutter test 会向测试进程注入 FLUTTER_TEST=true 环境变量
    // (非编译期 dart-define),运行时判断即可区分测试与生产。
    if (Platform.environment['FLUTTER_TEST'] == 'true') {
      return SharedPreferencesCredentialStorage();
    }
    return FlutterSecureCredentialStorage();
  }

  /// 当前版本（v2）配置键：只存 backendId 与非敏感字段。
  static String configKeyFor(String backendId) => 'cloud_cfg_$backendId';

  /// 旧版（v1）配置键：扁平字段名由各后端自定义，读取时经
  /// [CloudBackend.importLegacy] 迁移，迁移成功后删除。
  static String legacyConfigKeyFor(String backendId) =>
      'cloud_${backendId}_cfg';

  /// 加载当前激活的云服务配置。
  ///
  /// 配置缺失或解析失败时回退本地存储，并记录 warning 日志便于排查。
  Future<CloudServiceConfig> loadActive() async {
    final sp = await SharedPreferences.getInstance();
    final activeId =
        sp.getString(activeTypeKey) ?? CloudServiceConfig.localBackendId;
    if (activeId == CloudServiceConfig.localBackendId) {
      return CloudServiceConfig.local;
    }
    return (await _loadConfig(sp, activeId)) ?? CloudServiceConfig.local;
  }

  /// 加载指定后端的配置（与是否激活无关）。
  Future<CloudServiceConfig?> load(String backendId) async {
    final sp = await SharedPreferences.getInstance();
    return _loadConfig(sp, backendId);
  }

  /// 保存并激活配置。
  Future<void> saveAndActivate(CloudServiceConfig cfg) async {
    final sp = await SharedPreferences.getInstance();
    await _writeConfig(sp, cfg);
    await sp.setString(activeTypeKey, cfg.backendId);
  }

  /// 仅保存配置，不激活。
  Future<void> saveOnly(CloudServiceConfig cfg) async {
    final sp = await SharedPreferences.getInstance();
    await _writeConfig(sp, cfg);
  }

  /// 从外部配置（YAML 导入等）写入云服务配置，唯一受控的导入入口。
  ///
  /// 外部文件只更新连接位置与非敏感选项：凭据字段一律保留本机值
  /// （外部配置可能带脱敏占位符，覆盖会让本机配置失效）。未注册的后端无从
  /// 判断敏感度，一律按凭据处理。
  Future<void> saveImported(CloudServiceConfig cfg) async {
    final sp = await SharedPreferences.getInstance();
    final backend = CloudProviderRegistry.backendOf(cfg.backendId);
    final existing = await _loadConfig(sp, cfg.backendId);

    final merged = <String, dynamic>{...cfg.settings};
    for (final key in merged.keys.toList()) {
      if (backend != null && !backend.isSecretField(key)) continue;
      final local = existing?.settings[key];
      if (local == null) {
        merged.remove(key);
      } else {
        merged[key] = local;
      }
    }
    await _writeConfig(
      sp,
      CloudServiceConfig(backendId: cfg.backendId, settings: merged),
    );
  }

  /// 加载指定后端的配置；读到旧版键时顺带完成迁移落库。
  Future<CloudServiceConfig?> _loadConfig(
    SharedPreferences sp,
    String backendId,
  ) async {
    final raw = sp.getString(configKeyFor(backendId));

    Map<String, dynamic> settings;
    if (raw != null) {
      try {
        settings = decodeCloudConfig(raw).settings;
      } catch (e) {
        _warn('解析 $backendId 配置失败，按未配置处理', e);
        return null;
      }
    } else {
      final migrated = await _migrateLegacy(sp, backendId);
      if (migrated == null) return null;
      settings = migrated;
    }

    final cfg = CloudServiceConfig(
      backendId: backendId,
      settings: await _mergeSecrets(sp, backendId, settings),
    );
    // 迁移落地：读到旧键后回写成 v2 形态，避免旧格式中的明文凭据继续留存。
    if (raw == null) await _writeConfig(sp, cfg);
    return cfg;
  }

  /// 旧版扁平配置迁移；无旧数据、后端未注册或迁移失败时返回 null。
  Future<Map<String, dynamic>?> _migrateLegacy(
    SharedPreferences sp,
    String backendId,
  ) async {
    final legacyKey = legacyConfigKeyFor(backendId);
    final legacyRaw = sp.getString(legacyKey);
    if (legacyRaw == null) return null;

    final backend = CloudProviderRegistry.backendOf(backendId);
    if (backend == null) {
      _warn('$backendId 后端未注册，旧版配置暂无法迁移', null);
      return null;
    }
    try {
      final settings =
          backend.importLegacy(jsonDecode(legacyRaw) as Map<String, dynamic>)
            // 旧 JSON 里缺字段会写成 null，落库前清掉。
            ..removeWhere((_, value) => value == null);
      await sp.remove(legacyKey);
      return settings;
    } catch (e) {
      _warn('迁移 $backendId 旧版配置失败，按未配置处理', e);
      return null;
    }
  }

  /// 合并凭据存储中的敏感字段；顺带把旧版明文凭据键搬进安全存储。
  Future<Map<String, dynamic>> _mergeSecrets(
    SharedPreferences sp,
    String backendId,
    Map<String, dynamic> settings,
  ) async {
    var stored = await _credentialStorage.read(backendId);

    // 安全存储为空时迁移 SharedPreferences 中残留的明文凭据。
    // cloud_credential_* 明文时，先搬进安全存储再删除明文键，
    // 避免升级后配置丢失或凭据继续明文落盘。
    if (stored == null || stored.isEmpty) {
      final legacyKey = 'cloud_credential_$backendId';
      final legacyRaw = sp.getString(legacyKey);
      if (legacyRaw != null && legacyRaw.isNotEmpty) {
        await _credentialStorage.write(backendId, legacyRaw);
        if (_credentialStorage is! SharedPreferencesCredentialStorage) {
          await sp.remove(legacyKey);
        }
        stored = legacyRaw;
      }
    }

    if (stored == null || stored.isEmpty) return settings;
    try {
      return {...settings, ...jsonDecode(stored) as Map<String, dynamic>};
    } catch (e) {
      _warn('解析凭据存储失败，使用配置内旧值（$backendId）', e);
      return settings;
    }
  }

  /// 统一写配置：凭据字段进安全存储，其余字段进 SharedPreferences。
  Future<void> _writeConfig(
      SharedPreferences sp, CloudServiceConfig cfg) async {
    final backend = CloudProviderRegistry.backendOf(cfg.backendId);
    final secrets = <String, dynamic>{};
    final plain = <String, dynamic>{};

    for (final entry in cfg.settings.entries) {
      if (backend == null) {
        // 后端未注册时无从判断敏感度：整份进安全存储，绝不明文落盘。
        secrets[entry.key] = entry.value;
      } else if (backend.isSecretField(entry.key)) {
        secrets[entry.key] = entry.value;
      } else if (backend.hasField(entry.key)) {
        plain[entry.key] = entry.value;
      }
    }

    await _credentialStorage.write(cfg.backendId, jsonEncode(secrets));
    await sp.setString(
      configKeyFor(cfg.backendId),
      encodeCloudConfig(
        CloudServiceConfig(backendId: cfg.backendId, settings: plain),
      ),
    );
    // 生产走安全存储时同步清理 SharedPreferences 明文凭证键，防止密钥继续留在
    // SharedPreferences XML 中（测试注入的明文实现除外）。
    if (_credentialStorage is! SharedPreferencesCredentialStorage) {
      await sp.remove('cloud_credential_${cfg.backendId}');
    }
  }

  /// 清空指定后端的配置，使其回到「未配置」状态。
  ///
  /// 注意：无需调用 activate(local) —— loadActive() 在对应配置缺失时会自动回退
  /// 本地存储。若清掉的正是不活跃类型，不得影响现有激活状态。
  Future<void> clearConfig(String backendId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(configKeyFor(backendId));
    await sp.remove(legacyConfigKeyFor(backendId));
    await _credentialStorage.delete(backendId);

    // 若清掉的正是当前激活的云后端（非 local），把激活标记复位为 'local'。
    // 仅 loadActive 的配置缺失回退是不够的 —— activeTypeKey 会残留僵尸脏值
    // （如 'webdav'），持久化状态与真实状态不一致，可能被「当前激活的云类型」
    // 类逻辑误读。仅复位「被清类型 == 当前激活」的场景：清非激活配置、
    // 或 clearConfig(local) 均不得影响现有激活状态。
    if (backendId != CloudServiceConfig.localBackendId &&
        sp.getString(activeTypeKey) == backendId) {
      await sp.setString(activeTypeKey, CloudServiceConfig.localBackendId);
    }
  }

  /// 激活指定后端的配置。
  ///
  /// 仅当配置存在且完整时才激活；激活前会先执行读取迁移，
  /// 确保凭据已从安全存储合并回来再校验。
  Future<bool> activate(String backendId) async {
    final sp = await SharedPreferences.getInstance();

    if (backendId == CloudServiceConfig.localBackendId) {
      await sp.setString(activeTypeKey, backendId);
      return true;
    }

    final cfg = await _loadConfig(sp, backendId);
    if (cfg == null || !CloudProviderRegistry.isConfigValid(cfg)) return false;
    await sp.setString(activeTypeKey, backendId);
    return true;
  }

  /// 记录 warning 日志（配置解析 / 迁移失败必须可见，避免静默吞错）。
  void _warn(String message, Object? error) {
    _logger?.warning(error == null ? message : '$message: $error');
  }
}
