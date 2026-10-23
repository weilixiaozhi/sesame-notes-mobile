import 'package:sesame_cloud_backup/sesame_cloud_backup.dart' as cloud;

import 'logger_service.dart';

/// 插件日志接入应用日志系统，供配置存储与后端工厂共用。
final cloudBackupLogger = cloud.CloudSyncLogger(onLog: _logCloudBackup);

/// 保留插件日志级别与操作上下文；插件只提供经过脱敏的诊断内容。
void _logCloudBackup(cloud.LogLevel level, String message) {
  switch (level) {
    case cloud.LogLevel.debug:
      logger.debug('CloudBackup', message);
    case cloud.LogLevel.info:
      logger.info('CloudBackup', message);
    case cloud.LogLevel.warning:
      logger.warning('CloudBackup', message);
    case cloud.LogLevel.error:
      logger.error('CloudBackup', message);
  }
}
