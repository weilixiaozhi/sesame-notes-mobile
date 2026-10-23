import 'dart:convert';

import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart' hide Transaction;
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

class _SyncApi extends Mock implements SyncApi {}

const _ledgerId = '10000000-0000-4000-8000-000000000001';
const _transactionId = '10000000-0000-4000-8000-000000000002';
const _memberId = '10000000-0000-4000-8000-000000000003';
const _recurringId = '10000000-0000-4000-8000-000000000004';
const _time = '2026-09-10T10:00:00.000Z';

/// 与服务端权威交易快照一致的载荷，允许测试显式破坏指定字段。
Map<String, Object?> _transaction({int revision = 1}) => {
  'id': _transactionId,
  'ledger_id': _ledgerId,
  'tx_type': 'expense',
  'amount': '10',
  'native_amount': '10',
  'currency_code': 'CNY',
  'happened_at': _time,
  'created_at': _time,
  'updated_at': _time,
  'last_edited_at': null,
  'note': null,
  'category_id': null,
  'category_name': null,
  'category_kind': null,
  'recurring_id': null,
  'created_by_member_id': null,
  'last_edited_by_member_id': null,
  'payer_member_id': _memberId,
  'aa_mode': '2',
  'splits': [
    {'member_id': _memberId, 'amount': '10'},
  ],
  'revision': revision,
};

/// 使用真实响应序列化器解析事件外壳，交易载荷仍由投影边界负责解析。
GetSyncPull200Response _page(
  Map<String, Object?> payload, {
  String cursor = '1',
  String time = _time,
  String action = 'upsert',
}) => standardSerializers.deserializeWith(GetSyncPull200Response.serializer, {
  'changes': [
    {
      'change_id': cursor,
      'entity_type': 'transaction',
      'entity_id': _transactionId,
      'ledger_id': _ledgerId,
      'action': action,
      'payload': payload,
      'updated_at': time,
      'device_id': '10000000-0000-4000-8000-000000000005',
      'mutation_id': '10000000-0000-4000-8000-000000000006',
    },
  ],
  'server_cursor': cursor,
  'has_more': false,
})!;

