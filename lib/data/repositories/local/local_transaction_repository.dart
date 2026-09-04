import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// AA 指定分摊输入(契约 TransactionSplit 的本地表达)。
/// 参与人统一引用成员 id(member_id);amount 为规范化 Decimal 字符串。
/// 同步/上传时按成员绑定映射回契约的 user_id / virtual_user_id。
class TransactionSplitInput {
  final String memberId;
  final String amount;

  const TransactionSplitInput({required this.memberId, required this.amount});
}

/// 统一删除交易及其编辑历史。
///
/// 为什么需要单独收敛：各删除入口（单条删除、按 UUID 批量删除、按账本清空/删除）如果各自
/// 直接删除 transactions，record_edit_histories 会留下永远匹配不到交易的孤儿行；SQLite 的
/// 外键级联依赖 PRAGMA foreign_keys 开关，显式先删编辑历史更稳妥，且能让所有入口行为一致。
Future<int> deleteTransactionsWithEditHistories(
  SesameDatabase db,
  Iterable<String> transactionIds,
) async {
  final ids = transactionIds.toList();
  if (ids.isEmpty) return 0;

  // 先清编辑历史，再删交易主表；顺序保证即使外键未开启也不会残留孤儿历史。
  await (db.delete(
    db.recordEditHistories,
  )..where((h) => h.recordId.isIn(ids))).go();
  return (db.delete(db.transactions)..where((t) => t.id.isIn(ids))).go();
}

/// 本地交易Repository实现
/// 基于 Drift 数据库实现
class LocalTransactionRepository {
  final SesameDatabase db;

  /// 写事务中获取变更登记器，避免构造顺序形成循环依赖（与账本仓储同模式）。
  final ChangeRecorder? Function()? trackerGetter;

  LocalTransactionRepository(this.db, {this.trackerGetter});

