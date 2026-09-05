/// 备份恢复页 widget 测试（单步流程：打开 → 勾选 → 立即恢复 → 完成态）。
///
/// - 入口传入 .snbak 路径，进入页面直接打开预览（零写入 live DB）；
/// - 内容页按「本地账本 / 云端账本」分区；云端账本账号不符/未登录时落入
///   本地分区并提示「恢复为本地副本」；账号匹配时入云端分区并显示账号昵称；
/// - 账本卡片默认全选，点击切换勾选（未勾选 = 暂不处理）；
/// - 「立即恢复」单事务应用；成功后完成态逐账本列结果；
/// - 文件不存在 → toast 提示并退出；文件损坏 → 错误态。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/features/settings/presentation/restore_backup_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../helpers/test_isolation.dart';

/// 返回固定会话的认证桩。
class _StubAuthNotifier extends AuthSessionNotifier {
  _StubAuthNotifier(this.session);
  final AuthSession? session;
  @override
  AuthSession? build() => session;
}

/// 返回固定账号状态的桩。
class _StubAccountNotifier extends AccountStateNotifier {
  _StubAccountNotifier(this.accountState);
  final AccountState accountState;
  @override
  AccountState build() => accountState;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
  });

  /// 构造真实 .snbak：本地账本 + 当前账号域云端账本（owner 绑定 acc-1）。
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

  /// 驱动 initState 触发的真实文件 IO：交替 runAsync（真实事件循环）与
  /// pump（fake zone 微任务），直到打开/应用等异步链路全部完成。
  Future<void> settleAsync(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
  }

  /// 挂载恢复页（注入 live 库 / 导入服务 / 认证与账号状态桩）。
  ///
  /// [settle] 为 false 时跳过自动 settle（供「文件不存在」等停留在
  /// 加载态的场景手动驱动帧）。
  Future<SesameDatabase> pumpPage(
    WidgetTester tester,
    String backupPath, {
    AuthSession? session,
    AccountState? accountState,
    bool settle = true,
  }) async {
    // 临时目录与解压目录创建含真实文件 IO，须在 runAsync 中驱动
    final tmp = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('restore_page_'),
    ))!;
    addTearDown(() => tmp.delete(recursive: true));
    final liveDb = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(liveDb.close);
    final extractDir = Directory(p.join(tmp.path, 'extract'));
    await tester.runAsync(() => extractDir.create(recursive: true));
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(liveDb),
        authSessionProvider.overrideWith(() => _StubAuthNotifier(session)),
        if (accountState != null)
          accountStateProvider.overrideWith(
            () => _StubAccountNotifier(accountState),
          ),
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(
            importService: BackupImportService(tempDirOverride: extractDir),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RestoreBackupPage(initialBackupPath: backupPath),
        ),
      ),
    );
    if (settle) await settleAsync(tester);
    return liveDb;
  }

  testWidgets(
    '单步流程：直接打开 → 默认全选 → 取消勾选暂不处理 → 立即恢复 → 完成态',
    (tester) async {
      // 备份源构造含真实文件 IO，须在 runAsync 真实事件循环中驱动
      final tmp = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('restore_src_'),
      ))!;
      addTearDown(() => tmp.delete(recursive: true));
      final backup = (await tester.runAsync(() => createFixtureBackup(tmp)))!;
      final liveDb = await pumpPage(tester, backup.path);

      // 进入即打开：双分区标题 + 两个账本卡片（云端账本账号不符 → 本地分区）
      expect(find.text('本地账本'), findsOneWidget);
      expect(find.text('云端账本'), findsOneWidget);
      expect(find.text('私人账本'), findsOneWidget);
      expect(find.text('家庭账本'), findsOneWidget);
      expect(
        find.text('这是云账本，但不是当前账号，将恢复为本地副本'),
        findsOneWidget,
        reason: '未登录时云端账本落入本地分区并提示恢复为本地副本',
      );
      // 账本卡片展示账本管理同款字段：币种 / 笔数 / 支出
      expect(find.textContaining('币种：'), findsNWidgets(2));
      expect(find.textContaining('笔数：'), findsNWidgets(2));
      expect(find.textContaining('支出：'), findsNWidgets(2));
      // 成员数仅云端账本展示（本地账本无成员）
      expect(find.textContaining('位成员'), findsOneWidget);
      // 默认全选：两张卡片右上角均贴勾选角标
      expect(find.byIcon(AppIcons.check), findsNWidgets(2));
      // 本地分区排序：真本地账本在前，转本地的云端副本账本在后
      expect(
        tester.getTopLeft(find.text('私人账本')).dy,
        lessThan(tester.getTopLeft(find.text('家庭账本')).dy),
        reason: '本地账本应排在云端副本账本前面',
      );

      // 打开/勾选阶段 live DB 零写入
      expect(await liveDb.select(liveDb.ledgers).get(), isEmpty);

      // 取消勾选本地账本 → 暂不处理（角标只剩一个）
      await tester.tap(find.text('私人账本'));
      await tester.pumpAndSettle();
      expect(find.byIcon(AppIcons.check), findsOneWidget);

      // 立即恢复（应用真实文件 IO 在 runAsync 窗口中驱动）
      await tester.ensureVisible(find.text('立即恢复'));
      await tester.tap(find.text('立即恢复'));
      await settleAsync(tester);

      // 完成态（AppBar 与正文均显示「恢复完成」）
      expect(find.text('恢复完成'), findsWidgets);
      expect(find.text('家庭账本'), findsOneWidget);

      // live DB 落库断言：仅云端账本 Fork 恢复（本地账本被跳过）
      final ledgers = await liveDb.select(liveDb.ledgers).get();
      expect(ledgers, hasLength(1));
      expect(ledgers.single.syncId, isNull);
      expect(ledgers.single.originType, 'CLOUD_BACKUP');
      // 审计日志逐账本记录（skip 也留痕）：1 条 fork + 1 条 skip
      final logs = await liveDb.select(liveDb.recoveryLogs).get();
      expect(logs, hasLength(2));
      expect(
        logs.map((l) => l.action),
        containsAll(['fork_cloud_to_local', 'skip']),
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets('登录账号匹配：云端账本入云端分区并展示账号昵称', (tester) async {
    final tmp = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('restore_src_auth_'),
    ))!;
    addTearDown(() => tmp.delete(recursive: true));
    final backup = (await tester.runAsync(() => createFixtureBackup(tmp)))!;
    await pumpPage(
      tester,
      backup.path,
      session: const AuthSession(
        accessToken: 't',
        userId: 'acc-1',
        deviceId: 'd',
      ),
      accountState: const AccountState(
        status: AccountStatus.authenticated,
        profile: CloudProfile(userId: 'acc-1', displayName: '昵称Alice'),
      ),
    );

    expect(find.text('本地账本'), findsOneWidget);
    expect(find.text('云端账本'), findsOneWidget);
    expect(find.text('昵称Alice'), findsOneWidget, reason: '云端账本展示账号昵称副标题');
    // 昵称在账本名称行内右对齐
    expect(
      tester.widget<Text>(find.text('昵称Alice')).textAlign,
      TextAlign.right,
    );
    expect(
      find.text('这是云账本，但不是当前账号，将恢复为本地副本'),
      findsNothing,
      reason: '账号匹配的云端账本不再提示转本地副本',
    );
    // 默认全选：两张卡片右上角均贴勾选角标
    expect(find.byIcon(AppIcons.check), findsNWidgets(2));
  });

  testWidgets('备份文件不存在：toast 提示', (tester) async {
    await pumpPage(
      tester,
      p.join(Directory.systemTemp.path, 'definitely_missing.snbak'),
      settle: false,
    );
    // 驱动 exists() 真实 IO 完成，再渲染 toast
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.text('备份文件不存在'), findsOneWidget);
    // 等待 toast 自动消失，避免遗留挂起定时器
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('备份文件损坏：错误态展示可读文案', (tester) async {
    final tmp = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('restore_bad_'),
    ))!;
    addTearDown(() => tmp.delete(recursive: true));
    final bad = File(p.join(tmp.path, 'bad.snbak'));
    await tester.runAsync(() => bad.writeAsBytes([1, 2, 3]));
    await pumpPage(tester, bad.path);

    expect(find.text('无法打开备份：文件已损坏或不是备份文件'), findsOneWidget);
    expect(find.text('返回'), findsOneWidget);
  });
}
