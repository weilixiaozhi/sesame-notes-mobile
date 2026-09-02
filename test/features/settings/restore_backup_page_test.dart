/// 备份恢复页 4 步流程 widget 测试。
///
/// - Step 1 选择备份 + 输入密码 → 打开（只读）；
/// - Step 2 查看备份内容（本地/云端分域展示）；
/// - Step 3 每账本选择恢复策略（显式三选一）；
/// - Step 4 确认导入（明示不覆盖现有账本）→ 单事务应用；
/// - Step 1–3 全程 live DB 0 mutation；
/// - 应用后：云端账本 Fork（sync_id 恒 NULL）、recovery_log 落库。
///
/// 说明：文件 IO 与 Argon2id 是真实异步，FakeAsync 区不驱动它们——
/// 所有 IO 步骤收进 runAsync，UI 步骤验证渲染与状态切换。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/features/settings/presentation/restore_backup_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    '4 步流程：Step1-3 零写入，Step4 应用后 Fork 落库 + 审计日志',
    (tester) async {
      // ---- 真实备份源（全部 IO 在 runAsync 中执行）----
      late final Directory tmp;
      late final File srcFile;
      late final Directory backupDir;
      late final Directory extractDir;
      late final SesameDatabase srcDb;
      await tester.runAsync(() async {
        tmp = await Directory.systemTemp.createTemp('restore_page_');
        srcFile = File(p.join(tmp.path, 'src.sqlite'));
        backupDir = Directory(p.join(tmp.path, 'backups'));
        extractDir = Directory(p.join(tmp.path, 'extract'));
        await extractDir.create(recursive: true);
        srcDb = SesameDatabase.forTesting(NativeDatabase(srcFile));
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
        await LocalBackupService(
          backupDir: backupDir,
          databaseFile: srcFile,
        ).createBackup(
          db: srcDb,
          secrets: BackupSecrets(password: 'pw-123456'),
        );
      });
      addTearDown(() async {
        try {
          await srcDb.close();
        } catch (_) {}
        try {
          await tmp.delete(recursive: true);
        } catch (_) {}
      });

      // ---- live 库与依赖覆盖 ----
      final liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
      addTearDown(liveDb.close);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(liveDb),
          backupRestoreFlowProvider.overrideWith(
            () => BackupRestoreFlowNotifier(
              backupService: LocalBackupService(
                backupDir: backupDir,
                databaseFile: File(p.join(tmp.path, 'live.sqlite')),
              ),
              importService: BackupImportService(tempDirOverride: extractDir),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(backupRestoreFlowProvider.notifier);

      // Step 1：加载备份列表（IO 在 runAsync 中驱动）
      await tester.runAsync(() => notifier.loadBackups());
      await tester.binding.setSurfaceSize(const Size(800, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const RestoreBackupPage(),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.textContaining(RegExp(r'\d+月\d+日')),
        findsWidgets,
        reason: 'Step 1 应展示时间戳备份列表',
      );

      // Step 1→2：打开备份（Argon2id + 文件 IO 在 runAsync 中驱动）
      final backups = container.read(backupRestoreFlowProvider).backups;
      expect(backups, hasLength(1));
      await tester.runAsync(
        () => notifier.openBackup(file: backups.single, secret: 'pw-123456'),
      );
      await tester.pumpAndSettle();

      // Step 2：内容分域展示
      expect(find.text('私人账本'), findsOneWidget);
      expect(find.text('家庭账本'), findsOneWidget);
      expect(find.text('acc-1'), findsWidgets, reason: '云端账本按归属账号分域展示');

      // Step 1–3 零写入
      expect(
        await liveDb.select(liveDb.ledgers).get(),
        isEmpty,
        reason: '打开/预览阶段不得写入 live DB',
      );

      // Step 3：策略选择（显式三选一，无隐式 Merge）
      await tester.ensureVisible(find.text('选择恢复策略'));
      await tester.tap(find.text('选择恢复策略'));
      await tester.pumpAndSettle();
      expect(find.text('恢复为本地账本'), findsWidgets);
      expect(find.text('恢复为本地副本'), findsWidgets);
      expect(find.text('登录原账号获取最新'), findsOneWidget);

      // Step 4：确认页明示不覆盖
      await tester.ensureVisible(find.text('确认导入结果'));
      await tester.tap(find.text('确认导入结果'));
      await tester.pumpAndSettle();
      expect(find.text('恢复不会覆盖现有账本'), findsOneWidget);

      // Step 4 应用（drift 文件源经后台 isolate，runAsync 中驱动）
      await tester.runAsync(() => notifier.apply());
      await tester.pumpAndSettle();
      expect(find.text('恢复完成'), findsOneWidget);

      // live DB 落库断言：2 本账本、云端 Fork 后 sync_id 恒 NULL
      final ledgers = await liveDb.select(liveDb.ledgers).get();
      expect(ledgers, hasLength(2));
      expect(ledgers.every((l) => l.syncId == null), isTrue);
      expect(ledgers.any((l) => l.originType == 'LOCAL_BACKUP'), isTrue);
      expect(ledgers.any((l) => l.originType == 'CLOUD_BACKUP'), isTrue);
      // 审计日志
      final logs = await liveDb.select(liveDb.recoveryLogs).get();
      expect(logs, hasLength(2));
      expect(
        logs.map((l) => l.action),
        containsAll(['restore_local', 'fork_cloud_to_local']),
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
