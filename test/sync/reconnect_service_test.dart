/// Reconnect v1 服务测试。
///
/// - 登录原账号 → 只下载服务器当前状态（full 收敛），绝不重放备份 queue/cursor
///   （本地队列与游标原样保留）；
/// - 本地 Fork 账本（备份恢复产物）绝不被 reconnect 改写/绑定：
///   LOCAL 账本 sync_id 恒 NULL，无隐式 Merge；
/// - 412 SYNC_ID_MISMATCH（服务端 DR 轮换 sync identity）→ STALE_BINDING 标记，
///   经 abandonLocalChanges 重绑（客户端侧）；
/// - 服务端已不存在的账本 → gone 报告，本地行保留不动；
/// - LOCAL_ONLY 账本永不入同步队列。
library;

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/sync/reconnect_service.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Ledger,
        Transaction,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';

import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

class _MockLedgersApi extends Mock implements LedgersApi {}

/// 构造 full 响应（syncId 可配置）。
GetSyncFull200Response _fullResponse(
  String ledgerId,
  String syncId, {
  int serverCursor = 10,
}) {
  return GetSyncFull200Response(
    (b) => b
      ..ledger = GetSyncFull200ResponseLedger(
        (b) => b
          ..id = ledgerId
          ..syncId = syncId
          ..name = '云端账本'
          ..currency = 'CNY'
          ..monthStartDay = 1
          ..aaEnabled = false
          ..updatedAt = DateTime.now().toUtc(),
      ).toBuilder()
      ..transactions = BuiltList<Transaction>().toBuilder()
      ..categories = BuiltList<Category>().toBuilder()
      ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
      ..members = BuiltList<Member>().toBuilder()
      ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
      ..serverCursor = serverCursor.toString(),
  );
}

