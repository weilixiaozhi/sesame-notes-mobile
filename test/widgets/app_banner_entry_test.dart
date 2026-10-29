import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/app_banner_provider.dart';
import 'package:sesame_notes/shared/widgets/app_banner_entry.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 横幅渲染与导航验证，默认资源始终随应用可用。
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// 构建完整本地化和主题环境，入口宽度与手机页面一致。
  Widget page({
    required AppBannerSlot slot,
    required ValueChanged<String> onOpen,
    Future<Map<AppBannerSlot, ResolvedAppBanner>> Function()? load,
    Locale locale = const Locale('zh'),
  }) => ProviderScope(
    overrides: [
      apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
      if (load != null) appBannersProvider.overrideWith((ref) => load()),
    ],
    child: MaterialApp(
      locale: locale,
      theme: AppTheme.lightTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: AppBannerEntry(slot: slot, onOpen: onOpen),
          ),
        ),
      ),
    ),
  );

  testWidgets('无服务器时两张本地图片可见且各自进入对应库', (tester) async {
    for (final (slot, route) in [
      (AppBannerSlot.fitnessPlanLibrary, Routes.fitnessPlanLibrary),
      (AppBannerSlot.fitnessTemplateLibrary, Routes.fitnessTemplateLibrary),
    ]) {
      String? opened;
      await tester.pumpWidget(
        page(slot: slot, onOpen: (value) => opened = value),
      );
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as AssetImage).assetName, slot.assetPath);
      expect(tester.getSize(find.byType(AppBannerEntry)), const Size(360, 120));
      await tester.tap(find.byType(AppBannerEntry));
      expect(opened, route);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('远端加载悬挂时不阻塞本地图片与默认入口', (tester) async {
    final pending = Completer<Map<AppBannerSlot, ResolvedAppBanner>>();
    String? opened;
    await tester.pumpWidget(
      page(
        slot: AppBannerSlot.fitnessPlanLibrary,
        onOpen: (value) => opened = value,
        load: () => pending.future,
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(AppBannerEntry));
    expect(opened, Routes.fitnessPlanLibrary);
    expect(tester.widget<Image>(find.byType(Image)).image, isA<AssetImage>());
    pending.complete({});
    await tester.pumpAndSettle();
  });

  testWidgets('远端图片完整显示后使用配置目标和本地化读屏名称', (tester) async {
    final semantics = tester.ensureSemantics();
    final bytes = (await tester.runAsync(
      () => File('assets/fitness/template-library-banner.png').readAsBytes(),
    ))!;
    String? opened;
    await tester.pumpWidget(
      page(
        slot: AppBannerSlot.fitnessPlanLibrary,
        onOpen: (value) => opened = value,
        locale: const Locale('en'),
        load: () async => {
          AppBannerSlot.fitnessPlanLibrary: ResolvedAppBanner(
            bytes: bytes,
            target: AppBannerTarget.fitnessTemplateLibrary,
          ),
        },
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBannerEntry));
    expect(opened, Routes.fitnessTemplateLibrary);
    expect(find.bySemanticsLabel('Template library'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('显示阶段解码失败时图片和点击目标一起恢复默认', (tester) async {
    String? opened;
    await tester.pumpWidget(
      page(
        slot: AppBannerSlot.fitnessPlanLibrary,
        onOpen: (value) => opened = value,
        load: () async => {
          AppBannerSlot.fitnessPlanLibrary: ResolvedAppBanner(
            bytes: Uint8List.fromList([1, 2, 3]),
            target: AppBannerTarget.fitnessTemplates,
          ),
        },
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBannerEntry));
    expect(opened, Routes.fitnessPlanLibrary);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    // 预期的错误日志会延迟持久化，推进测试时钟完成日志写入。
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
