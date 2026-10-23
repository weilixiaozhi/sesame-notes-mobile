import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart'
    show PatchLedgersByLedgerIdCategoriesByCategoryIdRequest;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/category_conflict_state.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'request_observation.dart';

/// 经生产仓储和生成客户端验证分类层级、交易引用、复制及转云。
Future<void> runCategoryRoundtrip(
  SyncService a,
  SyncService b,
  String account, {
  required Future<void> Function(LocalRepository repo, String ledgerId)
  promoteLocal,
}) async {
  LocalRepository repository(SyncService sync) => LocalRepository(
    sync.db,
    changeTracker: ChangeRecorderImpl(sync.db, accountIdGetter: () => account),
    accountIdGetter: () => account,
  );
  final repoA = repository(a), repoB = repository(b);
  final generatedLevels = <Object?>[];
  final categoryOutcomes = <Map>[];
  final observer = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/v1/sync/push') {
        final data = observedRequestBody(options.data);
        final changes = data['changes'];
        if (changes is List) {
          for (final change in changes.whereType<Map>()) {
            if (change['entity_type'] == 'category' &&
                change['action'] == 'upsert' &&
                change['payload'] is Map) {
              generatedLevels.add((change['payload'] as Map)['level']);
              printOnFailure('生成分类请求: $change');
            }
          }
        }
      }
      // 只观察生成客户端的最终请求，不能在测试中修改 level 掩盖兼容问题。
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (response.requestOptions.path == '/api/v1/sync/push') {
        printOnFailure('分类链推送回执: ${response.data}');
        final request = observedRequestBody(response.requestOptions.data);
        final categoryIds = (request['changes'] as List)
            .whereType<Map>()
            .where((change) => change['entity_type'] == 'category')
            .map((change) => change['mutation_id'])
            .toSet();
        categoryOutcomes.addAll(
          ((response.data as Map)['outcomes'] as List).whereType<Map>().where(
            (outcome) => categoryIds.contains(outcome['mutation_id']),
          ),
        );
      }
      handler.next(response);
    },
  );
  a.client.dio.interceptors.add(observer);
  b.client.dio.interceptors.add(observer);
  addTearDown(() {
    a.client.dio.interceptors.remove(observer);
    b.client.dio.interceptors.remove(observer);
  });

  final ledgerId = await repoA.createLedger(
    name: '分类真实往返',
    storageMode: 'cloud',
  );
  await a.push();
  await a.full(ledgerId: ledgerId);
  await b.pull();
  await b.full(ledgerId: ledgerId);
  final parentId = await repoA.createCategory(
    name: '自定义父分类',
    kind: 'expense',
    icon: 'utensils',
    sortOrder: 17,
  );
  final childId = await repoA.createSubCategory(
    parentId: parentId,
    name: '引用子分类',
    kind: 'expense',
    icon: 'coffee',
    sortOrder: 2,
  );
  final spareId = await repoA.createSubCategory(
    parentId: parentId,
    name: '待删子分类',
    kind: 'expense',
    icon: 'shopping-bag',
    sortOrder: 3,
  );
  final transactionId = await repoA.addTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '12.34',
    nativeAmount: '12.34',
    currencyCode: 'CNY',
    categoryId: childId,
    happenedAt: DateTime.utc(2026, 1, 5),
    note: '必须保留分类引用',
  );
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  expect((await repoB.categoryStore.getCategoryById(parentId))!.level, 1);
  final child = (await repoB.categoryStore.getCategoryById(childId))!;
  expect(child.level, 2);
  expect(child.parentId, parentId);
  expect(child.icon, 'coffee');
  expect((await repoB.getTransactionById(transactionId))!.categoryId, childId);
  await _expectSnapshot(a, ledgerId, transactionId, childId, '引用子分类');

  // Web 同类 REST 写入使用服务端毫秒时钟，手机拉取后再作人工编辑。
  final webEdit =
      (await a.client
              .getCategoriesApi()
              .patchLedgersByLedgerIdCategoriesByCategoryId(
                ledgerId: ledgerId,
                categoryId: parentId,
                patchLedgersByLedgerIdCategoriesByCategoryIdRequest:
                    PatchLedgersByLedgerIdCategoriesByCategoryIdRequest(
                      (builder) => builder..name = 'Web 毫秒改名',
                    ),
              ))
          .data!;
  await b.pull();
  expect(
    (await repoB.categoryStore.getCategoryById(parentId))!.name,
    'Web 毫秒改名',
  );

  // 第二设备实际改名、图标和排序，再检验第一设备及 REST 快照。
  await repoB.updateCategory(parentId, name: '第二设备父分类');
  for (var index = 0; index < 100; index++) {
    await repoB.updateCategory(parentId, name: '连续改名$index');
  }
  await repoB.updateCategory(parentId, name: '第二设备父分类');
  await repoB.updateCategory(childId, name: '第二设备子分类', icon: 'apple');
  await repoB.updateCategorySortOrders([
    (id: spareId, sortOrder: 0),
    (id: childId, sortOrder: 1),
  ]);
  expect(
    (await repoB.categoryStore.getCategoryById(parentId))!.name,
    '第二设备父分类',
    reason: '第二设备保存必须先更新本地数据',
  );
  await b.push();
  await _expectAcknowledged(b);
  final editedFull = (await b.client.getSyncApi().getSyncFull(
    ledgerId: ledgerId,
  )).data!;
  expect(
    editedFull.categories.singleWhere((row) => row.id == parentId).updatedAt,
    isNot(webEdit.updatedAt),
  );
  expect(categoryOutcomes, isNotEmpty);
  expect(
    categoryOutcomes.every(
      (outcome) =>
          outcome['status'] == 'accepted' && outcome['change_id'] != null,
    ),
    isTrue,
    reason: '人工编辑逐项必须被接受，不能把 ignored 清队列当作保存成功',
  );
  expect(
    editedFull.categories.singleWhere((row) => row.id == parentId).name,
    '第二设备父分类',
    reason: '已确认的改名必须实际到达服务端',
  );
  await a.pull();
  expect(
    (await repoA.categoryStore.getCategoryById(parentId))!.name,
    '第二设备父分类',
  );
  expect((await repoA.categoryStore.getCategoryById(childId))!.name, '第二设备子分类');
  expect((await repoA.categoryStore.getCategoryById(childId))!.icon, 'apple');
  expect(
    (await repoA.categoryStore.getSubCategories(parentId)).map((row) => row.id),
    [spareId, childId],
  );
  await _expectSnapshot(a, ledgerId, transactionId, childId, '第二设备子分类');
  await expectLater(repoA.deleteCategory(parentId), throwsStateError);
  await expectLater(repoA.deleteCategory(childId), throwsStateError);
  await repoA.deleteCategory(spareId);
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  expect(await repoB.categoryStore.getCategoryById(spareId), isNull);

  // 同账号复制保留分类编号，云端和本地目录按账本归属独立保存。
  final copyId = await a.transferToLocal(
    SyncTarget('ledger', ledgerId),
    move: false,
  );
  final copied = await _transactions(a, copyId);
  expect(copied, hasLength(1));
  expect(copied.single.id, isNot(transactionId));
  expect(copied.single.categoryId, childId);
  expect(copied.single.note, '必须保留分类引用');
  final localCopyLedger = (await repoA.getLedgerById(copyId))!;
  final copyMembers = await (a.db.select(
    a.db.ledgerMembers,
  )..where((row) => row.ledgerId.equals(copyId))).get();
  printOnFailure(
    '复制后本人=${localCopyLedger.selfMemberId}；交易付款=${copied.single.payerMemberId}；成员=$copyMembers',
  );
  for (final scope in <String?>[
    categoryScopeForLedger(localCopyLedger),
    account,
  ]) {
    final scoped =
        await (a.db.select(a.db.categories)..where(
              (row) =>
                  row.id.equals(childId) & categoryScopePredicate(row, scope),
            ))
            .get();
    expect(scoped, hasLength(1), reason: '每个分类域中的同一编号只允许保留一份记录');
    expect(scoped.single.scopeAccountId, scope);
    expect(scoped.single.name, '第二设备子分类');
    expect(scoped.single.parentId, parentId);
    expect(scoped.single.cloudRegistered, scope != null);
  }
  final copiedCatalog = await readLedgerCategoryCatalog(a.db, copyId);
  expect(copiedCatalog[childId]?.scopeAccountId, isNull);
  expect(copiedCatalog[childId]?.name, '第二设备子分类');
  await promoteLocal(repoA, copyId);
  final promotedLedger = (await repoA.getLedgerById(copyId))!;
  final promotedTransaction = (await repoA.getTransactionById(
    copied.single.id,
  ))!;
  printOnFailure(
    '转云后本人=${promotedLedger.selfMemberId}；交易付款=${promotedTransaction.payerMemberId}',
  );
  final promotedCategories =
      await (a.db.select(a.db.categories)..where(
            (row) =>
                row.id.equals(childId) & categoryScopePredicate(row, account),
          ))
          .get();
  expect(promotedCategories, hasLength(1), reason: '同账号转云复用既有分类身份，不重复投影');
  expect(
    (await readLedgerCategoryCatalog(a.db, copyId))[childId]?.scopeAccountId,
    account,
  );
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  await b.full(ledgerId: copyId);
  expect(
    (await repoB.getTransactionById(copied.single.id))!.categoryId,
    childId,
  );
  await _expectSnapshot(b, copyId, copied.single.id, childId, '第二设备子分类');

  // 未上云的父子分类必须在首次转云时按依赖注册；不预先单独推分类。
  final localId = await repoA.createLedger(
    name: '本地分类首次转云',
    storageMode: 'local',
    localSelfId: 'recurring-e2e-self',
  );
  final localParent = await repoA.createCategory(
    name: '本地专用父分类',
    kind: 'expense',
    recordChanges: false,
    ledgerId: localId,
  );
  final localChild = await repoA.createSubCategory(
    parentId: localParent,
    name: '本地专用子分类',
    kind: 'expense',
    recordChanges: false,
    ledgerId: localId,
  );
  final localTx = await repoA.addTransaction(
    ledgerId: localId,
    type: 'expense',
    amount: '7.25',
    nativeAmount: '7.25',
    currencyCode: 'CNY',
    categoryId: localChild,
    happenedAt: DateTime.utc(2026, 1, 6),
  );
  await _expectAcknowledged(a);
  await promoteLocal(repoA, localId);
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  await b.full(ledgerId: localId);
  expect(
    (await repoB.categoryStore.getCategoryById(localChild))!.parentId,
    localParent,
  );
  await _expectSnapshot(b, localId, localTx, localChild, '本地专用子分类');
  await _aaCopyRoundtrip(a, b, repoA, repoB, localChild, promoteLocal);

  // 先删除两本中的引用交易，再删除分类，远端不得保留可用分类或悬空交易。
  await repoA.deleteTransaction(transactionId);
  await repoA.deleteTransaction(copied.single.id);
  await a.push();
  await a.pull();
  await repoA.deleteCategory(childId);
  await repoA.deleteCategory(parentId);
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  expect(await repoB.categoryStore.getCategoryById(childId), isNull);
  expect(await repoB.categoryStore.getCategoryById(parentId), isNull);
  expect(await repoB.getTransactionById(transactionId), isNull);
  expect(await repoB.getTransactionById(copied.single.id), isNull);
  final full = (await b.client.getSyncApi().getSyncFull(
    ledgerId: copyId,
  )).data!;
  expect(full.transactions, isEmpty);
  expect(
    full.categories.where(
      (row) => [parentId, childId, spareId].contains(row.id),
    ),
    isEmpty,
  );
  expect(generatedLevels, containsAll([1, 2]));
  expect(
    generatedLevels.every(
      (level) => level is int && (level == 1 || level == 2),
    ),
    isTrue,
    reason: '分类层级在真实 HTTP 请求中必须保持整数类型和值域',
  );
}

