/// 恢复流程 Notifier 打开备份测试。
///
/// 需求锚点：
/// - 入口传入 .snbak 文件直接打开进入预览（无选择列表步骤）；
/// - 打开成功后默认全选：本地→恢复为本地账本 / 云端账号匹配→恢复为云账本 /
///   云端不匹配或未登录→恢复为本地副本；
/// - 打开失败（损坏/非备份文件）→ openFailed，不产生会话；
/// - closeSession 释放解压出的临时 sqlite（幂等）。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

/// 返回固定会话的认证桩。
class _StubAuthNotifier extends AuthSessionNotifier {
  _StubAuthNotifier(this.session);
  final AuthSession? session;
  @override
  AuthSession? build() => session;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
  });

  /// 构造真实 .snbak 源：本地账本 + 当前账号域云端账本（owner 绑定 acc-1）。
  Future<File> createFixtureBackup(Directory tmp) async {
    final srcFile = File(p.join(tmp.path, 'src.sqlite'));
    final backupDir = Directory(p.join(tmp.path, 'backups'));
    final srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
    addTearDown(() async {
      try {
        await srcDb.close();
      } catch (_) {}
    });
    final now = DateTime.utc(2026, 8, 1);
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '11111111-1111-4111-8111-111111111111',
            name: '私人账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: '22222222-2222-4222-8222-222222222222',
            name: '家庭账本',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('sync-s1'),
            scopeAccountId: const d.Value('acc-1'),
            updatedAt: now,
          ),
        );
    await srcDb
        .into(srcDb.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: 'member-acc1',
            ledgerId: '22222222-2222-4222-8222-222222222222',
            displayName: 'Alice',
            memberType: 'REGISTERED',
            linkedAccountId: const d.Value('acc-1'),
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    return LocalBackupService(
      backupDir: backupDir,
      databaseFile: srcFile,
    ).createBackup(db: srcDb, currentAccountId: 'acc-1');
  }

  BackupRestoreFlowNotifier buildNotifier(
    Directory tmp, {
    AuthSession? session,
  }) {
    final liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(liveDb.close);
    // 导入服务解压临时 sqlite 前不负责建目录，测试目录需先创建
    final extractDir = Directory(p.join(tmp.path, 'extract'))
      ..createSync(recursive: true);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(liveDb),
        authSessionProvider.overrideWith(() => _StubAuthNotifier(session)),
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(
            importService: BackupImportService(tempDirOverride: extractDir),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(backupRestoreFlowProvider.notifier);
  }

  test('打开备份：直接进入预览并默认全选（未登录：云端→恢复为本地副本）', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_flow_');
    addTearDown(() => tmp.delete(recursive: true));
    final backup = await createFixtureBackup(tmp);
    final notifier = buildNotifier(tmp);

    await notifier.openBackup(file: backup);

    expect(notifier.state.error, RestoreFlowError.none);
    expect(notifier.state.session, isNotNull, reason: '打开成功应持有只读会话');
    expect(notifier.state.items, hasLength(2));
    expect(
      notifier.state.decisions['11111111-1111-4111-8111-111111111111'],
      RestoreDecision.restoreLocal,
      reason: '本地账本默认恢复为本地账本',
    );
    expect(
      notifier.state.decisions['22222222-2222-4222-8222-222222222222'],
      RestoreDecision.forkCloudToLocal,
      reason: '未登录时云端账本默认恢复为本地副本',
    );
    await notifier.closeSession();
  });

  test('打开备份：登录账号匹配时云端账本默认恢复为云账本', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_flow_auth_');
    addTearDown(() => tmp.delete(recursive: true));
    final backup = await createFixtureBackup(tmp);
    final notifier = buildNotifier(
      tmp,
      session: const AuthSession(
        accessToken: 't',
        userId: 'acc-1',
        deviceId: 'd',
      ),
    );

    await notifier.openBackup(file: backup);

    expect(
      notifier.state.decisions['22222222-2222-4222-8222-222222222222'],
      RestoreDecision.reconnect,
      reason: '账号匹配时云端账本默认恢复为云账本',
    );
    await notifier.closeSession();
  });

  test('打开损坏文件：openFailed，不产生会话', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_bad_');
    addTearDown(() => tmp.delete(recursive: true));
    final bad = File(p.join(tmp.path, 'bad.snbak'));
    await bad.writeAsBytes([1, 2, 3]);
    final notifier = buildNotifier(tmp);

    await notifier.openBackup(file: bad);

    expect(notifier.state.error, RestoreFlowError.openFailed);
    expect(notifier.state.session, isNull);
    expect(notifier.state.items, isEmpty);
  });

  test('closeSession：释放解压出的临时 sqlite', () async {
    final tmp = await Directory.systemTemp.createTemp('restore_close_');
    addTearDown(() => tmp.delete(recursive: true));
    final backup = await createFixtureBackup(tmp);
    final extractDir = Directory(p.join(tmp.path, 'extract'));
    final notifier = buildNotifier(tmp);

    await notifier.openBackup(file: backup);
    expect(
      extractDir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.sqlite'),
      ),
      isNotEmpty,
      reason: '打开备份后临时目录应存在解压出的 sqlite',
    );

    await notifier.closeSession();
    expect(notifier.state.session, isNull);
    expect(
      extractDir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.sqlite'),
      ),
      isEmpty,
      reason: '关闭会话后临时 sqlite 应被清理',
    );
    await notifier.closeSession(); // 幂等：重复关闭不抛异常
  });
}
