import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/models/memo.dart' as memos;
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart' as local;
import 'package:sesame_notes/data/models/day_event.dart' as days;
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/data/models/fitness.dart' as fitness;
import 'package:sesame_notes/domain/fitness/fitness_rules.dart'
    show fitnessDate;
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/diagnostics/data/acceptance_fitness_seeder.dart';
import 'package:uuid/uuid.dart';

import '../test/helpers/test_isolation.dart';
import 'category_roundtrip.dart';
import 'historical_member_roundtrip.dart';
import 'long_term_restore_roundtrip.dart';
import 'request_observation.dart';

const _backendMode = String.fromEnvironment(
  'E2E_BACKEND_MODE',
  defaultValue: 'isolated',
);
final _requestClock = Stopwatch()..start();
final _existingRequestPacer = ExistingBackendRequestPacer(
  nowMilliseconds: () => _requestClock.elapsedMilliseconds,
  delay: (duration) => Future<void>.delayed(duration),
);

/// 仅测试 transport 共用请求起始预算，不等待响应、不重试任何 HTTP 错误。
class ExistingBackendRequestPacer {
  ExistingBackendRequestPacer({
    required this.nowMilliseconds,
    required this.delay,
  });
  final int Function() nowMilliseconds;
  final Future<void> Function(Duration) delay;
  Future<void> _queue = Future<void>.value();
  int _nextRequestAt = 0, _nextAuthAt = 0;

  Future<void> waitForRequest(String path) {
    final auth = Uri.parse(path).path.startsWith('/api/v1/auth/');
    final reservation = _queue.then((_) async {
      final until = auth && _nextAuthAt > _nextRequestAt
          ? _nextAuthAt
          : _nextRequestAt;
      final remaining = until - nowMilliseconds();
      if (remaining > 0) await delay(Duration(milliseconds: remaining));
      final start = nowMilliseconds();
      _nextRequestAt = start + 250;
      if (auth) _nextAuthAt = start + 6500;
    });
    _queue = reservation;
    return reservation;
  }
}

