import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/local/sync_issues_repository.dart';

void main() {
  late SesameDatabase db;
  setUp(() => db = SesameDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());
  test('全局常驻摘要不携带正文，可见项才读详情并复核账号和解决状态', () async {
    final body = '字' * 100000;
    await db.batch(
      (b) => b.insertAll(db.syncConflicts, [
        for (var i = 0; i < 20; i++)
          SyncConflictsCompanion.insert(
            id: 'c$i',
            accountId: d.Value('a'),
            entityType: 'memo_entry',
            entityId: 'e$i',
            memoBookId: const d.Value('book'),
            localPayload: jsonEncode({'title': '记录$i', 'body': body}),
            remotePayload: jsonEncode({'body': body}),
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'm$i',
          ),
      ]),
    );
    final items = await readSyncIssues(
      db,
      account: 'a',
      includeDetails: false,
      includeFitnessCompleteness: false,
    );
    expect(items.where((i) => i.kind == SyncIssueKind.conflict), hasLength(20));
    expect(
      items.every(
        (i) => (i.local?.isEmpty ?? true) && (i.remote?.isEmpty ?? true),
      ),
      isTrue,
    );
    final summary = items.firstWhere((i) => i.id == 'c0');
    final detail = await readSyncIssueDetails(db, summary, account: 'a');
    expect(detail.title, '记录0');
    expect(detail.local!['body'], body);
    await expectLater(
      readSyncIssueDetails(db, summary, account: 'b'),
      throwsStateError,
    );
    await (db.update(db.syncConflicts)..where((c) => c.id.equals('c0'))).write(
      SyncConflictsCompanion(
        status: const d.Value('RESOLVED_REMOTE'),
        resolvedAt: d.Value(DateTime.now()),
      ),
    );
    await expectLater(
      readSyncIssueDetails(db, summary, account: 'a'),
      throwsStateError,
    );
  });
  test('其他账号的同步问题不能绕过归属检查读取正文', () async {
    await db
        .into(db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: 'other-account',
            accountId: d.Value('b'),
            entityType: 'transaction',
            entityId: 'tx',
            ledgerId: const d.Value('other'),
            localPayload: '{"note":"private"}',
            remotePayload: '{}',
            baseRevision: 1,
            remoteRevision: 2,
            localMutationId: 'old',
          ),
        );
    const summary = SyncIssue(
      id: 'other-account',
      kind: SyncIssueKind.conflict,
      target: SyncTarget('transaction', 'tx', parentId: 'other'),
      title: '',
    );
    await expectLater(
      readSyncIssueDetails(db, summary, account: 'a'),
      throwsStateError,
    );
  });

  test('拒绝交易仅在读取可见详情时提供分类金额日期及账本摘要', () async {
    try {
      final happened = DateTime.utc(2026, 10, 11, 7, 31);
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'book',
              name: '默认账本',
              scopeAccountId: const d.Value('a'),
              storageMode: const d.Value('cloud'),
              ownerAccountId: const d.Value('a'),
              createdAt: d.Value(happened),
              updatedAt: happened,
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'subscription',
              name: '订阅服务',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('a'),
              updatedAt: happened,
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: 'tx',
              ledgerId: const d.Value('book'),
              accountId: const d.Value('a'),
              action: 'upsert',
              payload: jsonEncode({
                'category_id': 'subscription',
                'amount': '28.5',
                'currency_code': 'CNY',
                'happened_at': happened.toIso8601String(),
                'note': 'PRIVATE_RECORD_NOTE',
              }),
              updatedAt: happened,
              mutationId: 'm',
              rejectionReason: const d.Value('请检查分类'),
              rejectionCode: const d.Value('INVALID_CATEGORY'),
            ),
          );
      final summary = (await readSyncIssues(
        db,
        account: 'a',
        includeDetails: false,
      )).single;
      expect(summary.local, isNull);
      expect(summary.accountingContext, isNull);
      expect(summary.title, '默认账本');
      final details = await readSyncIssueDetails(db, summary, account: 'a');
      expect(details.accountingContext?.bookName, '默认账本');
      expect(details.accountingContext?.categoryName, '订阅服务');
      expect(details.accountingContext?.amount, '28.5');
      expect(details.accountingContext?.currencyCode, 'CNY');
      expect(details.accountingContext?.happenedAt, happened.toLocal());
      expect(details.rejectionCode, 'INVALID_CATEGORY');
      await expectLater(
        readSyncIssueDetails(db, summary, account: 'b'),
        throwsStateError,
      );
    } catch (error, stackTrace) {
      // 失败时同时保留异常与调用栈，便于区分投影实现和夹具问题。
      logger.error(
        'SyncIssueProjectionTest',
        '拒绝交易详情投影验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('共享账本拒绝交易读取所有者分类镜像而不是本人或其他账号分类', () async {
    try {
      final happened = DateTime.utc(2026, 10, 11);
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'shared',
              name: '共享账本',
              role: const d.Value('editor'),
              scopeAccountId: const d.Value('a'),
              storageMode: const d.Value('cloud'),
              ownerAccountId: const d.Value('owner'),
              createdAt: d.Value(happened),
              updatedAt: happened,
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'category',
              name: '其他账号私有名称',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('b'),
              updatedAt: happened,
            ),
          );
      await db
          .into(db.sharedLedgerCategories)
          .insert(
            SharedLedgerCategoriesCompanion.insert(
              ledgerId: 'shared',
              categoryId: 'category',
              name: '所有者订阅服务',
              kind: 'expense',
              updatedAt: happened,
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'transaction',
              entityId: 'tx',
              ledgerId: const d.Value('shared'),
              accountId: const d.Value('a'),
              action: 'upsert',
              payload: '{"category_id":"category"}',
              updatedAt: happened,
              mutationId: 'm',
              rejectionReason: const d.Value('请检查分类'),
            ),
          );
      final summary = (await readSyncIssues(
        db,
        account: 'a',
        includeDetails: false,
      )).single;
      final details = await readSyncIssueDetails(db, summary, account: 'a');
      expect(details.accountingContext?.categoryName, '所有者订阅服务');
      await db.delete(db.sharedLedgerCategories).go();
      final missing = await readSyncIssueDetails(db, summary, account: 'a');
      expect(missing.accountingContext?.categoryName, isNull);
      expect(missing.accountingContext?.categoryId, 'category');
    } catch (error, stackTrace) {
      logger.error(
        'SyncIssueProjectionTest',
        '共享账本拒绝交易摘要验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('等待中的原分类和交易保持独立事项，交易明确说明分类依赖', () async {
    try {
      final happened = DateTime.utc(2026, 10, 12, 6, 17);
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'book',
              name: '默认账本',
              scopeAccountId: const d.Value('a'),
              storageMode: const d.Value('cloud'),
              ownerAccountId: const d.Value('a'),
              updatedAt: happened,
            ),
          );
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'subscription',
              name: '订阅服务',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('a'),
              updatedAt: happened,
            ),
          );
      await db.batch(
        (batch) => batch.insertAll(db.syncChanges, [
          SyncChangesCompanion.insert(
            entityType: 'category',
            entityId: 'subscription',
            accountId: const d.Value('a'),
            action: 'upsert',
            payload: '{"name":"订阅服务"}',
            updatedAt: happened,
            mutationId: 'category-mutation',
          ),
          SyncChangesCompanion.insert(
            entityType: 'transaction',
            entityId: 'tx',
            ledgerId: const d.Value('book'),
            accountId: const d.Value('a'),
            action: 'upsert',
            payload: jsonEncode({
              'category_id': 'subscription',
              'amount': '88',
              'currency_code': 'CNY',
              'happened_at': happened.toIso8601String(),
            }),
            updatedAt: happened,
            mutationId: 'transaction-mutation',
          ),
        ]),
      );
      final summaries = await readSyncIssues(
        db,
        account: 'a',
        includeDetails: false,
        expandPendingUploads: true,
      );
      expect(summaries, hasLength(2));
      expect(
        summaries.every(
          (issue) => issue.local == null && issue.accountingContext == null,
        ),
        isTrue,
      );
      final category = await readSyncIssueDetails(
        db,
        summaries.firstWhere((issue) => issue.target.type == 'category'),
        account: 'a',
      );
      final transaction = await readSyncIssueDetails(
        db,
        summaries.firstWhere((issue) => issue.target.type == 'transaction'),
        account: 'a',
      );
      expect(category.title, '订阅服务');
      expect(category.reason, contains('尚未上传'));
      expect(transaction.accountingContext?.categoryName, '订阅服务');
      expect(transaction.accountingContext?.bookName, '默认账本');
      expect(transaction.accountingContext?.amount, '88');
      expect(transaction.reason, '等待分类“订阅服务”同步完成后上传。');
      await (db.update(db.ledgers)..where((row) => row.id.equals('book')))
          .write(const LedgersCompanion(ownerAccountId: d.Value(null)));
      final missingOwner = await readSyncIssueDetails(
        db,
        summaries.firstWhere((issue) => issue.target.type == 'transaction'),
        account: 'a',
      );
      expect(missingOwner.accountingContext?.bookName, '默认账本');
      expect(missingOwner.accountingContext?.amount, '88');
      expect(missingOwner.accountingContext?.categoryName, isNull);
      expect(missingOwner.reason, contains('尚未确认账本的分类归属'));
    } catch (error, stackTrace) {
      logger.error(
        'SyncIssueProjectionTest',
        '待上传分类和记录依赖投影失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  });
}