  Stream<List<Transaction>> watchRecentTransactions({
    required String ledgerId,
    int limit = 20,
  }) {
    return (db.select(db.transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

  /// 读取账本的自定义每月起始日(1-28);账本缺失或查询异常时按 1(自然月)降级
  /// —— watch 流经 Stream.fromFuture 包裹,这里抛错会让流永久进 error 态。
  Future<int> _monthStartDayOf(String ledgerId) async {
    try {
      final row = await (db.select(
        db.ledgers,
      )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
      return (row?.monthStartDay ?? 1).clamp(1, 28);
    } catch (_) {
      return 1;
    }
  }

  Stream<List<Transaction>> watchTransactionsInMonth({
    required String ledgerId,
    required DateTime month,
  }) {
    return Stream.fromFuture(_monthStartDayOf(ledgerId)).asyncExpand((sd) {
      final range = periodForLabel(month.year, month.month, sd);
      return (db.select(db.transactions)
            ..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.deletedAt.isNull() &
                  t.happenedAt.isBiggerOrEqualValue(range.start) &
                  t.happenedAt.isSmallerThanValue(range.end),
            )
            ..orderBy([
              (t) => d.OrderingTerm(
                expression: t.happenedAt,
                mode: d.OrderingMode.desc,
              ),
            ]))
          .watch();
    });
  }

  /// 标准 tx + category LEFT JOIN。所有 list 风格的
  /// watch 都走这个,避免重复写 join 表。
  List<d.Join<d.HasResultSet, dynamic>> _txJoins() => [
    d.leftOuterJoin(
      db.categories,
      db.categories.id.equalsExp(db.transactions.categoryId) &
          db.categories.deletedAt.isNull(),
    ),
  ];

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryAll({String? ledgerId}) {
    final select = db.select(db.transactions)
      ..where((t) => t.deletedAt.isNull());
    if (ledgerId != null) {
      select.where((t) => t.ledgerId.equals(ledgerId));
    }
    select.orderBy([
      (t) =>
          d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
    ]);
    final q = select.join(_txJoins());
    return _watchTxJoinWithSharedHydration(q);
  }

  Stream<List<({Transaction t, Category? category})>>
  watchExcludedAaTransactions(String ledgerId) {
    // 只取 aaMode=1(不分摊)的交易,过滤下沉到 SQL,避免客户端全量过滤。
    final select = db.select(db.transactions)
      ..where(
        (t) =>
            t.ledgerId.equals(ledgerId) &
            t.deletedAt.isNull() &
            t.aaMode.equals(1),
      )
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
      ]);
    final q = select.join(_txJoins());
    return _watchTxJoinWithSharedHydration(q);
  }

  /// 把 Drift 主表 stream 跟 SharedLedgerCategories 表更新合流,
  /// 任一变化都重跑 hydration 并 emit。
  ///
  /// 单纯用 q.watch() 时,Drift 只 track query 里 join 到的表(transactions /
  /// categories)。SharedLedgerCategories 行被 WS handler 改了,stream 不会
  /// re-emit → tx tile 显示旧名字/图标,跟 picker 不一致。这里手动加一路
  /// db.tableUpdates(SharedLedgerCategories) 监听,触发时拿上一次
  /// Drift 结果重 hydrate 再 emit。
  Stream<List<({Transaction t, Category? category})>>
  _watchTxJoinWithSharedHydration(d.JoinedSelectStatement q) {
    late StreamController<List<({Transaction t, Category? category})>> ctrl;
    StreamSubscription? txSub;
    StreamSubscription? sharedCatSub;
    List<d.TypedResult>? lastRows;

    Future<void> rehydrate() async {
      if (lastRows == null) return;
      final out = lastRows!
          .map(
            (r) => (
              t: r.readTable(db.transactions),
              category: r.readTableOrNull(db.categories),
            ),
          )
          .toList();
      final hydrated = await _hydrateSharedOverrides(out);
      if (!ctrl.isClosed) ctrl.add(hydrated);
    }

    ctrl = StreamController<List<({Transaction t, Category? category})>>(
      onListen: () {
        txSub = q.watch().listen((rows) {
          lastRows = rows;
          rehydrate();
        });
        sharedCatSub = db
            .tableUpdates(d.TableUpdateQuery.onTable(db.sharedLedgerCategories))
            .listen((_) => rehydrate());
      },
      onCancel: () async {
        await txSub?.cancel();
        await sharedCatSub?.cancel();
      },
    );
    return ctrl.stream;
  }

  /// 共享账本下 Editor 记的 tx,主表 JOIN 不到 category 行(categoryId 是
  /// Owner 侧的分类 UUID,本地 Categories 表没有该行),category 字段是 null。
  /// 这里按 (ledgerId, categoryId) 反查 SharedLedgerCategories 镜像,
  /// 转 synthetic 实体回填,UI 不用区分来源。
  ///
  /// categoryId 本身就是 UUID,直接作为 Category.id。
  Future<List<({Transaction t, Category? category})>> _hydrateSharedOverrides(
    List<({Transaction t, Category? category})> rows,
  ) async {
    // 收集所有需要反查的 categoryId(UUID):JOIN 缺失且非空。
    final missingCatIds = <String>{};
    for (final r in rows) {
      final cid = r.t.categoryId;
      if (r.category == null && cid != null && cid.isNotEmpty) {
        missingCatIds.add(cid);
      }
    }
    if (missingCatIds.isEmpty) return rows;

    // 本地主表 tombstone 是删除权威，不能因共享镜像仍有旧快照而复活。
    final tombstonedIds =
        await (db.select(db.categories)..where(
              (category) =>
                  category.id.isIn(missingCatIds) &
                  category.deletedAt.isNotNull(),
            ))
            .get();
    missingCatIds.removeAll(tombstonedIds.map((category) => category.id));
    if (missingCatIds.isEmpty) return rows;

    // 按交易所属账本过滤,避免跨账本同 categoryId 碰撞取错分类。
    final ledgerIds = rows.map((r) => r.t.ledgerId).toSet().toList();
    final shared =
        await (db.select(db.sharedLedgerCategories)..where(
              (s) =>
                  s.ledgerId.isIn(ledgerIds) &
                  s.categoryId.isIn(missingCatIds.toList()),
            ))
            .get();
    final sharedByLedgerAndCat = {
      for (final s in shared) '${s.ledgerId}|${s.categoryId}': s,
    };

    // 回填到每行
    return rows.map((r) {
      Category? category = r.category;

      final cid = r.t.categoryId;
      if (category == null && cid != null && cid.isNotEmpty) {
        final s = sharedByLedgerAndCat['${r.t.ledgerId}|$cid'];
        if (s != null) category = _syntheticCategoryFromShared(s);
      }

      return (t: r.t, category: category);
    }).toList();
  }

  /// SharedLedgerCategory → synthetic Category。镜像行的 categoryId 本身就是
  /// Owner 侧的分类 UUID,直接作为 Category.id,与主表分类共享同一 id 空间,
  /// 分类详情反查/导出等下游路径无需区分来源。
  Category _syntheticCategoryFromShared(SharedLedgerCategory s) {
    return Category(
      id: s.categoryId,
      name: s.name,
      kind: s.kind,
      icon: s.icon,
      sortOrder: s.sortOrder,
      // 二级分类的 parentId 同为 UUID,直接透传,供导出拆「分类 / 二级分类」两列。
      parentId: s.parentId,
      level: s.level,
      updatedAt: s.updatedAt,
    );
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInMonth({
    required String ledgerId,
    required DateTime month,
  }) {
    return Stream.fromFuture(_monthStartDayOf(ledgerId)).asyncExpand((sd) {
      final range = periodForLabel(month.year, month.month, sd);
      final q =
          (db.select(db.transactions)
                ..where(
                  (t) =>
                      t.ledgerId.equals(ledgerId) &
                      t.deletedAt.isNull() &
                      t.happenedAt.isBiggerOrEqualValue(range.start) &
                      t.happenedAt.isSmallerThanValue(range.end),
                )
                ..orderBy([
                  (t) => d.OrderingTerm(
                    expression: t.happenedAt,
                    mode: d.OrderingMode.desc,
                  ),
                ]))
              .join(_txJoins());
      return _watchTxJoinWithSharedHydration(q);
    });
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInYear({
    required String ledgerId,
    required int year,
  }) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final q =
        (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.deletedAt.isNull() &
                    t.happenedAt.isBiggerOrEqualValue(start) &
                    t.happenedAt.isSmallerThanValue(end),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.desc,
                ),
              ]))
            .join(_txJoins());
    return _watchTxJoinWithSharedHydration(q);
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsForCategoryInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
    String? categoryId,
    required String type,
  }) {
    final base =
        (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.deletedAt.isNull() &
                    t.txType.equals(type) &
                    t.happenedAt.isBiggerOrEqualValue(start) &
                    t.happenedAt.isSmallerThanValue(end),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.desc,
                ),
              ]))
            .join(_txJoins());
    if (categoryId == null) {
      base.where(db.transactions.categoryId.isNull());
    } else {
      base.where(db.transactions.categoryId.equals(categoryId));
    }
    return _watchTxJoinWithSharedHydration(base);
  }

  static const _uuid = Uuid();

  /// 新增一条交易（本地创建路径）。
  ///
  /// 主键 UUID 由客户端生成（离线可用，本地即云端 id）；金额为规范化
  /// decimal 字符串直写，不做整数分换算。currencyCode/nativeAmount 是
  /// 契约必填列：调用方未显式传入时按「本位币交易」兜底（CNY、金额相等）。
  ///
  /// [operatorMemberId] 为当前操作者成员 id，与交易在同一事务写入
  /// createdByMemberId/lastEditedByMemberId，并在未指定支出人时兜底
  /// payerMemberId。为空表示成员身份未就绪，作者字段留空由服务端注入，
  /// 调用方不得在写库后再补一次作者回填（会产生第二条同步 mutation）。
  Future<String> addTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? categoryId,
    required DateTime happenedAt,
    String? note,
    bool excludeFromStats = false,
    String? currencyCode,
    String? nativeAmount,
    // AA 分摊字段:由调用方显式传入,子仓收"已定值"直写
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    // 子仓收「已定值」直写;带折算的兜底(查汇率)在聚合
    // LocalRepository 包装层(子仓拿不到汇率)。
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    // 空串视作身份未就绪：作者与支出人兜底都不生效。
    final author = (operatorMemberId?.isNotEmpty ?? false)
        ? operatorMemberId
        : null;
    // insert、分摊写入与变更登记放同一事务：登记失败整体回滚，
    // 避免"本地落库成功但云端永远推不出去"的账本内交易。
    await db.transaction(() async {
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              ledgerId: ledgerId,
              txType: type,
              amount: amount,
              categoryId: d.Value(categoryId),
              happenedAt: happenedAt,
              note: d.Value(note),
              excludeFromStats: d.Value(excludeFromStats),
              // 契约必填列:未折算时按本位币语义兜底(币种 CNY、快照=原币金额)。
              currencyCode: currencyCode ?? 'CNY',
              nativeAmount: nativeAmount ?? amount,
              // AA 字段:nullable,非 AA 交易传 null(列存 NULL)
              // 未指定支出人时以操作者兜底(默认支出人 = 创建人)。
              payerMemberId: d.Value(payerMemberId ?? author),
              aaMode: d.Value(aaMode),
              createdByMemberId: d.Value(author),
              lastEditedByMemberId: d.Value(author),
              createdAt: now,
              updatedAt: now,
            ),
          );
      // 指定分摊写入关系表(先删后插,整批替换语义与后端一致)。
      await replaceTransactionSplits(db, id, splits);
      // 仅云端账本登记 transaction upsert 变更(本地账本不进同步通道)。
      final row = await getTransactionById(id);
      if (row != null) {
        await _recordTxChange(row: row, action: 'upsert');
      }
    });
    return id;
  }

  Future<int> insertTransactionsBatch(
    List<TransactionsCompanion> items, {
    bool recordChanges = true,
  }) async {
    if (items.isEmpty) return 0;
    // 预填充主键:UUID 客户端生成,batch insertAll 不返回 rowid,
    // 后续反查与变更登记都依赖确定的 id。
    final effectiveItems = items.map((item) {
      // Value<String> 的 value 为非空 String,absent 状态要用 present 判断。
      if (!item.id.present) {
        return item.copyWith(id: d.Value(_uuid.v4()));
      }
      return item;
    }).toList();
    // 批量插入与批量变更登记同一事务:登记失败整体回滚,避免漏推。
    return db.transaction(() async {
      await db.batch((b) => b.insertAll(db.transactions, effectiveItems));
      if (recordChanges) {
        await recordBatchTxChanges(effectiveItems.map((c) => c.id.value));
      }
      return effectiveItems.length;
    });
  }

  // 批量插入交易(无标签/附件关联),返回每个交易的 UUID 主键
  Future<List<String>> insertTransactionsBatchWithRelations({
    required List<TransactionsCompanion> transactions,
    bool recordChanges = true,
  }) async {
    if (transactions.isEmpty) return const [];
    // 主键即 UUID:预先填充后 batch insert,id 列表直接可用。
    final effective = transactions.map((tx) {
      if (!tx.id.present) {
        return tx.copyWith(id: d.Value(_uuid.v4()));
      }
      return tx;
    }).toList();
    final ids = effective.map((c) => c.id.value).toList();

    // 批量插入与批量变更登记同一事务(导入路径默认 recordChanges=true)。
    await db.transaction(() async {
      await db.batch((b) => b.insertAll(db.transactions, effective));
      if (recordChanges) {
        await recordBatchTxChanges(ids);
      }
    });
    return ids;
  }

  /// 更新一条交易（本地编辑路径）。
  ///
  /// version+1 + lastEditedAt/updatedAt 支撑编辑历史与列表项 HH:mm 展示。
  /// 同步回放不走此方法，不会误增版本号。
  /// 先读旧 version 再 +1:本地单用户/共享账本 LWW 场景并发风险低,先读后写可接受。
  ///
  /// [operatorMemberId] 为当前操作者成员 id，与本次更新在同一事务写入
  /// lastEditedByMemberId，并在原支出人为空时兜底 payerMemberId
  /// （历史数据从未回填的极端场景）；createdByMemberId 维持 first-write-wins。
  Future<int> updateTransaction({
    required String id,
    required String type,
    required String amount,
    String? categoryId,
    String? note,
    DateTime? happenedAt,
    bool? excludeFromStats,
    String? currencyCode,
    String? nativeAmount,
    // AA 分摊字段:null = 不更新保持原值;splits 非 null 时整批替换关系表
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    final existing = await getTransactionById(id);
    if (existing == null) {
      throw StateError('交易不存在，无法更新: $id');
    }
    final newVersion = existing.version + 1;
    final now = DateTime.now().toUtc();
    final author = (operatorMemberId?.isNotEmpty ?? false)
        ? operatorMemberId
        : null;
    // 支出人语义:显式传入优先;未传且原值为空时以操作者兜底(支出人全局必填);
    // 原值非空视为用户手改值,保留不动。
    final effectivePayer =
        payerMemberId ??
        ((existing.payerMemberId?.isNotEmpty ?? false) ? null : author);
    // 更新、分摊替换与变更登记同一事务:登记失败整体回滚。
    return db.transaction(() async {
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          txType: d.Value(type),
          amount: d.Value(amount),
          categoryId: d.Value(categoryId),
          note: d.Value(note),
          happenedAt: happenedAt != null
              ? d.Value(happenedAt)
              : const d.Value.absent(),
          // null = 不更新(保持原值);非 null = 显式写入
          excludeFromStats: excludeFromStats == null
              ? const d.Value.absent()
              : d.Value(excludeFromStats),
          // null = 不更新(保持原快照);非 null = 显式写入
          currencyCode: currencyCode == null
              ? const d.Value.absent()
              : d.Value(currencyCode),
          nativeAmount: nativeAmount == null
              ? const d.Value.absent()
              : d.Value(nativeAmount),
          // AA 分摊字段:null = 不更新(absent);非 null = 显式写入。
          // 对 nullable 列,传入显式 null(空串)用于清空场景由调用方决定,
          // 这里按"传了就写"语义处理。
          payerMemberId: effectivePayer == null
              ? const d.Value.absent()
              : d.Value(effectivePayer),
          aaMode: aaMode == null ? const d.Value.absent() : d.Value(aaMode),
          // 编辑人随本次更新落库;创建人不动(first-write-wins)。
          lastEditedByMemberId: author == null
              ? const d.Value.absent()
              : d.Value(author),
          // 版本号自增 + 最后编辑时间戳;updatedAt 是同步 LWW 依据,必须随编辑前进。
          version: d.Value(newVersion),
          lastEditedAt: d.Value(now),
          updatedAt: d.Value(now),
        ),
      );
      // 指定分摊整批替换(仅当调用方显式传入 splits 时)。
      if (splits != null) {
        await replaceTransactionSplits(db, id, splits);
      }
      // payload 以变更后的完整实体构造(契约:payload 为完整实体 JSON)。
      final updated = await getTransactionById(id);
      if (updated != null) {
        await _recordTxChange(row: updated, action: 'upsert');
      }
      // 返回自增后的版本号:供 UI 层调用 appendEditHistory 时传入,
      // 让 transactions.version 与 record_edit_histories.version 保持一致,
      // 详情页"vN"标签才能正确对应本次编辑。
      return newVersion;
    });
  }

  Future<void> deleteTransaction(String id) async {
    // 删除、清编辑历史与登记 delete 变更同一事务：登记失败回滚，
    // 避免本地已删但云端仍持有投影（与分类/汇率删除登记模式对称）。
    await db.transaction(() async {
      final row = await getTransactionById(id);
      if (row == null) return;
      // 必须在物理删除前登记：ChangeRecorder 需从父交易读取
      // serverRevision 作为 delete 的 CAS 基线，先删行会错把已同步交易当成新建。
      await _recordTxChange(
        row: row.copyWith(updatedAt: DateTime.now().toUtc()),
        action: 'delete',
      );
      // 登记与物理删除仍在同一事务：任一步失败都整体回滚。
      await deleteTransactionsWithEditHistories(db, [id]);
    });
  }

  // ---------------------------------------------------------------
  // 变更登记（data 层端口依赖倒置：实现由 cloud/sync 注入）
  // ---------------------------------------------------------------

  /// 登记单条交易变更：仅云端账本进同步通道（本地账本永不产生同步事件）。
  ///
  /// [row] 为变更后的完整实体行（delete 时传入删除时刻快照），
  /// payload 以该行 + 分摊行构造完整实体 JSON。
  Future<void> _recordTxChange({
    required Transaction row,
    required String action,
  }) async {
    final tracker = trackerGetter?.call();
    if (tracker == null) return;
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(row.ledgerId))).getSingleOrNull();
    if (ledger == null || ledger.storageMode != 'cloud') return;
    final splits = await getTransactionSplits(row.id);
    // member 直写契约（不映射回 user_id/virtual_user_id）。
    final contractSplits = await _toContractSplits(splits);
    await tracker.recordLedgerChange(
      entityType: 'transaction',
      entityId: row.id,
      ledgerId: row.ledgerId,
      action: action,
      payload: transactionPayload(
        row,
        contractSplits,
        payerMemberId: row.payerMemberId,
      ),
      updatedAt: row.updatedAt,
    );
  }

  /// 批量登记交易 upsert 变更：payload 以落库后的完整行构造
  /// （契约要求 payload 为完整实体 JSON，批量插入后反查补齐全字段）。
  ///
  /// 批量插入与本位币重算共用本方法：调用方必须把它放在与数据写入同一个
  /// Drift 事务内，登记失败会随事务整体回滚，避免「本地已改、队列未写」。
  /// 只对 storageMode == 'cloud' 的账本登记；本地账本与记录器未注入时为空操作。
  Future<void> recordBatchTxChanges(Iterable<String> ids) async {
    final tracker = trackerGetter?.call();
    if (tracker == null) return;
    final idList = ids.toList();
    if (idList.isEmpty) return;
    final rows = await (db.select(
      db.transactions,
    )..where((t) => t.id.isIn(idList) & t.deletedAt.isNull())).get();
    if (rows.isEmpty) return;
    // 一次性查出涉及账本的归属，只对云端账本登记（本地账本批量导入不产生同步事件）。
    final ledgerIds = rows.map((r) => r.ledgerId).toSet().toList();
    final ledgers = await (db.select(
      db.ledgers,
    )..where((l) => l.id.isIn(ledgerIds))).get();
    final cloudIds = ledgers
        .where((l) => l.storageMode == 'cloud')
        .map((l) => l.id)
        .toSet();
    final changes = <SyncChangeRecord>[];
    for (final row in rows) {
      if (!cloudIds.contains(row.ledgerId)) continue;
      final splits = await getTransactionSplits(row.id);
      final contractSplits = await _toContractSplits(splits);
      changes.add((
        entityType: 'transaction',
        entityId: row.id,
        ledgerId: row.ledgerId,
        action: 'upsert',
        payload: transactionPayload(
          row,
          contractSplits,
          payerMemberId: row.payerMemberId,
        ),
        updatedAt: row.updatedAt,
      ));
    }
    if (changes.isNotEmpty) {
      await tracker.recordLedgerChanges(changes: changes);
    }
  }

  // ==================== 编辑历史 ====================

  Future<List<RecordEditHistory>> getEditHistories(String recordId) async {
    // 按版本号倒序:最新版本在前,详情区块从新到旧展示
    return (db.select(db.recordEditHistories)
          ..where((t) => t.recordId.equals(recordId))
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.version,
              mode: d.OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<int> appendEditHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  }) async {
    // 追加历史前校验交易仍存在,避免竞态/脏引用把历史写成一个孤儿行。
    final tx = await getTransactionById(recordId);
    if (tx == null) {
      throw StateError('交易不存在，无法追加编辑历史: $recordId');
    }
    return db
        .into(db.recordEditHistories)
        .insert(
          RecordEditHistoriesCompanion.insert(
            recordId: recordId,
            version: version,
            operatorMemberId: d.Value(operatorMemberId),
            summary: summary,
          ),
        );
  }

  Future<Transaction?> getTransactionById(String id) async {
    return await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// 读取交易的指定分摊行(按行 id 稳定排序,供编辑回显与详情展示)。
  Future<List<TransactionSplit>> getTransactionSplits(
    String transactionId,
  ) async {
    return (db.select(db.transactionSplits)
          ..where((t) => t.transactionId.equals(transactionId))
          ..orderBy([
            (t) => d.OrderingTerm(expression: t.id, mode: d.OrderingMode.asc),
          ]))
        .get();
  }

  /// 整批替换指定分摊行:先删后插(与后端 upsert 整批替换语义一致)。
  /// splits 为 null 或空列表时清空该交易全部分摊行。
  Future<void> replaceTransactionSplits(
    SesameDatabase executor,
    String transactionId,
    List<TransactionSplitInput>? splits,
  ) async {
    await (executor.delete(
      executor.transactionSplits,
    )..where((t) => t.transactionId.equals(transactionId))).go();
    final rows = splits ?? const [];
    if (rows.isEmpty) return;
    await executor.batch((b) {
      b.insertAll(
        executor.transactionSplits,
        rows.map(
          (s) => TransactionSplitsCompanion.insert(
            transactionId: transactionId,
            memberId: s.memberId,
            amount: s.amount,
          ),
        ),
      );
    });
  }

  /// 整批替换分摊行，并把最终分摊作为父交易快照登记。
  ///
  /// 同步 pull/add/update 继续使用上方无登记的底层方法，避免回放云端
  /// 数据时反向生成 mutation；只有公开的独立分摊编辑走此入口。
  Future<void> replaceTransactionSplitsAndRecord(
    String transactionId,
    List<TransactionSplitInput>? splits,
  ) async {
    await db.transaction(() async {
      final existing = await getTransactionById(transactionId);
      if (existing == null) {
        throw StateError('交易不存在，无法替换分摊: $transactionId');
      }
      await replaceTransactionSplits(db, transactionId, splits);
      final now = DateTime.now().toUtc();
      await (db.update(db.transactions)
            ..where((transaction) => transaction.id.equals(transactionId)))
          .write(TransactionsCompanion(updatedAt: d.Value(now)));
      final updated = await getTransactionById(transactionId);
      if (updated == null) {
        throw StateError('交易分摊替换失败，请重试: $transactionId');
      }
      await _recordTxChange(row: updated, action: 'upsert');
    });
  }

  /// 单条插入交易 Companion,返回落库使用的 UUID 主键。
  Future<String> insertTransactionCompanion(
    TransactionsCompanion item, {
    bool recordChanges = true,
  }) async {
    // Value<String> 的 value 为非空 String,absent 状态要用 present 判断。
    final effective = !item.id.present
        ? item.copyWith(id: d.Value(_uuid.v4()))
        : item;
    // 插入与变更登记同一事务:登记失败整体回滚。
    await db.transaction(() async {
      await db.into(db.transactions).insert(effective);
      if (recordChanges) {
        await recordBatchTxChanges([effective.id.value]);
      }
    });
    return effective.id.value;
  }

  Future<List<({Transaction t, Category? category})>>
  transactionsWithCategoryAll({String? ledgerId}) async {
    final select = db.select(db.transactions)
      ..where((t) => t.deletedAt.isNull());
    if (ledgerId != null) {
      select.where((t) => t.ledgerId.equals(ledgerId));
    }
    select.orderBy([
      (t) =>
          d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
    ]);
    final rows = await select.join(_txJoins()).get();
    final out = rows
        .map(
          (r) => (
            t: r.readTable(db.transactions),
            category: r.readTableOrNull(db.categories),
          ),
        )
        .toList();
    return _hydrateSharedOverrides(out);
  }

  Future<List<({Transaction t, Category? category})>>
  getRecentTransactionsWithCategory({
    required String ledgerId,
    required int limit,
  }) async {
    final q =
        (db.select(db.transactions)
              ..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.desc,
                ),
              ])
              ..limit(limit))
            .join(_txJoins());
    final rows = await q.get();
    final out = rows
        .map(
          (r) => (
            t: r.readTable(db.transactions),
            category: r.readTableOrNull(db.categories),
          ),
        )
        .toList();
    return _hydrateSharedOverrides(out);
  }

  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM transactions WHERE ledger_id = ?1 AND tx_type = ?2 AND happened_at >= ?3 AND happened_at < ?4 AND deleted_at IS NULL',
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(type),
            d.Variable.withDateTime(start),
            d.Variable.withDateTime(end),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    final v = row.data['c'];
    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    if (v is num) return v.toInt();
    return 0;
  }

  Future<List<Transaction>> getTransactionsByLedger(String ledgerId) async {
    return await (db.select(db.transactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Transaction>> getAaTransactionsByLedger(String ledgerId) async {
    // AA 分摊统计:过滤出 aaMode != 1 的交易。
    // aaMode=null/0(人均)和 aaMode=2(指定)都纳入;"不分摊"(aaMode=1)跳过。
    // 用 isNull() | isNotValue(1) 兼容 null 和非 1 两种"参与分摊"的情况。
    return await (db.select(db.transactions)
          ..where(
            (t) =>
                t.ledgerId.equals(ledgerId) &
                t.deletedAt.isNull() &
                (t.aaMode.isNull() | t.aaMode.isNotValue(1)),
          )
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<List<Transaction>> getTransactionsByLedgerInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) async {
    return await (db.select(db.transactions)
          ..where(
            (t) =>
                t.ledgerId.equals(ledgerId) &
                t.deletedAt.isNull() &
                t.happenedAt.isBiggerOrEqualValue(start) &
                t.happenedAt.isSmallerThanValue(end),
          )
          ..orderBy([
            (t) => d.OrderingTerm(
              expression: t.happenedAt,
              mode: d.OrderingMode.desc,
            ),
          ]))
        .get();
  }

  /// 跨账本移动交易（保留原 UUID）。
  ///
  /// 限制：服务端禁止同一 UUID 跨账本 upsert（ENTITY_SCOPE_CONFLICT），
  /// 云账本上此移动会被 push 拒绝且 pull 回放还原；当前无 UI 调用方。
  Future<void> updateTransactionLedger({
    required String id,
    required String ledgerId,
    required String currencyCode,
    required String nativeAmount,
  }) async {
    await db.transaction(() async {
      final existing = await getTransactionById(id);
      if (existing == null) {
        throw StateError('交易不存在，无法移动: $id');
      }
      final targetLedger = await (db.select(
        db.ledgers,
      )..where((ledger) => ledger.id.equals(ledgerId))).getSingleOrNull();
      if (targetLedger == null) {
        throw StateError('目标账本不存在，无法移动交易: $ledgerId');
      }
      final now = DateTime.now().toUtc();
      if (existing.ledgerId != ledgerId) {
        // 旧云账本先登记 delete，新云账本再登记 upsert；
        // 本地账本会被 _recordTxChange 自动跳过，因此四种组合共用一条路径。
        await _recordTxChange(
          row: existing.copyWith(updatedAt: now),
          action: 'delete',
        );
      }
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          ledgerId: d.Value(ledgerId),
          currencyCode: d.Value(currencyCode),
          nativeAmount: d.Value(nativeAmount),
          updatedAt: d.Value(now),
        ),
      );
      final moved = await getTransactionById(id);
      if (moved == null) {
        throw StateError('交易移动失败，请重试: $id');
      }
      await _recordTxChange(row: moved, action: 'upsert');
    });
  }

  // ==================== 日历功能相关 ====================

  /// 日历「单日合计」:金额已存为规范化 decimal 字符串,SQL 无法 SUM TEXT 列,
  /// 读取当月交易后 Dart 层 Decimal 累加(与统计路径同一精度策略)。
  Future<Map<String, double>> getDailyTotalsByMonth({
    required String ledgerId,
    required DateTime month,
  }) async {
    final startDate = DateTime(month.year, month.month, 1);
    // 半开区间 [月初, 下月1日):避免 23:59:59 边界漏掉带毫秒的交易。
    final endDate = DateTime(month.year, month.month + 1, 1);

    final rows =
        await (db.select(db.transactions)..where(
              (t) =>
                  t.ledgerId.equals(ledgerId) &
                  t.deletedAt.isNull() &
                  t.happenedAt.isBiggerOrEqualValue(startDate) &
                  t.happenedAt.isSmallerThanValue(endDate),
            ))
            .get();

    // 全局仅支出模式:Dart 层只聚合"支出且未被排除"的交易,按本地日期分组。
    // 折算快照优先,缺失才回退原币金额(契约:本位币交易二者相等)。
    final totals = <String, Decimal>{};
    for (final t in rows) {
      if (t.txType != 'expense' || t.excludeFromStats) continue;
      final v = Decimal.tryParse(t.nativeAmount) ?? Decimal.tryParse(t.amount);
      if (v == null) continue;
      final day = DateFormat('yyyy-MM-dd').format(t.happenedAt.toLocal());
      totals[day] = (totals[day] ?? Decimal.zero) + v;
    }

    // 按日期倒序(date DESC)返回,方便调用方直接取最近日期。
    final days = totals.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final day in days) day: totals[day]!.toDouble()};
  }

  // 返回单日交易及其关联分类
  Future<List<({Transaction t, Category? category})>> getTransactionsByDate({
    required String ledgerId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    // 半开区间 [当天0点, 次日0点):包含 23:59:59.xxx 的毫秒交易。
    final endOfDay = DateTime(date.year, date.month, date.day + 1);

    // 查询当天的所有交易
    final transactions =
        await (db.select(db.transactions)
              ..where(
                (t) =>
                    t.ledgerId.equals(ledgerId) &
                    t.deletedAt.isNull() &
                    t.happenedAt.isBiggerOrEqualValue(startOfDay) &
                    t.happenedAt.isSmallerThanValue(endOfDay),
              )
              ..orderBy([
                (t) => d.OrderingTerm(
                  expression: t.happenedAt,
                  mode: d.OrderingMode.desc,
                ),
              ]))
            .get();

    if (transactions.isEmpty) return [];

    // 批量查询分类
    final categoryIds = transactions
        .map((t) => t.categoryId)
        .whereType<String>()
        .toSet();
    final categoriesMap = <String, Category>{};
    if (categoryIds.isNotEmpty) {
      final cats =
          await (db.select(db.categories)..where(
                (category) =>
                    category.id.isIn(categoryIds) & category.deletedAt.isNull(),
              ))
              .get();
      for (final c in cats) {
        categoriesMap[c.id] = c;
      }
    }

    // 组装结果:分类反查不到时为 null,后续走共享账本镜像 hydration 兜底。
    // 用局部变量承接 categoryId 是为了 null 提升,避免对记录/字段直接断言。
    final raw = <({Transaction t, Category? category})>[];
    for (final tx in transactions) {
      final cid = tx.categoryId;
      raw.add((t: tx, category: cid == null ? null : categoriesMap[cid]));
    }
    // 共享账本 category hydration(与 watch 路径同一实现,回填共享镜像分类)
    return _hydrateSharedOverrides(raw);
  }

  /// 3.7：分摊行直接以 member_id 表达（服务端 3.5 起 member 直写契约）。
  Future<List<ContractSplit>> _toContractSplits(
    List<TransactionSplit> splits,
  ) async {
    if (splits.isEmpty) return const [];
    return [for (final s in splits) (memberId: s.memberId, amount: s.amount)];
  }
}