/// 使用两个独立内存库验证 Dart 客户端与明确选定的测试后端往返。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetGlobalTestState();
    // 两个内存库分别代表两台设备，测试结束后恢复 Drift 的全局告警设置。
    final previousWarning =
        d.driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    d.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    addTearDown(
      () => d.driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarning,
    );
  });

  test(
    '真实后端：四个业务域双端往返、失败恢复、冲突与账号隔离',
    () async {
      try {
        final baseUrl = validatedBackendUrl(
          const String.fromEnvironment('E2E_BASE_URL'),
          mode: _backendMode,
          confirmed: const bool.fromEnvironment(
            'E2E_EXISTING_BACKEND_CONFIRMED',
          ),
          expectedBackendUrl: const String.fromEnvironment(
            'E2E_EXPECTED_BACKEND_URL',
          ),
        );
        // headless 测试恢复真实 HTTP；结束后还原测试框架原有的网络覆盖。
        final previousHttpOverrides = HttpOverrides.current;
        HttpOverrides.global = null;
        addTearDown(() => HttpOverrides.global = previousHttpOverrides);
        final clientA = _client(baseUrl);
        final clientB = _client(baseUrl);
        final readiness = await clientA.dio.get<Map<String, dynamic>>(
          '/api/v1/health/ready',
        );
        expect(readiness.statusCode, 200);
        expect(readiness.data?['status'], 'ok', reason: 'HTTP 和测试数据库必须已经就绪');

        // 同一账号在两次安装中取得各自的服务端设备身份，推送不能使用安装 UUID。
        const password = 'roundtrip-password';
        final phoneSuffix = (DateTime.now().microsecondsSinceEpoch % 100000000)
            .toString()
            .padLeft(8, '0');
        final phone = '138$phoneSuffix';
        final installationA = const Uuid().v4();
        final sessionA = (await clientA.getAuthApi().postAuthRegister(
          postAuthRegisterRequest: PostAuthRegisterRequest(
            (b) => b
              ..countryCode = '+86'
              ..phone = phone
              ..password = password
              ..device = _device(installationA).toBuilder(),
          ),
        )).data!;
        clientA.setBearerAuth('bearerAuth', sessionA.accessToken);
        final installationB = const Uuid().v4();
        final sessionB = (await clientB.getAuthApi().postAuthLogin(
          postAuthLoginRequest: PostAuthLoginRequest(
            (b) => b
              ..countryCode = '+86'
              ..phone = phone
              ..password = password
              ..device = _device(installationB).toBuilder(),
          ),
        )).data!;
        clientB.setBearerAuth('bearerAuth', sessionB.accessToken);
        expect(sessionA.deviceId, isNot(installationA));
        expect(sessionB.deviceId, isNot(installationB));
        expect(sessionA.deviceId, isNot(sessionB.deviceId));
        expect(sessionB.user.userId, sessionA.user.userId);
        final accountId = sessionA.user.userId;

        final dbA = local.SesameDatabase.withExecutor(NativeDatabase.memory());
        addTearDown(dbA.close);
        final dbB = local.SesameDatabase.withExecutor(NativeDatabase.memory());
        addTearDown(dbB.close);
        final recorder = ChangeRecorderImpl(
          dbA,
          accountIdGetter: () => accountId,
        );
        final syncA = SyncService(
          client: clientA,
          db: dbA,
          deviceId: sessionA.deviceId,
          currentAccountIdGetter: () => accountId,
          repo: LocalLedgerRepository(
            dbA,
            trackerGetter: () => recorder,
            accountIdGetter: () => accountId,
          ),
          localSelfIdLoader: () async => 'recurring-e2e-self',
          memoRepository: MemoRepository(
            dbA,
            accountIdGetter: () => accountId,
            generationGetter: () => 0,
            changeRecorder: recorder,
          ),
          dayRepository: DayRepository(
            dbA,
            accountIdGetter: () => accountId,
            generationGetter: () => 0,
            validateAndProject: validateAndProject,
            changeRecorder: recorder,
          ),
        );
        final syncB = SyncService(
          client: clientB,
          db: dbB,
          deviceId: sessionB.deviceId,
          currentAccountIdGetter: () => accountId,
          memoRepository: MemoRepository(
            dbB,
            accountIdGetter: () => accountId,
            generationGetter: () => 0,
            changeRecorder: ChangeRecorderImpl(
              dbB,
              accountIdGetter: () => accountId,
            ),
          ),
          dayRepository: DayRepository(
            dbB,
            accountIdGetter: () => accountId,
            generationGetter: () => 0,
            validateAndProject: validateAndProject,
            changeRecorder: ChangeRecorderImpl(
              dbB,
              accountIdGetter: () => accountId,
            ),
          ),
        );
        final ledgerId = const Uuid().v4();
        const ledgerName = '真实后端往返账本';
        // 创建时间取上一整秒，后续删除使用当前整秒，避免 LWW 同毫秒平局。
        final createdAt = DateTime.fromMillisecondsSinceEpoch(
          (DateTime.now().millisecondsSinceEpoch ~/ 1000 - 1) * 1000,
          isUtc: true,
        );
        await dbA
            .into(dbA.ledgers)
            .insert(
              local.LedgersCompanion.insert(
                id: ledgerId,
                name: ledgerName,
                storageMode: const d.Value('cloud'),
                scopeAccountId: d.Value(accountId),
                updatedAt: createdAt,
              ),
            );
        await recorder.recordLedgerChange(
          entityType: 'ledger',
          entityId: ledgerId,
          ledgerId: ledgerId,
          action: 'upsert',
          payload: jsonEncode({
            'name': ledgerName,
            'currency': 'CNY',
            'month_start_day': 1,
            'aa_enabled': false,
          }),
          updatedAt: createdAt,
        );
        expect((await _ledger(dbA, ledgerId)).syncId, isNull);
        expect(await _pending(dbA), hasLength(1));
        await syncA.push();
        expect(await _pending(dbA), isEmpty, reason: '首创确认后不能残留未推送变更');
        final boundLedger = await _ledger(dbA, ledgerId);
        expect(boundLedger.syncId, isNotEmpty, reason: '首创响应必须建立服务端同步身份');
        final full = (await clientA.getSyncApi().getSyncFull(
          ledgerId: ledgerId,
        )).data!;
        expect(full.ledger.id, ledgerId);
        expect(full.ledger.name, ledgerName);
        expect(full.ledger.syncId, boundLedger.syncId);

        // 第二份空库通过生产 SyncService 拉取；断言实际落库和账号域，而非仅计数。
        expect(await syncB.pull(), greaterThan(0));
        final pulledLedger = await _ledger(dbB, ledgerId);
        expect(pulledLedger.name, ledgerName);
        expect(pulledLedger.currency, 'CNY');
        expect(pulledLedger.storageMode, 'cloud');
        expect(pulledLedger.scopeAccountId, accountId);
        expect(pulledLedger.deletedAt, isNull);
        // 首次绑定按启动流程读取 full；普通增量不保证包含服务器同步身份。
        await syncB.full(ledgerId: ledgerId);
        expect((await _ledger(dbB, ledgerId)).syncId, boundLedger.syncId);
        final storedCursorBeforeDelete =
            (await dbB.select(dbB.syncState).getSingle()).serverCursor;
        expect(
          storedCursorBeforeDelete,
          isNotNull,
          reason: '首次完整消费成功后必须持久化记账域水位，NULL 仍表示尚未初始化',
        );
        final cursorBeforeDelete = storedCursorBeforeDelete!;
        expect(BigInt.parse(cursorBeforeDelete), greaterThan(BigInt.zero));

        // 金额精度只验证真实 REST 和 full 的字符串边界，不对本地 double 作精度承诺。
        const exactAmount = '99999999999999999999.9999999999';
        final transactionId = const Uuid().v4();
        final transaction =
            (await clientA.getTransactionsApi().postLedgersByLedgerIdTransactions(
              ledgerId: ledgerId,
              postLedgersByLedgerIdTransactionsRequest:
                  PostLedgersByLedgerIdTransactionsRequest(
                    (b) => b
                      ..id = transactionId
                      ..txType =
                          PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
                              .expense
                      ..amount = exactAmount
                      ..nativeAmount = exactAmount
                      ..currencyCode = 'CNY'
                      ..happenedAt = createdAt,
                  ),
            )).data!;
        expect(transaction.id, transactionId);
        expect(transaction.amount, exactAmount);
        expect(transaction.nativeAmount, exactAmount);
        final snapshot = (await clientB.getSyncApi().getSyncFull(
          ledgerId: ledgerId,
        )).data!;
        final storedTransaction = snapshot.transactions.single;
        expect(storedTransaction.id, transactionId);
        expect(storedTransaction.amount, exactAmount);
        expect(storedTransaction.nativeAmount, exactAmount);

        final deletedAt = DateTime.fromMillisecondsSinceEpoch(
          DateTime.now().millisecondsSinceEpoch ~/ 1000 * 1000,
          isUtc: true,
        );
        await recorder.recordLedgerChange(
          entityType: 'ledger',
          entityId: ledgerId,
          ledgerId: ledgerId,
          action: 'delete',
          payload: jsonEncode({'deleted_at': deletedAt.toIso8601String()}),
          updatedAt: deletedAt,
        );
        await syncA.push();
        expect(await _pending(dbA), isEmpty, reason: '删除确认后待推送队列必须清空');
        final requestedCursors = <String>[];
        clientB.dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path == '/api/v1/sync/pull') {
                requestedCursors.add(
                  options.queryParameters['since'].toString(),
                );
              }
              handler.next(options);
            },
          ),
        );
        await syncB.pull();
        expect(
          requestedCursors.first,
          cursorBeforeDelete,
          reason: '删除必须复用已保存游标增量拉取',
        );
        final tombstone = await _ledger(dbB, ledgerId);
        expect(tombstone.deletedAt?.toUtc(), deletedAt, reason: '账本行保留明确的删除时间');
        final storedCursorAfterDelete =
            (await dbB.select(dbB.syncState).getSingle()).serverCursor;
        expect(
          storedCursorAfterDelete,
          isNotNull,
          reason: '删除增量成功提交后必须保留明确水位，不能退回未初始化状态',
        );
        final cursorAfterDelete = storedCursorAfterDelete!;
        expect(
          BigInt.parse(cursorAfterDelete),
          greaterThan(BigInt.parse(cursorBeforeDelete)),
        );
        expect(await syncB.pull(), 0, reason: '已确认的增量不能重复拉取');
        await runCategoryRoundtrip(
          syncA,
          syncB,
          accountId,
          promoteLocal: (repo, ledger) =>
              _promoteForRealTest(syncA, repo, ledger, accountId),
        );
        await runHistoricalMemberRoundtrip(
          syncA,
          syncB,
          accountId,
          promoteLocal: (repo, ledger) =>
              _promoteForRealTest(syncA, repo, ledger, accountId),
        );
        await _daysRoundtrip(syncA, syncB, accountId);
        await _memosRoundtrip(syncA, syncB, accountId);
        await _credentialOrderRoundtrip(syncA, syncB, accountId);
        await _fitnessRoundtrip(syncA, syncB, accountId, baseUrl);
        await _recurringRoundtrip(syncA, syncB, clientA, clientB, accountId);
        await runCategoryConflictRoundtrip(syncA, syncB, accountId);
        await runLongTermRestoreRoundtrip(syncA, syncB, accountId);
      } catch (error, stackTrace) {
        printOnFailure('真实测试后端往返失败，请检查断言和后端日志：$error\n$stackTrace');
        if (error is DioException) {
          printOnFailure(
            '${error.requestOptions.method} ${error.requestOptions.path} '
            'HTTP ${error.response?.statusCode}: ${error.response?.data}; '
            'Retry-After=${error.response?.headers.value('retry-after')}',
          );
        }
        rethrow;
      }
    },
    timeout: const Timeout(
      Duration(seconds: _backendMode == 'existing-backend' ? 180 : 120),
    ),
  );
}

