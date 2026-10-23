import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/services/category_seed_service.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:sesame_notes/utils/default_category_seed_catalog.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _otherAccount = '10000000-0000-4000-8000-000000000002';
const _device = '20000000-0000-4000-8000-000000000001';
const _ledger = '30000000-0000-4000-8000-000000000001';
const _custom = '40000000-0000-4000-8000-000000000001';
final _epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
final _token = 'a' * 64;

/// 部分账号目录包含独立一级与父子分类，剩余默认项由普通云事件提供。
const _presentKeys = {
  'dining',
  'beverage',
  'shopping',
  'transport',
  'communication',
  'snacks',
  'pets',
  'housing',
  'subscription',
  'entertainment',
  'education',
  'gift',
  'beauty',
  'medical',
  'digital',
  'other',
  'transport_transitcard',
  'beverage_milk_tea',
  'pets_food',
  'entertainment_movie',
  'shopping_supermarket',
  'beauty_cosmetics',
  'beverage_coffee',
  'pets_supplies',
  'transport_taxi',
  'beauty_salon',
  'pets_medical',
  'transport_fuel',
  'beverage_soda',
};

/// 网络替身只提供正式生成模型，数据合并、队列确认和账号隔离仍走同步引擎。
class _Api extends Mock implements api.SyncApi {}

/// 按固定身份构造云端分类，未被账单引用的分类仍具有完整云版本。
Map<String, dynamic> _categoryPayload(CategorySeedItem item) => {
  'id': defaultCategoryId(level: item.level, key: item.key),
  'owner_id': _account,
  'name': item.name,
  'kind': 'expense',
  'level': '${item.level}',
  'sort_order': item.sortOrder,
  'icon': item.icon,
  'parent_id': item.parentKey == null
      ? null
      : defaultCategoryId(level: 1, key: item.parentKey!),
  'updated_at': _epoch.toIso8601String(),
  'deleted_at': null,
  'version_token': _token,
};

/// 记录异步验收错误，保留原堆栈便于判断实现与测试夹具的责任边界。
Future<void> _verify(Future<void> Function() work) async {
  try {
    await work();
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(StateError('账号分类正常同步验收失败：$error'), stackTrace);
  }
}

