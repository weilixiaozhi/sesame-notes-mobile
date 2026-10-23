import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' show Mock, when, any;
import 'package:sesame_api_client/sesame_api_client.dart' show SesameApiClient;
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

/// 使用手动触发的计时器，让真实数据库和 Provider 始终留在同一异步环境。
class _Timer implements Timer {
  _Timer(this.delay, this.run);
  final Duration delay;
  final void Function() run;
  bool _active = true;
  int _tick = 0;
  @override
  bool get isActive => _active;
  @override
  int get tick => _tick;

  /// 取消后即使旧回调被测试再次触发也不执行任务。
  @override
  void cancel() => _active = false;

  /// 单次执行调度，不修改应用代码所选择的等待时长。
  void fire() {
    if (!_active) return;
    _active = false;
    _tick++;
    run();
  }
}

/// 记录生产调度器实际安排的等待时长，并等待下一次有效调度。
class _Timers {
  final timers = <_Timer>[];
  Completer<void>? _changed;
  Iterable<_Timer> get active => timers.where((timer) => timer.isActive);

  /// 向测试发布新定时器，取消的旧定时器仍保留以验证不会迟到执行。
  Timer schedule(Duration delay, void Function() run) {
    final timer = _Timer(delay, run);
    timers.add(timer);
    _changed?.complete();
    _changed = null;
    return timer;
  }

  /// 等待生产代码安排任务，不依赖真实睡眠或手动 invalidate Provider。
  Future<_Timer> next() async {
    while (active.isEmpty) {
      _changed ??= Completer<void>();
      await _changed!.future;
    }
    return active.first;
  }
}

/// 同步入口返回真实结果形态，测试不额外建立另一条后台队列。
class _Sync extends Fake implements SyncCoordinator {
  int calls = 0;
  Future<SyncRunResult> Function()? execute;

  /// 记录账号级完整轮次，由用例控制网络失败和任务完成。
  @override
  Future<SyncRunResult> run() async {
    calls++;
    return await execute?.call() ?? const SyncRunResult();
  }
}

/// 替代单本快照的网络边界，事务提交与发布标记仍由真实同步服务完成。
class _Api extends Mock implements api.SyncApi {}

/// 合法空账本也通过完整快照建立可见性，不使用交易笔数推断完成状态。
api.GetSyncFull200Response _full() => api.GetSyncFull200Response(
  (b) => b
    ..ledger = api.GetSyncFull200ResponseLedger(
      (row) => row
        ..id = 'cloud-ledger'
        ..ownerId = 'account-a'
        ..syncId = 'timeline'
        ..name = '后台完整空本'
        ..currency = 'CNY'
        ..monthStartDay = 1
        ..aaEnabled = false
        ..updatedAt = DateTime.utc(2026),
    ).toBuilder()
    ..transactions = ListBuilder<api.Transaction>()
    ..categories = ListBuilder<api.Category>()
    ..members = ListBuilder<api.Member>()
    ..recurringTransactions = ListBuilder<api.RecurringTransaction>()
    ..exchangeRateOverrides = ListBuilder<api.ExchangeRateOverride>()
    ..serverCursor = '10',
);