/// mocktail 需要为不可空参数注册 fallback 值（仅占位，不会被交互）。
void _registerPushFallback() {
  registerFallbackValue(
    PostSyncPushRequest(
      (b) => b
        ..deviceId = 'dummy'
        ..changes = BuiltList<PostSyncPushRequestChangesInner>([
          PostSyncPushRequestChangesInner(
            (b) => b
              ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOf>(
                value: PostSyncPushRequestChangesInnerAnyOf(
                  (b) => b
                    ..anyOf = AnyOf1<PostSyncPushRequestChangesInnerAnyOfAnyOf>(
                      value: PostSyncPushRequestChangesInnerAnyOfAnyOf(
                        (b) => b
                          ..mutationId = 'm'
                          ..entityType =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfEntityTypeEnum
                                  .ledger
                          ..entityId = 'x'
                          ..ledgerId = 'x'
                          ..action =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfActionEnum
                                  .upsert
                          ..updatedAt = DateTime.now()
                          ..payload =
                              PostSyncPushRequestChangesInnerAnyOfAnyOfPayload(
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(_registerPushFallback);

  late SesameDatabase db;
  late _MockSyncApi mockApi;
  late _MockLedgersApi mockLedgersApi;
  late SyncService sync;
  late ReconnectV1Service reconnect;

  setUp(() {
    resetGlobalTestState();
  });

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    mockApi = _MockSyncApi();
    mockLedgersApi = _MockLedgersApi();
    final client = SesameApiClient();
    sync = SyncService(
      client: client,
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
    );
    reconnect = ReconnectV1Service(
      db: db,
      sync: sync,
      ledgersApi: mockLedgersApi,
    );
  });

  tearDown(() async => db.close());

  Future<void> seedCloudLedger(String id, {String? syncId}) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: '云端账本',
            storageMode: const d.Value('cloud'),
            syncId: d.Value(syncId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  Future<void> seedLocalForkLedger(String id) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: '本地副本',
            storageMode: const d.Value('local'),
            syncId: const d.Value(null),
            originType: const d.Value('CLOUD_BACKUP'),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  void mockServerLedgers(List<String> ids) {
    final ledgerList = BuiltList<Ledger>([
      for (final id in ids)
        Ledger(
          (b) => b
            ..id = id
            ..name = '云端账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = false
            ..role = LedgerRoleEnum.owner
            ..memberCount = 1
            ..syncId = 'S-SERVER'
            ..updatedAt = DateTime.now().toUtc(),
        ),
    ]);
    when(() => mockLedgersApi.getLedgers()).thenAnswer(
      (_) async => Response<BuiltList<Ledger>>(
        requestOptions: RequestOptions(path: '/ledgers'),
        data: ledgerList,
        statusCode: 200,
      ),
    );
  }

  void mockFullOk(String ledgerId, String syncId) {
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response<GetSyncFull200Response>(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: _fullResponse(ledgerId, syncId),
        statusCode: 200,
      ),
    );
  }

  void mockFull412(String ledgerId) {
    when(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/full'),
          statusCode: 412,
        ),
      ),
    );
  }

  test('reconnect：云端账本下载服务器最新；本地 Fork 账本绝不被改写', () async {
    // 本地：云端账本（绑定 S100）+ 备份恢复的本地 Fork（同 id 存在于服务器！）
    final cloudId = '11111111-1111-4111-8111-111111111111';
    final forkId = '22222222-2222-4222-8222-222222222222';
    await seedCloudLedger(cloudId, syncId: 'S100');
    await seedLocalForkLedger(forkId);
    // 服务器清单：两个 id 都存在（用户仍有权访问原云端账本）
    mockServerLedgers([cloudId, forkId]);
    mockFullOk(cloudId, 'S100');

    final report = await reconnect.reconnectAfterLogin();

    expect(report.refreshed, contains(cloudId));
    // 本地 Fork 未被 full 下载（无隐式 Merge）
    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: forkId,
        syncId: any(named: 'syncId'),
      ),
    );
    final fork = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(forkId))).getSingle();
    expect(fork.storageMode, 'local');
    expect(fork.syncId, isNull, reason: 'LOCAL 账本 sync_id 恒 NULL');
    expect(fork.bindingStatus, isNull);
  });

  test('reconnect：绝不重放备份 queue/cursor', () async {
    final cloudId = '11111111-1111-4111-8111-111111111111';
    await seedCloudLedger(cloudId, syncId: 'S100');
    mockServerLedgers([cloudId]);
    mockFullOk(cloudId, 'S100');
    // 预置"残留"队列与游标（模拟恢复流程遗留，实际恢复不会产生，此处验证不重放不篡改）
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx-1',
            ledgerId: d.Value(cloudId),
            action: 'upsert',
            payload: '{}',
            updatedAt: DateTime.utc(2026, 8, 22),
            mutationId: 'm-1',
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'dev-1',
            serverCursor: d.Value('42'),
          ),
        );

    await reconnect.reconnectAfterLogin();

    // 队列不被注入/重放：原 1 行不变（reconnect 不读不写 sync_changes）
    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(1));
    // 游标推进到服务器当前值（full 正常语义）——备份游标从未被当作"恢复起点"
    final state = await db.select(db.syncState).getSingleOrNull();
    expect(state?.serverCursor, '10');
    // 不触发 push（只下载）
    verifyNever(
      () => mockApi.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    );
  });

  test('reconnect：412 → STALE_BINDING；abandonLocalChanges 重绑（客户端侧）', () async {
    final cloudId = '11111111-1111-4111-8111-111111111111';
    await seedCloudLedger(cloudId, syncId: 'S1');
    mockServerLedgers([cloudId]);
    mockFull412(cloudId); // 服务端 DR 后 sync identity 已轮换 S1→S2

    final report = await reconnect.reconnectAfterLogin();

    expect(report.stale, contains(cloudId));
    // 客户端标记 STALE_BINDING（同步暂停等待用户决策）
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(cloudId))).getSingle();
    expect(ledger.bindingStatus, 'stale');
    expect(ledger.syncId, 'S1', reason: '本地旧身份保留（不静默覆盖）');

    // 用户决策：放弃本地修改，按服务器当前时间线重绑（S2）
    mockFullOk(cloudId, 'S2');
    await sync.abandonLocalChanges(ledgerId: cloudId);
    final rebound = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(cloudId))).getSingle();
    expect(rebound.syncId, 'S2');
    expect(rebound.bindingStatus, isNull, reason: '重绑后恢复 bound');
  });

  test('reconnect：已是 STALE_BINDING 的账本不重复 full', () async {
    final cloudId = '11111111-1111-4111-8111-111111111111';
    await seedCloudLedger(cloudId, syncId: 'S1');
    await (db.update(db.ledgers)..where((l) => l.id.equals(cloudId))).write(
      const LedgersCompanion(bindingStatus: d.Value('stale')),
    );
    mockServerLedgers([cloudId]);

    final report = await reconnect.reconnectAfterLogin();

    expect(report.stale, contains(cloudId));
    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('reconnect：服务端已不存在的云端账本 → gone 报告，本地行保留', () async {
    final cloudId = '11111111-1111-4111-8111-111111111111';
    await seedCloudLedger(cloudId, syncId: 'S1');
    mockServerLedgers(const []); // 服务器无任何账本

    final report = await reconnect.reconnectAfterLogin();

    expect(report.gone, contains(cloudId));
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(cloudId))).getSingle();
    expect(ledger.storageMode, 'cloud', reason: '本地行保留，由用户决策');
    verifyNever(
      () => mockApi.getSyncFull(
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('LOCAL_ONLY 账本编辑永不入同步队列', () async {
    final repo = LocalLedgerRepository(
      db,
      trackerGetter: () => ChangeRecorderImpl(db),
    );
    // 云端账本 + 本地账本
    final cloudId = '11111111-1111-4111-8111-111111111111';
    await seedCloudLedger(cloudId, syncId: 'S1');
    await seedLocalForkLedger('22222222-2222-4222-8222-222222222222');

    await repo.updateLedger(id: cloudId, name: '云端改名');
    await repo.updateLedger(
      id: '22222222-2222-4222-8222-222222222222',
      name: '本地改名',
    );

    final changes = await db.select(db.syncChanges).get();
    expect(changes, hasLength(1), reason: '只有云端账本登记变更');
    expect(changes.single.ledgerId, cloudId);
  });

  test('恢复出的本地账本编辑后永不入队', () async {
    // 用恢复原语产出的本地账本（origin 溯源）
    final srcDb = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(srcDb.close);
    final srcId = '33333333-3333-4333-8333-333333333333';
    final now = DateTime.utc(2026, 8, 1);
    await srcDb
        .into(srcDb.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: srcId,
            name: '备份里的账本',
            storageMode: const d.Value('local'),
            updatedAt: now,
          ),
        );
    final liveRepo = LocalLedgerRepository(
      db,
      trackerGetter: () => ChangeRecorderImpl(db),
    );
    final restoredId = await liveRepo.restoreLocalLedger(
      sourceLedgerId: srcId,
      targetLedgerId: srcId,
      localSelfId: 'self-1',
      originBackupId: 'backup-1',
      sourceDb: srcDb,
    );
    // 恢复后继续编辑
    await liveRepo.updateLedger(id: restoredId, name: '恢复后改名');
    final changes = await db.select(db.syncChanges).get();
    expect(changes, isEmpty, reason: '恢复出的 LOCAL 账本永不入同步队列');
    final restored = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(restoredId))).getSingle();
    expect(restored.syncId, isNull);
    expect(restored.originType, 'LOCAL_BACKUP');
  });
}
