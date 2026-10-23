/// 云服务页（备份与云同步）的展示模型与用例编排。
///
/// 设计意图：页面/入口 tile/备份同步区块共用同一批 provider，各自只做渲染；
/// 所有对 CloudServiceStore 的读写收敛到 [CloudBackupActions]，UI 不直接持有
/// 存储句柄（便于测试 override）。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/logging/cloud_backup_logger.dart';
import 'package:sesame_notes/features/settings/infrastructure/cloud_connection_tester.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 云备份字段的页面输入类型。
enum CloudBackupFieldType { text, secret, number, boolean }

/// 云备份配置字段展示模型。
class CloudBackupFieldDisplay {
  const CloudBackupFieldDisplay({
    required this.key,
    required this.labelKey,
    required this.type,
    required this.defaultValue,
    required this.isRequired,
  });

  final String key;
  final String labelKey;
  final CloudBackupFieldType type;
  final Object? defaultValue;
  final bool isRequired;

  /// 是否需要以密码输入框展示。
  bool get isSecret => type == CloudBackupFieldType.secret;
}

/// 云备份后端展示模型。
class CloudBackupBackendDisplay {
  const CloudBackupBackendDisplay({
    required this.id,
    required this.displayName,
    required this.fields,
    required this.isConfigured,
    required this.isActive,
    required this.lastSuccessAt,
    this.hasLoadError = false,
    this.settings = const {},
  });

  final String id;
  final String displayName;
  final List<CloudBackupFieldDisplay> fields;
  final bool isConfigured;
  final bool isActive;
  final DateTime? lastSuccessAt;

  /// 读取失败独立于未配置；管理页仍展示编辑和清除入口，不参与上传配置选择。
  final bool hasLoadError;

  /// 已保存设置（未配置时为空表）；卡片副标题脱敏展示端点用。
  final Map<String, dynamic> settings;
}

/// 备份状态总览：入口 tile 与备份同步区块共用的数据源。
class CloudBackupSelection {
  /// 激活配置的只读展示快照，校验结果由应用层在读取配置时计算。
  const CloudBackupSelection({
    required this.backendId,
    required this.settings,
    required this.isValid,
  });

  static const localBackendId = 'local';
  static const local = CloudBackupSelection(
    backendId: localBackendId,
    settings: {},
    isValid: true,
  );
  final String backendId;
  final Map<String, dynamic> settings;
  final bool isValid;
  bool get isLocal => backendId == localBackendId;
}

/// 备份状态总览：入口 tile 与备份同步区块共用的数据源。
class CloudBackupOverview {
  const CloudBackupOverview({
    required this.active,
    required this.backends,
    this.lastSuccessAt,
    this.lastSuccessProvider,
    this.dirtySince,
  });

  /// 当前激活配置（未配置第三方时为 local）。
  final CloudBackupSelection active;

  /// 注册表内全部第三方后端（含配置/激活/最近成功状态）。
  final List<CloudBackupBackendDisplay> backends;

  /// 最近一次成功备份时间。
  final DateTime? lastSuccessAt;

  /// 最近一次成功备份所属后端（云端上传成功时记录）。
  final String? lastSuccessProvider;

  /// 最近一次失败时间（自动重试标记）。
  final DateTime? dirtySince;

  /// 备份是否处于失败待重试状态。
  bool get isDirty =>
      dirtySince != null &&
      (lastSuccessAt == null || dirtySince!.isAfter(lastSuccessAt!));

  /// 是否只有本地备份（未配置任何第三方后端且未激活第三方）。
  bool get isLocalOnly =>
      active.isLocal && backends.every((b) => !b.isConfigured);
}

/// 备份健康状态（入口 tile / 云服务页 / 备份同步区块共用分支依据）。
enum CloudBackupStatusKind {
  /// 仅本地备份：未配置任何第三方后端。
  localOnly,

  /// 已配置第三方后端但当前未启用。
  configuredInactive,

