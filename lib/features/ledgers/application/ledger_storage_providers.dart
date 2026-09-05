/// 账本归属移动编排（P0-2 移动到云端 / P0-3 移动到本地）。
///
/// 设计意图：
/// - moveToCloud：本地账本翻 storage_mode='cloud' 并 backfill 该账本全部实体
///   （账本/交易/虚拟用户/周期交易）的 upsert 变更——本地历史数据从未登记过
///   变更，不补登记云端将只有空账本；登记后由同步编排异步推送。
///   编辑历史为本地审计链，不随 backfill 上云（云端从迁云时刻起重新积累）。
/// - moveToLocal：先登记账本 delete（tombstone 删云端）并**等待推送成功**
///   （fail-closed：删云端失败则本地保持云端态），成功后本地断联
///   （置 local + 清除该账本全部待推送变更）；推送失败立即移除 delete 变更，
///   防止下次 push 误删云端。
library;

import 'dart:async';
import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

const _uuid = Uuid();

/// 账本归属移动编排实例。
class LedgerStorageActions {
  final Ref ref;

  LedgerStorageActions(this.ref);

  /// 移动到云端：单事务完成本人身份映射（LOCAL → REGISTERED）、分类克隆、
  /// 归属翻云与全量 backfill，随后异步触发同步。
  ///
  /// 设计意图（I-03 唯一允许的 member 重映射场景）：
  /// - M_local = ledger.self_member_id；M_registered = UUIDv5(ledger, user + userId)；
  /// - 全部本人引用（创建/编辑/付款/分摊/编辑历史）原子重写，AA 分摊合并；
  /// - 账本实际引用的本地域分类克隆到账号 scope（含父链），其他本地账本继续引用原分类；
  /// - backfill mutation 全部归属当前账号（B 推不到 A，未登录永不推送）。
  Future<void> moveToCloud(String ledgerId) async {
    final repo = ref.read(repositoryProvider);
    final tracker = repo.changeTracker;
    final session = ref.read(authSessionProvider);
    if (session == null) {
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
    if (ledger.scopeAccountId != null &&
        ledger.scopeAccountId != session.userId) {
      throw StateError('账本不属于当前账号，无法转换');
    }

    final db = repo.db;
    final now = DateTime.now().toUtc();
    final userId = session.userId;
    final profile = ref.read(cloudProfileCacheProvider).read(userId);

    await db.transaction(() async {
      // ---- 1. 校验本人身份：self_member_id 必须指向 LOCAL member ----
      final localSelfId = ledger.selfMemberId;
      final localSelf = localSelfId == null
          ? null
          : await (db.select(db.ledgerMembers)..where(
                  (m) => m.id.equals(localSelfId) & m.ledgerId.equals(ledgerId),
                ))
                .getSingleOrNull();
      // 同时提升 localSelfId 与 localSelf：self_member_id 必须存在且指向 LOCAL member
      if (localSelfId == null ||
          localSelf == null ||
          localSelf.memberType != 'LOCAL') {
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
        ),
      );

      // ---- 8. 被引用分类的归属随账本翻云：同一行 scope 直接置为账号域
      // （id 不变，全库恒一行，云端按 id 幂等收敛）。交易/周期模板引用
      // 无需重写；登出 purge 会把仍被本地账本引用的行迁回本地域 ----
      final referencedCategoryIds = <String>{};
      final txs =
          await (db.select(db.transactions)..where(
                (t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull(),
              ))
              .get();
      for (final tx in txs) {
        if (tx.categoryId != null) referencedCategoryIds.add(tx.categoryId!);
      }
      final recs =
          await (db.select(db.recurringTransactions)..where(
                (r) => r.ledgerId.equals(ledgerId) & r.deletedAt.isNull(),
              ))
              .get();
      for (final r in recs) {
        if (r.categoryId != null) referencedCategoryIds.add(r.categoryId!);
      }
      final rescopedCategoryIds = <String>{};
      for (final cid in referencedCategoryIds) {
        await _rescaleCategoryToAccountScope(
          db: db,
          categoryId: cid,
          accountId: userId,
          touched: rescopedCategoryIds,
        );
      }

      // ---- 9. backfill：迁域分类先登记（服务端按序应用，交易分类必须已存在），
      // 随后账本/交易/虚拟用户/周期模板全部 upsert。----
      if (rescopedCategoryIds.isNotEmpty) {
        final categoryRows = await (db.select(
          db.categories,
        )..where((c) => c.id.isIn(rescopedCategoryIds))).get();
        await tracker.recordUserGlobalChanges(
          changes: [
            for (final c in categoryRows)
              (
                entityType: 'category',
                entityId: c.id,
                ledgerId: null,
                action: 'upsert',
                payload: jsonEncode({
                  'name': c.name,
                  'kind': c.kind,
                  'level': c.level,
                  'sort_order': c.sortOrder,
                  'icon': c.icon,
                  'parent_id': c.parentId,
                }),
                updatedAt: now,
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
          'cloud',
          now,
        ),
        updatedAt: now,
      );
      final vus =
          await (db.select(db.ledgerMembers)..where(
                (m) =>
                    m.ledgerId.equals(ledgerId) &
                    m.memberType.equals('PLACEHOLDER') &
                    m.deletedAt.isNull(),
              ))
              .get();
      // 重读交易/周期模板（携带步骤 8 重写后的账号域分类 id 与步骤 4 的
      // 成员重映射结果），splits 一次性批量预取避免逐交易 N+1 查询
      final freshTxs =
          await (db.select(db.transactions)..where(
                (t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull(),
              ))
              .get();
      final freshRecs =
          await (db.select(db.recurringTransactions)..where(
                (r) => r.ledgerId.equals(ledgerId) & r.deletedAt.isNull(),
              ))
              .get();
      final txIds = [for (final t in freshTxs) t.id];
      final splitRows = txIds.isEmpty
          ? <TransactionSplit>[]
          : await (db.select(
              db.transactionSplits,
            )..where((s) => s.transactionId.isIn(txIds))).get();
      final splitsByTx = <String, List<ContractSplit>>{};
      for (final s in splitRows) {
        (splitsByTx[s.transactionId] ??= []).add((
          memberId: s.memberId,
          amount: s.amount,
        ));
      }
      await tracker.recordLedgerChanges(
        changes: [
          for (final tx in freshTxs)
            (
              entityType: 'transaction',
              entityId: tx.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: transactionPayload(
                tx,
                splitsByTx[tx.id] ?? const [],
                payerMemberId: tx.payerMemberId,
              ),
              updatedAt: now,
            ),
          for (final vu in vus)
            (
              entityType: 'member',
              entityId: vu.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: placeholderPayload(vu),
              updatedAt: now,
            ),
          for (final r in freshRecs)
            (
              entityType: 'recurring_transaction',
              entityId: r.id,
              ledgerId: ledgerId,
              action: 'upsert',
              payload: recurringTransactionPayload(r),
              updatedAt: now,
            ),
        ],
      );
    });

    // 后台推送：翻归属即视为用户意图上云，推送失败由同步层日志兜底，
    // 下次同步自动重试（change 已落库）。
    unawaited(
      ref.read(syncCoordinatorProvider).run().then((result) {
        if (result.error != null) {
          logger.warning('LedgerStorage', '上云推送失败(下次同步重试): $result.error');
        }
      }),
    );
  }

  /// 复制到本地：云端账本留一份本地副本（云端原件保留），返回新账本 id。
  ///
  /// 设计意图：共享账本无法移动归属（那是别人的云端资源），想在本地留档
  /// 只能走复制路径；副本为纯本地归属（storage_mode='local'），数据经
  /// copyLedgerData 搬运（虚拟用户映射重写 + 交易/分摊/编辑历史复制）。
  Future<String> copyToLocal(String ledgerId) async {
    final repo = ref.read(repositoryProvider);
    final ledger = await repo.getLedgerById(ledgerId);
    if (ledger == null) {
      throw StateError('账本不存在: $ledgerId');
    }
    if (ledger.storageMode != 'cloud') {
      throw StateError('只有云端账本可以复制到本地');
    }
    final newId = await repo.createLedger(
      name: ledger.name,
      currency: ledger.currency,
      storageMode: 'local',
      aaEnabled: ledger.aaEnabled,
      monthStartDay: ledger.monthStartDay,
    );
    await repo.copyLedgerData(sourceLedgerId: ledgerId, targetLedgerId: newId);
    return newId;
  }

  /// 移动到本地：先建隐藏 Fork（新 ledger id + pending_local_move），
  /// 确认源云端账本已删除后发布本地副本并清除旧云缓存。
  ///
  /// 设计意图（13.3）：
  /// - 隐藏 Fork 的 origin_ledger_id + binding_status 就是持久化 intent，
  ///   崩溃后启动恢复可安全完成发布，不会丢账；
  /// - 只把 delete outcome 的「accepted」视为成功；ignored 需权威查询证明
  ///   源已 tombstone；invalid/conflict 一律不继续（保留隐藏 Fork 供重试）。
  Future<void> moveToLocal(String ledgerId) async {
    final repo = ref.read(repositoryProvider);
    final tracker = repo.changeTracker;
    final session = ref.read(authSessionProvider);
    if (session == null) {
      throw StateError('登录后才能将云端账本转为本地账本');
    }
    if (tracker == null) {
      throw StateError('变更登记器不可用，无法登记同步变更');
    }
    final ledger = await repo.getLedgerById(ledgerId);
    if (ledger == null) {
      throw StateError('账本不存在: $ledgerId');
    }
    if (ledger.storageMode == 'local') return; // 幂等快路径
    if (ledger.scopeAccountId != session.userId) {
      throw StateError('账本不属于当前账号，无法移动');
    }

    final db = repo.db;
    final localSelfId = await ref.read(localSelfIdProvider.future);

    // ---- 1. 隐藏 Fork：新 ledger id，成员本地化，binding=pending_local_move ----
    final forkId = _uuid.v4();
    await repo.forkCloudLedgerToLocalPendingMove(
      sourceLedgerId: ledgerId,
      newLedgerId: forkId,
      localSelfId: localSelfId,
      currentAccountId: session.userId,
      originSyncId: ledger.syncId,
    );

    // ---- 2. 登记并推送源账本 delete（tombstone 删云端）----
    final now = DateTime.now().toUtc();
    await tracker.recordLedgerChange(
      entityType: 'ledger',
      entityId: ledgerId,
      ledgerId: ledgerId,
      action: 'delete',
      payload: jsonEncode({'id': ledgerId}),
      updatedAt: now,
    );
    try {
      final outcome = await ref
          .read(syncServiceProvider)
          .pushLedgerDelete(ledgerId: ledgerId);
      if (outcome == null) {
        throw StateError('账本 delete 变更未登记，无法确认云端删除');
      }
      if (outcome == 'invalid' || outcome == 'conflict') {
        // invalid/conflict 一律不继续：隐藏 Fork 保留，用户可重试或取消
        throw StateError('云端删除被拒绝，移动未完成（本地副本已保护）');
      }
      if (outcome == 'ignored') {
        // ignored：必须由服务端权威查询证明源账本已 tombstone/不可访问
        final remote = await ref
            .read(syncServiceProvider)
            .fetchLedgerRemoteStatus(ledgerId);
        if (!remote.deleted) {
          throw StateError('云端账本仍存活，移动未完成（本地副本已保护）');
        }
      }
    } catch (error, stackTrace) {
      // fail-closed：删除未确认，隐藏 Fork 保持 pending_local_move（持久 intent，
      // 启动恢复可重试/取消）；移除 delete 变更防止下次 push 误删云端
      logger.error(
        'LedgerStorage',
        'moveToLocal 云端删除未确认, 隐藏 Fork 已保护',
        error,
        stackTrace,
      );
      await (db.delete(db.syncChanges)..where(
            (c) => c.ledgerId.equals(ledgerId) & c.action.equals('delete'),
          ))
          .go();
      rethrow;
    }

    // ---- 3. 单事务发布：清除旧云缓存（级联子表）→ fork 置为正常本地账本 ----
    await db.transaction(() async {
      await (db.delete(db.ledgers)..where((l) => l.id.equals(ledgerId))).go();
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(ledgerId))).go();
      await (db.update(db.ledgers)..where((l) => l.id.equals(forkId))).write(
        LedgersCompanion(bindingStatus: const d.Value(null)),
      );
    });
  }
}

/// 账本归属移动编排 provider（全局唯一，随 app 生命周期）。
final ledgerStorageActionsProvider = Provider<LedgerStorageActions>(
  (ref) => LedgerStorageActions(ref),
);

/// 把 [categoryId] 及其父分类链的归属置为账号 scope（id 不变，全库恒一行）：
/// 已属本账号域的分类跳过；重复引用幂等。迁移行记录在 [touched] 供 backfill 登记。
Future<void> _rescaleCategoryToAccountScope({
  required SesameDatabase db,
  required String categoryId,
  required String accountId,
  required Set<String> touched,
}) async {
  if (touched.contains(categoryId)) return;
  final category =
      await (db.select(db.categories)
            ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
          .getSingleOrNull();
  if (category == null) return;
  // 父链优先迁移：子分类的 parent_id 在账号域同样有效
  if (category.parentId != null) {
    await _rescaleCategoryToAccountScope(
      db: db,
      categoryId: category.parentId!,
      accountId: accountId,
      touched: touched,
    );
  }
  if (category.scopeAccountId == accountId) return;
  await (db.update(db.categories)..where((c) => c.id.equals(category.id)))
      .write(CategoriesCompanion(scopeAccountId: d.Value(accountId)));
  touched.add(category.id);
}
