import 'package:sesame_notes/data/repositories/contracts/currency_transaction_repository.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/expense_type.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/data/repositories/support/ledger_lookup.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

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
  // 周期来源的墓碑是去重事实；清空和单笔删除都不能释放发生身份。
  final now = DateTime.now().toUtc();
  final tombstoned =
      await (db.update(db.transactions)..where(
            (t) =>
                t.id.isIn(ids) &
                t.recurringId.isNotNull() &
                t.deletedAt.isNull(),
          ))
          .write(
            TransactionsCompanion(
              deletedAt: d.Value(now),
              updatedAt: d.Value(now),
            ),
          );
  final removed = await (db.delete(
    db.transactions,
  )..where((t) => t.id.isIn(ids) & t.recurringId.isNull())).go();
  return tombstoned + removed;
}

/// 本地交易Repository实现
/// 基于 Drift 数据库实现
class LocalTransactionRepository implements CurrencyTransactionRepository {
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

  /// 供 watch 流使用的每月起始日读取：读取异常时按自然月降级。
  ///
  /// 这里必须兜住异常——结果要喂给 Stream.fromFuture，抛错会让整条 watch 流
  /// 停在 error 态（账本行不存在的情况已由 [ledgerMonthStartDay] 内部降级并
  /// 留痕，此处只兜真正的基础设施故障）。
  Future<int> _monthStartDayForStream(String ledgerId) async {
    try {
      return await ledgerMonthStartDay(db, ledgerId);
    } catch (error, stackTrace) {
      logger.warning(
        'TransactionWatch',
        '读取账本每月起始日失败，本月视图按自然月降级',
        '$error\n$stackTrace',
      );
      return 1;
    }
  }

