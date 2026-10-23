import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_rejection.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/sync_response.dart';
import '../helpers/test_isolation.dart';

class _MockSyncApi extends Mock implements api.SyncApi {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const account = 'account';
  const categoryId = '961e3602-ad43-5c82-af2f-4202def6098c';
  const ledgerId = '20000000-0000-4000-8000-000000000001';
  const txId = '30000000-0000-4000-8000-000000000001';
  final stamp = DateTime.utc(2026, 9, 5, 8);
  final categoryPayload = {
    'updated_at': stamp.toIso8601String(),
    'name': '订阅服务',
    'kind': 'expense',
    'level': '1',
    'sort_order': 0,
    'icon': null,
    'parent_id': null,
  };
  final txPayload = {
    'tx_type': 'expense',
    'amount': '100',
    'native_amount': '100',
    'currency_code': 'CNY',
    'happened_at': stamp.toIso8601String(),
    'note': null,
    'category_id': categoryId,
    'recurring_id': null,
    'payer_member_id': null,
    'aa_mode': null,
    'splits': null,
    'last_edited_at': null,
  };
  late SesameDatabase db;
  late _MockSyncApi endpoint;
  late SyncService service;

  /// 每个异步回归保留错误堆栈，测试失败时不丢失实际业务流程的诊断。
  Future<void> verifyFlow(Future<void> Function() work) async {
    try {
      await work();
    } catch (error, stack) {
      logger.error(
        'SyncRecoveryTest',
        '拒收恢复回归失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 完整权威分类快照沿用正式生成模型，验证真实分类确认分支。
  api.Category cloudCategory({bool deleted = false}) =>
      api.standardSerializers.deserializeWith(api.Category.serializer, {
        ...categoryPayload,
        'owner_id': account,
        'id': categoryId,
        'updated_at': stamp.toIso8601String(),
        'deleted_at': deleted ? stamp.toIso8601String() : null,
        'version_token': 'a' * 64,
      })!;

  setUpAll(
    () => registerFallbackValue(
      api.PostSyncPushRequest((b) => b..deviceId = 'device'),
    ),
  );
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    endpoint = _MockSyncApi();
    service = SyncService(
      client: api.SesameApiClient(),
      db: db,
      deviceId: 'device',
      apiOverride: endpoint,
      currentAccountIdGetter: () => account,
    );
    await verifyFlow(() async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: ledgerId,
              name: '默认账本',
              updatedAt: stamp,
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value(account),
              ownerAccountId: const d.Value(account),
              syncId: const d.Value('40000000-0000-4000-8000-000000000001'),
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: categoryId,
              name: '订阅服务',
              kind: 'expense',
              level: 1,
              updatedAt: stamp,
              scopeAccountId: const d.Value(account),
            ),
          );
    });
  });
  tearDown(() => db.close());

  /// 创建已明确拒绝的原始意图，保留被拒请求用于验证重试不会改变业务意图。
  Future<int> rejected({
    String type = 'transaction',
    String id = txId,
    String owner = account,
    String code = 'INVALID_CATEGORY',
    Map<String, dynamic>? content,
    String? frozenEnvelope,
    DateTime? updatedAt,
  }) async {
    try {
      return await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: type,
              entityId: id,
              ledgerId: type == 'category'
                  ? const d.Value(null)
                  : const d.Value(ledgerId),
              action: 'upsert',
              payload: jsonEncode(
                content ?? (type == 'category' ? categoryPayload : txPayload),
              ),
              updatedAt: updatedAt ?? stamp,
              mutationId: 'old-$owner-$id',
              accountId: d.Value(owner),
              rejectionCode: d.Value(code),
              rejectionReason: d.Value(syncRejectionReason(code)),
              frozenRequest: d.Value(
                frozenEnvelope ?? jsonEncode({'original': id}),
              ),
              baseRevision: const d.Value(7),
            ),
          );
    } catch (error, stack) {
      logger.error(
        'SyncRecoveryTest',
        '构造拒收队列失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  test(
    '显式重试分类拒收后同轮恢复关联记账，原内容与基线保持完整',
    () => verifyFlow(() async {
      final categoryChange = await rejected(
        type: 'category',
        id: categoryId,
        code: 'INVALID_CATEGORY_ICON',
      );
      await rejected();
      final sent = <Map<String, dynamic>>[];
      when(
        () => endpoint.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest]
                as api.PostSyncPushRequest;
        final changes = syncRequestChanges(request);
        sent.addAll(changes);
        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(
            request,
            overrides: [
              for (final change in changes)
                if (change['entity_type'] == 'category')
                  api.PostSyncPush200ResponseOutcomesInner(
                    (b) => b
                      ..mutationId = change['mutation_id'] as String
                      ..entityId = categoryId
                      ..status = api
                          .PostSyncPush200ResponseOutcomesInnerStatusEnum
                          .accepted
                      ..changeId = '100'
                      ..categoryState = cloudCategory().toBuilder(),
                  ),
            ],
          ),
        );
      });
      await service.retryRejectedChange(categoryChange.toString());
      await service.push();
      expect(sent.map((c) => c['entity_type']), ['category', 'transaction']);
      expect(sent.first['payload'], {...categoryPayload}..remove('updated_at'));
      expect(sent.last['payload'], {...txPayload}..remove('payer_member_id'));
      expect(
        sent.every((c) => !(c['mutation_id'] as String).startsWith('old-')),
        isTrue,
      );
      expect(sent.last['base_revision'], 7);
      expect(
        sent.every((c) => c['updated_at'] == stamp.toIso8601String()),
        isTrue,
      );
      expect(
        (await db.select(db.syncChanges).get()).every(
          (c) => c.pushedAt != null,
        ),
        isTrue,
      );
    }),
  );

  test(
    '明确分类拒收由显式重试唤醒，新拒收原因保留且不自动循环',
    () => verifyFlow(() async {
      final categoryChange = await rejected(
        type: 'category',
        id: categoryId,
        code: 'INVALID_CATEGORY_ICON',
      );
      var attempts = 0;
      when(
        () => endpoint.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        attempts++;
        final request =
            call.namedArguments[#postSyncPushRequest]
                as api.PostSyncPushRequest;
        final change = syncRequestChanges(request).single;
        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(
            request,
            overrides: [
              api.PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = change['mutation_id'] as String
                  ..entityId = categoryId
                  ..status =
                      api.PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                  ..code = 'INVALID_CATEGORY_ICON'
                  ..message = '服务端原文可能包含私密用户内容',
              ),
            ],
          ),
        );
      });
      await service.retryRejectedChange(categoryChange.toString());
      await service.push();
      await service.push();
      expect(attempts, 1);
      final remaining = await db.select(db.syncChanges).getSingle();
      expect(remaining.rejectionCode, 'INVALID_CATEGORY_ICON');
      expect(remaining.rejectionReason, contains('重新选择图标'));
      expect(remaining.rejectionReason, isNot(contains('私密用户内容')));
    }),
  );

  test(
    '权威分类恢复只解除本人账本的分类依赖拒绝，其他错误与账号保持原值',
    () => verifyFlow(() async {
      await rejected();
      await rejected(id: 'amount-error', code: 'INVALID_NATIVE_AMOUNT');
      await rejected(id: 'other-account', owner: 'other');
      await rejected(id: 'corrupt-payload');
      await (db.update(db.syncChanges)
            ..where((c) => c.entityId.equals('corrupt-payload')))
          .write(const SyncChangesCompanion(payload: d.Value('invalid json')));
      final before = await db.select(db.syncChanges).get();
      await service.projectionHandler.upsertCategory(
        cloudCategory(),
        accountId: account,
      );
      final after = await db.select(db.syncChanges).get();
      final recovered = after.singleWhere((c) => c.entityId == txId);
      expect(recovered.rejectionReason, isNull);
      expect(recovered.rejectionCode, isNull);
      expect(recovered.frozenRequest, isNull);
      expect(recovered.payload, jsonEncode(txPayload));
      for (final id in ['amount-error', 'other-account', 'corrupt-payload']) {
        expect(
          after.singleWhere((c) => c.entityId == id),
          before.singleWhere((c) => c.entityId == id),
        );
      }
    }),
  );

  test(
    '缺失拒收码时保留未知失败，不按消息猜测可自动恢复的分类依赖',
    () => verifyFlow(() async {
      final changeId = await rejected(
        type: 'category',
        id: categoryId,
        code: 'INVALID_CATEGORY_ICON',
      );
      when(
        () => endpoint.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest]
                as api.PostSyncPushRequest;
        final change = syncRequestChanges(request).single;
        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(
            request,
            overrides: [
              api.PostSyncPush200ResponseOutcomesInner(
                (b) => b
                  ..mutationId = change['mutation_id'] as String
                  ..entityId = categoryId
                  ..status =
                      api.PostSyncPush200ResponseOutcomesInnerStatusEnum.invalid
                  ..message = '父分类不存在或不可用',
              ),
            ],
          ),
        );
      });
      await service.retryRejectedChange(changeId.toString());
      await service.push();
      final rejectedChange = await db.select(db.syncChanges).getSingle();
      expect(rejectedChange.rejectionCode, 'UNKNOWN_VALIDATION');
      expect(rejectedChange.rejectionReason, contains('未提供可识别的失败原因'));
      expect(rejectedChange.rejectionReason, isNot(contains('父分类不存在')));
      verify(
        () => endpoint.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).called(1);
    }),
  );

  test(
    '分类墓碑、共享账本和结果未知后继不能被分类确认自动改写',
    () => verifyFlow(() async {
      await rejected();
      final before = await db.select(db.syncChanges).getSingle();
      await service.projectionHandler.upsertCategory(
        cloudCategory(deleted: true),
        accountId: account,
      );
      expect(await db.select(db.syncChanges).getSingle(), before);
      await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
        const LedgersCompanion(
          role: d.Value('editor'),
          ownerAccountId: d.Value('other-owner'),
        ),
      );
      await service.projectionHandler.upsertCategory(
        cloudCategory(),
        accountId: account,
      );
      expect(await db.select(db.syncChanges).getSingle(), before);
      await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
        const LedgersCompanion(
          role: d.Value('owner'),
          ownerAccountId: d.Value(account),
        ),
      );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: txId,
              ledgerId: const d.Value(ledgerId),
              action: 'upsert',
              payload: jsonEncode({...txPayload, 'amount': '200'}),
              updatedAt: stamp,
              mutationId: 'unknown-successor',
              accountId: const d.Value(account),
              frozenRequest: const d.Value('{"unknown":true}'),
            ),
          );
      final queue = await db.select(db.syncChanges).get();
      await service.projectionHandler.upsertCategory(
        cloudCategory(),
        accountId: account,
      );
      expect(await db.select(db.syncChanges).get(), queue);
    }),
  );

  test(
    '另一设备恢复分类的真实增量拉取会解除关联拒绝并推进游标',
    () => verifyFlow(() async {
      await rejected();
      final eventTime = stamp.add(const Duration(days: 1));
      final response = api.standardSerializers.deserializeWith(
        api.GetSyncPull200Response.serializer,
        {
          'changes': [
            {
              'change_id': '101',
              'entity_type': 'category',
              'entity_id': categoryId,
              'ledger_id': null,
              'action': 'upsert',
              'payload': {
                ...categoryPayload,
                'owner_id': account,
                'id': categoryId,
                'updated_at': eventTime.toIso8601String(),
                'deleted_at': null,
                'version_token': 'b' * 64,
              },
              'updated_at': eventTime.toIso8601String(),
              'device_id': '50000000-0000-4000-8000-000000000001',
              'mutation_id': '60000000-0000-4000-8000-000000000001',
            },
          ],
          'server_cursor': '101',
          'has_more': false,
        },
      )!;
      when(() => endpoint.getSyncPull(since: any(named: 'since'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          data: response,
        ),
      );
      expect(await service.pull(), 1);
      final recovered = await db.select(db.syncChanges).getSingle();
      expect(recovered.rejectionCode, isNull);
      expect(recovered.rejectionReason, isNull);
      expect(recovered.payload, jsonEncode(txPayload));
      expect((await db.select(db.syncState).getSingle()).serverCursor, '101');
    }),
  );

  test(
    '无新增事件的 ignored 仍可凭存活权威分类恢复依赖',
    () => verifyFlow(() async {
      final categoryChange = await rejected(
        type: 'category',
        id: categoryId,
        code: 'INVALID_CATEGORY_ICON',
      );
      await rejected();
      final sent = <String>[];
      when(
        () => endpoint.postSyncPush(
          postSyncPushRequest: any(named: 'postSyncPushRequest'),
        ),
      ).thenAnswer((call) async {
        final request =
            call.namedArguments[#postSyncPushRequest]
                as api.PostSyncPushRequest;
        final changes = syncRequestChanges(request);
        sent.addAll(changes.map((c) => c['entity_type'] as String));
        return Response(
          requestOptions: RequestOptions(path: '/sync/push'),
          data: acknowledgeSyncRequest(
            request,
            overrides: [
              for (final change in changes)
                if (change['entity_type'] == 'category')
                  api.PostSyncPush200ResponseOutcomesInner(
                    (b) => b
                      ..mutationId = change['mutation_id'] as String
                      ..entityId = categoryId
                      ..status = api
                          .PostSyncPush200ResponseOutcomesInnerStatusEnum
                          .ignored
                      ..categoryState = cloudCategory().toBuilder(),
                  ),
            ],
          ),
        );
      });
      await service.retryRejectedChange(categoryChange.toString());
      await service.push();
      expect(sent, ['category', 'transaction']);
      expect(
        (await db.select(db.syncChanges).get()).every(
          (c) => c.pushedAt != null,
        ),
        isTrue,
      );
    }),
  );

  test(
    '父分类确认恢复依赖缺失的子分类，永久结构错误保持拒绝',
    () => verifyFlow(() async {
      for (final entry in const {
        'child-pending': 'CATEGORY_PARENT_UNAVAILABLE',
        'child-invalid': 'CATEGORY_PARENT_FORBIDDEN',
      }.entries) {
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: 'category',
                entityId: entry.key,
                action: 'upsert',
                payload: jsonEncode({
                  ...categoryPayload,
                  'level': '2',
                  'parent_id': categoryId,
                }),
                updatedAt: stamp,
                mutationId: 'original-${entry.key}',
                accountId: const d.Value(account),
                rejectionCode: d.Value(entry.value),
                rejectionReason: d.Value(syncRejectionReason(entry.value)),
              ),
            );
      }
      final before = await db.select(db.syncChanges).get();
      await service.projectionHandler.upsertCategory(
        cloudCategory(),
        accountId: account,
      );
      final after = await db.select(db.syncChanges).get();
      expect(
        after.singleWhere((c) => c.entityId == 'child-pending').rejectionCode,
        isNull,
      );
      expect(
        after.singleWhere((c) => c.entityId == 'child-invalid'),
        before.singleWhere((c) => c.entityId == 'child-invalid'),
      );
    }),
  );

  test(
    '分类仍有未确认本机编辑时，权威快照不能解除关联拒绝',
    () => verifyFlow(() async {
      await rejected();
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: categoryId,
              action: 'upsert',
              payload: jsonEncode(categoryPayload),
              updatedAt: stamp,
              mutationId: 'category-edit',
              accountId: const d.Value(account),
            ),
          );
      final before = await db.select(db.syncChanges).get();
      await service.projectionHandler.upsertCategory(
        cloudCategory(),
        accountId: account,
      );
      expect(await db.select(db.syncChanges).get(), before);
    }),
  );

  test(
    '共享分类恢复只重新登记对应共享账本，不影响私有及其他Owner同编号引用',
    () => verifyFlow(() async {
      await rejected();
      const firstShared = '20000000-0000-4000-8000-000000000002';
      const secondShared = '20000000-0000-4000-8000-000000000003';
      for (final pair in const {
        firstShared: 'owner-one',
        secondShared: 'owner-two',
      }.entries) {
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: pair.key,
                name: '共享账本',
                updatedAt: stamp,
                storageMode: const d.Value('cloud'),
                scopeAccountId: const d.Value(account),
                ownerAccountId: d.Value(pair.value),
                role: const d.Value('editor'),
              ),
            );
        final id = await rejected(id: pair.key);
        await (db.update(db.syncChanges)..where((c) => c.id.equals(id))).write(
          SyncChangesCompanion(ledgerId: d.Value(pair.key)),
        );
        await db
            .into(db.sharedLedgerCategories)
            .insert(
              SharedLedgerCategoriesCompanion.insert(
                ledgerId: pair.key,
                categoryId: categoryId,
                name: '共享分类',
                kind: 'expense',
                updatedAt: stamp,
                deletedAt: d.Value(stamp),
              ),
            );
      }
      final before = await db.select(db.syncChanges).get();
      await service.runtime.rejectionRecovery.sharedCategoryAvailable(
        categoryId,
        firstShared,
        account,
      );
      expect(
        await db.select(db.syncChanges).get(),
        before,
        reason: '分类墓碑没有存活证明',
      );
      await (db.update(
        db.sharedLedgerCategories,
      )..where((c) => c.ledgerId.equals(firstShared))).write(
        const SharedLedgerCategoriesCompanion(deletedAt: d.Value(null)),
      );
      await service.runtime.rejectionRecovery.sharedCategoryAvailable(
        categoryId,
        firstShared,
        account,
      );
      final after = await db.select(db.syncChanges).get();
      expect(
        after.singleWhere((c) => c.entityId == firstShared).rejectionCode,
        isNull,
      );
      for (final id in [txId, secondShared]) {
        expect(
          after.singleWhere((c) => c.entityId == id),
          before.singleWhere((c) => c.entityId == id),
        );
      }
    }),
  );

  test('拒收结果只使用稳定错误码，缺失及私密内容保持安全未知原因', () {
    expect(syncRejectionCode('INVALID_CATEGORY_ICON'), 'INVALID_CATEGORY_ICON');
    expect(
      syncRejectionCode('CATEGORY_PARENT_UNAVAILABLE'),
      'CATEGORY_PARENT_UNAVAILABLE',
    );
    expect(syncRejectionCode(null), 'UNKNOWN_VALIDATION');
    expect(syncRejectionCode('level 字段无效'), 'UNKNOWN_VALIDATION');
    expect(syncRejectionCode('private@example.com'), 'UNKNOWN_VALIDATION');
    expect(syncRejectionReason('UNKNOWN_VALIDATION'), contains('未提供可识别的失败原因'));
  });

  test(
    '明确分类拒收后重试保留队列UTC毫秒时间并完成两项上传',
    () => verifyFlow(() async {
      final precise = stamp.add(const Duration(milliseconds: 947));
      final content = {
        ...categoryPayload,
        'updated_at': precise.toLocal().toIso8601String(),
      };
      final wireBody = {...content}..remove('updated_at');
      final frozen = jsonEncode({
        'mutation_id': 'old-$account-$categoryId',
        'entity_type': 'category',
        'entity_id': categoryId,
        'ledger_id': null,
        'action': 'upsert',
        'updated_at': precise.toIso8601String(),
        'payload': wireBody,
      });
      final categoryChange = await rejected(
        type: 'category',
        id: categoryId,
        code: 'INVALID_CATEGORY_ICON',
        content: content,
        frozenEnvelope: frozen,
        updatedAt: precise,
      );
      final transactionChange = await rejected();
      final sent = <Map<String, dynamic>>[];
      when(
        () => endpoint.postSyncPush(
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
      await service.retryRejectedChange(categoryChange.toString());
      await service.retryRejectedChange(transactionChange.toString());
      final issues = await readSyncIssues(db, account: account);
      expect(
        issues.singleWhere((i) => i.kind == SyncIssueKind.pendingUpload).count,
        2,
      );
      await service.push();
      expect(sent.map((c) => c['entity_type']), ['category', 'transaction']);
      expect(sent.first['entity_id'], categoryId);
      expect(sent.first['updated_at'], precise.toIso8601String());
      expect(sent.first['payload'], wireBody);
      expect((await db.select(db.categories).get()).map((c) => c.id), [
        categoryId,
      ]);
      expect(
        (await db.select(db.syncChanges).get()).every(
          (c) => c.pushedAt != null,
        ),
        isTrue,
      );
    }),
  );

  test(
    '结果未知的分类冻结请求重试沿用原幂等身份与UTC包络',
    () => verifyFlow(() async {
      final precise = stamp.add(const Duration(milliseconds: 947));
      final content = {
        ...categoryPayload,
        'updated_at': precise.toLocal().toIso8601String(),
      };
      final wireBody = {...content}..remove('updated_at');
      const mutation = '50000000-0000-4000-8000-000000000001';
      final envelope = {
        'mutation_id': mutation,
        'entity_type': 'category',
        'entity_id': categoryId,
        'action': 'upsert',
        'updated_at': precise.toIso8601String(),
        'payload': wireBody,
      };
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: categoryId,
              action: 'upsert',
              payload: jsonEncode(content),
              frozenRequest: d.Value(jsonEncode(envelope)),
              updatedAt: precise,
              mutationId: mutation,
              accountId: const d.Value(account),
            ),
          );
      final sent = <Map<String, dynamic>>[];
      when(
        () => endpoint.postSyncPush(
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
      final before = await db.select(db.syncChanges).getSingle();
      await service.retryRejectedChange(before.id.toString());
      expect(await db.select(db.syncChanges).getSingle(), before);
      await service.push();
      expect(sent.single['mutation_id'], mutation);
      expect(sent.single['updated_at'], precise.toIso8601String());
      expect(sent.single['payload'], wireBody);
      expect((await db.select(db.syncChanges).getSingle()).pushedAt, isNotNull);
    }),
  );
}
