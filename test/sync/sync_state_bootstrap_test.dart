import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart' as memos;
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../helpers/database_schema_fixture.dart';
import '../helpers/test_isolation.dart';

const _account = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
const _device = '66666666-6666-4666-8666-666666666666';
const _binding = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
const _dayBook = '11111111-1111-4111-8111-111111111111';
const _memoBook = '22222222-2222-4222-8222-222222222222';
const _memoEntry = '33333333-3333-4333-8333-333333333333';
const _fitnessSpace = '44444444-4444-4444-8444-444444444444';
const _stamp = '2026-10-20T00:00:00.123Z';

/// 仅替换 HTTP，真实 SDK 解码、四域完整快照、推送确认和数据库事务均参与回归。
class _BootstrapTransport implements HttpClientAdapter {
  _BootstrapTransport(this.highWater) : cut = highWater;

  int highWater;
  final int cut;
  final failedFull = <String>{};
  final calls = <String>[];
  final sent = <Map<String, dynamic>>[];
  Completer<void>? accountingGate;
  final accountingEntered = Completer<void>();

  /// 模拟当前接口的目录快照及 H 边界；已初始化的合法零水位不会收到 410。
  @override
  Future<ResponseBody> fetch(
    RequestOptions request,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final domain = request.path.endsWith('/accounting/full')
        ? 'accounting'
        : request.path.endsWith('/day-books')
        ? 'days'
        : request.path.endsWith('/memo-books')
        ? 'memos'
        : request.path.endsWith('/fitness-spaces')
        ? 'fitness'
        : null;
    if (domain != null) {
      calls.add('full:$domain');
      if (domain == 'accounting') {
        if (!accountingEntered.isCompleted) accountingEntered.complete();
        await accountingGate?.future;
      }
      if (failedFull.contains(domain)) {
        return _response({'error': 'unavailable'}, 503);
      }
      return _response({
        if (domain == 'accounting') ...{
          'ledger_snapshots': [],
          'categories': [
            {
              'id': '55555555-5555-4555-8555-555555555555',
              'owner_id': _account,
              'name': '远端分类',
              'kind': 'expense',
              'level': 1,
              'sort_order': 0,
              'icon': null,
              'parent_id': null,
              'updated_at': _stamp,
              'deleted_at': null,
              'version_token': 'a' * 64,
            },
          ],
          'category_tombstones': [],
          'exchange_rate_overrides': [],
          'deleted_exchange_rate_override_ids': [],
        } else if (domain == 'days')
          'day_books': []
        else if (domain == 'memos')
          'memo_books': []
        else
          'fitness_spaces': [],
        'server_cursor': '$highWater',
      });
    }
    if (request.path.endsWith('/push')) {
      calls.add('push');
      final body = jsonDecode(request.data as String) as Map;
      final changes = [
        for (final change in body['changes'] as List)
          Map<String, dynamic>.from(change as Map),
      ];
      sent.addAll(changes);
      return _response({
        'server_cursor': '${++highWater}',
        'outcomes': [
          for (final change in changes)
            {
              'mutation_id': change['mutation_id'],
              'entity_id': change['entity_id'],
              'status': 'accepted',
              'change_id': '$highWater',
              'revision': 1,
              'sync_id': _binding,
            },
        ],
      });
    }
    if (request.path.endsWith('/pull')) {
      final since = request.queryParameters['since'].toString();
      calls.add('pull:$since');
      if (BigInt.parse(since) < BigInt.from(cut)) {
        return _response({'error': 'cursor_expired'}, 410);
      }
      return _response({
        'changes': [],
        'server_cursor': '$highWater',
        'has_more': false,
      });
    }
    throw StateError('未预期的同步接口：${request.path}');
  }

  /// 保持实际 JSON 传输与状态码边界，避免绕过生成客户端的结构校验。
  ResponseBody _response(Map<String, Object?> body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );

  /// 传输夹具不持有外部连接。
  @override
  void close({bool force = false}) {}
}

