/// Mine 页入口测试。
///
/// 官方账号登录/登出只由页面头部与个人资料页承载；功能列表中的云入口
/// （备份与云同步）只用于备份配置，不根据官方账号会话改变文案或行为。
///
/// 测试栈：flutter_test + flutter_riverpod。Mine 页无官方同步 provider，
/// 云入口状态来自第三方备份总览（CloudBackupOverview），测试注入内存数据库
/// 与空 SharedPreferences；MinePageHeader 的异步头像加载在测试环境下读取不到
/// 文件即返回 null，不会抛错。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/presentation/language_settings_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/features/ledgers/presentation/mine_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';

import '../../helpers/cloud_backend_registration.dart';

/// 挂载 MinePage（使用加高视口，确保列表末尾的分组入口也被构建出来）。
///
/// 返回注入的 [ProviderContainer]，供测试断言 provider 状态。
Future<ProviderContainer> _pumpMinePage(WidgetTester tester) async {
  // 默认 800x600 视口下第二组入口可能落在首屏外（ListView 懒构建），
  // 加高视口让全部入口 tile 都被构建，断言才能稳定命中。
  tester.view.physicalSize = const Size(800, 12000);
  addTearDown(tester.view.resetPhysicalSize);
  final db = SesameDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  final container = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        // 测试环境默认 locale 为 en，强制 zh 以渲染中文文案
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // 命名路由由 go_router 统一解析（mine 页跳转已按路由名）。
        routerConfig: createAppRouter(home: () => const MinePage()),
      ),
    ),
  );
  // 使用有界 pump：MinePageHeader 的头像加载期间存在无限动画，
  // pumpAndSettle 会因此超时；第一帧构建后，后续帧让异步 provider 与
  // 头像加载的 setState 完成解析即可，断言不依赖 spinner 是否消失。
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  return container;
}

/// 取 [text] 所在 tile 的纵向坐标，用于断言分组内顺序。
double _yOf(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

/// 注册 Mine 页的组件行为测试。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 云服务页的第三方备份入口来自注册表，等价于 main.dart 的装配。
  void Function()? unregisterBackends;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    unregisterBackends = registerRealCloudBackends();
  });
  tearDown(() => unregisterBackends?.call());

  testWidgets('记账设置分组展示分类管理、汇率管理与周期账单', (tester) async {
    await _pumpMinePage(tester);

    expect(find.text('分类管理'), findsOneWidget);
    expect(find.text('汇率管理'), findsOneWidget);
    expect(find.text('周期账单'), findsOneWidget);
    // 换色功能已移除，页面不再出现该入口。
    expect(find.text('支出颜色'), findsNothing);
  });

  testWidgets('通用设置分组按序展示且不再包含偏好调节', (tester) async {
    await _pumpMinePage(tester);

    expect(find.text('偏好调节'), findsNothing);
    expect(find.text('应用语言'), findsOneWidget);
    expect(find.text('深色模式'), findsOneWidget);
    expect(find.text('通知设置'), findsOneWidget);
    expect(find.text('应用上锁'), findsOneWidget);
    expect(find.text('数据导入导出'), findsOneWidget);
    expect(find.text('配置导入导出'), findsOneWidget);
    expect(find.text('备份与云同步'), findsOneWidget);
    expect(find.text('数据清理'), findsNothing);

    // 分组内顺序：应用语言 → 深色模式 → 通知设置 → 应用上锁 →
    // 数据导入导出 → 配置导入导出 → 备份与云同步。
    expect(_yOf(tester, '深色模式'), greaterThan(_yOf(tester, '应用语言')));
    expect(_yOf(tester, '通知设置'), greaterThan(_yOf(tester, '深色模式')));
    expect(_yOf(tester, '应用上锁'), greaterThan(_yOf(tester, '通知设置')));
    expect(_yOf(tester, '数据导入导出'), greaterThan(_yOf(tester, '应用上锁')));
    expect(_yOf(tester, '配置导入导出'), greaterThan(_yOf(tester, '数据导入导出')));
    expect(_yOf(tester, '备份与云同步'), greaterThan(_yOf(tester, '配置导入导出')));
  });

  testWidgets('深色模式弹窗切换到暗黑', (tester) async {
    final container = await _pumpMinePage(tester);

    expect(container.read(themeModeProvider), ThemeMode.system);
    await tester.tap(find.text('深色模式'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('暗黑模式'));
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('点击应用语言导航到语言设置页', (tester) async {
    await _pumpMinePage(tester);

    await tester.tap(find.text('应用语言'));
    await tester.pumpAndSettle();
    expect(find.byType(LanguageSettingsPage), findsOneWidget);
  });

  testWidgets('展示应用内更新入口且独立成组位于末尾，点击弹三态弹窗（unknown 降级）', (tester) async {
    // mock package_info 平台实现（测试环境无通道）；HTTP 在 flutter_test
    // 默认返回 400 → check 降级 unknown → 弹窗展示「无法自动检查更新」。
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (call) async => {
            'appName': 'sesame_notes',
            'packageName': 'com.sesame.notes',
            'version': '1.0.0',
            'buildNumber': '1',
            'buildSignature': '',
          },
        );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            null,
          );
    });

    await _pumpMinePage(tester);

    expect(find.text('检查更新'), findsOneWidget, reason: 'P2 恢复应用内更新入口');
    // 检查更新单独成组并放在页面最后（位于通用设置的应用上锁之下）。
    final lockY = _yOf(tester, '应用上锁');
    final updateY = _yOf(tester, '检查更新');
    expect(updateY, greaterThan(lockY));

    await tester.tap(find.text('检查更新'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 测试环境无网络 → unknown 态弹窗：文案 + 「前往发布页」兜底按钮。
    expect(find.text('无法自动检查更新'), findsOneWidget);
    expect(find.text('前往发布页'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('我的页不展示任何副标题文案', (tester) async {
    await _pumpMinePage(tester);

    // 各入口曾经的副标题与云入口状态副标题均不再出现在我的页。
    expect(find.text('编辑自定义分类'), findsNothing);
    expect(find.text('管理周期性账单'), findsNothing);
    expect(find.text('设置每日记账提醒'), findsNothing);
    expect(find.text('主题、字体、语言、应用锁等'), findsNothing);
    expect(find.text('自动获取汇率，支持手动修正'), findsNothing);
    expect(find.text('支出明细csv格式文件'), findsNothing);
    expect(find.text('备份和恢复应用配置'), findsNothing);
    expect(find.text('检测 GitHub 发布页是否有新版本'), findsNothing);
    expect(find.text('仅本地备份'), findsNothing);
  });
}
