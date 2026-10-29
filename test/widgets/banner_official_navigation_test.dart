import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_banner_navigation.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/fitness_library_provider.dart';

/// 详情跳转复用应用正式参数，计划保留开始操作时的空间归属。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FitnessLibrary library;
  setUpAll(() async {
    library = FitnessLibrary.fromJson(
      jsonDecode(await File('assets/fitness/library.json').readAsString())
          as Map<String, dynamic>,
    );
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));
  for (final target in [
    AppBannerTarget.officialPlan,
    AppBannerTarget.officialTemplate,
  ]) {
    testWidgets('官方目标${target.id}传递现有详情参数', (tester) async {
      final actions = _Actions();
      const bookTarget = (
        bookId: 'space-a',
        accountId: null,
        syncId: null,
        generation: 0,
      );
      when(() => actions.target).thenReturn(bookTarget);
      final plan = target == AppBannerTarget.officialPlan;
      final id = plan ? library.plans.first.id : library.templates.first.id;
      final route = plan
          ? Routes.fitnessPlanEdit
          : Routes.fitnessTemplateDetail;
      Object? extra;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Consumer(
              builder: (context, ref, child) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      openFitnessBannerContent(context, ref, target, id),
                  child: const Text('打开'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: route,
            name: route,
            builder: (context, state) {
              extra = state.extra;
              return const Scaffold(body: Text('官方详情'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            fitnessLibraryProvider.overrideWith((ref) async => library),
            fitnessActionsProvider.overrideWithValue(actions),
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
      await tester.tap(find.text('打开'));
      await tester.pumpAndSettle();
      expect(find.text('官方详情'), findsOneWidget);
      if (plan) {
        final draft = extra as FitnessPlanImportDraft;
        expect(draft.target, bookTarget);
        expect(draft.plan.catalogOrigin!.itemId, id);
        expect(draft.officialTemplates, isNotEmpty);
      } else {
        expect((extra as OfficialFitnessTemplate).id, id);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('离线目标缺失时友好提示并回模板库，不跳不存在详情', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Consumer(
            builder: (context, ref, child) => Scaffold(
              body: TextButton(
                onPressed: () => openFitnessBannerContent(
                  context,
                  ref,
                  AppBannerTarget.officialTemplate,
                  '00000000-0000-4000-8000-000000000000',
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: Routes.fitnessTemplateLibrary,
          name: Routes.fitnessTemplateLibrary,
          builder: (context, state) => const Scaffold(body: Text('回到模板库')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fitnessLibraryProvider.overrideWith((ref) async => library),
          apiClientProvider.overrideWithValue(SesameApiClient(dio: Dio())),
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
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    expect(find.text('回到模板库'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

/// 只替换计划草稿的空间归属读取，不触碰真实账号或数据库。
class _Actions extends Mock implements FitnessActions {}
