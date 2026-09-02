// 第三方云备份页测试。
//
// 需求锚点：
// - 页面不展示官方账号登录、同步或退出入口；
// - 每个后端展示未配置、已配置未启用、当前使用三态；
// - 当前后端展示最近一次成功备份时间，没有成功记录时明确提示。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_service_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/cloud_backend_registration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void Function()? unregisterBackends;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    unregisterBackends = registerRealCloudBackends();
  });
  tearDown(() => unregisterBackends?.call());

  /// 挂载第三方云备份页，并注入独立的内存数据库。
  Future<void> pumpPage(WidgetTester tester, SesameDatabase db) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: createAppRouter(home: () => const CloudServicePage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('页面只展示第三方备份，不展示官方账号同步模块', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    expect(find.text('第三方云备份'), findsOneWidget);
    expect(find.text('Supabase'), findsOneWidget);
    expect(find.text('WebDAV'), findsOneWidget);
    expect(find.text('S3'), findsOneWidget);
    expect(find.text('已登录'), findsNothing);
    expect(find.text('点击可退出登录'), findsNothing);
    expect(find.text('仅在同步时需要'), findsNothing);
  });

  testWidgets('展示未配置、已配置未启用和当前服务最近成功时间', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final store = CloudServiceStore();
    await store.saveOnly(
      const CloudServiceConfig(
        backendId: 'supabase',
        settings: {'url': 'https://example.supabase.co', 'anonKey': 'key'},
      ),
    );
    await store.saveAndActivate(
      const CloudServiceConfig(
        backendId: 'webdav',
        settings: {
          'url': 'https://dav.example.com',
          'username': 'user',
          'password': 'secret',
        },
      ),
    );
    await db
        .into(db.backupState)
        .insert(
          BackupStateCompanion.insert(
            id: const d.Value(0),
            lastSuccessAt: d.Value(DateTime(2026, 9, 1, 8, 30)),
            currentProvider: const d.Value('webdav'),
          ),
        );

    await pumpPage(tester, db);

    expect(find.text('已配置，当前未使用'), findsOneWidget);
    expect(find.text('当前使用 · 上次成功 2026-09-01 08:30'), findsOneWidget);
    expect(find.text('未配置'), findsOneWidget);
  });

  testWidgets('保存配置后立即显示为当前使用且尚无成功备份', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await pumpPage(tester, db);

    await tester.tap(find.text('Supabase'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'https://example.supabase.co',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'anon-key');
    await tester.tap(find.text('保存配置'));
    await tester.pumpAndSettle();

    expect(find.text('当前使用 · 尚无成功备份'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
