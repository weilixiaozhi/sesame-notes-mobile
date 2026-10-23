import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';

const _a = '11111111-1111-4111-8111-111111111111';
const _b = '22222222-2222-4222-8222-222222222222';
const _binding = '33333333-3333-4333-8333-333333333333';
const _account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

/// 固定权威元数据直接来自契约，水位手工安排以暴露漏消费。
Map<String, Object?> _book(String id) => {
  'id': id,
  'name': id == _a ? 'A' : 'B',
  'sync_id': _binding,
  'revision': 1,
  'created_at': '2026-09-01T00:00:00.000Z',
  'updated_at': '2026-09-01T00:00:00.000Z',
  'deleted_at': null,
};

/// 父本增量使用独立固定变更序号，模拟两次拉取之间发生的操作。
Map<String, Object?> _bookChange(
  String id,
  String cursor, {
  bool deleted = false,
}) => {
  'change_id': cursor,
  'ledger_id': null,
  'day_book_id': id,
  'entity_type': 'day_book',
  'entity_id': id,
  'action': deleted ? 'delete' : 'upsert',
  'mutation_id': 'remote-$cursor',
  'payload': {
    ..._book(id),
    if (deleted) ...{'revision': 2, 'deleted_at': '2026-09-02T00:00:00.000Z'},
  },
  'updated_at': '2026-09-02T00:00:00.000Z',
  'device_id': 'remote',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SesameApiClient client;
  late SyncService sync;
  late _DayAdapter adapter;
  String? account;
  int generation = 0;

  setUp(() {
    account = _account;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    adapter = _DayAdapter();
    client = SesameApiClient(basePathOverride: 'https://days.test');
    client.dio.httpClientAdapter = adapter;
    sync = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
      dayRepository: DayRepository(db, validateAndProject: validateAndProject),
    );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  test('失效日子本重新下载时在同一事务建立新绑定与有效修订', () async {
    const oldBinding = '55555555-5555-4555-8555-555555555555';
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: _a,
            name: '旧名称',
            scopeAccountId: const d.Value(_account),
            storageMode: const d.Value('cloud'),
            syncId: const d.Value(oldBinding),
            serverRevision: const d.Value(8),
            fullCursor: const d.Value('80'),
            isStale: const d.Value(true),
            createdAt: DateTime.utc(2026, 9),
            updatedAt: DateTime.utc(2026, 9),
          ),
        );
    adapter.respond = (request) => request.path.endsWith('/day-books')
        ? {
            'day_books': [_book(_a)],
            'server_cursor': '10',
          }
        : {'day_book': _book(_a), 'day_events': [], 'server_cursor': '10'};

    await sync.refreshTarget(const SyncTarget('day_book', _a));

    final book = await db.select(db.dayBooks).getSingle();
    expect(
      (book.syncId, book.serverRevision, book.fullCursor),
      (_binding, 1, '10'),
    );
    expect(book.name, 'A');
    expect(book.isStale, isFalse);
  });

  for (final confirmation in ['deleted', 'present', 'offline']) {
    test('两次拉取之间新本创建又删除，full404后目录$confirmation按权威结果推进', () async {
      await db
          .into(db.syncState)
          .insert(
            SyncStateCompanion.insert(
              deviceId: 'device',
              accountId: const d.Value(_account),
              serverCursor: const d.Value('10'),
              dayEventsCursor: const d.Value('10'),
            ),
          );
      adapter.respond = (request) {
        if (request.path.endsWith('/pull')) {
          return {
            'changes': [
              _bookChange(_a, '11'),
              _bookChange(_a, '12', deleted: true),
              _bookChange(_b, '13'),
            ],
            'server_cursor': '13',
            'has_more': false,
          };
        }
        if (request.path.endsWith('/day-books/full')) {
          if (request.queryParameters['day_book_id'] == _a) {
            throw DioException(
              requestOptions: request,
              response: Response<Object?>(
                requestOptions: request,
                statusCode: 404,
              ),
              type: DioExceptionType.badResponse,
            );
          }
          return {
            'day_book': _book(_b),
            'day_events': [],
            'server_cursor': '13',
          };
        }
        if (request.path.endsWith('/day-books')) {
          if (confirmation == 'offline') {
            throw DioException(
              requestOptions: request,
              type: DioExceptionType.connectionTimeout,
            );
          }
          return {
            'day_books': [if (confirmation == 'present') _book(_a), _book(_b)],
            'server_cursor': '13',
          };
        }
        throw StateError(request.path);
      };
      if (confirmation == 'deleted') {
        await sync.pull();
        expect((await db.select(db.dayBooks).get()).map((book) => book.id), [
          _b,
        ]);
        expect(
          (await db.select(db.syncState).getSingle()).dayEventsCursor,
          '13',
        );
      } else {
        await expectLater(sync.pull(), throwsA(isA<DioException>()));
        expect(await db.select(db.dayBooks).get(), isEmpty);
        expect(
          (await db.select(db.syncState).getSingle()).dayEventsCursor,
          '10',
        );
      }
      expect(
        adapter.paths,
        contains('/api/v1/sync/day-books'),
        reason: '404本身不能充当删除确认，必须核验同账号权威目录',
      );
    });
  }

  test('目录40之后的新本50不能被A的full60跳过', () async {
    adapter.respond = (request) {
      if (request.path.endsWith('/day-books')) {
        return {
          'day_books': [_book(_a)],
          'server_cursor': '40',
        };
      }
      if (request.path.endsWith('/day-books/full')) {
        return {
          'day_book': _book(request.queryParameters['day_book_id'] as String),
          'day_events': [],
          'server_cursor': '60',
        };
      }
      if (request.path.endsWith('/pull')) {
        return {
          'changes': [
            {
              'change_id': '50',
              'ledger_id': null,
              'day_book_id': _b,
              'entity_type': 'day_book',
              'entity_id': _b,
              'action': 'upsert',
              'mutation_id': 'remote',
              'payload': _book(_b),
              'updated_at': '2026-09-01T00:00:00.000Z',
              'device_id': 'remote',
            },
          ],
          'server_cursor': '60',
          'has_more': false,
        };
      }
      throw StateError(request.path);
    };
    await sync.discoverDayBooks();
    var state = await db.select(db.syncState).getSingle();
    expect(state.dayEventsCursor, '40');
    expect((await db.select(db.dayBooks).get()).single.fullCursor, '60');
    await sync.pull();
    expect((await db.select(db.dayBooks).get()).map((b) => b.id).toSet(), {
      _a,
      _b,
    });
    state = await db.select(db.syncState).getSingle();
    expect(state.dayEventsCursor, '60');
  });

  test('单本恢复只写本边界，不发现其他本或推进任一域', () async {
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(_account),
            serverCursor: const d.Value('35'),
            dayEventsCursor: const d.Value('40'),
          ),
        );
    adapter.respond = (request) => {
      'day_book': _book(_a),
      'day_events': [],
      'server_cursor': '60',
    };
    await sync.fullDayBook(dayBookId: _a);
    expect(adapter.paths, ['/api/v1/sync/day-books/full']);
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '35');
    expect(state.dayEventsCursor, '40');
  });

  test('第一页日子定义坏了，第二页记账仍消费且日子不跨缺口', () async {
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(_account),
            serverCursor: const d.Value('10'),
            dayEventsCursor: const d.Value('10'),
          ),
        );
    var page = 0;
    adapter.respond = (request) {
      if (request.path.endsWith('/day-books/full')) {
        throw StateError('损坏的父本无法补全');
      }
      page++;
      return {
        'changes': page == 1
            ? [
                {
                  'change_id': '11',
                  'ledger_id': null,
                  'day_book_id': _a,
                  'entity_type': 'day_event',
                  'entity_id': _b,
                  'action': 'upsert',
                  'mutation_id': 'bad',
                  'payload': {'name': '缺少定义'},
                  'updated_at': '2026-09-01T00:00:00.000Z',
                  'device_id': 'remote',
                },
              ]
            : [],
        'server_cursor': page == 1 ? '12' : '20',
        'has_more': page == 1,
      };
    };
    await expectLater(sync.pull(), throwsA(anything));
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '20');
    expect(state.dayEventsCursor, '10');
  });

  test('完整快照响应迟到时账号变化使整本零写入', () async {
    adapter.respond = (request) {
      account = 'another';
      return {'day_book': _book(_a), 'day_events': [], 'server_cursor': '60'};
    };
    await expectLater(sync.fullDayBook(dayBookId: _a), throwsStateError);
    expect(await db.select(db.dayBooks).get(), isEmpty);
  });

  test('同账号退出后重登也拒绝前一会话迟到的快照', () async {
    adapter.respond = (request) {
      generation++;
      return {'day_book': _book(_a), 'day_events': [], 'server_cursor': '60'};
    };
    await expectLater(sync.fullDayBook(dayBookId: _a), throwsStateError);
    expect(await db.select(db.dayBooks).get(), isEmpty);
  });

  test('未确认创建遇到full保留本地定义并绑定快照，不破坏约束', () async {
    final now = DateTime.utc(2026, 9, 1);
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: _a,
            name: '本地名称',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            serverRevision: const d.Value(0),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'day_book',
            entityId: _a,
            dayBookId: const d.Value(_a),
            accountId: const d.Value(_account),
            action: 'upsert',
            payload: '{"name":"本地名称"}',
            baseRevision: const d.Value(0),
            updatedAt: now,
            mutationId: '44444444-4444-4444-8444-444444444444',
          ),
        );
    adapter.respond = (request) => {
      'day_book': _book(_a),
      'day_events': [],
      'server_cursor': '60',
    };
    await sync.fullDayBook(dayBookId: _a);
    final book = await db.select(db.dayBooks).getSingle();
    expect(book.name, '本地名称');
    expect(book.syncId, _binding);
    expect(book.fullCursor, '60');
    expect((await db.select(db.syncConflicts).getSingle()).remoteRevision, 1);
  });

  test('仅选一个日子本重连时只请求该本且保留两域水位', () async {
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(_account),
            serverCursor: const d.Value('35'),
            dayEventsCursor: const d.Value('40'),
          ),
        );
    adapter.respond = (request) => {
      'day_book': _book(_a),
      'day_events': [],
      'server_cursor': '60',
    };
    await ReconnectV1Service(
      db: db,
      sync: sync,
    ).reconnectAfterLogin(dayBookIds: {_a});
    expect(adapter.paths, ['/api/v1/sync/day-books/full']);
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '35');
    expect(state.dayEventsCursor, '40');
  });

  test('记账full第二本落库失败时第一本和账号水位一起回滚', () async {
    Map<String, Object?> block(String id) => {
      'ledger': {
        'id': id,
        'sync_id': _binding,
        'name': '云本',
        'currency': 'CNY',
        'month_start_day': 1,
        'aa_enabled': false,
        'updated_at': '2026-09-01T00:00:00.000Z',
      },
      'members': [],
      'transactions': [],
      'categories': [],
      'recurring_transactions': [],
      'exchange_rate_overrides': [],
    };
    await db.customStatement(
      "CREATE TRIGGER reject_second BEFORE INSERT ON ledgers WHEN NEW.id = '$_b' BEGIN SELECT RAISE(ABORT, 'second book fault'); END",
    );
    adapter.respond = (request) => {
      'ledger_snapshots': [block(_a), block(_b)],
      'categories': [],
      'exchange_rate_overrides': [],
      'deleted_exchange_rate_override_ids': [],
      'server_cursor': '60',
    };
    await expectLater(sync.accountingFull(), throwsA(anything));
    expect(await db.select(db.ledgers).get(), isEmpty);
    expect(await db.select(db.syncState).get(), isEmpty);
  });

  test('记账页水位写入失败时整页业务事件回滚', () async {
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(_account),
            serverCursor: const d.Value('10'),
            dayEventsCursor: const d.Value('10'),
          ),
        );
    await db.customStatement(
      "CREATE TRIGGER reject_water BEFORE UPDATE ON sync_state WHEN NEW.server_cursor <> OLD.server_cursor BEGIN SELECT RAISE(ABORT, 'water fault'); END",
    );
    adapter.respond = (request) => request.path.endsWith('/sync/full')
        ? {
            'ledger': {
              'id': _a,
              'sync_id': _binding,
              'name': '不得半提交',
              'currency': 'CNY',
              'month_start_day': 1,
              'aa_enabled': false,
              'updated_at': '2026-09-01T00:00:00.000Z',
            },
            'members': [],
            'transactions': [],
            'categories': [],
            'recurring_transactions': [],
            'exchange_rate_overrides': [],
            'server_cursor': '12',
          }
        : {
            'changes': [
              {
                'change_id': '11',
                'ledger_id': _a,
                'entity_type': 'ledger',
                'entity_id': _a,
                'action': 'upsert',
                'mutation_id': 'remote',
                'payload': {
                  'name': '不得半提交',
                  'currency': 'CNY',
                  'month_start_day': 1,
                  'aa_enabled': false,
                  'sync_id': _binding,
                  'updated_at': '2026-09-01T00:00:00.000Z',
                },
                'updated_at': '2026-09-01T00:00:00.000Z',
                'device_id': 'remote',
              },
            ],
            'server_cursor': '12',
            'has_more': false,
          };
    await expectLater(sync.pull(), throwsA(anything));
    expect(await db.select(db.ledgers).get(), isEmpty);
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '10');
    expect(state.dayEventsCursor, '12');
  });
}

/// 可排列响应及故障的传输桩，保留请求路径用于范围断言。
class _DayAdapter implements HttpClientAdapter {
  late Map<String, Object?> Function(RequestOptions) respond;
  final paths = <String>[];

  /// 将固定契约样本送入生成客户端的真实反序列化。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.path);
    return ResponseBody.fromString(
      jsonEncode(respond(options)),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  /// 桩不持有外部资源。
  @override
  void close({bool force = false}) {}
}