  /// 已启用第三方后端，尚无成功备份。
  activeNoSuccess,

  /// 已启用且最近一次备份成功。
  success,

  /// 上次备份失败，等待自动重试。
  failed,
}

/// 把备份总览映射为健康状态（纯函数，测试锚点）。
///
/// 优先级：配置不可用或失败待重试 > 未配置第三方 > 配置未启用 > 无成功记录 > 成功。
CloudBackupStatusKind cloudBackupStatusOf(CloudBackupOverview overview) {
  if (!overview.active.isValid || overview.isDirty) {
    return CloudBackupStatusKind.failed;
  }
  if (overview.isLocalOnly) return CloudBackupStatusKind.localOnly;
  if (overview.active.isLocal) return CloudBackupStatusKind.configuredInactive;
  // 当前服务必须有上传成功记录，切换服务后不能沿用其他服务的成功状态。
  if (overview.lastSuccessAt != null &&
      overview.lastSuccessProvider == overview.active.backendId) {
    return CloudBackupStatusKind.success;
  }
  return CloudBackupStatusKind.activeNoSuccess;
}

/// 云备份配置与连接测试用例。
class CloudBackupActions {
  const CloudBackupActions();

  /// 提供已注册后端的稳定标识列表，不将注册表或插件描述符暴露给页面。
  List<String> get backendIds => List.unmodifiable(
    CloudProviderRegistry.backends.map((backend) => backend.id),
  );

  /// 使用本机保存的完整配置测试连接，展示快照不负责传递凭据。
  Future<void> testSavedConnection(String backendId) async {
    try {
      final settings = await loadSettings(backendId);
      if (settings == null) throw StateError('请先配置备份服务');
      await testConnection(backendId, settings);
    } catch (error, stackTrace) {
      logger.error(
        'CloudBackupActions',
        '测试已保存备份配置失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 读取指定后端的已保存设置。
  Future<Map<String, dynamic>?> loadSettings(String backendId) async {
    try {
      return (await CloudServiceStore(
        logger: cloudBackupLogger,
      ).load(backendId))?.settings;
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '加载云备份配置失败', error, stackTrace);
      rethrow;
    }
  }

  /// 校验页面提交的设置是否满足后端约束。
  bool isValid(String backendId, Map<String, dynamic> settings) {
    try {
      return CloudProviderRegistry.isConfigValid(
        CloudServiceConfig(backendId: backendId, settings: settings),
      );
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '校验云备份配置失败', error, stackTrace);
      return false;
    }
  }

  /// 测试指定云备份设置的真实连通性。
  Future<void> testConnection(
    String backendId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await CloudConnectionTester.test(
        CloudServiceConfig(backendId: backendId, settings: settings),
      );
    } catch (error) {
      // 中间层只保留后端上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.warning(
        'CloudBackupActions',
        '云连接测试失败: $backendId',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 仅保存配置（不激活；「保存 ≠ 生效」）。
  Future<void> saveOnly(String backendId, Map<String, dynamic> settings) async {
    try {
      await CloudServiceStore(
        logger: cloudBackupLogger,
      ).saveOnly(CloudServiceConfig(backendId: backendId, settings: settings));
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '保存云备份配置失败', error, stackTrace);
      rethrow;
    }
  }

  /// 激活指定后端（配置缺失/无效时返回 false）。
  Future<bool> activate(String backendId) async {
    try {
      return await CloudServiceStore(
        logger: cloudBackupLogger,
      ).activate(backendId);
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '激活云备份失败', error, stackTrace);
      rethrow;
    }
  }