/// AA 分摊复制后必须全部引用目标成员，再经真实转云由另一设备恢复。
Future<void> _aaCopyRoundtrip(
  SyncService a,
  SyncService b,
  LocalRepository repoA,
  LocalRepository repoB,
  String categoryId,
  Future<void> Function(LocalRepository, String) promoteLocal,
) async {
  final source = await repoA.createLedger(name: 'AA 成员映射', aaEnabled: true);
  await a.push();
  await a.full(ledgerId: source);
  final owner = (await repoA.getMembersByLedger(
    source,
  )).singleWhere((row) => row.memberType == 'REGISTERED');
  final payer = await repoA.createPlaceholderMember(
    ledgerId: source,
    name: '共同付款成员',
  );
  await a.push();
  final original = await repoA.addTransaction(
    ledgerId: source,
    type: 'expense',
    amount: '10.25',
    nativeAmount: '10.25',
    currencyCode: 'CNY',
    categoryId: categoryId,
    happenedAt: DateTime.utc(2026, 2, 1),
    payerMemberId: payer,
    operatorMemberId: owner.id,
    aaMode: 2,
    splits: [
      TransactionSplitInput(memberId: owner.id, amount: '5'),
      TransactionSplitInput(memberId: payer, amount: '5.25'),
    ],
  );
  await a.push();
  await _expectAcknowledged(a);
  final copied = await a.transferToLocal(
    SyncTarget('ledger', source),
    move: false,
  );
  final transaction = (await _transactions(a, copied)).single;
  final copyLedger = (await repoA.getLedgerById(copied))!;
  final members = await repoA.getMembersByLedger(copied);
  final memberIds = members.map((row) => row.id).toSet();
  expect(transaction.createdByMemberId, copyLedger.selfMemberId);
  expect(transaction.payerMemberId, isNot(payer));
  expect(memberIds, contains(transaction.payerMemberId));
  final splits = await repoA.getTransactionSplits(transaction.id);
  expect(splits.map((row) => row.memberId).toSet(), {
    copyLedger.selfMemberId,
    transaction.payerMemberId,
  });
  expect(splits.map((row) => row.amount).toSet(), {'5', '5.25'});
  await promoteLocal(repoA, copied);
  await a.push();
  await _expectAcknowledged(a);
  await b.pull();
  await b.full(ledgerId: copied);
  final remote = (await b.client.getSyncApi().getSyncFull(
    ledgerId: copied,
  )).data!;
  final remoteTx = remote.transactions.single;
  expect(remoteTx.amount, '10.25');
  expect(remoteTx.payerMemberId, transaction.payerMemberId);
  final remoteMemberIds = remote.members.map((row) => row.id).toSet();
  expect(
    remoteMemberIds,
    containsAll(remoteTx.splits.map((row) => row.memberId)),
  );
  expect(
    (await repoB.getTransactionById(transaction.id))!.categoryId,
    categoryId,
  );
  expect(
    (await repoB.getTransactionSplits(
      transaction.id,
    )).map((row) => row.amount).toSet(),
    {'5', '5.25'},
  );
  expect(
    (await repoA.getTransactionById(original))!.payerMemberId,
    payer,
    reason: '复制转云不修改源账本的成员和分摊',
  );
}

