import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_event.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_ports.dart';
import 'package:sesame_notes/domain/analytics/product_banner_dimensions.dart';
import 'package:sesame_notes/infrastructure/analytics/product_analytics_service.dart';
import 'package:sesame_notes/shared/application/product_analytics_controller.dart';
import 'package:sesame_notes/shared/presentation/analytics/product_analytics_banner_observer.dart';
import 'package:sesame_notes/shared/providers/app_banner_provider.dart';

const _builtin = ProductBannerDimensions(
  slot: 'fitness-plan-library',
  source: 'builtin',
  id: 'builtin:fitness-plan-library',
  version: 0,
);
const _remote = ProductBannerDimensions(
  slot: 'fitness-plan-library',
  source: 'remote',
  id: '11111111-1111-4111-8111-111111111111',
  version: 7,
);

/// 横幅采集复用现有身份、访问、离线队列边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  test('同次访问同素材只曝光一次，前台恢复不重复，离开返回是新访问', () async {
    final writer = _Writer();
    var enabled = true;
    final controller = ProductAnalyticsController(
      writer: () async => writer,
      runtime: () => ProductAnalyticsRuntime(
        identity: const ProductAnalyticsIdentity('a', 1),
        enabled: enabled,
      ),
    );
    addTearDown(controller.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'plan-1');
    for (var n = 0; n < 4; n++) {
      controller.trackBanner(
        pageId: 'fitness.plans',
        action: ProductAction.bannerImpression,
        banner: _builtin,
      );
    }
    enabled = false;
    controller.observePage(pageId: 'fitness.plans', visitKey: 'plan-1');
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerClick,
      banner: _builtin,
    );
    enabled = true;
    controller.observePage(pageId: 'fitness.plans', visitKey: 'plan-1');
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _builtin,
    );
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _remote,
    );
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerClick,
      banner: _remote,
    );
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerClick,
      banner: _remote,
    );
    controller.observePage(pageId: 'fitness.templates', visitKey: 'template-1');
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerClick,
      banner: _remote,
    );
    controller.observePage(pageId: 'fitness.plans', visitKey: 'plan-1');
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _builtin,
    );
    await Future<void>.delayed(Duration.zero);
    final impressions = writer.events
        .where((e) => e.action == ProductAction.bannerImpression)
        .toList();
    expect(impressions.map((e) => e.banner!.source), [
      'builtin',
      'remote',
      'builtin',
    ]);
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerClick),
      hasLength(2),
    );
    expect(
      writer.events.map((e) => e.sequence).toList(),
      orderedEquals(List.generate(writer.events.length, (n) => n + 1)),
    );
    expect(writer.events.map((e) => e.sessionId).toSet(), hasLength(1));
  });

  test('匿名、身份变化与非宿主页面不采集，登录新访问可正常曝光', () async {
    final writer = _Writer();
    var identity = const ProductAnalyticsIdentity(null, 0);
    final controller = ProductAnalyticsController(
      writer: () async => writer,
      runtime: () => ProductAnalyticsRuntime(identity: identity, enabled: true),
    );
    addTearDown(controller.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _builtin,
    );
    identity = const ProductAnalyticsIdentity('a', 1);
    controller.identityChanged();
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _builtin,
    );
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    controller.trackBanner(
      pageId: 'fitness.templates',
      action: ProductAction.bannerClick,
      banner: _builtin,
    );
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _builtin,
    );
    await Future<void>.delayed(Duration.zero);
    expect(writer.events.where((e) => e.banner != null), hasLength(1));
    expect(writer.events.every((e) => e.identity.account == 'a'), isTrue);
  });

  test('断网重试保留横幅维度、事件UUID和顺序，跨服务器不补报', () async {
    final prefs = await SharedPreferences.getInstance();
    var now = DateTime.utc(2026, 10, 29);
    var fail = true;
    final batches = <Object>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://server-a.example.test'))
      ..httpClientAdapter = _Adapter((request) {
        final events = (request.data as Map)['events'] as List;
        batches.add(jsonDecode(jsonEncode(events)));
        return ResponseBody.fromString(
          jsonEncode(fail ? {} : {'accepted': events.length, 'duplicates': 0}),
          fail ? 503 : 200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
    final service = ProductAnalyticsService(
      dio: dio,
      preferences: prefs,
      accountId: () => 'a',
      accessToken: () => 'token',
      identityGeneration: () => 1,
      clock: () => now,
    );
    addTearDown(service.dispose);
    final controller = ProductAnalyticsController(
      writer: () async => service,
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity('a', 1),
        enabled: true,
      ),
      clock: () => now,
    );
    addTearDown(controller.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    await Future<void>.delayed(Duration.zero);
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerImpression,
      banner: _remote,
    );
    controller.trackBanner(
      pageId: 'fitness.plans',
      action: ProductAction.bannerClick,
      banner: _remote,
    );
    await Future<void>.delayed(Duration.zero);
    await service.flush();
    final pending =
        (jsonDecode(
              prefs.getString(
                prefs.getKeys().singleWhere(
                  (key) => key.startsWith('product_analytics'),
                ),
              )!,
            )
            as List);
    final bannerRows = pending
        .where((row) => row['banner_slot'] != null)
        .toList();
    expect(bannerRows, hasLength(2));
    expect(bannerRows.map((row) => row['banner_version']), [7, 7]);
    expect(
      bannerRows.every(
        (row) => !row.containsKey('url') && !row.containsKey('title'),
      ),
      isTrue,
    );
    dio.options.baseUrl = 'https://server-b.example.test';
    now = now.add(const Duration(seconds: 31));
    final count = batches.length;
    await service.flush();
    expect(batches, hasLength(count));
    dio.options.baseUrl = 'https://server-a.example.test';
    fail = false;
    await service.flush();
    expect(batches.last, pending);
    expect(
      prefs.getKeys().where((key) => key.startsWith('product_analytics')),
      isEmpty,
    );
  });

  test('规范拒绝缺字段、默认版本错误、错误页面及非横幅事件夹带字段', () {
    expect(
      ProductBannerDimensions.validEvent(
        'banner_impression',
        'fitness.plans',
        _remote.toJson(),
      ),
      isTrue,
    );
    expect(
      ProductBannerDimensions.validEvent('banner_click', 'fitness.plans', {}),
      isFalse,
    );
    expect(
      ProductBannerDimensions.validEvent('banner_click', 'fitness.plans', {
        'banner_slot': 'fitness-plan-library',
      }),
      isFalse,
    );
    expect(
      ProductBannerDimensions.validEvent('banner_click', 'fitness.plans', {
        ..._builtin.toJson(),
        'banner_version': 1,
      }),
      isFalse,
    );
    expect(
      ProductBannerDimensions.validEvent(
        'banner_click',
        'fitness.templates',
        _remote.toJson(),
      ),
      isFalse,
    );
    expect(
      ProductBannerDimensions.validEvent(
        'fitness_plans_view',
        'fitness.plans',
        _remote.toJson(),
      ),
      isFalse,
    );
  });

  test('刷新请求按三十秒节流，使用新实例不会继承另一服务器状态', () {
    final gate = AppBannerRefreshGate();
    final now = DateTime.utc(2026, 10, 29);
    expect(gate.claim(now), isTrue);
    expect(gate.claim(now.add(const Duration(seconds: 29))), isFalse);
    expect(gate.claim(now.add(const Duration(seconds: 30))), isTrue);
    expect(AppBannerRefreshGate().claim(now), isTrue);
  });

  testWidgets('未显示图片或不足半张不曝光，真实点击不等待统计', (tester) async {
    final writer = _Writer();
    final controller = ProductAnalyticsController(
      writer: () async => writer,
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity('a', 1),
        enabled: true,
      ),
    );
    addTearDown(controller.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    var tapped = 0;
    final ready = ValueNotifier<ProductBannerDimensions?>(null);
    addTearDown(ready.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: ready,
            builder: (context, banner, child) => SizedBox(
              width: 300,
              height: 100,
              child: ProductAnalyticsBannerObserver(
                controller: controller,
                banner: banner,
                onTap: () => tapped++,
                builder: (tap) => GestureDetector(
                  onTap: tap,
                  child: const ColoredBox(color: Colors.blue),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    _visibility(tester, .4);
    ready.value = _builtin;
    await tester.pumpAndSettle();
    expect(writer.events.where((e) => e.banner != null), isEmpty);
    await tester.tap(find.byType(ProductAnalyticsBannerObserver));
    await tester.pumpAndSettle();
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerClick),
      hasLength(1),
    );
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerImpression),
      isEmpty,
    );
    _visibility(tester, .6);
    await tester.pumpAndSettle();
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerImpression),
      hasLength(1),
    );
    await tester.tap(find.byType(ProductAnalyticsBannerObserver));
    expect(tapped, 2);
    await tester.pumpAndSettle();
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerClick),
      hasLength(2),
    );
    ready.value = const ProductBannerDimensions(
      slot: 'fitness-plan-library',
      source: 'builtin',
      id: 'builtin:fitness-plan-library',
      version: 0,
    );
    await tester.pumpAndSettle();
    expect(
      writer.events.where((e) => e.action == ProductAction.bannerImpression),
      hasLength(1),
    );
  });

  testWidgets('弹层遮挡时新素材不曝光，关闭后可见再采集', (tester) async {
    final writer = _Writer();
    final controller = ProductAnalyticsController(
      writer: () async => writer,
      runtime: () => const ProductAnalyticsRuntime(
        identity: ProductAnalyticsIdentity('a', 1),
        enabled: true,
      ),
    );
    addTearDown(controller.dispose);
    controller.observePage(pageId: 'fitness.plans', visitKey: 'p');
    final source = ValueNotifier(_builtin);
    addTearDown(source.dispose);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        home: Scaffold(
          body: ValueListenableBuilder(
            valueListenable: source,
            builder: (context, banner, child) => SizedBox(
              width: 300,
              height: 100,
              child: ProductAnalyticsBannerObserver(
                controller: controller,
                banner: banner,
                onTap: () {},
                builder: (_) => const ColoredBox(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );
    _visibility(tester, 1);
    await tester.pumpAndSettle();
    unawaited(
      showDialog<void>(
        context: tester.element(find.byType(ProductAnalyticsBannerObserver)),
        builder: (_) => const AlertDialog(content: Text('遮挡')),
      ),
    );
    await tester.pumpAndSettle();
    source.value = _remote;
    _visibility(tester, 1);
    await tester.pumpAndSettle();
    expect(writer.events.where((e) => e.banner?.source == 'remote'), isEmpty);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(
      writer.events.where((e) => e.banner?.source == 'remote'),
      hasLength(1),
    );
  });
}

/// Widget测试显式注入绘制可见面积，避免依赖测试引擎的合成层回调时机。
void _visibility(WidgetTester tester, double fraction) {
  final detector = tester.widget<VisibilityDetector>(
    find.byType(VisibilityDetector),
  );
  detector.onVisibilityChanged!(
    VisibilityInfo(
      key: detector.key!,
      size: const Size(300, 100),
      visibleBounds: Rect.fromLTWH(0, 0, 300 * fraction, 100),
    ),
  );
}

/// 内存写入出口保留调用时事件，不建立网络或账号依赖。
class _Writer implements ProductAnalyticsEventWriter {
  final events = <ProductAnalyticsEvent>[];

  /// 保留采集时的身份、时间与事件顺序。
  @override
  Future<void> record(ProductAnalyticsEvent event) async => events.add(event);

  /// 内存测试出口无需网络确认。
  @override
  Future<void> flush() async {}

  /// 测试出口没有在途网络请求。
  @override
  void identityChanged() {}

  /// 测试出口没有额外资源。
  @override
  void dispose() {}
}

/// 队列重试测试的本地响应适配器。
class _Adapter implements HttpClientAdapter {
  /// 注入本次测试使用的响应函数。
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  /// 根据测试请求返回固定协议响应。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? stream,
    Future<void>? cancel,
  ) async => respond(options);

  /// 适配器没有真实连接需要释放。
  @override
  void close({bool force = false}) {}
}
