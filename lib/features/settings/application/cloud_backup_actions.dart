/// 第三方云备份页面的展示模型与用例编排。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/cloud_backup_facade.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
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
  });

  final String key;
  final String labelKey;
  final CloudBackupFieldType type;
  final Object? defaultValue;

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
  });

  final String id;
  final String displayName;
  final List<CloudBackupFieldDisplay> fields;
  final bool isConfigured;
  final bool isActive;
  final DateTime? lastSuccessAt;
}

/// 云备份配置与连接测试用例。
class CloudBackupActions {
  const CloudBackupActions();

  /// 读取指定后端的已保存设置。
  Future<Map<String, dynamic>?> loadSettings(String backendId) async {
    try {
      return (await CloudServiceStore().load(backendId))?.settings;
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
    } catch (error, stackTrace) {
      logger.warning(
        'CloudBackupActions',
        '云连接测试失败: $backendId',
        '$error\n$stackTrace',
      );
      rethrow;
    }
  }

  /// 保存并激活指定云备份设置。
  Future<void> saveAndActivate(
    String backendId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await CloudServiceStore().saveAndActivate(
        CloudServiceConfig(backendId: backendId, settings: settings),
      );
    } catch (error, stackTrace) {
      logger.error('CloudBackupActions', '保存云备份配置失败', error, stackTrace);
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
        final store = CloudServiceStore();
        final active = await store.loadActive();
        final db = ref.read(databaseProvider);
        final backupState = await (db.select(
          db.backupState,
        )..where((row) => row.id.equals(0))).getSingleOrNull();

        return Future.wait(
          CloudProviderRegistry.backends.map((backend) async {
            final isActive = !active.isLocal && active.backendId == backend.id;
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
                    ),
                  )
                  .toList(growable: false),
              isConfigured: await store.load(backend.id) != null,
              isActive: isActive,
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
