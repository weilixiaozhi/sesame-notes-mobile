library;

import 'fitness_space_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import 'dart:convert';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/private_book.dart';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart'
    show categorySyncPayload;
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/recurring_initial_state.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 全应用数据删除与归属转换入口，实体差异仅交给既有仓储处理。
class DataLifecycleActions {
  final Ref ref;

  DataLifecycleActions(this.ref);

  /// 删除意图与归属操作共用全局闸门；本机事务成功后由统一 outbox 完成云端确认。
  /// 日子条目可携带确认前的 [fixedTarget]，身份与绑定在写事务内复核。
  Future<void> deleteTarget(
    SyncTarget target, {
    int? expectedCount,
    Future<Object?> Function()? validate,
    PrivateBookTarget? fixedTarget,
  }) async {
    await ref.read(syncCoordinatorProvider).runDataMutation(() async {
      await validate?.call();
      final account = ref.read(currentAccountIdProvider);
      switch (target.type) {
        case 'ledger':
          await ref.read(repositoryProvider).deleteLedger(target.id);
        case 'day_book':
          final repo = ref.read(dayRepositoryProvider);
          await repo.deleteBook(await repo.target(target.id));
        case 'memo_book':
          final repo = ref.read(memoRepositoryProvider);
          final fixed = await repo.target(target.id);
          final book = await repo.requireTarget(fixed);
          await repo.deleteBook(
            fixed,
            expectedCount: expectedCount ?? book.entryCount,
          );
        case 'fitness_space':
          final repo = ref.read(fitnessSpaceRepositoryProvider);
          final fixed = await repo.target(target.id);
          final space = await repo.requireTarget(fixed);
          await repo.deleteBook(
            fixed,
            expectedCount: expectedCount ?? space.entityCount,
          );
        case 'day_event':
          if (target.parentId == null) throw StateError('缺少记录所属本');
          final repo = ref.read(dayRepositoryProvider);
          if (fixedTarget != null) {
            if (fixedTarget.bookId != target.parentId) {
              throw StateError('DAY_TARGET_CHANGED');
            }
            await repo.deleteEventAtTarget(target.id, fixedTarget);
          } else {
            await repo.deleteEvent(
              target.id,
              target.parentId!,
              accountId: account,
            );
          }
        case 'memo_entry':
          if (target.parentId == null) throw StateError('缺少记录所属本');
          final repo = ref.read(memoRepositoryProvider);
          await repo.deleteEntry(
            target.id,
            await repo.target(target.parentId!),
          );
        case 'fitness_template':
          await (await _fitnessTarget(target)).deleteTemplate(target.id);
        case 'fitness_plan':
          await (await _fitnessTarget(target)).deletePlan(target.id);
        case 'fitness_workout':
          await (await _fitnessTarget(target)).deleteWorkout(target.id);
        default:
          throw StateError('此类型不支持整项删除');
      }
    });
  }

  Future<FitnessRepository> _fitnessTarget(SyncTarget target) async {
    final db = ref.read(databaseProvider);
    final row = await (db.select(
      db.fitnessEntities,
    )..where((e) => e.id.equals(target.id))).getSingle();
    if (target.parentId != null && target.parentId != row.fitnessSpaceId) {
      throw StateError('记录所属空间已变化');
    }
    await ref.read(fitnessSpaceRepositoryProvider).target(row.fitnessSpaceId);
    return FitnessRepository(
      db,
      spaceId: row.fitnessSpaceId,
      accountIdGetter: () => ref.read(currentAccountIdProvider),
      generationGetter: () => ref.read(authIdentityGenerationProvider),
      changeRecorder: ChangeRecorderImpl(
        db,
        accountIdGetter: () => ref.read(currentAccountIdProvider),
      ),
    );
  }

  Future<void> moveToCloud(SyncTarget target) async {
    await ref
        .read(syncCoordinatorProvider)
        .runDataMutation(() => promoteLocal(target));
  }

  /// 注册搬迁已经持有全局闸门，复用同一归属写事务而不嵌套排队。
  Future<void> promoteLocal(SyncTarget target) async {
    final account = ref.read(currentAccountIdProvider);
    if (account == null) throw StateError('请先登录');
    await ref.read(databaseProvider).transaction(() async {
      if (ref.read(currentAccountIdProvider) != account) {
        throw StateError('账号已改变');
      }
      switch (target.type) {
        case 'ledger':
          await _promoteLedger(target.id);
        case 'day_book':
          final repo = ref.read(dayRepositoryProvider);
          final book = await repo.getBook(target.id, accountId: account);
          if (book == null) throw StateError('日子本不存在');
          if (!book.isCloud) {
            await repo.moveToCloud(await repo.target(target.id));
          }
        case 'memo_book':
          final repo = ref.read(memoRepositoryProvider);
          final book = await repo.getBook(target.id, accountId: account);
          if (book == null) throw StateError('记事本不存在');
          if (!book.isCloud) {
            await repo.moveToCloud(await repo.target(target.id));
          }
        case 'fitness_space':
          final repo = ref.read(fitnessSpaceRepositoryProvider);
          await repo.moveToCloud(await repo.target(target.id));
        default:
          throw StateError('未知的数据类型');
      }
      if (ref.read(currentAccountIdProvider) != account) {
        throw StateError('账号已改变');
      }
    });
  }

