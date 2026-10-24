import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/mutation_executor_provider.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../../helpers/test_isolation.dart';

const _accountA = '00000000-0000-4000-8000-000000000001';
const _accountB = '00000000-0000-4000-8000-000000000002';
const _deadline = Duration(seconds: 5);
final _date = DateTime.utc(2026, 10, 13);

class _MockSyncService extends Mock implements SyncService {}

/// 控制真实 SQLite 事务在写入完成、提交之前的暂停边界。
class _TransactionPause {
  final entered = Completer<void>();
  final released = Completer<void>();

  /// 失败清理与正常路径都可安全释放事务。
  void release() {
    if (!released.isCompleted) released.complete();
  }
}

/// 仅注入可控的提交等待，所有业务写入仍走真实组合仓储与内存 Drift。
class _PausedRepository extends LocalRepository {
  /// 账号和 outbox 登记使用生产仓储相同的依赖。
  _PausedRepository(
    super.db, {
    required super.changeTracker,
    required super.accountIdGetter,
  });

  _TransactionPause? _nextPause;
  final events = <String>[];

  /// 下一次最外层事务写入后等待释放，嵌套数据库操作不重复领取暂停点。
  _TransactionPause pauseNextTransaction() {
    final pause = _TransactionPause();
    _nextPause = pause;
    return pause;
  }

