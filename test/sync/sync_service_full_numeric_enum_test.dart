import 'dart:convert';
import 'dart:typed_data';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Transaction,
        TransactionSplit,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// 按队列顺序返回预设响应的 Dio 适配器。
class _QueuedAdapter implements HttpClientAdapter {
  _QueuedAdapter(this.responses);

  final List<({int status, Object body})> responses;
  int _index = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final next =
        responses[_index < responses.length ? _index : responses.length - 1];
    _index++;
    return ResponseBody.fromString(
      jsonEncode(next.body),
      next.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// full 响应的账本对象（契约 required 字段）。
Map<String, Object?> _fullLedgerJson(String id) => {
  'id': id,
  'owner_id': 'user-1',
  'sync_id': const Uuid().v4(),
  'name': '云端账本',
  'currency': 'CNY',
  'month_start_day': 1,
  'aa_enabled': false,
  'updated_at': '2026-09-05T10:00:00.000Z',
};

/// full 响应的交易对象（契约 required 字段，aa_mode 为字符串枚举）。
Map<String, Object?> _txJson(String id, String ledgerId, Object? aaMode) => {
  'id': id,
  'ledger_id': ledgerId,
  'tx_type': 'expense',
  'amount': '10',
  'happened_at': '2026-09-05T10:00:00.000Z',
  'note': null,
  'category_id': null,
  'category_name': null,
  'category_kind': null,
  'currency_code': 'CNY',
  'native_amount': '10',
  'recurring_id': null,
  'created_by_member_id': null,
  'last_edited_by_member_id': null,
  'payer_member_id': null,
  'aa_mode': aaMode,
  'splits': <Object>[],
  'revision': 1,
  'last_edited_at': null,
  'updated_at': '2026-09-05T10:00:00.000Z',
  'created_at': '2026-09-05T10:00:00.000Z',
};

/// full 响应的分类对象（契约 required 字段，level 按服务端实际输出数值）。
Map<String, Object?> _categoryJson(String id, Object? level) => {
  'id': id,
  'owner_id': 'user-1',
  'name': '餐饮',
  'kind': 'expense',
  'level': level,
  'sort_order': 0,
  'icon': null,
  'parent_id': null,
  'version_token':
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  'deleted_at': null,
  'updated_at': '2026-09-05T10:00:00.000Z',
};

/// full 响应体（字符串 aa_mode 与数值 level，与验收后端真实输出一致）。
Map<String, Object?> _fullJson(String ledgerId, String txId, String catId) => {
  'ledger': _fullLedgerJson(ledgerId),
  'members': <Object>[],
  'transactions': [_txJson(txId, ledgerId, '0')],
  'categories': [_categoryJson(catId, 1)],
  'recurring_transactions': <Object>[],
  'exchange_rate_overrides': <Object>[],
  'server_cursor': '42',
};

/// 含 aaMode 枚举与 level 枚举的 full 响应对象（mocktail SyncApi 直返，
/// 跳过 JSON 层，专测落库映射）。
GetSyncFull200Response _fullResponseWithEnums(
  String ledgerId,
  String txId,
  String catId,
) {
  return GetSyncFull200Response(
    (b) => b
      ..ledger = GetSyncFull200ResponseLedger(
        (b) => b
          ..id = ledgerId
          ..ownerId = 'user-1'
          ..syncId = const Uuid().v4()
          ..name = '云端账本'
          ..currency = 'CNY'
          ..monthStartDay = 1
          ..aaEnabled = false
          ..updatedAt = DateTime.utc(2026, 9, 5, 10),
      ).toBuilder()
      ..transactions = BuiltList<Transaction>([
        Transaction(
          (b) => b
            ..id = txId
            ..ledgerId = ledgerId
            ..txType = TransactionTxTypeEnum.expense
            ..amount = '10'
            ..happenedAt = DateTime.utc(2026, 9, 5, 10)
            ..currencyCode = 'CNY'
            ..nativeAmount = '10'
            ..aaMode = TransactionAaModeEnum.n2
            ..revision = 1
            ..updatedAt = DateTime.utc(2026, 9, 5, 10)
            ..createdAt = DateTime.utc(2026, 9, 5, 10),
        ),
      ]).toBuilder()
      ..categories = BuiltList<Category>([
        Category(
          (b) => b
            ..id = catId
            ..ownerId = 'user-1'
            ..name = '餐饮'
            ..kind = CategoryKindEnum.expense
            ..level = CategoryLevelEnum.n2
            ..versionToken =
                'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            ..sortOrder = 0
            ..updatedAt = DateTime.utc(2026, 9, 5, 10),
        ),
      ]).toBuilder()
      ..recurringTransactions = BuiltList<RecurringTransaction>().toBuilder()
      ..members = BuiltList<Member>().toBuilder()
      ..exchangeRateOverrides = BuiltList<ExchangeRateOverride>().toBuilder()
      ..serverCursor = '42',
  );
}

/// 构造一条 pull 事件（payload 为自由形态 map）。
GetSyncPull200ResponseChangesInner _change(
  String changeId,
  String entityType,
  String entityId,
  String? ledgerId,
  Map<String, Object?> payload,
) {
  return GetSyncPull200ResponseChangesInner(
    (b) => b
      ..changeId = changeId
      ..ledgerId = ledgerId
      ..entityType = GetSyncPull200ResponseChangesInnerEntityTypeEnum.values
          .firstWhere((e) => e.name == entityType)
      ..entityId = entityId
      ..action = GetSyncPull200ResponseChangesInnerActionEnum.upsert
      ..mutationId = const Uuid().v4()
      ..payload = MapBuilder<String, JsonObject?>({
        for (final e in payload.entries)
          e.key: e.value == null
              ? null
              : JsonObject(jsonDecode(jsonEncode(e.value))),
      })
      ..updatedAt = DateTime.utc(2026, 9, 5, 10)
      ..deviceId = 'remote-device',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetGlobalTestState());

  test('契约边界：full 的分类 DTO 直接接收 level 数值枚举', () async {
    final ledgerId = const Uuid().v4();
    final txId = const Uuid().v4();
    final catId = const Uuid().v4();
    final adapter = _QueuedAdapter([
      (status: 200, body: _fullJson(ledgerId, txId, catId)),
    ]);
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    final client = SesameApiClient(dio: dio, serializers: apiSerializers);
    final api = SyncApi(client.dio, client.serializers);

    final resp = await api.getSyncFull(ledgerId: ledgerId);

    expect(resp.data, isNotNull);
    expect(
      resp.data!.transactions.single.aaMode,
      TransactionAaModeEnum.n0,
      reason: 'aa_mode 为契约字符串枚举，必须直接反序列化为枚举',
    );
    expect(
      resp.data!.categories.single.level,
      CategoryLevelEnum.n1,
      reason: '数值 level 必须在边界归一为字符串 wire 名后反序列化为枚举',
    );
  });

  test('pull 落库：契约字符串 aa_mode 与归一后的 level 正确落库', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final mockApi = _MockSyncApi();
    final ledgerId = const Uuid().v4();
    final txId = const Uuid().v4();
    final catId = const Uuid().v4();
    final syncId = const Uuid().v4();
    // 使用已发布且绑定明确的父账本，分类与交易只由本次增量事件写入。
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: ledgerId,
            name: '已有完整本地快照',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('user-1'),
            ownerAccountId: const d.Value('user-1'),
            syncId: d.Value(syncId),
            updatedAt: DateTime.utc(2026, 9, 5, 9),
          ),
        );
    // pull 的开放事件载荷保留整数 level；aa_mode 保持契约字符串枚举。
    when(() => mockApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        statusCode: 200,
        data: GetSyncPull200Response(
          (b) => b
            ..changes = BuiltList<GetSyncPull200ResponseChangesInner>([
              _change('1', 'ledger', ledgerId, ledgerId, {
                'owner_id': 'user-1',
                'sync_id': syncId,
                'name': '云端账本',
                'currency': 'CNY',
                'month_start_day': 1,
                'aa_enabled': false,
              }),
              _change('2', 'category', catId, null, {
                'owner_id': 'user-1',
                'name': '餐饮',
                'kind': 'expense',
                // 开放事件载荷保留整数，投影边界负责转换为本地分类层级。
                'level': 2,
                'sort_order': 0,
                'parent_id': null,
              }),
              _change(
                '3',
                'transaction',
                txId,
                ledgerId,
                _txJson(txId, ledgerId, '1'),
              ),
            ]).toBuilder()
            ..serverCursor = '3'
            ..hasMore = false,
        ),
      ),
    );
    final service = SyncService(
      client: SesameApiClient(serializers: apiSerializers),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );

