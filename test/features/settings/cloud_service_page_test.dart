/// 云服务页（备份与云同步配置）测试。
///
/// 需求锚点：
/// - 页面不展示官方账号登录、同步或退出入口（官方云端协同不在本页管理）；
/// - 三段式布局：离线模式（本地存储卡片）+ 备份同步（注册表后端卡片）；
/// - 激活的后端卡片正下方嵌入备份同步操作区块（上传/从云端恢复/自动同步开关/状态）；
/// - 未配置后端点击打开配置弹窗，保存后可「立即切换」激活；
/// - 本地存储卡片的配置入口进入本机备份页。
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

  /// 挂载云服务页，并注入独立的内存数据库。
  Future<void> pumpPage(WidgetTester tester, SesameDatabase db) async {
    tester.view.physicalSize = const Size(800, 2400);
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
          // 本机备份页重依赖（path_provider 等）用桩替换，验证路由可达性。
          routerConfig: createAppRouter(
            home: () => const CloudServicePage(),
            stubs: {
              '/backup/local': (_) => const Scaffold(
                body: Center(child: Text('LOCAL_BACKUP_STUB')),
              ),
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('三段式布局：离线模式 + 备份同步分组，不展示官方账号同步模块', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    expect(find.text('备份与云同步配置'), findsOneWidget);
    expect(find.text('离线模式'), findsOneWidget);
    expect(find.text('备份同步'), findsOneWidget);
    // 本地存储卡片 + 三个后端卡片。
    expect(find.text('本地存储'), findsWidgets);
    expect(find.text('自定义 WebDAV'), findsOneWidget);
    expect(find.text('自定义 Supabase'), findsOneWidget);
    expect(find.text('S3 协议存储'), findsOneWidget);
    // 官方云端协同不在本页管理。
    expect(find.text('已登录'), findsNothing);
    expect(find.text('点击可退出登录'), findsNothing);
    expect(find.text('仅在同步时需要'), findsNothing);
  });

  testWidgets('本地存储卡片的配置入口进入本机备份页', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    await tester.tap(find.text('配置').first);
    await tester.pumpAndSettle();
    expect(find.text('LOCAL_BACKUP_STUB'), findsOneWidget);
  });

  testWidgets('激活后端后卡片下方嵌入备份同步操作区块', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final store = CloudServiceStore();
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

    // 备份同步操作区块只挂在激活的 WebDAV 卡片下。
    expect(find.text('备份状态'), findsOneWidget);
    expect(find.text('立即上传到云端'), findsOneWidget);
    expect(find.text('从云端恢复'), findsOneWidget);
    expect(find.text('自动备份到云端'), findsOneWidget);
    expect(find.text('当前使用 · 上次成功 2026-09-01 08:30'), findsOneWidget);
    // WebDAV 用配置内凭据，无登录行。
    expect(find.text('登录'), findsNothing);
  });

  testWidgets('未配置后端点击打开配置弹窗，保存后立即切换即激活', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await pumpPage(tester, db);

    // 点击未配置的 WebDAV 卡片 → 打开配置弹窗。
    await tester.tap(find.text('自定义 WebDAV'));
    await tester.pumpAndSettle();
    expect(find.text('配置 WebDAV'), findsOneWidget);

    // 必填内联校验：直接保存提示必填。
    await tester.tap(find.text('保存').last);
    await tester.pump();
    expect(find.text('请填写完整信息'), findsWidgets);

    // 填写必填字段并保存。
    await tester.enterText(
      find.widgetWithText(TextField, '服务地址'),
      'https://dav.example.com',
    );
    await tester.enterText(find.widgetWithText(TextField, '用户名'), 'user');
    await tester.enterText(find.widgetWithText(TextField, '密码'), 'secret');
    await tester.tap(find.text('保存').last);
    await tester.pumpAndSettle();

    // 保存成功后引导「立即切换」；确认后直接激活（不二次确认）。
    expect(find.text('配置已保存'), findsOneWidget);
    await tester.tap(find.text('立即切换'));
    await tester.pumpAndSettle();

    // 激活后卡片下方出现操作区块，且激活 toast 展示。
    expect(find.text('备份状态'), findsOneWidget);
    expect(find.text('已切换到WebDAV'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('激活状态下点击本地存储卡片切回本地', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final store = CloudServiceStore();
    await store.saveAndActivate(
      const CloudServiceConfig(
        backendId: 's3',
        settings: {
          'endpoint': 'minio.example.com',
          'region': 'us-east-1',
          'accessKey': 'ak',
          'secretKey': 'sk',
          'bucket': 'sesame-backups',
        },
      ),
    );

    await pumpPage(tester, db);

    // 点击本地存储卡片 → 确认 → 切回本地。
    await tester.tap(find.text('本地存储').first);
    await tester.pumpAndSettle();
    expect(find.text('切换云服务'), findsOneWidget);
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('已切换到本地存储'), findsOneWidget);
    expect(find.text('备份状态'), findsNothing, reason: '本地模式不显示操作区块');
    await tester.pump(const Duration(seconds: 2));
  });
}
