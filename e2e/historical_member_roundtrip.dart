import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart' show SyncChangesCompanion;
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:uuid/uuid.dart';
import 'request_observation.dart';

/// 真实共享成员离开/移除后复制转云，历史身份不得复活或与同名成员合并。
Future<void> runHistoricalMemberRoundtrip(
  SyncService a,
  SyncService b,
  String account, {
  required Future<void> Function(LocalRepository, String) promoteLocal,
}) async {
  final repo = LocalRepository(
    a.db,
    accountIdGetter: () => account,
    changeTracker: ChangeRecorderImpl(a.db, accountIdGetter: () => account),
  );
  final source = await repo.createLedger(name: '历史成员真实往返', aaEnabled: true);
  await a.push();
  await a.full(ledgerId: source);
  final peerLeft = await _joinPeer(a.client, source);
  final peerRemoved = await _joinPeer(a.client, source);
  final leftId = registeredMemberId(source, peerLeft.$2);
  final removedId = registeredMemberId(source, peerRemoved.$2);
  final ownerId = registeredMemberId(source, account);
  await a.full(ledgerId: source);
  final originalTx = await repo.addTransaction(
    ledgerId: source,
    type: 'expense',
    amount: '12.9876543219',
    nativeAmount: '12.9876543219',
    currencyCode: 'CNY',
    happenedAt: DateTime.utc(2026, 2, 3),
    payerMemberId: leftId,
    operatorMemberId: ownerId,
    aaMode: 2,
    splits: [
      TransactionSplitInput(memberId: ownerId, amount: '4'),
      TransactionSplitInput(memberId: leftId, amount: '4'),
      TransactionSplitInput(memberId: removedId, amount: '4.9876543219'),
    ],
  );
  await a.push();
  await _expectNoPending(a);
  await peerLeft.$1.getSharingApi().postLedgersByLedgerIdLeave(
    ledgerId: source,
  );
  await a.client.getSharingApi().deleteLedgersByLedgerIdMembersByMemberId(
    ledgerId: source,
    memberId: removedId,
  );
  await a.full(ledgerId: source);
  final sourceMembers = await repo.getMembersByLedger(source);
  expect(sourceMembers.singleWhere((row) => row.id == leftId).status, 'LEFT');
  expect(
    sourceMembers.singleWhere((row) => row.id == removedId).status,
    'REMOVED',
  );
  expect(
    sourceMembers.every((row) => row.linkedAccountId == null),
    isTrue,
    reason: '真实 full 契约不携带私有账号关联，复制不能依赖它',
  );
  final sourceSnapshot = (await a.client.getSyncApi().getSyncFull(
    ledgerId: source,
  )).data!;

  final copyId = await a.transferToLocal(
    SyncTarget('ledger', source),
    move: false,
  );
  final copyMembers = await repo.getMembersByLedger(copyId);
  final left = copyMembers.singleWhere((row) => row.originMemberId == leftId);
  final removed = copyMembers.singleWhere(
    (row) => row.originMemberId == removedId,
  );
  expect(left.id, isNot(removed.id));
  expect(left.displayName, removed.displayName);
  expect(left.memberType, 'PLACEHOLDER');
  expect(removed.memberType, 'PLACEHOLDER');
  expect(left.status, 'LEFT');
  expect(removed.status, 'REMOVED');
  final copiedTx =
      await (a.db.select(a.db.transactions)..where(
            (row) => row.ledgerId.equals(copyId) & row.deletedAt.isNull(),
          ))
          .getSingle();
  expect(copiedTx.payerMemberId, left.id);
  expect(copiedTx.id, isNot(originalTx));
  await promoteLocal(repo, copyId);
  // 模拟旧离线数据中可修正的无效内容，仍通过正式生成客户端发送。
  // 每条 mutation 被明确拒绝后，新编辑须保留首次历史意图才能安全重试。
  for (final entry in [
    (left.id, 'display_name', ' '),
    (copiedTx.id, 'payer_member_id', const Uuid().v4()),
  ]) {
    final pending =
        await (a.db.select(a.db.syncChanges)..where(
              (row) => row.entityId.equals(entry.$1) & row.pushedAt.isNull(),
            ))
            .getSingle();
    final invalid = jsonDecode(pending.payload) as Map<String, dynamic>;
    invalid[entry.$2] = entry.$3;
    await (a.db.update(a.db.syncChanges)
          ..where((row) => row.id.equals(pending.id)))
        .write(SyncChangesCompanion(payload: d.Value(jsonEncode(invalid))));
  }
  await a.push();
  final rejected =
      await (a.db.select(a.db.syncChanges)..where(
            (row) =>
                row.entityId.isIn([left.id, copiedTx.id]) &
                row.pushedAt.isNull(),
          ))
          .get();
  expect(rejected, hasLength(2));
  expect(rejected.every((row) => row.rejectionReason != null), isTrue);
  await repo.updateTransaction(
    id: copiedTx.id,
    type: 'expense',
    amount: copiedTx.amount,
    payerMemberId: left.id,
    note: '纠正历史引用',
  );
  await repo.renameMember(id: left.id, name: '首次发送前编辑历史成员');

  final frozenBodies = <String>[];
  var loseResponse = true;
  final lostReceipt = InterceptorsWrapper(
    onResponse: (response, handler) {
      final request = response.requestOptions;
      if (request.path == '/api/v1/sync/push') {
        final data = observedRequestBody(request.data);
        final changes = data['changes'];
        if (changes is List &&
            changes.whereType<Map>().any(
              (change) =>
                  change['entity_id'] == copiedTx.id &&
                  change['payload'] is Map &&
                  (change['payload'] as Map)['initial_history'] == true,
            )) {
          frozenBodies.add(observedRequestJson(request.data));
          if (loseResponse) {
            loseResponse = false;
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.connectionError,
                error: '测试：历史写入成功后回执丢失',
              ),
            );
            return;
          }
        }
      }
      handler.next(response);
    },
  );
  a.client.dio.interceptors.add(lostReceipt);
  try {
    await expectLater(
      a.push(),
      throwsA(
        isA<DioException>().having(
          (error) => error.type,
          '提交后丢响应',
          DioExceptionType.connectionError,
        ),
      ),
    );
    // 未知回执期间仍可保存后继编辑，但不能改变首条导入请求或再带初始标记。
    await repo.updateTransaction(
      id: copiedTx.id,
      type: 'expense',
      amount: copiedTx.amount,
      note: '未知回执期间编辑',
    );
    await repo.renameMember(id: left.id, name: '回执未知后编辑历史成员');
    await a.push();
  } finally {
    a.client.dio.interceptors.remove(lostReceipt);
  }
  expect(frozenBodies.length, greaterThanOrEqualTo(2));
  expect(frozenBodies[1], frozenBodies[0]);
  await _expectNoPending(a);
  await b.pull();
  await b.full(ledgerId: copyId);
  final restored = (await b.client.getSyncApi().getSyncFull(
    ledgerId: copyId,
  )).data!;
  expect(restored.transactions, hasLength(1));
  expect(restored.transactions.single.note, '未知回执期间编辑');
  expect(restored.transactions.single.amount, '12.9876543219');
  expect(restored.transactions.single.payerMemberId, left.id);
  expect(
    restored.transactions.single.splits.map((row) => row.amount),
    unorderedEquals(['4', '4', '4.9876543219']),
  );
  expect(
    restored.members.singleWhere((row) => row.id == left.id).status.name,
    'LEFT',
  );
  expect(
    restored.members.singleWhere((row) => row.id == left.id).displayName,
    '回执未知后编辑历史成员',
  );
  expect(
    restored.members.singleWhere((row) => row.id == removed.id).status.name,
    'REMOVED',
  );
  expect(
    restored.members.where((row) => row.status.name == 'ACTIVE'),
    hasLength(1),
  );
  final localRestored = await (b.db.select(
    b.db.ledgerMembers,
  )..where((row) => row.ledgerId.equals(copyId))).get();
  expect(localRestored.singleWhere((row) => row.id == left.id).status, 'LEFT');
  expect(
    localRestored.singleWhere((row) => row.id == removed.id).status,
    'REMOVED',
  );
  expect(localRestored.where((row) => row.status == 'ACTIVE'), hasLength(1));
  final remoteIds = restored.members.map((row) => row.id).toSet();
  expect(
    remoteIds,
    containsAll(restored.transactions.single.splits.map((row) => row.memberId)),
  );
  final sourceAfter = (await a.client.getSyncApi().getSyncFull(
    ledgerId: source,
  )).data!;
  expect(sourceAfter.members, sourceSnapshot.members);
  expect(sourceAfter.transactions, sourceSnapshot.transactions);

  // 历史占位身份没有恢复共享权限，原账号仍不能访问新本。
  await expectLater(
    peerLeft.$1.getSyncApi().getSyncFull(ledgerId: copyId),
    throwsA(
      isA<DioException>().having(
        (error) => error.response?.statusCode,
        '历史身份不授予访问权',
        anyOf(403, 404),
      ),
    ),
  );
}