/// 两个真实会话、独立 SQLite 和生产仓储；响应丢失发生在服务端提交之后。
Future<void> _fitnessRoundtrip(
  SyncService existingA,
  SyncService existingB,
  String accountId,
  String baseUrl,
) async {
  final dbA = existingA.db, dbB = existingB.db;
  SyncService enabled(SyncService existing) => SyncService(
    client: existing.client,
    db: existing.db,
    deviceId: existing.deviceId,
    currentAccountIdGetter: () => accountId,
    fitnessEnabled: true,
    dayRepository: existing.dayRepository,
  );
  final syncA = enabled(existingA), syncB = enabled(existingB);
  final spaceId = const Uuid().v4();
  await FitnessSpaceRepository(
    dbA,
    accountIdGetter: () => accountId,
    changeRecorder: ChangeRecorderImpl(dbA, accountIdGetter: () => accountId),
  ).createBook(id: spaceId, name: '真实健身空间', storageMode: 'cloud');
  FitnessRepository repository(local.SesameDatabase db) => FitnessRepository(
    db,
    spaceId: spaceId,
    accountIdGetter: () => accountId,
    changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => accountId),
  );
  final repoA = repository(dbA), repoB = repository(dbB);
  final exercise = fitness.FitnessExercise(
    id: const Uuid().v4(),
    exerciseId: '0025',
    sets: [
      fitness.FitnessSet(
        id: const Uuid().v4(),
        weight: '20.1250000001',
        reps: 8,
      ),
      fitness.FitnessSet(id: const Uuid().v4()),
    ],
  );
  final template = await repoA.saveTemplate(
    fitness.FitnessTemplate(name: '健身真实模板', exercises: [exercise]),
  );
  final plan = await repoA.savePlan(
    fitness.FitnessPlan(
      name: '健身两日周期',
      startDate: fitnessDate(DateTime.now()),
      cycleDays: 2,
      days: [
        fitness.FitnessPlanDay(
          dayIndex: 0,
          slot: fitness.FitnessPlanSlot(
            id: const Uuid().v4(),
            sourceTemplateId: template.id,
            name: template.name,
            exercises: template.exercises,
          ),
        ),
        const fitness.FitnessPlanDay(dayIndex: 1),
      ],
    ),
  );
  final generated = (await repoA.getWorkouts()).single;
  await repoA.startWorkout(generated.id);
  final performed = (await repoA.getWorkout(generated.id))!.exercises.single;
  await repoA.setGroupCompleted(
    generated.id,
    performed.id,
    performed.sets.first.id,
    true,
  );
  await repoA.pauseRest(generated.id);
  await repoA.pauseWorkout(generated.id);
  await repoA.savePreferences(
    const fitness.FitnessPreferences(
      defaultRestSeconds: 105,
      exerciseRestSettings: {
        '0025': fitness.FitnessExerciseRest(
          restSeconds: 90,
          warmupRestSeconds: 30,
        ),
      },

      pinnedExerciseIds: ['0025'],
    ),
  );
  await syncA.push();
  expect(await _pending(dbA), isEmpty);
  final localRows = await dbA.select(dbA.fitnessEntities).get();
  expect(localRows.map((e) => e.entityType).toSet(), {
    'fitness_template',
    'fitness_plan',
    'fitness_workout',
    'fitness_preferences',
  });
  expect(
    localRows.every((e) => e.syncId != null && e.serverRevision == 1),
    isTrue,
  );

  await syncB.discoverFitnessSpaces();
  expect((await dbB.select(dbB.fitnessSpaces).getSingle()).id, spaceId);
  final downloaded = (await repoB.getWorkout(generated.id))!;
  expect(downloaded.status, 'in_progress');
  expect(
    (await repoB.getPreferences())
        .exerciseRestSettings['0025']!
        .warmupRestSeconds,
    30,
  );
  expect(downloaded.exercises.single.sets.first.weight, '20.1250000001');
  expect(downloaded.exercises.single.sets.first.completed, isTrue);
  expect(downloaded.exercises.single.sets.last.completed, isFalse);
  expect(downloaded.restTimer!.status, 'paused');
  expect(downloaded.runSegments.single.endedAt, isNotNull);
  expect(
    (await repoB.getPlans())
        .single
        .generationState
        .generatedCycles
        .single
        .restDates,
    hasLength(1),
  );
  expect((await repoB.getTemplates()).single.name, '健身真实模板');
  expect((await repoB.getPreferences()).defaultRestSeconds, 105);
  expect(
    (await FitnessSpaceRepository(
      dbB,
      accountIdGetter: () => accountId,
    ).getBook(spaceId, accountId: accountId))!.isComplete,
    isTrue,
  );

  // 请求已在真实后端提交，丢弃响应；用户再次编辑时仍必须先重放原 mutation。
  await repoA.saveTemplate(template.copyWith(name: '首次改名'));
  final sent = <String>[];
  var loseResponse = true;
  final loseAfterCommit = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/v1/sync/push') {
        sent.add(observedRequestJson(options.data));
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (loseResponse && response.requestOptions.path == '/api/v1/sync/push') {
        loseResponse = false;
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.connectionError,
          ),
        );
      } else {
        handler.next(response);
      }
    },
  );
  syncA.client.dio.interceptors.add(loseAfterCommit);
  try {
    await expectLater(syncA.push(), throwsA(isA<DioException>()));
    final frozen = (await _pending(dbA)).single.frozenRequest;
    expect(frozen, isNotNull);
    await repoA.saveTemplate(template.copyWith(name: '再次改名'));
    await syncA.push();
    expect(sent, hasLength(3));
    expect(sent[0], sent[1], reason: '响应丢失后重放同一请求与mutation身份');
    expect(sent[2], isNot(sent[1]));
    expect(await _pending(dbA), isEmpty);
    expect((await _fitnessRow(dbA, template.id)).serverRevision, 3);
  } finally {
    syncA.client.dio.interceptors.remove(loseAfterCommit);
  }
  await syncB.pull();
  expect((await repoB.getTemplates()).single.name, '再次改名');

  // 两端同一基线并发编辑：冲突不覆盖本机，选择本机后以最新远端revision重新CAS。
  await repoA.saveTemplate(template.copyWith(name: '甲端改名'));
  await repoB.saveTemplate(template.copyWith(name: '乙端改名'));
  await syncA.push();
  await syncB.push();
  final conflict =
      await (dbB.select(dbB.syncConflicts)..where(
            (c) => c.entityId.equals(template.id) & c.status.equals('OPEN'),
          ))
          .getSingle();
  expect((await repoB.getTemplates()).single.name, '乙端改名');
  expect(conflict.remoteRevision, 4);
  expect(await _pending(dbB), hasLength(1));
  await syncB.resolveConflictKeepLocal(conflict.id);
  await syncB.push();
  await syncA.pull();
  expect((await repoA.getTemplates()).single.name, '乙端改名');
  expect((await _fitnessRow(dbA, template.id)).serverRevision, 5);

  await repoA.finishWorkout(generated.id);
  await repoA.deletePlan(plan.id);
  await syncA.push();
  await syncB.pull();
  expect((await repoB.getWorkout(generated.id))!.status, 'completed');
  expect((await _fitnessRow(dbB, plan.id)).deletedAt, isNotNull);
  expect(
    (await repoB.getPlans(
      includeDeleted: true,
    )).single.generationState.generatedCycles.single.restDates,
    hasLength(1),
    reason: '计划墓碑保留历史休息日期，独立训练不级联删除',
  );

  // 首页同一生成入口：真实 PostgreSQL 往返校验全部样例，再在另一端恢复、暂停和完成。
  await fillAcceptanceFitness(repoA, paused: true);
  final seededRows = await dbA.select(dbA.fitnessEntities).get();
  await syncA.push();
  expect(await _pending(dbA), isEmpty);
  await syncB.pull();
  for (final row in seededRows.where((r) => r.deletedAt == null)) {
    expect(
      jsonDecode((await _fitnessRow(dbB, row.id)).payload),
      jsonDecode(row.payload),
    );
  }
  final active = (await repoB.getWorkouts()).singleWhere(
    (w) => w.status == 'in_progress',
  );
  expect(active.runSegments.last.endedAt, isNotNull);
  await repoB.startWorkout(active.id);
  await syncB.push();
  await syncA.pull();
  expect((await repoA.getWorkout(active.id))!.runSegments.last.endedAt, isNull);
  await repoA.pauseWorkout(active.id);
  await syncA.push();
  await syncB.pull();
  expect(
    (await repoB.getWorkout(active.id))!.runSegments.last.endedAt,
    isNotNull,
  );
  for (final set in active.exercises.single.sets.where((s) => !s.completed)) {
    await repoB.setGroupCompleted(
      active.id,
      active.exercises.single.id,
      set.id,
      true,
    );
  }
  // 勾完全部组后由用户明确结束训练，保留最后一组休息的协议语义。
  await repoB.finishWorkout(active.id);
  await syncB.push();
  await syncA.pull();
  expect((await repoA.getWorkout(active.id))!.status, 'completed');
  expect(
    (await repoA.getWorkout(active.id))!.toJson(),
    (await repoB.getWorkout(active.id))!.toJson(),
  );
  expect(await _pending(dbA), isEmpty);
  expect(await _pending(dbB), isEmpty);

  final restoredDb = local.SesameDatabase.withExecutor(NativeDatabase.memory());
  addTearDown(restoredDb.close);
  final restored = SyncService(
    client: syncB.client,
    db: restoredDb,
    deviceId: syncB.deviceId,
    currentAccountIdGetter: () => accountId,
    fitnessEnabled: true,
  );
  await restored.discoverFitnessSpaces();
  expect(
    (await restoredDb.select(restoredDb.fitnessEntities).get()).length,
    (await dbA.select(dbA.fitnessEntities).get()).length,
  );
  expect((await _fitnessRow(restoredDb, plan.id)).deletedAt, isNotNull);
  expect(
    jsonDecode((await _fitnessRow(restoredDb, generated.id)).payload),
    jsonDecode((await _fitnessRow(dbB, generated.id)).payload),
  );

  final otherClient = _client(baseUrl);
  final phone =
      '139${(DateTime.now().microsecondsSinceEpoch % 100000000).toString().padLeft(8, '0')}';
  final other = (await otherClient.getAuthApi().postAuthRegister(
    postAuthRegisterRequest: PostAuthRegisterRequest(
      (b) => b
        ..countryCode = '+86'
        ..phone = phone
        ..password = 'roundtrip-password'
        ..device = _device(const Uuid().v4()).toBuilder(),
    ),
  )).data!;
  otherClient.setBearerAuth('bearerAuth', other.accessToken);
  final otherDb = local.SesameDatabase.withExecutor(NativeDatabase.memory());
  addTearDown(otherDb.close);
  final otherSync = SyncService(
    client: otherClient,
    db: otherDb,
    deviceId: other.deviceId,
    currentAccountIdGetter: () => other.user.userId,
    fitnessEnabled: true,
  );
  await otherSync.discoverFitnessSpaces();
  await otherSync.pull();
  expect(
    await otherDb.select(otherDb.fitnessEntities).get(),
    isEmpty,
    reason: '另一真实账号不能通过full或pull读取原账号的五类健身记录',
  );
  expect(await otherDb.select(otherDb.fitnessSpaces).get(), isEmpty);
}

