import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';

/// 已明确拒收的队列恢复只重新登记原始意图，结果未知的冻结请求保持不可变。
class SyncRejectionRecovery {
  /// 所有恢复事务共用同步会话守卫，账号变化时整次操作一起回滚。
  SyncRejectionRecovery(this.db, {required this.transaction});

  final SesameDatabase db;
  final Future<void> Function(String?, Future<void> Function()) transaction;

  /// 为一次明确拒收建立新的幂等身份，保留最新正文与最早乐观并发基线。
  Future<bool> retryRejectedChange(int id, String account) async {
    var retried = false;
    try {
      await transaction(account, () async {
        final rejected =
            await (db.select(db.syncChanges)..where(
                  (c) =>
                      c.id.equals(id) &
                      c.accountId.equals(account) &
                      c.pushedAt.isNull(),
                ))
                .getSingleOrNull();
        if (rejected == null || rejected.rejectionReason == null) return;
        if (rejected.action == 'delete' &&
            [
              'ledger',
              'day_book',
              'memo_book',
              'fitness_space',
            ].contains(rejected.entityType)) {
          throw StateError('请重新预览并确认此本的删除');
        }
        final pending =
            await (db.select(db.syncChanges)
                  ..where(
                    (c) =>
                        c.accountId.equals(account) &
                        c.entityType.equals(rejected.entityType) &
                        c.entityId.equals(rejected.entityId) &
                        c.pushedAt.isNull(),
                  )
                  ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
                .get();
        // 明确拒收可以替换幂等身份；任何后继结果未知时必须先重放确认，不能改写。
        if (pending.any(
          (c) => c.frozenRequest != null && c.rejectionReason == null,
        )) {
          return;
        }
        final latest = pending.last;
        // 队列毫秒时间已经在结构升级时规范化，重试保留最后意图的原绝对时刻。
        // 新幂等身份不能借当前墙上时间或旧正文的无时区时间改变编辑顺序。
        final timestamp = latest.updatedAt.toUtc();
        var payload = latest.payload;
        if (latest.entityType == 'transaction' && latest.action == 'upsert') {
          final original =
              jsonDecode(pending.first.payload) as Map<String, dynamic>;
          final body = jsonDecode(payload) as Map<String, dynamic>;
          // 首次迁入历史的授权属于原始意图，合并未发送的后继编辑时仍须保留。
          if (original['initial_history'] == true) {
            payload = jsonEncode({...body, 'initial_history': true});
          }
        }
        await (db.delete(
          db.syncChanges,
        )..where((c) => c.id.isIn(pending.map((c) => c.id)))).go();
        await db
            .into(db.syncChanges)
            .insert(
              SyncChangesCompanion.insert(
                entityType: latest.entityType,
                entityId: latest.entityId,
                ledgerId: d.Value(latest.ledgerId),
                dayBookId: d.Value(latest.dayBookId),
                memoBookId: d.Value(latest.memoBookId),
                fitnessSpaceId: d.Value(latest.fitnessSpaceId),
                accountId: d.Value(account),
                action: latest.action,
                payload: payload,
                updatedAt: timestamp,
                mutationId: const Uuid().v4(),
                baseRevision: d.Value(pending.first.baseRevision),
              ),
            );
        retried = true;
      });
      return retried;
    } catch (error, stack) {
      logger.error(
        'SyncRecovery',
        '重新登记拒收变更失败: queue=$id',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 权威确认分类存活后，按稳定错误码与实际引用恢复子分类及本人账本的依赖拒绝。
  Future<void> categoryAvailable(String categoryId, String account) async {
    try {
      await transaction(account, () async {
        final category =
            await (db.select(db.categories)..where(
                  (c) =>
                      c.id.equals(categoryId) &
                      c.scopeAccountId.equals(account) &
                      c.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (category == null) return;
        final categoryPending =
            await (db.select(db.syncChanges)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.entityType.equals('category') &
                      c.entityId.equals(categoryId) &
                      c.pushedAt.isNull(),
                ))
                .get();
        final conflicts =
            await (db.select(db.syncConflicts)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.entityType.equals('category') &
                      c.entityId.equals(categoryId) &
                      c.status.equals('OPEN'),
                ))
                .get();
        if (categoryPending.isNotEmpty || conflicts.isNotEmpty) return;
        final ledgers =
            await (db.select(db.ledgers)..where(
                  (l) =>
                      categoryLedgerPredicate(l, account) &
                      l.deletedAt.isNull(),
                ))
                .get();
        final rejected =
            await (db.select(db.syncChanges)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.pushedAt.isNull() &
                      ((c.ledgerId.isIn(ledgers.map((l) => l.id)) &
                              c.entityType.isIn([
                                'transaction',
                                'recurring_transaction',
                              ]) &
                              c.rejectionCode.equals('INVALID_CATEGORY')) |
                          (c.entityType.equals('category') &
                              c.rejectionCode.equals(
                                'CATEGORY_PARENT_UNAVAILABLE',
                              ))),
                ))
                .get();
        final recovered = await _recoverReferences(
          rejected,
          categoryId,
          account,
          allowChildCategories: category.level == 1,
        );
        if (recovered > 0) {
          logger.info(
            'SyncRecovery',
            '分类已确认，恢复 $recovered 条分类依赖拒绝: category=$categoryId',
          );
        }
      });
    } catch (error, stack) {
      logger.error(
        'SyncRecovery',
        '恢复分类依赖失败: category=$categoryId',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 共享分类确认仅恢复该账本的引用，私有同编号分类及其他共享账本保持独立。
  Future<void> sharedCategoryAvailable(
    String categoryId,
    String ledgerId,
    String account,
  ) async {
    try {
      await transaction(account, () async {
        final ledger =
            await (db.select(db.ledgers)..where(
                  (l) =>
                      l.id.equals(ledgerId) &
                      l.scopeAccountId.equals(account) &
                      l.storageMode.equals('cloud') &
                      l.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (ledger?.ownerAccountId == null ||
            ledger!.ownerAccountId == account) {
          return;
        }
        final mirror =
            await (db.select(db.sharedLedgerCategories)..where(
                  (c) =>
                      c.ledgerId.equals(ledgerId) &
                      c.categoryId.equals(categoryId) &
                      c.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (mirror == null) return;
        final rejected =
            await (db.select(db.syncChanges)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.ledgerId.equals(ledgerId) &
                      c.pushedAt.isNull() &
                      c.entityType.isIn([
                        'transaction',
                        'recurring_transaction',
                      ]) &
                      c.rejectionCode.equals('INVALID_CATEGORY'),
                ))
                .get();
        final recovered = await _recoverReferences(
          rejected,
          categoryId,
          account,
        );
        if (recovered > 0) {
          logger.info(
            'SyncRecovery',
            '共享分类已确认，恢复 $recovered 条引用: ledger=$ledgerId, category=$categoryId',
          );
        }
      });
    } catch (error, stack) {
      logger.error(
        'SyncRecovery',
        '恢复共享分类引用失败: ledger=$ledgerId',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 恢复明确的分类依赖拒绝共用原意图重登记规则，不触碰结果未知请求或不匹配的引用。
  Future<int> _recoverReferences(
    List<SyncChange> rejected,
    String categoryId,
    String account, {
    bool allowChildCategories = false,
  }) async {
    var recovered = 0;
    for (final change in rejected) {
      final payload = _dependencyPayload(change);
      if (payload == null) continue;
      final field = change.entityType == 'category'
          ? 'parent_id'
          : 'category_id';
      if (change.action != 'upsert' || payload[field] != categoryId) continue;
      if (change.entityType == 'category' &&
          (!allowChildCategories ||
              (payload['level'] != 2 && payload['level'] != '2'))) {
        continue;
      }
      if (await retryRejectedChange(change.id, account)) recovered++;
    }
    return recovered;
  }

  /// 损坏的拒收正文保持待处理并留痕，不影响同批合法分类与其他依赖的确认。
  Map<String, dynamic>? _dependencyPayload(SyncChange change) {
    try {
      return jsonDecode(change.payload) as Map<String, dynamic>;
    } catch (error, stack) {
      logger.error(
        'SyncRecovery',
        '读取拒收依赖失败: queue=${change.id}',
        safeErrorSummary(error),
        stack,
      );
      return null;
    }
  }
}
