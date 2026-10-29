import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_ports.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/providers/app_banner_provider.dart';
import 'package:sesame_notes/shared/widgets/app_banner_entry.dart';

/// 真实横幅组件按实际已显示的图片归因，后台恢复默认通过配置刷新生效。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('多张横幅显示圆点且仅当前张曝光，反复滑动不重复曝光并使用当前详情目标', (tester) async {
    final writer = _Writer();
    final controller = ProductAnalyticsController(
      writer: () async => writer,
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity('a', 1),
        enabled: true,
      ),
    );
    addTearDown(controller.dispose);
    final bytes = (await tester.runAsync(
      () => File('assets/fitness/template-library-banner.png').readAsBytes(),
    ))!;
    const firstId = '11111111-1111-4111-8111-111111111111';
    const secondId = '22222222-2222-4222-8222-222222222222';
    const targetId = '33333333-3333-4333-8333-333333333333';
    (AppBannerTarget, String)? opened;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: SizedBox(
              width: 360,
              child: AppBannerEntry(
                slot: AppBannerSlot.fitnessPlanLibrary,
                onOpen: (_) {},
                onOpenOfficial: (target, id) async => opened = (target, id),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
          productAnalyticsControllerProvider.overrideWithValue(controller),
          appBannersProvider.overrideWith(
            (ref) async => {
              AppBannerSlot.fitnessPlanLibrary: [
                ResolvedAppBanner(
                  id: firstId,
                  bytes: bytes,
                  target: AppBannerTarget.fitnessPlans,
                  version: 1,
                ),
                ResolvedAppBanner(
                  id: secondId,
                  bytes: bytes,
                  target: AppBannerTarget.officialTemplate,
                  targetId: targetId,
                  version: 2,
                ),
              ],
            },
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => precacheImage(
        MemoryImage(bytes),
        tester.element(find.byType(AppBannerEntry)),
      ),
    );
    await tester.pumpAndSettle();
    _visibleAll(tester);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('banner-pagination')), findsOneWidget);
    expect(
      writer.events.where((e) => e.banner != null).map((e) => e.banner!.id),
      [firstId],
    );
    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    _visibleAll(tester);
    await tester.pumpAndSettle();
    expect(
      writer.events
          .where((e) => e.eventName == 'banner_impression')
          .map((e) => e.banner!.id),
      [firstId, secondId],
    );
    await tester.tap(find.byType(PageView));
    await tester.pumpAndSettle();
    expect(opened, (AppBannerTarget.officialTemplate, targetId));
    expect(writer.events.last.banner!.id, secondId);
    for (final offset in [350.0, -350.0]) {
      await tester.drag(find.byType(PageView), Offset(offset, 0));
      await tester.pumpAndSettle();
      _visibleAll(tester);
      await tester.pumpAndSettle();
    }
    expect(
      writer.events.where((e) => e.eventName == 'banner_impression'),
      hasLength(2),
    );
    expect(writer.events.where((e) => e.kind == 'page_view'), hasLength(1));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  for (final corrupt in [true, false]) {
    testWidgets(corrupt ? '远端图片显示失败的曝光点击只归默认素材' : '回前台刷新撤销远端图与目标且不清全局图片缓存', (
      tester,
    ) async {
      final writer = _Writer();
      final controller = ProductAnalyticsController(
        writer: () async => writer,
        runtime: () => const ProductAnalyticsRuntime(
          identity: ProductAnalyticsIdentity('a', 1),
          enabled: true,
        ),
      );
      final gate = AppBannerRefreshGate()..mark(DateTime.now());
      addTearDown(controller.dispose);
      final bytes = corrupt
          ? Uint8List.fromList([1, 2, 3])
          : (await tester.runAsync(
              () => File(
                'assets/fitness/template-library-banner.png',
              ).readAsBytes(),
            ))!;
      var configured = true;
      var loads = 0;
      String? opened;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: SizedBox(
                width: 360,
                child: AppBannerEntry(
                  slot: AppBannerSlot.fitnessPlanLibrary,
                  onOpen: (route) => opened = route,
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiConfigProvider.overrideWithValue(
              const ApiConfig(baseUrl: 'https://banner.example.test'),
            ),
            productAnalyticsControllerProvider.overrideWithValue(controller),
            appBannerRefreshGateProvider.overrideWithValue(gate),
            appBannersProvider.overrideWith((ref) async {
              loads++;
              gate.mark(DateTime.now());
              return configured
                  ? {
                      AppBannerSlot.fitnessPlanLibrary: [
                        ResolvedAppBanner(
                          id: '11111111-1111-4111-8111-111111111111',
                          bytes: bytes,
                          target: AppBannerTarget.fitnessTemplateLibrary,
                          version: 7,
                        ),
                      ],
                    }
                  : {};
            }),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await precacheImage(
          const AssetImage('assets/fitness/plan-library-banner.png'),
          tester.element(find.byType(AppBannerEntry)),
        );
        if (!corrupt) {
          await precacheImage(
            MemoryImage(bytes),
            tester.element(find.byType(AppBannerEntry)),
          );
        }
      });
      await tester.pumpAndSettle();
      _visible(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AppBannerEntry));
      await tester.pumpAndSettle();
      final rows = writer.events.where((e) => e.banner != null).toList();
      expect(find.byKey(const ValueKey('banner-pagination')), findsNothing);
      expect(rows, hasLength(2));
      expect(
        rows.every((e) => e.banner!.source == (corrupt ? 'builtin' : 'remote')),
        isTrue,
      );
      expect(rows.every((e) => e.banner!.version == (corrupt ? 0 : 7)), isTrue);
      expect(
        opened,
        corrupt ? Routes.fitnessPlanLibrary : Routes.fitnessTemplateLibrary,
      );
      if (!corrupt) {
        configured = false;
        gate.mark(DateTime.now().subtract(const Duration(seconds: 31)));
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        _visible(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AppBannerEntry));
        await tester.pumpAndSettle();
        expect(loads, 2);
        expect(opened, Routes.fitnessPlanLibrary);
        expect(writer.events.last.banner!.source, 'builtin');
        expect(writer.events.last.banner!.version, 0);
      }
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}

/// 测试引擎通过显式绘制通知验证真实图片帧之后的归因。
void _visible(WidgetTester tester) {
  final detector = tester.widget<VisibilityDetector>(
    find.byType(VisibilityDetector),
  );
  detector.onVisibilityChanged!(
    VisibilityInfo(
      key: detector.key!,
      size: const Size(360, 120),
      visibleBounds: const Rect.fromLTWH(0, 0, 360, 120),
    ),
  );
}

/// 同时通知预加载页可见，确认只有选中页面具有可采集的素材身份。
void _visibleAll(WidgetTester tester) {
  for (final element in find.byType(VisibilityDetector).evaluate()) {
    final detector = element.widget as VisibilityDetector;
    detector.onVisibilityChanged!(
      VisibilityInfo(
        key: detector.key!,
        size: const Size(360, 120),
        visibleBounds: const Rect.fromLTWH(0, 0, 360, 120),
      ),
    );
  }
}

/// 测试只替换事件出口，组件仍通过正式采集用例触发统计。
class _Writer implements ProductAnalyticsEventWriter {
  final events = <ProductAnalyticsEvent>[];

  /// 保留真实调用时的不可变事件。
  @override
  Future<void> record(ProductAnalyticsEvent event) async => events.add(event);

  /// 测试出口无需网络确认。
  @override
  Future<void> flush() async {}

  /// 测试出口没有在途请求。
  @override
  void identityChanged() {}

  /// 测试出口没有额外资源。
  @override
  void dispose() {}
}