/// 每轮写入必须确认落库，不能将同步接口部分拒收视作成功。
Future<void> _expectAcknowledged(SyncService sync) async {
  final pending = await (sync.db.select(
    sync.db.syncChanges,
  )..where((row) => row.pushedAt.isNull())).get();
  expect(pending, isEmpty, reason: '生成客户端真实推送必须全部确认');
}

/// 用生成的 full 响应检查服务端分类快照，不手写传输类型。
Future<void> _expectSnapshot(
  SyncService sync,
  String ledgerId,
  String transactionId,
  String categoryId,
  String name,
) async {
  final full = (await sync.client.getSyncApi().getSyncFull(
    ledgerId: ledgerId,
  )).data!;
  final transaction = full.transactions.singleWhere(
    (row) => row.id == transactionId,
  );
  expect(transaction.categoryId, categoryId);
  expect(transaction.categoryName, name);
  expect(full.categories.singleWhere((row) => row.id == categoryId).name, name);
}

/// 读取当前有效的本地交易以验证复制后的真实引用关系。
Future<List<Transaction>> _transactions(SyncService sync, String ledgerId) =>
    (sync.db.select(sync.db.transactions)..where(
          (row) => row.ledgerId.equals(ledgerId) & row.deletedAt.isNull(),
        ))
        .get();

