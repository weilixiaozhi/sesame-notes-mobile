import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'dart:convert';
import 'sync_edit_clock.dart';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/category_clone.dart';
import 'package:sesame_notes/data/models/expense_type.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'local_transaction_repository.dart';
import 'package:sesame_notes/utils/member_id.dart';

const _uuid = Uuid();

/// 本地账本 Repository 实现（UUID 主键，契约对齐）。
class LocalLedgerRepository {
  final SesameDatabase db;

  /// 写事务中获取变更登记器，避免构造顺序形成循环依赖。
  final ChangeRecorder? Function()? trackerGetter;

  /// 当前云账号，用于让客户端发起的云账本写入立即进入正确账号域。
  final String? Function()? accountIdGetter;

  LocalLedgerRepository(this.db, {this.trackerGetter, this.accountIdGetter});

  /// 隐藏云转本地移动中的隐藏 Fork（binding_status=pending_local_move），
  /// 恢复完成前不展示重复账本；正常列表只含已发布账本。
  Stream<List<Ledger>> watchLedgers() {
    return (db.select(db.ledgers)
          ..where(
            (l) =>
                l.bindingStatus.isNotValue('pending_local_move') &
                l.deletedAt.isNull(),
          )
          ..orderBy([(l) => d.OrderingTerm.asc(l.storageMode)]))
        .watch();
  }

  Future<List<Ledger>> getAllLedgers() async {
    return (db.select(db.ledgers)
          ..where(
            (l) =>
                l.bindingStatus.isNotValue('pending_local_move') &
                l.deletedAt.isNull(),
          )
          ..orderBy([(l) => d.OrderingTerm.asc(l.storageMode)]))
        .get();
  }

  /// 读取待发布的隐藏 Fork（云转本地 intent 恢复扫描用）。
  Future<List<Ledger>> getPendingLocalMoveForks() async {
    return (db.select(db.ledgers)..where(
          (l) =>
              l.bindingStatus.equals('pending_local_move') &
              l.deletedAt.isNull(),
        ))
        .get();
  }

  Future<Ledger?> getLedgerById(String id) async {
    final query = db.select(db.ledgers)
      ..where((l) => l.id.equals(id) & l.deletedAt.isNull());
    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }

  /// 归档或恢复本人的账本入口，并在同一事务内登记独立的云端变更。
  Future<void> setLedgerArchived(
    String id,
    bool archived, {
    String? deviceId,
  }) => db.transaction(() async {
    final ledger = await getLedgerById(id);
    if (ledger == null) throw StateError('账本已不存在，请刷新后重试');
    if ((ledger.archivedAt != null) == archived) return;
    final now = DateTime.now().toUtc();
    await (db.update(db.ledgers)..where((row) => row.id.equals(id))).write(
      LedgersCompanion(
        archivedAt: d.Value(archived ? now : null),
        archiveUpdatedAt: d.Value(now),
        archiveDeviceId: d.Value(deviceId),
      ),
    );
    // 个人入口状态独立登记，不触碰共享账本元信息及既有同步队列。
    if (ledger.storageMode == 'cloud') {
      await trackerGetter?.call()?.recordLedgerChange(
        entityType: 'ledger_archive',
        entityId: id,
        ledgerId: id,
        action: 'upsert',
        payload: jsonEncode({'archived': archived}),
        updatedAt: now,
      );
    }
  });

  Future<({int dayCount, int txCount})> getCountsForLedger({
    required String ledgerId,
  }) async {
    if (await getLedgerById(ledgerId) == null) {
      return (dayCount: 0, txCount: 0);
    }
    final txRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM transactions '
          'WHERE ledger_id = ?1 AND deleted_at IS NULL',
          variables: [d.Variable.withString(ledgerId)],
          readsFrom: {db.transactions},
        )
        .getSingle();
    // 计算记账天数：今天 - 第一笔记账日期 + 1
    final dayRow = await db
        .customSelect(
          """
      SELECT CASE
        WHEN MIN(happened_at) IS NULL THEN 0
        ELSE CAST(julianday('now', 'localtime', 'start of day') - julianday(MIN(happened_at), 'unixepoch', 'localtime', 'start of day') + 1 AS INTEGER)
      END AS c
      FROM transactions
      WHERE ledger_id = ?1 AND deleted_at IS NULL
      """,
          variables: [d.Variable.withString(ledgerId)],
          readsFrom: {db.transactions},
        )
        .getSingle();

    int parse(dynamic v) {
      if (v is int) return v;
      if (v is BigInt) return v.toInt();
      if (v is num) return v.toInt();
      return 0;
    }