/// 从正式自动同步 Provider 验证持久下载任务、身份和暂停条件的装配。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late StreamController<bool> network;
  late CloudLedgerDownloadStore downloads;
  late _Timers timers;
  late _Sync sync;
  ProviderSubscription<AutoSyncCoordinator>? subscription;
  var disposed = false;

  /// 常驻订阅与应用根部相同，身份变化时会释放旧调度器。
  void activate() {
    subscription = container.listen(autoSyncCoordinatorProvider, (_, _) {});
  }

  /// 推进一次已安排的任务，再排空真实数据库与状态通知的微任务。
  Future<_Timer> runNext() async {
    final timer = await timers.next();
    timer.fire();
    await pumpEventQueue();
    return timer;
  }

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get();
    network = StreamController<bool>.broadcast(sync: true);
    timers = _Timers();
    sync = _Sync();
    subscription = null;
    disposed = false;
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(SesameApiClient()),
        cloudNetworkEventsProvider.overrideWithValue(network.stream),
        autoSyncTimerFactoryProvider.overrideWithValue(timers.schedule),
        syncCoordinatorProvider.overrideWithValue(sync),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token',
            userId: 'account-a',
            deviceId: 'device',
          ),
        );
    downloads = container.read(cloudLedgerDownloadStoreProvider);
    network.add(true);
  });

  tearDown(() async {
    subscription?.close();
    if (!disposed) container.dispose();
    await pumpEventQueue();
    await network.close();
    await db.close();
    await logger.clear();
  });

  test('应用已启动后仅登记首次任务、没有本地账本行也自动补齐，HTTP失败自动退避', () async {
    activate();
    await runNext();
    expect(sync.calls, 1);
    expect(timers.active, isEmpty);
    await downloads.markPending('account-a', 'invited-ledger');
    var attempts = 0;
    sync.execute = () async {
      attempts++;
      if (attempts == 1) {
        final connection = container.read(cloudConnectionProvider.notifier);
        connection.requestFailed(
          connection.generation,
          DioException(
            requestOptions: RequestOptions(path: '/sync/full'),
            type: DioExceptionType.receiveTimeout,
          ),
        );
        return const SyncRunResult(
          failure: SyncOperationFailure(
            code: 'NETWORK_UNAVAILABLE',
            message: '网络暂时不可用，数据已保存在本机',
          ),
        );
      }
      await downloads.markReady('account-a', 'invited-ledger');
      return const SyncRunResult();
    };
    final initial = await runNext();
    expect(initial.delay, const Duration(seconds: 2));
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(
      container.read(cloudConnectionProvider),
      CloudConnectionStatus.offline,
    );
    expect(
      container.read(cloudConnectionProvider.notifier).isNetworkUnavailable,
      isFalse,
    );
    final retry = await timers.next();
    expect(retry.delay, const Duration(seconds: 5));
    retry.fire();
    await pumpEventQueue();
    expect(attempts, 2);
    expect(await downloads.pending('account-a'), isEmpty);
    expect(timers.active, isEmpty);
  });

  for (final hasLocalSnapshot in [false, true]) {
    test('启动消费已持久化${hasLocalSnapshot ? '刷新' : '首次'}full任务，不要求本地变更', () async {
      await downloads.markPending(
        'account-a',
        'ledger',
        hasLocalSnapshot: hasLocalSnapshot,
      );
      sync.execute = () async {
        await downloads.markReady('account-a', 'ledger');
        return const SyncRunResult();
      };
      activate();
      await runNext();
      expect(sync.calls, 1);
      expect(await downloads.pending('account-a'), isEmpty);
      expect(timers.active, isEmpty);
    });
  }

  for (final state in ['stale', 'deleted', 'local', 'foreign-account']) {
    test('$state账本残留full任务不形成自动定时重试', () async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'ledger',
              name: '旧任务',
              storageMode: d.Value(state == 'local' ? 'local' : 'cloud'),
              scopeAccountId: d.Value(
                state == 'foreign-account' ? 'account-b' : 'account-a',
              ),
              bindingStatus: d.Value(state == 'stale' ? 'stale' : null),
              deletedAt: d.Value(
                state == 'deleted' ? DateTime.utc(2026) : null,
              ),
              updatedAt: DateTime.utc(2026),
            ),
          );
      await downloads.markPending(
        'account-a',
        'ledger',
        hasLocalSnapshot: true,
      );
      activate();
      await runNext();
      expect(sync.calls, 1);
      expect(await downloads.pending('account-a'), {'ledger'});
      expect(timers.active, isEmpty);
    });
  }

  test('旧集合仅剩stale任务时，新邀请ID变化仍启动下载并停止旧无效重试', () async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'stale-ledger',
            name: '待处理绑定',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            bindingStatus: const d.Value('stale'),
            updatedAt: DateTime.utc(2026),
          ),
        );
    await downloads.markPending(
      'account-a',
      'stale-ledger',
      hasLocalSnapshot: true,
    );
    activate();
    await runNext();
    expect(timers.active, isEmpty);
    await downloads.markPending('account-a', 'new-invite');
    sync.execute = () async {
      await downloads.markReady('account-a', 'new-invite');
      return const SyncRunResult();
    };
    final next = await runNext();
    expect(next.delay, const Duration(seconds: 2));
    expect(sync.calls, 2);
    expect(await downloads.pending('account-a'), {'stale-ledger'});
    expect(timers.active, isEmpty);
  });

  test('联网后后台full原子提交，正式列表和持久选本监听自动发布合法空账本', () async {
    network.add(false);
    await downloads.markPending('account-a', 'cloud-ledger');
    final persist = container.listen(currentLedgerPersistProvider, (_, _) {});
    final selected = Completer<void>();
    final selection = container.listen(currentLedgerIdProvider, (_, value) {
      if (value == 'cloud-ledger' && !selected.isCompleted) selected.complete();
    });
    final requested = Completer<void>();
    final response = Completer<Response<api.GetSyncFull200Response>>();
    final finished = Completer<void>();
    final fullApi = _Api();
    when(
      () => fullApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer((_) async {
      requested.complete();
      return response.future;
    });
    final service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'device',
      apiOverride: fullApi,
      currentAccountIdGetter: () => 'account-a',
      downloadStore: downloads,
    );
    sync.execute = () async {
      try {
        await service.full(ledgerId: 'cloud-ledger');
        return const SyncRunResult();
      } finally {
        finished.complete();
      }
    };
    try {
      await container.read(currentLedgerPersistProvider.future);
      activate();
      await pumpEventQueue();
      final actions = container.read(ledgerActionsProvider);
      expect(await actions.getAll(), isEmpty);
      expect(container.read(currentLedgerIdProvider), isEmpty);
      expect(timers.active, isEmpty);
      network.add(true);
      (await timers.next()).fire();
      await requested.future;
      expect(await actions.getAll(), isEmpty, reason: '网络响应和完整事务尚未完成时不发布占位本');
      response.complete(
        Response(
          requestOptions: RequestOptions(path: '/sync/full'),
          data: _full(),
        ),
      );
      await finished.future;
      await selected.future.timeout(const Duration(seconds: 5));
      await pumpEventQueue();
      expect((await actions.getAll()).map((book) => book.id), ['cloud-ledger']);
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await downloads.pending('account-a'), isEmpty);
      expect(timers.active, isEmpty);
    } finally {
      if (!response.isCompleted) {
        response.complete(
          Response(
            requestOptions: RequestOptions(path: '/sync/full'),
            data: _full(),
          ),
        );
      }
      if (requested.isCompleted) await finished.future;
      selection.close();
      persist.close();
    }
  });

  for (final gate in ['restore', 'account']) {
    test('无网恢复后仍有$gate闸门则暂停，开闸后自动继续', () async {
      network.add(false);
      if (gate == 'restore') {
        container.read(restoreGateProvider.notifier).hold();
      } else {
        container.read(syncGateProvider.notifier).hold();
      }
      await downloads.markPending('account-a', 'ledger');
      activate();
      await pumpEventQueue();
      expect(timers.active, isEmpty);
      network.add(true);
      await pumpEventQueue();
      expect(timers.active, isEmpty);
      if (gate == 'restore') {
        container.read(restoreGateProvider.notifier).release();
      } else {
        container.read(syncGateProvider.notifier).release();
      }
      sync.execute = () async {
        await downloads.markReady('account-a', 'ledger');
        return const SyncRunResult();
      };
      await runNext();
      expect(sync.calls, 1);
      expect(await downloads.pending('account-a'), isEmpty);
      expect(timers.active, isEmpty);
    });
  }

  for (final dispose in [false, true]) {
    test('full退避期间${dispose ? '销毁作用域' : '登出'}取消旧调度，无迟到同步', () async {
      await downloads.markPending('account-a', 'ledger');
      activate();
      await runNext();
      final retry = await timers.next();
      expect(retry.delay, const Duration(seconds: 5));
      if (dispose) {
        subscription?.close();
        subscription = null;
        container.dispose();
        disposed = true;
      } else {
        container.read(authSessionProvider.notifier).signOut();
      }
      await pumpEventQueue();
      expect(retry.isActive, isFalse);
      retry.fire();
      await pumpEventQueue();
      expect(sync.calls, 1);
      expect(timers.active, isEmpty);
    });
  }

  test('仅轮换访问令牌保留原退避，不提前重启同一身份任务', () async {
    await downloads.markPending('account-a', 'ledger');
    activate();
    await runNext();
    final retry = await timers.next();
    expect(retry.delay, const Duration(seconds: 5));
    container.read(authSessionProvider.notifier).updateToken('new-token');
    await pumpEventQueue();
    expect(timers.active.toList(), [retry]);
    expect(sync.calls, 1);
    sync.execute = () async {
      await downloads.markReady('account-a', 'ledger');
      return const SyncRunResult();
    };
    retry.fire();
    await pumpEventQueue();
    expect(sync.calls, 2);
    expect(timers.active, isEmpty);
  });

  test('HTTP超时后系统才断网，暂停到联网恢复仍能继续待下载任务', () async {
    await downloads.markPending('account-a', 'ledger');
    activate();
    await runNext();
    final retry = await timers.next();
    final connection = container.read(cloudConnectionProvider.notifier);
    connection.requestFailed(
      connection.generation,
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        type: DioExceptionType.receiveTimeout,
      ),
    );
    network.add(false);
    // 显示状态已是offline，原生断网可能不再发布相同枚举；到期检查仍须停下。
    retry.fire();
    await pumpEventQueue();
    expect(sync.calls, 1);
    expect(timers.active, isEmpty);
    sync.execute = () async {
      await downloads.markReady('account-a', 'ledger');
      return const SyncRunResult();
    };
    network.add(true);
    await runNext();
    expect(sync.calls, 2);
    expect(timers.active, isEmpty);
  });

  test('真实待推队列失败有界重试，冻结等簿记不续预算，新编辑重新唤醒', () async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: 'ledger',
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: '{"name":"第一次编辑"}',
            updatedAt: DateTime.utc(2026, 10, 19),
            mutationId: 'same-mutation',
          ),
        );
    sync.execute = () async {
      await (db.update(
        db.syncChanges,
      )..where((row) => row.mutationId.equals('same-mutation'))).write(
        const SyncChangesCompanion(
          frozenRequest: d.Value('{"mutation_id":"same-mutation"}'),
        ),
      );
      return const SyncRunResult(
        failure: SyncOperationFailure(
          code: 'CLOUD_SERVICE_UNAVAILABLE',
          message: '服务暂时不可用，数据已保存在本机',
        ),
      );
    };
    activate();
    expect((await runNext()).delay, const Duration(seconds: 2));
    for (final seconds in [5, 10, 20, 40, 60]) {
      expect((await runNext()).delay, Duration(seconds: seconds));
    }
    expect(sync.calls, 6);
    expect(timers.active, isEmpty);
    await (db.update(
      db.syncChanges,
    )..where((row) => row.mutationId.equals('same-mutation'))).write(
      const SyncChangesCompanion(
        frozenRequest: d.Value('{"mutation_id":"same-mutation"}'),
      ),
    );
    await pumpEventQueue();
    expect(timers.active, isEmpty);
    final frozen = await db.select(db.syncChanges).getSingle();
    expect(frozen.mutationId, 'same-mutation');
    expect(frozen.frozenRequest, '{"mutation_id":"same-mutation"}');
    // 结果未知的冻结行保持原样，新编辑作为其后继排队。
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: 'ledger',
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: '{"name":"第二次编辑"}',
            updatedAt: DateTime.utc(2026, 10, 19, 0, 0, 1),
            mutationId: 'new-mutation',
          ),
        );
    expect((await runNext()).delay, const Duration(seconds: 2));
    expect((await runNext()).delay, const Duration(seconds: 5));
    expect(sync.calls, 8);
  });

  test('普通上传退避期间访问令牌轮换保留原计时器，账号切换取消旧任务', () async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: 'ledger',
            accountId: const d.Value('account-a'),
            action: 'upsert',
            payload: '{}',
            updatedAt: DateTime.utc(2026),
            mutationId: 'pending-a',
          ),
        );
    sync.execute = () async => const SyncRunResult(
      failure: SyncOperationFailure(
        code: 'NETWORK_UNAVAILABLE',
        message: '网络暂时不可用，数据已保存在本机',
      ),
    );
    activate();
    await runNext();
    final retry = await timers.next();
    container.read(authSessionProvider.notifier).updateToken('rotated-token');
    await pumpEventQueue();
    expect(timers.active.toList(), [retry]);
    expect(sync.calls, 1);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'account-b-token',
            userId: 'account-b',
            deviceId: 'device',
          ),
        );
    await pumpEventQueue();
    expect(retry.isActive, isFalse);
    retry.fire();
    await pumpEventQueue();
    expect(sync.calls, 1, reason: '旧账号的退避回调不能替新账号同步');
    await runNext();
    expect(sync.calls, 2, reason: '新账号只执行自身启动同步');
    expect(timers.active, isEmpty, reason: '账号A待推行不能参与账号B重试资格');
  });
}
