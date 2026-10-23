import '../helpers/sync_response.dart';
import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import '../helpers/test_isolation.dart';

class MockSyncApi extends Mock implements SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late MockSyncApi api;
  late SesameApiClient client;

  setUp(() {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = MockSyncApi();
    client = SesameApiClient(basePathOverride: 'http://test.local');
    registerFallbackValue(
      PostSyncPushRequest(
        (b) => b
          ..deviceId = 'dummy'
          ..changes = BuiltList<PostSyncPushRequestChangesInner>(
            [],
          ).toBuilder(),
      ),
    );
  });

  tearDown(() async => db.close());

  SyncService buildService() {
    return SyncService(
      client: client,
      db: db,
      deviceId: 'device-1',
      apiOverride: api,
      currentAccountIdGetter: () => 'user-a',
    );
  }

  test('push 信封 updated_at 恒为契约 3 位毫秒格式', () async {
    const ledgerId = 'b27e759f-c9eb-49c4-b9f7-fdfcd95c6235';
    const syncId = '32479a53-fbb4-4155-9865-850aa191dcd4';
    // 微秒非零的真实时钟在 SQLite 往返后，包络仍须使用三位毫秒。
    final now = DateTime.utc(2026, 9, 5, 8, 0, 0, 123, 456);

    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '测试账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
            syncId: const d.Value(syncId),
            updatedAt: now,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'ledger',
            entityId: ledgerId,
            ledgerId: const d.Value(ledgerId),
            action: 'delete',
            payload: jsonEncode({
              'id': ledgerId,
              'updated_at': now.toIso8601String(),
            }),
            updatedAt: now,
            mutationId: 'm-ledger-del-1',
            accountId: const d.Value('user-a'),
          ),
        );

    PostSyncPushRequest? captured;
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      captured =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(captured!),
      );
    });

    await buildService().push();

    expect(captured, isNotNull);
    final json = jsonEncode(
      standardSerializers.serialize(
        captured!,
        specifiedType: const FullType(PostSyncPushRequest),
      ),
    );
    final timestamps = RegExp(
      r'\d{4}-\d{2}-\d{2}T[\d:.]+Z',
    ).allMatches(json).map((m) => m.group(0)).toList();
    expect(timestamps, isNotEmpty, reason: '推送请求应包含 updated_at 时间');
    final contract = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$');
    for (final ts in timestamps) {
      expect(ts, matches(contract), reason: '信封时间必须为 3 位毫秒: $ts');
    }
  });

  for (final rawTime in [null, '2026-09-05T08:00:00.123+08:00']) {
    test('删除正文时间为 $rawTime 时仍使用队列 UTC 毫秒，原身份和本地快照不变', () async {
      try {
        const ledgerId = 'b27e759f-c9eb-49c4-b9f7-fdfcd95c6235';
        final updatedAt = DateTime.utc(2026, 9, 5, 8, 0, 0, 123, 456);
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: ledgerId,
                name: '时间验证账本',
                storageMode: const d.Value('cloud'),
                scopeAccountId: const d.Value('user-a'),
                ownerAccountId: const d.Value('user-a'),
                syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
                updatedAt: updatedAt,
              ),
            );
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'ledger',
                entityId: ledgerId,
                ledgerId: const d.Value(ledgerId),
                accountId: const d.Value('user-a'),
                action: 'delete',
                payload: jsonEncode({'id': ledgerId, 'updated_at': ?rawTime}),
                updatedAt: updatedAt,
                mutationId: 'invalid-time-delete',
              ),
            );
        final before = await db.select(db.syncChanges).getSingle();
        final sent = <Map<String, dynamic>>[];
        when(
          () => api.postSyncPush(
            postSyncPushRequest: any(named: 'postSyncPushRequest'),
          ),
        ).thenAnswer((call) async {
          final request =
              call.namedArguments[#postSyncPushRequest] as PostSyncPushRequest;
          sent.addAll(syncRequestChanges(request));
          // 回执尚未到达时，冻结传输只能读取原快照，不能改写正文或编辑意图。
          final atSend = await (db.select(
            db.syncChanges,
          )..where((row) => row.id.equals(before.id))).getSingle();
          expect(atSend.payload, before.payload);
          expect(atSend.mutationId, before.mutationId);
          expect(atSend.updatedAt, before.updatedAt);
          expect(atSend.frozenRequest, isNotNull);
          return Response(
            requestOptions: RequestOptions(path: '/sync/push'),
            statusCode: 200,
            data: acknowledgeSyncRequest(request),
          );
        });
        await buildService().push();
        final request = sent.single;
        expect(request['entity_type'], 'ledger');
        expect(request['entity_id'], before.entityId);
        expect(request['mutation_id'], before.mutationId);
        expect(request['action'], 'delete');
        expect(request['payload'], isEmpty);
        expect(request['updated_at'], '2026-09-05T08:00:00.123Z');
        final after = await db.select(db.syncChanges).getSingle();
        expect(after.entityId, before.entityId);
        expect(after.mutationId, before.mutationId);
        expect(after.payload, '{}');
        expect(after.updatedAt, before.updatedAt);
        expect(
          after.updatedAt.millisecondsSinceEpoch,
          updatedAt.millisecondsSinceEpoch,
        );
        expect(after.updatedAt.microsecond, 0);
        expect(after.pushedAt, isNotNull);
        verify(
          () => api.postSyncPush(
            postSyncPushRequest: any(named: 'postSyncPushRequest'),
          ),
        ).called(1);
      } catch (error, stack) {
        logger.error(
          'WireTimestampTest',
          '正文时间独立于队列的删除回归失败',
          safeErrorSummary(error),
          stack,
        );
        rethrow;
      }
    });
  }

  for (final explicitTime in [false, true]) {
    test('远端账本墓碑保留协议时间，正文显式时间：$explicitTime', () async {
      const ledgerId = 'b27e759f-c9eb-49c4-b9f7-fdfcd95c6235';
      final eventTime = DateTime.utc(2026, 9, 1, 12);
      final deletionTime = explicitTime
          ? eventTime.subtract(const Duration(minutes: 1))
          : eventTime;
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: '远端删除时间',
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('user-a'),
              ownerAccountId: const d.Value('user-a'),
              syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
              updatedAt: eventTime.subtract(const Duration(days: 1)),
            ),
          );
      when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          statusCode: 200,
          data: standardSerializers.deserializeWith(
            GetSyncPull200Response.serializer,
            {
              'server_cursor': '1',
              'has_more': false,
              'changes': [
                {
                  'change_id': '1',
                  'ledger_id': ledgerId,
                  'day_book_id': null,
                  'memo_book_id': null,
                  'fitness_space_id': null,
                  'entity_type': 'ledger',
                  'entity_id': ledgerId,
                  'action': 'delete',
                  'mutation_id': 'remote-delete',
                  'payload': {
                    'owner_id': 'user-a',
                    if (explicitTime)
                      'deleted_at': deletionTime.toIso8601String(),
                  },
                  'updated_at': eventTime.toIso8601String(),
                  'device_id': 'remote-device',
                },
              ],
            },
          ),
        ),
      );
      await buildService().pull();
      final row = await (db.select(
        db.ledgers,
      )..where((row) => row.id.equals(ledgerId))).getSingle();
      expect(row.deletedAt?.toUtc(), deletionTime);
    });
  }
}
