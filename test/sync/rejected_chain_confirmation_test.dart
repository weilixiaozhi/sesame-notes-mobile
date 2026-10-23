import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

class _Endpoint extends Mock implements api.SyncApi {}

const _account = '10000000-0000-4000-8000-000000000001';
const _ledger = '20000000-0000-4000-8000-000000000001';
const _entity = '30000000-0000-4000-8000-000000000001';
final _stamp = DateTime.utc(2026, 10, 11, 1, 2, 3, 980);

/// 真实冻结请求与原队列共用业务身份，确认未知结果不能顺带上传未发送后继。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SyncService service;
  late api.SesameApiClient client;
  late _Endpoint endpoint;
  late List<String> sent;

  setUpAll(
    () => registerFallbackValue(
      api.PostSyncPushRequest((b) => b..deviceId = 'device'),
    ),
  );
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = api.SesameApiClient();
    endpoint = _Endpoint();
    sent = [];
    when(
      () => endpoint.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as api.PostSyncPushRequest;
      sent.addAll(syncRequestChanges(request).map(jsonEncode));
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(request),
      );
    });
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      apiOverride: endpoint,
      currentAccountIdGetter: () => _account,
    );
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _ledger,
            name: '本人账本',
            updatedAt: _stamp,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_account),
            ownerAccountId: const d.Value(_account),
            syncId: const d.Value('40000000-0000-4000-8000-000000000001'),
          ),
        );
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 仅替换网络，冻结仍走真实 SDK 与冻结器，已拒收前缀保留诊断原文。
  Future<SyncChange> enqueue(
    int ordinal, {
    bool rejected = false,
    bool frozen = false,
  }) async {
    final id = await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: _entity,
            ledgerId: const d.Value(_ledger),
            action: 'upsert',
            payload: jsonEncode({
              'tx_type': 'expense',
              'amount': '$ordinal',
              'native_amount': '$ordinal',
              'currency_code': 'CNY',
              'happened_at': _stamp.toIso8601String(),
              'category_id': null,
              'note': '保留正文$ordinal',
              'recurring_id': null,
              'payer_member_id': null,
              'aa_mode': null,
              'splits': null,
              'last_edited_at': null,
            }),
            updatedAt: _stamp,
            mutationId:
                '50000000-0000-4000-8000-${ordinal.toString().padLeft(12, '0')}',
            accountId: const d.Value(_account),
            baseRevision: const d.Value(7),
            rejectionReason: d.Value(rejected ? '金额不可用，请检查后保存' : null),
            rejectionCode: d.Value(rejected ? 'INVALID_AMOUNT' : null),
            frozenRequest: d.Value(
              rejected ? '{"known_rejected":$ordinal}' : null,
            ),
          ),
        );
    final row = await (db.select(
      db.syncChanges,
    )..where((c) => c.id.equals(id))).getSingle();
    return frozen
        ? (await service.pushCoordinator.freezePending(row, _account))!
        : row;
  }

  test('只越过已拒收前缀确认未知冻结原字节，后续未发送意图继续等待用户处理', () async {
    final first = await enqueue(1, rejected: true);
    final second = await enqueue(2, rejected: true);
    final unknown = await enqueue(3, frozen: true);
    final unsent = await enqueue(4);
    await service.push();
    expect(sent, [unknown.frozenRequest]);
    final after = await db.select(db.syncChanges).get();
    expect(after.singleWhere((c) => c.id == first.id), first);
    expect(after.singleWhere((c) => c.id == second.id), second);
    final confirmed = after.singleWhere((c) => c.id == unknown.id);
    expect(confirmed.pushedAt, isNotNull);
    expect(confirmed.frozenRequest, isNull);
    final successor = after.singleWhere((c) => c.id == unsent.id);
    expect(
      (successor.entityId, successor.mutationId, successor.payload),
      (unsent.entityId, unsent.mutationId, unsent.payload),
    );
    expect(successor.baseRevision, 8);
    expect(successor.frozenRequest, isNull);
    await service.push();
    expect(sent, [unknown.frozenRequest]);
  });

  test('已拒收前缀后的未发送意图不能被越过以寻找更晚的冻结请求', () async {
    await enqueue(1, rejected: true);
    await enqueue(2);
    await enqueue(3, frozen: true);
    final before = await db.select(db.syncChanges).get();
    await service.push();
    expect(sent, isEmpty);
    expect(await db.select(db.syncChanges).get(), before);
  });

  test('未知重放传输失败保留全部原队列和冻结字节，第二次只重放同一mutation', () async {
    await enqueue(1, rejected: true);
    final unknown = await enqueue(2, frozen: true);
    final before = await db.select(db.syncChanges).get();
    var loseReply = true;
    when(
      () => endpoint.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((call) async {
      final request =
          call.namedArguments[#postSyncPushRequest] as api.PostSyncPushRequest;
      sent.addAll(syncRequestChanges(request).map(jsonEncode));
      if (loseReply) {
        loseReply = false;
        throw DioException(
          requestOptions: RequestOptions(path: '/sync/push'),
          type: DioExceptionType.connectionError,
        );
      }
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        statusCode: 200,
        data: acknowledgeSyncRequest(request),
      );
    });
    await expectLater(service.push(), throwsA(isA<DioException>()));
    expect(await db.select(db.syncChanges).get(), before);
    await service.push();
    expect(sent, [unknown.frozenRequest, unknown.frozenRequest]);
  });
}
