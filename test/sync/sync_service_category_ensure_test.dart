/// SyncService.push 分类先导登记测试。
///
/// 锚点：云账本交易引用了本地确定性 v5 seed 分类（scopeAccountId 为空）时，
/// push 前必须把该分类登记为 user 级 upsert 变更并排在引用它的变更之前，
/// 否则服务端按序应用时分类不存在，交易被判 invalid 永久丢弃。
library;

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';
import 'package:one_of/any_of.dart';
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

  test('push 前把交易引用的未登记 v5 分类登记为 user 级变更并排在交易之前', () async {
    const categoryId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
    const ledgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6235';
    const txnId = '3c0d0f14-04aa-4c11-bbf8-f0358ab1b9d7';
    final updatedAt = DateTime.utc(2026, 9, 5, 8);

    // 云账本（已绑定同步身份，可同步）
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '可乐',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    // 本地 seed 确定性 v5 分类：从未登记上云（scopeAccountId 为空）
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            sortOrder: const d.Value(0),
            updatedAt: updatedAt,
          ),
        );
    // 待推交易变更：引用该分类
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: txnId,
            ledgerId: const d.Value(ledgerId),
            action: 'upsert',
            payload: jsonEncode({
              'tx_type': 'expense',
              'amount': '10.5',
              'happened_at': '2026-09-05T08:00:00.000Z',
              'note': 'v5 分类交易',
              'category_id': categoryId,
              'exclude_from_stats': false,
              'currency_code': 'CNY',
              'native_amount': '10.5',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-tx-1',
            accountId: const d.Value('user-a'),
          ),
        );

    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              [],
            ).toBuilder()
            ..serverCursor = '0',
        ),
      ),
    );

    await buildService().push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final request = captured.single as PostSyncPushRequest;
    expect(request.changes, hasLength(2), reason: '分类先导变更 + 交易变更');
    // 与真实 HTTP 路径同一序列化器：按 wire JSON 断言批次顺序
    Map<String, dynamic> wireOf(PostSyncPushRequestChangesInner ch) {
      final anyOf = ch.anyOf;
      return client.serializers.serialize(
            anyOf,
            specifiedType: FullType(
              AnyOf,
              anyOf.valueTypes.map((type) => FullType(type)).toList(),
            ),
          )!
          as Map<String, dynamic>;
    }

    final first = wireOf(request.changes.first);
    expect(first['entity_type'], 'category');
    expect(first['entity_id'], categoryId);
    expect(first['action'], 'upsert');
    final second = wireOf(request.changes.last);
    expect(second['entity_type'], 'transaction');
    expect(second['entity_id'], txnId);

    // 分类行同步绑定当前账号域，后续变更走常规登记路径
    final catRow = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(categoryId))).getSingle();
    expect(catRow.scopeAccountId, 'user-a');
  });

  test('push 出口把交易金额规范化为契约格式（尾零剥离）', () async {
    const ledgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6235';
    const txnId = '3c0d0f14-04aa-4c11-bbf8-f0358ab1b9d7';
    final updatedAt = DateTime.utc(2026, 9, 5, 8);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '可乐',
            storageMode: const d.Value('cloud'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: txnId,
            ledgerId: const d.Value(ledgerId),
            action: 'upsert',
            payload: jsonEncode({
              'tx_type': 'expense',
              'amount': '857.00',
              'happened_at': '2026-09-05T08:00:00.000Z',
              'note': '尾零金额',
              'category_id': null,
              'exclude_from_stats': false,
              'currency_code': 'CNY',
              'native_amount': '857.00',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-tx-2',
            accountId: const d.Value('user-a'),
          ),
        );

    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: PostSyncPush200Response(
          (b) => b
            ..outcomes = BuiltList<PostSyncPush200ResponseOutcomesInner>(
              [],
            ).toBuilder()
            ..serverCursor = '0',
        ),
      ),
    );

    await buildService().push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final request = captured.single as PostSyncPushRequest;
    final ch = request.changes.single;
    final wire =
        client.serializers.serialize(
              ch.anyOf,
              specifiedType: FullType(
                AnyOf,
                ch.anyOf.valueTypes.map((type) => FullType(type)).toList(),
              ),
            )!
            as Map<String, dynamic>;
    final payload = wire['payload'] as Map<String, dynamic>;
    expect(payload['amount'], '857');
    expect(payload['native_amount'], '857');
  });
}
