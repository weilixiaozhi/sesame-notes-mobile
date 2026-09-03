/// 自动备份编排（D 备份语义落地：本地快照 + 云端上传，按天去重）。
///
/// 设计意图：
/// - 冷启动 / 切回前台时执行一次自动备份：先做本地 SQLite 快照（LocalBackupService
///   原子落盘），若已配置第三方备份（Supabase/WebDAV/S3）则把最新快照上传到云端
///   固定路径（base64 编码，覆盖式单份最新）；
/// - 按天去重：backup_state.lastSuccessAt 与当天比较，当天已成功直接跳过
///   （与 resumed 触发的幂等一致）；
/// - 失败不打扰用户：记录 dirtySince（下次触发重试）并记日志，不向上抛；
/// - 依赖注入式构造便于单元测试；生产由 autoBackupCoordinatorProvider 装配。
library;

import 'dart:io';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 自动备份执行结果。
enum AutoBackupOutcome {
  /// 成功（本地快照 + 云端上传完成或云端未配置）。
  success,

  /// 失败（本地或上传失败，已记 dirty 待重试）。
  failed,

  /// 当天已成功，跳过。
  skipped,
}

/// 自动备份编排实例（依赖注入式，便于测试）。
class AutoBackupService {
  final Future<bool> Function() loadEnabled;
  final Future<DateTime?> Function() loadLastSuccess;
  final Future<void> Function(DateTime successAt) markSuccess;
  final Future<void> Function() markDirty;
  final Future<File> Function() createLocalBackup;
  final Future<void> Function(File backupFile) uploadToCloud;
  final DateTime Function() now;

  AutoBackupService({
    Future<bool> Function()? loadEnabled,
    required this.loadLastSuccess,
    required this.markSuccess,
    required this.markDirty,
    required this.createLocalBackup,
    required this.uploadToCloud,
    DateTime Function()? now,
  }) : loadEnabled = loadEnabled ?? _alwaysEnabled,
       now = now ?? DateTime.now;

  /// 开关默认值：未注入时恒启用（历史调用方不受影响）。
  static Future<bool> _alwaysEnabled() async => true;

  /// 执行一次自动备份；开关关闭直接跳过，开关打开后按天去重，失败降级不打扰用户。
  Future<AutoBackupOutcome> runOnLaunch() async {
    final today = now();
    try {
      // 用户可在本机备份页关闭自动备份：关闭时完全不执行备份动作。
      if (!await loadEnabled()) {
        return AutoBackupOutcome.skipped;
      }
      final last = await loadLastSuccess();
      if (last != null && _sameDay(last, today)) {
        return AutoBackupOutcome.skipped;
      }
      final file = await createLocalBackup();
      await uploadToCloud(file);
      await markSuccess(today);
      return AutoBackupOutcome.success;
    } catch (error, stackTrace) {
      logger.warning('AutoBackup', '自动备份失败(下次触发重试)', '$error\n$stackTrace');
      try {
        await markDirty();
      } catch (_) {
        // dirty 记录失败不阻断：备份失败信息已记日志。
      }
      return AutoBackupOutcome.failed;
    }
  }

  /// 同一天判断（本地时区日历日）。
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
