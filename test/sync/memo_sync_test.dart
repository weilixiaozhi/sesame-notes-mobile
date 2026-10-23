import 'package:sesame_notes/data/models/sync_issue.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart' as memos;
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

const a = '11111111-1111-4111-8111-111111111111';
const e = '22222222-2222-4222-8222-222222222222';
const binding = '33333333-3333-4333-8333-333333333333';
const owner = '44444444-4444-4444-8444-444444444444';
const time = '2026-09-08T12:34:56.789Z';
Map<String, Object?> book({int revision = 1}) => {
  'id': a,
  'name': '本',
  'type': 'normal',
  'sync_id': binding,
  'revision': revision,
  'created_at': time,
  'updated_at': time,
  'deleted_at': null,
};
Map<String, Object?> note(String title, {int revision = 1}) => {
  'id': e,
  'memo_book_id': a,
  'book_type': 'normal',
  'title': title,
  'body_format': 'delta_v1',
  'body': {
    'ops': [
      {'insert': ' \u0000中文😀\n\n'},
    ],
  },
  'account': null,
  'password': null,
  'phone': null,
  'email': null,
  'remark': null,
  'order_key': null,
  'created_at': time,
  'updated_at': time,
  'deleted_at': null,
  'sync_id': binding,
  'revision': revision,
  'book_updated_at': time,
};
memos.MemoEntry localNote(String title) => memos.MemoEntry(
  id: e,
  memoBookId: a,
  bookType: 'normal',
  title: title,
  bodyJson: jsonEncode(note(title)['body']),
  createdAt: DateTime.parse(time),
  updatedAt: DateTime.parse(time),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SesameApiClient client;
  late MemoRepository repo;
  late SyncService sync;
  late _Adapter adapter;
  String? account;
  int generation = 0;
  setUp(() {
    account = owner;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = MemoRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    adapter = _Adapter();
    client = SesameApiClient(basePathOverride: 'https://memos.test');
    client.dio.httpClientAdapter = adapter;
    sync = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      memoRepository: repo,
      dayRepository: DayRepository(db, validateAndProject: validateAndProject),
      currentAccountIdGetter: () => account,
      sessionGenerationGetter: () => generation,
    );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });
  Future<void> create() async {
    await repo.createBook(
      id: a,
      name: '本',
      type: 'normal',
      storageMode: 'cloud',
      createdAt: DateTime.parse(time),
    );
    await repo.saveEntry(
      localNote('本地'),
      await repo.target(a),
      preserveTimes: true,
    );
  }

  Future<void> bound() async {
    await create();
    await (db.delete(db.syncChanges)).go();
    await (db.update(db.memoBooks)..where((b) => b.id.equals(a))).write(
      const MemoBooksCompanion(
        syncId: d.Value(binding),
        serverRevision: d.Value(1),
        fullCursor: d.Value('10'),
      ),
    );
    await (db.update(db.memoEntries)..where((v) => v.id.equals(e))).write(
      const MemoEntriesCompanion(serverRevision: d.Value(1)),
    );
  }

  test('失效备忘录本重新下载时替换绑定并采用新时间线内容', () async {
    await bound();
    const oldBinding = '55555555-5555-4555-8555-555555555555';
    await (db.update(db.memoBooks)..where((row) => row.id.equals(a))).write(
      const MemoBooksCompanion(
        syncId: d.Value(oldBinding),
        serverRevision: d.Value(8),
        fullCursor: d.Value('80'),
        isStale: d.Value(true),
      ),
    );
    adapter.respond = (request, _) async => request.path.endsWith('/memo-books')
        ? {
            'memo_books': [
              {...book(), 'entry_count': 1},
            ],
            'server_cursor': '10',
          }
        : {
            'memo_book': book(),
            'memo_entries': [note('新时间线')],
            'server_cursor': '10',
          };

    await sync.refreshTarget(const SyncTarget('memo_book', a));

    final restored = await db.select(db.memoBooks).getSingle();
    expect(
      (restored.syncId, restored.serverRevision, restored.fullCursor),
      (binding, 1, '10'),
    );
    expect(restored.isStale, isFalse);
    expect((await db.select(db.memoEntries).getSingle()).title, '新时间线');
  });

  Map<String, Object?> accepted(
    Map<String, dynamic> change, {
    int revision = 1,
  }) => {
    'outcomes': [
      {
        'mutation_id': change['mutation_id'],
        'entity_id': change['entity_id'],
        'status': 'accepted',
        'revision': revision,
        'sync_id': binding,
        'change_id': '11',
      },
    ],
    'server_cursor': '11',
  };

  for (final type in ['normal', 'credentials']) {
    test('$type 标题原始字符在 full、pull 落库与 push 序列化时逐字保留', () async {
      try {
        // 单反斜杠转义在运行时生成真实 NUL，双反斜杠保留字面转义文本。
        final title = type == 'normal'
            ? '  首行\u0000与字面\\u0000😀  '
            : '\t账号\u0000标题\\u0000🔐\n';
        final snapshot = {
          ...note(title),
          'book_type': type,
          'body_format': type == 'normal' ? 'delta_v1' : 'fields_v1',
          'order_key': type == 'normal' ? null : '0',
          if (type == 'credentials')
            'body': {
              'fields': [
                {'label': '密码', 'value': '真实\u0000与字面\\u0000'},
              ],
            },
        };
        adapter.respond = (_, _) async => {
          'memo_book': {...book(), 'type': type},
          'memo_entries': [snapshot],
          'server_cursor': '10',
        };
        await sync.fullMemoBook(memoBookId: a);
        expect(
          (await db.select(db.memoEntries).getSingle()).title,
          title,
          reason: 'full 必须将完整标题原样落库',
        );

        // 增量使用不同标题与更高版本，确保断言验证实际更新后的持久化结果。
        await db
            .into(db.syncState)
            .insert(
              SyncStateCompanion.insert(
                deviceId: 'device',
                accountId: const d.Value(owner),
                serverCursor: const d.Value('10'),
                dayEventsCursor: const d.Value('10'),
                memosCursor: const d.Value('10'),
              ),
            );
        final pulledTitle = '\t修改$title\n';
        adapter.respond = (_, _) async => {
          'changes': [
            {
              'change_id': '11',
              'entity_type': 'memo_entry',
              'entity_id': e,
              'memo_book_id': a,
              'ledger_id': null,
              'day_book_id': null,
              'action': 'upsert',
              'payload': {...snapshot, 'title': pulledTitle, 'revision': 2},
              'updated_at': time,
              'mutation_id': 'remote',
              'device_id': 'remote',
            },
          ],
          'server_cursor': '11',
          'has_more': false,
        };
        await sync.pull();
        expect(
          (await db.select(db.memoEntries).getSingle()).title,
          pulledTitle,
          reason: 'pull 必须将修改后的完整标题原样落库',
        );

        await repo.saveEntry(
          memos.MemoEntry(
            id: e,
            memoBookId: a,
            bookType: type,
            title: title,
            bodyJson: jsonEncode(snapshot['body']),
            createdAt: DateTime.parse(time),
            updatedAt: DateTime.parse(time),
          ),
          await repo.target(a),
        );
        final sent = <Map<String, dynamic>>[];
        adapter.respond = (_, data) async {
          final change =
              (data!['changes'] as List).single as Map<String, dynamic>;
          sent.add(change);
          return accepted(change, revision: 3);
        };
        await sync.push();
        expect(sent, hasLength(1));
        expect(sent.single['entity_type'], 'memo_entry');
        expect(sent.single['base_revision'], 2);
        // 适配器从真实 HTTP 请求字节解码 JSON，覆盖生成客户端的完整序列化路径。
        expect(
          (sent.single['payload'] as Map)['title'],
          title,
          reason: 'push 必须逐字保留真实 NUL、字面转义、前后空白和 emoji',
        );
        expect((sent.single['payload'] as Map)['book_type'], type);
      } catch (error, stackTrace) {
        fail('$type 标题原始字符同步回归失败：$error\n$stackTrace');
      }
    });
  }

  test('小正文合并上传，大正文按字节预算拆分且全部得到确认', () async {
    await bound();
    final target = await repo.target(a);
    for (var i = 1; i <= 8; i++) {
      await repo.saveEntry(
        memos.MemoEntry(
          id: '55555555-5555-4555-8555-${i.toString().padLeft(12, '0')}',
          memoBookId: a,
          bookType: 'normal',
          title: '$i',
          bodyJson: jsonEncode({
            'ops': [
              {'insert': '${i <= 2 ? '中' * 180000 : '小正文'}\n'},
            ],
          }),
          createdAt: DateTime.parse(time),
          updatedAt: DateTime.parse(time),
        ),
        target,
      );
    }
    final counts = <int>[];
    adapter.respond = (options, data) async {
      final changes = (data!['changes'] as List).cast<Map<String, dynamic>>();
      expect(
        utf8.encode(jsonEncode(data)).length,
        lessThanOrEqualTo(1024 * 1024),
      );
      counts.add(changes.length);
      return {
        'outcomes': [
          for (final change in changes)
            (accepted(change)['outcomes'] as List).single,
        ],
        'server_cursor': '11',
      };
    };
    await sync.push();
    expect(counts.reduce((a, b) => a + b), 8);
    expect(counts.length, lessThan(8));
    expect(counts.length, greaterThan(1));
    expect(
      await (db.select(
        db.syncChanges,
      )..where((c) => c.pushedAt.isNull())).get(),
      isEmpty,
    );
  });

  test('移动删除响应丢失时保留隐藏副本，重放冻结请求后只发布同一份', () async {
    await bound();
    await repo.saveEntry(localNote('离线修改'), await repo.target(a));
    final sent = <Map<String, dynamic>>[];
    var loseResponse = true;
    adapter.respond = (options, data) async {
      if (options.method == 'GET') {
        return {
          'memo_book': book(),
          'memo_entries': [note('离线修改', revision: 2)],
          'server_cursor': '12',
        };
      }
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      if (change['action'] != 'delete') return accepted(change, revision: 2);
      sent.add(change);
      expect(change['entity_type'], 'memo_book');
      expect((change['payload'] as Map)['expected_full_cursor'], '12');
      if (loseResponse) {
        loseResponse = false;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return accepted(change, revision: 2);
    };
    await expectLater(
      sync.transferToLocal(const SyncTarget('memo_book', a), move: true),
      throwsA(isA<DioException>()),
    );
    final hidden = await (db.select(
      db.memoBooks,
    )..where((b) => b.isHidden.equals(true))).getSingle();
    expect(
      (await (db.select(
        db.memoEntries,
      )..where((e) => e.memoBookId.equals(hidden.id))).getSingle()).title,
      '离线修改',
    );
    expect(await repo.getBook(a, accountId: owner), isNull);
    final localId = await sync.transferToLocal(
      const SyncTarget('memo_book', a),
      move: true,
    );
    expect(localId, hidden.id);
    expect(sent, hasLength(2));
    expect(sent[0], sent[1]);
    expect((await repo.getEntries(localId)).single.title, '离线修改');
    expect((await repo.getBooks(accountId: owner)).map((b) => b.id), [localId]);
    expect(
      (await db.select(db.syncChanges).get()).every((c) => c.pushedAt != null),
      isTrue,
    );
  });

  test('移动删除被拒绝后重读完整内容，刷新原隐藏副本并重新确认删除', () async {
    await bound();
    var rejected = true;
    adapter.respond = (options, data) async {
      if (options.method == 'GET') {
        return {
          'memo_book': book(),
          'memo_entries': [
            note(rejected ? '本地' : '另一设备修改', revision: rejected ? 1 : 2),
            if (!rejected)
              {...note('另一设备新增'), 'id': '55555555-5555-4555-8555-555555555555'},
          ],
          'server_cursor': rejected ? '12' : '20',
        };
      }
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      if (rejected) {
        return {
          'outcomes': [
            {
              'mutation_id': change['mutation_id'],
              'entity_id': change['entity_id'],
              'status': 'invalid',
              'message': '内容已变化，请刷新后重新确认',
            },
          ],
          'server_cursor': '13',
        };
      }
      expect((change['payload'] as Map)['expected_full_cursor'], '20');
      return accepted(change, revision: 2);
    };
    await expectLater(
      sync.transferToLocal(const SyncTarget('memo_book', a), move: true),
      throwsStateError,
    );
    final hidden = await (db.select(
      db.memoBooks,
    )..where((b) => b.isHidden.equals(true))).getSingle();
    expect(
      (await db.select(db.syncChanges).getSingle()).rejectionReason,
      isNotNull,
    );
    rejected = false;
    await expectLater(
      sync.transferToLocal(const SyncTarget('memo_book', a), move: true),
      throwsStateError,
    );
    final preview = await sync.prepareScopeDelete(
      const SyncTarget('memo_book', a),
    );
    expect(preview.count, 2);
    await sync.confirmScopeDelete(preview);
    final localId = hidden.id;
    expect((await repo.getEntries(localId)).map((e) => e.title).toSet(), {
      '另一设备修改',
      '另一设备新增',
    });
    expect(await repo.getBook(a, accountId: owner), isNull);
    expect((await repo.getBooks(accountId: owner)).length, 1);
  });

  test('完整本消费增量后离线删除使用新快照水位，未确认分支不提升水位', () async {
    await bound();
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(owner),
            serverCursor: const d.Value('10'),
            dayEventsCursor: const d.Value('10'),
            memosCursor: const d.Value('10'),
          ),
        );
    adapter.respond = (_, _) async => {
      'changes': [],
      'server_cursor': '20',
      'has_more': false,
    };
    await sync.pull();
    expect((await repo.getBook(a, accountId: owner))!.fullCursor, '20');
    await repo.saveEntry(localNote('尚未确认'), await repo.target(a));
    adapter.respond = (_, _) async => {
      'changes': [],
      'server_cursor': '30',
      'has_more': false,
    };
    await sync.pull();
    expect((await repo.getBook(a, accountId: owner))!.fullCursor, '20');
    await repo.deleteBook(await repo.target(a), expectedCount: 1);
    final deletion = (await db.select(db.syncChanges).get()).singleWhere(
      (c) => c.action == 'delete',
    );
    expect(jsonDecode(deletion.payload)['expected_full_cursor'], '20');
  });

  test('父本先绑定、子项后发送，真实生成客户端保留正文与毫秒', () async {
    await create();
    final sent = <Map<String, dynamic>>[];
    adapter.respond = (options, data) async {
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      sent.add(change);
      final queued =
          await (db.select(db.syncChanges)..where(
                (c) => c.mutationId.equals(change['mutation_id'] as String),
              ))
              .getSingle();
      expect(jsonDecode(queued.frozenRequest!), change);
      return accepted(change);
    };
    await sync.push();
    expect(sent.map((c) => c['entity_type']), ['memo_book', 'memo_entry']);
    expect(sent.last['sync_id'], binding);
    expect((sent.last['payload'] as Map)['body'], note('')['body']);
    expect((sent.last['payload'] as Map)['created_at'], time);
    expect(
      (await repo.getEntries(a, accountId: owner)).single.serverRevision,
      1,
    );
    expect((await repo.getBook(a, accountId: owner))!.isComplete, isTrue);
  });
  test('云端整本恢复父本新代确认后发送同ID子项，丢失响应不改写冻结请求', () async {
    await bound();
    final source = (await repo.getBook(a, accountId: owner))!;
    await repo.restoreSnapshot(
      book: source,
      entries: [localNote('恢复内容')],
      receipts: [],
      cloud: true,
    );
    const nextBinding = '55555555-5555-4555-8555-555555555555';
    final sent = <Map<String, dynamic>>[];
    var fail = true;
    adapter.respond = (options, data) async {
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      sent.add(change);
      if (fail) {
        fail = false;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return {
        'outcomes': [
          {
            'mutation_id': change['mutation_id'],
            'entity_id': change['entity_id'],
            'status': 'accepted',
            'revision': 1,
            'sync_id': nextBinding,
            'change_id': '15',
          },
        ],
        'server_cursor': '15',
      };
    };
    await expectLater(sync.push(), throwsA(anything));
    await sync.push();
    expect(sent, hasLength(3));
    expect(sent[0], sent[1]);
    expect((sent[0]['payload'] as Map)['restore'], true);
    expect((sent[0]['payload'] as Map)['expected_full_cursor'], '10');
    expect(sent[2]['sync_id'], nextBinding);
    expect(sent[2]['entity_id'], e);
    expect(sent[2]['base_revision'], 0);
    expect((await repo.getBook(a, accountId: owner))!.syncId, nextBinding);
    expect((await repo.getEntries(a, accountId: owner)).single.title, '恢复内容');
  });
  test('丢失响应后原样重放冻结请求，后续输入使用确认后的 CAS', () async {
    await bound();
    final target = await repo.target(a);
    await repo.saveEntry(localNote('第一版'), target);
    final sent = <Map<String, dynamic>>[];
    var fail = true;
    adapter.respond = (options, data) async {
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      sent.add(change);
      if (fail) {
        fail = false;
        await repo.saveEntry(localNote('最后输入'), target);
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      }
      return accepted(change, revision: sent.length == 2 ? 2 : 3);
    };
    await expectLater(sync.push(), throwsA(anything));
    await sync.push();
    expect(sent[1], sent[0]);
    expect(sent[2]['base_revision'], 2);
    expect((sent[2]['payload'] as Map)['title'], '最后输入');
    expect((await repo.getEntries(a, accountId: owner)).single.title, '最后输入');
  });
  test('并发冲突保留在途输入，等待全局明确选择后采用远端', () async {
    await bound();
    final target = await repo.target(a);
    await repo.saveEntry(localNote('发出版本'), target);
    var conflicted = false;
    adapter.respond = (options, data) async {
      final change = (data!['changes'] as List).single as Map<String, dynamic>;
      if (!conflicted) {
        conflicted = true;
        await repo.saveEntry(localNote('在途最新输入'), target);
        return {
          'outcomes': [
            {
              'mutation_id': change['mutation_id'],
              'entity_id': e,
              'status': 'conflict',
              'current_revision': 2,
              'current_deleted': false,
              'current_entity': note('远端版本', revision: 2),
              'change_id': null,
            },
          ],
          'server_cursor': '12',
        };
      }
      return accepted(change);
    };
    await sync.push();
    var rows = await repo.getEntries(a, accountId: owner);
    expect(rows.single.title, '在途最新输入');
    final conflict = await db.select(db.syncConflicts).getSingle();
    expect(conflict.status, 'OPEN');
    expect(jsonDecode(conflict.localPayload)['title'], '在途最新输入');
    await sync.push();
    expect((await repo.getEntries(a, accountId: owner)).single.title, '在途最新输入');
    await sync.resolveConflictAdoptRemote(conflict.id);
    rows = await repo.getEntries(a, accountId: owner);
    expect(rows.single.title, '远端版本');
    expect(rows.single.serverRevision, 2);
    expect(
      (await db.select(db.syncConflicts).getSingle()).status,
      'RESOLVED_REMOTE',
    );
    await sync.push();
    expect(await repo.getEntries(a, accountId: owner), hasLength(1));
  });
  for (final missingField in ['current_revision', 'current_entity']) {
    test('备忘录冲突缺少$missingField不能伪造可解决的冲突', () async {
      await bound();
      await repo.saveEntry(localNote('本地输入'), await repo.target(a));
      adapter.respond = (_, data) async {
        final change = (data!['changes'] as List).single as Map;
        final outcome = <String, Object?>{
          'mutation_id': change['mutation_id'],
          'entity_id': e,
          'status': 'conflict',
          'current_revision': 2,
          'current_deleted': false,
          'current_entity': note('远端', revision: 2),
        }..remove(missingField);
        return {
          'outcomes': [outcome],
          'server_cursor': '12',
        };
      };

      await expectLater(sync.push(), throwsA(isA<FormatException>()));

      expect(await db.select(db.syncConflicts).get(), isEmpty);
      final pending = await (db.select(
        db.syncChanges,
      )..where((change) => change.pushedAt.isNull())).getSingle();
      expect(pending.frozenRequest, isNotNull);
      expect(pending.rejectionReason, isNull);
      expect(jsonDecode(pending.payload)['title'], '本地输入');
      final local = await db.select(db.memoEntries).getSingle();
      expect(local.title, '本地输入');
      expect(local.serverRevision, 1);
      expect(local.deletedAt, isNull);
    });
  }

  for (final keepLocal in [false, true]) {
    test('云端明确不存在的备忘录${keepLocal ? '保留本地副本' : '采用远端落墓碑'}', () async {
      await bound();
      await repo.saveEntry(localNote('需要保留的输入'), await repo.target(a));
      adapter.respond = (_, data) async {
        final change = (data!['changes'] as List).single as Map;
        return {
          'outcomes': [
            {
              'mutation_id': change['mutation_id'],
              'entity_id': e,
              'status': 'conflict',
              'current_revision': 0,
              'current_deleted': true,
              'current_entity': null,
            },
          ],
          'server_cursor': '12',
        };
      };
      await sync.push();
      final conflict = await db.select(db.syncConflicts).getSingle();
      expect(conflict.remoteRevision, 0);
      if (keepLocal) {
        await sync.resolveConflictKeepLocal(conflict.id);
      } else {
        await sync.resolveConflictAdoptRemote(conflict.id);
      }

      final original = await (db.select(
        db.memoEntries,
      )..where((entry) => entry.id.equals(e))).getSingle();
      expect(original.deletedAt, isNotNull);
      expect(original.serverRevision, 0);
      expect(original.title, '需要保留的输入');
      expect(
        await (db.select(
          db.syncChanges,
        )..where((change) => change.pushedAt.isNull())).get(),
        isEmpty,
      );
      final active = await (db.select(
        db.memoEntries,
      )..where((entry) => entry.deletedAt.isNull())).get();
      expect(active.length, keepLocal ? 1 : 0);
      if (keepLocal) {
        expect(active.single.id, isNot(e));
        expect(active.single.title, '需要保留的输入');
        final preservedBook =
            await (db.select(db.memoBooks)
                  ..where((book) => book.id.equals(active.single.memoBookId)))
                .getSingle();
        expect(preservedBook.storageMode, 'local');
      }
      expect(
        (await db.select(db.syncConflicts).getSingle()).status,
        keepLocal ? 'RESOLVED_LOCAL' : 'RESOLVED_REMOTE',
      );
    });
  }

  test('备忘录失败时其水位不前进，其余两域即使无事件也独立提交', () async {
    await bound();
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(owner),
            serverCursor: const d.Value('10'),
            dayEventsCursor: const d.Value('10'),
            memosCursor: const d.Value('10'),
          ),
        );
    adapter.respond = (_, _) async => {
      'changes': [
        {
          'change_id': '11',
          'entity_type': 'memo_entry',
          'entity_id': e,
          'memo_book_id': a,
          'ledger_id': null,
          'day_book_id': null,
          'action': 'upsert',
          'payload': {'memo_book_id': a},
          'updated_at': time,
          'mutation_id': 'remote',
          'device_id': 'remote',
        },
      ],
      'server_cursor': '20',
      'has_more': false,
    };
    await expectLater(sync.pull(), throwsA(anything));
    final state = await db.select(db.syncState).getSingle();
    expect(state.serverCursor, '20');
    expect(state.dayEventsCursor, '20');
    expect(state.memosCursor, '10');
    expect((await repo.getEntries(a, accountId: owner)).single.title, '本地');
    expect((await db.select(db.syncPullErrors).getSingle()).memoBookId, a);
  });
  test('单本 full 原子应用并保留内容时间，不提升域水位；换号响应拒绝落库', () async {
    await bound();
    await db
        .into(db.syncState)
        .insert(
          SyncStateCompanion.insert(
            deviceId: 'device',
            accountId: const d.Value(owner),
            memosCursor: const d.Value('10'),
          ),
        );
    adapter.respond = (_, _) async => {
      'memo_book': book(),
      'memo_entries': [note('远端', revision: 2)],
      'server_cursor': '100',
    };
    await sync.fullMemoBook(memoBookId: a);
    expect((await db.select(db.syncState).getSingle()).memosCursor, '10');
    expect(
      (await repo.getEntries(a, accountId: owner)).single.createdAt,
      DateTime.parse(time),
    );
    adapter.respond = (_, _) async {
      generation++;
      return {
        'memo_book': book(),
        'memo_entries': [note('不得落库', revision: 3)],
        'server_cursor': '110',
      };
    };
    await expectLater(sync.fullMemoBook(memoBookId: a), throwsA(anything));
    expect((await repo.getEntries(a, accountId: owner)).single.title, '远端');
  });
}

class _Adapter implements HttpClientAdapter {
  late Future<Map<String, Object?>> Function(
    RequestOptions,
    Map<String, dynamic>?,
  )
  respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    Map<String, dynamic>? data;
    if (requestStream != null) {
      final bytes = BytesBuilder();
      await for (final chunk in requestStream) {
        bytes.add(chunk);
      }
      if (bytes.length > 0) {
        data =
            jsonDecode(utf8.decode(bytes.takeBytes())) as Map<String, dynamic>;
      }
    }
    return ResponseBody.fromString(
      jsonEncode(await respond(options, data)),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