    return (dayCount: parse(dayRow.data['c']), txCount: parse(txRow.data['c']));
  }

  /// 账本支出总额：金额为规范化 decimal 字符串，累加用 Decimal 保持精度，
  /// 返回 double 仅为兼容既有 UI 展示接口。
  Future<({double expenseTotal, int transactionCount})> getLedgerStats({
    required String ledgerId,
    List<TransactionSnapshot>? transactions,
  }) async {
    if (await getLedgerById(ledgerId) == null) {
      return (expenseTotal: 0.0, transactionCount: 0);
    }
    final rows =
        transactions
            ?.where((transaction) => transaction.deletedAt == null)
            .toList() ??
        await (db.select(db.transactions)..where(
              (transaction) =>
                  transaction.ledgerId.equals(ledgerId) &
                  transaction.deletedAt.isNull(),
            ))
            .get();

    final transactionCount = rows.length;
    var total = Decimal.zero;
    for (final t in rows) {
      // 折算快照优先，缺失才回退原币金额（契约：本位币交易二者相等）。
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) total += v;
    }
    return (expenseTotal: total.toDouble(), transactionCount: transactionCount);
  }

  /// 全部账本支出总额使用 Decimal 聚合，避免 SQL 浮点转换损失精度。
  Future<Map<String, ({double expenseTotal, int transactionCount})>>
  getAllLedgerStats() async {
    final activeLedgerIds = (await getAllLedgers()).map((ledger) => ledger.id);
    if (activeLedgerIds.isEmpty) return const {};
    final rows =
        await (db.select(db.transactions)..where(
              (transaction) =>
                  transaction.ledgerId.isIn(activeLedgerIds) &
                  transaction.deletedAt.isNull(),
            ))
            .get();
    final totals = <String, Decimal>{};
    final counts = <String, int>{};
    for (final t in rows) {
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v != null) {
        totals[t.ledgerId] = (totals[t.ledgerId] ?? Decimal.zero) + v;
      }
      counts[t.ledgerId] = (counts[t.ledgerId] ?? 0) + 1;
    }
    return {
      for (final id in totals.keys)
        id: (
          expenseTotal: totals[id]!.toDouble(),
          transactionCount: counts[id] ?? 0,
        ),
    };
  }

  /// 离线创建账本：客户端立即生成 UUID 主键，本地与云端始终同一 id。
  ///
  /// [localSelfId] 提供时（本地账本）在同一事务内创建 LOCAL self 成员并
  /// 回写 ledgers.self_member_id——账本从诞生起就拥有稳定的「我」，
  /// 登录/退出只改绑定关系，不改身份。
  Future<String> createLedger({
    required String name,
    String currency = 'CNY',
    // 默认 'cloud' 以兼容现有调用方；未登录用户由 UI 显式传 'local'。
    String storageMode = 'cloud',
    // AA 分摊开关:默认 false(新账本关闭)。
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
  }) async {
    name = normalizeName(name);
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final capturedAccount = storageMode == 'cloud'
        ? accountIdGetter?.call()
        : null;
    // insert 与变更登记放同一事务:避免"账本落库成功但变更登记失败"留下
    // 一本云端永远推不出去的新账本。
    return db.transaction(() async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: id,
              name: name,
              currency: d.Value(currency),
              monthStartDay: d.Value(monthStartDay.clamp(1, 31)),
              aaEnabled: d.Value(aaEnabled),
              storageMode: d.Value(storageMode),
              scopeAccountId: d.Value(capturedAccount),
              ownerAccountId: d.Value(capturedAccount),
              updatedAt: now,
            ),
          );
      // 本地账本从诞生起创建「我」成员（LOCAL），并回写 self_member_id。
      if (storageMode == 'local' &&
          localSelfId != null &&
          localSelfId.isNotEmpty) {
        final selfMemberId = localSelfMemberId(id, localSelfId);
        await db
            .into(db.ledgerMembers)
            .insert(
              LedgerMembersCompanion.insert(
                id: selfMemberId,
                ledgerId: id,
                displayName: '',
                memberType: 'LOCAL',
                role: const d.Value('owner'),
                updatedAt: now,
              ),
            );
        await (db.update(db.ledgers)..where((l) => l.id.equals(id))).write(
          LedgersCompanion(selfMemberId: d.Value(selfMemberId)),
        );
      }
      // 仅云端账本登记 ledger upsert 变更；local 账本不进同步通道。
      final tracker = trackerGetter?.call();
      if (tracker != null && storageMode == 'cloud') {
        await tracker.recordLedgerChange(
          entityType: 'ledger',
          entityId: id,
          ledgerId: id,
          action: 'upsert',
          payload: ledgerPayload(
            id,
            name,
            currency,
            monthStartDay,
            aaEnabled,
            now,
          ),
          updatedAt: now,
        );
      }
      return id;
    });
  }

  /// 更新账本的云同步时间线身份（绑定建立/确认路径：push outcome、full 快照）。
  Future<void> updateLedgerSyncId({
    required String id,
    required String syncId,
  }) async {
    // 同一身份的重复确认保留投影位置；切换时间线时原子清除旧游标。
    await (db.update(
      db.ledgers,
    )..where((tbl) => tbl.id.equals(id) & tbl.syncId.isNotValue(syncId))).write(
      LedgersCompanion(
        syncId: d.Value(syncId),
        archiveServerCursor: const d.Value(null),
      ),
    );
  }

  Future<void> updateLedgerStorageMode({
    required String id,
    required String storageMode,
  }) async {
    await (db.update(db.ledgers)..where((tbl) => tbl.id.equals(id))).write(
      LedgersCompanion(storageMode: d.Value(storageMode)),
    );
  }

  /// 转为本地账本时，在同一事务清除云绑定、归档投影游标及待上传队列。
  Future<void> detachFromCloud(String id) async {
    // 「转本地」断联:翻归属标记 + 清除同步身份 + 清除该账本遗留的待推送变更,
    // 同一事务保证原子。同步身份必须清空——Detach 后本地副本不持有任何
    // 云同步时间线身份（不生成伪本地 sync_id）。
    await db.transaction(() async {
      final source = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(id))).getSingle();
      final transactions = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(id))).get();
      final rules = await (db.select(
        db.recurringTransactions,
      )..where((r) => r.ledgerId.equals(id))).get();
      final references = {
        for (final t in transactions)
          if (t.categoryId != null) t.categoryId!,
        for (final r in rules)
          if (r.categoryId != null) r.categoryId!,
      };
      if (references.isNotEmpty && source.ownerAccountId == null) {
        throw StateError('账本分类归属尚未确认，请先同步账本');
      }
      await cloneCategoryReferences(
        source: db,
        target: db,
        categoryIds: references,
        sourceAccountId: source.ownerAccountId,
        targetAccountId: null,
        sharedLedgerId: source.ownerAccountId != source.scopeAccountId
            ? id
            : null,
      );
      await updateLedgerStorageMode(id: id, storageMode: 'local');
      await (db.update(db.ledgers)..where((tbl) => tbl.id.equals(id))).write(
        const LedgersCompanion(
          scopeAccountId: d.Value(null),
          ownerAccountId: d.Value(null),
          syncId: d.Value(null),
          archiveServerCursor: d.Value(null),
        ),
      );
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(id))).go();
    });
  }

  /// Cloud→Local Fork：新 ledger_id + sync_id=NULL +
  /// binding=NULL + storageMode=local + origin 七字段溯源。
  ///
  /// 设计意图：云端账本的活跃绑定关系绝不随备份恢复——Fork 产出的是一本
  /// 与云端时间线无关的独立本地账本（sync_id 恒 NULL）；成员重映射/
  /// 交易复制/AA 复制/编辑历史沿用共享规则；pending 队列/冲突/server_revision
  /// 一律不复制。origin_* 仅作 provenance。
  Future<String> forkCloudLedgerToLocal({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String originBackupId,
    String? originAccountId,
    String? originSyncId,
    int? originLastRevision,
    SesameDatabase? sourceDb,
    String? currentAccountId,
  }) {
    return _copyLedgerWithOrigin(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: newLedgerId,
      originType: 'CLOUD_BACKUP',
      localSelfId: localSelfId,
      originBackupId: originBackupId,
      originAccountId: originAccountId,
      originSyncId: originSyncId,
      originLastRevision: originLastRevision,
      sourceDb: sourceDb,
      currentAccountId: currentAccountId,
    );
  }

  /// 本地状态保护 Fork：DR 后服务端轮换 sync identity 使本地绑定
  /// 失效（412）时，先把云端账本的本地数据复制为 LOCAL 保护副本
  /// （origin_type=DR_PROTECT），再允许用户手动放弃本地修改/重绑——
  /// 绝不默认丢弃任何本地数据（Local Safety Fork）。
  ///
  /// [targetLedgerId] 由调用方提供（批量 Safety Fork 时按
  /// (operation_id, source_id) 确定性生成，重试不产生重复副本）；
  /// 调用方可在自己的外层事务内调用本原语（内层事务退化为 savepoint），
  /// 批量失败整批回滚。幂等由调用方按"同源已有 DR_PROTECT 副本"判断。
  Future<String> protectCloudLedgerToLocalFork({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    String? currentAccountId,
  }) {
    return _copyLedgerWithOrigin(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: targetLedgerId,
      originType: 'DR_PROTECT',
      localSelfId: localSelfId,
      originBackupId: 'dr-protect',
      originSyncId: null,
      currentAccountId: currentAccountId,
    );
  }

  /// 云本复制与移动复用完整成员本地化规则，同时保留周期模板和编辑历史。
  Future<String> copyCloudLedgerToLocal({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String currentAccountId,
    String? originSyncId,
  }) => _copyLedgerWithOrigin(
    sourceLedgerId: sourceLedgerId,
    targetLedgerId: newLedgerId,
    originType: 'CLOUD_COPY',
    localSelfId: localSelfId,
    originBackupId: 'cloud-copy',
    originAccountId: currentAccountId,
    originSyncId: originSyncId,
    currentAccountId: currentAccountId,
    localizeSelf: true,
  );

  /// 云转本地移动的隐藏 Fork：新 ledger id + storage_mode=local +
  /// binding_status=pending_local_move + origin 溯源。目标行的
  /// origin_ledger_id + binding_status 就是持久化 intent，无需另建操作表。
  ///
  /// 成员本地化：当前账号的 REGISTERED self 映射为目标 LOCAL self，
  /// 其他 REGISTERED 与 PLACEHOLDER 分别映射为新 PLACEHOLDER（不能合并）；
  /// 源账本确认删除后由调用方把 binding_status 置空并清除旧云缓存。
  Future<String> forkCloudLedgerToLocalPendingMove({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String currentAccountId,
    String? originSyncId,
    bool overwrite = false,
  }) {
    return _copyLedgerWithOrigin(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: newLedgerId,
      originType: 'CLOUD_MOVE',
      localSelfId: localSelfId,
      originBackupId: 'pending-local-move',
      originSyncId: originSyncId,
      currentAccountId: currentAccountId,
      targetBindingStatus: 'pending_local_move',
      originAccountId: currentAccountId,
      overwrite: overwrite,
      localizeSelf: true,
    );
  }

  /// 本地账本恢复：[targetLedgerId] 由调用方按 ID 冲突策略决定
  /// （目标库无该 ID → 原 identity；有该 ID 的本地账本 → 覆盖；有该 ID 的
  /// 云端账本 → 新 ID Fork）。[overwrite] 为 true 时先物理删除目标账本现有
  /// 数据再以备份快照重建（调用方保证目标行是本地账本）。origin_type 记
  /// LOCAL_BACKUP。
  Future<String> restoreLocalLedger({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    required String originBackupId,
    SesameDatabase? sourceDb,
    String? currentAccountId,
    bool overwrite = false,
  }) {
    return _copyLedgerWithOrigin(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: targetLedgerId,
      originType: 'LOCAL_BACKUP',
      localSelfId: localSelfId,
      originBackupId: originBackupId,
      sourceDb: sourceDb,
      currentAccountId: currentAccountId,
      overwrite: overwrite,
    );
  }

  /// Fork/恢复共用的账本复制原语：单事务内建目标账本行（origin 溯源）→
  /// 按"我是谁"规则确定 self 成员 → 复制成员/交易/AA/编辑历史。
  ///
  /// [targetBindingStatus]：云转本地隐藏 Fork 时为 pending_local_move，
  /// 其余路径保持 null（正常本地账本）。
  /// [localizeSelf]：隐藏 Fork 时把当前账号的 REGISTERED self 映射为
  /// 目标 LOCAL self，其余 REGISTERED/PLACEHOLDER 分别映射为 PLACEHOLDER。
  /// [overwrite]：覆盖恢复——先删除目标账本现有数据再按备份快照重建。
  Future<String> _copyLedgerWithOrigin({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String originType,
    required String localSelfId,
    required String originBackupId,
    String? originAccountId,
    String? originSyncId,
    int? originLastRevision,
    SesameDatabase? sourceDb,
    String? currentAccountId,
    String? targetBindingStatus,
    bool localizeSelf = false,
    bool overwrite = false,
  }) async {
    // [sourceDb]：恢复场景的只读备份源；缺省为当前库（同库搬运）。
    final src = sourceDb ?? db;
    return db.transaction(() async {
      final srcLedger = await (src.select(
        src.ledgers,
      )..where((l) => l.id.equals(sourceLedgerId))).getSingleOrNull();
      if (srcLedger == null) throw StateError('源账本不存在: $sourceLedgerId');
      if (overwrite) {
        // 覆盖：先物理删除目标账本现有数据，再以备份快照重建。账本行
        // 级联清除成员/交易/分摊/编辑历史/周期模板；同步队列、冲突、
        // 拉取错误与共享分类镜像无外键，显式清理避免旧同步身份残留。
        await (db.delete(
          db.syncChanges,
        )..where((c) => c.ledgerId.equals(targetLedgerId))).go();
        await (db.delete(
          db.syncConflicts,
        )..where((c) => c.ledgerId.equals(targetLedgerId))).go();
        await (db.delete(
          db.syncPullErrors,
        )..where((c) => c.ledgerId.equals(targetLedgerId))).go();
        await (db.delete(
          db.sharedLedgerCategories,
        )..where((c) => c.ledgerId.equals(targetLedgerId))).go();
        await (db.delete(
          db.ledgers,
        )..where((l) => l.id.equals(targetLedgerId))).go();
      }
      final now = DateTime.now().toUtc();
      final srcMembers =
          await (src.select(src.ledgerMembers)..where(
                (member) =>
                    member.ledgerId.equals(sourceLedgerId) &
                    member.deletedAt.isNull(),
              ))
              .get();

      // 目标账本行：storageMode=local、同步身份/绑定全空，
      // origin 七字段写入溯源。
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: targetLedgerId,
              name: srcLedger.name,
              currency: d.Value(srcLedger.currency),
              monthStartDay: d.Value(srcLedger.monthStartDay),
              aaEnabled: d.Value(srcLedger.aaEnabled),
              // 复制与恢复延续个人归档状态及其同步版本。
              archivedAt: d.Value(srcLedger.archivedAt),
              archiveUpdatedAt: d.Value(srcLedger.archiveUpdatedAt),
              archiveDeviceId: d.Value(srcLedger.archiveDeviceId),
              storageMode: const d.Value('local'),
              syncId: const d.Value(null),
              bindingStatus: d.Value(targetBindingStatus),
              createdAt: d.Value(now),
              updatedAt: now,
              originType: d.Value(originType),
              originLedgerId: d.Value(sourceLedgerId),
              originSyncId: d.Value(originSyncId),
              originAccountId: d.Value(originAccountId),
              originBackupId: d.Value(originBackupId),
              originLastRevision: d.Value(originLastRevision),
              detachedAt: d.Value(now),
            ),
          );

      // ============================================================
      // "我是谁"决策：ledger.selfMemberId 是恢复后唯一权威，
      // 禁止隐式创建第二个 self。
      //   情况 A：源 self 是 REGISTERED 且当前账号 == 源账号 → self 指向重映射成员；
      //   情况 B：源 self 是 LOCAL（本地备份跨设备）→ 复制 LOCAL 成员为权威；
      //   情况 C：其余（无 self / 账号不匹配）→ 创建新 LOCAL self。
      // ============================================================
      final srcSelfMember = srcMembers
          .where((m) => m.id == srcLedger.selfMemberId)
          .firstOrNull;
      String? selfMemberId;
      var copyLocalMembers = false;
      if (localizeSelf) {
        // 云转本地隐藏 Fork：self 一律本地化为目标 LOCAL self（确定性派生），
        // 成员行由 copyLedgerData 的 localize 分支创建（保留源展示快照）；
        // 源账本没有匹配当前账号的 REGISTERED 成员时，才由情况 C 兜底创建
        selfMemberId = localSelfMemberId(targetLedgerId, localSelfId);
        final hasRegisteredSelf = srcMembers.any(
          (m) =>
              m.memberType == 'REGISTERED' &&
              currentAccountId != null &&
              (m.linkedAccountId == currentAccountId ||
                  m.id == registeredMemberId(sourceLedgerId, currentAccountId)),
        );
        // 云端账本成员只可能是 REGISTERED/PLACEHOLDER；无匹配 REGISTERED
        // 成员（极端脏数据）时兜底创建 LOCAL self，保证 self_member_id 不悬空
        if (!hasRegisteredSelf) {
          await db
              .into(db.ledgerMembers)
              .insert(
                LedgerMembersCompanion.insert(
                  id: selfMemberId,
                  ledgerId: targetLedgerId,
                  displayName: srcSelfMember?.displayName ?? '',
                  memberType: 'LOCAL',
                  role: const d.Value('owner'),
                  updatedAt: now,
                ),
              );
        }
      } else if (srcSelfMember != null &&
          srcSelfMember.memberType == 'REGISTERED' &&
          currentAccountId != null &&
          (srcSelfMember.linkedAccountId == currentAccountId ||
              srcSelfMember.id ==
                  registeredMemberId(sourceLedgerId, currentAccountId))) {
        // 情况 A：身份可验证——self 指向重映射后的 REGISTERED 成员
        selfMemberId = registeredMemberId(targetLedgerId, currentAccountId);
      } else if (srcSelfMember != null && srcSelfMember.memberType == 'LOCAL') {
        // 情况 B：本地备份跨设备——复制 LOCAL self 成员为权威
        copyLocalMembers = true;
        selfMemberId = targetLedgerId == sourceLedgerId
            ? srcSelfMember.id
            : localSelfMemberIdFromOriginal(targetLedgerId, srcSelfMember.id);
      } else {
        // 情况 C：创建新 LOCAL self（仅当无既有 self 权威时）
        selfMemberId = localSelfMemberId(targetLedgerId, localSelfId);
        await db
            .into(db.ledgerMembers)
            .insert(
              LedgerMembersCompanion.insert(
                id: selfMemberId,
                ledgerId: targetLedgerId,
                displayName: '',
                memberType: 'LOCAL',
                role: const d.Value('owner'),
                updatedAt: now,
              ),
            );
      }
      await (db.update(db.ledgers)..where((l) => l.id.equals(targetLedgerId)))
          .write(LedgersCompanion(selfMemberId: d.Value(selfMemberId)));

      // 成员/交易/分摊/编辑历史复制（内层事务 = savepoint；server_revision 不复制；
      // 情况 B 时连同 LOCAL self 成员一起复制；localize 模式把 REGISTERED
      // self 映射为目标 LOCAL self，其余成员映射为独立 PLACEHOLDER）。
      await copyLedgerData(
        sourceLedgerId: sourceLedgerId,
        targetLedgerId: targetLedgerId,
        sourceDb: sourceDb,
        copyLocalMembers: copyLocalMembers,
        localSelfMemberId: localizeSelf ? selfMemberId : null,
        currentAccountId: currentAccountId,
        // 云转本地隐藏 Fork 同时复制有效周期模板
        copyRecurring: localizeSelf,
      );
      return targetLedgerId;
    });
  }

  /// 按来源目录复制分类与账单，身份或同级名称冲突时整份副本回滚并保留原数据供确认。
  Future<void> copyLedgerData({
    required String sourceLedgerId,
    required String targetLedgerId,
    SesameDatabase? sourceDb,
    bool copyLocalMembers = false,

    /// localize 模式的目标 LOCAL self 成员 id（云转本地隐藏 Fork 专用）
    String? localSelfMemberId,

    /// localize 模式识别源 self 的当前账号 id
    String? currentAccountId,

    /// 复制有效周期模板到目标账本（隐藏 Fork 专用）
    bool copyRecurring = false,
  }) async {
    // 跨账本数据搬运:先搬成员、再搬交易及其编辑历史。
    // [sourceDb] 为恢复场景的只读备份源（RecoverySession 的 backup.sqlite）；
    // 缺省为当前库（moveToCloud 等同库搬运路径）。
    // 分类目录按来源账本的所有者读取，复制到目标自己的目录，不能换绑来源账号行。
    // 成员复制规则:
    // - REGISTERED:用目标账本派生同一账号的 member_id(uuidV5 与账本 id 相关,
    //   跨账本必然不同),交易引用按映射重写;
    // - PLACEHOLDER:生成新 UUID 并建立「旧 → 新」映射,交易引用按映射重写;
    // - LOCAL:默认不复制(目标账本由调用方创建自己的 self member)；
    //   [copyLocalMembers] 为真时复制（本地备份跨设备恢复：源 LOCAL self 是
    //   历史"我"的权威，必须保留）。
    final src = sourceDb ?? db;
    await db.transaction(() async {
      final srcMembers =
          await (src.select(src.ledgerMembers)..where(
                (member) =>
                    member.ledgerId.equals(sourceLedgerId) &
                    member.deletedAt.isNull(),
              ))
              .get();
      final memberIdMap = <String, String>{};
      final now = DateTime.now().toUtc();
      for (final m in srcMembers) {
        if (m.memberType == 'LOCAL') {
          // 恢复跨设备场景（copyLocalMembers）：源 LOCAL self 是历史"我"的
          // 权威——原 identity 时 id 不变；Fork 时按原成员 id 确定性派生
          // （不创建第二个 self）。
          if (!copyLocalMembers) continue;
          final newId = targetLedgerId == sourceLedgerId
              ? m.id
              : localSelfMemberIdFromOriginal(targetLedgerId, m.id);
          memberIdMap[m.id] = newId;
          await db
              .into(db.ledgerMembers)
              .insert(
                LedgerMembersCompanion.insert(
                  id: newId,
                  ledgerId: targetLedgerId,
                  displayName: m.displayName,
                  memberType: 'LOCAL',
                  role: const d.Value('owner'),
                  updatedAt: now,
                ),
              );
          continue;
        }
        if (m.memberType == 'REGISTERED') {
          // 完整快照不公开账号关联；仅当前账号可通过确定性成员身份验证自身归属。
          final accountId = m.linkedAccountId?.isNotEmpty == true
              ? m.linkedAccountId
              : currentAccountId != null &&
                    m.id == registeredMemberId(sourceLedgerId, currentAccountId)
              ? currentAccountId
              : null;
          // full 快照不泄露成员账号关联，自己的确定性成员 ID 仍可验证身份。
          // localize 必须先映射所有注册成员，不能因缺少账号字段跳过历史引用。
          if (localSelfMemberId != null &&
              currentAccountId != null &&
              (accountId == currentAccountId ||
                  m.id ==
                      registeredMemberId(sourceLedgerId, currentAccountId))) {
            // localize：当前账号的 REGISTERED self → 目标 LOCAL self
            // （确定性派生 id，同源多次 Fork 收敛同一成员；保留展示快照与溯源）
            memberIdMap[m.id] = localSelfMemberId;
            await db
                .into(db.ledgerMembers)
                .insert(
                  LedgerMembersCompanion.insert(
                    id: localSelfMemberId,
                    ledgerId: targetLedgerId,
                    displayName: m.displayName,
                    memberType: 'LOCAL',
                    role: const d.Value('owner'),
                    originMemberId: d.Value(m.id),
                    updatedAt: now,
                  ),
                );
            continue;
          }
          if (localSelfMemberId != null) {
            // localize：其他 REGISTERED 成员各自映射为独立 PLACEHOLDER，
            // 不得与其他成员或既有占位合并
            final newId = _uuid.v4();
            memberIdMap[m.id] = newId;
            await db
                .into(db.ledgerMembers)
                .insert(
                  LedgerMembersCompanion.insert(
                    id: newId,
                    ledgerId: targetLedgerId,
                    displayName: m.displayName,
                    memberType: 'PLACEHOLDER',
                    originMemberId: d.Value(m.id),
                    status: d.Value(m.status),
                    updatedAt: now,
                  ),
                );
            continue;
          }
          if (accountId == null) {
            // 无法恢复云账号绑定的历史成员仍保存为独立占位成员，全部账务引用重映射。
            final newId = _uuid.v4();
            memberIdMap[m.id] = newId;
            await db
                .into(db.ledgerMembers)
                .insert(
                  LedgerMembersCompanion.insert(
                    id: newId,
                    ledgerId: targetLedgerId,
                    displayName: m.displayName,
                    memberType: 'PLACEHOLDER',
                    originMemberId: d.Value(m.id),
                    status: d.Value(m.status),
                    updatedAt: now,
                  ),
                );
            continue;
          }
          final newId = registeredMemberId(targetLedgerId, accountId);
          memberIdMap[m.id] = newId;
          await db
              .into(db.ledgerMembers)
              .insertOnConflictUpdate(
                LedgerMembersCompanion.insert(
                  id: newId,
                  ledgerId: targetLedgerId,
                  displayName: m.displayName,
                  memberType: 'REGISTERED',
                  linkedAccountId: d.Value(accountId),
                  role: d.Value(m.role),
                  avatarUrl: d.Value(m.avatarUrl),
                  avatarVersion: d.Value(m.avatarVersion),
                  status: d.Value(m.status),
                  updatedAt: now,
                ),
              );
        } else {
          final newId = _uuid.v4();
          memberIdMap[m.id] = newId;
          await db
              .into(db.ledgerMembers)
              .insert(
                LedgerMembersCompanion.insert(
                  id: newId,
                  ledgerId: targetLedgerId,
                  displayName: m.displayName,
                  memberType: 'PLACEHOLDER',
                  status: d.Value(m.status),
                  updatedAt: now,
                ),
              );
        }
      }

      // 周期副本保留完整历史及墓碑，先分配新规则身份再重映射发生身份。
      final srcRecs =
          await (src.select(src.recurringTransactions)..where(
                (row) =>
                    row.ledgerId.equals(sourceLedgerId) &
                    (copyRecurring
                        ? const d.Constant(true)
                        : row.deletedAt.isNull()),
              ))
              .get();
      final recurringIdMap = <String, String>{
        if (copyRecurring)
          for (final rule in srcRecs) rule.id: _uuid.v4(),
      };
      final srcTxs =
          await (src.select(src.transactions)..where(
                (transaction) =>
                    transaction.ledgerId.equals(sourceLedgerId) &
                    (transaction.deletedAt.isNull() |
                        (copyRecurring
                            ? transaction.recurringId.isNotNull() &
                                  transaction.occurrenceDate.isNotNull()
                            : const d.Constant(false))),
              ))
              .get();
      final sourceLedger = await (src.select(
        src.ledgers,
      )..where((l) => l.id.equals(sourceLedgerId))).getSingle();
      final targetLedger = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(targetLedgerId))).getSingle();
      final authenticatedAccount = currentAccountId ?? accountIdGetter?.call();
      if (sourceDb == null &&
          sourceLedger.storageMode == 'cloud' &&
          (authenticatedAccount == null ||
              sourceLedger.scopeAccountId != authenticatedAccount)) {
        throw StateError('源账本不属于当前账号，请重新确认账号后再复制');
      }
      final sourceScope = sourceLedger.storageMode == 'local'
          ? null
          : sourceLedger.ownerAccountId;
      final sharedSource =
          sourceLedger.storageMode == 'cloud' &&
          sourceScope != sourceLedger.scopeAccountId;
      final targetScope = targetLedger.storageMode == 'local'
          ? null
          : targetLedger.ownerAccountId;
      if (targetLedger.storageMode == 'cloud' &&
          (targetScope == null ||
              targetScope != authenticatedAccount ||
              targetLedger.scopeAccountId != authenticatedAccount)) {
        throw StateError('只能迁入本人账本的分类目录');
      }
      final referencedCategoryIds = {
        for (final t in srcTxs)
          if (t.categoryId != null) t.categoryId!,
        if (copyRecurring)
          for (final r in srcRecs)
            if (r.categoryId != null) r.categoryId!,
      };
      if (sourceLedger.storageMode == 'cloud' && sourceScope == null) {
        throw StateError('账本分类归属尚未确认，请先同步账本');
      }
      final categoryMap = await cloneCategoryReferences(
        source: src,
        target: db,
        categoryIds: referencedCategoryIds,
        sourceAccountId: sourceScope,
        targetAccountId: targetScope,
        sharedLedgerId: sharedSource ? sourceLedgerId : null,
      );
      for (final tx in srcTxs) {
        final newRecurringId = copyRecurring && tx.recurringId != null
            ? recurringIdMap[tx.recurringId] ?? tx.recurringId
            : null;
        final newOccurrenceDate = newRecurringId == null
            ? null
            : tx.occurrenceDate;
        final newTxId = newRecurringId != null && newOccurrenceDate != null
            ? recurringOccurrenceId(
                targetLedgerId,
                newRecurringId,
                newOccurrenceDate,
              )
            : _uuid.v4();
        final now = DateTime.now().toUtc();
        // 云转本地必须具有完整目标成员引用；缺失时回滚整个副本，不能保留源本 ID。
        String? remap(String? memberId) {
          if (memberId == null) return null;
          final mapped = memberIdMap[memberId];
          if (mapped == null && localSelfMemberId != null) {
            throw StateError('成员资料不完整，请重新同步后再复制账本');
          }
          return mapped ?? memberId;
        }

        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: newTxId,
                ledgerId: targetLedgerId,
                txType: requireExpenseType(tx.txType),
                amount: tx.amount,
                categoryId: d.Value(
                  tx.categoryId == null ? null : categoryMap[tx.categoryId],
                ),
                happenedAt: tx.happenedAt,
                note: d.Value(tx.note),
                // 完整周期副本重映射来源；普通交易副本不携带源本的周期身份。
                recurringId: d.Value(newRecurringId),
                occurrenceDate: d.Value(newOccurrenceDate),
                currencyCode: tx.currencyCode,
                nativeAmount: tx.nativeAmount,
                createdByMemberId: d.Value(remap(tx.createdByMemberId)),
                lastEditedByMemberId: d.Value(remap(tx.lastEditedByMemberId)),
                version: d.Value(tx.version),
                lastEditedAt: d.Value(tx.lastEditedAt),
                // 支出人成员引用按映射重写。
                payerMemberId: d.Value<String?>(remap(tx.payerMemberId)),
                aaMode: d.Value(tx.aaMode),
                createdAt: tx.createdAt,
                updatedAt: now,
                deletedAt: d.Value(tx.deletedAt),
              ),
            );
        // 复制 AA 指定分摊行:参与人成员引用按映射重写。
        final srcSplits = await (src.select(
          src.transactionSplits,
        )..where((s) => s.transactionId.equals(tx.id))).get();
        if (srcSplits.isNotEmpty) {
          await db.batch((b) {
            b.insertAll(
              db.transactionSplits,
              srcSplits.map(
                (s) => TransactionSplitsCompanion.insert(
                  transactionId: newTxId,
                  memberId: remap(s.memberId)!,
                  amount: s.amount,
                ),
              ),
            );
          });
        }
        // 拷贝该交易的编辑历史(操作者成员引用按映射重写——历史必须指向
        // 目标账本的重映射成员，否则跨账本后悬空)。
        final hist = await (src.select(
          src.recordEditHistories,
        )..where((h) => h.recordId.equals(tx.id))).get();
        for (final h in hist) {
          await db
              .into(db.recordEditHistories)
              .insert(
                RecordEditHistoriesCompanion.insert(
                  recordId: newTxId,
                  version: h.version,
                  operatorMemberId: d.Value(remap(h.operatorMemberId)),
                  summary: h.summary,
                  createdAt: d.Value(h.createdAt),
                ),
              );
        }
      }

      // 隐藏 Fork 同时保留已删除规则的墓碑，以解释发生来源，绝不复活。
      if (copyRecurring) {
        for (final r in srcRecs) {
          await db
              .into(db.recurringTransactions)
              .insert(
                RecurringTransactionsCompanion.insert(
                  id: recurringIdMap[r.id]!,
                  ledgerId: targetLedgerId,
                  txType: requireExpenseType(r.txType),
                  amount: r.amount,
                  currencyCode: r.currencyCode,
                  categoryId: d.Value(
                    r.categoryId == null ? null : categoryMap[r.categoryId],
                  ),
                  note: d.Value(r.note),
                  frequency: r.frequency,
                  protocolVersion: d.Value(r.protocolVersion),
                  timeZone: d.Value(r.timeZone),
                  interval: d.Value(r.interval),
                  dayOfMonth: d.Value(r.dayOfMonth),
                  dayOfWeek: d.Value(r.dayOfWeek),
                  monthOfYear: d.Value(r.monthOfYear),
                  startDate: r.startDate,
                  endDate: d.Value(r.endDate),
                  lastGeneratedDate: d.Value(r.lastGeneratedDate),
                  enabled: d.Value(r.enabled),
                  createdAt: d.Value(r.createdAt),
                  updatedAt: now,
                  deletedAt: d.Value(r.deletedAt),
                ),
              );
        }
      }
    });
  }

  /// 更新账本元数据。
  ///
  /// [recordChanges] 默认 true；恢复导入等「数据回填」路径传 false，
  /// 禁止把备份元数据作为本地编辑反向推云（登记在写事务内，失败整体回滚）。
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) async {
    if (name != null) name = normalizeName(name);
    // 全部字段均未变更时直接返回:避免空 UPDATE,也不产生无意义同步信号。
    final hasAnyChange =
        name != null ||
        currency != null ||
        monthStartDay != null ||
        aaEnabled != null;
    if (!hasAnyChange) return;

    // 写库与变更登记放同一事务(与 createLedger 模式对称)。
    await db.transaction(() async {
      final row = await (db.select(
        db.ledgers,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      // 账本行缺失即拒绝：静默跳过会同时给出"保存成功"提示与零副作用。
      if (row == null) {
        throw StateError('账本不存在，无法更新: $id');
      }
      final tracker = trackerGetter?.call();
      final shouldRecord =
          recordChanges && tracker != null && row.storageMode == 'cloud';
      final accountId = shouldRecord ? accountIdGetter?.call() : null;
      final now = shouldRecord
          ? await nextSyncEditTime(
              db,
              entityType: 'ledger',
              entityId: id,
              accountId: accountId,
              storedUpdatedAt: row.updatedAt,
            )
          : DateTime.now().toUtc();
      final comp = LedgersCompanion(
        name: name != null ? d.Value(name) : const d.Value.absent(),
        currency: currency != null ? d.Value(currency) : const d.Value.absent(),
        monthStartDay: monthStartDay != null
            ? d.Value(monthStartDay.clamp(1, 31))
            : const d.Value.absent(),
        aaEnabled: aaEnabled != null
            ? d.Value(aaEnabled)
            : const d.Value.absent(),
        // 账本行与 mutation 共用同一 LWW 时间，避免本地行仍携带旧时间。
        updatedAt: d.Value(now),
        scopeAccountId: accountId != null
            ? d.Value(accountId)
            : const d.Value.absent(),
      );
      await (db.update(
        db.ledgers,
      )..where((tbl) => tbl.id.equals(id))).write(comp);
      if (shouldRecord) {
        await tracker.recordLedgerChange(
          entityType: 'ledger',
          entityId: id,
          ledgerId: id,
          action: 'upsert',
          payload: ledgerPayload(
            id,
            name ?? row.name,
            currency ?? row.currency,
            monthStartDay ?? row.monthStartDay,
            aaEnabled ?? row.aaEnabled,
            now,
          ),
          updatedAt: now,
        );
      }
    });
  }

  Stream<Ledger?> watchLedger(String id) {
    return (db.select(db.ledgers)
          ..where((l) => l.id.equals(id) & l.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  /// 删除账本：本地账本物理删除，云账本保留同步身份 tombstone 与 delete mutation。
  Future<void> deleteLedger(String id) async {
    await db.transaction(() async {
      final row = await (db.select(
        db.ledgers,
      )..where((ledger) => ledger.id.equals(id))).getSingleOrNull();
      if (row == null) return;

      final pending = await (db.select(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(id) & c.pushedAt.isNull())).get();
      if (row.storageMode == 'cloud' &&
          (row.role != 'owner' ||
              accountIdGetter != null &&
                  row.scopeAccountId != accountIdGetter!())) {
        throw StateError('只有当前账号所有者可以删除云端原本');
      }
      if (row.storageMode == 'cloud' &&
          (row.syncId != null || pending.any((c) => c.frozenRequest != null))) {
        final tracker = trackerGetter?.call();
        if (tracker == null) {
          throw StateError('云账本暂时无法登记删除同步，请稍后重试');
        }
        final now = await nextSyncEditTime(
          db,
          entityType: 'ledger',
          entityId: id,
          accountId: accountIdGetter?.call(),
          storedUpdatedAt: row.updatedAt,
        );
        // 未发送的子修改由父删除覆盖；结果未知的冻结请求必须先确认，不能丢弃。
        await (db.delete(db.syncChanges)..where(
              (change) =>
                  change.ledgerId.equals(id) &
                  change.pushedAt.isNull() &
                  change.frozenRequest.isNull(),
            ))
            .go();
        await (db.update(
          db.ledgers,
        )..where((ledger) => ledger.id.equals(id))).write(
          LedgersCompanion(updatedAt: d.Value(now), deletedAt: d.Value(now)),
        );
        await tracker.recordLedgerChange(
          entityType: 'ledger',
          entityId: id,
          ledgerId: id,
          action: 'delete',
          payload: ledgerPayload(
            id,
            row.name,
            row.currency,
            row.monthStartDay,
            row.aaEnabled,
            now,
            deletedAt: now,
          ),
          updatedAt: now,
        );
        // 本地保留 ledger tombstone 与 sync_id，push 才能携带正确同步身份；
        // pull 到旧 upsert 时 tombstone 也能阻止账本在删除确认前重新出现。
        return;
      }

      // 本地账本不进入云同步通道，可直接物理删除全部关联数据。
      final txIds = (await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(id))).get()).map((t) => t.id).toList();
      await deleteTransactionsWithEditHistories(db, txIds);
      await (db.delete(db.ledgers)..where((tbl) => tbl.id.equals(id))).go();
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(id))).go();
    });
  }

  /// 清除指定账号的云账本缓存；其他账号的离线数据保持隔离保留。
  /// 本机账本不参与清理，子记录、同步队列及成员镜像在同一事务删除。
  Future<void> purgeAllCloudLedgers({required String accountId}) async {
    try {
      if (accountId.trim().isEmpty) {
        throw StateError('账号信息无效，未清理账本');
      }
      await db.transaction(() async {
        final rows =
            await (db.select(db.ledgers)..where(
                  (tbl) =>
                      tbl.storageMode.equals('cloud') &
                      tbl.scopeAccountId.equals(accountId),
                ))
                .get();
        if (rows.isEmpty) return;
        final ledgerIds = rows.map((row) => row.id).toList();
        // 先保存交易编号，让编辑历史与目标账号的账本在同一事务中完整删除。
        final transactionIds =
            (await (db.select(
                  db.transactions,
                )..where((row) => row.ledgerId.isIn(ledgerIds))).get())
                .map((row) => row.id)
                .toList();
        await deleteTransactionsWithEditHistories(db, transactionIds);
        await (db.delete(
          db.syncChanges,
        )..where((row) => row.ledgerId.isIn(ledgerIds))).go();
        await (db.delete(
          db.ledgerMembers,
        )..where((row) => row.ledgerId.isIn(ledgerIds))).go();
        await (db.delete(
          db.sharedLedgerCategories,
        )..where((row) => row.ledgerId.isIn(ledgerIds))).go();
        // 周期规则等带外键的子记录随账本行级联清理。
        await (db.delete(
          db.ledgers,
        )..where((row) => row.id.isIn(ledgerIds))).go();
      });
    } catch (error, stackTrace) {
      logger.error('LocalLedger', '清理账号云账本缓存失败', error, stackTrace);
      rethrow;
    }
  }

  /// 单账本 purge：清除一本账本及其全部关联本地数据（退出/删除共享账本用）。
  ///
  /// 与 [purgeAllCloudLedgers] 同源级联，仅选区收敛到单账本：交易+编辑历史、
  /// 待推送变更、成员镜像、共享分类镜像与账本行一并清除；不登记任何新变更
  /// （云端已由 REST 完成退出/删除，再登记 delete 会二次推送）。
  Future<void> purgeLedger(String id) async {
    // 幂等快路径：账本不存在时零副作用。
    final row = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(id))).getSingleOrNull();
    if (row == null) return;

    final txIds = (await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id))).get()).map((t) => t.id).toList();
    await db.transaction(() async {
      await deleteTransactionsWithEditHistories(db, txIds);
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(id))).go();
      await (db.delete(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.equals(id))).go();
      await (db.delete(
        db.sharedLedgerCategories,
      )..where((s) => s.ledgerId.equals(id))).go();
      await (db.delete(db.ledgers)..where((l) => l.id.equals(id))).go();
    });
  }
}

/// 构造契约形状的 ledger payload(规范化 snake_case)。
String ledgerPayload(
  String id,
  String name,
  String currency,
  int monthStartDay,
  bool aaEnabled,
  DateTime updatedAt, {
  DateTime? deletedAt,
}) {
  return jsonEncode({
    'id': id,
    'name': name,
    'currency': currency,
    'month_start_day': monthStartDay,
    'aa_enabled': aaEnabled,
    // role/member_count 由服务端权威回填,本地 push 时以服务端快照为准。
    'role': 'owner',
    'member_count': 1,
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (deletedAt != null) 'deleted_at': deletedAt.toUtc().toIso8601String(),
  });
}