  /// 移动到云端：单事务完成本人身份映射（LOCAL → REGISTERED）、分类克隆、
  /// 归属翻云与全量 backfill，随后异步触发同步。
  ///
  /// 本人成员与分类归属在同一事务内转换：
  /// - M_local = ledger.self_member_id；M_registered = UUIDv5(ledger, user + userId)；
  /// - 全部本人引用（创建/编辑/付款/分摊/编辑历史）原子重写，AA 分摊合并；
  /// - 账本实际引用的本地域分类克隆到账号 scope（含父链），其他本地账本继续引用原分类；
  /// - backfill mutation 全部归属当前账号（B 推不到 A，未登录永不推送）。
  Future<void> _promoteLedger(String ledgerId) async {
    final repo = ref.read(repositoryProvider);
    final tracker = repo.changeTracker;
    final userId = ref.read(currentAccountIdProvider);
    if (userId == null) {
      throw StateError('登录后才能将本地账本转为云端账本');
    }
    if (tracker == null) {
      throw StateError('变更登记器不可用，无法登记同步变更');
    }
    final ledger = await repo.getLedgerById(ledgerId);
    if (ledger == null) {
      throw StateError('账本不存在: $ledgerId');
    }
    if (ledger.storageMode == 'cloud') return; // 幂等快路径
    if (ledger.scopeAccountId != null && ledger.scopeAccountId != userId) {
      throw StateError('账本不属于当前账号，无法转换');
    }

    final db = repo.db;
    final now = DateTime.now().toUtc();
    final profile = ref.read(cloudProfileCacheProvider).read(userId);

    await db.transaction(() async {
      if (ref.read(currentAccountIdProvider) != userId) {
        throw StateError('账号已改变');
      }
      // 所有历史与容量校验必须先于本人重映射和存储模式切换；失败整本仍在本地。
      await prepareRecurringInitialStates(db, ledgerId);
      // ---- 1. 校验本人身份：self_member_id 必须指向 LOCAL member ----
      // 从未打开过的本子可能尚无本人指针，沿用内容编辑器的设备身份补齐。
      final localSelfId =
          ledger.selfMemberId ??
          (await repo.ensureLocalSelfMember(
            ledgerId: ledgerId,
            localSelfId: await ref.read(localSelfIdProvider.future),
            displayName: '',
          )).id;
      final localSelf =
          await (db.select(db.ledgerMembers)..where(
                (m) => m.id.equals(localSelfId) & m.ledgerId.equals(ledgerId),
              ))
              .getSingleOrNull();
      // 同时提升 localSelfId 与 localSelf：self_member_id 必须存在且指向 LOCAL member
      if (localSelf == null || localSelf.memberType != 'LOCAL') {
        throw StateError('本地账本缺少 LOCAL 本人成员，无法转换');
      }
      final mRegistered = registeredMemberId(ledgerId, userId);

      // ---- 2. 先合并 AA 分摊：同一交易同时存在两个本人行时，
      // 金额并入 M_registered 行后删除 M_local 行（总额必须保持完全相等）----
      final registeredSplits = await (db.select(
        db.transactionSplits,
      )..where((s) => s.memberId.equals(mRegistered))).get();
      for (final rs in registeredSplits) {
        final localSplits =
            await (db.select(db.transactionSplits)..where(
                  (s) =>
                      s.transactionId.equals(rs.transactionId) &
                      s.memberId.equals(localSelfId),
                ))
                .get();
        for (final ls in localSplits) {
          final merged = (Decimal.parse(rs.amount) + Decimal.parse(ls.amount))
              .toString();
          await (db.update(db.transactionSplits)
                ..where((s) => s.id.equals(rs.id)))
              .write(TransactionSplitsCompanion(amount: d.Value(merged)));
          await (db.delete(
            db.transactionSplits,
          )..where((s) => s.id.equals(ls.id))).go();
        }
      }

      // ---- 3. 创建/合并 REGISTERED 本人（origin_member_id 永久保留来源链）----
      await db
          .into(db.ledgerMembers)
          .insertOnConflictUpdate(
            LedgerMembersCompanion.insert(
              id: mRegistered,
              ledgerId: ledgerId,
              displayName: profile?.displayName ?? localSelf.displayName,
              memberType: 'REGISTERED',
              linkedAccountId: d.Value(userId),
              originMemberId: d.Value(localSelfId),
              role: d.Value(localSelf.role),
              avatarUrl: d.Value(profile?.avatarUrl),
              avatarVersion: d.Value(profile?.avatarVersion ?? 0),
              updatedAt: now,
            ),
          );

      // ---- 4. 原子重写全部本人引用（交易/分摊/编辑历史）----
      await (db.update(db.transactions)..where(
            (t) =>
                t.ledgerId.equals(ledgerId) &
                t.createdByMemberId.equals(localSelfId),
          ))
          .write(
            TransactionsCompanion(createdByMemberId: d.Value(mRegistered)),
          );
      await (db.update(db.transactions)..where(
            (t) =>
                t.ledgerId.equals(ledgerId) &
                t.lastEditedByMemberId.equals(localSelfId),
          ))
          .write(
            TransactionsCompanion(lastEditedByMemberId: d.Value(mRegistered)),
          );
      await (db.update(db.transactions)..where(
            (t) =>
                t.ledgerId.equals(ledgerId) &
                t.payerMemberId.equals(localSelfId),
          ))
          .write(TransactionsCompanion(payerMemberId: d.Value(mRegistered)));
      await (db.update(db.transactionSplits)
            ..where((s) => s.memberId.equals(localSelfId)))
          .write(TransactionSplitsCompanion(memberId: d.Value(mRegistered)));
      await (db.update(
        db.recordEditHistories,
      )..where((h) => h.operatorMemberId.equals(localSelfId))).write(
        RecordEditHistoriesCompanion(operatorMemberId: d.Value(mRegistered)),
      );

      // ---- 5. self_member_id 指向新本人 ----
      await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
        LedgersCompanion(selfMemberId: d.Value(mRegistered)),
      );

      // ---- 6. 清理已无引用的 LOCAL member ----
      final stillReferenced =
          await (db.select(db.transactions)..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    (t.createdByMemberId.equals(localSelfId) |
                        t.lastEditedByMemberId.equals(localSelfId) |
                        t.payerMemberId.equals(localSelfId)),
              ))
              .getSingleOrNull();
      final splitReferenced = await (db.select(
        db.transactionSplits,
      )..where((s) => s.memberId.equals(localSelfId))).getSingleOrNull();
      final historyReferenced =
          await (db.select(db.recordEditHistories)
                ..where((h) => h.operatorMemberId.equals(localSelfId)))
              .getSingleOrNull();
      if (stillReferenced == null &&
          splitReferenced == null &&
          historyReferenced == null) {
        await (db.delete(db.ledgerMembers)..where(
              (m) => m.id.equals(localSelfId) & m.ledgerId.equals(ledgerId),
            ))
            .go();
      }

      // ---- 7. 归属翻云 + 写入账号域 ----
      await (db.update(db.ledgers)..where((l) => l.id.equals(ledgerId))).write(
        LedgersCompanion(
          storageMode: const d.Value('cloud'),
          scopeAccountId: d.Value(userId),
          ownerAccountId: d.Value(userId),
        ),
      );

      // 本地账本明确引用的分类及祖先复制到账号目录，原本地目录继续服务其他本地账本。
      final referencedCategoryIds = <String>{};
      final txs =
          await (db.select(db.transactions)..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    (t.deletedAt.isNull() | t.recurringId.isNotNull()),
              ))
              .get();
      for (final tx in txs) {
        if (tx.categoryId != null) referencedCategoryIds.add(tx.categoryId!);
      }
      final recs = await (db.select(
        db.recurringTransactions,
      )..where((r) => r.ledgerId.equals(ledgerId))).get();
      for (final r in recs) {
        if (r.categoryId != null) referencedCategoryIds.add(r.categoryId!);
      }
      final clonedCategories = await cloneCategoryReferences(
        source: db,
        target: db,
        categoryIds: referencedCategoryIds,
        sourceAccountId: null,
        targetAccountId: userId,
      );