  /// 清除指定后端的配置（回到未配置状态；云端数据不删除）。
  Future<void> clearConfig(String backendId) async {
    try {
      await CloudServiceStore(logger: cloudBackupLogger).clearConfig(backendId);
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '清除云备份配置失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 云备份配置用例入口。
final cloudBackupActionsProvider = Provider<CloudBackupActions>(
  (_) => const CloudBackupActions(),
);

/// 读取所有已注册后端的配置、激活和最近成功状态。
final cloudBackupBackendsProvider =
    FutureProvider<List<CloudBackupBackendDisplay>>((ref) async {
      try {
        final store = CloudServiceStore(logger: cloudBackupLogger);
        final activeId = await store.loadActiveBackendId();
        final db = ref.read(databaseProvider);
        final backupState = await (db.select(
          db.backupState,
        )..where((row) => row.id.equals(0))).getSingleOrNull();

        return await Future.wait(
          CloudProviderRegistry.backends.map((backend) async {
            final isActive = activeId == backend.id;
            CloudServiceConfig? saved;
            var hasLoadError = false;
            try {
              saved = await store.load(backend.id);
            } catch (_) {
              // 管理页把不可读配置显示为故障项，保留用户主动修复入口。
              hasLoadError = true;
            }
            return CloudBackupBackendDisplay(
              id: backend.id,
              displayName: backend.displayName,
              fields: backend.fields
                  .map(
                    (field) => CloudBackupFieldDisplay(
                      key: field.key,
                      labelKey: field.labelKey,
                      type: switch (field.kind) {
                        CloudConfigFieldKind.text => CloudBackupFieldType.text,
                        CloudConfigFieldKind.secret =>
                          CloudBackupFieldType.secret,
                        CloudConfigFieldKind.number =>
                          CloudBackupFieldType.number,
                        CloudConfigFieldKind.boolean =>
                          CloudBackupFieldType.boolean,
                      },
                      defaultValue: field.defaultValue,
                      isRequired: field.isRequired,
                    ),
                  )
                  .toList(growable: false),
              isConfigured: saved != null || hasLoadError,
              isActive: isActive,
              hasLoadError: hasLoadError,
              settings: saved?.settings ?? const {},
              lastSuccessAt:
                  isActive && backupState?.currentProvider == backend.id
                  ? backupState?.lastSuccessAt
                  : null,
            );
          }),
        );
      } catch (error, stackTrace) {
        logger.error('CloudBackupActions', '加载第三方备份状态失败', error, stackTrace);
        rethrow;
      }
    });

/// 备份状态总览（入口 tile / 云服务页头部 / 备份同步区块共用）。
final cloudBackupOverviewProvider = FutureProvider<CloudBackupOverview>((
  ref,
) async {
  try {
    final store = CloudServiceStore(logger: cloudBackupLogger);
    final activeId = await store.loadActiveBackendId();
    final backends = await ref.watch(cloudBackupBackendsProvider.future);
    final selected = backends
        .where((backend) => backend.id == activeId)
        .firstOrNull;
    final db = ref.read(databaseProvider);
    final backupState = await (db.select(
      db.backupState,
    )..where((row) => row.id.equals(0))).getSingleOrNull();

    return CloudBackupOverview(
      active: CloudBackupSelection(
        backendId: activeId,
        isValid:
            activeId == CloudServiceConfig.localBackendId ||
            selected != null &&
                !selected.hasLoadError &&
                CloudProviderRegistry.isConfigValid(
                  CloudServiceConfig(
                    backendId: activeId,
                    settings: selected.settings,
                  ),
                ),
        settings: Map.unmodifiable({
          for (final entry
              in (selected?.settings ?? const <String, dynamic>{}).entries)
            if (CloudProviderRegistry.backendOf(
                  activeId,
                )?.isSecretField(entry.key) ==
                false)
              entry.key: entry.value,
        }),
      ),
      backends: backends,
      lastSuccessAt: backupState?.lastSuccessAt,
      lastSuccessProvider: backupState?.currentProvider,
      dirtySince: backupState?.dirtySince,
    );
  } catch (error, stackTrace) {
    logger.error('CloudBackupActions', '加载备份状态总览失败', error, stackTrace);
    rethrow;
  }
});
