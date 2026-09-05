/// SyncService.push 信封时间格式契约测试。
///
/// 锚点：服务端 OpenAPI 契约 TIMESTAMP_PATTERN 只接受 3 位毫秒
/// （^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z$）；
/// Dart DateTime.now() 带微秒精度，toIso8601String() 会输出 6 位小数，
/// 直接进信封会被服务端 400 VALIDATION_ERROR 拒绝，导致全部 push 失败。
library;

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

import '../helpers/test_isolation.dart';

class MockSyncApi extends Mock implements SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late MockSyncApi api;
  late SesameApiClient client;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
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
    // 微秒非零的真实时钟精度：修复前序列化为 6 位小数,违反契约
    final now = DateTime.utc(2026, 9, 5, 8, 0, 0, 123, 456);

    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '测试账本',
            storageMode: const d.Value('cloud'),
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
            payload: jsonEncode({'id': ledgerId}),
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
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              [],
            ).toBuilder()
            ..serverCursor = '0',
        ),
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
}
