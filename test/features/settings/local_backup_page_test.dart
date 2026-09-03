/// 本机备份页（LocalBackupPage）测试。
///
/// 需求锚点：
/// - 自动本地备份开关（默认开，写 SharedPreferences）；
/// - 快照列表点击进入 4 步恢复页（本测试用路由桩验证可达性）；
/// - 空态展示「暂无备份」与「导入文件恢复」兜底入口。
///
/// 列表数据用桩服务注入（真实文件枚举由 local_backup_service_test 覆盖），
/// 页面测试只验证交互与路由。
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/features/settings/presentation/local_backup_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 列表桩服务：返回固定快照，无文件 IO。
class _StubBackupService extends LocalBackupService {
  final List<LocalBackupFile> stubBackups;

  _StubBackupService({this.stubBackups = const []});

  @override
  Future<List<LocalBackupFile>> listBackups() async => stubBackups;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// 挂载本机备份页（注入内存数据库与列表桩服务）。
  Future<void> pumpPage(
    WidgetTester tester,
    SesameDatabase db, {
    List<LocalBackupFile> backups = const [],
  }) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        localBackupServiceProvider.overrideWithValue(
          _StubBackupService(stubBackups: backups),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // 恢复页重依赖，用桩替换验证路由可达性。
          routerConfig: createAppRouter(
            home: () => const LocalBackupPage(),
            stubs: {
              '/backup/restore': (_) =>
                  const Scaffold(body: Center(child: Text('RESTORE_STUB'))),
            },
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('渲染自动备份开关、空态与导入文件恢复入口', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    expect(find.text('本地存储'), findsOneWidget);
    expect(find.text('自动本地备份'), findsOneWidget);
    expect(find.text('暂无备份'), findsOneWidget);
    expect(find.text('导入文件恢复'), findsOneWidget);
  });

  testWidgets('切换自动备份开关写入 SharedPreferences', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(LocalBackupService.prefsKeyAutoBackup),
      isFalse,
      reason: '关闭开关应持久化 false',
    );
  });

  testWidgets('备份密码未设置时可设置并展示恢复词', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    await tester.tap(find.text('备份密码'));
    await tester.pumpAndSettle();
    // 设置弹层：新密码 + 确认密码。
    await tester.enterText(
      find.widgetWithText(TextField, '新密码'),
      'pw-12345678',
    );
    await tester.enterText(
      find.widgetWithText(TextField, '确认新密码'),
      'pw-12345678',
    );
    await tester.tap(find.text('确定').last);
    // 密码哈希（Argon2id）是真实异步，runAsync 驱动完成。
    await tester.runAsync(() async {
      await Future.delayed(const Duration(seconds: 2));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 恢复词一次性展示弹窗。
    expect(find.text('请妥善保存恢复词'), findsOneWidget);
    await tester.tap(find.text('确定').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('备份密码已设置'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('backup_password_verifier'),
      isNotNull,
      reason: '密码校验哈希已落库',
    );
    // 让 toast 自动消失的定时器走完，避免测试结束时有 pending timer。
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('快照列表展示文件名与大小，点击进入恢复页（路由桩）', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final stubFile = File('sesame_notes_20260801_120000.snbak');

    await pumpPage(
      tester,
      db,
      backups: [
        LocalBackupFile(
          file: stubFile,
          createdAt: DateTime(2026, 8, 1, 12, 0),
          sizeBytes: 3072,
        ),
      ],
    );

    expect(find.text('sesame_notes_20260801_120000.snbak'), findsOneWidget);
    expect(find.text('3.0 KB'), findsOneWidget);

    await tester.tap(find.text('sesame_notes_20260801_120000.snbak'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('RESTORE_STUB'), findsOneWidget);
  });
}
