import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> events;

  setUp(() async {
    events = [];
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
  });
  tearDown(() async => logger.clear());

  /// 为串行场景注入固定时钟和可控上传结果。
  AutoBackupService buildService({
    DateTime? lastSuccess,
    bool cloudConfigured = true,
    bool uploadFails = false,
    DateTime? now,
  }) {
    return AutoBackupService(
      loadLastSuccess: () async => lastSuccess,
      markSuccess: (t, uploadedProvider) async =>
          events.add('markSuccess:${t.toIso8601String()}'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async {
        events.add('localBackup');
        return AutoBackupSnapshot(
          file: File('fake.sqlite'),
          isCurrent: () => true,
        );
      },
      uploadToCloud: (f) async {
        events.add('upload');
        if (uploadFails) throw StateError('upload boom');
        return cloudConfigured ? 'test-cloud' : null;
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
      markSuccess: (_, uploadedProvider) async => events.add('markSuccess'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async {
        events.add('localBackup');
        return AutoBackupSnapshot(
          file: File('fake.sqlite'),
          isCurrent: () => true,
        );
      },
      uploadToCloud: (_) async {
        events.add('upload');
        return null;
      },
      now: () => DateTime(2026, 8, 1, 10, 0),
    );
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.skipped);
    expect(events, isEmpty, reason: '开关关闭时不得执行任何备份动作');
  });

  test('本地备份失败：同样降级为 failed 并记 dirty', () async {
    final service = AutoBackupService(
      loadLastSuccess: () async => null,
      markSuccess: (_, uploadedProvider) async => events.add('markSuccess'),
      markDirty: () async => events.add('markDirty'),
      createLocalBackup: () async => throw StateError('disk full'),
      uploadToCloud: (_) async {
        events.add('upload');
        return null;
      },
      now: () => DateTime(2026, 8, 1, 10, 0),
    );
    final outcome = await service.runOnLaunch();
    expect(outcome, AutoBackupOutcome.failed);
    expect(events, contains('markDirty'));
    expect(events, isNot(contains('upload')));
  });

  for (final phase in ['snapshot', 'upload', 'markSuccess']) {
    test('$phase 未完成时多次回到前台只执行一次备份，完成后恢复按天去重', () async {
      final entered = Completer<void>();
      final released = Completer<void>();
      DateTime? lastSuccess;

      /// 挂起指定的真实任务阶段，模拟慢磁盘、慢网络和未完成的状态写入。
      Future<void> step(String name) async {
        events.add(name);
        if (name == phase) {
          entered.complete();
          await released.future;
        }
      }

      final service = AutoBackupService(
        loadLastSuccess: () async => lastSuccess,
        markSuccess: (at, _) async {
          await step('markSuccess');
          lastSuccess = at;
        },
        markDirty: () async => events.add('dirty'),
        createLocalBackup: () async {
          await step('snapshot');
          return AutoBackupSnapshot(
            file: File('fake.snbak'),
            isCurrent: () => true,
          );
        },
        uploadToCloud: (_) async {
          await step('upload');
          return 'cloud';
        },
        now: () => DateTime(2026, 9, 27),
      );
      final first = service.runOnLaunch();
      await entered.future;
      final second = service.runOnLaunch();
      final third = service.runOnLaunch();
      released.complete();

      expect(await Future.wait([first, second, third]), [
        AutoBackupOutcome.success,
        AutoBackupOutcome.success,
        AutoBackupOutcome.success,
      ]);
      expect(events, ['snapshot', 'upload', 'markSuccess']);
      expect(await service.runOnLaunch(), AutoBackupOutcome.skipped);
      expect(events, ['snapshot', 'upload', 'markSuccess']);
    });
  }

  test('同一在途失败只记录一次，重试标记失败也不阻止下次成功重试', () async {
    final entered = Completer<void>();
    final released = Completer<void>();
    var uploads = 0;
    final service = AutoBackupService(
      loadLastSuccess: () async => null,
      markSuccess: (_, _) async => events.add('success'),
      markDirty: () async {
        events.add('dirty');
        throw StateError('模拟标记写入失败');
      },
      createLocalBackup: () async {
        events.add('snapshot');
        return AutoBackupSnapshot(
          file: File('fake.snbak'),
          isCurrent: () => true,
        );
      },
      uploadToCloud: (_) async {
        uploads++;
        if (uploads == 1) {
          entered.complete();
          await released.future;
          throw StateError('模拟上传失败');
        }
        return 'cloud';
      },
    );
    final first = service.runOnLaunch();
    await entered.future;
    final second = service.runOnLaunch();
    released.complete();

    expect(await Future.wait([first, second]), [
      AutoBackupOutcome.failed,
      AutoBackupOutcome.failed,
    ]);
    expect(events, ['snapshot', 'dirty']);
    expect(await service.runOnLaunch(), AutoBackupOutcome.success);
    expect(uploads, 2);
    expect(events, ['snapshot', 'dirty', 'snapshot', 'success']);
  });

  test('关闭开关导致跳过后重新开启，新的生命周期事件可以启动备份', () async {
    var enabled = false;
    final service = AutoBackupService(
      loadEnabled: () async => enabled,
      loadLastSuccess: () async => null,
      markSuccess: (_, _) async => events.add('success'),
      markDirty: () async => events.add('dirty'),
      createLocalBackup: () async {
        events.add('snapshot');
        return AutoBackupSnapshot(
          file: File('fake.snbak'),
          isCurrent: () => true,
        );
      },
      uploadToCloud: (_) async => null,
    );
    expect(await service.runOnLaunch(), AutoBackupOutcome.skipped);
    expect(events, isEmpty);
    enabled = true;
    expect(await service.runOnLaunch(), AutoBackupOutcome.success);
    expect(events, ['snapshot', 'success']);
  });
}
