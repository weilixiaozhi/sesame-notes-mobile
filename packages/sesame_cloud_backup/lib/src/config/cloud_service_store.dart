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
/// 3. adapter 未声明的键一律丢弃，保存配置和激活后端分步进行；
/// 4. 业务层通过 [saveOnly] 保存完整设置，通过 [activate] 校验并切换生效后端。
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

  /// 配置键：只存 backendId 与非敏感字段。
  static String configKeyFor(String backendId) => 'cloud_cfg_$backendId';

  /// 读取用户保存的后端选择，配置管理页据此展示故障后端并提供修复入口。
  Future<String> loadActiveBackendId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(activeTypeKey) ?? CloudServiceConfig.localBackendId;
  }

  /// 加载当前激活的云服务配置。
  ///
  /// 未选择云服务时使用本地存储；已选择的配置不可读时明确失败，避免把未上传记成成功。
  Future<CloudServiceConfig> loadActive() async {
    final sp = await SharedPreferences.getInstance();
    final activeId =
        sp.getString(activeTypeKey) ?? CloudServiceConfig.localBackendId;
    if (activeId == CloudServiceConfig.localBackendId) {
      return CloudServiceConfig.local;
    }
    final config = await _loadConfig(sp, activeId);
    if (config == null) {
      throw StateError('已激活的云备份配置缺失，请重新配置或切换到本地备份');
    }
    return config;
  }

  /// 加载指定后端的配置（与是否激活无关）。
  Future<CloudServiceConfig?> load(String backendId) async {
    final sp = await SharedPreferences.getInstance();
    return _loadConfig(sp, backendId);
  }

  /// 仅保存配置，不激活。
  Future<void> saveOnly(CloudServiceConfig cfg) async {
    final sp = await SharedPreferences.getInstance();
    await _writeConfig(sp, cfg);
  }

  /// 加载指定后端的配置，并合并安全存储中的凭据。
  Future<CloudServiceConfig?> _loadConfig(
    SharedPreferences sp,
    String backendId,
  ) async {
    final raw = sp.getString(configKeyFor(backendId));
    if (raw == null) return null;

    final Map<String, dynamic> settings;
    try {
      final config = decodeCloudConfig(raw);
      if (config.backendId != backendId) {
        throw const FormatException('云备份配置身份与存储位置不一致');
      }
      settings = config.settings;
    } catch (error, stackTrace) {
      _warn('解析 $backendId 配置失败', error);
      Error.throwWithStackTrace(
        StateError('云备份配置无法读取，请重新配置或清除该配置'),
        stackTrace,
      );
    }

    return CloudServiceConfig(
      backendId: backendId,
      settings: await _mergeSecrets(backendId, settings),
    );
  }

  /// 合并凭据存储中的敏感字段。
  Future<Map<String, dynamic>> _mergeSecrets(
    String backendId,
    Map<String, dynamic> settings,
  ) async {
    final stored = await _credentialStorage.read(backendId);
    if (stored == null) return settings;
    try {
      final storedSettings = jsonDecode(stored) as Map<String, dynamic>;
      final backend = CloudProviderRegistry.backendOf(backendId);
      // 延迟注册前安全存储承载完整配置；注册后普通字段以显式保存值为准，凭据仍由安全存储提供。
      return {
        ...settings,
        for (final entry in storedSettings.entries)
          if (backend == null ||
              backend.isSecretField(entry.key) ||
              !settings.containsKey(entry.key))
            entry.key: entry.value,
      };
    } catch (error, stackTrace) {
      _warn('解析 $backendId 凭据存储失败', error);
      Error.throwWithStackTrace(
        StateError('云备份凭据无法读取，请重新填写凭据'),
        stackTrace,
      );
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
    await _persistPreference(
      sp,
      configKeyFor(cfg.backendId),
      encodeCloudConfig(
        CloudServiceConfig(backendId: cfg.backendId, settings: plain),
      ),
    );
  }

  /// 清空指定后端的配置，使其回到「未配置」状态。
  ///
  /// 清除当前后端时显式切回本地备份；清除非激活配置不影响当前选择。
  Future<void> clearConfig(String backendId) async {
    final sp = await SharedPreferences.getInstance();
    await _persistPreference(sp, configKeyFor(backendId), null);
    await _credentialStorage.delete(backendId);

    // 激活标记必须同步复位；清除其他后端或 local 时保持当前选择。
    if (backendId != CloudServiceConfig.localBackendId &&
        sp.getString(activeTypeKey) == backendId) {
      await _persistPreference(
          sp, activeTypeKey, CloudServiceConfig.localBackendId);
    }
  }

  /// 激活指定后端的配置。
  ///
  /// 仅当配置存在且完整时才激活；校验前先合并安全存储中的凭据。
  Future<bool> activate(String backendId) async {
    final sp = await SharedPreferences.getInstance();

    if (backendId == CloudServiceConfig.localBackendId) {
      await _persistPreference(sp, activeTypeKey, backendId);
      return true;
    }

    final cfg = await _loadConfig(sp, backendId);
    if (cfg == null || !CloudProviderRegistry.isConfigValid(cfg)) return false;
    await _persistPreference(sp, activeTypeKey, backendId);
    return true;
  }

  /// 偏好插件确认落盘后才完成操作；失败时重载其乐观缓存，避免内存状态冒充持久化结果。
  Future<void> _persistPreference(
    SharedPreferences sp,
    String key,
    String? value,
  ) async {
    try {
      final saved =
          value == null ? await sp.remove(key) : await sp.setString(key, value);
      if (!saved) throw StateError('云备份配置保存失败，请稍后重试');
    } catch (error, stackTrace) {
      try {
        await sp.reload();
      } catch (reloadError, reloadStackTrace) {
        _logger?.error(
            '刷新云备份配置缓存失败：${reloadError.runtimeType}\n$reloadStackTrace');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// 记录配置解析失败的 warning 日志，隐藏可能含有凭据的异常原文。
  void _warn(String message, Object error) {
    // 解析异常可能携带配置或凭据原文，只保留错误类型供诊断。
    _logger?.warning('$message: ${error.runtimeType}');
  }
}