/// 使用内存库或真实历史文件库，验证各域完整同步先于普通发送。
class _BootstrapFixture {
  _BootstrapFixture(int highWater, {SesameDatabase? database})
    : db = database ?? SesameDatabase.withExecutor(NativeDatabase.memory()),
      transport = _BootstrapTransport(highWater) {
    client.dio.httpClientAdapter = transport;
    recorder = ChangeRecorderImpl(db, accountIdGetter: () => account);
    accounting = LocalRepository(
      db,
      changeTracker: recorder,
      accountIdGetter: () => account,
    );
    days = DayRepository(
      db,
      validateAndProject: validateAndProject,
      changeRecorder: recorder,
      accountIdGetter: () => account,
      generationGetter: () => generation,
    );
    memosRepository = MemoRepository(
      db,
      changeRecorder: recorder,
      accountIdGetter: () => account,
      generationGetter: () => generation,
    );
    fitnessSpaces = FitnessSpaceRepository(
      db,
      changeRecorder: recorder,
      accountIdGetter: () => account,
      generationGetter: () => generation,
    );
    service = SyncService(
      client: client,
      db: db,
      deviceId: _device,
      repo: accounting.ledgerStore,
      dayRepository: days,
      memoRepository: memosRepository,
      fitnessEnabled: true,
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
    );
  }

  final SesameDatabase db;
  final client = SesameApiClient(
    basePathOverride: 'https://bootstrap.test',
    serializers: apiSerializers,
  );
  final _BootstrapTransport transport;
  String account = _account;
  int generation = 1;
  late final ChangeRecorderImpl recorder;
  late final LocalRepository accounting;
  late final DayRepository days;
  late final MemoRepository memosRepository;
  late final FitnessSpaceRepository fitnessSpaces;
  late final SyncService service;

  /// 省略四域游标，验证当前表的缺省值确实是未完成初始化。
  Future<void> seedUninitialized() => db
      .into(db.syncState)
      .insert(
        SyncStateCompanion.insert(
          deviceId: _device,
          accountId: const d.Value(_account),
        ),
      )
      .then((_) {});

  /// 从实际持久行读取四域水位，合法的字符串零与 NULL 保持不同。
  Future<List<String?>> cursors() async {
    final state = await db.select(db.syncState).getSingle();
    return [
      state.serverCursor,
      state.dayEventsCursor,
      state.memosCursor,
      state.fitnessCursor,
    ];
  }

  /// 用户在首次联网前创建云父本及内容，完整目录尚无这些未登记实体。
  Future<void> createPendingParents() async {
    final ledger = await accounting.createLedger(
      name: '新云账本',
      storageMode: 'cloud',
    );
    await accounting.addTransaction(
      ledgerId: ledger,
      type: 'expense',
      amount: '12.34',
      happenedAt: DateTime.parse(_stamp),
    );
    await days.createBook(id: _dayBook, name: '新日子本', storageMode: 'cloud');
    await memosRepository.createBook(
      id: _memoBook,
      name: '新笔记本',
      type: 'normal',
      storageMode: 'cloud',
    );
    await memosRepository.saveEntry(
      memos.MemoEntry(
        id: _memoEntry,
        memoBookId: _memoBook,
        bookType: 'normal',
        title: '未上云正文',
        bodyJson: jsonEncode({
          'ops': [
            {'insert': '本机内容\n'},
          ],
        }),
        createdAt: DateTime.parse(_stamp),
        updatedAt: DateTime.parse(_stamp),
      ),
      await memosRepository.target(_memoBook),
    );
    await fitnessSpaces.createBook(
      id: _fitnessSpace,
      name: '新健身空间',
      storageMode: 'cloud',
    );
  }

  /// 关闭连接与数据库，等待被挂起的真实同步结束由测试显式负责。
  Future<void> dispose() async {
    client.dio.close(force: true);
    await db.close();
  }
}

