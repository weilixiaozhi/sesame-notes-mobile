import 'dart:io';

import 'package:drift/native.dart';
import 'package:sesame_notes/data/db.dart';

import '../domain/backup_manifest.dart';

/// 备份仅接受已有主库升级链覆盖的结构版本，未知版本不能进入恢复流程。
bool supportsBackupSchema(int sourceVersion) =>
    sourceVersion >= 4 && sourceVersion <= currentSchemaVersion;

/// 隔离库升级完成后派生当前清单，来源、内容与统计保持原值。
BackupManifest currentBackupManifest(BackupManifest source) =>
    BackupManifest.fromJson({
      ...source.toJson(),
      'db_schema_version': currentSchemaVersion,
    });

/// 对已核验来源版本的提取副本执行同一主库升级事务，不接触原备份或活动库。
Future<void> upgradeExtractedBackupSchema(File extracted) async {
  final database = SesameDatabase.withExecutor(NativeDatabase(extracted));
  try {
    // 惰性打开执行真实升级，并由主库的完整结构检查确认结果。
    await database.customSelect('SELECT 1').get();
  } finally {
    await database.close();
  }
}
