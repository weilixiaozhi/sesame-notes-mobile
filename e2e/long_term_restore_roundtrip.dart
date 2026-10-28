import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:uuid/uuid.dart';

import '../test/helpers/test_isolation.dart';

/// 连接现有隔离测试会话，分别为备份源和恢复端建立真实磁盘库及生产同步服务。
SyncService _connected(
  SyncService session,
  SesameDatabase db,
  String account,
) => SyncService(
  client: session.client,
  db: db,
  deviceId: session.deviceId,
  currentAccountIdGetter: () => account,
  memoRepository: MemoRepository(
    db,
    accountIdGetter: () => account,
    changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
  ),
);

/// 仅生成受支持的富文本字符和样式，保存原始内容时间以便逐字段核对。
MemoEntry _note(String id, String book, String title, {DateTime? createdAt}) {
  final now = DateTime.now().toUtc();
  return MemoEntry(
    id: id,
    memoBookId: book,
    bookType: 'normal',
    title: title,
    bodyJson: jsonEncode({
      'ops': [
        {
          'insert': title,
          'attributes': {'bold': true},
        },
        {'insert': '\n'},
        {'insert': '合成换机内容：中文🙂、换行\n第二段保留\n'},
      ],
    }),
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

/// 同时核对条目身份、父本关系、全部正文载荷与删除状态，不以记录数量代替内容一致。
Map<String, Object?> _contents(List<MemoEntry> entries) => {
  for (final entry in entries)
    entry.id: {
      'book': entry.memoBookId,
      'payload': entry.payload,
      'deleted_at': entry.deletedAt?.toUtc().toIso8601String(),
    },
};

/// 备忘录代表链路：真实备份恢复为独立副本，首次联网保留云端新内容，再明确上云并双端往返。
///
/// 两个磁盘库和两个已登录测试设备使用真实 HTTP；此用例不宣称手机界面或物理换机已验收。
Future<void> runLongTermRestoreRoundtrip(
  SyncService sessionA,
  SyncService sessionB,
  String account,
) async {
  final root = await createTestTempDirectory('long-term-restore-wire-');
  final sourceFile = File('${root.path}/source.sqlite');
  final restoredFile = File('${root.path}/restored.sqlite');
  final source = SesameDatabase.withExecutor(NativeDatabase(sourceFile));
  var restored = SesameDatabase.withExecutor(NativeDatabase(restoredFile));
  RecoverySession? preview;
  try {
    expect(sessionA.deviceId, isNot(sessionB.deviceId));
    final a = _connected(sessionA, source, account);
    var b = _connected(sessionB, restored, account);
    final sourceRepo = a.memoRepository!;
    final book = const Uuid().v4();
    final originalId = const Uuid().v4();
    await sourceRepo.createBook(
      id: book,
      name: '备份恢复真实同步验收',
      type: 'normal',
      storageMode: 'cloud',
    );
    await sourceRepo.saveEntry(
      _note(originalId, book, '备份内版本'),
      await sourceRepo.target(book),
    );
    await a.push();
    await a.fullMemoBook(memoBookId: book);
    final backedUp = (await sourceRepo.getEntries(
      book,
      accountId: account,
    )).single;
    final backup =
        await LocalBackupService(
          databaseFile: sourceFile,
          backupDir: Directory('${root.path}/backups'),
        ).createBackup(
          db: source,
          currentAccountId: account,
          trigger: BackupTrigger.automatic,
        );

    // 备份完成后云端继续编辑并新增，随后恢复旧快照不得默默覆盖这些新内容。
    final cloudAddedId = const Uuid().v4();
    await sourceRepo.saveEntry(
      _note(originalId, book, '云端较新版本', createdAt: backedUp.createdAt),
      await sourceRepo.target(book),
    );
    await sourceRepo.saveEntry(
      _note(cloudAddedId, book, '备份后云端新增'),
      await sourceRepo.target(book),
    );
    await a.push();
    await a.fullMemoBook(memoBookId: book);
    final cloudBefore = _contents(
      await sourceRepo.getEntries(book, accountId: account),
    );

    final importer = BackupImportService(tempDirOverride: root);
    preview = await importer.openBackup(backupFile: backup);
    expect(await restored.select(restored.memoBooks).get(), isEmpty);
    preview.memoBookDecisions[book] = RecoveryDecision.forkCloudToLocal;
    preview.memoTargetSnapshots.addAll(
      await importer.captureMemoTargets(restored, [book]),
    );
    final report = await importer.apply(
      session: preview,
      liveDb: restored,
      localSelfId: 'restore-roundtrip-synthetic-self',
      currentAccountId: account,
    );
    final copyId = report.memoBookResults[book]!;
    expect(copyId, isNot(book));
    var restoredRepo = b.memoRepository!;
    final restoredBook = (await restoredRepo.getBook(
      copyId,
      accountId: account,
    ))!;
    expect(restoredBook.storageMode, 'local');
    expect(restoredBook.sourceMemoBookId, book);
    final copied = (await restoredRepo.getEntries(
      copyId,
      accountId: account,
    )).single;
    expect(copied.id, isNot(originalId));
    expect(copied.sourceEntryId, originalId);
    expect(copied.memoBookId, copyId);
    expect(copied.payload, backedUp.payload);

    // 首次同步使用产品初始化流程；本机副本保留旧快照，原云本读取最新内容。
    await b.synchronize();
    await b.fullMemoBook(memoBookId: book);
    expect(
      _contents(await restoredRepo.getEntries(book, accountId: account)),
      cloudBefore,
    );
    expect(
      (await restoredRepo.getEntries(
        copyId,
        accountId: account,
      )).single.payload,
      backedUp.payload,
    );
    expect(
      (await restoredRepo.getBook(copyId, accountId: account))!.storageMode,
      'local',
    );

    // 明确选择将恢复副本上云，与应用使用相同的原子迁移及父子同步队列。
    await restoredRepo.moveToCloud(await restoredRepo.target(copyId));
    await b.push();
    await b.fullMemoBook(memoBookId: copyId);
    await a.pull();
    await a.fullMemoBook(memoBookId: copyId);
    expect(
      _contents(await sourceRepo.getEntries(copyId, accountId: account)),
      _contents(await restoredRepo.getEntries(copyId, accountId: account)),
    );

    // 不调用网络期间保存修改及新增；关闭并重新打开磁盘库，验证内容与待办真实落盘。
    final offlineId = const Uuid().v4();
    await restoredRepo.saveEntry(
      _note(copied.id, copyId, '恢复后离线修改', createdAt: copied.createdAt),
      await restoredRepo.target(copyId),
    );
    await restoredRepo.saveEntry(
      _note(offlineId, copyId, '恢复后离线新增'),
      await restoredRepo.target(copyId),
    );
    final offline = _contents(
      await restoredRepo.getEntries(copyId, accountId: account),
    );
    expect(offline, hasLength(2));
    await restored.close();
    restored = SesameDatabase.withExecutor(NativeDatabase(restoredFile));
    b = _connected(sessionB, restored, account);
    restoredRepo = b.memoRepository!;
    expect(
      _contents(await restoredRepo.getEntries(copyId, accountId: account)),
      offline,
    );
    final pending =
        await (restored.select(restored.syncChanges)..where(
              (row) => row.memoBookId.equals(copyId) & row.pushedAt.isNull(),
            ))
            .get();
    expect(pending, hasLength(2));
    await b.push();
    await a.pull();
    expect(
      _contents(await sourceRepo.getEntries(copyId, accountId: account)),
      offline,
    );
    expect(
      await (restored.select(restored.syncChanges)..where(
            (row) => row.memoBookId.equals(copyId) & row.pushedAt.isNull(),
          ))
          .get(),
      isEmpty,
    );

    // 第二端修改也能返回恢复端，且原云本的备份后编辑和新增始终保持原样。
    final peerEntry = (await sourceRepo.getEntries(
      copyId,
      accountId: account,
    )).singleWhere((entry) => entry.id == offlineId);
    await sourceRepo.saveEntry(
      _note(offlineId, copyId, '另一设备修改回传', createdAt: peerEntry.createdAt),
      await sourceRepo.target(copyId),
    );
    await a.push();
    await b.pull();
    expect(
      _contents(await restoredRepo.getEntries(copyId, accountId: account)),
      _contents(await sourceRepo.getEntries(copyId, accountId: account)),
    );
    await a.fullMemoBook(memoBookId: book);
    expect(
      _contents(await sourceRepo.getEntries(book, accountId: account)),
      cloudBefore,
    );
    expect(
      await restored.customSelect('PRAGMA foreign_key_check').get(),
      isEmpty,
    );
    stdout.writeln(
      'LONG_TERM_RESTORE_ROUNDTRIP ${jsonEncode({'domain': 'memos', 'backup': 'snbak', 'restore': 'fresh_disk_sqlite_local_fork', 'first_sync': 'real_http_sync_service', 'offline_reopen': 'content_and_two_pending_changes_match', 'two_device_contents': 'all_fields_match', 'newer_original_cloud_records': 'unchanged', 'phone_ui_or_process_kill': 'not_measured'})}',
    );
  } catch (error, stack) {
    printOnFailure('备份恢复后的真实同步验收失败：$error\n$stack');
    rethrow;
  } finally {
    await preview?.close();
    await source.close();
    await restored.close();
    await root.delete(recursive: true);
  }
}
