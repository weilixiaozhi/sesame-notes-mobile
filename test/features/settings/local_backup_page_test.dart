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
