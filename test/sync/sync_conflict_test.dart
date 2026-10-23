import '../helpers/sync_response.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// 仅响应分类候选查询，确保真实生成客户端完成解码且测试不访问网络。
class _EmptyCategoryConflictsAdapter implements HttpClientAdapter {
  int requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.method != 'GET' ||
        options.path != '/api/v1/category-conflicts') {
      throw StateError('Unexpected request: ${options.method} ${options.path}');
    }
    requests++;
    return ResponseBody.fromString(
      jsonEncode({'items': [], 'next_cursor': null, 'has_more': false}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void _registerPushFallback() {
  registerFallbackValue(
    PostSyncPushRequest(
      (b) => b
        ..deviceId = 'dummy'
        ..changes = BuiltList<PostSyncPushRequestChangesInner>([
          PostSyncPushRequestChangesInner(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2>(
                value: PostSyncPushRequestChangesInnerAnyOf2(
                  (b) => b
                    ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf2AnyOf>(
                      value: PostSyncPushRequestChangesInnerAnyOf2AnyOf(
                        (b) => b
                          ..mutationId = 'm'
                          ..entityType =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfEntityTypeEnum
                                  .ledger
                          ..entityId = 'x'
                          ..ledgerId = 'x'
                          ..action =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfActionEnum
                                  .upsert
                          ..updatedAt = DateTime.now()
                          ..payload =
                              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
                                (b) => b
                                  ..name = 'x'
                                  ..currency = 'CNY'
                                  ..monthStartDay = 1
                                  ..aaEnabled = false,
                              ).toBuilder(),
                      ),
                    ),
                ),
              ),
          ),
        ]).toBuilder(),
    ),
  );
}

/// 构造 pull 事件 payload（builder 字段类型为 MapBuilder）。
MapBuilder<String, JsonObject?> _eventPayload(Map<String, Object?> data) =>
    MapBuilder<String, JsonObject?>({
      // JsonObject 不能包装 null：可空值直接以 null 表达
      for (final e in data.entries)
        e.key: e.value == null ? null : JsonObject(e.value),
    });

PostSyncPush200ResponseOutcomesInner _outcome(
  String mutationId,
  PostSyncPush200ResponseOutcomesInnerStatusEnum status, {
  int? revision,
  int? currentRevision,
  bool currentDeleted = false,
  String? message,
}) => PostSyncPush200ResponseOutcomesInner(
  (b) => b
    ..mutationId = mutationId
    ..entityId = 'tx-1'
    ..status = status
    ..changeId = revision == null ? null : '10'
    ..revision = revision
    ..currentRevision = currentRevision
    ..currentDeleted = currentDeleted
    ..message = message
    ..currentEntity =
        status == PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict
        ? JsonObject({'note': '云端版本'})
        : null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_registerPushFallback);

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late SyncService service;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    mockApi = _MockSyncApi();
    final client = SesameApiClient();
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'account',
    );
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
      accountIdGetter: () => 'account',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> seedCloudTx({int? serverRevision}) async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    // createLedger 已落账本行，这里补写同步身份（避免重复插入主键冲突）；
    // 并清理账本自身登记的 change（模拟已绑定账本：只有交易变更待推）
    await (db.update(db.ledgers)..where((t) => t.id.equals(ledgerId))).write(
      LedgersCompanion(syncId: d.Value('S1')),
    );
    await (db.delete(
      db.syncChanges,
    )..where((c) => c.entityId.equals(ledgerId))).go();
    // 用仓储创建交易（登记 pending change）
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    if (serverRevision != null) {
      await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
        TransactionsCompanion(serverRevision: d.Value(serverRevision)),
      );
    }
    return txId;
  }

  test('invalid 保留可修复数据和脱敏拒绝原因，同步结果不能成功且不自动重试', () async {
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
      accountIdGetter: () => 'account',
    );
    final txId = await seedCloudTx();
    final pending = await db.select(db.syncChanges).getSingle();
    final conflicts = _EmptyCategoryConflictsAdapter();
    final client = SesameApiClient(dio: Dio()..httpClientAdapter = conflicts);
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'account',
    );
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              pending.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid,
              message: 'private-note token=secret account@example.com',
            ),
          ],
        ),
        statusCode: 200,
      ),
    );
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = ListBuilder<GetSyncPull200ResponseChangesInner>()
            ..serverCursor = '100'
            ..hasMore = false,
        ),
        statusCode: 200,
      ),
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 't',
            userId: 'account',
            deviceId: 'dev-1',
          ),
        );

    final result = await container.read(syncCoordinatorProvider).run();

    expect(result.ok, isFalse, reason: '服务端拒绝的交易不能归为同步完成');
    expect(result.error, contains('未上传'));
    expect(conflicts.requests, 1);
    final rejected = await db.select(db.syncChanges).getSingle();
    expect(rejected.pushedAt, isNull);
    final stored = await db
        .customSelect('SELECT rejection_reason FROM sync_changes')
        .getSingle();
    expect(stored.read<String>('rejection_reason'), isNotEmpty);
    expect(stored.read<String>('rejection_reason'), isNot(contains('secret')));
    expect(
      stored.read<String>('rejection_reason'),
      isNot(contains('private-note')),
    );
    expect(
      stored.read<String>('rejection_reason'),
      isNot(contains('account@example.com')),
    );
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.amount, '10');
    expect(tx.deletedAt, isNull);
    expect(
      (await container.read(
        ledgerSyncRejectionsProvider(pending.ledgerId!).future,
      )),
      isNotEmpty,
    );
    final retry = await container.read(syncCoordinatorProvider).run();
    expect(retry.ok, isFalse);
    expect(retry.error, contains('未上传'));
    expect(conflicts.requests, 2);
    verify(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).called(1);
  });

  test('invalid 后修正交易重新登记新 mutation，基于实际服务端 revision 上传', () async {
    final txId = await seedCloudTx(serverRevision: 4);
    // 服务端已有 revision=4，本次被拒绝的是其后的编辑。
    await db
        .update(db.syncChanges)
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now())));
    await repo.updateTransaction(id: txId, type: 'expense', amount: '20');
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).getSingle();
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              pending.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid,
              message: '交易分类不存在或不属于账本 Owner',
            ),
          ],
        ),
        statusCode: 200,
      ),
    );
    await service.push();
    expect(
      (await (db.select(
        db.syncChanges,
      )..where((c) => c.id.equals(pending.id))).getSingle()).pushedAt,
      isNull,
    );

    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '30',
      note: '修正内容',
    );

    final repaired = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(repaired, hasLength(1));
    expect(repaired.single.mutationId, isNot(pending.mutationId));
    expect(repaired.single.baseRevision, 4);
    expect(jsonDecode(repaired.single.payload), containsPair('amount', '30'));
    expect(
      await db
          .customSelect(
            'SELECT id FROM sync_changes WHERE rejection_reason IS NOT NULL',
          )
          .get(),
      isEmpty,
    );
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              repaired.single.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted,
              revision: 5,
            ),
          ],
        ),
        statusCode: 200,
      ),
    );
    await service.push();
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
    );
    expect(
      (await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).getSingle()).serverRevision,
      5,
    );
  });

  test('修正拒绝交易只替换本账号队列，不继承其他账号的 FIFO 基线', () async {
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account-A'),
      accountIdGetter: () => 'account-A',
    );
    final txId = await seedCloudTx(serverRevision: 4);
    await db
        .update(db.syncChanges)
        .write(
          const SyncChangesCompanion(
            rejectionReason: d.Value('请检查内容'),
            baseRevision: d.Value(4),
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: txId,
            accountId: const d.Value('account-B'),
            action: 'upsert',
            payload: '{"amount":"99"}',
            updatedAt: DateTime.utc(2026, 9, 6),
            mutationId: 'other-account',
            baseRevision: const d.Value(99),
          ),
        );

    await repo.updateTransaction(id: txId, type: 'expense', amount: '30');

    final own = await (db.select(
      db.syncChanges,
    )..where((c) => c.accountId.equals('account-A'))).getSingle();
    final other = await (db.select(
      db.syncChanges,
    )..where((c) => c.accountId.equals('account-B'))).getSingle();
    expect(own.baseRevision, 4);
    expect(own.rejectionReason, isNull);
    expect(other.mutationId, 'other-account');
    expect(other.baseRevision, 99);
    expect(other.payload, '{"amount":"99"}');
  });

  test('被拒绝的分类遇到远端 LWW 更新时保留本地可修复内容', () async {
    final categoryId = await repo.createCategory(name: '本地分类', kind: 'expense');
    await db
        .update(db.syncChanges)
        .write(const SyncChangesCompanion(rejectionReason: d.Value('请调整分类')));
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              GetSyncPull200ResponseChangesInner(
                (b) => b
                  ..changeId = '120'
                  ..entityId = categoryId
                  ..entityType =
                      GetSyncPull200ResponseChangesInnerEntityTypeEnum.category
                  ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
                  ..mutationId = 'remote-category'
                  ..deviceId = 'remote-device'
                  ..updatedAt = DateTime.utc(2030)
                  ..payload = _eventPayload({
                    'owner_id': 'account',
                    'kind': 'expense',
                    'name': '远端覆盖',
                    'updated_at': '2030-01-01T00:00:00Z',
                  }),
              ),
            ]).toBuilder()
            ..serverCursor = '120'
            ..hasMore = false,
        ),
      ),
    );

    await service.pull();

    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(categoryId))).getSingle();
    expect(category.name, '本地分类');
    final change = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(categoryId))).getSingle();
    expect(change.pushedAt, isNull);
    expect(change.rejectionReason, '请调整分类');
  });

  test('FIFO 链：同实体连续编辑 base 依次递增（create → 1 → 2）', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '20',
      note: '第二次',
    );
    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '30',
      note: '第三次',
    );

    final rows =
        await (db.select(db.syncChanges)
              ..where((c) => c.entityId.equals(txId))
              ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
            .get();
    expect(rows.length, 3);
    // create（无服务端版本）→ null；后续链式 1 → 2
    expect(rows[0].baseRevision, isNull);
    expect(rows[1].baseRevision, 1);
    expect(rows[2].baseRevision, 2);
  });

  test('FIFO 链：已有 server_revision 时 base 从服务端版本起步', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    final txId = await repo.addTransaction(
      ledgerId: ledgerId,
      type: 'expense',
      amount: '10',
      happenedAt: DateTime.utc(2026, 8, 22),
    );
    // 模拟 create 已推送成功（服务端 revision=5），之后编辑的 base 从服务端版本起步
    await (db.update(db.syncChanges)..where((c) => c.entityId.equals(txId)))
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())));
    await (db.update(db.transactions)..where((t) => t.id.equals(txId))).write(
      TransactionsCompanion(serverRevision: d.Value(5)),
    );
    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '20',
      note: '改',
    );
    final rows = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(txId))).get();
    final latest = rows.reduce((a, b) => a.id > b.id ? a : b);
    expect(latest.baseRevision, 5);
  });

  test('push conflict：SyncConflict 落库（OPEN）+ pending 保留不标记推送', () async {
    final txId = await seedCloudTx(serverRevision: 1);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(pending.length, 1);
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              pending.single.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict,
              currentRevision: 3,
            ),
          ],
        ),
        statusCode: 200,
      ),
    );

    await service.push();

    // 冲突落库：OPEN + 双方 payload + revision
    final conflicts = await db.select(db.syncConflicts).get();
    expect(conflicts.length, 1);
    expect(conflicts.single.status, 'OPEN');
    expect(conflicts.single.entityId, txId);
    // create 语义的 base 为 null，数据库 NOT NULL 归一为 0
    expect(conflicts.single.baseRevision, 0);
    expect(conflicts.single.remoteRevision, 3);
    expect(
      jsonDecode(conflicts.single.remotePayload),
      containsPair('note', '云端版本'),
    );
    // pending 保留：不标记 pushedAt（解决后重推）
    final after = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(after.length, 1);
  });

  test('有 OPEN 冲突的实体整组暂停推送（前序冲突后序不发送）', () async {
    final txId = await seedCloudTx(serverRevision: 1);
    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '20',
      note: '后续编辑',
    );
    // 预置 OPEN 冲突
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'c1',
            accountId: d.Value('account'),
            ledgerId: d.Value('led-1'),
            entityType: 'transaction',
            entityId: txId,
            localPayload: '{}',
            remotePayload: '{}',
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'm1',
          ),
        );
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [],
        ),
        statusCode: 200,
      ),
    );

    await service.push();

    // 该实体的 pending 全部未发送（mock 未收到任何请求）
    verifyNever(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    );
  });

  for (final hasOpenConflict in [false, true]) {
    test('两条 FIFO pending 遇到远端更新保留本地并建立或更新冲突：OPEN=$hasOpenConflict', () async {
      final txId = await seedCloudTx(serverRevision: 1);
      await repo.updateTransaction(
        id: txId,
        type: 'expense',
        amount: '20',
        note: '本地可修复数据',
      );
      final pending =
          await (db.select(db.syncChanges)
                ..where((c) => c.entityId.equals(txId))
                ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
              .get();
      expect(pending, hasLength(2));
      if (hasOpenConflict) {
        await db
            .into(db.syncConflicts)
            .insert(
              SyncConflictsCompanion.insert(
                id: 'existing-conflict',
                accountId: d.Value('account'),
                ledgerId: d.Value(pending.first.ledgerId!),
                entityType: 'transaction',
                entityId: txId,
                localPayload: pending.last.payload,
                remotePayload: '{}',
                baseRevision: 0,
                remoteRevision: 2,
                localMutationId: pending.first.mutationId,
              ),
            );
        await service.push();
        verifyNever(
          () => mockApi.postSyncPush(
            postSyncPushRequest: any(named: 'postSyncPushRequest'),
          ),
        );
      }
      when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
        (invocation) async => Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          statusCode: 200,
          data: GetSyncPull200Response(
            (b) => b
              ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
                GetSyncPull200ResponseChangesInner(
                  (b) => b
                    ..changeId = '80'
                    ..ledgerId = pending.first.ledgerId
                    ..entityType =
                        GetSyncPull200ResponseChangesInnerEntityTypeEnum
                            .transaction
                    ..entityId = txId
                    ..action =
                        GetSyncPull200ResponseChangesInnerActionEnum.upsert
                    ..mutationId = 'remote-new'
                    ..payload = _eventPayload({
                      'id': txId,
                      'ledger_id': pending.first.ledgerId,
                      'tx_type': 'expense',
                      'amount': '99',
                      'native_amount': '99',
                      'currency_code': 'CNY',
                      'happened_at': '2026-08-23T00:00:00.000Z',
                      'created_at': '2026-08-22T00:00:00.000Z',
                      'updated_at': '2026-08-23T00:00:00.000Z',
                      'aa_mode': null,
                      'splits': <Object>[],
                      'revision': 3,
                    })
                    ..updatedAt = DateTime.utc(2026, 8, 23)
                    ..deviceId = 'remote-device',
                ),
              ]).toBuilder()
              ..serverCursor = '80'
              ..hasMore = false,
          ),
        ),
      );

      await service.pull();

      expect(await db.select(db.syncPullErrors).get(), isEmpty);
      final conflicts = await db.select(db.syncConflicts).get();
      expect(conflicts, hasLength(1));
      expect(conflicts.single.status, 'OPEN');
      expect(conflicts.single.remoteRevision, 3);
      expect(
        jsonDecode(conflicts.single.localPayload),
        containsPair('amount', '20'),
      );
      final tx = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(txId))).getSingle();
      expect(tx.amount, '20');
      expect(tx.serverRevision, 1);
      final retained = await (db.select(
        db.syncChanges,
      )..where((c) => c.entityId.equals(txId))).get();
      expect(retained, hasLength(2));
      expect(retained.every((c) => c.pushedAt == null), isTrue);
    });
  }

  test('push accepted：pushedAt 标记 + server_revision 落库', () async {
    final txId = await seedCloudTx(serverRevision: 1);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              pending.single.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted,
              revision: 2,
            ),
          ],
        ),
        statusCode: 200,
      ),
    );

    await service.push();

    final after = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(after, isEmpty);
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.serverRevision, 2);
  });

  test('pull 遇到远端修订超前于 pending 基线 -> 冲突，本地不被覆盖', () async {
    final txId = await seedCloudTx(serverRevision: 1);
    final ledgerId = (await repo.getTransactionById(txId))!.ledgerId;
    // 未确认创建仍在队首，远端 revision=2 已超前于该待确认基线。
    final remoteEventBuilder = GetSyncPull200ResponseChangesInnerBuilder()
      ..changeId = '50'
      ..ledgerId = ledgerId
      ..entityType =
          GetSyncPull200ResponseChangesInnerEntityTypeEnum.transaction
      ..entityId = txId
      ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
      ..mutationId = 'remote-m1'
      ..payload = _eventPayload({
        'id': txId,
        'ledger_id': ledgerId,
        'tx_type': 'expense',
        'amount': '99',
        'happened_at': '2026-08-22T10:00:00.000Z',
        'note': '远端修改',
        'category_id': null,
        'currency_code': 'CNY',
        'native_amount': '99',
        'recurring_id': null,
        'created_by_user_id': null,
        'last_edited_by_user_id': null,
        'paid_by_user_id': null,
        'aa_mode': null,
        'splits': <Object>[],
        'revision': 2,
        'last_edited_at': null,
        'updated_at': '2026-08-22T11:00:00.000Z',
        'created_at': '2026-08-22T11:00:00.000Z',
      })
      ..updatedAt = DateTime.utc(2026, 8, 22, 11)
      ..deviceId = 'remote-dev';
    final remoteEvent = remoteEventBuilder.build();
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              remoteEvent,
            ]).toBuilder()
            ..serverCursor = '50'
            ..hasMore = false,
        ),
        statusCode: 200,
      ),
    );

    await service.pull();

    // 冲突产生，本地金额未被远端覆盖
    final conflicts = await db.select(db.syncConflicts).get();
    expect(conflicts.length, 1);
    expect(conflicts.single.status, 'OPEN');
    expect(conflicts.single.remoteRevision, 2);
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.amount, '10');
    expect(tx.serverRevision, 1);
  });

  test('pull：远端修订不超前于 pending 基线 -> 跳过（不覆盖本地）', () async {
    final txId = await seedCloudTx(serverRevision: 2);
    final ledgerId = (await repo.getTransactionById(txId))!.ledgerId;
    // 模拟 create 已推送成功（服务端 revision=2），随后本地编辑产生 base=2 的 pending
    await (db.update(db.syncChanges)..where((c) => c.entityId.equals(txId)))
        .write(SyncChangesCompanion(pushedAt: d.Value(DateTime.now().toUtc())));
    await repo.updateTransaction(
      id: txId,
      type: 'expense',
      amount: '20',
      note: '本地修改',
    );
    // pending base=2，pull 收到 revision=2 的旧事件 → 跳过
    final remoteEventBuilder = GetSyncPull200ResponseChangesInnerBuilder()
      ..changeId = '60'
      ..ledgerId = ledgerId
      ..entityType =
          GetSyncPull200ResponseChangesInnerEntityTypeEnum.transaction
      ..entityId = txId
      ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
      ..mutationId = 'remote-m2'
      ..payload = _eventPayload({
        'id': txId,
        'ledger_id': ledgerId,
        'tx_type': 'expense',
        'amount': '50',
        'happened_at': '2026-08-22T10:00:00.000Z',
        'note': '旧事件',
        'category_id': null,
        'currency_code': 'CNY',
        'native_amount': '50',
        'recurring_id': null,
        'created_by_user_id': null,
        'last_edited_by_user_id': null,
        'paid_by_user_id': null,
        'aa_mode': null,
        'splits': <Object>[],
        'revision': 2,
        'last_edited_at': null,
        'updated_at': '2026-08-22T11:00:00.000Z',
        'created_at': '2026-08-22T11:00:00.000Z',
      })
      ..updatedAt = DateTime.utc(2026, 8, 22, 11)
      ..deviceId = 'remote-dev';
    final remoteEvent = remoteEventBuilder.build();
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              remoteEvent,
            ]).toBuilder()
            ..serverCursor = '60'
            ..hasMore = false,
        ),
        statusCode: 200,
      ),
    );

    await service.pull();

    expect(await db.select(db.syncConflicts).get(), isEmpty);
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.amount, '20');
  });

  test('STALE_BINDING 账本暂停 push，其他账本继续同步', () async {
    final staleLedgerId = await repo.createLedger(
      name: '旧时间线',
      storageMode: 'cloud',
    );
    final activeLedgerId = await repo.createLedger(
      name: '正常时间线',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(staleLedgerId)))
        .write(const LedgersCompanion(bindingStatus: d.Value('stale')));
    final activeChange = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(activeLedgerId))).getSingle();
    late PostSyncPushRequest sentRequest;
    when(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      sentRequest =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
          overrides: [
            _outcome(
              activeChange.mutationId,
              PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted,
            ),
          ],
        ),
        statusCode: 200,
      );
    });

    await service.push();

    final staleChange = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(staleLedgerId))).getSingle();
    final pushedActiveChange = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(activeLedgerId))).getSingle();
    expect(sentRequest.changes, hasLength(1), reason: 'stale 时间线不得进入网络请求');
    expect(staleChange.pushedAt, isNull, reason: 'stale 时间线的 pending 必须保留');
    expect(pushedActiveChange.pushedAt, isNotNull, reason: '其他账本不得被一起暂停');
  });

  test('STALE_BINDING 账本暂停 pull 应用，其他账本继续收敛', () async {
    final staleLedgerId = await repo.createLedger(
      name: '本地保留',
      storageMode: 'cloud',
    );
    final activeLedgerId = await repo.createLedger(
      name: '本地旧值',
      storageMode: 'cloud',
    );
    await (db.update(db.ledgers)..where((l) => l.id.equals(staleLedgerId)))
        .write(const LedgersCompanion(bindingStatus: d.Value('stale')));

    GetSyncPull200ResponseChangesInner ledgerEvent(String id, String name) =>
        GetSyncPull200ResponseChangesInner(
          (b) => b
            ..changeId = id == staleLedgerId ? '69' : '70'
            ..ledgerId = id
            ..entityType =
                GetSyncPull200ResponseChangesInnerEntityTypeEnum.ledger
            ..entityId = id
            ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
            ..mutationId = 'remote-$id'
            ..payload = _eventPayload({
              'owner_id': 'account',
              'sync_id': '88888888-8888-4888-8888-888888888888',
              'name': name,
              'currency': 'CNY',
              'month_start_day': 1,
              'aa_enabled': false,
              'updated_at': '2026-08-22T12:00:00.000Z',
            })
            ..updatedAt = DateTime.utc(2026, 8, 22, 12)
            ..deviceId = 'remote-dev',
        );
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              ledgerEvent(staleLedgerId, '不应应用'),
              ledgerEvent(activeLedgerId, '云端新值'),
            ]).toBuilder()
            ..serverCursor = '70'
            ..hasMore = false,
        ),
        statusCode: 200,
      ),
    );

    await service.pull();

    final staleLedger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(staleLedgerId))).getSingle();
    final activeLedger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(activeLedgerId))).getSingle();
    expect(staleLedger.name, '本地保留', reason: 'stale 时间线不得应用增量');
    expect(activeLedger.name, '云端新值', reason: '正常时间线必须继续收敛');
  });
}
