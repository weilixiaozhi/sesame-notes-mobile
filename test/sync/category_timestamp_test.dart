import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart' hide Category, Transaction;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

class _Api extends Mock implements SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late _Api api;
  late SesameApiClient client;
  late SyncService sync;
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = _Api();
    client = SesameApiClient(basePathOverride: 'http://test.local');
    repo = LocalRepository(
      db,
      accountIdGetter: () => 'account',
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
    );
    sync = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
      apiOverride: api,
    );
    registerFallbackValue(
      PostSyncPushRequest(
        (builder) => builder
          ..deviceId = 'device'
          ..changes = ListBuilder<PostSyncPushRequestChangesInner>(),
      ),
    );
  });
  tearDown(() async {
    client.dio.close();
    await db.close();
  });

  /// 用正式响应序列化器传入自由载荷，再通过真实同步服务完成增量处理。
  Future<void> pullChange(
    String action,
    Map<String, dynamic> payload,
    DateTime time,
    int cursor, {
    String entityType = 'category',
  }) async {
    final response = standardSerializers.deserializeWith(
      GetSyncPull200Response.serializer,
      {
        'changes': [
          {
            'change_id': '$cursor',
            'entity_type': entityType,
            'entity_id': '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
            'ledger_id': null,
            'action': action,
            'payload': {...payload, 'owner_id': 'account'},
            'updated_at': time.toIso8601String(),
            'device_id': '00000000-0000-4000-8000-000000000001',
            'mutation_id': '00000000-0000-4000-8000-000000000002',
          },
        ],
        'server_cursor': '$cursor',
        'has_more': false,
      },
    )!;
    when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: response,
      ),
    );
    expect(await sync.pull(), 1);
  }

  /// 建立已绑定账本，让增量测试直接验证投影边界而不是触发首次整本下载。
  Future<void> seedCloudLedger(DateTime time) async {
    try {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
              name: '原账本',
              currency: const d.Value('CNY'),
              monthStartDay: const d.Value(15),
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('account'),
              ownerAccountId: const d.Value('account'),
              syncId: const d.Value('001e3ea4-2fce-40a4-a1b4-9ea9a797d7ef'),
              updatedAt: time,
            ),
          );
    } catch (error, stackTrace) {
      debugPrint('准备增量账本夹具失败，请检查测试数据库：$error\n$stackTrace');
      rethrow;
    }
  }

  test('Web 毫秒分类快照落库后真实人工编辑发送新时间', () async {
    const id = '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef';
    final webTime = DateTime.now().toUtc().subtract(
      const Duration(milliseconds: 1),
    );
    await pullChange(
      'upsert',
      {
        'id': id,
        'name': 'Web 修改',
        'kind': 'expense',
        'level': '1',
        'sort_order': 0,
        'icon': null,
        'parent_id': null,
        'updated_at': webTime.toIso8601String(),
      },
      webTime,
      1,
    );
    await repo.updateCategory(id, name: '手机后续修改');
    final queued = await db.select(db.syncChanges).getSingle();
    final payload = jsonDecode(queued.payload) as Map<String, dynamic>;
    expect(
      DateTime.parse(payload['updated_at'] as String).millisecondsSinceEpoch,
      greaterThan(webTime.millisecondsSinceEpoch),
    );
  });

  for (final (field, value) in <(String, num)>[
    ('level', 1.9),
    ('level', 2.9),
    ('sort_order', 1.9),
    ('sort_order', 2.9),
    ('sort_order', -2147483649),
    ('sort_order', 2147483648),
  ]) {
    test('分类增量 $field=$value 被拒绝，业务投影与消费水位保持原值', () async {
      const id = '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef';
      final time = DateTime.utc(2026, 1, 1);
      final payload = {
        'id': id,
        'name': '原分类',
        'kind': 'expense',
        'level': '1',
        'sort_order': 0,
        'icon': null,
        'parent_id': null,
        'updated_at': time.toIso8601String(),
      };
      await pullChange('upsert', payload, time, 7);
      final before = await db.select(db.categories).getSingle();
      final next = time.add(const Duration(seconds: 1));

      await expectLater(
        pullChange(
          'upsert',
          {
            ...payload,
            'name': '非法变更不能覆盖原分类',
            field: value,
            'updated_at': next.toIso8601String(),
          },
          next,
          8,
        ),
        throwsA(isA<FormatException>()),
      );

      final after = await db.select(db.categories).getSingle();
      expect(after.toJson(), before.toJson(), reason: '失败页不能改写业务行');
      final state = await db.select(db.syncState).getSingle();
      expect(state.serverCursor, '7', reason: '失败页不能推进消费水位');
      final failure = await db.select(db.syncPullErrors).getSingle();
      expect(failure.changeId, '8');
      expect(failure.errorClass, 'FormatException');
    });
  }

  for (final sortOrder in [-2147483648, 2147483647, 1.0]) {
    test('分类增量合法排序 $sortOrder 保留整数语义并推进水位', () async {
      final time = DateTime.utc(2026, 1, 1);
      await pullChange(
        'upsert',
        {
          'id': '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
          'name': '排序边界',
          'kind': 'expense',
          'level': '1',
          'sort_order': sortOrder,
          'icon': null,
          'parent_id': null,
          'updated_at': time.toIso8601String(),
        },
        time,
        1,
      );
      expect((await db.select(db.categories).getSingle()).sortOrder, sortOrder);
      expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
    });
  }

  for (final monthStartDay in [null, 1.9, 2.9, 0, 32]) {
    test('账本增量月界 $monthStartDay 被拒绝，业务投影与消费水位保持原值', () async {
      final time = DateTime.utc(2026, 1, 1);
      await seedCloudLedger(time.subtract(const Duration(seconds: 1)));
      final payload = {
        'id': '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
        'name': '原账本',
        'sync_id': '001e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
        'currency': 'CNY',
        'month_start_day': 15,
        'aa_enabled': false,
      };
      await pullChange('upsert', payload, time, 7, entityType: 'ledger');
      final before = await db.select(db.ledgers).getSingle();

      await expectLater(
        pullChange(
          'upsert',
          {...payload, 'name': '非法变更不能覆盖原账本', 'month_start_day': monthStartDay},
          time.add(const Duration(seconds: 1)),
          8,
          entityType: 'ledger',
        ),
        throwsA(isA<FormatException>()),
      );

      final after = await db.select(db.ledgers).getSingle();
      expect(after.toJson(), before.toJson(), reason: '失败页不能改写业务行');
      expect((await db.select(db.syncState).getSingle()).serverCursor, '7');
      final failure = await db.select(db.syncPullErrors).getSingle();
      expect(failure.changeId, '8');
      expect(failure.errorClass, 'FormatException');
    });
  }

  for (final (field, invalid) in <(String, Object?)>[
    ('name', 42),
    ('name', ''),
    ('currency', 42),
    ('currency', 'usd'),
    ('aa_enabled', 'true'),
    ('sync_id', 42),
  ]) {
    test('账本增量 $field=$invalid 不能通过类型转换变成有效账本', () async {
      final time = DateTime.utc(2026, 1, 1);
      await seedCloudLedger(time.subtract(const Duration(seconds: 1)));
      final before = await db.select(db.ledgers).getSingle();
      await expectLater(
        pullChange(
          'upsert',
          {
            'id': before.id,
            'name': '完整账本',
            'currency': 'USD',
            'month_start_day': 31,
            'aa_enabled': true,
            'sync_id': '001e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
            field: invalid,
          },
          time,
          8,
          entityType: 'ledger',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        (await db.select(db.ledgers).getSingle()).toJson(),
        before.toJson(),
      );
      expect(
        (await db.select(db.syncState).getSingleOrNull())?.serverCursor,
        isNot('8'),
      );
      expect((await db.select(db.syncPullErrors).getSingle()).changeId, '8');
    });
  }

  for (final field in [
    'name',
    'currency',
    'month_start_day',
    'aa_enabled',
    'sync_id',
  ]) {
    test('账本增量缺少 $field 保留原账本与水位，补齐后可重新同步', () async {
      final time = DateTime.utc(2026, 1, 1);
      await seedCloudLedger(time.subtract(const Duration(seconds: 1)));
      final payload = <String, dynamic>{
        'id': '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
        'name': '美元 AA 账本',
        'currency': 'USD',
        'month_start_day': 31,
        'aa_enabled': true,
        'sync_id': '001e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
      };
      await pullChange('upsert', payload, time, 7, entityType: 'ledger');
      final before = await db.select(db.ledgers).getSingle();
      final missing = {...payload}..remove(field);
      await expectLater(
        pullChange(
          'upsert',
          missing,
          time.add(const Duration(seconds: 1)),
          8,
          entityType: 'ledger',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        (await db.select(db.ledgers).getSingle()).toJson(),
        before.toJson(),
      );
      expect((await db.select(db.syncState).getSingle()).serverCursor, '7');
      expect((await db.select(db.syncPullErrors).getSingle()).changeId, '8');

      await pullChange(
        'upsert',
        payload,
        time.add(const Duration(seconds: 1)),
        8,
        entityType: 'ledger',
      );
      final saved = await db.select(db.ledgers).getSingle();
      expect(saved.name, '美元 AA 账本');
      expect(saved.currency, 'USD');
      expect(saved.monthStartDay, 31);
      expect(saved.aaEnabled, isTrue);
      expect((await db.select(db.syncState).getSingle()).serverCursor, '8');
      expect((await db.select(db.syncPullErrors).getSingle()).changeId, '8');
    });
  }

  for (final (label, fields, expected) in <(String, Map<String, Object?>, int)>[
    ('整数小数表达', {'month_start_day': 1.0}, 1),
    ('月底边界', {'month_start_day': 31.0}, 31),
  ]) {
    test('账本增量月界 $label：保留合法整数并推进水位', () async {
      final time = DateTime.utc(2026, 1, 1);
      await seedCloudLedger(time.subtract(const Duration(seconds: 1)));
      await pullChange(
        'upsert',
        {
          'id': '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
          'name': '月界边界',
          'sync_id': '001e3ea4-2fce-40a4-a1b4-9ea9a797d7ef',
          'currency': 'CNY',
          'aa_enabled': false,
          ...fields,
        },
        time,
        1,
        entityType: 'ledger',
      );
      expect((await db.select(db.ledgers).getSingle()).monthStartDay, expected);
      expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
    });
  }

  for (final level in [double.nan, double.infinity, double.negativeInfinity]) {
    test('非有限分类层级 $level 返回可识别的格式错误', () {
      // JSON 无法编码非有限值，直接校验自由值解码边界的异常语义。
      expect(
        () => sync.payloadCodec.categoryLevel(level),
        throwsA(isA<FormatException>()),
      );
    });
  }

  test('删除投影推进版本时间，较旧快照不会复活分类', () async {
    const id = '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef';
    final before = DateTime.utc(2026, 1, 1);
    final deleted = before.add(const Duration(seconds: 2, milliseconds: 789));
    final oldPayload = {
      'id': id,
      'name': '旧分类',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
      'updated_at': before.toIso8601String(),
    };
    await pullChange('upsert', oldPayload, before, 1);
    await pullChange(
      'delete',
      {'deleted_at': deleted.toIso8601String()},
      deleted,
      2,
    );
    final tombstone = await db.select(db.categories).getSingle();
    expect(tombstone.updatedAt.toUtc(), deleted);
    expect(tombstone.deletedAt?.toUtc(), deleted);
    await pullChange('upsert', oldPayload, before, 3);
    expect(await repo.categoryStore.getCategoryById(id), isNull);
  });

  test('UTC 毫秒队列保留分类编辑精度，首次冻结及网络重试保持同体', () async {
    const id = '651e3ea4-2fce-40a4-a1b4-9ea9a797d7ef';
    final precise = DateTime.utc(2026, 9, 1, 2, 3, 4, 789, 654);
    await ChangeRecorderImpl(
      db,
      accountIdGetter: () => 'account',
    ).recordUserGlobalChange(
      entityType: 'category',
      entityId: id,
      action: 'upsert',
      updatedAt: precise,
      payload: jsonEncode({
        'name': '精度分类',
        'kind': 'expense',
        'level': '1',
        'parent_id': null,
        'icon': null,
        'sort_order': 0,
        'updated_at': precise.toIso8601String(),
      }),
    );
    final stored = await db.select(db.syncChanges).getSingle();
    expect(stored.updatedAt.isUtc, isTrue);
    expect(stored.updatedAt.millisecond, 789);
    expect(stored.updatedAt.microsecond, 0);
    expect(
      stored.updatedAt.millisecondsSinceEpoch,
      precise.millisecondsSinceEpoch,
    );
    final requests = <String>[];
    var lost = true;
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      requests.add(
        jsonEncode(
          client.serializers.serializeWith(
            PostSyncPushRequest.serializer,
            request,
          ),
        ),
      );
      if (lost) {
        lost = false;
        throw DioException(
          requestOptions: RequestOptions(path: '/sync/push'),
          type: DioExceptionType.connectionError,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(request),
      );
    });
    await expectLater(sync.push(), throwsA(isA<DioException>()));
    final frozen = await db.select(db.syncChanges).getSingle();
    expect(frozen.frozenRequest, isNotNull);
    expect(frozen.mutationId, stored.mutationId);
    expect(frozen.updatedAt, stored.updatedAt);
    // 模拟后续版本修复了本地 JSON：重试仍必须复用已经发送的冻结内容。
    final payload = jsonDecode(frozen.payload) as Map<String, dynamic>;
    payload['updated_at'] = precise
        .add(const Duration(days: 1))
        .toIso8601String();
    await (db.update(db.syncChanges)..where((row) => row.id.equals(frozen.id)))
        .write(SyncChangesCompanion(payload: d.Value(jsonEncode(payload))));
    await sync.push();
    expect(requests, hasLength(2));
    expect(requests[1], requests[0]);
    final wire = jsonDecode(requests.first) as Map<String, dynamic>;
    final change = (wire['changes'] as List).single as Map;
    expect(change['entity_id'], id);
    expect(change['mutation_id'], stored.mutationId);
    expect((change['payload'] as Map)['name'], '精度分类');
    expect(
      DateTime.parse((wire['changes'] as List).single['updated_at'] as String),
      DateTime.fromMillisecondsSinceEpoch(
        precise.millisecondsSinceEpoch,
        isUtc: true,
      ),
    );
  });

  test('100 次连续人工编辑按毫秒前进，排序和删除继续沿用精确队列时钟', () async {
    final id = await repo.createCategory(name: '初始', kind: 'expense');
    final start = DateTime.now().toUtc();
    for (var index = 0; index < 100; index++) {
      await repo.updateCategory(id, name: '修改$index');
    }
    await repo.updateCategorySortOrders([(id: id, sortOrder: 7)]);
    await repo.deleteCategory(id);
    final changes =
        await (db.select(db.syncChanges)
              ..where((row) => row.entityId.equals(id))
              ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
            .get();
    expect(changes, hasLength(103));
    final times = changes
        .map(
          (row) => DateTime.parse(
            (jsonDecode(row.payload) as Map<String, dynamic>)['updated_at']
                as String,
          ).millisecondsSinceEpoch,
        )
        .toList();
    for (var index = 1; index < times.length; index++) {
      expect(times[index], greaterThan(times[index - 1]));
    }
    expect(
      times.last,
      lessThan(start.add(const Duration(seconds: 5)).millisecondsSinceEpoch),
      reason: '不能累加整秒而触发服务端 now+5s 裁剪',
    );
    expect(changes.last.action, 'delete');
  });
}
