import '../helpers/sync_response.dart';
import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _SyncApi extends Mock implements api.SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const ledgerId = '44cef162-c446-44cf-953c-cfa8c9aa355e';
  const accountId = 'account-a';
  final archivedAt = DateTime.utc(2026, 9, 6, 8);
  late SesameDatabase db;
  late _SyncApi remote;
  late SyncService sync;

  /// 构造本人范围的归档事件，账本 ID 位于 payload。
  Map<String, Object?> archiveEvent({bool archived = true, int hour = 8}) => {
    'change_id': '1',
    'ledger_id': null,
    'entity_type': 'ledger_archive',
    'entity_id': ledgerId,
    'action': 'upsert',
    'mutation_id': 'remote-archive',
    'device_id': 'device-b',
    'updated_at': '2026-09-06T${hour.toString().padLeft(2, '0')}:00:00.000Z',
    'payload': {
      'ledger_id': ledgerId,
      'archived_at': archived ? '2026-09-06T08:00:00.000Z' : null,
    },
  };

  /// 下发完整快照，个人状态与公共账本更新时间分别给出。
  void fullResponse({int hour = 8, bool archived = true}) {
    final response = api.standardSerializers.deserializeWith(
      api.GetSyncFull200Response.serializer,
      {
        'ledger': {
          'id': ledgerId,
          'owner_id': accountId,
          'sync_id': 'timeline',
          'name': '云端账本',
          'currency': 'CNY',
          'month_start_day': 1,
          'aa_enabled': false,
          'updated_at': '2026-09-06T07:00:00.000Z',
          'archived_at': archived ? '2026-09-06T08:00:00.000Z' : null,
          'archive_updated_at':
              '2026-09-06T${hour.toString().padLeft(2, '0')}:00:00.000Z',
          'archive_device_id': 'device-b',
        },
        'transactions': [],
        'categories': [],
        'members': [],
        'recurring_transactions': [],
        'exchange_rate_overrides': [],
        'server_cursor': '10',
      },
    );
    when(
      () => remote.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        data: response,
      ),
    );
  }

  /// 将真实协议 JSON 交给生成客户端解析，再由同步服务消费。
  void pullResponse(List<Map<String, Object?>> changes) {
    when(() => remote.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: api.standardSerializers.deserializeWith(
          api.GetSyncPull200Response.serializer,
          {'changes': changes, 'server_cursor': '10', 'has_more': false},
        ),
      ),
    );
  }

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    remote = _SyncApi();
    sync = SyncService(
      client: api.SesameApiClient(),
      db: db,
      deviceId: 'device-a',
      apiOverride: remote,
      currentAccountIdGetter: () => accountId,
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '原账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(accountId),
            ownerAccountId: const d.Value(accountId),
            syncId: const d.Value('timeline'),
            updatedAt: DateTime.utc(2026, 9, 6, 7),
          ),
        );
    registerFallbackValue(
      api.PostSyncPushRequest((b) => b..deviceId = 'device-a'),
    );
  });
  tearDown(() => db.close());

  test('个人归档经私有事件落库，共享元数据更新不取消归档', () async {
    pullResponse([
      archiveEvent(),
      {
        ...archiveEvent(hour: 9),
        'entity_type': 'ledger',
        'ledger_id': ledgerId,
        'payload': {
          'sync_id': 'timeline',
          'owner_id': accountId,
          'name': '其他成员看到的名称',
          'currency': 'CNY',
          'month_start_day': 1,
          'aa_enabled': false,
        },
      },
    ]);
    await sync.pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.archivedAt?.toUtc(), archivedAt);
    expect(ledger.name, '其他成员看到的名称');
    expect(ledger.archiveDeviceId, 'device-b');
  });

  test('full带回本人归档状态，旧快照不能覆盖较新的本地恢复', () async {
    fullResponse();
    await sync.full(ledgerId: ledgerId);
    expect(
      (await db.select(db.ledgers).getSingle()).archivedAt?.toUtc(),
      archivedAt,
    );
    await db
        .update(db.ledgers)
        .write(
          LedgersCompanion(
            archivedAt: const d.Value(null),
            archiveUpdatedAt: d.Value(DateTime.utc(2026, 9, 6, 10)),
            archiveDeviceId: const d.Value('device-a'),
          ),
        );
    await sync.full(ledgerId: ledgerId);
    expect((await db.select(db.ledgers).getSingle()).archivedAt, isNull);
  });

  test('较新的归档恢复事件胜出，较旧事件不能反向覆盖', () async {
    pullResponse([archiveEvent(archived: false, hour: 10), archiveEvent()]);
    await sync.pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.archivedAt, isNull);
    expect(ledger.archiveUpdatedAt?.toUtc(), DateTime.utc(2026, 9, 6, 10));
  });

  test('另一设备按游标顺序接收同设备同秒归档和恢复', () async {
    pullResponse([
      archiveEvent(),
      {...archiveEvent(archived: false), 'change_id': '2'},
    ]);
    await sync.pull();
    expect((await db.select(db.ledgers).getSingle()).archivedAt, isNull);
  });

  for (final state in [
    'deleted',
    'other-account',
    'local',
    'missing',
    'stale',
    'invalid',
  ]) {
    test('归档事件不能恢复或修改不可见账本：$state', () async {
      if (state == 'missing') {
        await db.delete(db.ledgers).go();
      } else {
        await db
            .update(db.ledgers)
            .write(
              LedgersCompanion(
                deletedAt: state == 'deleted'
                    ? d.Value(archivedAt)
                    : const d.Value.absent(),
                scopeAccountId: state == 'other-account'
                    ? const d.Value('account-b')
                    : const d.Value.absent(),
                storageMode: state == 'local'
                    ? const d.Value('local')
                    : const d.Value.absent(),
                bindingStatus: switch (state) {
                  'stale' => const d.Value('stale'),
                  'invalid' => const d.Value('unknown'),
                  _ => const d.Value.absent(),
                },
              ),
            );
      }
      pullResponse([archiveEvent()]);
      await sync.pull();
      final ledger = await db.select(db.ledgers).getSingleOrNull();
      expect(ledger?.archivedAt, isNull);
      if (state == 'missing') expect(ledger, isNull);
      if (state == 'deleted') expect(ledger!.deletedAt?.toUtc(), archivedAt);
    });
  }

  test('归档状态通过现有outbox携带账本绑定推送', () async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger_archive',
            entityId: ledgerId,
            ledgerId: const d.Value(ledgerId),
            action: 'upsert',
            payload: jsonEncode({'archived': true}),
            updatedAt: archivedAt,
            mutationId: 'archive-mutation',
            accountId: const d.Value(accountId),
          ),
        );
    Map<String, dynamic>? request;
    when(
      () => remote.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      request =
          jsonDecode(
                jsonEncode(
                  api.standardSerializers.serialize(
                    invocation.namedArguments[#postSyncPushRequest],
                    specifiedType: const FullType(api.PostSyncPushRequest),
                  ),
                ),
              )
              as Map<String, dynamic>;
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as api.PostSyncPushRequest,
        ),
      );
    });
    await sync.push();
    final change = (request!['changes'] as List).single as Map<String, dynamic>;
    expect(change['entity_type'], 'ledger_archive');
    expect(change['ledger_id'], ledgerId);
    expect(change['sync_id'], 'timeline');
    expect(change['payload'], {'archived': true});
  });

  for (final status in ['accepted', 'ignored']) {
    test('$status归档确认使用权威版本，避免超前时钟永久压住同步', () async {
      if (status == 'ignored') {
        fullResponse(archived: false);
        await sync.full(ledgerId: ledgerId);
      }
      final future = DateTime.utc(2099);
      await db
          .update(db.ledgers)
          .write(
            LedgersCompanion(
              archivedAt: d.Value(future),
              archiveUpdatedAt: d.Value(future),
              archiveDeviceId: const d.Value('device-a'),
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'ledger_archive',
              entityId: ledgerId,
              ledgerId: const d.Value(ledgerId),
              action: 'upsert',
              payload: jsonEncode({'archived': true}),
              updatedAt: future,
              mutationId: 'archive-future',
              accountId: const d.Value(accountId),
            ),
          );
      when(
        () => remote.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: api.standardSerializers.deserializeWith(
            api.PostSyncPush200Response.serializer,
            {
              'server_cursor': '10',
              'outcomes': [
                {
                  'mutation_id': 'archive-future',
                  'entity_id': ledgerId,
                  'status': status,
                  'change_id': null,
                  'current_entity': {
                    'ledger_id': ledgerId,
                    'archived_at': '2026-09-06T08:00:00.000Z',
                    'updated_at': '2026-09-06T08:00:00.000Z',
                    'device_id': 'device-a',
                    'server_cursor': '2',
                  },
                },
              ],
            },
          ),
        ),
      );
      await sync.push();
      final ledger = await db.select(db.ledgers).getSingle();
      expect(ledger.archivedAt?.toUtc(), archivedAt);
      expect(ledger.archiveUpdatedAt?.toUtc(), archivedAt);
      expect(ledger.archiveServerCursor, status == 'ignored' ? '10' : '2');
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
    });
  }

  for (final source in ['full', 'accepted', 'ignored']) {
    test('$source已确认恢复后分页断网，旧的同秒归档不能回退状态', () async {
      final actor = source == 'accepted' ? 'device-a' : 'device-b';
      if (source == 'full') {
        fullResponse(archived: false);
        await sync.full(ledgerId: ledgerId);
      } else {
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'ledger_archive',
                entityId: ledgerId,
                ledgerId: const d.Value(ledgerId),
                action: 'upsert',
                payload: jsonEncode({'archived': false}),
                updatedAt: archivedAt,
                mutationId: 'restore-current',
                accountId: const d.Value(accountId),
              ),
            );
        when(
          () => remote.postSyncPush(
            postSyncPushRequest: any(named: 'postSyncPushRequest'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/sync/push'),
            data: api.standardSerializers.deserializeWith(
              api.PostSyncPush200Response.serializer,
              {
                'server_cursor': '2',
                'outcomes': [
                  {
                    'mutation_id': 'restore-current',
                    'entity_id': ledgerId,
                    'status': source,
                    'change_id': source == 'accepted' ? '2' : null,
                    'current_entity': {
                      'ledger_id': ledgerId,
                      'archived_at': null,
                      'updated_at': '2026-09-06T08:00:00.000Z',
                      'device_id': actor,
                      'server_cursor': '2',
                    },
                  },
                ],
              },
            ),
          ),
        );
        await sync.push();
      }
      expect((await db.select(db.ledgers).getSingle()).archivedAt, isNull);
      when(() => remote.getSyncPull(since: any(named: 'since'))).thenAnswer((
        invocation,
      ) async {
        if (invocation.namedArguments[#since] == '1') {
          throw DioException(
            requestOptions: RequestOptions(path: '/sync/pull'),
            type: DioExceptionType.connectionTimeout,
          );
        }
        return Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          data: api.standardSerializers.deserializeWith(
            api.GetSyncPull200Response.serializer,
            {
              'changes': [
                {...archiveEvent(), 'device_id': actor},
              ],
              'server_cursor': '1',
              'has_more': true,
            },
          ),
        );
      });
      await expectLater(sync.pull(), throwsA(isA<DioException>()));
      verify(() => remote.getSyncPull(since: '1')).called(1);
      expect((await db.select(db.ledgers).getSingle()).archivedAt, isNull);
    });
  }

  test('本人有待上传恢复时，pull和full均保留本地选择且不推进归档游标', () async {
    await db
        .update(db.ledgers)
        .write(
          LedgersCompanion(
            archiveUpdatedAt: d.Value(DateTime.utc(2026, 9, 6, 10)),
            archiveDeviceId: const d.Value('device-a'),
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger_archive',
            entityId: ledgerId,
            ledgerId: const d.Value(ledgerId),
            action: 'upsert',
            payload: jsonEncode({'archived': false}),
            updatedAt: DateTime.utc(2026, 9, 6, 10),
            mutationId: 'pending-restore',
            accountId: const d.Value(accountId),
          ),
        );
    fullResponse(hour: 20);
    await sync.full(ledgerId: ledgerId);
    pullResponse([archiveEvent(hour: 20)]);
    await sync.pull();
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.archivedAt, isNull);
    expect(ledger.archiveUpdatedAt?.toUtc(), DateTime.utc(2026, 9, 6, 10));
    expect(ledger.archiveServerCursor, isNull);
  });

  test('放弃旧云端分支重新绑定时，旧归档时间不能阻止新快照恢复使用', () async {
    await db
        .update(db.ledgers)
        .write(
          LedgersCompanion(
            syncId: const d.Value('old-timeline'),
            bindingStatus: const d.Value('stale'),
            archivedAt: d.Value(DateTime.utc(2026, 9, 7)),
            archiveUpdatedAt: d.Value(DateTime.utc(2026, 9, 7)),
            archiveDeviceId: const d.Value('device-a'),
            archiveServerCursor: const d.Value('999'),
          ),
        );
    fullResponse(archived: false);
    await sync.abandonLocalChanges(ledgerId: ledgerId);
    final ledger = await db.select(db.ledgers).getSingle();
    expect(ledger.archivedAt, isNull);
    expect(ledger.archiveUpdatedAt?.toUtc(), archivedAt);
    expect(ledger.archiveServerCursor, '10');
    expect(ledger.syncId, 'timeline');
    expect(ledger.bindingStatus, isNull);
  });
}