Future<local.FitnessEntityRow> _fitnessRow(
  local.SesameDatabase db,
  String id,
) => (db.select(db.fitnessEntities)..where((e) => e.id.equals(id))).getSingle();

/// 复用同账号双会话与双库，验证日子父子协议、完整定义和独立水位。
Future<void> _daysRoundtrip(
  SyncService syncA,
  SyncService syncB,
  String accountId,
) async {
  final repositoryA = syncA.dayRepository!;
  final repositoryB = syncB.dayRepository!;
  final dbA = syncA.db;
  final dbB = syncB.db;
  final bookId = const Uuid().v4();
  final eventIds = List.generate(
    days.DayCategory.values.length,
    (_) => const Uuid().v4(),
  );
  final createdAt = DateTime.utc(2020, 1, 1);
  // 农历投影采用已人工核对的固定日期，不调用待测历法库生成预期。
  final leapDate = days.OriginalDate(
    calendarType: days.DayCalendarType.lunar,
    originalYear: 2023,
    originalMonth: 2,
    originalDay: 1,
    isLeapMonth: true,
    solarDate: days.DateOnly(2023, 3, 22),
  );
  final lunarStart = days.OriginalDate(
    calendarType: days.DayCalendarType.lunar,
    originalYear: 2023,
    originalMonth: 1,
    originalDay: 1,
    solarDate: days.DateOnly(2023, 1, 22),
  );
  final lunarEnd = days.OriginalDate(
    calendarType: days.DayCalendarType.lunar,
    originalYear: 2023,
    originalMonth: 8,
    originalDay: 15,
    solarDate: days.DateOnly(2023, 9, 29),
  );
  final definitions = [
    days.DayEventDefinition(
      name: '农历闰月生日',
      category: days.DayCategory.birthday,
      repeatType: days.DayRepeatType.yearly,
      statisticType: days.DayStatisticType.year,
      event: leapDate,
    ),
    days.DayEventDefinition(
      name: '公历纪念日',
      category: days.DayCategory.anniversary,
      repeatType: days.DayRepeatType.yearly,
      statisticType: days.DayStatisticType.year,
      event: days.OriginalDate.solar(days.DateOnly(2020, 2, 29)),
    ),
    days.DayEventDefinition(
      name: '农历起点七日循环',
      category: days.DayCategory.countdown,
      repeatType: days.DayRepeatType.none,
      statisticType: days.DayStatisticType.day,
      countdownMode: days.DayCountdownMode.intervalDays,
      intervalDays: 7,
      start: lunarStart,
    ),
    days.DayEventDefinition(
      name: '双历法阶段',
      category: days.DayCategory.stage,
      repeatType: days.DayRepeatType.none,
      statisticType: days.DayStatisticType.day,
      start: days.OriginalDate.solar(days.DateOnly(2023, 9, 28)),
      end: lunarEnd,
    ),
  ];
  final batches = <List<Map<String, dynamic>>>[];
  final observer = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/v1/sync/push') {
        final changes = observedRequestBody(options.data)['changes'];
        if (changes is List) {
          final dayChanges = changes.cast<Map>().where(
            (change) => change['day_book_id'] == bookId,
          );
          if (dayChanges.isNotEmpty) {
            batches.add(
              dayChanges
                  .map((change) => Map<String, dynamic>.from(change))
                  .toList(),
            );
          }
        }
      }
      handler.next(options);
    },
  );
  syncA.client.dio.interceptors.add(observer);
  try {
    await repositoryA.createBook(
      id: bookId,
      name: '真实双端日子本',
      storageMode: 'cloud',
      accountId: accountId,
    );
    for (var index = 0; index < definitions.length; index++) {
      await repositoryA.saveEvent(
        days.DayEvent(
          id: eventIds[index],
          dayBookId: bookId,
          definition: definitions[index],
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        accountId: accountId,
      );
    }
    expect(
      (await repositoryA.getBook(bookId, accountId: accountId))!.syncId,
      isNull,
    );
    expect(await _pending(dbA), hasLength(definitions.length + 1));
    await syncA.push();
    final bound = (await repositoryA.getBook(bookId, accountId: accountId))!;
    expect(bound.syncId, isNotEmpty);
    expect(bound.serverRevision, 1);
    expect(await _pending(dbA), isEmpty);
    expect(batches.first, hasLength(1), reason: '未知绑定本的创建必须单独先行');
    expect(batches.first.single['entity_type'], 'day_book');
    expect(batches.first.single['sync_id'], isNull);
    final children = batches.skip(1).expand((batch) => batch).toList();
    expect(children, hasLength(definitions.length));
    for (final change in children) {
      expect(change['entity_type'], 'day_event');
      expect(change['day_book_id'], bookId);
      expect(change['ledger_id'], isNull);
      expect(change['sync_id'], bound.syncId, reason: '只有父绑定已确认后才能发送子记录');
      expect(change['base_revision'], 0);
    }

    final beforeFull = await dbB.select(dbB.syncState).getSingle();
    await syncB.fullDayBook(dayBookId: bookId);
    final afterFull = await dbB.select(dbB.syncState).getSingle();
    expect(
      afterFull.serverCursor,
      beforeFull.serverCursor,
      reason: '单本日子 full 不得提升记账水位',
    );
    expect(
      afterFull.dayEventsCursor,
      beforeFull.dayEventsCursor,
      reason: '单本 full 不证明其他日子本已经追赶',
    );
    final copied = (await repositoryB.getBook(bookId, accountId: accountId))!;
    expect(copied.scopeAccountId, accountId);
    expect(copied.storageMode, 'cloud');
    expect(copied.syncId, bound.syncId);
    expect(copied.fullCursor, isNotNull);
    final received = await repositoryB.getEvents(bookId, accountId: accountId);
    expect(received.map((event) => event.id), unorderedEquals(eventIds));
    for (var index = 0; index < definitions.length; index++) {
      final event = received.singleWhere(
        (event) => event.id == eventIds[index],
      );
      final expected = definitions[index];
      expect(event.serverRevision, 1);
      expect(event.createdAt.toUtc(), createdAt);
      expect(
        [
          event.definition.name,
          event.definition.category,
          event.definition.countdownMode,
          event.definition.intervalDays,
          event.definition.repeatType,
          event.definition.statisticType,
          event.definition.event,
          event.definition.start,
          event.definition.end,
        ],
        [
          expected.name,
          expected.category,
          expected.countdownMode,
          expected.intervalDays,
          expected.repeatType,
          expected.statisticType,
          expected.event,
          expected.start,
          expected.end,
        ],
        reason: '完整定义及原始历法、闰标志、公历投影必须经过两端后原样保留',
      );
    }
    final directory = (await syncB.client.getSyncApi().getSyncDayBooks()).data!;
    expect(
      directory.dayBooks.singleWhere((book) => book.id == bookId).syncId,
      bound.syncId,
    );
    await syncB.discoverDayBooks();
    final afterDirectory = await dbB.select(dbB.syncState).getSingle();
    expect(
      afterDirectory.serverCursor,
      beforeFull.serverCursor,
      reason: '目录恢复只建立日子域屏障',
    );
    expect(
      BigInt.parse(afterDirectory.dayEventsCursor!),
      greaterThan(BigInt.parse(beforeFull.dayEventsCursor!)),
    );
    expect(
      BigInt.parse(afterDirectory.dayEventsCursor!),
      greaterThanOrEqualTo(BigInt.parse(directory.serverCursor)),
    );

    // 先让 A 建立现有边界，再制造 B 的新版本，确保下一步验证真实增量。
    await syncA.discoverDayBooks();
    await syncA.pull();
    final original = received.singleWhere(
      (event) => event.id == eventIds.first,
    );
    await repositoryB.saveEvent(
      days.DayEvent(
        id: original.id,
        dayBookId: bookId,
        createdAt: original.createdAt,
        updatedAt: DateTime.now().toUtc(),
        definition: days.DayEventDefinition(
          name: '设备 B 修改后的生日',
          category: days.DayCategory.birthday,
          repeatType: days.DayRepeatType.yearly,
          statisticType: days.DayStatisticType.year,
          event: leapDate,
        ),
      ),
      accountId: accountId,
      expectedSyncId: bound.syncId,
    );
    await syncB.push();
    expect(await _pending(dbB), isEmpty);
    expect(await syncA.pull(), greaterThan(0));
    final edited = (await repositoryA.getEvents(
      bookId,
      accountId: accountId,
    )).singleWhere((event) => event.id == original.id);
    expect(edited.definition.name, '设备 B 修改后的生日');
    expect(edited.definition.event, leapDate);
    expect(edited.serverRevision, 2);
    expect(
      await dbA.select(dbA.syncConflicts).get(),
      isEmpty,
      reason: '自己的历史回显不能产生自冲突',
    );

    await repositoryA.deleteEvent(eventIds[2], bookId, accountId: accountId);
    await syncA.push();
    await syncB.pull();
    final deletedChild = await (dbB.select(
      dbB.dayEvents,
    )..where((row) => row.id.equals(eventIds[2]))).getSingle();
    expect(deletedChild.deletedAt, isNotNull, reason: '子记录删除保留明确墓碑');
    expect(deletedChild.serverRevision, 2);
    expect(
      await repositoryB.getEvents(bookId, accountId: accountId),
      hasLength(3),
    );
    expect(
      await repositoryB.getBook(bookId, accountId: accountId),
      isNotNull,
      reason: '删子不能删除父本',
    );

    // 云端条件删除以用户确认的最新完整快照为边界。
    await syncA.fullDayBook(dayBookId: bookId);
    await repositoryA.deleteBook(await repositoryA.target(bookId));
    await syncA.push();
    await syncB.pull();
    final deletedBook = await (dbB.select(
      dbB.dayBooks,
    )..where((row) => row.id.equals(bookId))).getSingle();
    expect(deletedBook.deletedAt, isNotNull, reason: '整本删除保留父墓碑并隐藏所有子记录');
    final tombstones = await (dbB.select(
      dbB.dayEvents,
    )..where((row) => row.dayBookId.equals(bookId))).get();
    expect(tombstones, hasLength(definitions.length));
    expect(tombstones.every((row) => row.deletedAt != null), isTrue);
    expect(await repositoryB.getEvents(bookId, accountId: accountId), isEmpty);
    expect(await repositoryB.getBook(bookId, accountId: accountId), isNull);
    expect(
      (await syncB.client.getSyncApi().getSyncDayBooks()).data!.dayBooks.where(
        (book) => book.id == bookId,
      ),
      isEmpty,
    );
    expect(await _pending(dbA), isEmpty);
    expect(await _pending(dbB), isEmpty);
    expect(await syncB.pull(), 0, reason: '日子墓碑确认后同一增量不重复应用');
  } finally {
    syncA.client.dio.interceptors.remove(observer);
  }
}