  Stream<List<Transaction>> watchTransactionsInMonth({
    required String ledgerId,
    required DateTime month,
  }) {
    return Stream.fromFuture(_monthStartDayForStream(ledgerId)).asyncExpand((
      sd,
    ) {
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

  /// 监听交易与该账本真实分类域，展示不会混用其他所有者的同 ID 分类。
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
    return _watchTransactionsWithCategories(select);
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
    return _watchTransactionsWithCategories(select);
  }

  /// 交易、分类目录和账本归属变化共用同一个解析出口，较旧的异步结果不能覆盖新状态。
  Stream<List<({Transaction t, Category? category})>>
  _watchTransactionsWithCategories(d.Selectable<Transaction> query) {
    late StreamController<List<({Transaction t, Category? category})>> ctrl;
    StreamSubscription? txSub;
    StreamSubscription? categorySub;
    List<Transaction>? lastRows;
    var generation = 0;

    /// 每次读取精确账本目录，解析失败通过流返回并保留完整诊断。
    Future<void> rehydrate() async {
      if (lastRows == null) return;
      final currentGeneration = ++generation;
      try {
        final hydrated = await readTransactionCategories(db, lastRows!);
        if (!ctrl.isClosed && currentGeneration == generation) {
          ctrl.add(hydrated);
        }
      } catch (error, stackTrace) {
        logger.error('TransactionWatch', '读取交易所属分类失败', error, stackTrace);
        if (!ctrl.isClosed && currentGeneration == generation) {
          ctrl.addError(error, stackTrace);
        }
      }
    }

    ctrl = StreamController<List<({Transaction t, Category? category})>>(
      onListen: () {
        txSub = query.watch().listen((rows) {
          lastRows = rows;
          rehydrate();
        }, onError: ctrl.addError);
        categorySub = db
            .tableUpdates(
              d.TableUpdateQuery.onAllTables([
                db.categories,
                db.sharedLedgerCategories,
                db.ledgers,
              ]),
            )
            .listen((_) => rehydrate());
      },
      onCancel: () async {
        await txSub?.cancel();
        generation++;
        await categorySub?.cancel();
      },
    );
    return ctrl.stream;
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInMonth({
    required String ledgerId,
    required DateTime month,
  }) {
    return Stream.fromFuture(_monthStartDayForStream(ledgerId)).asyncExpand((
      sd,
    ) {
      final range = periodForLabel(month.year, month.month, sd);
      final q = (db.select(db.transactions)
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
        ]));
      return _watchTransactionsWithCategories(q);
    });
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInYear({
    required String ledgerId,
    required int year,
  }) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final q = (db.select(db.transactions)
      ..where(
        (t) =>
            t.ledgerId.equals(ledgerId) &
            t.deletedAt.isNull() &
            t.happenedAt.isBiggerOrEqualValue(start) &
            t.happenedAt.isSmallerThanValue(end),
      )
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
      ]));
    return _watchTransactionsWithCategories(q);
  }

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsForCategoryInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
    String? categoryId,
    required String type,
  }) {
    final base = (db.select(db.transactions)
      ..where(
        (t) =>
            t.ledgerId.equals(ledgerId) &
            t.deletedAt.isNull() &
            t.txType.equals(type) &
            t.happenedAt.isBiggerOrEqualValue(start) &
            t.happenedAt.isSmallerThanValue(end),
      )
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
      ]));
    if (categoryId == null) {
      base.where((row) => row.categoryId.isNull());
    } else {
      base.where((row) => row.categoryId.equals(categoryId));
    }
    return _watchTransactionsWithCategories(base);
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
    String? currencyCode,
    String? nativeAmount,
    // AA 分摊字段:由调用方显式传入,子仓收"已定值"直写
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
    String? recurringId,
    String? occurrenceDate,
    String? transactionId,
  }) async {
    requireExpenseType(type);
    // 子仓收「已定值」直写;带折算的兜底(查汇率)在聚合
    // LocalRepository 包装层(子仓拿不到汇率)。
    final id = transactionId ?? _uuid.v4();
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
              // 契约必填列:未折算时按本位币语义兜底(币种 CNY、快照=原币金额)。
              currencyCode: currencyCode ?? 'CNY',
              nativeAmount: nativeAmount ?? amount,
              recurringId: d.Value(recurringId),
              occurrenceDate: d.Value(occurrenceDate),
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
      requireExpenseType(item.txType.value);
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
      requireExpenseType(tx.txType.value);
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
  /// 版本读取和递增与内容更新共用同一事务，并发编辑按提交顺序分配版本。
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
    String? currencyCode,
    String? nativeAmount,
    // AA 分摊字段:null = 不更新保持原值;splits 非 null 时整批替换关系表
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    requireExpenseType(type);
    // 更新、分摊替换与变更登记同一事务:登记失败整体回滚。
    return db.transaction(() async {
      final existing = await getTransactionById(id);
      if (existing == null) {
        throw StateError('交易不存在，无法更新: $id');
      }
      final newVersion = existing.version + 1;
      final now = DateTime.now().toUtc();
      final author = (operatorMemberId?.isNotEmpty ?? false)
          ? operatorMemberId
          : null;
      // 支出人随当前事务中的最新行决定，迟到编辑不能覆盖已经确定的成员。
      final effectivePayer =
          payerMemberId ??
          ((existing.payerMemberId?.isNotEmpty ?? false) ? null : author);
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          txType: d.Value(type),
          amount: d.Value(amount),
          categoryId: d.Value(categoryId),
          note: d.Value(note),
          happenedAt: happenedAt != null
              ? d.Value(happenedAt)
              : const d.Value.absent(),
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
    // 分摊成员 id 直接写入契约的 member_id。
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
  @override
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

  @override
  Future<Transaction?> getTransactionById(String id) async {
    return await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  /// 读取交易的指定分摊行(按行 id 稳定排序,供编辑回显与详情展示)。
  @override
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

  /// 使用有界 IN 查询分批读取关系行，兼容 SQLite 参数数量上限并保持同一读事务。
  Future<Map<String, List<TransactionSplit>>>
  getTransactionSplitsByTransactionIds(Iterable<String> transactionIds) async {
    try {
      final ids = transactionIds.toSet().toList(growable: false);
      if (ids.isEmpty) return const {};
      return await db.transaction(() async {
        final result = <String, List<TransactionSplit>>{};
        const batchSize = 500;
        for (var offset = 0; offset < ids.length; offset += batchSize) {
          final end = (offset + batchSize).clamp(0, ids.length);
          final rows =
              await (db.select(db.transactionSplits)
                    ..where(
                      (row) => row.transactionId.isIn(ids.sublist(offset, end)),
                    )
                    ..orderBy([(row) => d.OrderingTerm(expression: row.id)]))
                  .get();
          for (final row in rows) {
            (result[row.transactionId] ??= []).add(row);
          }
        }
        return result;
      });
    } catch (error, stackTrace) {
      logger.error('TransactionRepository', '批量读取分摊关系失败', error, stackTrace);
      rethrow;
    }
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
    final rows = await select.get();
    return readTransactionCategories(db, rows);
  }

  Future<List<({Transaction t, Category? category})>>
  getRecentTransactionsWithCategory({
    required String ledgerId,
    required int limit,
  }) async {
    final q = (db.select(db.transactions)
      ..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())
      ..orderBy([
        (t) =>
            d.OrderingTerm(expression: t.happenedAt, mode: d.OrderingMode.desc),
      ])
      ..limit(limit));
    final rows = await q.get();
    return readTransactionCategories(db, rows);
  }

  /// 统计区间内参与收支分析的交易笔数，排除已删除的记录。
  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final row = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM transactions '
            'WHERE ledger_id = ?1 AND tx_type = ?2 '
            'AND happened_at >= ?3 AND happened_at < ?4 '
            'AND deleted_at IS NULL',
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
    } catch (error, stackTrace) {
      logger.error(
        'LocalTransactionRepository',
        '读取统计笔数失败 type=$type '
            'start=${start.toIso8601String()} end=${end.toIso8601String()}',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
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
  @override
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

  /// 日历单日合计读取当月交易，以 Decimal 累加十进制文本，避免浮点转换损失精度。
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
      if (t.txType != 'expense') continue;
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

    return readTransactionCategories(db, transactions);
  }

  /// 分摊行直接以成员身份和金额表达。
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
    'currency_code': t.currencyCode,
    'native_amount': t.nativeAmount,
    'recurring_id': t.recurringId,
    'occurrence_date': t.occurrenceDate,
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
