import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/recurring_generation_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../helpers/test_isolation.dart';

const _accountA = '00000000-0000-4000-8000-000000000001';
const _accountB = '00000000-0000-4000-8000-000000000002';
const _deadline = Duration(seconds: 5);

/// 挂起一次发生的入口，观察账号屏障是否等待整次本机用例。
class _OccurrencePause {
  final entered = Completer<void>();
  final released = Completer<void>();

  /// 清理和正常路径共用幂等释放，避免断言失败后遗留等待。
  void release() {
    if (!released.isCompleted) released.complete();
  }
}

/// 只控制发生入口的等待，实际生成与 outbox 仍使用真实内存数据库。
class _PausedRecurringRepository extends LocalRepository {
  /// 使用真实账号 getter 与变更登记，防止测试绕开生命周期约束。
  _PausedRecurringRepository(
    super.db, {
    required super.accountIdGetter,
    required super.changeTracker,
  });

  _OccurrencePause? pause;

  /// 在事务前暂停，账号队列仍必须等待已受理的完整发生用例。
  @override
  Future<String> generateRecurringTransaction({
    required RecurringTransactionSnapshot recurring,
    required DateTime happenedAt,
  }) async {
    try {
      final current = pause;
      pause = null;
      if (current != null) {
        current.entered.complete();
        await current.released.future;
      }
      return await super.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: happenedAt,
      );
    } catch (error, stackTrace) {
      printOnFailure('受控周期发生失败：$error\n$stackTrace');
      rethrow;
    }
  }
}

/// 启动补记遵守恢复与账号转换屏障，每次发生保留独立的本机事务。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _PausedRecurringRepository repository;
  late ProviderContainer container;
  late String ledgerId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _PausedRecurringRepository(
      db,
      accountIdGetter: () => container.read(currentAccountIdProvider),
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => container.read(currentAccountIdProvider),
      ),
    );
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repository),
        unpublishedCloudLedgersProvider.overrideWith((ref) async => <String>{}),
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
    ledgerId = await repository.createLedger(
      name: '周期补记生命周期',
      storageMode: 'cloud',
    );
    await repository.addRecurringTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '8',
      frequency: 'daily',
      interval: 1,
      startDate: DateTime.utc(2024, 1, 1),
      endDate: DateTime.utc(2024, 1, 2),
      timeZone: 'UTC',
    );
  });

  tearDown(() async {
    try {
      container.dispose();
      await db.close();
    } catch (error, stackTrace) {
      printOnFailure('清理周期生命周期夹具失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('恢复期间启动补记不写业务行或推进游标', () async {
    final gate = container.read(restoreGateProvider.notifier)..hold();
    try {
      final generated = await container
          .read(startupRecurringGenerationProvider)()
          .timeout(_deadline);
      expect(generated, isEmpty);
      expect(await db.select(db.transactions).get(), isEmpty);
      final rule = await db.select(db.recurringTransactions).getSingle();
      expect(rule.lastGeneratedDate, isNull);
    } finally {
      gate.release();
    }
  });

  for (final transition in [
    (account: _accountB, name: '切号'),
    (account: _accountA, name: '同账号重新登录'),
  ]) {
    test('${transition.name}等待已受理发生完成，旧扫描不能继续补记余下日期', () async {
      final pause = _OccurrencePause();
      repository.pause = pause;
      final generation = container.read(authIdentityGenerationProvider);
      final generating = container.read(startupRecurringGenerationProvider)();
      Future<void>? switching;
      var transitioned = false;
      late Set<String> generated;
      try {
        await pause.entered.future.timeout(_deadline);
        switching = container
            .read(syncCoordinatorProvider)
            .runAccountTransition(() async {
              transitioned = true;
              container
                  .read(authSessionProvider.notifier)
                  .signIn(
                    AuthSession(
                      accessToken: 'b',
                      userId: transition.account,
                      deviceId: 'device',
                    ),
                  );
            });
        await pumpEventQueue();
        expect(transitioned, isFalse, reason: '账号转换必须等待已受理的本机发生用例');
      } finally {
        pause.release();
        generated = await generating.timeout(_deadline);
        await switching?.timeout(_deadline);
      }
      expect(generated, {ledgerId});
      final transactions = await db.select(db.transactions).get();
      expect(transactions, hasLength(1), reason: '切号后旧任务不能继续第二个发生日期');
      final changes = await (db.select(
        db.syncChanges,
      )..where((change) => change.entityType.equals('transaction'))).get();
      expect(changes, hasLength(1));
      expect(changes.single.accountId, _accountA);
      expect(container.read(currentAccountIdProvider), transition.account);
      expect(
        container.read(authIdentityGenerationProvider),
        greaterThan(generation),
      );
    });
  }

  test('同账号令牌轮换不取消已受理扫描，两天发生各生成一次', () async {
    final pause = _OccurrencePause();
    repository.pause = pause;
    final generation = container.read(authIdentityGenerationProvider);
    final generating = container.read(startupRecurringGenerationProvider)();
    try {
      await pause.entered.future.timeout(_deadline);
      // 令牌轮换保留身份；显式重新登录属于新的账号生命周期。
      container
          .read(authSessionProvider.notifier)
          .signIn(
            const AuthSession(
              accessToken: 'rotated',
              userId: _accountA,
              deviceId: 'device',
            ),
            preserveIdentity: true,
          );
      expect(container.read(authSessionProvider)?.accessToken, 'rotated');
      expect(container.read(authIdentityGenerationProvider), generation);
    } finally {
      pause.release();
      expect(await generating.timeout(_deadline), {ledgerId});
    }
    expect(await db.select(db.transactions).get(), hasLength(2));
    expect(
      await container.read(startupRecurringGenerationProvider)(),
      isEmpty,
      reason: '重复扫描仍受确定发生身份和游标保护',
    );
  });

  test('准备账本期间替换数据库，旧扫描不写旧库或新库', () async {
    final directory = Completer<Set<String>>();
    container.updateOverrides([
      databaseProvider.overrideWithValue(db),
      repositoryProvider.overrideWithValue(repository),
      unpublishedCloudLedgersProvider.overrideWith((ref) => directory.future),
    ]);
    final generating = container.read(startupRecurringGenerationProvider)();
    final replacement = SesameDatabase.withExecutor(NativeDatabase.memory());
    final replacementRepository = LocalRepository(replacement);
    try {
      await pumpEventQueue();
      container.updateOverrides([
        databaseProvider.overrideWithValue(replacement),
        repositoryProvider.overrideWithValue(replacementRepository),
        unpublishedCloudLedgersProvider.overrideWith((ref) => directory.future),
      ]);
      directory.complete({});
      expect(await generating.timeout(_deadline), isEmpty);
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await replacement.select(replacement.transactions).get(), isEmpty);
      final rule = await db.select(db.recurringTransactions).getSingle();
      expect(rule.lastGeneratedDate, isNull);
    } catch (error, stackTrace) {
      printOnFailure('数据库代次隔离验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      if (!directory.isCompleted) directory.complete({});
      await generating.timeout(_deadline);
      await replacement.close();
    }
  });
}