/// 完整目录、增量、墓碑及主动新增均通过正常同步路径维护稳定身份。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _Api remote;
  late api.SesameApiClient client;
  late SyncService sync;
  late LocalRepository repository;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    remote = _Api();
    client = api.SesameApiClient(basePathOverride: 'https://catalog.test');
    sync = SyncService(
      client: client,
      db: db,
      deviceId: _device,
      apiOverride: remote,
      currentAccountIdGetter: () => _account,
    );
    repository = LocalRepository(
      db,
      accountIdGetter: () => _account,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => _account),
    );
    registerFallbackValue(
      api.PostSyncPushRequest(
        (builder) => builder
          ..deviceId = _device
          ..changes = ListBuilder<api.PostSyncPushRequestChangesInner>(),
      ),
    );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 按精确账号域读取全部行，墓碑也进入比较以防删除被静默复活。
  Future<List<Category>> rows(String? scope) =>
      (db.select(db.categories)
            ..where((row) => categoryScopePredicate(row, scope))
            ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
          .get();

  /// 给完整快照装配正式响应，账号尚无账本也能取得独立分类目录。
  void serveFull(
    Iterable<Map<String, dynamic>> categories, {
    String cursor = '61',
  }) {
    final response = api.standardSerializers
        .deserializeWith(api.GetSyncAccountingFull200Response.serializer, {
          'ledger_snapshots': [],
          'categories': categories.toList(),
          'category_tombstones': [],
          'exchange_rate_overrides': [],
          'deleted_exchange_rate_override_ids': [],
          'server_cursor': cursor,
        })!;
    when(() => remote.getSyncAccountingFull()).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/accounting/full'),
        data: response,
      ),
    );
  }

  /// 按请求游标返回用户级分类事件，不需要账单或账本变更触发分类落库。
  void servePull(
    Iterable<Map<String, dynamic>> categories, {
    required int firstCursor,
    String action = 'upsert',
  }) {
    final changes = [
      for (final (index, payload) in categories.indexed)
        {
          'change_id': '${firstCursor + index}',
          'entity_type': 'category',
          'entity_id': payload['id'],
          'ledger_id': null,
          'action': action,
          'payload': payload,
          'updated_at': payload['updated_at'],
          'device_id': _device,
          'mutation_id':
              '50000000-0000-4000-8000-${(firstCursor + index).toString().padLeft(12, '0')}',
        },
    ];
    when(() => remote.getSyncPull(since: any(named: 'since'))).thenAnswer((
      call,
    ) async {
      final since = int.parse(call.namedArguments[#since] as String);
      final response = api.standardSerializers
          .deserializeWith(api.GetSyncPull200Response.serializer, {
            'changes': changes
                .where(
                  (change) => int.parse(change['change_id'] as String) > since,
                )
                .toList(),
            'server_cursor': '${firstCursor + changes.length - 1}',
            'has_more': false,
          })!;
      return Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: response,
      );
    });
  }

  /// 准备同 UUID 的其他目录记录，验证云事件不会借用或覆盖另一归属。
  Future<void> insertIsolated(
    String? scope,
    String name, {
    String key = 'housing',
  }) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: defaultCategoryId(level: 1, key: key),
          name: name,
          kind: 'expense',
          level: 1,
          scopeAccountId: d.Value(scope),
          updatedAt: DateTime.utc(2026, 10, 1),
        ),
      );

  /// 构造已存在的部分账号目录与自定义类别，普通交易直接使用该自定义 UUID。
  Future<void> seedPartial() async {
    expect(_presentKeys, hasLength(29));
    for (final item in accountDefaultCategorySeeds.where(
      (item) => _presentKeys.contains(item.key),
    )) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: defaultCategoryId(level: item.level, key: item.key),
              scopeAccountId: const d.Value(_account),
              name: item.name,
              kind: 'expense',
              level: item.level,
              sortOrder: d.Value(item.sortOrder),
              icon: d.Value(item.icon),
              parentId: d.Value(
                item.parentKey == null
                    ? null
                    : defaultCategoryId(level: 1, key: item.parentKey!),
              ),
              cloudRegistered: const d.Value(true),
              serverVersionToken: d.Value(_token),
              updatedAt: _epoch,
            ),
          );
    }
    final time = DateTime.utc(2026, 10, 1);
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: _custom,
            scopeAccountId: const d.Value(_account),
            name: '旅行',
            kind: 'expense',
            level: 1,
            icon: const d.Value('plane'),
            sortOrder: const d.Value(88),
            cloudRegistered: const d.Value(true),
            serverVersionToken: d.Value('b' * 64),
            updatedAt: time,
          ),
        );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledger,
            name: '日常账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            ownerAccountId: const d.Value(_account),
            syncId: const d.Value('60000000-0000-4000-8000-000000000001'),
            updatedAt: time,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: '70000000-0000-4000-8000-000000000001',
            ledgerId: _ledger,
            txType: 'expense',
            amount: '123.45',
            nativeAmount: '123.45',
            currencyCode: 'CNY',
            categoryId: const d.Value(_custom),
            note: const d.Value('完整保留的原账单'),
            happenedAt: time,
            createdAt: time,
            updatedAt: time,
          ),
        );
  }

  for (final hasLocalMirror in [false, true]) {
    test(
      '账号无任何账单时完整快照仍保存61项云目录：本地镜像=$hasLocalMirror',
      () => _verify(() async {
        if (hasLocalMirror) {
          await CategorySeedService.ensureAccountSeed(db, _account);
        }
        await insertIsolated(_otherAccount, '另一账号住房');
        await insertIsolated(null, '本地住房');
        final otherBefore = await rows(_otherAccount);
        final localBefore = await rows(null);
        serveFull(accountDefaultCategorySeeds.map(_categoryPayload));
        await sync.accountingFull();

        final categories = await rows(_account);
        expect(categories, hasLength(61));
        expect(categories.where((row) => row.level == 1), hasLength(20));
        expect(categories.where((row) => row.level == 2), hasLength(41));
        expect(
          categories.every(
            (row) =>
                row.cloudRegistered &&
                row.serverVersionToken == _token &&
                row.observedCloudState != null,
          ),
          isTrue,
        );
        expect(categories.map((row) => row.id).toSet(), {
          for (final item in accountDefaultCategorySeeds)
            defaultCategoryId(level: item.level, key: item.key),
        });
        expect(await db.select(db.transactions).get(), isEmpty);
        expect(await db.select(db.syncChanges).get(), isEmpty);
        expect(await rows(_otherAccount), otherBefore);
        expect(await rows(null), localBefore);
        await sync.accountingFull();
        expect(await rows(_account), categories);
      }),
    );
  }

  test('其他账号同编号待传和冲突不会阻止本人完整分类快照', () async {
    final item = accountDefaultCategorySeeds.first;
    final payload = _categoryPayload(item);
    final id = payload['id'] as String;
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: id,
            accountId: const d.Value(_otherAccount),
            action: 'upsert',
            payload: jsonEncode(payload),
            updatedAt: _epoch,
            mutationId: '50000000-0000-4000-8000-000000000001',
          ),
        );
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: '50000000-0000-4000-8000-000000000002',
            accountId: const d.Value(_otherAccount),
            entityType: 'category',
            entityId: id,
            localPayload: jsonEncode(payload),
            remotePayload: jsonEncode(payload),
            baseRevision: 0,
            remoteRevision: 1,
            localMutationId: '50000000-0000-4000-8000-000000000001',
          ),
        );
    serveFull([payload]);

    await sync.accountingFull();

    final category = (await rows(_account)).single;
    expect(category.id, id);
    expect(category.cloudRegistered, isTrue);
    expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNull);
    expect((await db.select(db.syncConflicts).getSingle()).status, 'OPEN');
  });

  test(
    '部分目录增量接收32项后共62项，自定义分类和原账单完整保留',
    () => _verify(() async {
      await seedPartial();
      await insertIsolated(_otherAccount, '另一账号住房');
      await insertIsolated(null, '本地住房');
      final existing = await rows(_account);
      final otherBefore = await rows(_otherAccount);
      final localBefore = await rows(null);
      final transaction = await db.select(db.transactions).getSingle();
      final missing = accountDefaultCategorySeeds
          .where((item) => !_presentKeys.contains(item.key))
          .toList();
      expect(missing, hasLength(32));
      servePull(missing.map(_categoryPayload), firstCursor: 1);
      expect(await sync.pull(), 32);
      final categories = await rows(_account);
      expect(categories, hasLength(62));
      for (final prior in existing) {
        expect(categories.singleWhere((row) => row.id == prior.id), prior);
      }
      for (final item in missing) {
        final row = categories.singleWhere(
          (row) =>
              row.id == defaultCategoryId(level: item.level, key: item.key),
        );
        expect(row.cloudRegistered, isTrue);
        expect(row.serverVersionToken, _token);
        expect(row.name, item.name);
        expect(
          row.parentId,
          item.parentKey == null
              ? null
              : defaultCategoryId(level: 1, key: item.parentKey!),
        );
      }
      expect(await db.select(db.transactions).getSingle(), transaction);
      expect(await rows(_otherAccount), otherBefore);
      expect(await rows(null), localBefore);
      expect(await sync.pull(), 0);
      expect(await rows(_account), categories);
      expect(await db.select(db.syncChanges).get(), isEmpty);
    }),
  );

  test(
    '已删除分类在重复增量和较早完整快照后保持墓碑且不影响其他账号',
    () => _verify(() async {
      serveFull(accountDefaultCategorySeeds.map(_categoryPayload));
      await sync.accountingFull();
      final item = accountDefaultCategorySeeds.singleWhere(
        (item) => item.key == 'communication',
      );
      await insertIsolated(_otherAccount, '另一账号保留通讯', key: 'communication');
      final otherBefore = await rows(_otherAccount);
      final deletedAt = DateTime.utc(2026, 10, 15);
      final tombstone = {
        ..._categoryPayload(item),
        'updated_at': deletedAt.toIso8601String(),
        'deleted_at': deletedAt.toIso8601String(),
        'version_token': 'c' * 64,
      };
      servePull([tombstone], firstCursor: 62, action: 'delete');
      expect(await sync.pull(), 1);
      final afterDelete = await rows(_account);
      expect(
        afterDelete.singleWhere((row) => row.id == tombstone['id']).deletedAt,
        deletedAt,
      );
      expect(await sync.pull(), 0);
      expect(await rows(_account), afterDelete);
      serveFull(
        accountDefaultCategorySeeds.map(_categoryPayload),
        cursor: '62',
      );
      await sync.accountingFull();
      expect(await rows(_account), afterDelete);
      expect(await rows(_otherAccount), otherBefore);
      expect(await db.select(db.syncChanges).get(), isEmpty);
    }),
  );

  test(
    '已有账号主动新增未被账单引用的自定义分类仍登记并上传用户级变更',
    () => _verify(() async {
      await seedPartial();
      final transaction = await db.select(db.transactions).getSingle();
      final id = await repository.createCategory(
        name: '未记账的收藏',
        kind: 'expense',
        icon: 'bookmark',
      );
      final queued = await db.select(db.syncChanges).getSingle();
      expect(
        (queued.entityType, queued.entityId, queued.accountId, queued.ledgerId),
        ('category', id, _account, null),
      );
      expect(queued.pushedAt, isNull);
      expect(
        (await db.select(db.transactions).get()).where(
          (row) => row.categoryId == id,
        ),
        isEmpty,
      );
      final sent = <Map<String, dynamic>>[];
      when(
        () => remote.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest]
                as api.PostSyncPushRequest;
        sent.addAll(syncRequestChanges(request));
        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(request),
        );
      });
      await sync.push();
      expect(sent, hasLength(1));
      expect(sent.single['entity_id'], id);
      expect(sent.single['entity_type'], 'category');
      expect(sent.single['ledger_id'], isNull);
      expect((sent.single['payload'] as Map)['name'], '未记账的收藏');
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
      final created = (await rows(_account)).singleWhere((row) => row.id == id);
      expect(created.cloudRegistered, isTrue);
      expect(created.name, '未记账的收藏');
      expect(await db.select(db.transactions).getSingle(), transaction);
      expect(jsonDecode(queued.payload)['name'], '未记账的收藏');
    }),
  );
}
