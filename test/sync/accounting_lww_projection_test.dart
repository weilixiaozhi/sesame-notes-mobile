import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/utils/exchange_rate_id.dart';

import '../helpers/test_isolation.dart';

const _account = 'd2471ee2-767a-49a7-ab02-639201999140';
const _ledger = 'ff7ac6a2-2d7b-4a81-abd8-11878205dd84';
const _entity = '6e5b77c7-76d7-407b-aae5-abfa3b304bce';
const _binding = 'b98bbd02-de41-43b5-b73e-bdc86c743107';
const _deviceA = '00000000-0000-4000-8000-000000000001';
const _deviceC = '00000000-0000-4000-8000-000000000002';
const _deviceB = 'ffffffff-ffff-4fff-bfff-ffffffffffff';
final _time = DateTime.utc(2026, 10, 22, 1, 2, 3, 456);
const _types = [
  'ledger',
  'member',
  'exchange_rate_override',
  'recurring_transaction',
];

/// 仅替换 HTTP 传输；生成 SDK、域游标、账号事务与实体投影均执行生产代码。
class _PullAdapter implements HttpClientAdapter {
  List<Map<String, dynamic>> changes = [];
  int cursor = 0;
  final requestedSince = <String>[];

  /// 按测试安排返回服务端已接受的有序事件，保留真实 SDK 解码边界。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!options.path.endsWith('/sync/pull')) {
      throw StateError('非预期请求 ${options.path}');
    }
    requestedSince.add(options.queryParameters['since'].toString());
    return ResponseBody.fromString(
      jsonEncode({
        'changes': changes,
        'server_cursor': '$cursor',
        'has_more': false,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  /// 内存传输没有持久资源。
  @override
  void close({bool force = false}) {}
}

/// 四类 LWW 元数据统一验证三设备平局、重放与真实待上传链。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late api.SesameApiClient client;
  late _PullAdapter adapter;
  late SyncService service;

  /// 用设备 B 重新装配引擎，重放保护必须来自持久游标而非内存缓存。
  SyncService buildService() => SyncService(
    client: client,
    db: db,
    deviceId: _deviceB,
    currentAccountIdGetter: () => _account,
  );

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    adapter = _PullAdapter();
    client = api.SesameApiClient(basePathOverride: 'https://sync.test');
    client.dio.httpClientAdapter = adapter;
    service = buildService();
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledger,
            name: '初始账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            ownerAccountId: const d.Value(_account),
            syncId: const d.Value(_binding),
            updatedAt: _time.subtract(const Duration(milliseconds: 1)),
          ),
        );
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: _deviceB,
            accountId: const d.Value(_account),
            serverCursor: const d.Value('0'),
            dayEventsCursor: const d.Value('0'),
            memosCursor: const d.Value('0'),
            fitnessCursor: const d.Value('0'),
          ),
        );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 汇率使用正式确定性身份，其他实体使用已绑定账本或合法 UUID。
  String id(String type) => switch (type) {
    'ledger' => _ledger,
    'exchange_rate_override' => exchangeRateOverrideId(_account, 'USD', 'CNY'),
    _ => _entity,
  };

  /// 构造当前协议下完整元数据，业务值便于直接核对数据库结果。
  Map<String, dynamic> payload(String type, String value, DateTime time) => {
    'id': id(type),
    'updated_at': time.toIso8601String(),
    ...switch (type) {
      'ledger' => {
        'owner_id': _account,
        'sync_id': _binding,
        'name': value,
        'currency': 'CNY',
        'month_start_day': 1,
        'aa_enabled': false,
      },
      'member' => {
        'ledger_id': _ledger,
        'display_name': value,
        'member_type': 'PLACEHOLDER',
        'status': 'ACTIVE',
      },
      'exchange_rate_override' => {
        'base_currency': 'USD',
        'quote_currency': 'CNY',
        'rate': value,
      },
      _ => {
        'ledger_id': _ledger,
        'tx_type': 'expense',
        'amount': value,
        'currency_code': 'CNY',
        'category_id': null,
        'note': null,
        'protocol_version': 1,
        'time_zone': 'UTC',
        'frequency': 'daily',
        'interval': 1,
        'day_of_month': null,
        'day_of_week': null,
        'month_of_year': null,
        'start_date': '2026-01-01T00:00:00.000Z',
        'end_date': null,
        'last_generated_date': null,
        'enabled': false,
      },
    },
  };

  /// 事件游标独立于毫秒时间；A 与 C 的同毫秒更新依服务端顺序先后提交。
  Map<String, dynamic> event(
    String type,
    String value,
    String device,
    int cursor, {
    DateTime? time,
  }) => {
    'change_id': '$cursor',
    'ledger_id': type == 'exchange_rate_override' ? null : _ledger,
    'entity_type': type,
    'entity_id': id(type),
    'action': 'upsert',
    'mutation_id':
        '11111111-1111-4111-8111-${cursor.toString().padLeft(12, '0')}',
    'payload': payload(type, value, time ?? _time),
    'updated_at': (time ?? _time).toIso8601String(),
    'device_id': device,
  };

  /// 从 SQLite 读取实际业务值，不能以网络夹具或内存对象代替投影断言。
  Future<String> value(String type) async => switch (type) {
    'ledger' => (await db.select(db.ledgers).getSingle()).name,
    'member' => (await db.select(db.ledgerMembers).getSingle()).displayName,
    'exchange_rate_override' =>
      (await db.select(db.exchangeRateOverrides).getSingle()).rate,
    _ => (await db.select(db.recurringTransactions).getSingle()).amount,
  };

  /// 本地编辑副本与待上传正文同时存在，不能只造 outbox 而遗漏实际业务行。
  Future<void> writeLocalValue(String type, String text) async {
    switch (type) {
      case 'ledger':
        await (db.update(
          db.ledgers,
        )..where((row) => row.id.equals(id(type)))).write(
          LedgersCompanion(name: d.Value(text), updatedAt: d.Value(_time)),
        );
      case 'member':
        await (db.update(
          db.ledgerMembers,
        )..where((row) => row.id.equals(id(type)))).write(
          LedgerMembersCompanion(
            displayName: d.Value(text),
            updatedAt: d.Value(_time),
          ),
        );
      case 'exchange_rate_override':
        await (db.update(
          db.exchangeRateOverrides,
        )..where((row) => row.id.equals(id(type)))).write(
          ExchangeRateOverridesCompanion(
            rate: d.Value(text),
            updatedAt: d.Value(_time),
          ),
        );
      case 'recurring_transaction':
        await (db.update(
          db.recurringTransactions,
        )..where((row) => row.id.equals(id(type)))).write(
          RecurringTransactionsCompanion(
            amount: d.Value(text),
            updatedAt: d.Value(_time),
          ),
        );
    }
  }

  /// 一次完整 pull 消费给定页面，服务端水位可以包含重复的旧事件供防重验证。
  Future<void> pull(List<Map<String, dynamic>> events, int cursor) async {
    adapter.changes = events;
    adapter.cursor = cursor;
    await service.pull();
  }

  for (final type in _types) {
    test('$type A<C<B 同毫秒三设备更新必须采用服务端接受的 C，重启重放不回退', () async {
      final a = event(type, '1', _deviceA, 1);
      final c = event(type, '2', _deviceC, 2);
      await pull([a], 1);
      expect(await value(type), '1');
      expect(await db.select(db.syncChanges).get(), isEmpty);
      await pull([c], 2);
      expect(await value(type), '2');
      final ledger = await db.select(db.ledgers).getSingle();
      expect(ledger.scopeAccountId, _account);
      expect(ledger.ownerAccountId, _account);
      expect(ledger.syncId, _binding);
      expect((await db.select(db.syncState).getSingle()).serverCursor, '2');
      service = buildService();
      await pull([a, c], 2);
      expect(await value(type), '2');
      expect(adapter.requestedSince.last, '2');
    });

    test('$type 较旧元数据时间不能覆盖已观察的新版本', () async {
      await pull([event(type, '2', _deviceC, 1)], 1);
      await pull([
        event(
          type,
          '1',
          _deviceB,
          2,
          time: _time.subtract(const Duration(milliseconds: 1)),
        ),
      ], 2);
      expect(await value(type), '2');
      expect((await db.select(db.syncState).getSingle()).serverCursor, '2');
    });

    for (final rejected in [false, true]) {
      test('$type 待上传原文与明确拒收副本保留 rejected=$rejected', () async {
        await pull([event(type, '1', _deviceA, 1)], 1);
        await writeLocalValue(type, '3');
        final original = jsonEncode(payload(type, '3', _time));
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: type,
                entityId: id(type),
                ledgerId: d.Value(
                  type == 'exchange_rate_override' ? null : _ledger,
                ),
                accountId: const d.Value(_account),
                action: 'upsert',
                payload: original,
                updatedAt: _time,
                mutationId: '22222222-2222-4222-8222-222222222222',
                rejectionReason: d.Value(rejected ? 'VALIDATION_FAILED' : null),
              ),
            );
        await pull([event(type, '2', _deviceC, 2)], 2);
        // 普通 LWW 接受云端投影，但队列原文独立；周期及确定拒收保留本机副本。
        expect(
          await value(type),
          rejected || type == 'recurring_transaction' ? '3' : '2',
        );
        final pending = await db.select(db.syncChanges).getSingle();
        expect(pending.payload, original);
        expect(pending.pushedAt, isNull);
      });
    }

    test('$type 已确认本机同毫秒事件按服务器顺序收敛，随后旧页不能回退', () async {
      await pull([event(type, '1', _deviceA, 1)], 1);
      await writeLocalValue(type, '3');
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: type,
              entityId: id(type),
              accountId: const d.Value(_account),
              action: 'upsert',
              payload: '{}',
              updatedAt: _time,
              pushedAt: d.Value(_time),
              mutationId: '33333333-3333-4333-8333-333333333333',
            ),
          );
      final c = event(type, '2', _deviceC, 2);
      final b = event(type, '3', _deviceB, 3);
      await pull([c, b], 3);
      expect(await value(type), '3');
      await pull([c], 3);
      expect(await value(type), '3');
      expect((await db.select(db.syncState).getSingle()).serverCursor, '3');
    });
  }

  for (final type in ['member', 'exchange_rate_override']) {
    test('$type 同毫秒的权威删除不能被读取设备 B 的编号拒绝', () async {
      await pull([event(type, '1', _deviceA, 1)], 1);
      final removed = event(type, '1', _deviceC, 2);
      removed['action'] = 'delete';
      removed['payload'] = {
        ...payload(type, '1', _time),
        'deleted_at': _time.toIso8601String(),
        if (type == 'member') 'status': 'REMOVED',
      };
      await pull([removed], 2);
      if (type == 'member') {
        expect(
          (await db.select(db.ledgerMembers).getSingle()).status,
          'REMOVED',
        );
      } else {
        expect(
          (await db.select(db.exchangeRateOverrides).getSingle()).deletedAt,
          _time,
        );
      }
      expect((await db.select(db.syncState).getSingle()).serverCursor, '2');
    });
  }
}