    expect(await service.pull(), 3);

    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(catId))).getSingle();
    expect(category.level, 2, reason: '归一后的 level 必须严格解析落库');
    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(tx.aaMode, 1, reason: '契约字符串 aa_mode 必须严格解析落库');
    expect(tx.deletedAt, isNull);
    expect((await db.select(db.ledgers).getSingle()).name, '云端账本');
    verifyNever(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    );
  });

  test('full 落库：aaMode 与 level 枚举按 wire 值写入本地行，快照应用不抛错', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final mockApi = _MockSyncApi();
    final ledgerId = const Uuid().v4();
    final txId = const Uuid().v4();
    final catId = const Uuid().v4();
    when(
      () => mockApi.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        statusCode: 200,
        data: _fullResponseWithEnums(ledgerId, txId, catId),
      ),
    );
    final service = SyncService(
      client: SesameApiClient(serializers: apiSerializers),
      db: db,
      deviceId: 'dev-1',
      apiOverride: mockApi,
      currentAccountIdGetter: () => 'user-1',
    );

    await service.full(ledgerId: ledgerId);

    final tx = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(txId))).getSingle();
    expect(
      tx.aaMode,
      2,
      reason: 'full 落库必须按 wire 值写 aa_mode（枚举名 n2 → 2），不得解析 Dart 枚举名',
    );
    final category = await (db.select(
      db.categories,
    )..where((c) => c.id.equals(catId))).getSingle();
    expect(
      category.level,
      2,
      reason: 'full 落库必须按 wire 值写 level（枚举名 n2 → 2），不得解析 Dart 枚举名',
    );
    expect(
      category.serverVersionToken,
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
    expect(tx.deletedAt, isNull);
  });
}
