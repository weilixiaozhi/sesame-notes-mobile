/// 自动备份编排（本地快照 + 云端上传，按天去重）测试。
///
/// 需求锚点：
/// - 冷启动/切回前台时执行一次自动备份（本地 SQLite 快照 + 上传到已配置的
///   第三方云端），按天去重：当天已成功则跳过；
/// - 未配置第三方备份时只做本地快照（云端上传 no-op）；
/// - 备份失败不打扰用户：记录 dirtySince（下次重试），不向上抛；
/// - 成功记录 lastSuccessAt 与 currentProvider（backup_state 单例行）。
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> events;

  setUp(() => events = []);

  AutoBackupService buildService({
    DateTime? lastSuccess,
    bool cloudConfigured = true,
    bool uploadFails = false,
    DateTime? now,
  }) {
    return AutoBackupService(
      loadLastSuccess: () async => lastSuccess,
      markSuccess: (t) async =>
          events.add('markSuccess:${t.toIso8601String()}'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async {
        events.add('localBackup');
        return File('fake.sqlite');
      },
      uploadToCloud: (f) async {
        events.add('upload');
        if (uploadFails) throw StateError('upload boom');
      },
      now: () => now ?? DateTime(2026, 8, 1, 10, 0),
    );
  }

  test('每天首次打开：本地备份 + 云端上传 + 记录成功', () async {
    final service = buildService();
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.success);
    expect(events, [
      'localBackup',
      'upload',
      'markSuccess:2026-08-01T10:00:00.000',
    ]);
  });

  test('当天已成功：跳过（按天去重）', () async {
    final service = buildService(
      lastSuccess: DateTime(2026, 8, 1, 8, 0), // 同一天
    );
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.skipped);
    expect(events, isEmpty, reason: '当天已备份不得重复执行');
  });

  test('昨天成功：今天重新备份（跨天去重）', () async {
    final service = buildService(lastSuccess: DateTime(2026, 7, 31, 23, 59));
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.success);
    expect(events, contains('localBackup'));
  });

  test('上传失败：不抛错，记录 dirty 待下次重试', () async {
    final service = buildService(uploadFails: true);
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.failed);
    expect(events, contains('localBackup'));
    expect(events, contains('markDirty'));
    expect(events, isNot(contains('markSuccess')));
  });

  test('自动备份开关关闭：直接跳过，不备份不上传', () async {
    final service = AutoBackupService(
      loadEnabled: () async => false,
      loadLastSuccess: () async => null,
      markSuccess: (_) async => events.add('markSuccess'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async {
        events.add('localBackup');
        return File('fake.sqlite');
      },
      uploadToCloud: (_) async => events.add('upload'),
      now: () => DateTime(2026, 8, 1, 10, 0),
    );
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.skipped);
    expect(events, isEmpty, reason: '开关关闭时不得执行任何备份动作');
  });

  test('本地备份失败：同样降级为 failed 并记 dirty', () async {
    final service = AutoBackupService(
      loadLastSuccess: () async => null,
      markSuccess: (_) async => events.add('markSuccess'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async => throw StateError('disk full'),
      uploadToCloud: (_) async => events.add('upload'),
      now: () => DateTime(2026, 8, 1, 10, 0),
    );
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.failed);
    expect(events, contains('markDirty'));
    expect(events, isNot(contains('upload')));
  });
}
