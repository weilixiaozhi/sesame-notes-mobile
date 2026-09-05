import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
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
    return (db.select(db.ledgers)..where(
          (l) =>
              l.bindingStatus.isNotValue('pending_local_move') &
              l.deletedAt.isNull(),
        ))
        .watch();
  }

  Future<List<Ledger>> getAllLedgers() async {
    return (db.select(db.ledgers)..where(
          (l) =>
              l.bindingStatus.isNotValue('pending_local_move') &
              l.deletedAt.isNull(),
        ))
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
        ELSE CAST(julianday('now', 'localtime') - julianday(MIN(happened_at), 'unixepoch', 'localtime') + 1 AS INTEGER)
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
    List<Transaction>? transactions,
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

  /// 全部账本支出总额（Dart 层聚合保持 Decimal 精度，避免 TEXT 列 SQL SUM 失效）。
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
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
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
              monthStartDay: d.Value(monthStartDay.clamp(1, 28)),
              aaEnabled: d.Value(aaEnabled),
              storageMode: d.Value(storageMode),
              scopeAccountId: d.Value(
                storageMode == 'cloud' ? accountIdGetter?.call() : null,
              ),
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
            storageMode,
            now,
          ),
          updatedAt: now,
        );
      }
      return id;
    });
  }

  /// 云端已创建的账本本地落"已绑定"行：不登记变更（服务器已有该账本）。
  ///
  /// [syncId] 为服务端下发的同步时间线身份（full 快照 / moveToCloud 响应），
  /// 必须随绑定行一并落库，否则本地无法校验同步身份。
  Future<void> createBoundLedger({
    required String id,
    required String name,
    String currency = 'CNY',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? syncId,
  }) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            currency: d.Value(currency),
            monthStartDay: d.Value(monthStartDay.clamp(1, 28)),
            aaEnabled: d.Value(aaEnabled),
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountIdGetter?.call()),
            syncId: d.Value(syncId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// 更新账本的云同步时间线身份（绑定建立/确认路径：push outcome、full 快照）。
  Future<void> updateLedgerSyncId({
    required String id,
    required String syncId,
  }) async {
    await (db.update(db.ledgers)..where((tbl) => tbl.id.equals(id))).write(
      LedgersCompanion(syncId: d.Value(syncId)),
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

  Future<void> detachFromCloud(String id) async {
    // 「转本地」断联:翻归属标记 + 清除同步身份 + 清除该账本遗留的待推送变更,
    // 同一事务保证原子。同步身份必须清空——Detach 后本地副本不持有任何
    // 云同步时间线身份（不生成伪本地 sync_id）。
    await db.transaction(() async {
      await updateLedgerStorageMode(id: id, storageMode: 'local');
      await (db.update(db.ledgers)..where((tbl) => tbl.id.equals(id))).write(
        const LedgersCompanion(
          scopeAccountId: d.Value(null),
          syncId: d.Value(null),
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
    DateTime? backupCreatedAt,
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
      backupCreatedAt: backupCreatedAt,
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
      localizeSelf: true,
    );
  }

  /// 本地账本恢复：[targetLedgerId] 由调用方按 ID 冲突策略决定
  /// （目标库无该 ID → 原 identity；有该 ID → 新 ID Fork）。origin_type 记 LOCAL_BACKUP。
  Future<String> restoreLocalLedger({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    required String originBackupId,
    DateTime? backupCreatedAt,
    SesameDatabase? sourceDb,
    String? currentAccountId,
  }) {
    return _copyLedgerWithOrigin(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: targetLedgerId,
      originType: 'LOCAL_BACKUP',
      localSelfId: localSelfId,
      originBackupId: originBackupId,
      backupCreatedAt: backupCreatedAt,
      sourceDb: sourceDb,
      currentAccountId: currentAccountId,
    );
  }

  /// Fork/恢复共用的账本复制原语：单事务内建目标账本行（origin 溯源）→
  /// 按"我是谁"规则确定 self 成员 → 复制成员/交易/AA/编辑历史。
  ///
  /// [targetBindingStatus]：云转本地隐藏 Fork 时为 pending_local_move，
  /// 其余路径保持 null（正常本地账本）。
  /// [localizeSelf]：隐藏 Fork 时把当前账号的 REGISTERED self 映射为
  /// 目标 LOCAL self，其余 REGISTERED/PLACEHOLDER 分别映射为 PLACEHOLDER。
  Future<String> _copyLedgerWithOrigin({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String originType,
    required String localSelfId,
    required String originBackupId,
    String? originAccountId,
    String? originSyncId,
    int? originLastRevision,
    DateTime? backupCreatedAt,
    SesameDatabase? sourceDb,
    String? currentAccountId,
    String? targetBindingStatus,
    bool localizeSelf = false,
  }) async {
    // [sourceDb]：恢复场景的只读备份源；缺省为当前库（同库搬运）。
    final src = sourceDb ?? db;
    return db.transaction(() async {
      final srcLedger = await (src.select(
        src.ledgers,
      )..where((l) => l.id.equals(sourceLedgerId))).getSingleOrNull();
      if (srcLedger == null) throw StateError('源账本不存在: $sourceLedgerId');
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
              m.linkedAccountId == currentAccountId,
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
          srcSelfMember.linkedAccountId == currentAccountId) {
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
        currentAccountId: localizeSelf ? currentAccountId : null,
        // 云转本地隐藏 Fork 同时复制周期模板与本地域分类副本
        copyRecurringAndCategories: localizeSelf,
      );
      return targetLedgerId;
    });
  }

  Future<void> copyLedgerData({
    required String sourceLedgerId,
    required String targetLedgerId,
    SesameDatabase? sourceDb,
    bool copyLocalMembers = false,

    /// localize 模式的目标 LOCAL self 成员 id（云转本地隐藏 Fork 专用）
    String? localSelfMemberId,

    /// localize 模式识别源 self 的当前账号 id
    String? currentAccountId,

    /// 复制周期模板并把源引用的账号域分类克隆到本地域（隐藏 Fork 专用）
    bool copyRecurringAndCategories = false,
  }) async {
    // 跨账本数据搬运:先搬成员、再搬交易及其编辑历史。
    // [sourceDb] 为恢复场景的只读备份源（RecoverySession 的 backup.sqlite）；
    // 缺省为当前库（moveToCloud 等同库搬运路径）。
    // Categories 是 user-global 表(无 ledgerId 列),分类被所有账本共享,无需拷贝。
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
          final accountId = m.linkedAccountId;
          if (accountId == null || accountId.isEmpty) continue;
          if (localSelfMemberId != null && accountId == currentAccountId) {
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

      final srcTxs =
          await (src.select(src.transactions)..where(
                (transaction) =>
                    transaction.ledgerId.equals(sourceLedgerId) &
                    transaction.deletedAt.isNull(),
              ))
              .get();
      for (final tx in srcTxs) {
        final newTxId = _uuid.v4();
        final now = DateTime.now().toUtc();
        // 作者/支出人成员引用按映射重写;未知成员保持原值(源账本遗留脏引用
        // 不阻塞复制,由展示层降级处理)。
        String? remap(String? memberId) =>
            memberId == null ? null : (memberIdMap[memberId] ?? memberId);
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: newTxId,
                ledgerId: targetLedgerId,
                txType: tx.txType,
                amount: tx.amount,
                categoryId: d.Value(tx.categoryId),
                happenedAt: tx.happenedAt,
                note: d.Value(tx.note),
                // 副本不复制周期模板,recurringId 必须清空,否则会指向源账本
                // 的模板 id,源账本删除后副本交易产生悬空引用。
                recurringId: const d.Value.absent(),
                excludeFromStats: d.Value(tx.excludeFromStats),
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
                  memberId: memberIdMap[s.memberId] ?? s.memberId,
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

      // 隐藏 Fork（云转本地）：复制有效周期模板，并把源引用的账号域分类
      // 克隆到本地域（新 UUID + 重写交易/模板 category id；已删除模板不复制，
      // 禁止复活已删除实体）。
      if (copyRecurringAndCategories) {
        // 收集源账本交易/周期模板实际引用的分类（含父链），克隆为本地域副本
        final categoryIds = <String>{};
        final srcTxsAll =
            await (src.select(src.transactions)..where(
                  (t) =>
                      t.ledgerId.equals(sourceLedgerId) & t.deletedAt.isNull(),
                ))
                .get();
        for (final t in srcTxsAll) {
          if (t.categoryId != null) categoryIds.add(t.categoryId!);
        }
        final srcRecs =
            await (src.select(src.recurringTransactions)..where(
                  (r) =>
                      r.ledgerId.equals(sourceLedgerId) & r.deletedAt.isNull(),
                ))
                .get();
        for (final r in srcRecs) {
          if (r.categoryId != null) categoryIds.add(r.categoryId!);
        }
        final categoryIdMap = <String, String>{};
        for (final cid in categoryIds) {
          await _cloneCategoryToLocal(
            src: src,
            db: db,
            categoryId: cid,
            map: categoryIdMap,
            now: now,
          );
        }
        // 重写目标交易与周期模板的分类引用（新分类只属于本地域）
        if (categoryIdMap.isNotEmpty) {
          final targetTxRows = await (db.select(
            db.transactions,
          )..where((t) => t.ledgerId.equals(targetLedgerId))).get();
          for (final t in targetTxRows) {
            final mapped = t.categoryId == null
                ? null
                : categoryIdMap[t.categoryId!];
            if (mapped != null) {
              await (db.update(db.transactions)
                    ..where((x) => x.id.equals(t.id)))
                  .write(TransactionsCompanion(categoryId: d.Value(mapped)));
            }
          }
          final targetRecRows = await (db.select(
            db.recurringTransactions,
          )..where((r) => r.ledgerId.equals(targetLedgerId))).get();
          for (final r in targetRecRows) {
            final mapped = r.categoryId == null
                ? null
                : categoryIdMap[r.categoryId!];
            if (mapped != null) {
              await (db.update(
                db.recurringTransactions,
              )..where((x) => x.id.equals(r.id))).write(
                RecurringTransactionsCompanion(categoryId: d.Value(mapped)),
              );
            }
          }
        }
        // 复制有效周期模板（含重映射后的分类引用）
        for (final r in srcRecs) {
          await db
              .into(db.recurringTransactions)
              .insert(
                RecurringTransactionsCompanion.insert(
                  id: _uuid.v4(),
                  ledgerId: targetLedgerId,
                  txType: r.txType,
                  amount: r.amount,
                  currencyCode: r.currencyCode,
                  categoryId: d.Value(
                    r.categoryId == null
                        ? null
                        : (categoryIdMap[r.categoryId!] ?? r.categoryId),
                  ),
                  note: d.Value(r.note),
                  frequency: r.frequency,
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
                ),
              );
        }
      }
    });
  }

  /// 把 [categoryId] 及其父分类链克隆为本地域（scopeAccountId=null）副本：
  /// 新 UUID 写 [map]，重复引用复用同一副本；已克隆/本地域分类跳过。
  ///
  /// 去重契约：源分类已属本地域且父链保持原 id 时直接复用自身；
  /// 本地域已有同名同类同父分类时复用既有副本——克隆制造新实体会
  /// 把同名分类逐次翻倍，云端与本地都会越积越多。
  Future<void> _cloneCategoryToLocal({
    required SesameDatabase src,
    required SesameDatabase db,
    required String categoryId,
    required Map<String, String> map,
    required DateTime now,
  }) async {
    if (map.containsKey(categoryId)) return;
    final category =
        await (src.select(src.categories)
              ..where((c) => c.id.equals(categoryId) & c.deletedAt.isNull()))
            .getSingleOrNull();
    if (category == null) return;
    // 父链优先克隆：子分类的 parent_id 必须指向本地域副本
    if (category.parentId != null) {
      await _cloneCategoryToLocal(
        src: src,
        db: db,
        categoryId: category.parentId!,
        map: map,
        now: now,
      );
    }
    // 父分类在本地域的映射 id（父已属本地域时为原 id，父被克隆时为克隆 id）
    final mappedParent = category.parentId == null
        ? null
        : (map[category.parentId!] ?? category.parentId);
    // 源分类已属本地域且父链保持原 id：引用直接指向自身，无需克隆
    if (category.scopeAccountId == null && mappedParent == category.parentId) {
      map[category.id] = category.id;
      return;
    }
    // 去重：本地域已有同名同类同父分类时复用既有副本，避免重复克隆
    final existing =
        await (db.select(db.categories)..where(
              (c) =>
                  c.scopeAccountId.isNull() &
                  c.name.equals(category.name) &
                  c.kind.equals(category.kind) &
                  c.deletedAt.isNull() &
                  (mappedParent == null
                      ? c.parentId.isNull()
                      : c.parentId.equals(mappedParent)),
            ))
            .getSingleOrNull();
    if (existing != null) {
      map[category.id] = existing.id;
      return;
    }
    final newId = _uuid.v4();
    map[category.id] = newId;
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: newId,
            name: category.name,
            kind: category.kind,
            level: category.level,
            sortOrder: d.Value(category.sortOrder),
            icon: d.Value(category.icon),
            parentId: d.Value(mappedParent),
            updatedAt: now,
          ),
        );
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
      if (row == null) return;
      final now = DateTime.now().toUtc();
      final tracker = trackerGetter?.call();
      final shouldRecord =
          recordChanges && tracker != null && row.storageMode == 'cloud';
      final accountId = shouldRecord ? accountIdGetter?.call() : null;
      final comp = LedgersCompanion(
        name: name != null ? d.Value(name) : const d.Value.absent(),
        currency: currency != null ? d.Value(currency) : const d.Value.absent(),
        monthStartDay: monthStartDay != null
            ? d.Value(monthStartDay.clamp(1, 28))
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
            row.storageMode,
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

      if (row.storageMode == 'cloud') {
        final tracker = trackerGetter?.call();
        if (tracker == null) {
          throw StateError('云账本暂时无法登记删除同步，请稍后重试');
        }
        final now = DateTime.now().toUtc();
        // 最终 ledger delete 已涵盖服务端级联；先清掉该账本旧 mutation，
        // 避免删除后仍推送无意义的交易/成员更新，再留下唯一删除事件。
        await (db.delete(
          db.syncChanges,
        )..where((change) => change.ledgerId.equals(id))).go();
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
            row.storageMode,
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

  /// 退出登录 purge：整本清除全部云端账本及其关联数据。
  ///
  /// 设计意图：退出登录后这台设备不持有云账号数据，storage_mode='cloud'
  /// 的账本（含交易、编辑历史、待推送变更、成员/共享分类镜像等）全部清除，
  /// 重登后由全量同步拉回；storage_mode='local' 的账本一行不动——那是这台
  /// 设备自己的数据。选区只看 storage_mode，不依赖 member_count 派生（本地
  /// 账本即使残留成员镜像也不误伤）。
  Future<void> purgeAllCloudLedgers() async {
    final rows = await (db.select(
      db.ledgers,
    )..where((tbl) => tbl.storageMode.equals('cloud'))).get();
    if (rows.isEmpty) return; // 幂等快路径：无云端账本时零副作用
    final localIds = rows.map((r) => r.id).toList();

    // 先取待删交易 id，用于连带清编辑历史（record_edit_histories 引用交易 id，
    // 只删交易会留下永远匹配不上的孤儿历史行）。
    final txIds =
        (await (db.select(
              db.transactions,
            )..where((t) => t.ledgerId.isIn(localIds))).get())
            .map((t) => t.id)
            .toList();

    // 单事务级联：交易+编辑历史 → 无外键的镜像表与待推送变更 → 账本行。
    // 周期交易 / 虚拟用户带 FK cascade，随账本行删除自动清除，无需手动删。
    await db.transaction(() async {
      await deleteTransactionsWithEditHistories(db, txIds);
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.isIn(localIds))).go();
      await (db.delete(
        db.ledgerMembers,
      )..where((m) => m.ledgerId.isIn(localIds))).go();
      await (db.delete(
        db.sharedLedgerCategories,
      )..where((s) => s.ledgerId.isIn(localIds))).go();
      await (db.delete(db.ledgers)..where((l) => l.id.isIn(localIds))).go();
    });
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
  String storageMode,
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
    'role': storageMode == 'cloud' ? 'owner' : 'owner',
    'member_count': 1,
    'updated_at': updatedAt.toIso8601String(),
    if (deletedAt != null) 'deleted_at': deletedAt.toIso8601String(),
  });
}