/// 隔离模式只接受本机；既有模式必须显式确认本轮授权的唯一测试地址。
String validatedBackendUrl(
  String value, {
  String mode = 'isolated',
  bool confirmed = false,
  String expectedBackendUrl = '',
}) {
  final uri = Uri.tryParse(value);
  if (uri == null ||
      value.trim() != value ||
      value.contains('\\') ||
      uri.scheme != 'http' ||
      !uri.hasPort ||
      uri.port <= 0 ||
      uri.port > 65535 ||
      uri.userInfo.isNotEmpty ||
      (uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw StateError('测试后端必须是带端口、无凭据或附加路径的 HTTP 地址');
  }
  if (mode == 'existing-backend') {
    // 授权目标独立于待访问地址传入；仅允许本机和私有局域网测试服务。
    final expected = Uri.tryParse(expectedBackendUrl);
    if (!confirmed ||
        !_isPrivateTestHost(uri.host) ||
        expected == null ||
        expected.scheme != 'http' ||
        !expected.hasPort ||
        (expectedBackendUrl != expected.origin &&
            expectedBackendUrl != '${expected.origin}/') ||
        uri.origin != expected.origin) {
      throw StateError('既有模式必须明确确认，并匹配配置的本机或私有局域网测试地址');
    }
  } else if (mode != 'isolated' ||
      confirmed ||
      !{'127.0.0.1', 'localhost'}.contains(uri.host)) {
    throw StateError('隔离模式仅允许本轮编排的本机测试地址');
  }
  return uri.origin;
}

/// 限定可写入测试数据的主机范围，不解析或信任任意公网域名。
bool _isPrivateTestHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1') return true;
  final octets = host.split('.');
  if (octets.length != 4 ||
      octets.any((part) => !RegExp(r'^(0|[1-9]\d{0,2})$').hasMatch(part))) {
    return false;
  }
  final parts = octets.map(int.parse).toList();
  if (parts.any((part) => part > 255)) return false;
  return parts[0] == 10 ||
      (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) ||
      (parts[0] == 192 && parts[1] == 168);
}