/// 分类 A：两份 SQLite、真实候选确认及服务端提交后的回执中断；只使用本轮新账号。
Future<void> runCategoryConflictRoundtrip(
  SyncService a,
  SyncService b,
  String account,
) async {
  LocalRepository repository(SyncService sync) => LocalRepository(
    sync.db,
    changeTracker: ChangeRecorderImpl(sync.db, accountIdGetter: () => account),
    accountIdGetter: () => account,
  );
  final repoA = repository(a), repoB = repository(b);
  final ledgerId = await repoA.createLedger(
    name: '分类确认真实往返',
    storageMode: 'cloud',
  );
  await a.push();
  await a.full(ledgerId: ledgerId);
  final parentId = defaultCategoryId(level: 1, key: 'dining');
  final childId = defaultCategoryId(level: 2, key: 'dining_dinner');
  await repoA.insertCanonicalCategory(
    id: parentId,
    name: '饮食',
    kind: 'expense',
    level: 1,
  );
  await repoA.insertCanonicalCategory(
    id: childId,
    name: '晚餐',
    kind: 'expense',
    level: 2,
    parentId: parentId,
  );
  await a.push();
  await _expectAcknowledged(a);
  await a.full(ledgerId: ledgerId);
  await b.pull();
  await b.full(ledgerId: ledgerId);

  Future<void> webName(String id, String name) async {
    final current = (await b.client.getSyncApi().getSyncFull(
      ledgerId: ledgerId,
    )).data!.categories.singleWhere((row) => row.id == id);
    await b.client
        .getCategoriesApi()
        .patchLedgersByLedgerIdCategoriesByCategoryId(
          ledgerId: ledgerId,
          categoryId: id,
          expectedVersionToken: current.versionToken,
          idempotencyKey: const Uuid().v4(),
          patchLedgersByLedgerIdCategoriesByCategoryIdRequest:
              PatchLedgersByLedgerIdCategoriesByCategoryIdRequest(
                (builder) => builder..name = name,
              ),
        );
  }

  Future<String> cloudName(String id) async {
    final full = (await b.client.getSyncApi().getSyncFull(
      ledgerId: ledgerId,
    )).data!;
    return full.categories.singleWhere((category) => category.id == id).name;
  }

  Future<SyncChange> change(String mutation) => (a.db.select(
    a.db.syncChanges,
  )..where((row) => row.mutationId.equals(mutation))).getSingle();
  Future<SyncIssue> issue(SyncService sync, String id) async =>
      (await readSyncIssues(sync.db, account: account)).singleWhere(
        (row) =>
            row.kind == SyncIssueKind.conflict &&
            row.target == SyncTarget('category', id),
      );

  final transactionId = await repoA.addTransaction(
    ledgerId: ledgerId,
    type: 'expense',
    amount: '16.8',
    nativeAmount: '16.8',
    currencyCode: 'CNY',
    categoryId: parentId,
    happenedAt: DateTime.now().toUtc(),
    note: '分类确认始终保留原ID引用',
  );
  await a.push();
  await _expectAcknowledged(a);
  final parent = (await repoA.categoryStore.getCategoryById(parentId))!;
  expect(parent.serverVersionToken, isNotNull);
  await webName(parentId, 'Web 已确认的饮食');

  // 精确模拟旧客户端已经持久化的无云基线意图；不伪造新的 HTTP DTO。
  final head = const Uuid().v4();
  final now = DateTime.now().toUtc();
  await a.db
      .into(a.db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: 'category',
          entityId: parentId,
          action: 'upsert',
          mutationId: head,
          accountId: d.Value(account),
          updatedAt: now,
          payload: jsonEncode({
            'name': '旧离线饮食',
            'kind': parent.kind,
            'level': '1',
            'sort_order': parent.sortOrder,
            'icon': parent.icon,
            'parent_id': null,
            'updated_at': now.toIso8601String(),
          }),
        ),
      );
  await a.push();
  final first = await issue(a, parentId);
  expect(first.local?['name'], '旧离线饮食');
  expect(first.remote?['name'], 'Web 已确认的饮食');
  expect(await cloudName(parentId), 'Web 已确认的饮食');
  expect((await change(head)).pushedAt, isNull);
  expect((await change(head)).frozenRequest, isNotNull);

  await repoA.updateCategory(parentId, name: '确认期间的后继饮食编辑');
  final successor =
      await (a.db.select(a.db.syncChanges)..where(
            (row) =>
                row.entityId.equals(parentId) &
                row.pushedAt.isNull() &
                row.mutationId.equals(head).not(),
          ))
          .getSingle();
  final successorPayload = successor.payload;
  final decisions = <String>[];
  var loseDecision = true;
  final lostDecision = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/v1/category-conflicts/${first.id}/resolve') {
        decisions.add(observedRequestJson(options.data));
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (loseDecision &&
          response.requestOptions.path ==
              '/api/v1/category-conflicts/${first.id}/resolve') {
        loseDecision = false;
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.connectionError,
            error: '合成断线：服务端确认后丢失回执',
          ),
        );
      } else {
        handler.next(response);
      }
    },
  );
  a.client.dio.interceptors.add(lostDecision);
  try {
    await expectLater(
      a.resolveCategoryConflict(
        first.id,
        keepLocal: false,
        expectedDecisionVersion: first.decisionVersion!,
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    expect((await issue(a, parentId)).resolutionPending, isTrue);
    expect((await change(head)).pushedAt, isNull);
    await webName(parentId, '确认后另一端再次修改');
    await a.retryCategoryConflictResolution(first.id);
    expect(decisions, hasLength(2));
    expect(decisions[1], decisions[0], reason: '未知回执只能重试原 mutation 和完整确认正文');
  } finally {
    a.client.dio.interceptors.remove(lostDecision);
  }
  expect((await change(head)).pushedAt, isNotNull);
  expect((await change(successor.mutationId)).pushedAt, isNull);
  expect((await change(successor.mutationId)).payload, successorPayload);
  await a.push();
  final next = await issue(a, parentId);
  expect(next.id, isNot(first.id));
  expect(next.local?['name'], '确认期间的后继饮食编辑');
  expect(next.remote?['name'], '确认后另一端再次修改');
  expect(
    await cloudName(parentId),
    '确认后另一端再次修改',
    reason: '重试所得最新云态不得自动授权旧后继覆盖',
  );
  await a.resolveCategoryConflict(
    next.id,
    keepLocal: true,
    expectedDecisionVersion: next.decisionVersion!,
  );
  await b.pull();
  expect(
    (await repoB.categoryStore.getCategoryById(parentId))!.name,
    '确认期间的后继饮食编辑',
  );
  expect((await repoB.getTransactionById(transactionId))!.categoryId, parentId);
  final cloud = (await b.client.getSyncApi().getSyncFull(
    ledgerId: ledgerId,
  )).data!;
  expect(cloud.categories.where((row) => row.id == parentId), hasLength(1));
  expect(
    cloud.categories.where((row) => row.name == '确认期间的后继饮食编辑'),
    hasLength(1),
  );
  await _expectAcknowledged(a);

  // 旧冻结 delete 仍含完整旧字段、字符串 level、显式 null 和未知字段。
  final child = (await repoA.categoryStore.getCategoryById(childId))!;
  await webName(childId, 'Web 晚餐');
  final deleteMutation = const Uuid().v4();
  final deletedAt = DateTime.fromMillisecondsSinceEpoch(
    DateTime.now().millisecondsSinceEpoch,
    isUtc: true,
  );
  final oldPayload = <String, dynamic>{
    'name': child.name,
    'kind': child.kind,
    'level': '2',
    'icon': null,
    'parent_id': parentId,
    'sort_order': child.sortOrder,
    'unknown': {
      'order': [null, 2, '1'],
    },
    'updated_at': deletedAt.toIso8601String(),
  };
  final oldRequest = jsonEncode({
    'mutation_id': deleteMutation,
    'entity_type': 'category',
    'entity_id': childId,
    'ledger_id': null,
    'action': 'delete',
    'updated_at': deletedAt.toIso8601String(),
    'payload': oldPayload,
  });
  await a.db
      .into(a.db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: 'category',
          entityId: childId,
          action: 'delete',
          mutationId: deleteMutation,
          accountId: d.Value(account),
          updatedAt: deletedAt,
          payload: jsonEncode(oldPayload),
          frozenRequest: d.Value(oldRequest),
        ),
      );
  final sentDeletes = <String>[];
  var loseDelete = true;
  final lostDelete = InterceptorsWrapper(
    onRequest: (options, handler) {
      if (options.path == '/api/v1/sync/push') {
        final body = observedRequestBody(options.data);
        for (final wire in (body['changes'] as List).whereType<Map>()) {
          if (wire['mutation_id'] == deleteMutation) {
            sentDeletes.add(jsonEncode(wire));
          }
        }
      }
      handler.next(options);
    },
    onResponse: (response, handler) {
      final includesDelete =
          response.requestOptions.path == '/api/v1/sync/push' &&
          (observedRequestBody(response.requestOptions.data)['changes'] as List)
              .whereType<Map>()
              .any((wire) => wire['mutation_id'] == deleteMutation);
      if (loseDelete && includesDelete) {
        loseDelete = false;
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            type: DioExceptionType.connectionError,
            error: '合成断线：分类候选持久化后丢失回执',
          ),
        );
      } else {
        handler.next(response);
      }
    },
  );
  a.client.dio.interceptors.add(lostDelete);
  try {
    await expectLater(a.push(), throwsA(isA<DioException>()));
    expect((await change(deleteMutation)).frozenRequest, oldRequest);
    await repoA.updateCategory(childId, name: '删除请求之后仍保留的编辑');
    final later =
        await (a.db.select(a.db.syncChanges)..where(
              (row) =>
                  row.entityId.equals(childId) &
                  row.pushedAt.isNull() &
                  row.mutationId.equals(deleteMutation).not(),
            ))
            .getSingle();
    await b.refreshCategoryConflicts();
    final deleteIssue = await issue(b, childId);
    expect(deleteIssue.local?['deleted'], isTrue);
    await b.resolveCategoryConflict(
      deleteIssue.id,
      keepLocal: true,
      expectedDecisionVersion: deleteIssue.decisionVersion!,
    );
    await a.push();
    expect(sentDeletes, [
      oldRequest,
      oldRequest,
    ], reason: '正式 SDK 与真实服务器重放完整原删除正文');
    expect((await change(deleteMutation)).pushedAt, isNotNull);
    expect((await change(later.mutationId)).pushedAt, isNull);
    expect((await change(later.mutationId)).payload, later.payload);
    final restore = await issue(a, childId);
    expect(restore.local?['name'], '删除请求之后仍保留的编辑');
    expect(restore.remote?['deleted_at'], isNotNull);
    await expectLater(
      a.resolveCategoryConflict(
        restore.id,
        keepLocal: true,
        expectedDecisionVersion: restore.decisionVersion!,
      ),
      throwsA(isA<CategoryDecisionException>()),
    );
    await a.resolveCategoryConflict(
      restore.id,
      keepLocal: true,
      restoreDeleted: true,
      expectedDecisionVersion: restore.decisionVersion!,
    );
  } finally {
    a.client.dio.interceptors.remove(lostDelete);
  }
  await b.pull();
  await b.refreshCategoryConflicts();
  expect(
    (await repoB.categoryStore.getCategoryById(childId))!.name,
    '删除请求之后仍保留的编辑',
  );
  expect(
    (await repoB.categoryStore.getCategoryById(childId))!.parentId,
    parentId,
  );
  expect((await repoB.getTransactionById(transactionId))!.categoryId, parentId);
  expect(
    (await readSyncIssues(
      a.db,
      account: account,
    )).where((row) => row.target.type == 'category'),
    isEmpty,
  );
  expect(
    (await readSyncIssues(
      b.db,
      account: account,
    )).where((row) => row.target.type == 'category'),
    isEmpty,
  );
  await _expectAcknowledged(a);
  await _expectAcknowledged(b);
}