/// 初始化由持久 NULL 决定，接口 H 数值和合法的零游标不承担初始化状态。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  for (final scenario in [
    (version: 4, old: '0', h: 0),
    (version: 7, old: '50', h: 50),
    (version: 8, old: '9007199254740993', h: 50),
  ]) {
    test(
      '真实schema${scenario.version}旧游标${scenario.old}迁移后先完成四域full再推拉',
      () async {
        final directory = await createTestTempDirectory(
          'sync-bootstrap-migration-',
        );
        _BootstrapFixture? fixture;
        try {
          final file = File('${directory.path}/historical.sqlite');
          await createHistoricalDatabaseFixture(file, scenario.version);
          final raw = sql.sqlite3.open(file.path);
          try {
            // 原始连接保留历史非空约束，把四域旧值及身份写入同一真实设备状态行。
            raw.execute(
              'UPDATE sync_state SET account_id=?,device_id=?,server_cursor=?,day_events_cursor=?,memos_cursor=?,fitness_cursor=?',
              [_account, _device, ...List.filled(4, scenario.old)],
            );
            expect(
              raw.select('PRAGMA user_version').single.values.single,
              scenario.version,
            );
            final cursorColumn = raw
                .select('PRAGMA table_info(sync_state)')
                .singleWhere((column) => column['name'] == 'server_cursor');
            expect(cursorColumn['notnull'], 1);
            expect(cursorColumn['dflt_value'], "'0'");
            expect(
              raw
                  .select('SELECT server_cursor FROM sync_state')
                  .single['server_cursor'],
              scenario.old,
            );
          } finally {
            raw.close();
          }

          final migrated = _BootstrapFixture(
            scenario.h,
            database: SesameDatabase.withExecutor(NativeDatabase(file)),
          );
          fixture = migrated;
          // 首次读取真实触发升级；迁移后的空值要求四域分别建立完整基线。
          expect(await migrated.cursors(), [null, null, null, null]);
          await migrated.createPendingParents();
          expect(await migrated.service.synchronize(), 0);
          expect(migrated.transport.calls.take(4), [
            'full:accounting',
            'full:days',
            'full:memos',
            'full:fitness',
          ]);
          expect(
            migrated.transport.calls.indexOf('push'),
            greaterThanOrEqualTo(4),
          );
          expect(migrated.transport.sent, isNotEmpty);
          // push 返回的较高水位只确认本机变更，增量仍从完整快照水位开始消费。
          expect(
            migrated.transport.calls.where((call) => call.startsWith('pull:')),
            ['pull:${scenario.h}'],
          );
          expect(
            await migrated.cursors(),
            List.filled(4, '${migrated.transport.highWater}'),
          );
        } catch (error, stackTrace) {
          logger.error(
            'SyncBootstrapTest',
            '历史库迁移后的首次同步回归失败',
            error,
            stackTrace,
          );
          rethrow;
        } finally {
          try {
            await fixture?.dispose();
          } finally {
            final root =
                '${Directory('Temp').absolute.path}${Platform.pathSeparator}';
            if (!directory.absolute.path.startsWith(root)) {
              throw StateError('测试目录不在 Temp 内');
            }
            await directory.delete(recursive: true);
          }
        }
      },
    );
  }

  test('仅日子域初始化成功不把记账与其他域伪装就绪，下一轮只补未完成域', () async {
    final fixture = _BootstrapFixture(0);
    try {
      await fixture.seedUninitialized();
      fixture.transport.failedFull.addAll(['accounting', 'memos', 'fitness']);
      await expectLater(fixture.service.pull(), throwsA(isA<DioException>()));
      expect(await fixture.cursors(), [null, '0', null, null]);
      fixture.transport.calls.clear();
      fixture.transport.failedFull.clear();
      await fixture.service.pull();
      expect(fixture.transport.calls, [
        'full:accounting',
        'full:memos',
        'full:fitness',
        'pull:0',
      ]);
      expect(await fixture.cursors(), ['0', '0', '0', '0']);
    } finally {
      await fixture.dispose();
    }
  });

  test('完整快照实际落库失败不写该域水位，其他域成功结果仍保留', () async {
    final fixture = _BootstrapFixture(50);
    try {
      await fixture.seedUninitialized();
      await fixture.db.customStatement(
        "CREATE TRIGGER fail_bootstrap BEFORE INSERT ON categories BEGIN SELECT RAISE(ABORT,'bootstrap projection failed'); END",
      );
      await expectLater(
        fixture.service.pull(),
        throwsA(isA<SqliteException>()),
      );
      expect(await fixture.cursors(), [null, '50', '50', '50']);
      expect(await fixture.db.select(fixture.db.categories).get(), isEmpty);
      await fixture.db.customStatement('DROP TRIGGER fail_bootstrap');
      await fixture.service.pull();
      expect(await fixture.cursors(), ['50', '50', '50', '50']);
    } finally {
      await fixture.dispose();
    }
  });

  test('已完整初始化的合法零游标直接增量消费，不重复full', () async {
    final fixture = _BootstrapFixture(0);
    try {
      await fixture.db
          .into(fixture.db.syncState)
          .insert(
            SyncStateCompanion.insert(
              deviceId: _device,
              accountId: const d.Value(_account),
              serverCursor: const d.Value('0'),
              dayEventsCursor: const d.Value('0'),
              memosCursor: const d.Value('0'),
              fitnessCursor: const d.Value('0'),
            ),
          );
      await fixture.service.pull();
      expect(fixture.transport.calls, ['pull:0']);
      expect(await fixture.cursors(), ['0', '0', '0', '0']);
    } finally {
      await fixture.dispose();
    }
  });

  test('首次完整同步先full再推送新父本与内容，目录缺失不能隔离尚未登记的新本', () async {
    final fixture = _BootstrapFixture(0);
    try {
      await fixture.seedUninitialized();
      await fixture.createPendingParents();
      await fixture.service.synchronize();
      expect(fixture.transport.calls.take(4), [
        'full:accounting',
        'full:days',
        'full:memos',
        'full:fitness',
      ]);
      expect(fixture.transport.calls.last, startsWith('pull:'));
      expect(
        fixture.transport.sent.map((c) => c['entity_type']).toSet(),
        containsAll([
          'ledger',
          'transaction',
          'day_book',
          'memo_book',
          'memo_entry',
          'fitness_space',
        ]),
      );
      final ledger = await fixture.db.select(fixture.db.ledgers).getSingle();
      expect(ledger.bindingStatus, isNot('stale'));
      expect(ledger.deletedAt, isNull);
      expect(ledger.syncId, _binding);
      expect(
        (await fixture.db.select(fixture.db.dayBooks).getSingle()).isStale,
        isFalse,
      );
      expect(
        (await fixture.db.select(fixture.db.memoBooks).getSingle()).isHidden,
        isFalse,
      );
      expect(
        (await fixture.db.select(fixture.db.memoBooks).getSingle()).isStale,
        isFalse,
      );
      expect(
        (await fixture.db.select(fixture.db.fitnessSpaces).getSingle()).isStale,
        isFalse,
      );
      expect(
        (await fixture.db.select(fixture.db.memoEntries).getSingle()).title,
        '未上云正文',
      );
      expect(
        (await fixture.db.select(fixture.db.syncChanges).get()).every(
          (c) => c.pushedAt != null,
        ),
        isTrue,
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('单域full失败只阻止该域上行，成功域继续完成push与唯一增量扫描', () async {
    final fixture = _BootstrapFixture(50);
    try {
      await fixture.seedUninitialized();
      await fixture.createPendingParents();
      fixture.transport.failedFull.add('memos');
      await expectLater(
        fixture.service.synchronize(),
        throwsA(isA<DioException>()),
      );
      final types = fixture.transport.sent.map((c) => c['entity_type']).toSet();
      expect(
        types,
        containsAll(['ledger', 'transaction', 'day_book', 'fitness_space']),
      );
      expect(types, isNot(contains('memo_book')));
      expect(types, isNot(contains('memo_entry')));
      expect(
        fixture.transport.calls.where((c) => c.startsWith('pull:')),
        hasLength(1),
      );
      final state = await fixture.cursors();
      expect(state[2], isNull);
      expect([state[0], state[1], state[3]].every((c) => c != null), isTrue);
      final pending = await (fixture.db.select(
        fixture.db.syncChanges,
      )..where((c) => c.memoBookId.equals(_memoBook))).get();
      expect(pending, hasLength(2));
      expect(
        pending.every((c) => c.pushedAt == null && c.frozenRequest == null),
        isTrue,
      );
    } finally {
      await fixture.dispose();
    }
  });

  test('full在途期间换账号，迟到快照不能落水位或触发任何域上行', () async {
    final fixture = _BootstrapFixture(50);
    final gate = Completer<void>();
    fixture.transport.accountingGate = gate;
    Future<int>? pulling;
    try {
      await fixture.seedUninitialized();
      await fixture.createPendingParents();
      pulling = fixture.service.synchronize();
      final failure = expectLater(pulling, throwsStateError);
      await fixture.transport.accountingEntered.future;
      expect(await fixture.cursors(), [null, null, null, null]);
      fixture.account = 'different-account';
      fixture.generation++;
      gate.complete();
      await failure;
      expect(await fixture.cursors(), [null, null, null, null]);
      expect(fixture.transport.sent, isEmpty);
    } finally {
      if (!gate.isCompleted) gate.complete();
      try {
        await pulling;
      } catch (_) {}
      await fixture.dispose();
    }
  });
}