/// 创建有界超时的生成客户端，禁止跳转其他地址并在测试结束时关闭连接。
SesameApiClient _client(String baseUrl) {
  final client = SesameApiClient(
    basePathOverride: baseUrl,
    serializers: apiSerializers,
  );
  if (_backendMode == 'existing-backend') {
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _existingRequestPacer.waitForRequest(options.path);
          handler.next(options);
        },
      ),
    );
  }
  client.dio.options
    ..receiveTimeout = const Duration(seconds: 10)
    ..headers['x-sesame-recurring-protocol'] = '1'
    ..followRedirects = false;
  addTearDown(() => client.dio.close(force: true));
  return client;
}

/// 两份本机移动数据栈先离线生成同一发生，再由真实 API 生成并编辑，确认只保留一笔。
Future<void> _recurringRoundtrip(
  SyncService a,
  SyncService b,
  SesameApiClient clientA,
  SesameApiClient clientB,
  String account,
) async {
  LocalRepository repo(SyncService sync) => LocalRepository(
    sync.db,
    changeTracker: ChangeRecorderImpl(sync.db, accountIdGetter: () => account),
    accountIdGetter: () => account,
  );
  final repoA = repo(a), repoB = repo(b);
  final ledgerId = await repoA.createLedger(
    name: '周期跨端往返',
    storageMode: 'cloud',
  );
  await a.push();
  await b.pull();
  final now = DateTime.now().toUtc();
  final start = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 2));
  final ruleId = await repoA.addRecurringTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '10',
    frequency: 'daily',
    interval: 1,
    startDate: start,
    endDate: start,
    timeZone: 'Asia/Shanghai',
  );
  await a.push();
  await b.pull();
  final ruleA = (await repoA.getRecurringTransactionsByLedger(ledgerId)).single;
  final ruleB = (await repoB.getRecurringTransactionsByLedger(ledgerId)).single;
  final idA = await repoA.generateRecurringTransaction(
    recurring: ruleA,
    happenedAt: start,
  );
  final idB = await repoB.generateRecurringTransaction(
    recurring: ruleB,
    happenedAt: start,
  );
  expect(idA, idB);
  expect(idA, recurringOccurrenceId(ledgerId, ruleId, recurringDateKey(start)));
  final ledger = await _ledger(a.db, ledgerId);
  final syncId = ledger.syncId!;
  final generated =
      (await clientB
              .getAccountingApi()
              .postLedgersByLedgerIdRecurringTransactionsGenerateDue(
                ledgerId: ledgerId,
                postLedgersByLedgerIdRecurringTransactionsGenerateDueRequest:
                    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest(
                      (builder) => builder
                        ..expectedSyncId = syncId
                        ..expectedCurrency = ledger.currency
                        ..mutationId = const Uuid().v4(),
                    ),
              ))
          .data!;
  expect(generated.generatedCount, 1);
  await clientA
      .getTransactionsApi()
      .patchLedgersByLedgerIdTransactionsByTransactionId(
        ledgerId: ledgerId,
        transactionId: idA,
        patchLedgersByLedgerIdTransactionsByTransactionIdRequest:
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequest(
              (builder) => builder
                ..baseRevision = 1
                ..amount = '22'
                ..nativeAmount = '22'
                ..note = '网页修正',
            ),
      );
  await a.push();
  await b.push();
  expect((await repoA.getTransactionById(idA))!.amount, '22');
  expect((await repoB.getTransactionById(idB))!.note, '网页修正');
  final full = (await clientA.getSyncApi().getSyncFull(
    ledgerId: ledgerId,
  )).data!;
  expect(full.transactions, hasLength(1));
  expect(
    full.transactions.single.occurrenceDate.toString(),
    recurringDateKey(start),
  );
  expect(await _pending(a.db), isEmpty);
  expect(await _pending(b.db), isEmpty);
  await repoB.clearLedgerTransactions(ledgerId);
  await b.push();
  await a.pull();
  expect(await repoA.getTransactionById(idA), isNull);
  expect(
    (await a.db.select(a.db.transactions).get())
        .where((row) => row.id == idA)
        .single
        .recurringId,
    ruleId,
  );
  await _recurringPromotionRoundtrip(a, b, repoA, account);
}

