import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as sdk;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

/// 仅替代传输边界，队列冻结、拆包和回执应用均由真实 SyncService 执行。
class _MockSyncApi extends Mock implements sdk.SyncApi {}

/// 测试身份只存在内存，避免读取系统安全存储。
class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;

  @override
  Future<void> delete() async => value = null;
}

const _account = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

/// 使用生成序列化器记录完整请求，验证冻结重试时每个字段保持原文。
String _wire(sdk.PostSyncPushRequest request) => jsonEncode(
  sdk.standardSerializers.serializeWith(
    sdk.PostSyncPushRequest.serializer,
    request,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    registerFallbackValue(
      sdk.PostSyncPushRequest(
        (b) => b
          ..deviceId = 'fixture-device'
          ..changes = ListBuilder<sdk.PostSyncPushRequestChangesInner>(),
      ),
    );
  });
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;
  late DataLifecycleActions actions;
  late SyncService service;
  late _MockSyncApi api;
  final day = DateTime.utc(2024, 1, 1);

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      accountIdGetter: () => _account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => _account),
    );
    api = _MockSyncApi();
    service = SyncService(
      client: sdk.SesameApiClient(),
      db: db,
      deviceId: 'fixture-device',
      apiOverride: api,
      currentAccountIdGetter: () => _account,
    );
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        secureAccountStoreProvider.overrideWithValue(
          SecureAccountStore(
            _MemorySecureStore(),
            pendingStore: _MemorySecureStore(),
            logoutMarkerStore: _MemorySecureStore(),
          ),
        ),
        cloudProfileCacheProvider.overrideWithValue(CloudProfileCache(prefs)),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'fixture-token',
            userId: _account,
            deviceId: 'fixture-device',
          ),
        );
    actions = container.read(dataLifecycleProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 正常仓储入口创建本地账本、占位成员和带 AA 引用的历史发生，再原子转云。
  Future<({String ledger, String member, String rule, String tx})>
  promotedHistory() async {
    final ledger = await repo.createLedger(
      name: '发送链路验收',
      storageMode: 'local',
      localSelfId: 'fixture-local-self',
    );
    final member = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '同行人',
    );
    final rule = await repo.addRecurringTransaction(
      ledgerId: ledger,
      type: 'expense',
      amount: '10',
      frequency: 'daily',
      interval: 1,
      startDate: day,
      timeZone: 'UTC',
    );
    final recurring = (await repo.getRecurringTransactionsByLedger(
      ledger,
    )).single;
    final tx = await repo.generateRecurringTransaction(
      recurring: recurring,
      happenedAt: day,
    );
    await repo.updateTransaction(
      id: tx,
      type: 'expense',
      amount: '10',
      note: '原始历史',
      aaMode: 2,
      payerMemberId: member,
      splits: [TransactionSplitInput(memberId: member, amount: '10')],
    );
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    return (ledger: ledger, member: member, rule: rule, tx: tx);
  }

  /// 按每条请求返回对应 mutation 回执，不预设生产拆包的请求数量。
  Response<sdk.PostSyncPush200Response> accepted(
    sdk.PostSyncPushRequest request,
  ) => Response(
    requestOptions: RequestOptions(path: '/api/v1/sync/push'),
    data: acknowledgeSyncRequest(request),
  );

  test('实际发送先创建成员再初始化规则再上传发生，同一交易后继修改遵守FIFO', () async {
    final seeded = await promotedHistory();
    await repo.updateTransaction(
      id: seeded.tx,
      type: 'expense',
      amount: '10',
      note: '后继人工编辑',
    );
    final queued =
        await (db.select(db.syncChanges)
              ..where(
                (row) =>
                    row.entityType.equals('transaction') &
                    row.entityId.equals(seeded.tx),
              )
              ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
            .get();
    expect(queued, hasLength(2));
    final sent = <Map<String, dynamic>>[];
    final knownMembers = <String>{};
    final knownRules = <String>{};
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as sdk.PostSyncPushRequest;
      final changes = syncRequestChanges(request);
      expect(
        changes.map((row) => (row['entity_type'], row['entity_id'])).toSet(),
        hasLength(changes.length),
        reason: '同实体的两个版本不能在一个请求里并发越过回执',
      );
      for (final change in changes) {
        final payload = change['payload'] as Map;
        if (change['entity_type'] == 'member') {
          knownMembers.add(change['entity_id'] as String);
        }
        if (change['entity_type'] == 'recurring_transaction') {
          expect(knownMembers, contains(seeded.member));
          final initial = payload['initial_state'] as Map;
          final occurrence = (initial['occurrences'] as List).single as Map;
          expect(
            (occurrence['payload'] as Map)['payer_member_id'],
            seeded.member,
          );
          knownRules.add(change['entity_id'] as String);
        }
        if (change['entity_type'] == 'transaction') {
          expect(knownRules, contains(seeded.rule));
        }
        sent.add(change);
      }
      return accepted(request);
    });
    await service.push();
    expect(sent.first['entity_type'], 'ledger');
    final transactionChanges = sent
        .where((row) => row['entity_id'] == seeded.tx)
        .toList();
    expect(
      transactionChanges.map((row) => row['mutation_id']),
      queued.map((row) => row.mutationId),
    );
    expect(transactionChanges.map((row) => (row['payload'] as Map)['note']), [
      '原始历史',
      '后继人工编辑',
    ]);
    expect(transactionChanges.last['base_revision'], 1);
    expect(
      (await db.select(db.syncChanges).get()).every(
        (row) => row.pushedAt != null,
      ),
      isTrue,
    );
  });

  test('两规则各5001个历史按规则拆包，后包回执丢失只原文重试未确认包', () async {
    final ledger = await repo.createLedger(
      name: '大历史分包',
      storageMode: 'local',
      localSelfId: 'fixture-local-self',
    );
    final member = await repo.createPlaceholderMember(
      ledgerId: ledger,
      name: '历史成员',
    );
    final start = DateTime.utc(1990, 1, 1);
    final last = start.add(const Duration(days: 5000));
    final ids = <String>[];
    for (var index = 0; index < 2; index++) {
      ids.add(
        await repo.addRecurringTransaction(
          ledgerId: ledger,
          type: 'expense',
          amount: '1',
          frequency: 'daily',
          interval: 1,
          startDate: start,
          timeZone: 'UTC',
        ),
      );
    }
    // 大批记录仍是真实本地行。墓碑只通过 initial_state 传输，避免额外 live 交易掩盖拆包边界。
    await db.batch(
      (batch) => batch.insertAll(db.transactions, [
        for (final rule in ids)
          for (var index = 0; index < 5001; index++)
            TransactionsCompanion.insert(
              id: recurringOccurrenceId(
                ledger,
                rule,
                recurringDateKey(start.add(Duration(days: index))),
              ),
              ledgerId: ledger,
              txType: 'expense',
              amount: '1',
              nativeAmount: '1',
              currencyCode: 'CNY',
              happenedAt: start.add(Duration(days: index)),
              createdAt: start,
              updatedAt: DateTime.utc(2020),
              deletedAt: d.Value(DateTime.utc(2020)),
              recurringId: d.Value(rule),
              occurrenceDate: d.Value(
                recurringDateKey(start.add(Duration(days: index))),
              ),
              payerMemberId: d.Value(member),
            ),
      ]),
    );
    await (db.update(
      db.recurringTransactions,
    )..where((row) => row.ledgerId.equals(ledger))).write(
      RecurringTransactionsCompanion(lastGeneratedDate: d.Value(last)),
    );
    final expectedIds = (await db.select(db.transactions).get())
        .map((row) => row.id)
        .toSet();
    await actions.promoteLocal(SyncTarget('ledger', ledger));
    expect(await db.select(db.syncChanges).get(), hasLength(4));
    final initialAttempts = <Map<String, dynamic>>[];
    final payloadByRule = <String, Map<String, dynamic>>{};
    var dropped = false;
    String? failedWire;
    String? failedRule;
    final successfulMembers = <String>{};
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as sdk.PostSyncPushRequest;
      final changes = syncRequestChanges(request);
      var occurrencesInRequest = 0;
      final initials = <Map<String, dynamic>>[];
      for (final change in changes) {
        final payload = change['payload'] as Map;
        if (change['entity_type'] == 'member') {
          successfulMembers.add(change['entity_id'] as String);
        }
        final state = payload['initial_state'];
        if (state is Map) {
          expect(successfulMembers, contains(member));
          final occurrences = state['occurrences'] as List;
          expect(occurrences, hasLength(5001), reason: '不得截断或拆散一条规则的初始化事务');
          occurrencesInRequest += occurrences.length;
          expect(state['last_generated_date'], last.toIso8601String());
          expect(
            occurrences.every((value) => (value as Map)['deleted_at'] != null),
            isTrue,
          );
          initials.add(change);
          initialAttempts.add(change);
          payloadByRule.putIfAbsent(
            change['entity_id'] as String,
            () => change,
          );
        }
      }
      expect(occurrencesInRequest, lessThanOrEqualTo(10000));
      if (initials.isNotEmpty && payloadByRule.length == 2 && !dropped) {
        dropped = true;
        failedWire = _wire(request);
        failedRule = initials.single['entity_id'] as String;
        throw DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          type: DioExceptionType.connectionError,
          error: '测试模拟回执丢失',
        );
      }
      if (initials.any((change) => change['entity_id'] == failedRule)) {
        expect(_wire(request), failedWire);
      }
      return accepted(request);
    });
    await expectLater(service.push(), throwsA(isA<DioException>()));
    expect(dropped, isTrue);
    final stillPending = await (db.select(
      db.syncChanges,
    )..where((row) => row.pushedAt.isNull())).get();
    expect(stillPending, hasLength(1));
    expect(stillPending.single.entityId, failedRule);
    expect(stillPending.single.frozenRequest, isNotNull);
    final frozen = stillPending.single.frozenRequest;
    expect(jsonDecode(frozen!)['mutation_id'], stillPending.single.mutationId);
    await service.push();
    expect(initialAttempts, hasLength(3));
    expect(
      initialAttempts.where((row) => row['entity_id'] == failedRule),
      hasLength(2),
    );
    final firstId = ids.singleWhere((id) => id != failedRule);
    expect(
      initialAttempts.where((row) => row['entity_id'] == firstId),
      hasLength(1),
    );
    final uploadedIds = payloadByRule.values
        .expand(
          (change) =>
              (((change['payload'] as Map)['initial_state']
                          as Map)['occurrences']
                      as List)
                  .map((occurrence) => (occurrence as Map)['id'] as String),
        )
        .toSet();
    expect(uploadedIds, expectedIds);
    expect(uploadedIds, hasLength(10002));
    expect(
      (await db.select(db.syncChanges).get()).every(
        (row) => row.pushedAt != null,
      ),
      isTrue,
    );
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('初始化结果未知期间编辑规则和发生，冻结请求原文重试且后继版本等待确认', () async {
    final seeded = await promotedHistory();
    String? failedWire;
    var drop = true;
    final requests = <List<Map<String, dynamic>>>[];
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as sdk.PostSyncPushRequest;
      final changes = syncRequestChanges(request);
      requests.add(changes);
      final bootstrap = changes.any(
        (row) => (row['payload'] as Map).containsKey('initial_state'),
      );
      if (bootstrap && drop) {
        drop = false;
        failedWire = _wire(request);
        throw DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          type: DioExceptionType.connectionError,
          error: '测试模拟结果未知',
        );
      }
      if (bootstrap) {
        expect(_wire(request), failedWire);
      }
      return accepted(request);
    });
    await expectLater(service.push(), throwsA(isA<DioException>()));
    final original = await (db.select(
      db.syncChanges,
    )..where((row) => row.pushedAt.isNull())).get();
    expect(
      original.where((row) => row.entityId == seeded.rule).single.frozenRequest,
      isNotNull,
    );
    await repo.toggleRecurringTransaction(seeded.rule, false);
    await repo.updateTransaction(
      id: seeded.tx,
      type: 'expense',
      amount: '10',
      note: '在途后继编辑',
    );
    for (final old in original) {
      final current = await (db.select(
        db.syncChanges,
      )..where((row) => row.id.equals(old.id))).getSingle();
      expect(current.mutationId, old.mutationId);
      expect(current.frozenRequest, old.frozenRequest);
      expect(current.payload, old.payload);
    }
    final beforeRetry = requests.length;
    await service.push();
    final retried = requests
        .skip(beforeRetry)
        .expand((batch) => batch)
        .toList();
    for (final entity in [seeded.rule, seeded.tx]) {
      final sent = retried.where((row) => row['entity_id'] == entity).toList();
      expect(sent, hasLength(2));
      final first = original.singleWhere((row) => row.entityId == entity);
      expect(sent.first['mutation_id'], first.mutationId);
      expect(sent.last['mutation_id'], isNot(first.mutationId));
    }
    final ruleChanges = retried
        .where((row) => row['entity_id'] == seeded.rule)
        .toList();
    expect(
      (ruleChanges.first['payload'] as Map).containsKey('initial_state'),
      isTrue,
    );
    expect(
      (ruleChanges.last['payload'] as Map).containsKey('initial_state'),
      isFalse,
    );
    expect((ruleChanges.last['payload'] as Map)['enabled'], isFalse);
    final txChanges = retried
        .where((row) => row['entity_id'] == seeded.tx)
        .toList();
    expect((txChanges.last['payload'] as Map)['note'], '在途后继编辑');
    expect(txChanges.last['base_revision'], 1);
    expect(
      (await db.select(db.syncChanges).get()).every(
        (row) => row.pushedAt != null,
      ),
      isTrue,
    );
  });
}
