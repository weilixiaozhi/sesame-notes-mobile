import 'dart:async';

import 'package:sesame_notes/providers/app_composition.dart';
import 'dart:ui' show Locale;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late ProviderContainer container;
  late AppLocalizations l10n;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    l10n = lookupAppLocalizations(const Locale('zh'));
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        ...applicationOverrides(),
        databaseProvider.overrideWithValue(db),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    await logger.clear();
  });

  test('没有任何本子时，首条数据按业务域创建默认本子并选为当前', () async {
    final provisioner = container.read(defaultBookProvisionerProvider);

    for (final mode in AppMode.values) {
      expect(
        await provisioner.ensureDefault(mode, l10n),
        isNotNull,
        reason: '${mode.name} 应创建默认本子承载首条数据',
      );
    }

    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.single.name, l10n.ledgerDefaultName);
    expect(ledgers.single.storageMode, 'local', reason: '未登录建本地本子，注册时随本搬迁');
    expect(container.read(currentLedgerIdProvider), ledgers.single.id);

    final dayBooks = await db.select(db.dayBooks).get();
    expect(dayBooks.single.name, l10n.dayDefaultBookName);
    expect(
      await container.read(currentDayBookIdProvider.future),
      dayBooks.single.id,
    );

    final memoBooks = await db.select(db.memoBooks).get();
    expect(memoBooks.single.name, l10n.memoDefaultBookName);
    expect(
      await container.read(currentMemoBookIdProvider.future),
      memoBooks.single.id,
    );

    final spaces = await db.select(db.fitnessSpaces).get();
    expect(spaces.single.name, l10n.fitnessDefaultSpaceName);
    expect(
      await container.read(currentFitnessSpaceIdProvider.future),
      spaces.single.id,
    );
  });

  test('已有本子时不再创建：登录账号不会多出一本同名默认本子', () async {
    final existing = await container
        .read(repositoryProvider)
        .createLedger(name: '云端账本', storageMode: 'local');

    expect(
      await container
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.bookkeeping, l10n),
      isNull,
    );
    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.single.id, existing);
  });

  test('已登录且已有云端健身空间时沿用目录，不重复创建默认空间', () async {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    final existing = await container
        .read(fitnessSpaceRepositoryProvider)
        .createBook(
          id: '11111111-1111-4111-8111-111111111111',
          name: '已有训练空间',
          storageMode: 'cloud',
        );

    expect(
      await container
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.fitness, l10n),
      isNull,
    );
    expect((await db.select(db.fitnessSpaces).get()).single.id, existing.id);
  });

  for (final mode in [AppMode.days, AppMode.memos, AppMode.fitness]) {
    test('${mode.name} 并发首条记录只创建一个默认本', () async {
      final provisioner = container.read(defaultBookProvisionerProvider);
      final results = await Future.wait([
        provisioner.ensureDefault(mode, l10n),
        provisioner.ensureDefault(mode, l10n),
      ]);
      final count = switch (mode) {
        AppMode.days => (await db.select(db.dayBooks).get()).length,
        AppMode.memos => (await db.select(db.memoBooks).get()).length,
        AppMode.fitness => (await db.select(db.fitnessSpaces).get()).length,
        _ => throw StateError('不支持的测试业务域'),
      };
      expect(count, 1);
      expect(results.whereType<String>(), hasLength(1));
    });
  }

  test('已知云端账本首次内容尚未发布时不自动另建默认本', () async {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    await container
        .read(cloudLedgerDownloadStoreProvider)
        .markPending('account', 'remote-book');
    expect(
      await container
          .read(defaultBookProvisionerProvider)
          .ensureDefault(AppMode.bookkeeping, l10n),
      isNull,
    );
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(container.read(currentLedgerIdProvider), isEmpty);
  });

  for (final mode in [AppMode.days, AppMode.memos, AppMode.fitness]) {
    for (final status in BookDirectoryStatus.values) {
      test('${mode.name} 登录后目录$status只在确认空目录时自动建本', () async {
        container
            .read(authSessionProvider.notifier)
            .signIn(
              const AuthSession(
                accessToken: 'token',
                userId: 'account',
                deviceId: 'device',
              ),
            );
        final directory = switch (mode) {
          AppMode.days => dayDirectoryStatusProvider,
          AppMode.memos => memoDirectoryStatusProvider,
          AppMode.fitness => fitnessDirectoryStatusProvider,
          _ => throw StateError('不支持的测试业务域'),
        };
        container.read(directory.notifier).setStatus(status);
        final id = await container
            .read(defaultBookProvisionerProvider)
            .ensureDefault(mode, l10n);
        expect(id, status == BookDirectoryStatus.ready ? isNotNull : isNull);
        final count = switch (mode) {
          AppMode.days => (await db.select(db.dayBooks).get()).length,
          AppMode.memos => (await db.select(db.memoBooks).get()).length,
          AppMode.fitness => (await db.select(db.fitnessSpaces).get()).length,
          _ => throw StateError('不支持的测试业务域'),
        };
        expect(count, status == BookDirectoryStatus.ready ? 1 : 0);
      });
    }
  }

  test('账号密码目录未确认时不建空本，确认后并发新增复用同一本', () async {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account',
            deviceId: 'device',
          ),
        );
    final provisioner = container.read(defaultBookProvisionerProvider);
    expect(await provisioner.ensureCredentialBook(l10n), isNull);
    expect(await db.select(db.memoBooks).get(), isEmpty);
    container
        .read(memoDirectoryStatusProvider.notifier)
        .setStatus(BookDirectoryStatus.ready);
    final ids = await Future.wait([
      provisioner.ensureCredentialBook(l10n),
      provisioner.ensureCredentialBook(l10n),
    ]);
    expect(ids.first, isNotNull);
    expect(ids.toSet(), hasLength(1));
    expect(await db.select(db.memoBooks).get(), hasLength(1));
  });

  test('默认建本等待期间换号，不沿用旧账号的无本判定', () async {
    final started = Completer<void>();
    final release = Completer<SharedPreferences>();
    container.dispose();
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        ...applicationOverrides(),
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWith((ref) async {
          if (!started.isCompleted) started.complete();
          return release.future;
        }),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'a',
            userId: 'account-a',
            deviceId: 'device',
          ),
        );
    final creating = container
        .read(defaultBookProvisionerProvider)
        .ensureDefault(AppMode.bookkeeping, l10n);
    await started.future;
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'b',
            userId: 'account-b',
            deviceId: 'device',
          ),
        );
    release.complete(await SharedPreferences.getInstance());
    expect(await creating, isNull);
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(container.read(currentLedgerIdProvider), isEmpty);
  });
}