/// 使用生产归属转换动作验证历史迁入、丢回执重试及完整快照复制再转云。
Future<void> _recurringPromotionRoundtrip(
  SyncService a,
  SyncService b,
  LocalRepository repo,
  String account,
) async {
  final now = DateTime.now().toUtc();
  final start = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 5));
  final ledgerId = await repo.createLedger(
    name: '本地周期迁入',
    storageMode: 'local',
    localSelfId: 'recurring-e2e-self',
  );
  final ruleId = await repo.addRecurringTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '10',
    frequency: 'daily',
    interval: 1,
    startDate: start,
    endDate: start.add(const Duration(days: 1)),
    timeZone: 'UTC',
  );
  var rule = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
  final deletedId = await repo.generateRecurringTransaction(
    recurring: rule,
    happenedAt: start,
  );
  rule = (await repo.getRecurringTransactionsByLedger(ledgerId)).single;
  final liveId = await repo.generateRecurringTransaction(
    recurring: rule,
    happenedAt: start.add(const Duration(days: 1)),
  );
  await repo.deleteTransaction(deletedId);
  await repo.updateTransaction(
    id: liveId,
    type: 'expense',
    amount: '33',
    note: '迁入前人工修改',
  );
  // 当前排期故意不同于历史；迁入不能按新排期否决已发生事实。
  await repo.updateRecurringTransaction(
    id: ruleId,
    ledgerId: ledgerId,
    type: 'expense',
    amount: '10',
    frequency: 'monthly',
    interval: 2,
    dayOfMonth: 31,
    startDate: start,
    endDate: start.add(const Duration(days: 1)),
    enabled: false,
    timeZone: 'UTC',
  );
  final removedRuleId = await repo.addRecurringTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '7',
    frequency: 'daily',
    interval: 1,
    startDate: start,
    endDate: start,
    timeZone: 'UTC',
  );
  final removedRule = (await repo.getRecurringTransactionsByLedger(
    ledgerId,
  )).singleWhere((row) => row.id == removedRuleId);
  final removedOccurrenceId = await repo.generateRecurringTransaction(
    recurring: removedRule,
    happenedAt: start,
  );
  await repo.deleteTransaction(removedOccurrenceId);
  await repo.deleteRecurringTransaction(removedRuleId);

  // 历史删除发生在迁入之前；增量事件、full和副本必须保留同一原始时间。
  final firstDeletedAt = start.add(const Duration(days: 3, hours: 6));
  final secondDeletedAt = start.add(const Duration(days: 4, hours: 6));
  await (a.db.update(a.db.transactions)
        ..where((row) => row.id.equals(deletedId)))
      .write(local.TransactionsCompanion(deletedAt: d.Value(firstDeletedAt)));
  await (a.db.update(a.db.transactions)
        ..where((row) => row.id.equals(removedOccurrenceId)))
      .write(local.TransactionsCompanion(deletedAt: d.Value(secondDeletedAt)));
  await (a.db.update(
    a.db.recurringTransactions,
  )..where((row) => row.id.equals(removedRuleId))).write(
    local.RecurringTransactionsCompanion(deletedAt: d.Value(secondDeletedAt)),
  );

  await _promoteForRealTest(a, repo, ledgerId, account);
  final initialRequests = <String>[];
  var loseResponse = true;
  final observer = InterceptorsWrapper(
    onError: (error, handler) {
      if (error.response?.data is Map &&
          (error.response!.data as Map)['code'] ==
              'RECURRING_INITIAL_INVALID') {
        Directory('Temp').createSync(recursive: true);
        File(
          'Temp/mobile-recurring-invalid-request.json',
        ).writeAsStringSync(observedRequestJson(error.requestOptions.data));
      }
      handler.next(error);
    },
    onResponse: (response, handler) {
      final request = response.requestOptions;
      if (request.path == '/api/v1/sync/push') {
        final changes = observedRequestBody(request.data)['changes'];
        if (changes is List &&
            changes.any(
              (change) =>
                  change is Map &&
                  change['payload'] is Map &&
                  (change['payload'] as Map).containsKey('initial_state'),
            )) {
          initialRequests.add(observedRequestJson(request.data));
          if (loseResponse) {
            loseResponse = false;
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.connectionError,
                error: '验收：服务端提交后丢失回执',
              ),
            );
            return;
          }
        }
      }
      handler.next(response);
    },
  );
  a.client.dio.interceptors.add(observer);
  try {
    await expectLater(
      a.push(),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          '模拟提交后的回执丢失',
          DioExceptionType.connectionError,
        ),
      ),
    );
    await a.push();
  } finally {
    a.client.dio.interceptors.remove(observer);
  }
  expect(initialRequests.length, greaterThanOrEqualTo(2));
  expect(
    initialRequests[1],
    initialRequests[0],
    reason: '未知提交结果必须重用完整冻结请求及mutation ID',
  );
  await _pullHistoricalTombstones(
    b,
    {deletedId: firstDeletedAt, removedOccurrenceId: secondDeletedAt},
    ruleTombstones: {removedRuleId: secondDeletedAt},
  );
  await b.full(ledgerId: ledgerId);
  final restoredRules = await (b.db.select(
    b.db.recurringTransactions,
  )..where((row) => row.ledgerId.equals(ledgerId))).get();
  expect(restoredRules, hasLength(2));
  expect(
    restoredRules
        .singleWhere((row) => row.id == removedRuleId)
        .deletedAt
        ?.toUtc(),
    secondDeletedAt,
  );
  final restored = await (b.db.select(
    b.db.transactions,
  )..where((row) => row.ledgerId.equals(ledgerId))).get();
  expect(restored, hasLength(3));
  expect(restored.singleWhere((row) => row.id == liveId).amount, '33');
  expect(restored.where((row) => row.deletedAt != null), hasLength(2));
  expect(
    restored.singleWhere((row) => row.id == deletedId).deletedAt?.toUtc(),
    firstDeletedAt,
  );
  expect(
    restored
        .singleWhere((row) => row.id == removedOccurrenceId)
        .deletedAt
        ?.toUtc(),
    secondDeletedAt,
  );

  final forkId = await a.transferToLocal(
    SyncTarget('ledger', ledgerId),
    move: false,
  );
  final forkRules = await (a.db.select(
    a.db.recurringTransactions,
  )..where((row) => row.ledgerId.equals(forkId))).get();
  final forkRows = await (a.db.select(
    a.db.transactions,
  )..where((row) => row.ledgerId.equals(forkId))).get();
  expect(forkRules, hasLength(2));
  expect(forkRows, hasLength(3));
  for (final row in forkRows) {
    expect(
      row.id,
      recurringOccurrenceId(forkId, row.recurringId!, row.occurrenceDate!),
    );
    if (row.deletedAt != null) {
      expect(
        row.deletedAt!.toUtc(),
        row.amount == '7' ? secondDeletedAt : firstDeletedAt,
      );
    }
  }
  await _promoteForRealTest(a, repo, forkId, account);
  await a.push();
  await _pullHistoricalTombstones(
    b,
    {
      for (final row in forkRows)
        if (row.deletedAt != null) row.id: row.deletedAt!.toUtc(),
    },
    ruleTombstones: {
      for (final rule in forkRules)
        if (rule.deletedAt != null) rule.id: rule.deletedAt!.toUtc(),
    },
  );
  await b.full(ledgerId: forkId);
  final forkLedger = await _ledger(a.db, forkId);
  final generated =
      (await a.client
              .getAccountingApi()
              .postLedgersByLedgerIdRecurringTransactionsGenerateDue(
                ledgerId: forkId,
                postLedgersByLedgerIdRecurringTransactionsGenerateDueRequest:
                    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest(
                      (builder) => builder
                        ..expectedSyncId = forkLedger.syncId!
                        ..expectedCurrency = forkLedger.currency
                        ..mutationId = const Uuid().v4(),
                    ),
              ))
          .data!;
  expect(generated.generatedCount, 0, reason: '暂停/已结束/已删历史迁入不能重生成支出');
  final finalRows = await (b.db.select(
    b.db.transactions,
  )..where((row) => row.ledgerId.equals(forkId))).get();
  expect(finalRows.where((row) => row.deletedAt == null).single.amount, '33');
  expect(finalRows.where((row) => row.deletedAt != null), hasLength(2));
  for (final row in finalRows.where((row) => row.deletedAt != null)) {
    expect(
      row.deletedAt!.toUtc(),
      row.amount == '7' ? secondDeletedAt : firstDeletedAt,
    );
  }
  expect(await _pending(a.db), isEmpty);
}

/// 在完整快照之前验证增量事件及本地墓碑，确保历史交易和规则不会被投影为活动记录。
Future<void> _pullHistoricalTombstones(
  SyncService sync,
  Map<String, DateTime> expected, {
  Map<String, DateTime> ruleTombstones = const {},
}) async {
  final received = <String, Object?>{};
  final observer = InterceptorsWrapper(
    onResponse: (response, handler) {
      if (response.requestOptions.path.endsWith('/sync/pull') &&
          response.data is Map) {
        final changes = (response.data as Map)['changes'];
        if (changes is List) {
          for (final change in changes.whereType<Map>()) {
            final expectedIds = change['entity_type'] == 'transaction'
                ? expected
                : change['entity_type'] == 'recurring_transaction'
                ? ruleTombstones
                : const <String, DateTime>{};
            if (expectedIds.containsKey(change['entity_id']) &&
                change['action'] == 'delete' &&
                change['entity_id'] is String) {
              final payload = change['payload'];
              received[change['entity_id'] as String] = payload is Map
                  ? payload['deleted_at']
                  : null;
            }
          }
        }
      }
      handler.next(response);
    },
  );
  sync.client.dio.interceptors.add(observer);
  try {
    await sync.pull();
    final expectedTimes = {...expected, ...ruleTombstones};
    expect(received.keys, unorderedEquals(expectedTimes.keys));
    for (final entry in expectedTimes.entries) {
      expect(received[entry.key], isA<String>(), reason: '增量墓碑必须携带原历史删除时间');
      expect(
        DateTime.parse(received[entry.key] as String).toUtc(),
        entry.value,
      );
    }
    // 先检查真实 SQLite 投影；后续完整快照即使能补齐墓碑，也不能掩盖增量回放错误。
    for (final entry in expected.entries) {
      final transaction = await (sync.db.select(
        sync.db.transactions,
      )..where((row) => row.id.equals(entry.key))).getSingle();
      expect(
        transaction.deletedAt?.toUtc(),
        entry.value,
        reason: '历史交易增量回放必须保留墓碑，不能被相同 revision 的活动快照覆盖',
      );
    }
    for (final entry in ruleTombstones.entries) {
      final rule = await (sync.db.select(
        sync.db.recurringTransactions,
      )..where((row) => row.id.equals(entry.key))).getSingle();
      expect(
        rule.deletedAt?.toUtc(),
        entry.value,
        reason: '历史规则增量回放必须保留墓碑，不能被元数据时钟拦截',
      );
    }
  } catch (error, stack) {
    printOnFailure('历史增量墓碑验收失败：$error\n$stack');
    rethrow;
  } finally {
    sync.client.dio.interceptors.remove(observer);
  }
}