/// 契约形状的分摊行：member_id 直传（不映射回 user/virtual）。
typedef ContractSplit = ({String memberId, String amount});

/// 构造契约形状的 transaction payload（snake_case 键，与 push 侧生成模型
/// wire name 对齐，保证 SyncService.push 反序列化即消费成功）。
///
/// aa_mode 为契约枚举（wire 名 "0"/"1"/"2"），用字符串承载；
/// 时间统一 UTC ISO8601；splits 为契约 TransactionSplit 内嵌数组。
String transactionPayload(
  Transaction t,
  List<ContractSplit> splits, {
  String? payerMemberId,
}) {
  // member 直写契约（payer_member_id / splits[].member_id）；
  // revision 由服务端 CAS 维护，payload 不携带版本字段
  return jsonEncode({
    'tx_type': t.txType,
    'amount': t.amount,
    'happened_at': t.happenedAt.toUtc().toIso8601String(),
    'note': t.note,
    'category_id': t.categoryId,
    'exclude_from_stats': t.excludeFromStats,
    'currency_code': t.currencyCode,
    'native_amount': t.nativeAmount,
    'recurring_id': t.recurringId,
    'created_by_member_id': t.createdByMemberId,
    'last_edited_by_member_id': t.lastEditedByMemberId,
    'payer_member_id': payerMemberId,
    'aa_mode': t.aaMode?.toString(),
    'splits': [
      for (final s in splits) {'member_id': s.memberId, 'amount': s.amount},
    ],
    'last_edited_at': t.lastEditedAt?.toUtc().toIso8601String(),
  });
}