/// 验证同步契约、真实 SQLite 状态和消费游标的一致性。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SyncService service;
  late GetSyncPull200Response page;
  late _SyncApi api;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = _SyncApi();
    page = _page(_transaction());
    when(() => api.getSyncPull(since: any(named: 'since'))).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/pull'),
        data: page,
        statusCode: 200,
      ),
    );
    service = SyncService(
      client: SesameApiClient(),
      db: db,
      deviceId: 'device',
      apiOverride: api,
      currentAccountIdGetter: () => 'account',
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledgerId,
            name: '云账本',
            updatedAt: DateTime.parse(_time),
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account'),
            ownerAccountId: const d.Value('account'),
            syncId: const d.Value('10000000-0000-4000-8000-000000000007'),
          ),
        );
  });
  tearDown(() => db.close());

  test('合法增量保留周期关联、金额、分摊、时间和明确的空值', () async {
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: _recurringId,
            ledgerId: _ledgerId,
            txType: 'expense',
            amount: '10',
            currencyCode: 'CNY',
            frequency: 'monthly',
            startDate: DateTime.parse(_time),
            updatedAt: DateTime.parse(_time),
          ),
        );
    page = _page({..._transaction(), 'recurring_id': _recurringId});
    expect(await service.pull(), 1);
    final row = await db.select(db.transactions).getSingle();
    expect(row.recurringId, _recurringId);
    expect(row.amount, '10');
    expect(row.currencyCode, 'CNY');
    expect(row.happenedAt.toUtc(), DateTime.parse(_time));
    expect(row.note, isNull);
    expect(row.lastEditedAt, isNull);
    final split = await db.select(db.transactionSplits).getSingle();
    expect((split.memberId, split.amount), (_memberId, '10'));
    expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
  });

  test('新 revision 不受较旧时间戳或较小设备 ID 的 LWW 过滤', () async {
    await service.pull();
    const earlier = '2026-09-01T10:00:00.000Z';
    page = _page(
      {..._transaction(revision: 2), 'note': '云端新版本', 'updated_at': earlier},
      cursor: '2',
      time: earlier,
    );
    await service.pull();
    final row = await db.select(db.transactions).getSingle();
    expect(row.serverRevision, 2);
    expect(row.note, '云端新版本');
    expect(row.updatedAt.toUtc(), DateTime.parse(earlier));
    // 较旧 revision 即使时间更晚，也不能覆盖已经应用的新版本。
    page = _page(_transaction(), cursor: '3', time: _time);
    await service.pull();
    expect(await db.select(db.transactions).getSingle(), row);
    expect((await db.select(db.syncState).getSingle()).serverCursor, '3');
  });

  for (final mode in [null, '0', '1']) {
    test('合法 AA 模式 $mode 与空分摊清除旧分摊，保留空值语义', () async {
      await service.pull();
      page = _page({
        ..._transaction(revision: 2),
        'aa_mode': mode,
        'splits': <Object>[],
      }, cursor: '2');
      await service.pull();
      final row = await db.select(db.transactions).getSingle();
      expect(row.aaMode, mode == null ? null : int.parse(mode));
      expect(row.serverRevision, 2);
      expect(await db.select(db.transactionSplits).get(), isEmpty);
    });
  }

  test('删除载荷仅需 revision，旧时间戳不阻断新版本墓碑', () async {
    await service.pull();
    const deletedAt = '2026-09-01T10:00:00.000Z';
    page = _page(
      {'revision': 2},
      cursor: '2',
      time: deletedAt,
      action: 'delete',
    );
    await service.pull();
    final row = await db.select(db.transactions).getSingle();
    expect(row.serverRevision, 2);
    expect(row.deletedAt?.toUtc(), DateTime.parse(deletedAt));
    expect(row.amount, '10');
    expect((await db.select(db.syncState).getSingle()).serverCursor, '2');
  });

  test('损坏远端版本不能进入冲突，也不能在采用云端时清除本地待上传修改', () async {
    await service.pull();
    final before = await db.select(db.transactions).getSingle();
    final splits = await db.select(db.transactionSplits).get();
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: _transactionId,
            ledgerId: const d.Value(_ledgerId),
            accountId: const d.Value('account'),
            action: 'upsert',
            payload: jsonEncode(_transaction()),
            updatedAt: DateTime.parse(_time),
            mutationId: 'pending',
            baseRevision: const d.Value(1),
          ),
        );
    final pending = await db.select(db.syncChanges).get();
    final payload = _transaction(revision: 2)..remove('amount');
    page = _page(payload, cursor: '2');
    await expectLater(
      service.pull(),
      throwsA(
        isA<DeserializationError>().having(
          (e) => e.toString(),
          '原始原因',
          contains('amount'),
        ),
      ),
    );
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    expect(await db.select(db.syncChanges).get(), pending);
    // 冲突可能在前一次运行中已持久化；采用远端仍需走相同的载荷边界。
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'conflict',
            accountId: const d.Value('account'),
            ledgerId: const d.Value(_ledgerId),
            entityType: 'transaction',
            entityId: _transactionId,
            localPayload: jsonEncode(_transaction()),
            remotePayload: jsonEncode(payload),
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'pending',
          ),
        );
    await expectLater(
      service.resolveConflictAdoptRemote('conflict'),
      throwsA(
        isA<DeserializationError>().having(
          (e) => e.toString(),
          '原始原因',
          contains('amount'),
        ),
      ),
    );
    expect(await db.select(db.transactions).getSingle(), before);
    expect(await db.select(db.transactionSplits).get(), splits);
    expect(await db.select(db.syncChanges).get(), pending);
    expect((await db.select(db.syncConflicts).getSingle()).status, 'OPEN');
    expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
  });

  test('非法分摊不能进入冲突或清除采用云端前的本地待上传修改', () async {
    await service.pull();
    final before = await db.select(db.transactions).getSingle();
    final splits = await db.select(db.transactionSplits).get();
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: _transactionId,
            ledgerId: const d.Value(_ledgerId),
            accountId: const d.Value('account'),
            action: 'upsert',
            payload: jsonEncode(_transaction()),
            updatedAt: DateTime.parse(_time),
            mutationId: 'pending-split',
            baseRevision: const d.Value(1),
          ),
        );
    final pending = await db.select(db.syncChanges).get();
    final payload = {
      ..._transaction(revision: 2),
      'splits': [
        {'member_id': _memberId, 'amount': '6'},
        {'member_id': 'invalid-member', 'amount': '4'},
      ],
    };
    page = _page(payload, cursor: '2');
    await expectLater(service.pull(), throwsFormatException);
    expect(await db.select(db.syncConflicts).get(), isEmpty);
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'invalid-split-conflict',
            accountId: const d.Value('account'),
            ledgerId: const d.Value(_ledgerId),
            entityType: 'transaction',
            entityId: _transactionId,
            localPayload: jsonEncode(_transaction()),
            remotePayload: jsonEncode(payload),
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'pending-split',
          ),
        );
    await expectLater(
      service.resolveConflictAdoptRemote('invalid-split-conflict'),
      throwsFormatException,
    );
    expect(await db.select(db.transactions).getSingle(), before);
    expect(await db.select(db.transactionSplits).get(), splits);
    expect(await db.select(db.syncChanges).get(), pending);
    expect((await db.select(db.syncConflicts).getSingle()).status, 'OPEN');
    expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
  });

  final corruptions = <String, void Function(Map<String, Object?>)>{
    '缺少金额': (p) => p.remove('amount'),
    '缺少币种': (p) => p.remove('currency_code'),
    '无效业务时间': (p) => p['happened_at'] = 'invalid-time',
    '缺少创建时间': (p) => p.remove('created_at'),
    '无效更新时间': (p) => p['updated_at'] = 'invalid-time',
    '缺少分摊集合': (p) => p.remove('splits'),
    '无效分摊元素': (p) => p['splits'] = ['invalid-split'],
    for (final invalid in <String, Object?>{
      '缺少分摊成员': null,
      '分摊成员为空': null,
      '分摊成员为空串': '',
      '分摊成员 UUID 非法': 'invalid-member',
    }.entries)
      invalid.key: (p) => p['splits'] = [
        {'member_id': _memberId, 'amount': '6'},
        {
          if (invalid.key != '缺少分摊成员') 'member_id': invalid.value,
          'amount': '4',
        },
      ],
    '数字 AA 枚举': (p) => p['aa_mode'] = 2,
    '小数 revision': (p) => p['revision'] = 2.5,
    '载荷身份不符': (p) => p['id'] = _memberId,
    '载荷账本不符': (p) => p['ledger_id'] = _memberId,
  };
  for (final corruption in corruptions.entries) {
    test('${corruption.key}不能伪造成功，原交易、分摊及游标保持不变', () async {
      await service.pull();
      final before = await db.select(db.transactions).getSingle();
      final splits = await db.select(db.transactionSplits).get();
      final payload = _transaction(revision: 2)..['note'] = '不得提交';
      corruption.value(payload);
      page = _page(payload, cursor: '2', time: '2026-09-11T10:00:00.000Z');
      await expectLater(
        service.pull(),
        throwsA(anyOf(isA<FormatException>(), isA<DeserializationError>())),
      );
      expect(await db.select(db.transactions).getSingle(), before);
      expect(await db.select(db.transactionSplits).get(), splits);
      expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
      final failure = await db.select(db.syncPullErrors).getSingle();
      expect(failure.accountId, 'account');
      expect(failure.entityId, _transactionId);
      expect(failure.errorClass, isNotEmpty);
      expect(failure.stackTrace, isNotEmpty);
      expect((jsonDecode(failure.rawChangeJson) as Map)['payload'], payload);
      // 服务端载荷修正后，沿原游标重试必须能完整提交，不能留下部分分摊或重复行。
      page = _page(_transaction(revision: 2), cursor: '2');
      expect(await service.pull(), 1);
      expect((await db.select(db.transactions).getSingle()).serverRevision, 2);
      expect(await db.select(db.transactionSplits).get(), hasLength(1));
      expect((await db.select(db.syncState).getSingle()).serverCursor, '2');
    });
  }

  test('UUID v5 成员资料尚未同步时仍完整保留合法分摊引用', () async {
    const memberV5 = '056cf10d-2d59-599c-9d97-6749e866aa52';
    page = _page({
      ..._transaction(),
      'splits': [
        {'member_id': _memberId, 'amount': '6'},
        {'member_id': memberV5, 'amount': '4'},
      ],
    });
    expect(await service.pull(), 1);
    final splits = await db.select(db.transactionSplits).get();
    expect(splits.map((s) => (s.memberId, s.amount)), [
      (_memberId, '6'),
      (memberV5, '4'),
    ]);
    expect(await db.select(db.ledgerMembers).get(), isEmpty);
  });

  test('分摊写入中途失败时回滚主记录、已替换的分摊与游标', () async {
    await service.pull();
    final before = await db.select(db.transactions).getSingle();
    final splits = await db.select(db.transactionSplits).get();
    // 在第二条合法分摊的写入处制造存储失败，验证实际事务回滚而非仅验证前置校验。
    await db.customStatement('''
      CREATE TRIGGER reject_second_split BEFORE INSERT ON transaction_splits
      WHEN NEW.member_id = '056cf10d-2d59-599c-9d97-6749e866aa52'
      BEGIN SELECT RAISE(ABORT, 'split-write-failure'); END
    ''');
    page = _page({
      ..._transaction(revision: 2),
      'note': '不得提交',
      'splits': [
        {'member_id': _memberId, 'amount': '6'},
        {'member_id': '056cf10d-2d59-599c-9d97-6749e866aa52', 'amount': '4'},
      ],
    }, cursor: '2');
    await expectLater(
      service.pull(),
      throwsA(
        predicate<Object>(
          (error) => error.toString().contains('split-write-failure'),
        ),
      ),
    );
    expect(await db.select(db.transactions).getSingle(), before);
    expect(await db.select(db.transactionSplits).get(), splits);
    expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
  });

  test('全量快照含非法分摊时回滚账本、交易、分摊及游标', () async {
    await service.pull();
    final ledger = await db.select(db.ledgers).getSingle();
    final before = await db.select(db.transactions).getSingle();
    final splits = await db.select(db.transactionSplits).get();
    final invalid = standardSerializers.deserializeWith(
      Transaction.serializer,
      {
        ..._transaction(revision: 2),
        'note': '不得提交',
        'splits': [
          {'member_id': _memberId, 'amount': '6'},
          {'member_id': '', 'amount': '4'},
        ],
      },
    )!;
    final full = GetSyncFull200Response(
      (b) => b
        ..ledger = GetSyncFull200ResponseLedger(
          (b) => b
            ..id = _ledgerId
            ..ownerId = 'account'
            ..syncId = ledger.syncId
            ..name = '不得覆盖账本'
            ..currency = 'CNY'
            ..monthStartDay = 1
            ..aaEnabled = true
            ..updatedAt = DateTime.parse(_time),
        ).toBuilder()
        ..transactions = BuiltList<Transaction>([invalid]).toBuilder()
        ..serverCursor = '2',
    );
    when(
      () => api.getSyncFull(
        includeRecurringState: any(named: 'includeRecurringState'),
        ledgerId: any(named: 'ledgerId'),
        syncId: any(named: 'syncId'),
      ),
    ).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/sync/full'),
        statusCode: 200,
        data: full,
      ),
    );
    await expectLater(service.full(ledgerId: _ledgerId), throwsFormatException);
    expect(await db.select(db.ledgers).getSingle(), ledger);
    expect(await db.select(db.transactions).getSingle(), before);
    expect(await db.select(db.transactionSplits).get(), splits);
    expect((await db.select(db.syncState).getSingle()).serverCursor, '1');
  });
}
