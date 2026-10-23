import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:uuid/uuid.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements SyncApi {}

/// 验证单本操作仍纳入必需分类，并保持其他本和无关分类的独立范围。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const account = 'user-a';
  const ledgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6235';
  const otherLedgerId = 'b27e759f-c9eb-49c4-b9f7-dffcd95c6236';
  const parentId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b6';
  const childId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b7';
  const otherCategoryId = '1527ffc3-6087-5b6b-99c6-c6837a5db1b8';
  const transactionId = '3c0d0f14-04aa-4c11-bbf8-f0358ab1b9d7';
  const otherTransactionId = '3c0d0f14-04aa-4c11-bbf8-f0358ab1b9d8';
  final now = DateTime.utc(2026, 10, 11, 8);
  late SesameDatabase db;
  late _MockSyncApi api;
  late SyncService service;
  late List<Map<String, dynamic>> sent;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    api = _MockSyncApi();
    service = SyncService(
      client: SesameApiClient(basePathOverride: 'http://test.local'),
      db: db,
      deviceId: 'device-1',
      apiOverride: api,
      currentAccountIdGetter: () => account,
    );
    sent = [];
    registerFallbackValue(
      PostSyncPushRequest(
        (b) => b
          ..deviceId = 'device-1'
          ..changes = ListBuilder<PostSyncPushRequestChangesInner>(),
      ),
    );
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      sent.addAll(syncRequestChanges(request));
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(request),
      );
    });
  });
  tearDown(() async => db.close());

  /// 建立已有云同步身份的账本，单本操作可以直接提交其待上传记录。
  Future<void> ledger(String id) => db
      .into(db.ledgers)
      .insert(
        LedgersCompanion.insert(
          id: id,
          name: '云账本',
          storageMode: const d.Value('cloud'),
          scopeAccountId: const d.Value(account),
          ownerAccountId: const d.Value(account),
          syncId: const d.Value('32479a53-fbb4-4155-9865-850aa191dcd4'),
          updatedAt: now,
        ),
      );

  /// 建立本地分类及父子关系，空账号表示尚未登记上云的种子分类。
  Future<void> category(String id, {String? parent, String? scope}) => db
      .into(db.categories)
      .insert(
        CategoriesCompanion.insert(
          id: id,
          name: id == parentId ? '订阅服务' : '视频会员',
          kind: 'expense',
          level: parent == null ? 1 : 2,
          parentId: d.Value(parent),
          scopeAccountId: d.Value(scope),
          updatedAt: now,
        ),
      );

  /// 构造完整交易载荷，保持分类引用和其他业务字段可独立验证。
  Map<String, dynamic> transactionPayload(String categoryId) => {
    'tx_type': 'expense',
    'amount': '12.5',
    'happened_at': now.toIso8601String(),
    'note': null,
    'category_id': categoryId,
    'currency_code': 'CNY',
    'native_amount': '12.5',
    'recurring_id': null,
    'payer_member_id': null,
    'aa_mode': null,
    'splits': null,
    'last_edited_at': null,
  };

  /// 保存原始待上传意图，拒绝标记只用于验证分类前置门禁。
  Future<int> change(
    String type,
    String id,
    Map<String, dynamic> payload, {
    String? ledger,
    String? rejection,
    String? rejectionCode,
    String accountId = account,
    String action = 'upsert',
  }) => db
      .into(db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: type,
          entityId: id,
          ledgerId: d.Value(ledger),
          accountId: d.Value(accountId),
          action: action,
          payload: jsonEncode({
            ...payload,
            if (type == 'category') 'updated_at': now.toIso8601String(),
          }),
          updatedAt: now,
          mutationId: const Uuid().v4(),
          rejectionReason: d.Value(rejection),
          rejectionCode: d.Value(rejectionCode),
        ),
      );

  /// 保留测试名称、原始异常及堆栈，失败时可直接定位违背的依赖规则。
  void dependencyTest(String name, Future<void> Function() verify) {
    test(name, () async {
      try {
        await verify();
      } catch (error, stack) {
        debugPrint('$name 失败：$error\n$stack');
        rethrow;
      }
    });
  }

  for (final target in [null, const SyncTarget('ledger', ledgerId)]) {
    dependencyTest(
      '${target == null ? '全局' : '单账本'}交易完整迁移链确认后才删除源分类，目标分类仍先登记',
      () async {
        await ledger(ledgerId);
        await category(parentId, scope: account);
        await category(otherCategoryId, scope: account);
        if (target != null) {
          await ledger(otherLedgerId);
          await change(
            'transaction',
            otherTransactionId,
            transactionPayload(otherCategoryId),
            ledger: otherLedgerId,
          );
        }
        await (db.update(db.categories)
              ..where((row) => row.id.equals(parentId)))
            .write(CategoriesCompanion(deletedAt: d.Value(now)));
        await change(
          'transaction',
          transactionId,
          transactionPayload(parentId),
          ledger: ledgerId,
        );
        await change(
          'transaction',
          transactionId,
          transactionPayload(otherCategoryId),
          ledger: ledgerId,
        );
        await change('category', parentId, {
          'name': '删除源分类',
          'kind': 'expense',
          'level': 1,
          'sort_order': 0,
          'icon': null,
          'parent_id': null,
        }, action: 'delete');

        await service.pushCoordinator.pushPending(account, target: target);

        expect(
          sent.map(
            (row) => (row['entity_type'], row['entity_id'], row['action']),
          ),
          [
            ('category', otherCategoryId, 'upsert'),
            ('transaction', transactionId, 'upsert'),
            ('transaction', transactionId, 'upsert'),
            ('category', parentId, 'delete'),
          ],
        );
        final remaining = await (db.select(
          db.syncChanges,
        )..where((row) => row.pushedAt.isNull())).get();
        if (target == null) {
          expect(remaining, isEmpty);
        } else {
          expect(remaining.single.entityId, otherTransactionId);
          expect(remaining.single.frozenRequest, isNull);
        }
      },
    );
  }

  dependencyTest('无关账本的拒收交易不阻挡独立分类删除', () async {
    await ledger(ledgerId);
    await ledger(otherLedgerId);
    await category(parentId, scope: account);
    await category(otherCategoryId, scope: account);
    await change(
      'transaction',
      otherTransactionId,
      transactionPayload(otherCategoryId),
      ledger: otherLedgerId,
      rejection: '这笔交易需要用户处理',
      rejectionCode: 'INVALID_TRANSACTION_PAYLOAD',
    );
    await (db.update(db.categories)..where((row) => row.id.equals(parentId)))
        .write(CategoriesCompanion(deletedAt: d.Value(now)));
    await change('category', parentId, {
      'name': '没有任何交易引用的分类',
      'kind': 'expense',
      'level': 1,
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, action: 'delete');

    await service.pushCoordinator.pushPending(account);

    expect(
      sent
          .where((row) => row['entity_id'] == parentId)
          .map((row) => row['action']),
      ['delete'],
    );
    final remaining = await (db.select(
      db.syncChanges,
    )..where((row) => row.pushedAt.isNull())).get();
    expect(remaining.single.entityId, otherTransactionId);
    expect(remaining.single.rejectionCode, 'INVALID_TRANSACTION_PAYLOAD');
  });

  dependencyTest('关联迁移被拒收时分类删除取得明确的云端引用错误', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await category(otherCategoryId, scope: account);
    await change(
      'transaction',
      transactionId,
      transactionPayload(otherCategoryId),
      ledger: ledgerId,
      rejection: '迁移交易需要用户处理',
      rejectionCode: 'INVALID_TRANSACTION_PAYLOAD',
    );
    await change('category', parentId, {
      'name': '云端仍有引用的分类',
      'kind': 'expense',
      'level': 1,
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, action: 'delete');
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      final wire = syncRequestChanges(request);
      sent.addAll(wire);
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          request,
          overrides: [
            for (final row in wire)
              if (row['entity_id'] == parentId)
                PostSyncPush200ResponseOutcomesInner(
                  (b) => b
                    ..mutationId = row['mutation_id'] as String
                    ..entityId = parentId
                    ..status =
                        PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                    ..code = 'CATEGORY_HAS_TRANSACTIONS',
                ),
          ],
        ),
      );
    });

    await service.pushCoordinator.pushPending(account);

    final removal = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(parentId))).getSingle();
    expect(removal.pushedAt, isNull);
    expect(removal.rejectionCode, 'CATEGORY_HAS_TRANSACTIONS');
    expect(removal.rejectionReason, contains('先完成关联记录的迁移或删除'));
    expect(sent.where((row) => row['entity_id'] == parentId), hasLength(1));
  });

  dependencyTest('未知结果分类删除在引用后继仍可推进时按原请求确认', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await category(otherCategoryId, scope: account);
    await change('category', parentId, {
      'name': '已发送删除的分类',
      'kind': 'expense',
      'level': 1,
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, action: 'delete');
    final deletion = await (db.select(
      db.syncChanges,
    )..where((row) => row.entityId.equals(parentId))).getSingle();
    final frozen = await service.pushCoordinator.freezePending(
      deletion,
      account,
    );
    await change(
      'transaction',
      transactionId,
      transactionPayload(otherCategoryId),
      ledger: ledgerId,
    );
    await change(
      'transaction',
      transactionId,
      transactionPayload(otherCategoryId),
      ledger: ledgerId,
    );

    await service.pushCoordinator.pushPending(account);

    final confirmIndex = sent.indexWhere((row) => row['entity_id'] == parentId);
    final transactionIndices = [
      for (var i = 0; i < sent.length; i++)
        if (sent[i]['entity_id'] == transactionId) i,
    ];
    expect(confirmIndex, greaterThan(transactionIndices.first));
    expect(confirmIndex, lessThan(transactionIndices.last));
    expect(sent[confirmIndex], jsonDecode(frozen!.frozenRequest!));
  });

  dependencyTest('交易删除不受分类冲突阻挡，子分类删除先于父分类', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await category(childId, parent: parentId, scope: account);
    await (db.update(
      db.categories,
    )).write(CategoriesCompanion(deletedAt: d.Value(now)));
    await change(
      'transaction',
      transactionId,
      transactionPayload(childId),
      ledger: ledgerId,
      action: 'delete',
    );
    for (final id in [parentId, childId]) {
      await change('category', id, {
        'name': '删除分类',
        'kind': 'expense',
        'level': id == parentId ? 1 : 2,
        'sort_order': 0,
        'icon': null,
        'parent_id': id == parentId ? null : parentId,
      }, action: 'delete');
    }

    await service.pushCoordinator.pushPending(account);

    expect(sent.map((row) => (row['entity_id'], row['action'])), [
      (transactionId, 'delete'),
      (childId, 'delete'),
      (parentId, 'delete'),
    ]);
  });

  dependencyTest('有待处理分类拒绝时仍可先同步解除引用的交易删除', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await change('category', parentId, {
      'name': '待处理分类',
      'kind': 'expense',
      'level': 1,
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, rejection: '分类内容需要处理');
    await change(
      'transaction',
      transactionId,
      transactionPayload(parentId),
      ledger: ledgerId,
      action: 'delete',
    );

    await service.pushCoordinator.pushPending(account);

    expect(sent.map((row) => (row['entity_id'], row['action'])), [
      (transactionId, 'delete'),
    ]);
  });

  dependencyTest('单账本推送先登记父子分类，其他账本及无关分类保持待上传', () async {
    await ledger(ledgerId);
    await ledger(otherLedgerId);
    await category(parentId);
    await category(childId, parent: parentId);
    await category(otherCategoryId);
    await change(
      'transaction',
      transactionId,
      transactionPayload(childId),
      ledger: ledgerId,
    );
    final otherTx = await change(
      'transaction',
      otherTransactionId,
      transactionPayload(otherCategoryId),
      ledger: otherLedgerId,
    );
    final unrelated = await change(
      'category',
      otherCategoryId,
      {
        'name': '无关分类',
        'kind': 'expense',
        'level': '1',
        'sort_order': 0,
        'icon': null,
        'parent_id': null,
      },
      rejection: '记录内容未通过服务端校验，请检查并编辑后保存',
      rejectionCode: 'INVALID_CATEGORY_ICON',
    );

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent.map((c) => c['entity_id']), [parentId, childId, transactionId]);
    for (final id in [otherTx, unrelated]) {
      final row = await (db.select(
        db.syncChanges,
      )..where((c) => c.id.equals(id))).getSingle();
      expect(row.pushedAt, isNull);
      expect(row.frozenRequest, isNull);
    }
  });

  dependencyTest('单账本推送被拒分类的引用交易保持未发送', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await change('category', parentId, {
      'name': '订阅服务',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, rejection: '分类内容需要处理');
    final tx = await change(
      'transaction',
      transactionId,
      transactionPayload(parentId),
      ledger: ledgerId,
    );

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent, isEmpty);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.id.equals(tx))).getSingle();
    expect(pending.pushedAt, isNull);
    expect(pending.rejectionReason, isNull);
    expect(pending.frozenRequest, isNull);
  });

  dependencyTest('单账本推送本轮分类拒绝立即拦截引用交易', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await change('category', parentId, {
      'name': '订阅服务',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    });
    await change(
      'transaction',
      transactionId,
      transactionPayload(parentId),
      ledger: ledgerId,
    );
    when(
      () => api.postSyncPush(
        postSyncPushRequest: any(named: 'postSyncPushRequest'),
      ),
    ).thenAnswer((invocation) async {
      final request =
          invocation.namedArguments[#postSyncPushRequest]
              as PostSyncPushRequest;
      final wire = syncRequestChanges(request);
      sent.addAll(wire);
      return Response(
        requestOptions: RequestOptions(path: '/sync/push'),
        data: acknowledgeSyncRequest(
          request,
          overrides: [
            if (wire.single['entity_type'] == 'category')
              PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = wire.single['mutation_id'] as String
                  ..entityId = parentId
                  ..status =
                      PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                  ..message = '分类层级无效',
              ),
          ],
        ),
      );
    });

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent.map((c) => c['entity_id']), [parentId]);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.entityId.equals(transactionId))).getSingle();
    expect(pending.frozenRequest, isNull);
    expect(pending.rejectionReason, isNull);
  });

  dependencyTest('已确认子分类的父级受阻时，单账本引用仍遵守祖先依赖', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await category(childId, parent: parentId, scope: account);
    await change('category', parentId, {
      'name': '订阅服务',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, rejection: '分类内容需要处理');
    await change(
      'transaction',
      transactionId,
      transactionPayload(childId),
      ledger: ledgerId,
    );

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent, isEmpty);
  });

  dependencyTest('单账本周期账单同样等待引用分类完成处理', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await change('category', parentId, {
      'name': '订阅服务',
      'kind': 'expense',
      'level': '1',
      'sort_order': 0,
      'icon': null,
      'parent_id': null,
    }, rejection: '分类内容需要处理');
    final rule = await change('recurring_transaction', transactionId, {
      'tx_type': 'expense',
      'amount': '12.5',
      'currency_code': 'CNY',
      'category_id': parentId,
      'note': null,
      'frequency': 'monthly',
      'interval': 1,
      'day_of_month': 11,
      'day_of_week': null,
      'month_of_year': null,
      'start_date': now.toIso8601String(),
      'end_date': null,
      'last_generated_date': null,
      'enabled': true,
    }, ledger: ledgerId);

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent, isEmpty);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.id.equals(rule))).getSingle();
    expect(pending.frozenRequest, isNull);
    expect(pending.rejectionReason, isNull);
  });

  dependencyTest('另一账号同身份分类的拒绝不影响当前单账本推送', () async {
    await ledger(ledgerId);
    await category(parentId, scope: account);
    await (db.update(db.categories)..where(
          (c) => c.id.equals(parentId) & c.scopeAccountId.equals(account),
        ))
        .write(const CategoriesCompanion(cloudRegistered: d.Value(true)));
    final otherAccount = await change(
      'category',
      parentId,
      {
        'name': '订阅服务',
        'kind': 'expense',
        'level': '1',
        'sort_order': 0,
        'icon': null,
        'parent_id': null,
      },
      rejection: '分类内容需要处理',
      accountId: 'user-b',
    );
    await change(
      'transaction',
      transactionId,
      transactionPayload(parentId),
      ledger: ledgerId,
    );

    await service.pushCoordinator.pushPending(
      account,
      target: const SyncTarget('ledger', ledgerId),
    );

    expect(sent.map((c) => c['entity_id']), [transactionId]);
    final pending = await (db.select(
      db.syncChanges,
    )..where((c) => c.id.equals(otherAccount))).getSingle();
    expect(pending.pushedAt, isNull);
    expect(pending.frozenRequest, isNull);
  });
}