  /// 完成实际写入后再等待，只有数据库提交完成才记录 committed。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) async {
    final pause = _nextPause;
    _nextPause = null;
    try {
      final result = await super.runInTransaction(() async {
        final value = await action();
        if (pause != null) {
          pause.entered.complete();
          await pause.released.future;
        }
        return value;
      });
      if (pause != null) events.add('committed');
      return result;
    } catch (error, stackTrace) {
      logger.error('MutationLifecycleTest', '真实交易事务失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 保存全部业务表内容，连同步队列、编辑历史与派生水位都必须保持原样。
Future<Map<String, List<Map<String, Object?>>>> _databaseSnapshot(
  SesameDatabase db,
) async {
  try {
    final snapshot = <String, List<Map<String, Object?>>>{};
    for (final table in db.allTables) {
      final rows = await db
          .customSelect(
            'SELECT * FROM "${table.actualTableName}" ORDER BY rowid',
          )
          .get();
      snapshot[table.actualTableName] = [for (final row in rows) row.data];
    }
    return snapshot;
  } catch (error, stackTrace) {
    logger.error('MutationLifecycleTest', '读取数据库快照失败', error, stackTrace);
    rethrow;
  }
}

/// 真实写用例必须统一遵守恢复和切号闸门，普通增量网络不阻塞本机保存。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _PausedRepository repo;
  late ProviderContainer container;
  late _MockSyncService service;
  late SesameApiClient client;
  late TransactionActions actions;
  late String ledgerId;
  late String transactionId;
  late String recurringId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = SesameApiClient(
      dio: Dio(BaseOptions(baseUrl: 'https://example.test')),
    );
    service = _MockSyncService();
    when(() => service.client).thenReturn(client);
    when(() => service.fitnessEnabled).thenReturn(false);
    when(() => service.currentAccountIdGetter).thenReturn(() => _accountA);
    when(() => service.synchronize()).thenAnswer((_) async => 0);
    when(() => service.refreshCategoryConflicts()).thenAnswer((_) async {});
    repo = _PausedRepository(
      db,
      accountIdGetter: () => container.read(currentAccountIdProvider),
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(currentAccountIdProvider),
      ),
    );
    container = ProviderContainer(
      overrides: [
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://example.test'),
        ),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        apiClientProvider.overrideWithValue(client),
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'a',
            userId: _accountA,
            deviceId: 'device',
          ),
        );
    ledgerId = await repo.createLedger(name: '生命周期账本', storageMode: 'cloud');
    transactionId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      happenedAt: _date,
    );
    recurringId = await repo.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      frequency: 'daily',
      interval: 1,
      startDate: _date,
    );
    await repo.setOverride(base: 'CNY', quote: 'USD', rate: '7');
    actions = container.read(transactionActionsProvider);
    // 使用真实装配端口，不能用测试执行器绕过本次要验证的协调器。
    expect(
      container.read(mutationExecutorProvider),
      same(container.read(syncCoordinatorProvider)),
    );
  });

  tearDown(() async {
    try {
      container.dispose();
      client.dio.close(force: true);
      await db.close();
    } catch (error, stackTrace) {
      logger.error('MutationLifecycleTest', '清理测试资源失败', error, stackTrace);
      rethrow;
    }
  });

  /// 每个入口使用有效业务参数，失败原因只能是生命周期闸门。
  Future<Object?> perform(String operation) => switch (operation) {
    'add' => actions.add(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '9',
      happenedAt: _date,
    ),
    'edit' => actions.edit(
      id: transactionId,
      type: 'expense',
      amount: '10',
      historySummary: '调整金额',
    ),
    'delete' => actions.delete(transactionId),
    'addRecurring' => actions.addRecurring(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '9',
      frequency: 'daily',
      interval: 1,
      startDate: _date,
    ),
    'updateRecurring' => actions.updateRecurring(
      id: recurringId,
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 2,
      startDate: _date,
    ),
    'deleteRecurring' => actions.deleteRecurring(recurringId),
    'setRateOverride' => actions.setRateOverride(
      base: 'CNY',
      quote: 'USD',
      rate: '8',
    ),
    'removeRateOverride' => actions.removeRateOverride(
      base: 'CNY',
      quote: 'USD',
    ),
    _ => throw ArgumentError.value(operation, 'operation'),
  };

  for (final operation in [
    'add',
    'edit',
    'delete',
    'addRecurring',
    'updateRecurring',
    'deleteRecurring',
    'setRateOverride',
    'removeRateOverride',
  ]) {
    test('恢复闸门拒绝 $operation，所有业务表与待同步记录保持原样', () async {
      final before = await _databaseSnapshot(db);
      final gate = container.read(restoreGateProvider.notifier)..hold();
      try {
        await expectLater(
          perform(operation).timeout(_deadline),
          throwsA(isA<DataMutationPausedException>()),
        );
        expect(await _databaseSnapshot(db), equals(before));
      } finally {
        gate.release();
      }
      verifyNever(() => service.synchronize());
    });
  }

  test('切号等待真实交易提交，期间新保存立即拒绝且不会写入新账号', () async {
    final coordinator = container.read(syncCoordinatorProvider);
    final pause = repo.pauseNextTransaction();
    final writing = actions.add(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '11',
      happenedAt: _date,
      note: '切号前保存',
    );
    Future<void>? switching;
    late String savedId;
    try {
      await pause.entered.future.timeout(_deadline);
      switching = coordinator.runAccountTransition(() async {
        repo.events.add('switch');
        // 只有真实数据库提交完成，账号切换才能查到刚保存的完整记录。
        final saved = await (db.select(
          db.transactions,
        )..where((row) => row.note.equals('切号前保存'))).getSingle();
        expect(saved.amount, '11');
        container
            .read(authSessionProvider.notifier)
            .signIn(
              const AuthSession(
                accessToken: 'b',
                userId: _accountB,
                deviceId: 'device',
              ),
            );
      });
      await expectLater(
        actions
            .add(
              ledgerId: ledgerId,
              type: 'expense',
              amount: '12',
              happenedAt: _date,
              note: '不得写入',
            )
            .timeout(_deadline),
        throwsA(isA<DataMutationPausedException>()),
      );
      expect(repo.events, isEmpty);
      expect(container.read(authSessionProvider)!.userId, _accountA);
    } finally {
      pause.release();
      savedId = await writing.timeout(_deadline);
      await switching?.timeout(_deadline);
    }
    expect(repo.events, ['committed', 'switch']);
    expect(container.read(authSessionProvider)!.userId, _accountB);
    final records = await db.select(db.transactions).get();
    expect(records, hasLength(2));
    expect(records.where((row) => row.note == '不得写入'), isEmpty);
    final changes = await (db.select(
      db.syncChanges,
    )..where((change) => change.entityId.equals(savedId))).get();
    expect(changes, isNotEmpty);
    expect(changes.every((change) => change.accountId == _accountA), isTrue);
  });

  test('完整同步轮次尚未返回时本机保存仍完成并登记待同步记录', () async {
    final entered = Completer<void>();
    final releasePush = Completer<void>();
    when(() => service.synchronize()).thenAnswer((_) async {
      entered.complete();
      await releasePush.future;
      return 0;
    });
    final syncing = container.read(syncCoordinatorProvider).run();
    try {
      await entered.future.timeout(_deadline);
      final id = await actions
          .add(
            ledgerId: ledgerId,
            type: 'expense',
            amount: '13',
            happenedAt: _date,
          )
          .timeout(_deadline);
      expect(releasePush.isCompleted, isFalse, reason: '保存完成不能以网络返回为前提');
      expect((await repo.getTransactionById(id))?.amount, '13');
      final changes = await (db.select(
        db.syncChanges,
      )..where((change) => change.entityId.equals(id))).get();
      expect(changes, isNotEmpty);
      expect(changes.every((change) => change.pushedAt == null), isTrue);
      verify(() => service.synchronize()).called(1);
    } finally {
      releasePush.complete();
      await syncing.timeout(_deadline);
    }
  });

  test('周期更新复用一次生命周期保护，内部事务嵌套不会等待自身队列', () async {
    await actions
        .updateRecurring(
          id: recurringId,
          ledgerId: ledgerId,
          type: 'expense',
          amount: '14',
          frequency: 'daily',
          interval: 2,
          startDate: _date,
        )
        .timeout(_deadline);
    final recurring = (await repo.getAllRecurringTransactions()).singleWhere(
      (row) => row.id == recurringId,
    );
    expect(recurring.amount, '14');
    expect(recurring.interval, 2);
    // 再次写入验证生命周期队列已释放，不能只看到内层 SQL 提交就认定成功。
    final id = await actions
        .add(
          ledgerId: ledgerId,
          type: 'expense',
          amount: '15',
          happenedAt: _date,
        )
        .timeout(_deadline);
    expect((await repo.getTransactionById(id))?.amount, '15');
  });
}
