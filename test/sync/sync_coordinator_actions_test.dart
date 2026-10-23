import 'package:drift/drift.dart' as d;
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late _MockSyncService service;
  late List<String> events;
  late SesameApiClient client;
  Completer<void>? restoreResponse;
  late Completer<void> restoreEntered;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    events = [];
    restoreResponse = null;
    restoreEntered = Completer<void>();
    service = _MockSyncService();
    when(() => service.refreshCategoryConflicts()).thenAnswer((_) async {});
    when(() => service.fitnessEnabled).thenReturn(false);
    when(() => service.currentAccountIdGetter).thenReturn(() => 'account-a');
    client = SesameApiClient(dio: Dio());
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          events.add('restore');
          if (!restoreEntered.isCompleted) restoreEntered.complete();
          await restoreResponse?.future;
          handler.resolve(Response(requestOptions: options, data: []));
        },
      ),
    );
    when(() => service.client).thenReturn(client);
    when(() => service.accountingFull()).thenAnswer((_) async {
      events.add('restore');
      if (!restoreEntered.isCompleted) restoreEntered.complete();
      await restoreResponse?.future;
    });
    when(() => service.synchronize()).thenAnswer((_) async {
      events.add('sync');
      return 0;
    });
    when(() => service.resolveConflictKeepLocal('conflict')).thenAnswer((
      _,
    ) async {
      events.add('keep');
    });
    when(() => service.resolveConflictAdoptRemote('conflict')).thenAnswer((
      _,
    ) async {
      events.add('adopt');
    });
    when(() => service.abandonLocalChanges(ledgerId: 'ledger')).thenAnswer((
      _,
    ) async {
      events.add('abandon');
    });
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(client),
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(accessToken: 'a', userId: 'a', deviceId: 'device'),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('切号先收敛已开始的本机事务，新保存立即提示暂停且不会写到新账号', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final coordinator = container.read(syncCoordinatorProvider);
    final writing = coordinator.runDataMutation(
      () => db.transaction(() async {
        await db.customStatement(
          "INSERT INTO categories(id,name,kind,level,scope_account_id,updated_at) "
          "VALUES('offline-category','账号A的分类','expense',1,'a',1000)",
        );
        entered.complete();
        await release.future;
        events.add('local-committed');
      }),
    );
    await entered.future;
    final switching = coordinator.runAccountTransition(() async {
      events.add('switch');
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'b',
              userId: 'b',
              deviceId: 'device',
            ),
          );
    });
    var unexpectedWrite = false;
    try {
      await expectLater(
        coordinator.runDataMutation(() async => unexpectedWrite = true),
        throwsA(isA<DataMutationPausedException>()),
      );
      expect(unexpectedWrite, isFalse);
      expect(events, isEmpty);
      expect(container.read(authSessionProvider)!.userId, 'a');
    } finally {
      release.complete();
      await writing;
      await switching;
    }
    expect(events, ['local-committed', 'switch']);
    final category = await db.select(db.categories).getSingle();
    expect(category.scopeAccountId, 'a');
    expect(category.name, '账号A的分类');
  });

  test('显式云端决策先收敛本机事务，操作在途时新保存立即失败并在结束后恢复', () async {
    final entered = Completer<void>();
    final releaseLocal = Completer<void>();
    final remoteEntered = Completer<void>();
    final releaseRemote = Completer<void>();
    final coordinator = container.read(syncCoordinatorProvider);
    final writing = coordinator.runDataMutation(
      () => db.transaction(() async {
        await db.customStatement(
          "INSERT INTO categories(id,name,kind,level,scope_account_id,updated_at) "
          "VALUES('preserved-category','离线分类','expense',1,'a',1000)",
        );
        entered.complete();
        await releaseLocal.future;
        events.add('local-committed');
      }),
    );
    await entered.future;
    final remote = coordinator.runDataOperation((_) async {
      events.add('remote-started');
      remoteEntered.complete();
      await releaseRemote.future;
    });
    try {
      await expectLater(
        coordinator.runDataMutation(() async => fail('决策期间不能启动新写入')),
        throwsA(isA<DataMutationPausedException>()),
      );
      expect(events, isEmpty);
      releaseLocal.complete();
      await writing;
      await remoteEntered.future;
      expect(events, ['local-committed', 'remote-started']);
      await expectLater(
        coordinator.runDataMutation(() async => fail('远端在途不能启动新写入')),
        throwsA(isA<DataMutationPausedException>()),
      );
    } finally {
      if (!releaseLocal.isCompleted) releaseLocal.complete();
      if (!releaseRemote.isCompleted) releaseRemote.complete();
      await writing;
      await remote;
    }
    await coordinator.runDataMutation(() async {
      await db.customStatement(
        "UPDATE categories SET name='操作结束后的分类' WHERE id='preserved-category' AND scope_account_id='a'",
      );
    });
    expect((await db.select(db.categories).getSingle()).name, '操作结束后的分类');
  });

  for (final operation in ['run', 'reconnect', 'bootstrap']) {
    test('$operation 三域目录一起开始发现，已有可用目录保持 ready', () async {
      final providers = [
        dayDirectoryStatusProvider,
        memoDirectoryStatusProvider,
        fitnessDirectoryStatusProvider,
      ];
      final readyIndex = ['run', 'reconnect', 'bootstrap'].indexOf(operation);
      for (var index = 0; index < providers.length; index++) {
        container
            .read(providers[index].notifier)
            .setStatus(
              index == readyIndex
                  ? BookDirectoryStatus.ready
                  : index.isEven
                  ? BookDirectoryStatus.unknown
                  : BookDirectoryStatus.failed,
            );
      }
      final entered = Completer<void>();
      final released = Completer<void>();

      /// 挂起当前同步入口，在网络响应前观察实际目录状态。
      Future<void> holdRequest() async {
        if (!entered.isCompleted) entered.complete();
        await released.future;
      }

      if (operation == 'run') {
        when(() => service.synchronize()).thenAnswer((_) async {
          await holdRequest();
          return 0;
        });
      } else {
        when(() => service.accountingFull()).thenAnswer((_) => holdRequest());
      }
      final coordinator = container.read(syncCoordinatorProvider);
      final running = switch (operation) {
        'run' => coordinator.run(),
        'reconnect' => coordinator.reconnect(),
        _ => coordinator.bootstrap(),
      };
      try {
        await entered.future;
        for (var index = 0; index < providers.length; index++) {
          expect(
            container.read(providers[index]),
            index == readyIndex
                ? BookDirectoryStatus.ready
                : BookDirectoryStatus.loading,
          );
        }
      } finally {
        released.complete();
        await running;
        // 普通恢复会尾随增量轮次，等待队列清空后再销毁测试容器。
        await coordinator.run();
      }
    });
  }

  test('拉取错误只在可信快照成功后清除，失败和其他账号错误均保留', () async {
    final now = DateTime.utc(2026, 9, 14);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger',
            name: '账本',
            updatedAt: now,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('a'),
          ),
        );
    final errorIds = <int>[];
    for (final account in ['a', 'b']) {
      errorIds.add(
        await db
            .into(db.syncPullErrors)
            .insert(
              SyncPullErrorsCompanion.insert(
                accountId: d.Value(account),
                changeId: account,
                entityType: 'category',
                entityId: 'record',
                action: 'upsert',
                rawChangeJson: '不能重放的原始内容',
                firstSeenAt: now,
                lastAttemptAt: now,
              ),
            ),
      );
    }
    final coordinator = container.read(syncCoordinatorProvider);
    when(() => service.accountingFull()).thenThrow(StateError('下载失败'));
    await expectLater(
      coordinator.retryPullError('pull:${errorIds.first}'),
      throwsStateError,
    );
    expect(
      (await db.select(db.syncPullErrors).get()).every(
        (row) => row.resolvedAt == null,
      ),
      isTrue,
    );
    when(() => service.accountingFull()).thenAnswer((_) async {});
    await coordinator.retryPullError('pull:${errorIds.first}');
    final rows = await db.select(db.syncPullErrors).get();
    expect(
      rows.firstWhere((row) => row.accountId == 'a').resolvedAt,
      isNotNull,
    );
    expect(rows.firstWhere((row) => row.accountId == 'b').resolvedAt, isNull);
    await expectLater(
      coordinator.retryPullError('pull:${errorIds.last}'),
      throwsStateError,
    );
    verify(() => service.accountingFull()).called(2);
  });

  test('同一账号刷新令牌时在途同步服务保持有效，换号才重建', () async {
    final actual = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(client),
      ],
    );
    addTearDown(actual.dispose);
    final sessions = actual.read(authSessionProvider.notifier);
    sessions.signIn(
      const AuthSession(accessToken: 'a', userId: 'a', deviceId: 'device'),
    );
    final original = actual.read(syncServiceProvider);
    sessions.updateToken('refreshed-token');
    expect(actual.read(syncServiceProvider), same(original));
    expect(original.currentAccountIdGetter(), 'a');
    sessions.signIn(
      const AuthSession(accessToken: 'b', userId: 'b', deviceId: 'device'),
    );
    expect(actual.read(syncServiceProvider), isNot(same(original)));
  });

  for (final action in ['keep', 'adopt', 'abandon']) {
    test('正在同步时 $action 等待完整同步轮次完成，后续同步不能越过用户操作', () async {
      final pushed = Completer<void>();
      final releasePush = Completer<void>();
      final entered = Completer<void>();
      final releaseAction = Completer<void>();
      when(() => service.synchronize()).thenAnswer((_) async {
        events.add('sync');
        if (!pushed.isCompleted) {
          pushed.complete();
          await releasePush.future;
        }
        return 0;
      });

      /// 保持用户操作在途，验证后续同步不得同时改写队列或快照。
      Future<void> perform() async {
        events.add(action);
        entered.complete();
        await releaseAction.future;
      }

      when(
        () => service.resolveConflictKeepLocal('conflict'),
      ).thenAnswer((_) => perform());
      when(
        () => service.resolveConflictAdoptRemote('conflict'),
      ).thenAnswer((_) => perform());
      when(
        () => service.abandonLocalChanges(ledgerId: 'ledger'),
      ).thenAnswer((_) => perform());
      final coordinator = container.read(syncCoordinatorProvider);
      final actions = container.read(ledgerActionsProvider);
      final syncing = coordinator.run();
      await pushed.future;
      final decision = switch (action) {
        'keep' => actions.resolveConflictKeepLocal('conflict'),
        'adopt' => actions.resolveConflictAdoptRemote('conflict'),
        _ => actions.abandonLocalChanges(ledgerId: 'ledger'),
      };
      await Future<void>.delayed(Duration.zero);
      expect(events, ['sync']);
      releasePush.complete();
      await syncing;
      await entered.future;
      final trailing = coordinator.run();
      await Future<void>.delayed(Duration.zero);
      expect(events, ['sync', action]);
      releaseAction.complete();
      expect((await decision).ok, isTrue);
      await trailing;
      expect(events, ['sync', action, 'sync']);
      verifyInOrder([
        () => service.synchronize(),
        () => service.refreshCategoryConflicts(),
        () => service.synchronize(),
        () => service.refreshCategoryConflicts(),
      ]);
    });
  }

  for (final restoring in [false, true]) {
    test('${restoring ? '恢复' : '账号清理'}闸门置起时三个用户动作均返回说明且不触碰服务', () async {
      if (restoring) {
        container.read(restoreGateProvider.notifier).hold();
      } else {
        container.read(syncGateProvider.notifier).hold();
      }
      final actions = container.read(ledgerActionsProvider);
      final results = await Future.wait([
        actions.resolveConflictKeepLocal('conflict'),
        actions.resolveConflictAdoptRemote('conflict'),
        actions.abandonLocalChanges(ledgerId: 'ledger'),
      ]);
      expect(
        results.every((result) => !result.ok && result.error!.isNotEmpty),
        isTrue,
      );
      expect(events, isEmpty);
    });
  }

  test('换号等待在途下载完成；换号前排在其后的点击不能操作新账号', () async {
    final downloading = Completer<void>();
    final downloaded = Completer<void>();
    when(() => service.abandonLocalChanges(ledgerId: 'ledger')).thenAnswer((
      _,
    ) async {
      downloading.complete();
      await downloaded.future;
      events.add('snapshot:${container.read(authSessionProvider)!.userId}');
    });
    final coordinator = container.read(syncCoordinatorProvider);
    final actions = container.read(ledgerActionsProvider);
    final abandon = actions.abandonLocalChanges(ledgerId: 'ledger');
    await downloading.future;
    final switching = coordinator.runAccountTransition(() async {
      events.add('switch');
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'b',
              userId: 'b',
              deviceId: 'device',
            ),
          );
    });
    final oldClick = actions.resolveConflictAdoptRemote('conflict');
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
    downloaded.complete();
    expect((await abandon).ok, isTrue);
    await switching;
    final result = await oldClick;
    expect(result.ok, isFalse);
    expect(result.error, contains('账号'));
    expect(events, ['snapshot:a', 'switch']);
  });

  test('用户操作已排队时，新同步触发必须排在用户决策之后', () async {
    final pushed = Completer<void>();
    final releasePush = Completer<void>();
    when(() => service.synchronize()).thenAnswer((_) async {
      events.add('sync');
      if (!pushed.isCompleted) {
        pushed.complete();
        await releasePush.future;
      }
      return 0;
    });
    final coordinator = container.read(syncCoordinatorProvider);
    final first = coordinator.run();
    await pushed.future;
    final decision = container
        .read(ledgerActionsProvider)
        .resolveConflictAdoptRemote('conflict');
    final laterRun = coordinator.run();
    releasePush.complete();
    await Future.wait([first, decision, laterRun]);
    expect(events, ['sync', 'adopt', 'sync']);
  });

  test('旧账号排队恢复过期后，新账号首次恢复仍执行', () async {
    final pushed = Completer<void>();
    final releasePush = Completer<void>();
    when(() => service.synchronize()).thenAnswer((_) async {
      events.add('sync');
      if (!pushed.isCompleted) {
        pushed.complete();
        await releasePush.future;
      }
      return 0;
    });
    final coordinator = container.read(syncCoordinatorProvider);
    final first = coordinator.run();
    await pushed.future;
    final switching = coordinator.runAccountTransition(() async {
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'b',
              userId: 'b',
              deviceId: 'device',
            ),
          );
    });
    final oldRestore = coordinator.reconnect();
    releasePush.complete();
    await switching;
    final newRestore = coordinator.reconnect();
    await first;
    await oldRestore;
    await newRestore;
    await coordinator.run();
    expect(events.where((event) => event == 'restore'), hasLength(1));
    expect(container.read(restoreGateProvider), isFalse);
  });

  for (final bootstrap in [false, true]) {
    test(
      '${bootstrap ? 'bootstrap' : 'reconnect'}等待在途用户操作，恢复结束后才补跑同步',
      () async {
        restoreResponse = Completer<void>();
        final entered = Completer<void>();
        final released = Completer<void>();
        when(() => service.resolveConflictAdoptRemote('conflict')).thenAnswer((
          _,
        ) async {
          events.add('adopt');
          entered.complete();
          await released.future;
          events.add('adopt-done');
        });
        final coordinator = container.read(syncCoordinatorProvider);
        final action = container
            .read(ledgerActionsProvider)
            .resolveConflictAdoptRemote('conflict');
        await entered.future;
        final restoring = bootstrap
            ? coordinator.bootstrap()
            : coordinator.reconnect();
        await Future<void>.delayed(Duration.zero);
        expect(events, ['adopt']);
        released.complete();
        await action;
        await restoreEntered.future;
        expect(container.read(restoreGateProvider), isTrue);
        final rejected = await container
            .read(ledgerActionsProvider)
            .abandonLocalChanges(ledgerId: 'ledger');
        expect(rejected.ok, isFalse);
        restoreResponse!.complete();
        await restoring;
        await coordinator.run();
        expect(events.take(4), ['adopt', 'adopt-done', 'restore', 'sync']);
        expect(container.read(restoreGateProvider), isFalse);
      },
    );
  }
}