/// 临时 Provider 作用域只替换基础设施，调用与应用相同的原子转云动作。
Future<void> _promoteForRealTest(
  SyncService sync,
  LocalRepository repo,
  String ledgerId,
  String account,
) async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(sync.db),
      repositoryProvider.overrideWithValue(repo),
      syncServiceProvider.overrideWithValue(sync),
      localSelfIdProvider.overrideWith((ref) async => 'recurring-e2e-self'),
      secureAccountStoreProvider.overrideWithValue(
        SecureAccountStore(
          _E2eSecureStore(),
          pendingStore: _E2eSecureStore(),
          logoutMarkerStore: _E2eSecureStore(),
        ),
      ),
      cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
    ],
  );
  try {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          AuthSession(
            accessToken: '仅本地Provider占位，HTTP使用真实已授权client',
            userId: account,
            deviceId: 'recurring-e2e',
          ),
        );
    await container
        .read(dataLifecycleProvider)
        .promoteLocal(SyncTarget('ledger', ledgerId));
  } finally {
    container.dispose();
  }
}

class _E2eSecureStore implements SecureStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String v) async {
    value = v;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

/// 构造安装信息；账号域设备身份由注册或登录响应返回。
PostAuthRegisterRequestDevice _device(String installationId) =>
    PostAuthRegisterRequestDevice(
      (b) => b
        ..installationId = installationId
        ..name = '本机自动验收'
        ..platform = 'flutter_test',
    );

/// 读取唯一账本行，缺行时立即失败，防止把物理删除当成正确墓碑。
Future<local.Ledger> _ledger(local.SesameDatabase db, String id) =>
    (db.select(db.ledgers)..where((row) => row.id.equals(id))).getSingle();

/// 读取未确认的同步队列，拒绝或冲突的变更仍属于待处理记录。
Future<List<local.SyncChange>> _pending(local.SesameDatabase db) =>
    (db.select(db.syncChanges)..where((row) => row.pushedAt.isNull())).get();

/// 两端真实 CAS 冲突经全局决策解决，再通过同一云转本机流程确认删除。
Future<void> _memosRoundtrip(
  SyncService a,
  SyncService b,
  String account,
) async {
  final repoA = a.memoRepository!, repoB = b.memoRepository!;
  final bookId = const Uuid().v4(), entryId = const Uuid().v4();
  await repoA.createBook(
    id: bookId,
    name: '记事往返',
    type: 'normal',
    storageMode: 'cloud',
  );
  memos.MemoEntry entry(String text) => memos.MemoEntry(
    id: entryId,
    memoBookId: bookId,
    bookType: 'normal',
    title: text,
    bodyJson: jsonEncode({
      'ops': [
        {'insert': '$text\n'},
      ],
    }),
    createdAt: DateTime.utc(2026, 9, 1),
    updatedAt: DateTime.now().toUtc(),
  );
  await repoA.saveEntry(entry('初稿'), await repoA.target(bookId));
  await a.push();
  await b.pull();
  expect(
    (await repoB.getEntry(entryId, await repoB.target(bookId)))!.title,
    '初稿',
  );
  await repoA.saveEntry(entry('设备甲修改'), await repoA.target(bookId));
  await repoB.saveEntry(entry('设备乙修改'), await repoB.target(bookId));
  await a.push();
  await b.push();
  final conflict =
      await (b.db.select(
            b.db.syncConflicts,
          )..where((c) => c.entityId.equals(entryId) & c.status.equals('OPEN')))
          .getSingle();
  expect(jsonDecode(conflict.localPayload)['title'], '设备乙修改');
  expect(jsonDecode(conflict.remotePayload)['title'], '设备甲修改');
  await b.resolveConflictKeepLocal(conflict.id);
  await b.push();
  await a.pull();
  expect(
    (await repoA.getEntry(entryId, await repoA.target(bookId)))!.title,
    '设备乙修改',
  );
  final localCopy = await a.transferToLocal(
    SyncTarget('memo_book', bookId),
    move: true,
  );
  final copied = await repoA.getBook(localCopy, accountId: account);
  expect(copied!.storageMode, 'local');
  expect(copied.entryCount, 1);
  await b.pull();
  expect(await repoB.getBook(bookId, accountId: account), isNull);
}

/// 两台设备往返排序，验证同步顺序参与默认展示且卡片正文完整保留。
Future<void> _credentialOrderRoundtrip(
  SyncService a,
  SyncService b,
  String account,
) async {
  final repoA = a.memoRepository!, repoB = b.memoRepository!;
  final bookId = const Uuid().v4();
  final ids = List.generate(3, (_) => const Uuid().v4());
  await repoA.createBook(
    id: bookId,
    name: '卡片顺序往返',
    type: 'credentials',
    storageMode: 'cloud',
  );
  final targetA = await repoA.target(bookId);
  for (var index = 0; index < ids.length; index++) {
    await repoA.saveEntry(
      memos.MemoEntry(
        id: ids[index],
        memoBookId: bookId,
        bookType: 'credentials',
        title: '卡片$index',
        bodyJson: jsonEncode({
          'fields': [
            {'label': '账号', 'value': '合成测试$index'},
          ],
        }),
        orderKey: index,
        createdAt: DateTime.utc(2026, 10, 1),
        updatedAt: DateTime.now().toUtc(),
      ),
      targetA,
    );
  }
  await a.push();
  await b.pull();
  final first = await repoA
      .watchCredentialEntries(bookId: bookId, accountId: account)
      .first;
  await repoA.reorderCredentials(targetA, first, [ids[2], ids[0], ids[1]]);
  await a.push();
  await b.pull();
  final remote = await repoB
      .watchCredentialEntries(bookId: bookId, accountId: account)
      .first;
  expect(remote.map((entry) => entry.id), [ids[2], ids[0], ids[1]]);

  final targetB = await repoB.target(bookId);
  await repoB.reorderCredentials(targetB, remote, [ids[1], ids[2], ids[0]]);
  await b.push();
  await a.pull();
  final returned = await repoA
      .watchCredentialEntries(bookId: bookId, accountId: account)
      .first;
  expect(returned.map((entry) => entry.id), [ids[1], ids[2], ids[0]]);
  for (var index = 0; index < ids.length; index++) {
    final entry = await repoA.getEntry(ids[index], targetA);
    expect(entry!.title, '卡片$index');
    expect(jsonDecode(entry.bodyJson!)['fields'][0]['value'], '合成测试$index');
  }
}
