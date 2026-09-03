/// 恢复流程外部 .snbak 文件支持测试。
///
/// 需求锚点：
/// - 本机备份页「从文件恢复」与云端「从云端恢复」会把外部 .snbak 文件
///   传入恢复流程：loadBackups(externalPath:) 将外部文件插入列表头部并预选；
/// - 不传 externalPath 时行为与传 externalPath 时一致。
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetGlobalTestState);

  /// 在独立容器中装配恢复流程 Notifier（注入临时备份目录）。
  BackupRestoreFlowNotifier buildNotifier(Directory backupDir) {
    final container = ProviderContainer(
      overrides: [
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(
            backupService: LocalBackupService(backupDir: backupDir),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(backupRestoreFlowProvider.notifier);
  }

  test('loadBackups(externalPath:)：外部文件插入列表头部并预选', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_external_');
    addTearDown(() => tmp.delete(recursive: true));
    // 外部文件放在备份目录之外，模拟「从文件恢复」选择的任意位置文件。
    final externalDir = Directory(p.join(tmp.path, 'external'));
    await externalDir.create();
    final external = File(
      p.join(externalDir.path, 'sesame_notes_20260801_120000.snbak'),
    );
    await external.writeAsBytes([1, 2, 3]);

    final notifier = buildNotifier(Directory(p.join(tmp.path, 'backups')));
    await notifier.loadBackups(externalPath: external.path);

    final state = notifier.state;
    expect(state.backups, hasLength(1), reason: '备份目录为空时外部文件单独成项');
    expect(state.backups.first.pathKey, external.path);
    expect(state.selected?.pathKey, external.path, reason: '外部文件应被预选');
  });

  test('loadBackups()：不传外部路径时行为不变', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_none_');
    addTearDown(() => tmp.delete(recursive: true));

    final notifier = buildNotifier(tmp);
    await notifier.loadBackups();

    expect(notifier.state.backups, isEmpty);
    expect(notifier.state.selected, isNull, reason: '无外部文件不得预选');
  });
}
