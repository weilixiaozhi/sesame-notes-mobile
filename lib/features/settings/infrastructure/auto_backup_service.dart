/// 自动备份编排：本地快照、云端上传和成功记录构成一次完整任务。
/// 冷启动与回到前台共用在途结果，完成后按本地日历日跳过已成功的备份。
/// 失败记录重试标记与日志，由下次生命周期触发重试。
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

/// 已合法落盘的自动备份及其发送前身份守卫，不持有临时快照或确认会话。
class AutoBackupSnapshot {
  /// 文件和守卫由同一次快照任务共同生成，上传阶段不能重设所属身份。
  const AutoBackupSnapshot({required this.file, required this.isCurrent});

  final File file;
  final bool Function() isCurrent;
}

/// 自动备份编排实例（依赖注入式，便于测试）。
class AutoBackupService {
  final Future<bool> Function() loadEnabled;
  final Future<DateTime?> Function() loadLastSuccess;
  final Future<void> Function(DateTime successAt, String? uploadedProvider)
  markSuccess;
  final Future<void> Function() markDirty;
  final Future<AutoBackupSnapshot> Function() createLocalBackup;
  final Future<String?> Function(AutoBackupSnapshot snapshot) uploadToCloud;
  final DateTime Function() now;
  Future<AutoBackupOutcome>? _inFlight;

  /// 注入备份、上传与状态持久化边界，默认使用本地时钟。
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

  /// 未注入开关读取器时，自动备份默认启用。
  static Future<bool> _alwaysEnabled() async => true;

  /// 并发的生命周期事件共用完整任务，成功、失败和跳过都会释放在途状态。
  Future<AutoBackupOutcome> runOnLaunch() =>
      _inFlight ??= _runOnce().whenComplete(() => _inFlight = null);

  /// 执行开关、按天去重、快照、上传与成功记录；所有调用方等待同一结果。
  Future<AutoBackupOutcome> _runOnce() async {
    try {
      final today = now();
      // 用户可在本机备份页关闭自动备份：关闭时完全不执行备份动作。
      if (!await loadEnabled()) {
        return AutoBackupOutcome.skipped;
      }
      final last = await loadLastSuccess();
      if (last != null && _sameDay(last, today)) {
        return AutoBackupOutcome.skipped;
      }
      final snapshot = await createLocalBackup();
      final uploadedProvider = await uploadToCloud(snapshot);
      await markSuccess(today, uploadedProvider);
      return AutoBackupOutcome.success;
    } catch (error, stackTrace) {
      logger.error(
        'AutoBackup',
        '自动备份未完成，下次启动或回到前台时重试',
        safeErrorSummary(error),
        stackTrace,
      );
      try {
        await markDirty();
      } catch (dirtyError, dirtyStackTrace) {
        logger.error(
          'AutoBackup',
          '保存自动备份重试标记失败',
          safeErrorSummary(dirtyError),
          dirtyStackTrace,
        );
      }
      return AutoBackupOutcome.failed;
    }
  }

  /// 同一天判断（本地时区日历日）。
  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
