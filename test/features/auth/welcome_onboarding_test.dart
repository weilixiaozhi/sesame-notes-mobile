import 'dart:ui' show Locale;

import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/auth/application/welcome_onboarding.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/shared/providers/seed_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late ProviderContainer container;
  late AppLocalizations l10n;
  var preloads = 0;

  /// 与 main() 一致的装配：注入真实的启屏预加载实现由启动测试覆盖，
  /// 此处只关心完成流程是否触发预加载以及预加载失败能否降级。
  ProviderContainer buildContainer({Future<void> Function()? preload}) {
    return ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
        splashPreloadRunnerProvider.overrideWith(
          (ref) => preload ?? () async => preloads++,
        ),
      ],
    );
  }

  setUp(() {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    l10n = lookupAppLocalizations(const Locale('zh'));
    preloads = 0;
    container = buildContainer();
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('完成欢迎流程：四域可用，只落分类模板，本子由首条数据懒创建', () async {
    final completed = await container
        .read(welcomeOnboardingProvider)
        .complete(l10n: l10n);

    expect(completed, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_shown'), isTrue);
    expect(prefs.getString('selected_currency'), 'CNY');
    // 分类模板就绪（首条数据的分类选择依赖它），四本本子一个都不预建
    expect(
      await LocalRepository(db).categoryStore.getAllCategories(),
      isNotEmpty,
    );
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await db.select(db.dayBooks).get(), isEmpty);
    expect(await db.select(db.memoBooks).get(), isEmpty);
    expect(await db.select(db.fitnessSpaces).get(), isEmpty);
    expect(prefs.getString('current_ledger_id'), isNull);
    expect(await container.read(currentDayBookIdProvider.future), isNull);
    expect(await container.read(currentMemoBookIdProvider.future), isNull);
    expect(container.read(currentModeProvider), AppMode.bookkeeping);
    expect(preloads, 1);
  });

  test('首次初始化固定CNY，不受地区或旧偏好影响，也不改已有账本币种', () async {
    SharedPreferences.setMockInitialValues({'selected_currency': 'HKD'});
    final dispatcher = TestWidgetsFlutterBinding.instance.platformDispatcher;
    dispatcher.localeTestValue = const Locale('en', 'US');
    addTearDown(dispatcher.clearLocaleTestValue);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'existing-usd',
            name: '已有美元账本',
            currency: const d.Value('USD'),
            updatedAt: DateTime(2026),
          ),
        );
    final completed = await container
        .read(welcomeOnboardingProvider)
        .complete(l10n: lookupAppLocalizations(const Locale('en')));
    expect(completed, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_currency'), 'CNY');
    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.single.currency, 'USD');
  });

  test('seed 失败：不写完成标记，重启后仍回欢迎页', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
        splashPreloadRunnerProvider.overrideWith(
          (ref) =>
              () async => preloads++,
        ),
        ensureSeedProvider.overrideWith(
          (ref) => ({AppLocalizations? l10n}) async {
            throw StateError('seed boom');
          },
        ),
      ],
    );

    await expectLater(
      container.read(welcomeOnboardingProvider).complete(l10n: l10n),
      throwsA(isA<StateError>()),
    );

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool('welcome_shown'),
      isNull,
      reason: '初始化失败绝不能标记完成，重启后仍走欢迎页',
    );
    expect(await db.select(db.ledgers).get(), isEmpty);
    // 冷启动判定：完成标记缺失时必须进入欢迎页
    expect(await container.read(welcomeCheckProvider.future), isTrue);
    expect(container.read(shouldShowWelcomeProvider), isTrue);
  });

  test('预加载失败不阻断完成流程，完成标记照常就绪', () async {
    container.dispose();
    container = buildContainer(
      preload: () async => throw StateError('preload boom'),
    );

    final completed = await container
        .read(welcomeOnboardingProvider)
        .complete(l10n: l10n);

    expect(completed, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('welcome_shown'), isTrue);
    expect(await db.select(db.ledgers).get(), isEmpty);
  });

  test('必需初始化失败保留欢迎流程，不写完成标记', () async {
    container.dispose();
    container = buildContainer(
      preload: () async {
        container.read(appInitStateProvider.notifier).set(AppInitState.failed);
        throw StateError('required initialization failed');
      },
    );
    try {
      await expectLater(
        container.read(welcomeOnboardingProvider).complete(l10n: l10n),
        throwsA(anything),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('welcome_shown'), isNull);
      expect(container.read(appInitStateProvider), AppInitState.failed);
    } catch (error, stackTrace) {
      fail('欢迎流程必需初始化回归失败：$error\n$stackTrace');
    }
  });
}