/// 只通过正式生成客户端创建合成测试账号和共享关系。
Future<(api.SesameApiClient, String)> _joinPeer(
  api.SesameApiClient owner,
  String ledgerId,
) async {
  final client = api.SesameApiClient(
    basePathOverride: owner.dio.options.baseUrl,
    serializers: apiSerializers,
  );
  client.dio.options.headers['x-sesame-recurring-protocol'] = '1';
  addTearDown(() => client.dio.close(force: true));
  final suffix = (DateTime.now().microsecondsSinceEpoch % 100000000)
      .toString()
      .padLeft(8, '0');
  final session = (await client.getAuthApi().postAuthRegister(
    postAuthRegisterRequest: api.PostAuthRegisterRequest(
      (builder) => builder
        ..countryCode = '+86'
        ..phone = '139$suffix'
        ..password = 'isolated-history-test'
        ..device = api.PostAuthRegisterRequestDevice(
          (device) => device
            ..installationId = const Uuid().v4()
            ..name = '历史身份验收'
            ..platform = 'flutter_test',
        ).toBuilder(),
    ),
  )).data!;
  client.setBearerAuth('bearerAuth', session.accessToken);
  await client.getProfileApi().patchProfileMe(
    patchProfileMeRequest: api.PatchProfileMeRequest(
      (builder) => builder..displayName = '同名历史成员',
    ),
  );
  final invite = (await owner.getSharingApi().postLedgersByLedgerIdInvites(
    ledgerId: ledgerId,
    postLedgersByLedgerIdInvitesRequest:
        api.PostLedgersByLedgerIdInvitesRequest(),
  )).data!;
  await client.getSharingApi().postInvitesByCodeAccept(code: invite.code);
  return (client, session.user.userId);
}

/// 留存或拒收队列意味着往返未完成，不能用 HTTP 200 替代业务断言。
Future<void> _expectNoPending(SyncService service) async {
  expect(
    await (service.db.select(
      service.db.syncChanges,
    )..where((row) => row.pushedAt.isNull())).get(),
    isEmpty,
  );
}
