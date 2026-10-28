import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_refresh.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

/// 只隔离云同步边界，刷新编排与本地重查都走真实仓储和内存库。
class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

/// 账号事实的唯一来源：仓储 accountIdGetter 与 Provider 都读它。
class _Account extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final accountProvider = NotifierProvider<_Account, String?>(_Account.new);

/// 本地读取失败由仓储注入，守住「本地失败不谎报成功」的分支。
class _FailingDayRepository extends DayRepository {
  _FailingDayRepository(super.db)
    : super(validateAndProject: validateAndProject);

  @override
  Future<List<DayBook>> getBooks({String? accountId}) async =>
      throw StateError('本地读取失败');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localId = '11111111-1111-4111-8111-111111111111';
  const cloudId = '22222222-2222-4222-8222-222222222222';

  late SesameDatabase db;
  late ProviderContainer container;
  late DayRepository repository;
  late _MockSyncCoordinator sync;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    sync = _MockSyncCoordinator();
    repository = DayRepository(
      db,
      validateAndProject: validateAndProject,
      accountIdGetter: () => container.read(accountProvider),
      changeRecorder: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(accountProvider),
      ),
    );
    container = ProviderContainer(
      overrides: [
        dayRepositoryProvider.overrideWithValue(repository),
        currentAccountIdProvider.overrideWith(
          (ref) => ref.watch(accountProvider),
        ),
        syncCoordinatorProvider.overrideWithValue(sync),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 建立目标本并返回仓储中的真实快照。
  Future<DayBook> createBook(String id, {bool cloud = false}) async {
    await repository.createBook(
      id: id,
      name: cloud ? '云端日子' : '本机日子',
      storageMode: cloud ? 'cloud' : 'local',
      accountId: cloud ? 'account' : null,
    );
    return (await repository.getBook(id, accountId: cloud ? 'account' : null))!;
  }

  /// 读取失败场景使用独立容器；登录状态按容器各自持有，需在此重新设置。
  ProviderContainer failingContainer({DayRepository? repo}) {
    final value = ProviderContainer(
      overrides: [
        dayRepositoryProvider.overrideWithValue(
          repo ?? _FailingDayRepository(db),
        ),
        currentAccountIdProvider.overrideWith(
          (ref) => ref.watch(accountProvider),
        ),
        syncCoordinatorProvider.overrideWithValue(sync),
      ],
    );
    addTearDown(value.dispose);
    value.read(accountProvider.notifier).set('account');
    return value;
  }

  test('本机本只重读本地库，登录后也不调用云端同步', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(localId);
    expect(
      await container.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localSuccess,
    );
    verifyNever(() => sync.refreshData());
  });

  test('未指定目标本且未登录时只刷新本地，不调用云端同步', () async {
    await createBook(localId);
    expect(
      await container.read(dayRefreshProvider).run(),
      DayRefreshOutcome.localSuccess,
    );
    verifyNever(() => sync.refreshData());
  });

  test('退出后旧云本快照只报告本地刷新，不产生云端失败提示', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    container.read(accountProvider.notifier).set(null);

    expect(
      await container.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localSuccess,
    );
    verifyNever(() => sync.refreshData());
  });

  test('未指定目标本但已登录时按账号级云端刷新', () async {
    container.read(accountProvider.notifier).set('account');
    await createBook(cloudId, cloud: true);
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult.cloudSynced());
    expect(
      await container.read(dayRefreshProvider).run(),
      DayRefreshOutcome.cloudSuccess,
    );
    verify(() => sync.refreshData()).called(1);
  });

  test('本机读取失败返回本机失败结果', () async {
    final target = await createBook(localId);
    expect(
      await failingContainer().read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localFailed,
    );
    verifyNever(() => sync.refreshData());
  });

  test('云本收到本地刷新结果时只提示本地成功，本地读取失败也按本地失败反馈', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult.localOnly());
    expect(
      await container.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localSuccess,
    );
    expect(
      await failingContainer().read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localFailed,
    );
  });

  test('缓存账号和云本在空服务器配置下真实刷新只报告本地成功，待上传记录保留', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    final before = await db.select(db.syncChanges).get();
    final scoped = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
        databaseProvider.overrideWithValue(db),
        dayRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(scoped.dispose);
    scoped
        .read(accountStateProvider.notifier)
        .restorePending(userId: 'account');
    expect(
      await scoped.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.localSuccess,
    );
    expect(await db.select(db.syncChanges).get(), before);
    expect(
      (await repository.getBook(cloudId, accountId: 'account'))?.storageMode,
      'cloud',
    );
  });

  test('云端同步失败仍返回本地成功结果', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult(error: '同步失败'));
    expect(
      await container.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.cloudFailedButLocalOk,
    );
    verify(() => sync.refreshData()).called(1);
  });

  test('云端同步抛异常仍返回本地成功结果', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    when(() => sync.refreshData()).thenThrow(StateError('网络异常'));
    expect(
      await container.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.cloudFailedButLocalOk,
    );
    verify(() => sync.refreshData()).called(1);
  });

  test('云端本的本地快照读取失败返回云端失败结果，不谎报云端成功', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    when(
      () => sync.refreshData(),
    ).thenAnswer((_) async => const SyncRunResult.cloudSynced());
    final scoped = failingContainer();
    expect(
      await scoped.read(dayRefreshProvider).run(book: target),
      DayRefreshOutcome.cloudFailed,
    );
    verify(() => sync.refreshData()).called(1);
  });

  test('刷新期间账号变化不发布迟到结果', () async {
    container.read(accountProvider.notifier).set('account');
    final target = await createBook(cloudId, cloud: true);
    when(() => sync.refreshData()).thenAnswer((_) async {
      container.read(accountProvider.notifier).set('other');
      return const SyncRunResult.cloudSynced();
    });
    expect(await container.read(dayRefreshProvider).run(book: target), isNull);
  });

  for (final fails in [false, true]) {
    test('同账号退出再登录不发布旧会话刷新结果：失败=$fails', () async {
      try {
        container.read(accountProvider.notifier).set('account');
        final target = await createBook(cloudId, cloud: true);
        const session = AuthSession(
          accessToken: 'token',
          userId: 'account',
          deviceId: 'device',
        );
        container.read(authSessionProvider.notifier).signIn(session);
        when(() => sync.refreshData()).thenAnswer((_) async {
          container.read(authSessionProvider.notifier).signOut();
          container.read(authSessionProvider.notifier).signIn(session);
          if (fails) throw StateError('原会话云端失败');
          return const SyncRunResult.cloudSynced();
        });
        expect(
          await container.read(dayRefreshProvider).run(book: target),
          isNull,
        );
      } catch (error, stackTrace) {
        fail('日子刷新会话隔离回归失败：$error\n$stackTrace');
      }
    });
  }
}