      // 新目录中尚未登记的分类先上云，既有已登记身份不重复创建或改变因果基线。
      if (clonedCategories.isNotEmpty) {
        final categoryRows =
            await (db.select(db.categories)
                  ..where(
                    (c) =>
                        c.id.isIn(clonedCategories.values) &
                        categoryScopePredicate(c, userId) &
                        c.cloudRegistered.equals(false),
                  )
                  ..orderBy([(c) => d.OrderingTerm.asc(c.level)]))
                .get();
        await tracker.recordUserGlobalChanges(
          changes: [
            for (final c in categoryRows)
              (
                entityType: 'category',
                entityId: c.id,
                ledgerId: null,
                action: 'upsert',
                payload: categorySyncPayload(c),
                // 复制沿用来源元数据时钟，云端原身份仍按独立版本冲突规则确认。
                updatedAt: c.updatedAt,
              ),
          ],
        );
      }
      await tracker.recordLedgerChange(
        entityType: 'ledger',
        entityId: ledgerId,
        ledgerId: ledgerId,
        action: 'upsert',
        payload: ledgerPayload(
          ledgerId,
          ledger.name,
          ledger.currency,
          ledger.monthStartDay,
          ledger.aaEnabled,
          now,
        ),
        updatedAt: now,
      );
      if (ledger.archivedAt != null) {
        await tracker.recordLedgerChange(
          entityType: 'ledger_archive',
          entityId: ledgerId,
          ledgerId: ledgerId,
          action: 'upsert',
          payload: jsonEncode({'archived': true}),
          updatedAt: now,
        );
      }
      final vus =
          await (db.select(db.ledgerMembers)..where(
                (m) =>
                    m.ledgerId.equals(ledgerId) &
                    m.memberType.equals('PLACEHOLDER') &
                    m.deletedAt.isNull(),
              ))
              .get();
      // 重读交易与周期模板，采用账号域分类和已映射成员；分摊批量预取，避免逐笔查询。
      final freshTxs =
          await (db.select(db.transactions)..where(
                (t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull(),
              ))
              .get();
      final freshRecs = await (db.select(
        db.recurringTransactions,
      )..where((r) => r.ledgerId.equals(ledgerId))).get();
      final splitRows =
          await (db.select(db.transactionSplits)..where(
                (split) => split.transactionId.isInQuery(
                  db.selectOnly(db.transactions)
                    ..addColumns([db.transactions.id])
                    ..where(
                      db.transactions.ledgerId.equals(ledgerId) &
                          db.transactions.deletedAt.isNull(),
                    ),
                ),
              ))
              .get();
      final splitsByTx = <String, List<ContractSplit>>{};
      for (final s in splitRows) {
        (splitsByTx[s.transactionId] ??= []).add((
          memberId: s.memberId,
          amount: s.amount,
        ));
      }
      // 成员引用完成重映射后冻结一次初始包，同一 outbox mutation 在失败重试中复用。
      final initialStates = await prepareRecurringInitialStates(db, ledgerId);
      await tracker.recordLedgerChanges(
        changes: [
          for (final tx in freshTxs)
            (
              entityType: 'transaction',
              entityId: tx.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: jsonEncode({
                ...jsonDecode(
                      transactionPayload(
                        tx,
                        splitsByTx[tx.id] ?? const [],
                        payerMemberId: tx.payerMemberId,
                      ),
                    )
                    as Map<String, dynamic>,
                // 仅首次转云登记历史导入意图；后继人工编辑不携带此标记。
                // 周期发生由所属规则的 initial_state 原子迁入。
                if (tx.recurringId == null) 'initial_history': true,
              }),
              updatedAt: now,
            ),
          for (final vu in vus)
            (
              entityType: 'member',
              entityId: vu.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: jsonEncode({
                ...jsonDecode(placeholderPayload(vu)) as Map<String, dynamic>,
                // 历史离开/移除身份保持停用，不能重新进入 AA 活跃成员池。
                'initial_status': vu.status,
              }),
              updatedAt: now,
            ),
          for (final r in freshRecs)
            (
              entityType: 'recurring_transaction',
              entityId: r.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: jsonEncode({
                ...jsonDecode(recurringTransactionPayload(r))
                    as Map<String, dynamic>,
                'initial_state': initialStates[r.id]!,
              }),
              updatedAt: now,
            ),
        ],
      );
      if (ref.read(currentAccountIdProvider) != userId) {
        throw StateError('账号已改变');
      }
    });
  }

  /// 复制到本地：云端原件保留，返回新发布的本地副本 id。
  Future<String> copyToLocal(SyncTarget target) =>
      ref.read(syncCoordinatorProvider).transferToLocal(target, move: false);

  /// 移动到本地：返回新发布的本地副本 id，供调用方切换当前选择。
  Future<String> moveToLocal(SyncTarget target) =>
      ref.read(syncCoordinatorProvider).transferToLocal(target, move: true);
}

/// 账本归属移动编排 provider（全局唯一，随 app 生命周期）。
final dataLifecycleProvider = Provider<DataLifecycleActions>(
  (ref) => DataLifecycleActions(ref),
);
