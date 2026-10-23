import '../helpers/sync_response.dart';
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
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
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
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
        ),
      ),
    );

    await buildService().push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final changes = captured
        .cast<PostSyncPushRequest>()
        .expand((request) => request.changes)
        .toList();
    expect(changes, hasLength(2), reason: '分类先导变更 + 交易变更');
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

    final first = wireOf(changes.first);
    expect(first['entity_type'], 'category');
    expect(first['entity_id'], categoryId);
    expect(first['action'], 'upsert');
    expect(
      (first['payload'] as Map)['level'],
      '1',
      reason: '已发布生成客户端以字符串枚举发送分类层级，服务端需要兼容实际 wire',
    );
    expect(DateTime.parse(first['updated_at'] as String), updatedAt);
    final second = wireOf(changes.last);
    expect(second['entity_type'], 'transaction');
    expect(second['entity_id'], txnId);

    // 当前账号独立登记分类，本地原分类保留自己的归属和时间。
    final catRow =
        await (db.select(db.categories)..where(
              (c) =>
                  c.id.equals(categoryId) & c.scopeAccountId.equals('user-a'),
            ))
            .getSingle();
    expect(catRow.scopeAccountId, 'user-a');
    expect(catRow.updatedAt.toUtc(), updatedAt, reason: '确保注册不伪造较新的分类编辑时间');
    final localCategory =
        await (db.select(db.categories)..where(
              (c) => c.id.equals(categoryId) & c.scopeAccountId.equals(''),
            ))
            .getSingle();
    expect(localCategory.scopeAccountId, isNull);
    expect(localCategory.updatedAt.toUtc(), updatedAt);
    final categoryChange = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityType.equals('category'))).getSingle();
    expect(categoryChange.updatedAt.toUtc(), updatedAt);
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
              'currency_code': 'CNY',
              'native_amount': '857.00',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': '2',
              'splits': [
                {
                  'member_id': '1527ffc3-6087-5b6b-99c6-c6837a5db1b6',
                  'amount': '50.00',
                },
              ],
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
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
        ),
      ),
    );

    await buildService().push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final changes = captured
        .cast<PostSyncPushRequest>()
        .expand((request) => request.changes)
        .toList();
    final ch = changes.single;
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
    final splits = payload['splits'] as List<dynamic>;
    expect((splits.single as Map<String, dynamic>)['amount'], '50');
  });

  test('先导登记的分类按层级排序：一级父分类先于二级子分类', () async {
    const parentId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
    const childId = 'd5f0c25f-7ec2-5d9c-9f0b-0b2c1f8a7c3d';
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
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: parentId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            sortOrder: const d.Value(0),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: childId,
            name: '早餐',
            kind: 'expense',
            level: 2,
            parentId: const d.Value(parentId),
            sortOrder: const d.Value(1),
            updatedAt: updatedAt,
          ),
        );
    // 模拟历史队列：二级子分类的变更早已入队（id 更小），
    // 一级父分类尚未登记——push 批次必须把父分类重排到子分类之前。
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: childId,
            action: 'upsert',
            payload: jsonEncode({
              'name': '早餐',
              'updated_at': updatedAt.toIso8601String(),
              'kind': 'expense',
              'level': '2',
              'sort_order': 1,
              'icon': null,
              'parent_id': parentId,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-cat-child',
            accountId: const d.Value('user-a'),
          ),
        );
    // 交易只引用二级子分类：父分类也必须一并先导登记
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
              'note': '二级分类交易',
              'category_id': childId,
              'currency_code': 'CNY',
              'native_amount': '10.5',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-tx-3',
            accountId: const d.Value('user-a'),
          ),
        );

    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
        ),
      ),
    );

    await buildService().push();

    final captured = verify(
      () => api.postSyncPush(
        postSyncPushRequest: captureAny(named: 'postSyncPushRequest'),
      ),
    ).captured;
    final changes = captured
        .cast<PostSyncPushRequest>()
        .expand((request) => request.changes)
        .toList();
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

    final wireChanges = changes.map(wireOf).toList();
    expect(wireChanges, hasLength(3), reason: '父分类 + 子分类 + 交易');
    expect(wireChanges[0]['entity_id'], parentId, reason: '一级父分类必须最先');
    expect((wireChanges[0]['payload'] as Map)['level'], '1');
    expect(wireChanges[1]['entity_id'], childId);
    expect((wireChanges[1]['payload'] as Map)['level'], '2');
    expect(wireChanges[2]['entity_type'], 'transaction');
  });

  test('分类被拒绝时，引用它的交易不得推送（避免逐条被判分类不可用）', () async {
    const categoryId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
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
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('user-a'),
            updatedAt: updatedAt,
          ),
        );
    // 分类变更已被服务端拒绝，等待用户处理
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: categoryId,
            action: 'upsert',
            payload: jsonEncode({
              'name': '餐饮',
              'updated_at': updatedAt.toIso8601String(),
              'kind': 'expense',
              'level': '1',
              'sort_order': 0,
              'icon': null,
              'parent_id': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-cat-rejected',
            accountId: const d.Value('user-a'),
            rejectionReason: const d.Value('记录内容未通过服务端校验，请检查并编辑后保存'),
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
              'amount': '10.5',
              'happened_at': '2026-09-05T08:00:00.000Z',
              'note': '被拒分类的交易',
              'category_id': categoryId,
              'currency_code': 'CNY',
              'native_amount': '10.5',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-tx-blocked',
            accountId: const d.Value('user-a'),
          ),
        );

    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer(
      (invocation) async => Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest,
        ),
      ),
    );

    await buildService().push();

    verifyNever(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    );
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('transaction'))).getSingle();
    expect(pending.pushedAt, isNull, reason: '分类未修复前交易保持待上传，不能换来逐条被拒');
    expect(pending.rejectionReason, isNull, reason: '依赖未就绪不是交易自身的错误');
  });

  test('本轮父分类被拒后阻止子分类及引用交易，其他交易继续同步', () async {
    const parentId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
    const childId = 'd5f0c25f-7ec2-5d9c-9f0b-0b2c1f8a7c3d';
    const ledgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6235';
    const otherLedgerId = 'af7de4f4-d732-4cd5-bf95-aef0406ad377';
    final updatedAt = DateTime.utc(2026, 9, 5, 8);
    for (final id in [ledgerId, otherLedgerId]) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: id,
              name: '云账本',
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('user-a'),
              ownerAccountId: const d.Value('user-a'),
              syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
              updatedAt: updatedAt,
            ),
          );
    }
    for (final (id, parent, level) in [
      (parentId, null, 1),
      (childId, parentId, 2),
    ]) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: '待上传分类',
              kind: 'expense',
              level: level,
              parentId: d.Value(parent),
              updatedAt: updatedAt,
            ),
          );
    }
    for (final (id, category, ledger) in [
      ('tx-parent', parentId, ledgerId),
      ('tx-child', childId, ledgerId),
      ('tx-independent', null, ledgerId),
      ('tx-other-ledger', null, otherLedgerId),
    ]) {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: id,
              ledgerId: d.Value(ledger),
              action: 'upsert',
              payload: jsonEncode({
                'tx_type': 'expense',
                'amount': '100',
                'happened_at': '2026-09-05T08:00:00.000Z',
                'category_id': category,
                'currency_code': 'CNY',
                'native_amount': '100',
              }),
              updatedAt: updatedAt,
              mutationId: 'mutation-$id',
              accountId: const d.Value('user-a'),
            ),
          );
    }
    final pushed = <Map<String, dynamic>>[];
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      final changes = syncRequestChanges(request);
      pushed.addAll(changes);
      final rejected = changes.where((c) => c['entity_id'] == parentId);
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(
          request,
          overrides: [
            for (final change in rejected)
              PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = change['mutation_id'] as String
                  ..entityId = parentId
                  ..status =
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                  ..message = 'level 必须是整数',
              ),
          ],
        ),
      );
    });

    await buildService().push();

    expect(pushed.map((c) => c['entity_id']), [
      parentId,
      'tx-independent',
      'tx-other-ledger',
    ], reason: '本轮收到父分类拒绝回执后，必须立即拦截其子分类及直接、间接引用交易');
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.pushedAt.isNull())).get();
    expect(
      pending.map((c) => c.entityId),
      unorderedEquals([parentId, childId, 'tx-parent', 'tx-child']),
    );
    expect(
      pending
          .where((c) => c.entityId != parentId)
          .every((c) => c.rejectionReason == null && c.frozenRequest == null),
      isTrue,
      reason: '依赖未就绪的记录保留为未发送待上传状态，无需人工逐条修改',
    );
  });

  test('分类重新确认后，关联交易保留原内容并自动恢复上传', () async {
    const categoryId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
    const ledgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6235';
    const txnId = '3c0d0f14-04aa-4c11-bbf8-f0358ab1b9d7';
    final updatedAt = DateTime.utc(2026, 9, 5, 8);
    final categoryPayload = {
      'updated_at': updatedAt.toIso8601String(),
      'name': '送礼',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    };
    final transactionPayload = {
      'tx_type': 'expense',
      'amount': '100',
      'happened_at': '2026-09-05T08:00:00.000Z',
      'note': '原始交易内容',
      'category_id': categoryId,
      'currency_code': 'CNY',
      'native_amount': '100',
      'recurring_id': null,
      'payer_member_id': null,
      'aa_mode': null,
      'splits': null,
      'last_edited_at': null,
    };
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '云账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '送礼',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('user-a'),
            updatedAt: updatedAt,
          ),
        );
    // 已明确拒绝的 mutation 可以使用新幂等键重试，原始业务内容仍完整保留。
    final categoryChangeId = await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: categoryId,
            action: 'upsert',
            payload: jsonEncode(categoryPayload),
            updatedAt: updatedAt,
            mutationId: 'rejected-category',
            accountId: const d.Value('user-a'),
            rejectionReason: const d.Value('记录内容未通过服务端校验，请检查并编辑后保存'),
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
            payload: jsonEncode(transactionPayload),
            updatedAt: updatedAt,
            mutationId: 'rejected-transaction',
            accountId: const d.Value('user-a'),
            rejectionCode: const d.Value('INVALID_CATEGORY'),
            rejectionReason: const d.Value('分类不可用，请重新选择分类后保存'),
          ),
        );
    final pushed = <Map<String, dynamic>>[];
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      pushed.addAll(syncRequestChanges(request));
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(request),
      );
    });
    final service = buildService();

    await service.retryRejectedChange(categoryChangeId.toString());
    await service.push();

    expect(pushed, hasLength(2));
    expect(pushed.first['entity_type'], 'category');
    expect(pushed.first['payload'], {...categoryPayload}..remove('updated_at'));
    expect(pushed.first['mutation_id'], isNot('rejected-category'));
    expect(pushed.first['updated_at'], updatedAt.toIso8601String());
    expect(pushed.last['entity_type'], 'transaction');
    // 可选支出人为空时生成客户端省略字段，缺省与 null 均由服务端解析为当前成员。
    expect(
      pushed.last['payload'],
      {...transactionPayload}..remove('payer_member_id'),
    );
    expect(pushed.last['mutation_id'], isNot('rejected-transaction'));
    expect(pushed.last['updated_at'], updatedAt.toIso8601String());
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
      reason: '服务端恢复后两条原始记录均确认上传，无需重新录入或变更分类',
    );
  });

  test('分类请求失败时整轮停止，交易不得越过未确认的分类上云', () async {
    const categoryId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
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
            scopeAccountId: const d.Value('user-a'),
            ownerAccountId: const d.Value('user-a'),
            syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: categoryId,
            name: '餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: updatedAt,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: categoryId,
            action: 'upsert',
            payload: jsonEncode({
              'name': '餐饮',
              'updated_at': updatedAt.toIso8601String(),
              'kind': 'expense',
              'level': '1',
              'sort_order': 0,
              'icon': null,
              'parent_id': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-cat-fail',
            accountId: const d.Value('user-a'),
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
              'amount': '10.5',
              'happened_at': '2026-09-05T08:00:00.000Z',
              'note': '分类未确认',
              'category_id': categoryId,
              'currency_code': 'CNY',
              'native_amount': '10.5',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: updatedAt,
            mutationId: 'm-tx-after-fail',
            accountId: const d.Value('user-a'),
          ),
        );

    final pushed = <PostSyncPushRequest>[];
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      pushed.add(
        invocation.namedArguments[#postSyncPushRequest] as PostSyncPushRequest,
      );
      // 分类请求整体失败（网络/服务端 5xx）：依赖它的账本级变更必须留待重试
      throw DioException(
        requestOptions: RequestOptions(path: '/sync/push'),
        response: Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          statusCode: 500,
        ),
      );
    });

    await expectLater(buildService().push(), throwsA(isA<DioException>()));

    final wire = pushed.expand(syncRequestChanges).toList();
    expect(
      wire.every((change) => change['entity_type'] == 'category'),
      isTrue,
      reason: '分类未确认时不得把引用它的交易发给服务端',
    );
    final tx = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityType.equals('transaction'))).getSingle();
    expect(tx.pushedAt, isNull);
  });
}
