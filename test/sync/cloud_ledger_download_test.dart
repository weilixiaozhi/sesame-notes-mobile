import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Ledger,
        Transaction,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// 发现事件包含完整账本字段；用户域没有 ledger_id，requires_full 表示另取父子内容快照。
GetSyncPull200ResponseChangesInner _ledgerChange({
  bool requiresFull = true,
  bool userScoped = true,
  String syncId = 'timeline',
}) => GetSyncPull200ResponseChangesInner(
  (b) => b
    ..changeId = '1'
    ..ledgerId = userScoped ? null : 'cloud-ledger'
    ..entityId = 'cloud-ledger'
    ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.ledger
    ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
    ..mutationId = 'remote-discovery'
    ..deviceId = 'remote'
    ..updatedAt = DateTime.utc(2026, 9, 6)
    ..payload = MapBuilder<String, JsonObject?>({
      'id': JsonObject('cloud-ledger'),
      'name': JsonObject('发现事件账本'),
      'owner_id': JsonObject('account-a'),
      'sync_id': JsonObject(syncId),
      'currency': JsonObject('CNY'),
      'month_start_day': JsonObject(1),
      'aa_enabled': JsonObject(false),
      if (requiresFull) 'requires_full': JsonObject(true),
    }),
);

/// 云端空账本也必须经过完整快照，不能用交易笔数判断是否已下载。
GetSyncFull200Response _full() => GetSyncFull200Response(
  (b) => b
    ..ledger = GetSyncFull200ResponseLedger(
      (b) => b
        ..id = 'cloud-ledger'
        ..ownerId = 'account-a'
        ..syncId = 'timeline'
        ..name = '完整账本'
        ..currency = 'CNY'
        ..monthStartDay = 1
        ..aaEnabled = false
        ..updatedAt = DateTime.utc(2026, 9, 6),
    ).toBuilder()
    ..transactions = ListBuilder<Transaction>()
    ..categories = ListBuilder<Category>()
    ..members = ListBuilder<Member>()
    ..recurringTransactions = ListBuilder<RecurringTransaction>()
    ..exchangeRateOverrides = ListBuilder<ExchangeRateOverride>()
    ..serverCursor = '10',
);

/// 账号快照包含与单本下载相同的完整内容，并共享一个账号水位。
GetSyncAccountingFull200Response _accountingFull() {
  final full = _full();
  return GetSyncAccountingFull200Response(
    (b) => b
      ..ledgerSnapshots =
          ListBuilder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>([
            GetSyncAccountingFull200ResponseLedgerSnapshotsInner(
              (b) => b
                ..ledger = full.ledger.toBuilder()
                ..members = full.members.toBuilder()
                ..transactions = full.transactions.toBuilder()
                ..categories = full.categories.toBuilder()
                ..recurringTransactions = full.recurringTransactions.toBuilder()
                ..exchangeRateOverrides = full.exchangeRateOverrides
                    .toBuilder(),
            ),
          ])
      ..categories = ListBuilder<Category>()
      ..exchangeRateOverrides = ListBuilder<ExchangeRateOverride>()
      ..deletedExchangeRateOverrideIds = ListBuilder<String>()
      ..serverCursor = full.serverCursor,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _MockSyncApi api;
  late CloudLedgerDownloadStore store;

  /// 重新构造同步服务，模拟进程恢复后从持久存储读取待下载账本。
  SyncService service() => SyncService(
    client: SesameApiClient(),
    db: db,
    deviceId: 'device',
    apiOverride: api,
    currentAccountIdGetter: () => 'account-a',
    downloadStore: store,
  );

  /// 构造本轮增量响应，空数组表示服务端不再重复下发 requires_full 事件。
  void pullChanges([
    List<GetSyncPull200ResponseChangesInner> changes = const [],
    String cursor = '1',
  ]) {
    when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = ListBuilder(changes)
            ..serverCursor = cursor
            ..hasMore = false,
        ),
      ),
    );
  }

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = _MockSyncApi();
    store = CloudLedgerDownloadStore(SharedPreferences.getInstance);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'cloud-ledger',
            name: '占位账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account-a'),
            ownerAccountId: const d.Value('account-a'),
            updatedAt: DateTime.utc(2026, 9, 6),
          ),
        );
    pullChanges();
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: _full(),
      ),
    );
    when(() => api.getSyncAccountingFull()).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/accounting/full'),
        data: _accountingFull(),
      ),
    );
  });
  tearDown(() => db.close());

  test('持久待下载标记在新服务无新增事件时仍补full，事务成功后解除', () async {
    await store.markPending('account-a', 'cloud-ledger');
    await (await SharedPreferences.getInstance()).reload();
    await service().pull();
    expect(await store.pending('account-a'), isEmpty);
    expect((await db.select(db.ledgers).getSingle()).name, '完整账本');
    verify(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: 'cloud-ledger',
        syncId: null,
      ),
    ).called(1);
  });

  test('首次发现快照失败只留下内部任务，后续无新增事件也可原子发布空本', () async {
    await db.delete(db.ledgers).go();
    pullChanges([_ledgerChange()]);
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        type: DioExceptionType.connectionError,
      ),
    );
    await expectLater(service().pull(), throwsA(isA<DioException>()));
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await store.pending('account-a'), {'cloud-ledger'});
    expect(await store.unpublished('account-a'), {'cloud-ledger'});
    expect(await db.select(db.syncPullErrors).get(), isEmpty);

    pullChanges();
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: _full(),
      ),
    );
    await service().pull();
    expect(await store.pending('account-a'), isEmpty);
    expect(await store.unpublished('account-a'), isEmpty);
    expect((await db.select(db.ledgers).getSingle()).name, '完整账本');
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('普通远端新本先取完整快照，下载在途不发布元数据', () async {
    await db.delete(db.ledgers).go();
    pullChanges([_ledgerChange(requiresFull: false, userScoped: false)]);
    final requested = Completer<void>();
    final response = Completer<GetSyncFull200Response>();
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer((_) async {
      requested.complete();
      return Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: await response.future,
      );
    });
    final pulling = service().pull();
    try {
      await requested.future;
      expect(await db.select(db.ledgers).get(), isEmpty);
      expect(await store.unpublished('account-a'), {'cloud-ledger'});
    } finally {
      response.complete(_full());
      await pulling;
    }
    expect((await db.select(db.ledgers).getSingle()).name, '完整账本');
    expect(await store.pending('account-a'), isEmpty);
  });

  test('已完整下载的空本重新取快照失败时保留原本，只登记后台刷新', () async {
    await service().full(ledgerId: 'cloud-ledger');
    pullChanges([_ledgerChange()]);
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(service().pull(), throwsA(isA<DioException>()));
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.name, '完整账本');
    expect(ledger.syncId, 'timeline');
    expect(await db.select(db.transactions).get(), isEmpty);
    expect(await store.pending('account-a'), {'cloud-ledger'});
    expect(await store.unpublished('account-a'), isEmpty);
    expect(await db.select(db.syncPullErrors).get(), isEmpty);
  });

  test('首次下载任务已有占位行仍保持未发布，失败不更新占位元数据', () async {
    await store.markPending('account-a', 'cloud-ledger');
    pullChanges([_ledgerChange()]);
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/full'),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(service().pull(), throwsA(isA<DioException>()));
    expect(await store.unpublished('account-a'), {'cloud-ledger'});
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.name, '占位账本');
    expect(ledger.syncId, isNull);
  });

  test('新本完整快照的页事务失败时整本不发布，下载任务保留', () async {
    await db.delete(db.ledgers).go();
    pullChanges([_ledgerChange()]);
    await db.customStatement('''
      CREATE TEMP TRIGGER reject_page_cursor BEFORE INSERT ON sync_state
      BEGIN SELECT RAISE(ABORT, 'cursor write failed'); END
    ''');

    await expectLater(service().pull(), throwsA(isA<SqliteException>()));
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await db.select(db.syncState).get(), isEmpty);
    expect(await store.pending('account-a'), {'cloud-ledger'});
    expect(await store.unpublished('account-a'), {'cloud-ledger'});
  });

  test('用户域重新发现旧墓碑时先完整下载再恢复，不仅复活元数据', () async {
    await db
        .update(db.ledgers)
        .write(LedgersCompanion(deletedAt: d.Value(DateTime.utc(2026, 9, 5))));
    pullChanges([_ledgerChange()]);

    await service().pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.deletedAt, isNull);
    expect(ledger.name, '完整账本');
    expect(ledger.syncId, 'timeline');
    expect(await store.pending('account-a'), isEmpty);
    verify(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: 'cloud-ledger',
        syncId: 'timeline',
      ),
    ).called(1);
  });

  test('首次发现携带预期绑定，服务端返回另一时间线时不发布账本', () async {
    await db.delete(db.ledgers).go();
    pullChanges([_ledgerChange(syncId: 'expected-timeline')]);

    await expectLater(service().pull(), throwsFormatException);
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await store.unpublished('account-a'), {'cloud-ledger'});
    expect(await db.select(db.syncPullErrors).get(), hasLength(1));
    verify(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: 'cloud-ledger',
        syncId: 'expected-timeline',
      ),
    ).called(1);
  });

  test('页内旧绑定和已删除条目最终由完整快照覆盖，不复活旧增量', () async {
    const transactionId = '00000000-0000-4000-8000-000000000011';
    const memberId = '00000000-0000-4000-8000-000000000012';
    await service().full(ledgerId: 'cloud-ledger');
    pullChanges([
      _ledgerChange(syncId: 'old-event-binding'),
      _ledgerChange(userScoped: false).rebuild(
        (b) => b
          ..changeId = '2'
          ..entityType =
              GetSyncPull200ResponseChangesInnerEntityTypeEnum.transaction
          ..entityId = transactionId
          ..mutationId = 'old-transaction'
          ..payload = MapBuilder<String, JsonObject?>({
            'id': JsonObject(transactionId),
            'ledger_id': JsonObject('cloud-ledger'),
            'tx_type': JsonObject('expense'),
            'amount': JsonObject('10'),
            'currency_code': JsonObject('CNY'),
            'native_amount': JsonObject('10'),
            'revision': JsonObject(1),
            'splits': JsonObject(<Object>[]),
            'happened_at': JsonObject('2026-09-06T00:00:00.000Z'),
            'created_at': JsonObject('2026-09-06T00:00:00.000Z'),
            'updated_at': JsonObject('2026-09-06T00:00:00.000Z'),
          }),
      ),
      _ledgerChange(userScoped: false).rebuild(
        (b) => b
          ..changeId = '3'
          ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.member
          ..entityId = memberId
          ..mutationId = 'old-member'
          ..payload = MapBuilder<String, JsonObject?>({
            'display_name': JsonObject('已被删除的占位成员'),
            'member_type': JsonObject('PLACEHOLDER'),
            'role': JsonObject('editor'),
            'status': JsonObject('ACTIVE'),
          }),
      ),
      _ledgerChange(userScoped: false).rebuild(
        (b) => b
          ..changeId = '4'
          ..action = GetSyncPull200ResponseChangesInnerActionEnum.delete
          ..mutationId = 'old-ledger-delete'
          ..payload = MapBuilder<String, JsonObject?>({
            'owner_id': JsonObject('account-a'),
            'deleted_at': JsonObject('2026-09-06T00:00:00.000Z'),
          }),
      ),
    ], '4');

    await service().pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.name, '完整账本');
    expect(ledger.syncId, 'timeline');
    expect(ledger.deletedAt, isNull);
    expect((await db.select(db.transactions).getSingle()).deletedAt, isNotNull);
    expect(
      (await db.select(db.ledgerMembers).getSingle()).deletedAt,
      isNotNull,
    );
    expect(await store.pending('account-a'), isEmpty);
    verify(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: 'cloud-ledger',
        syncId: 'timeline',
      ),
    ).called(1);
  });

  test('无发现元数据的内部任务采用当前快照绑定，不需要占位账本', () async {
    await db.delete(db.ledgers).go();
    await store.markPending('account-a', 'cloud-ledger');
    pullChanges();

    await service().pull();
    expect((await db.select(db.ledgers).getSingle()).syncId, 'timeline');
    expect(await store.unpublished('account-a'), isEmpty);
    verify(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: 'cloud-ledger',
        syncId: null,
      ),
    ).called(1);
  });

  for (final statusCode in [408, 429, 500, 503, 400]) {
    test('首次快照$statusCode保留内部任务，只有非暂时错误进入数据处理列表', () async {
      await db.delete(db.ledgers).go();
      pullChanges([_ledgerChange()]);
      when(
        () => api.getSyncFull(
          includeRecurringState: any(named: 'includeRecurringState'),
          ledgerId: any(named: 'ledgerId'),
          syncId: any(named: 'syncId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/sync/full'),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/sync/full'),
            statusCode: statusCode,
          ),
        ),
      );

      await expectLater(service().pull(), throwsA(isA<DioException>()));
      expect(await db.select(db.ledgers).get(), isEmpty);
      expect(await store.unpublished('account-a'), {'cloud-ledger'});
      expect(
        await db.select(db.syncPullErrors).get(),
        hasLength(statusCode == 400 ? 1 : 0),
      );
    });
  }

  test('首次发现412在没有本地行时安全隔离，保留未发布任务', () async {
    await db.delete(db.ledgers).go();
    pullChanges([_ledgerChange()]);
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
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

    await service().pull();
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await store.unpublished('account-a'), {'cloud-ledger'});
  });

  test('用户域刷新遭遇412时保留既有快照并冻结旧绑定，不套用发现元数据', () async {
    await service().full(ledgerId: 'cloud-ledger');
    pullChanges([_ledgerChange()]);
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
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

    await service().pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.name, '完整账本');
    expect(ledger.syncId, 'timeline');
    expect(ledger.bindingStatus, 'stale');
    expect(await store.pending('account-a'), {'cloud-ledger'});
    expect(await store.unpublished('account-a'), isEmpty);
  });

  for (final statusCode in [403, 404]) {
    test('用户域新本发现被$statusCode拒绝时不插入元数据且清理任务', () async {
      await db.delete(db.ledgers).go();
      pullChanges([_ledgerChange()]);
      when(
        () => api.getSyncFull(
          includeRecurringState: any(named: 'includeRecurringState'),
          ledgerId: any(named: 'ledgerId'),
          syncId: any(named: 'syncId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/sync/full'),
          response: Response(
            requestOptions: RequestOptions(path: '/sync/full'),
            statusCode: statusCode,
          ),
        ),
      );

      await service().pull();
      expect(await db.select(db.ledgers).get(), isEmpty);
      expect(await store.pending('account-a'), isEmpty);
      expect(await store.unpublished('account-a'), isEmpty);
    });

    test('待下载账本明确$statusCode撤权后隐藏占位并清任务，不重复请求', () async {
      await store.markPending('account-a', 'cloud-ledger');
      when(
        () => api.getSyncFull(
          includeRecurringState: any(named: 'includeRecurringState'),
          ledgerId: any(named: 'ledgerId'),
          syncId: any(named: 'syncId'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/sync/full'),
          response: Response(
            requestOptions: RequestOptions(path: '/sync/full'),
            statusCode: statusCode,
          ),
        ),
      );
      await service().pull();
      expect(await store.pending('account-a'), isEmpty);
      expect((await db.select(db.ledgers).getSingle()).deletedAt, isNotNull);
      await service().pull();
      verify(
        () => api.getSyncFull(
          includeRecurringState: any(named: 'includeRecurringState'),
          ledgerId: 'cloud-ledger',
          syncId: null,
        ),
      ).called(1);
    });
  }

  test('full写库事务失败保留待下载事实，不发布部分元数据', () async {
    await store.markPending('account-a', 'cloud-ledger');
    await db.customStatement('''
      CREATE TEMP TRIGGER reject_full BEFORE UPDATE ON ledgers
      BEGIN SELECT RAISE(ABORT, 'disk write failed'); END
    ''');
    await expectLater(
      service().full(ledgerId: 'cloud-ledger'),
      throwsA(isA<SqliteException>()),
    );
    expect(await store.pending('account-a'), {'cloud-ledger'});
    expect((await db.select(db.ledgers).getSingle()).name, '占位账本');
  });

  test('账号完整快照提交后解除已下载标记，其他账号标记保持原样', () async {
    await store.markPending('account-a', 'cloud-ledger');
    await store.markPending('account-b', 'cloud-ledger');

    await service().accountingFull();

    expect((await db.select(db.ledgers).getSingle()).name, '完整账本');
    expect((await db.select(db.syncState).getSingle()).serverCursor, '10');
    expect(await store.pending('account-a'), isEmpty);
    expect(await store.pending('account-b'), {'cloud-ledger'});
    verifyNever(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('账号完整快照水位提交失败时回滚内容并保留待下载标记', () async {
    await store.markPending('account-a', 'cloud-ledger');
    // 水位在所有账本写入之后保存，失败必须同时撤销已应用的账本内容。
    await db.customStatement('''
      CREATE TEMP TRIGGER reject_account_cursor BEFORE INSERT ON sync_state
      BEGIN SELECT RAISE(ABORT, 'cursor write failed'); END
    ''');

    await expectLater(
      service().accountingFull(),
      throwsA(isA<SqliteException>()),
    );

    expect((await db.select(db.ledgers).getSingle()).name, '占位账本');
    expect(await db.select(db.syncState).get(), isEmpty);
    expect(await store.pending('account-a'), {'cloud-ledger'});
  });

  for (final state in ['stale', 'local', 'binding-mismatch']) {
    test('账号完整快照跳过$state分支时保留其待下载标记', () async {
      await store.markPending('account-a', 'cloud-ledger');
      await db
          .update(db.ledgers)
          .write(
            LedgersCompanion(
              storageMode: d.Value(state == 'local' ? 'local' : 'cloud'),
              bindingStatus: d.Value(state == 'stale' ? 'stale' : null),
              syncId: d.Value(
                state == 'binding-mismatch' ? 'old-timeline' : null,
              ),
            ),
          );

      await service().accountingFull();

      final ledger = await db.select(db.ledgers).getSingle();
      expect(ledger.name, '占位账本');
      expect(await store.pending('account-a'), {'cloud-ledger'});
      if (state == 'binding-mismatch') {
        expect(ledger.syncId, 'old-timeline');
        expect(ledger.bindingStatus, 'stale');
      }
    });
  }

  test('410恢复账号快照后刷新本轮待下载集合，不重复请求单本快照', () async {
    await store.markPending('account-a', 'cloud-ledger');
    when(() => api.getSyncPull(since: '0')).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/sync/pull'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          statusCode: 410,
        ),
      ),
    );
    when(() => api.getSyncPull(since: '10')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: GetSyncPull200Response(
          (b) => b
            ..changes = ListBuilder<GetSyncPull200ResponseChangesInner>()
            ..serverCursor = '10'
            ..hasMore = false,
        ),
      ),
    );

    expect(await service().pull(), 0);

    expect(await store.pending('account-a'), isEmpty);
    expect((await db.select(db.ledgers).getSingle()).name, '完整账本');
    verify(() => api.getSyncAccountingFull()).called(1);
    verify(() => api.getSyncPull(since: '10')).called(1);
    verifyNever(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });
}
