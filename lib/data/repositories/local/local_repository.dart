import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'local_ledger_repository.dart';
import 'local_transaction_repository.dart';
import 'local_category_repository.dart';
import 'local_statistics_repository.dart';
import 'local_recurring_transaction_repository.dart';
import 'local_exchange_rate_repository.dart';
import 'local_member_repository.dart';

/// 本地数据库仓库：聚合各子仓库查询。
///
/// 变更登记由子仓储在写事务内完成，本层只负责转发与跨仓储编排。
class LocalRepository {
  /// 底层数据库实例
  final SesameDatabase db;

  /// 可选的变更追踪器（供子仓储写路径登记同步变更）。
  ChangeRecorder? changeTracker;

  /// 当前云账号 userId（null = 未登录本地域），用于同步实体账号域与
  /// 确定性主键，确保账号切换时可完整清理当前账号数据。
  final String? Function()? accountIdGetter;

  // 子 Repository 实例
  late final LocalLedgerRepository _ledgerRepo;
  late final LocalTransactionRepository _transactionRepo;
  late final LocalCategoryRepository _categoryRepo;
  late final LocalStatisticsRepository _statisticsRepo;
  late final LocalRecurringTransactionRepository _recurringTransactionRepo;
  late final LocalExchangeRateRepository _exchangeRateRepo;
  late final LocalLedgerMemberRepository _memberRepo;

  /// 在同一 Drift 事务内执行一组必须原子提交的仓储操作。
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      db.transaction(action);

  LocalRepository(this.db, {this.changeTracker, this.accountIdGetter}) {
    _ledgerRepo = LocalLedgerRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    _transactionRepo = LocalTransactionRepository(
      db,
      trackerGetter: () => changeTracker,
    );
    _categoryRepo = LocalCategoryRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    _statisticsRepo = LocalStatisticsRepository(db);
    _recurringTransactionRepo = LocalRecurringTransactionRepository(
      db,
      trackerGetter: () => changeTracker,
    );
    _exchangeRateRepo = LocalExchangeRateRepository(
      db,
      trackerGetter: () => changeTracker,
      accountIdGetter: accountIdGetter,
    );
    _memberRepo = LocalLedgerMemberRepository(
      db,
      trackerGetter: () => changeTracker,
    );
  }

  /// 最外层委托统一守卫：捕获并记录仓储异常后原样上抛。
  Future<T> _guard<T>(String operation, Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, st) {
      logger.error('LocalRepository', '$operation 失败', e, st);
      rethrow;
    }
  }

  // ============================================
  // 账本 - 委托给 LocalLedgerRepository
  // ============================================

  Stream<List<Ledger>> watchLedgers() => _ledgerRepo.watchLedgers();

  Stream<Ledger?> watchLedger(String id) => _ledgerRepo.watchLedger(id);

  Future<List<Ledger>> getAllLedgers() => _ledgerRepo.getAllLedgers();

  Future<Ledger?> getLedgerById(String id) => _ledgerRepo.getLedgerById(id);

  Future<({int dayCount, int txCount})> getCountsForLedger({
    required String ledgerId,
  }) => _ledgerRepo.getCountsForLedger(ledgerId: ledgerId);

  Future<({double expenseTotal, int transactionCount})> getLedgerStats({
    required String ledgerId,
    List<Transaction>? transactions,
  }) => _ledgerRepo.getLedgerStats(
    ledgerId: ledgerId,
    transactions: transactions,
  );

  Future<Map<String, ({double expenseTotal, int transactionCount})>>
  getAllLedgerStats() => _ledgerRepo.getAllLedgerStats();

  Future<String> createLedger({
    required String name,
    String currency = 'CNY',
    String storageMode = 'cloud',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? localSelfId,
  }) => _ledgerRepo.createLedger(
    name: name,
    currency: currency,
    storageMode: storageMode,
    aaEnabled: aaEnabled,
    monthStartDay: monthStartDay,
    localSelfId: localSelfId,
  );

  Future<void> createBoundLedger({
    required String id,
    required String name,
    String currency = 'CNY',
    bool aaEnabled = false,
    int monthStartDay = 1,
    String? syncId,
  }) => _ledgerRepo.createBoundLedger(
    id: id,
    name: name,
    currency: currency,
    aaEnabled: aaEnabled,
    monthStartDay: monthStartDay,
    syncId: syncId,
  );

  Future<void> updateLedgerSyncId({
    required String id,
    required String syncId,
  }) => _ledgerRepo.updateLedgerSyncId(id: id, syncId: syncId);

  Future<void> updateLedgerStorageMode({
    required String id,
    required String storageMode,
  }) => _ledgerRepo.updateLedgerStorageMode(id: id, storageMode: storageMode);

  Future<void> detachFromCloud(String id) => _ledgerRepo.detachFromCloud(id);

  /// 本地状态保护 Fork（见 [LocalLedgerRepository.protectCloudLedgerToLocalFork]）。
  Future<String> protectCloudLedgerToLocalFork({
    required String sourceLedgerId,
    required String targetLedgerId,
    required String localSelfId,
    String? currentAccountId,
  }) => _ledgerRepo.protectCloudLedgerToLocalFork(
    sourceLedgerId: sourceLedgerId,
    targetLedgerId: targetLedgerId,
    localSelfId: localSelfId,
    currentAccountId: currentAccountId,
  );

  /// 云转本地移动的隐藏 Fork（见 [LocalLedgerRepository.forkCloudLedgerToLocalPendingMove]）。
  Future<String> forkCloudLedgerToLocalPendingMove({
    required String sourceLedgerId,
    required String newLedgerId,
    required String localSelfId,
    required String currentAccountId,
    String? originSyncId,
  }) => _ledgerRepo.forkCloudLedgerToLocalPendingMove(
    sourceLedgerId: sourceLedgerId,
    newLedgerId: newLedgerId,
    localSelfId: localSelfId,
    currentAccountId: currentAccountId,
    originSyncId: originSyncId,
  );

  /// 读取待发布的隐藏 Fork（云转本地 intent 恢复扫描用）。
  Future<List<Ledger>> getPendingLocalMoveForks() =>
      _ledgerRepo.getPendingLocalMoveForks();

  Future<void> copyLedgerData({
    required String sourceLedgerId,
    required String targetLedgerId,
  }) => _guard(
    'copyLedgerData',
    () => _ledgerRepo.copyLedgerData(
      sourceLedgerId: sourceLedgerId,
      targetLedgerId: targetLedgerId,
    ),
  );

  /// 更新账本元数据；[recordChanges] 为 false 时不登记同步变更
  /// （恢复导入等数据回填路径用，禁止备份元数据反向推云）。
  Future<void> updateLedger({
    required String id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    bool recordChanges = true,
  }) => _ledgerRepo.updateLedger(
    id: id,
    name: name,
    currency: currency,
    monthStartDay: monthStartDay,
    aaEnabled: aaEnabled,
    recordChanges: recordChanges,
  );

  /// 删除账本；云账本由子仓储保留 tombstone 与最终 delete mutation。
  Future<void> deleteLedger(String id) =>
      _guard('deleteLedger($id)', () => _ledgerRepo.deleteLedger(id));

  /// 退出登录 purge：整本清除全部云端账本（见 [LocalLedgerRepository.purgeAllCloudLedgers]）。
  Future<void> purgeAllCloudLedgers() => _ledgerRepo.purgeAllCloudLedgers();

  /// 单账本 purge：清除一本账本及其全部关联本地数据
  /// （见 [LocalLedgerRepository.purgeLedger]，退出/删除共享账本用）。
  Future<void> purgeLedger(String id) =>
      _guard('purgeLedger($id)', () => _ledgerRepo.purgeLedger(id));

  /// 清空账本交易，并复用单笔删除入口保证云账本逐笔登记 delete mutation。
  Future<int> clearLedgerTransactions(String ledgerId) => _guard(
    'clearLedgerTransactions($ledgerId)',
    () => db.transaction(() async {
      final ids =
          (await (db.select(db.transactions)..where(
                    (t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull(),
                  ))
                  .get())
              .map((t) => t.id);
      return _deleteTransactionsByIds(ids);
    }),
  );

  // ============================================
  // 交易 - 委托给 LocalTransactionRepository
  // ============================================

  Stream<List<Transaction>> watchRecentTransactions({
    required String ledgerId,
    int limit = 20,
  }) => _transactionRepo.watchRecentTransactions(
    ledgerId: ledgerId,
    limit: limit,
  );

  Stream<List<Transaction>> watchTransactionsInMonth({
    required String ledgerId,
    required DateTime month,
  }) => _transactionRepo.watchTransactionsInMonth(
    ledgerId: ledgerId,
    month: month,
  );

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryAll({String? ledgerId}) =>
      _transactionRepo.watchTransactionsWithCategoryAll(ledgerId: ledgerId);

  Stream<List<({Transaction t, Category? category})>>
  watchExcludedAaTransactions(String ledgerId) =>
      _transactionRepo.watchExcludedAaTransactions(ledgerId);

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInMonth({
    required String ledgerId,
    required DateTime month,
  }) => _transactionRepo.watchTransactionsWithCategoryInMonth(
    ledgerId: ledgerId,
    month: month,
  );

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsWithCategoryInYear({
    required String ledgerId,
    required int year,
  }) => _transactionRepo.watchTransactionsWithCategoryInYear(
    ledgerId: ledgerId,
    year: year,
  );

  Stream<List<({Transaction t, Category? category})>>
  watchTransactionsForCategoryInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
    String? categoryId,
    required String type,
  }) => _transactionRepo.watchTransactionsForCategoryInRange(
    ledgerId: ledgerId,
    start: start,
    end: end,
    categoryId: categoryId,
    type: type,
  );

  /// 新增交易（金额为规范化 Decimal 字符串）。
  ///
  /// 币种折算兜底：未传 currencyCode/nativeAmount 时按账本本位币补齐
  /// （外币取有效汇率折算，取不到时 native=amount 交由未折算检测捞回）。
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
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    final (cc, na) = await _resolveTxCurrency(
      ledgerId: ledgerId,
      amount: amount,
      currencyCode: currencyCode,
      nativeAmount: nativeAmount,
    );
    return _transactionRepo.addTransaction(
      ledgerId: ledgerId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      happenedAt: happenedAt,
      note: note,
      excludeFromStats: excludeFromStats,
      currencyCode: cc,
      nativeAmount: na,
      payerMemberId: payerMemberId,
      aaMode: aaMode,
      splits: _normalizeSplitsForWrite(splits, amount, na, payerMemberId),
      operatorMemberId: operatorMemberId,
    );
  }

  Future<int> insertTransactionsBatch(
    List<TransactionsCompanion> items, {
    bool recordChanges = true,
  }) => _transactionRepo.insertTransactionsBatch(
    items,
    recordChanges: recordChanges,
  );

  /// 更新交易；返回编辑后版本号（UI 写编辑历史用）。
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
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) async {
    final old = await _transactionRepo.getTransactionById(id);
    if (old == null) {
      throw StateError('交易不存在，无法更新: $id');
    }
    // 联动兜底：调用方不传两字段时，按隐含汇率缩放或沿用旧值。
    var effCurrency = currencyCode;
    var effNative = nativeAmount;
    // 两字段都缺省时，仅当交易币种就是账本本位币才带入旧币种走下方缩放：
    // 本位币交易 nativeAmount 恒等于 amount，金额变化后快照必须跟随新值，
    // 否则汇总永远停留在旧金额；外币交易则保持快照列不动——本地层不得发明
    // 调用方未请求的汇率换算（编辑器、AA 工具等真实调用方总是显式传两字段）。
    if (effCurrency == null && effNative == null) {
      final ledger = await getLedgerById(old.ledgerId);
      final base = (ledger?.currency.isNotEmpty ?? false)
          ? ledger!.currency.toUpperCase()
          : 'CNY';
      if (old.currencyCode.toUpperCase() == base) {
        effCurrency = old.currencyCode;
      }
    }
    if (effCurrency != null && effNative == null) {
      final oldNative = old.nativeAmount;
      if (oldNative.isNotEmpty &&
          old.currencyCode.toUpperCase() == effCurrency.toUpperCase() &&
          old.amount == amount) {
        effNative = oldNative;
      } else if (oldNative.isNotEmpty && amount != old.amount) {
        // 按隐含汇率缩放：native_new = native_old × amount_new / amount_old
        final oldA = Decimal.tryParse(old.amount);
        final newA = Decimal.tryParse(amount);
        final oldN = Decimal.tryParse(oldNative);
        if (oldA != null &&
            newA != null &&
            oldN != null &&
            oldA != Decimal.zero) {
          // Decimal / Decimal 返回 Rational，先 toDecimal 再规范化。
          effNative = normalizeDecimal(
            (oldN * newA / oldA).toDecimal(),
            scale: 10,
          );
        } else {
          effNative = amount;
        }
      } else {
        effNative = amount;
      }
    } else if (effCurrency == null && effNative != null) {
      effCurrency = old.currencyCode;
    }
    return _transactionRepo.updateTransaction(
      id: id,
      type: type,
      amount: amount,
      categoryId: categoryId,
      note: note,
      happenedAt: happenedAt,
      excludeFromStats: excludeFromStats,
      currencyCode: effCurrency,
      nativeAmount: effNative,
      payerMemberId: payerMemberId,
      aaMode: aaMode,
      splits: effNative == null
          ? splits
          : _normalizeSplitsForWrite(splits, amount, effNative, payerMemberId),
      operatorMemberId: operatorMemberId,
    );
  }

  Future<void> deleteTransaction(String id) =>
      _transactionRepo.deleteTransaction(id);

  /// 在当前外层事务中逐笔调用交易删除入口，复用其历史清理与云 mutation 契约。
  Future<int> _deleteTransactionsByIds(Iterable<String> ids) async {
    final idList = ids.toSet().toList();
    if (idList.isEmpty) return 0;
    final rows = await (db.select(
      db.transactions,
    )..where((t) => t.id.isIn(idList) & t.deletedAt.isNull())).get();
    await _ensureCloudChangesCanBeRecorded(rows);
    for (final row in rows) {
      // 单笔入口把快照登记、交易删除和编辑历史清理置于同一 Drift 事务；
      // 外层事务再保证批量操作不会因中途登记失败而只删掉一部分。
      await _transactionRepo.deleteTransaction(row.id);
    }
    return rows.length;
  }

  /// 云交易若缺少记录器必须中止，避免本地已改而远端永远收不到 mutation。
  Future<void> _ensureCloudChangesCanBeRecorded(
    Iterable<Transaction> rows,
  ) async {
    if (changeTracker != null) return;
    final ledgerIds = rows.map((row) => row.ledgerId).toSet().toList();
    if (ledgerIds.isEmpty) return;
    final cloudLedger =
        await (db.select(db.ledgers)
              ..where(
                (ledger) =>
                    ledger.id.isIn(ledgerIds) &
                    ledger.storageMode.equals('cloud'),
              )
              ..limit(1))
            .getSingleOrNull();
    if (cloudLedger != null) {
      throw StateError('云账本暂时无法登记同步变更，请稍后重试');
    }
  }

  // ==================== 编辑历史 ====================

  Future<List<RecordEditHistory>> getEditHistories(String recordId) =>
      _transactionRepo.getEditHistories(recordId);

  Future<int> appendEditHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  }) => _transactionRepo.appendEditHistory(
    recordId: recordId,
    version: version,
    operatorMemberId: operatorMemberId,
    summary: summary,
  );

  Future<Transaction?> getTransactionById(String id) =>
      _transactionRepo.getTransactionById(id);

  /// 读取交易的指定分摊行(关系表,aa_mode=2 时落行)。
  Future<List<TransactionSplit>> getTransactionSplits(String transactionId) =>
      _transactionRepo.getTransactionSplits(transactionId);

  /// 整批替换交易的指定分摊行(先删后插;null/空列表即清空)。
  Future<void> replaceTransactionSplits(
    String transactionId,
    List<TransactionSplitInput>? splits,
  ) => _guard(
    'replaceTransactionSplits transaction=$transactionId',
    () => _transactionRepo.replaceTransactionSplitsAndRecord(
      transactionId,
      splits,
    ),
  );

  // ---------------------------------------------------------------------
  // 折算兜底 + 重算/检测
  // ---------------------------------------------------------------------

  /// 以 [base] 为本位币合成有效汇率（手动 > 最新自动）。
  Future<Map<String, EffectiveRate>> _effectiveRatesFor(String base) async {
    final autos = await getLatestAutoRates(base);
    final overrides = await getOverrides(base);
    return mergeEffectiveRates(
      autoRates: [
        for (final r in autos)
          (quote: r.quoteCurrency, rate: r.rate, rateDate: r.rateDate),
      ],
      overrides: [
        for (final o in overrides) (quote: o.quoteCurrency, rate: o.rate),
      ],
    );
  }

  /// 兜底解析 (currencyCode, nativeAmount)：币种默认账本本位币；
  /// 外币按有效汇率折算，取不到则 native=amount（未折算检测可捞回）。
  Future<(String, String)> _resolveTxCurrency({
    required String ledgerId,
    required String amount,
    String? currencyCode,
    String? nativeAmount,
  }) async {
    if (currencyCode != null &&
        currencyCode.isNotEmpty &&
        nativeAmount != null &&
        nativeAmount.isNotEmpty) {
      return (currencyCode.toUpperCase(), nativeAmount);
    }
    final ledger = await getLedgerById(ledgerId);
    final base =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    var cc = currencyCode?.toUpperCase();
    if (cc == null || cc.isEmpty) {
      cc = base;
    }
    var na = nativeAmount;
    if (na == null || na.isEmpty) {
      if (cc == base) {
        na = amount;
      } else {
        final rates = await _effectiveRatesFor(base);
        na =
            computeNativeAmountDecimal(
              amount: amount,
              txCurrency: cc,
              ledgerBase: base,
              rates: rates,
            ) ??
            amount;
      }
    }
    return (cc, na);
  }

  /// 重算核心：遍历该账本交易按 [base] 重算 nativeAmount（Decimal 字符串版）。
  ///
  /// [recordChanges] 默认 true：云端账本在同一个写事务内登记 transaction
  /// upsert 同步变更（含 AA 分摊行折算后的完整 payload）；恢复导入等回填
  /// 路径传 false，禁止历史快照反向推云。
  Future<int> _recalcNativeAmounts(
    String ledgerId,
    String base, {
    required bool onlyUnconverted,
    String? previousBase,
    bool recordChanges = true,
  }) => db.transaction(
    () => _recalcNativeAmountsInner(
      ledgerId,
      base,
      onlyUnconverted: onlyUnconverted,
      previousBase: previousBase,
      recordChanges: recordChanges,
    ),
  );

  Future<int> _recalcNativeAmountsInner(
    String ledgerId,
    String base, {
    required bool onlyUnconverted,
    required String? previousBase,
    bool recordChanges = true,
  }) async {
    final baseUp = base.toUpperCase();
    final previousBaseUp = previousBase?.trim().toUpperCase();
    final rates = await _effectiveRatesFor(baseUp);
    final txs = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())).get();
    // 单次重算共用同一时刻：交易 updatedAt 与同步变更登记时间一致，云端
    // LWW 按该时间裁决，避免「本地已改、云端仍旧」的半同步态。
    final now = DateTime.now().toUtc();
    final changedIds = <String>[];
    for (final t in txs) {
      final shouldBackfillCurrency =
          !onlyUnconverted &&
          previousBaseUp != null &&
          (t.currencyCode.isEmpty || t.currencyCode.trim().isEmpty);
      final cc =
          (shouldBackfillCurrency
                  ? previousBaseUp
                  : t.currencyCode.isEmpty
                  ? baseUp
                  : t.currencyCode)
              .toUpperCase();
      if (cc == baseUp) {
        // 本位币交易：全量重算时对齐 native=amount。
        if (onlyUnconverted ||
            (!shouldBackfillCurrency && t.nativeAmount == t.amount)) {
          continue;
        }
        await (db.update(
          db.transactions,
        )..where((x) => x.id.equals(t.id))).write(
          TransactionsCompanion(
            currencyCode: shouldBackfillCurrency
                ? d.Value(cc)
                : const d.Value.absent(),
            nativeAmount: d.Value(t.amount),
            updatedAt: d.Value(now),
          ),
        );
        // 本位币口径同样要求 sum(splits)==amount，历史错快照同步补齐。
        await _scaleAaSplitsForRecalc(t, newNative: t.amount);
        changedIds.add(t.id);
      } else {
        if (onlyUnconverted && t.nativeAmount != t.amount) {
          continue; // 已折算过，不动。
        }
        var na = computeNativeAmountDecimal(
          amount: t.amount,
          txCurrency: cc,
          ledgerBase: baseUp,
          rates: rates,
        );
        if (na == null) {
          if (onlyUnconverted) continue;
          na = t.amount;
        }
        if (t.nativeAmount == na) continue;
        await (db.update(
          db.transactions,
        )..where((x) => x.id.equals(t.id))).write(
          TransactionsCompanion(
            currencyCode: shouldBackfillCurrency
                ? d.Value(cc)
                : const d.Value.absent(),
            nativeAmount: d.Value(na),
            updatedAt: d.Value(now),
          ),
        );
        // AA 指定分摊：本位币切换后同步换算分账金额，保持服务端
        // sum(splits)==native_amount 契约成立，否则推送会被整体拒绝。
        await _scaleAaSplitsForRecalc(t, newNative: na);
        changedIds.add(t.id);
      }
    }
    if (changedIds.isNotEmpty) {
      if (recordChanges) {
        // 变更登记与数据更新同一事务：登记失败整体回滚。
        // 现有实现只对 storageMode == 'cloud' 的账本实际写入。
        await _transactionRepo.recordBatchTxChanges(changedIds);
      }
      logger.info(
        'LocalRepository',
        '多币种重算完成 ledger=$ledgerId base=$baseUp onlyUnconverted=$onlyUnconverted 改动 ${changedIds.length} 笔',
      );
    }
    return changedIds.length;
  }

  /// AA 指定分摊（aaMode=2 且有分摊行）随本位币切换同步换算。
  ///
  /// 按「新 native / 旧合计」比例缩放每行金额，四舍五入后的尾差归支出人
  /// （不在分摊列表时归最后一位参与人），保证换算后
  /// sum(splits) == 新 nativeAmount 精确成立。
  ///
  /// 旧合计可能是原币口径（存量/编辑器直写）或旧本位币口径（已换算过），
  /// 用合计匹配判别换算基准；两者都不匹配时视为脏数据，跳过换算并告警。
  Future<void> _scaleAaSplitsForRecalc(
    Transaction t, {
    required String newNative,
  }) async {
    final rows = await _transactionRepo.getTransactionSplits(t.id);
    if (rows.isEmpty) return;
    final amountD = Decimal.tryParse(t.amount);
    final oldNativeD = Decimal.tryParse(t.nativeAmount);
    final newNativeD = Decimal.tryParse(newNative);
    if (amountD == null || oldNativeD == null || newNativeD == null) return;
    final values = <Decimal>[];
    for (final r in rows) {
      final v = Decimal.tryParse(r.amount);
      if (v == null || v <= Decimal.zero) {
        logger.warning(
          'LocalRepository',
          'AA 分摊金额非法，跳过换算 tx=${t.id} amount=${r.amount}',
        );
        return;
      }
      values.add(v);
    }
    final oldSum = sumOfSplits(values);
    final Decimal fromTotal;
    if (oldSum == oldNativeD) {
      fromTotal = oldNativeD; // 本位币口径：按新旧 native 比例换算
    } else if (oldSum == amountD) {
      fromTotal = amountD; // 原币口径：按新 native / 原币比例换算
    } else {
      logger.warning(
        'LocalRepository',
        'AA 分摊合计与新旧快照均不匹配，跳过换算 tx=${t.id} sum=$oldSum amount=${t.amount} oldNative=${t.nativeAmount}',
      );
      return;
    }
    if (fromTotal == newNativeD) return; // 数值未变，无需重写分摊行。
    final scaled = <Decimal>[
      for (final v in values) scaleSplitValue(v, fromTotal, newNativeD),
    ];
    final payerIdx = t.payerMemberId == null
        ? -1
        : rows.indexWhere((r) => r.memberId == t.payerMemberId);
    final balanced = balanceSplitRemainder(
      scaled,
      total: newNativeD,
      remainderIndex: payerIdx,
    );
    for (var i = 0; i < rows.length; i++) {
      await (db.update(
        db.transactionSplits,
      )..where((s) => s.id.equals(rows[i].id))).write(
        TransactionSplitsCompanion(
          amount: d.Value(normalizeDecimal(balanced[i])),
        ),
      );
    }
  }

  /// 编辑路径 AA 指定分摊落库前归为账本本位币口径（服务端契约
  /// sum(splits)==native_amount）：编辑器输入恒为原币口径，外币交易按隐含
  /// 汇率换算；本位币交易（native==amount）与既有本位币口径数据恒等直写。
  List<TransactionSplitInput>? _normalizeSplitsForWrite(
    List<TransactionSplitInput>? splits,
    String amount,
    String nativeAmount,
    String? payerMemberId,
  ) {
    if (splits == null || splits.isEmpty) return splits;
    final amountD = Decimal.tryParse(amount);
    final nativeD = Decimal.tryParse(nativeAmount);
    if (amountD == null || nativeD == null) return splits;
    final values = <Decimal>[];
    for (final s in splits) {
      final v = Decimal.tryParse(s.amount);
      if (v == null || v <= Decimal.zero) return splits; // 脏值直写，由校验层兜底
      values.add(v);
    }
    // 已为本位币口径（或合计不匹配的脏数据）：原样透传，保留输入字符串，
    // 不因归一化改写存量断言/编辑回显（本位币交易 native==amount 恒等）。
    final rawSum = sumOfSplits(values);
    if (rawSum == nativeD || rawSum != amountD) return splits;
    final payerIdx = payerMemberId == null
        ? -1
        : splits.indexWhere((s) => s.memberId == payerMemberId);
    final normalized = normalizeSplitsToNative(
      splits: values,
      amount: amountD,
      nativeAmount: nativeD,
      remainderIndex: payerIdx,
    );
    return [
      for (var i = 0; i < splits.length; i++)
        TransactionSplitInput(
          memberId: splits[i].memberId,
          amount: normalizeDecimal(normalized[i]),
        ),
    ];
  }

  /// 账本本位币切换后重算所有交易快照。
  ///
  /// [recordChanges] 默认 true；恢复导入传 false（数据回填不反向推云）。
  Future<int> recalcNativeAmountsForLedger(
    String ledgerId,
    String newBase, {
    required String previousBase,
    bool recordChanges = true,
  }) => _recalcNativeAmounts(
    ledgerId,
    newBase,
    onlyUnconverted: false,
    previousBase: previousBase,
    recordChanges: recordChanges,
  );

  /// 统计账本尚未推送成功的同步变更条数。
  ///
  /// 云端账本导入完成后用于提示「N 条记录待同步至云端」；本地账本不产生
  /// 同步事件，恒为 0。pushed_at 非 null 表示服务端已确认（或标记处理）。
  Future<int> countPendingSyncChanges(String ledgerId) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM sync_changes '
          'WHERE ledger_id = ?1 AND pushed_at IS NULL',
          variables: [d.Variable.withString(ledgerId)],
          readsFrom: {db.syncChanges},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<int> recomputeForeignTxForLedger(String ledgerId) async {
    final ledger = await getLedgerById(ledgerId);
    final base =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    return _recalcNativeAmounts(ledgerId, base, onlyUnconverted: true);
  }

  Future<int> countUnconvertedForeignTx(String ledgerId) async {
    final ledger = await getLedgerById(ledgerId);
    final base =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM transactions t '
          'WHERE t.ledger_id = ?1 '
          'AND t.deleted_at IS NULL '
          "AND UPPER(COALESCE(t.currency_code, ?2)) != ?2 "
          'AND COALESCE(t.native_amount, t.amount) = t.amount',
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(base),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  Future<int> countForeignCurrencyTx(String ledgerId) async {
    final ledger = await getLedgerById(ledgerId);
    final base =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS cnt FROM transactions t '
          'WHERE t.ledger_id = ?1 '
          'AND t.deleted_at IS NULL '
          "AND UPPER(COALESCE(t.currency_code, ?2)) != ?2",
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(base),
          ],
          readsFrom: {db.transactions},
        )
        .getSingle();
    return row.read<int>('cnt');
  }

  // 批量插入交易
  Future<List<String>> insertTransactionsBatchWithRelations({
    required List<TransactionsCompanion> transactions,
    bool recordChanges = true,
  }) => _transactionRepo.insertTransactionsBatchWithRelations(
    transactions: transactions,
    recordChanges: recordChanges,
  );

  Future<String> insertTransactionCompanion(
    TransactionsCompanion item, {
    bool recordChanges = true,
  }) => _transactionRepo.insertTransactionCompanion(
    item,
    recordChanges: recordChanges,
  );

  Future<List<({Transaction t, Category? category})>>
  transactionsWithCategoryAll({String? ledgerId}) => _guard(
    'transactionsWithCategoryAll',
    () => _transactionRepo.transactionsWithCategoryAll(ledgerId: ledgerId),
  );

  Future<List<({Transaction t, Category? category})>>
  getRecentTransactionsWithCategory({
    required String ledgerId,
    required int limit,
  }) => _transactionRepo.getRecentTransactionsWithCategory(
    ledgerId: ledgerId,
    limit: limit,
  );

  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _transactionRepo.countByTypeInRange(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  Future<List<Transaction>> getTransactionsByLedger(String ledgerId) =>
      _transactionRepo.getTransactionsByLedger(ledgerId);

  Future<List<Transaction>> getAaTransactionsByLedger(String ledgerId) =>
      _transactionRepo.getAaTransactionsByLedger(ledgerId);

  Future<List<Transaction>> getTransactionsByLedgerInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) => _transactionRepo.getTransactionsByLedgerInRange(
    ledgerId: ledgerId,
    start: start,
    end: end,
  );

  /// 跨账本移动交易：按新账本本位币重算快照。
  Future<void> updateTransactionLedger({
    required String id,
    required String ledgerId,
  }) => _guard(
    'updateTransactionLedger transaction=$id ledger=$ledgerId',
    () async {
      final tx = await _transactionRepo.getTransactionById(id);
      if (tx == null) {
        throw StateError('交易不存在，无法移动: $id');
      }
      final ledger = await getLedgerById(ledgerId);
      if (ledger == null) {
        throw StateError('目标账本不存在，无法移动交易: $ledgerId');
      }
      final base = (ledger.currency.isNotEmpty ? ledger.currency : 'CNY')
          .toUpperCase();
      final cc = tx.currencyCode.isEmpty ? base : tx.currencyCode.toUpperCase();
      String na;
      if (cc == base) {
        na = tx.amount;
      } else {
        final rates = await _effectiveRatesFor(base);
        na =
            computeNativeAmountDecimal(
              amount: tx.amount,
              txCurrency: cc,
              ledgerBase: base,
              rates: rates,
            ) ??
            tx.amount;
      }
      await _transactionRepo.updateTransactionLedger(
        id: id,
        ledgerId: ledgerId,
        currencyCode: cc,
        nativeAmount: na,
      );
    },
  );

  /// 该账本交易涉及的全部外币币种（≠本位币）。
  Future<Set<String>> getLedgerForeignCurrencies(String ledgerId) async {
    final ledger = await getLedgerById(ledgerId);
    final base =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    final rows = await db
        .customSelect(
          'SELECT DISTINCT UPPER(COALESCE(t.currency_code, ?2)) AS cc '
          'FROM transactions t '
          'WHERE t.ledger_id = ?1 '
          'AND t.deleted_at IS NULL',
          variables: [
            d.Variable.withString(ledgerId),
            d.Variable.withString(base),
          ],
          readsFrom: {db.transactions},
        )
        .get();
    return {
      for (final r in rows)
        if (r.read<String>('cc') != base) r.read<String>('cc'),
    };
  }

  // ==================== 日历功能相关 ====================

  Future<Map<String, double>> getDailyTotalsByMonth({
    required String ledgerId,
    required DateTime month,
  }) =>
      _transactionRepo.getDailyTotalsByMonth(ledgerId: ledgerId, month: month);

  Future<List<({Transaction t, Category? category})>> getTransactionsByDate({
    required String ledgerId,
    required DateTime date,
  }) => _transactionRepo.getTransactionsByDate(ledgerId: ledgerId, date: date);

  // ============================================
  // 分类 - 委托给 LocalCategoryRepository
  // ============================================

  /// 创建分类，并透传是否登记同步变更；恢复回填使用 false。
  Future<String> createCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    int level = 1,
    String? parentId,
    bool recordChanges = true,
  }) => _categoryRepo.createCategory(
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    level: level,
    parentId: parentId,
    recordChanges: recordChanges,
  );

  /// 创建子分类，并透传是否登记同步变更；恢复回填使用 false。
  Future<String> createSubCategory({
    required String parentId,
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
  }) => _categoryRepo.createSubCategory(
    parentId: parentId,
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
    recordChanges: recordChanges,
  );

  Future<void> updateCategory(
    String id, {
    String? name,
    String? icon,
    String? parentId,
    int? level,
  }) => _categoryRepo.updateCategory(
    id,
    name: name,
    icon: icon,
    parentId: parentId,
    level: level,
  );

  Future<void> deleteCategory(String id) => _categoryRepo.deleteCategory(id);

  Future<void> deleteCategoriesByIds(List<String> ids) =>
      _categoryRepo.deleteCategoriesByIds(ids);

  /// 删除指定分类下的交易；云账本逐笔登记 delete，本地账本只改本地数据。
  Future<int> deleteTransactionsByCategoryIds(List<String> categoryIds) {
    if (categoryIds.isEmpty) return Future.value(0);
    return _guard(
      'deleteTransactionsByCategoryIds',
      () => db.transaction(() async {
        final ids =
            (await (db.select(db.transactions)..where(
                      (t) =>
                          t.categoryId.isIn(categoryIds) & t.deletedAt.isNull(),
                    ))
                    .get())
                .map((t) => t.id);
        return _deleteTransactionsByIds(ids);
      }),
    );
  }

  Future<int> promoteSubCategoriesToTopLevel(String parentId) =>
      _categoryRepo.promoteSubCategoriesToTopLevel(parentId);

  Future<({String id, bool created})> upsertCategory({
    required String name,
    required String kind,
    String? icon,
    int? sortOrder,
  }) => _categoryRepo.upsertCategory(
    name: name,
    kind: kind,
    icon: icon,
    sortOrder: sortOrder,
  );

  Future<Category?> getCategoryById(String categoryId) =>
      _categoryRepo.getCategoryById(categoryId);

  Future<List<Category>> filterCategoriesForLedgerPicker(
    List<Category> all, {
    String? ledgerId,
    String? kind,
    bool topLevelOnly = true,
  }) => _categoryRepo.filterCategoriesForLedgerPicker(
    all,
    ledgerId: ledgerId,
    kind: kind,
    topLevelOnly: topLevelOnly,
  );

  Future<Map<String, Category>> getCategoriesByIds(Iterable<String> ids) =>
      _categoryRepo.getCategoriesByIds(ids);

  Future<List<Category>> getTopLevelCategories(String kind) =>
      _categoryRepo.getTopLevelCategories(kind);

  Future<List<Category>> getSubCategories(String parentId) =>
      _categoryRepo.getSubCategories(parentId);

  Future<CategoryRowTree> getCategoryTree(String kind) =>
      _categoryRepo.getCategoryTree(kind);

  Future<List<Category>> getUsableCategories(String kind) =>
      _categoryRepo.getUsableCategories(kind);

  Future<bool> isCategoryNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
  }) => _categoryRepo.isCategoryNameDuplicate(
    name: name,
    kind: kind,
    excludeId: excludeId,
    parentId: parentId,
  );

  Future<bool> hasSubCategories(String categoryId) =>
      _categoryRepo.hasSubCategories(categoryId);

  Future<int> getSubCategoryCount(String categoryId) =>
      _categoryRepo.getSubCategoryCount(categoryId);

  Future<int> getTransactionCountByCategory(String categoryId) =>
      _categoryRepo.getTransactionCountByCategory(categoryId);

  Future<Map<String, int>> getAllCategoryTransactionCounts() =>
      _categoryRepo.getAllCategoryTransactionCounts();

  Future<({int totalCount, double totalAmount, double averageAmount})>
  getCategorySummary(String categoryId, {required String ledgerId}) =>
      _categoryRepo.getCategorySummary(categoryId, ledgerId: ledgerId);

  Future<List<Transaction>> getTransactionsByCategory(String categoryId) =>
      _categoryRepo.getTransactionsByCategory(categoryId);

  Future<List<Transaction>> getTransactionsByCategoryWithSort(
    String categoryId, {
    required String ledgerId,
    String sortBy = 'time',
    bool ascending = false,
  }) => _categoryRepo.getTransactionsByCategoryWithSort(
    categoryId,
    ledgerId: ledgerId,
    sortBy: sortBy,
    ascending: ascending,
  );

  /// 迁移分类直属交易，并为实际变化的云交易登记完整 upsert 快照。
  Future<int> migrateCategory({
    required String fromCategoryId,
    required String toCategoryId,
  }) => _guard(
    'migrateCategory($fromCategoryId->$toCategoryId)',
    () => db.transaction(() async {
      final rows =
          await (db.select(db.transactions)..where(
                (t) =>
                    t.categoryId.equals(fromCategoryId) & t.deletedAt.isNull(),
              ))
              .get();
      final migrated = await _categoryRepo.migrateCategory(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      await _ensureCloudChangesCanBeRecorded(rows);
      await _transactionRepo.recordBatchTxChanges(rows.map((row) => row.id));
      return migrated;
    }),
  );

  /// 迁移分类树，只为 categoryId 真正变化的云交易登记 upsert。
  Future<({int migratedTransactions, int migratedSubCategories})>
  migrateCategoryTransactions({
    required String fromCategoryId,
    required String toCategoryId,
  }) => _guard(
    'migrateCategoryTransactions($fromCategoryId->$toCategoryId)',
    () => db.transaction(() async {
      final childIds =
          (await (db.select(db.categories)..where(
                    (c) =>
                        c.parentId.equals(fromCategoryId) &
                        c.deletedAt.isNull(),
                  ))
                  .get())
              .map((row) => row.id);
      final sourceIds = {fromCategoryId, ...childIds};
      final before =
          await (db.select(db.transactions)..where(
                (t) => t.categoryId.isIn(sourceIds) & t.deletedAt.isNull(),
              ))
              .get();

      final result = await _categoryRepo.migrateCategoryTransactions(
        fromCategoryId: fromCategoryId,
        toCategoryId: toCategoryId,
      );
      final after = {
        for (final row
            in await (db.select(db.transactions)..where(
                  (t) =>
                      t.id.isIn(before.map((row) => row.id).toList()) &
                      t.deletedAt.isNull(),
                ))
                .get())
          row.id: row,
      };
      final changed = before.where(
        (row) => after[row.id]?.categoryId != row.categoryId,
      );
      await _ensureCloudChangesCanBeRecorded(changed);
      await _transactionRepo.recordBatchTxChanges(changed.map((row) => row.id));
      return result;
    }),
  );

  Future<({int transactionCount, bool canMigrate})> getCategoryMigrationInfo({
    required String fromCategoryId,
    required String toCategoryId,
  }) => _categoryRepo.getCategoryMigrationInfo(
    fromCategoryId: fromCategoryId,
    toCategoryId: toCategoryId,
  );

  Future<void> updateCategorySortOrders(
    List<({String id, int sortOrder})> updates,
  ) => _categoryRepo.updateCategorySortOrders(updates);

  Future<String> getCategoryFullName(String categoryId) =>
      _categoryRepo.getCategoryFullName(categoryId);

  Stream<Category?> watchCategory(String categoryId) =>
      _categoryRepo.watchCategory(categoryId);

  Stream<List<Transaction>> watchTransactionsByCategory(
    String categoryId, {
    String? ledgerId,
    bool includeSubCategories = false,
  }) => _categoryRepo.watchTransactionsByCategory(
    categoryId,
    ledgerId: ledgerId,
    includeSubCategories: includeSubCategories,
  );

  Stream<List<Category>> watchCategoryWithSubs(String categoryId) =>
      _categoryRepo.watchCategoryWithSubs(categoryId);

  Stream<List<({Category category, int transactionCount})>>
  watchCategoriesWithCount() => _categoryRepo.watchCategoriesWithCount();

  Future<List<Category>> getAllCategories() => _categoryRepo.getAllCategories();

  Future<List<Category>> getAllCategoriesIncludingShared() =>
      _categoryRepo.getAllCategoriesIncludingShared();

  Future<void> batchInsertCategories(List<CategoriesCompanion> categories) =>
      _categoryRepo.batchInsertCategories(categories);

  Future<String> insertCategory(CategoriesCompanion category) =>
      _categoryRepo.insertCategory(category);

  Future<Set<String>> getUsedCurrencies() async {
    final rows = await db
        .customSelect(
          "SELECT DISTINCT currency_code FROM transactions "
          "WHERE deleted_at IS NULL "
          "AND currency_code IS NOT NULL AND currency_code != ''",
        )
        .get();
    return rows.map((r) => r.read<String>('currency_code')).toSet();
  }

  // ============================================
  // 统计 - 委托给 LocalStatisticsRepository
  // ============================================

  Future<List<({String? id, String name, String? icon, double total})>>
  totalsByCategory({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _statisticsRepo.totalsByCategory(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  Future<
    List<
      ({
        String? id,
        String name,
        String? icon,
        String? parentId,
        int level,
        double total,
      })
    >
  >
  totalsByCategoryWithHierarchy({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _statisticsRepo.totalsByCategoryWithHierarchy(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _statisticsRepo.totalsByDay(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  Future<List<({DateTime month, double total})>> totalsByMonth({
    required String ledgerId,
    required String type,
    required int year,
  }) =>
      _statisticsRepo.totalsByMonth(ledgerId: ledgerId, type: type, year: year);

  Future<List<({int year, double total})>> totalsByYearSeries({
    required String ledgerId,
    required String type,
  }) => _statisticsRepo.totalsByYearSeries(ledgerId: ledgerId, type: type);

  Future<DateTime?> earliestExpenseDate({required String ledgerId}) =>
      _statisticsRepo.earliestExpenseDate(ledgerId: ledgerId);

  Future<DateTime?> latestExpenseDate({required String ledgerId}) =>
      _statisticsRepo.latestExpenseDate(ledgerId: ledgerId);

  Future<bool> hasAnyExpenseTx({required String ledgerId}) =>
      _statisticsRepo.hasAnyExpenseTx(ledgerId: ledgerId);

  Future<double> totalsInRange({
    required String ledgerId,
    required DateTime start,
    required DateTime end,
  }) =>
      _statisticsRepo.totalsInRange(ledgerId: ledgerId, start: start, end: end);

  Future<double> monthlyTotals({
    required String ledgerId,
    required DateTime month,
  }) => _statisticsRepo.monthlyTotals(ledgerId: ledgerId, month: month);

  Future<double> todayExpense({
    required String ledgerId,
    required DateTime now,
  }) => _statisticsRepo.todayExpense(ledgerId: ledgerId, now: now);

  Future<double> weekExpense({
    required String ledgerId,
    required DateTime now,
  }) => _statisticsRepo.weekExpense(ledgerId: ledgerId, now: now);

  Future<double> yearlyTotals({required String ledgerId, required int year}) =>
      _statisticsRepo.yearlyTotals(ledgerId: ledgerId, year: year);

  Future<Map<String, Category>> getSharedSyntheticCategoriesForLedger(
    String ledgerId,
  ) => _statisticsRepo.getSharedSyntheticCategoriesForLedger(ledgerId);

  // ============================================
  // 周期交易 - 委托给 LocalRecurringTransactionRepository
  // ============================================

  Future<List<RecurringTransaction>> getAllRecurringTransactions() =>
      _recurringTransactionRepo.getAllRecurringTransactions();

  /// 按周期模板生成交易，并在同一事务内推进最后生成日期。
  Future<String> generateRecurringTransaction({
    required RecurringTransaction recurring,
    required DateTime happenedAt,
  }) => _guard(
    'generateRecurringTransaction recurring=${recurring.id}',
    () => db.transaction(() async {
      final txId = await addTransaction(
        ledgerId: recurring.ledgerId,
        type: recurring.txType,
        amount: recurring.amount,
        currencyCode: recurring.currencyCode,
        categoryId: recurring.categoryId,
        happenedAt: happenedAt,
        note: recurring.note,
      );
      await updateLastGeneratedDate(recurring.id, happenedAt);
      return txId;
    }),
  );

  Future<List<RecurringTransaction>> getRecurringTransactionsByLedger(
    String ledgerId,
  ) => _recurringTransactionRepo.getRecurringTransactionsByLedger(ledgerId);

  Future<List<RecurringTransaction>> getEnabledRecurringTransactions(
    String ledgerId,
  ) => _recurringTransactionRepo.getEnabledRecurringTransactions(ledgerId);

  Future<String> addRecurringTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    required DateTime startDate,
    DateTime? endDate,
    bool enabled = true,
  }) => _recurringTransactionRepo.addRecurringTransaction(
    ledgerId: ledgerId,
    type: type,
    amount: amount,
    currencyCode: currencyCode,
    categoryId: categoryId,
    note: note,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    dayOfWeek: dayOfWeek,
    monthOfYear: monthOfYear,
    startDate: startDate,
    endDate: endDate,
    enabled: enabled,
  );

  Future<void> updateRecurringTransaction({
    required String id,
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    required DateTime startDate,
    DateTime? endDate,
    bool? enabled,
    bool clearLastGeneratedDate = false,
  }) => _recurringTransactionRepo.updateRecurringTransaction(
    id: id,
    ledgerId: ledgerId,
    type: type,
    amount: amount,
    currencyCode: currencyCode,
    categoryId: categoryId,
    note: note,
    frequency: frequency,
    interval: interval,
    dayOfMonth: dayOfMonth,
    dayOfWeek: dayOfWeek,
    monthOfYear: monthOfYear,
    startDate: startDate,
    endDate: endDate,
    enabled: enabled,
    clearLastGeneratedDate: clearLastGeneratedDate,
  );

  Future<void> deleteRecurringTransaction(String id) =>
      _recurringTransactionRepo.deleteRecurringTransaction(id);

  Future<void> toggleRecurringTransaction(String id, bool enabled) =>
      _recurringTransactionRepo.toggleRecurringTransaction(id, enabled);

  Future<void> updateLastGeneratedDate(String id, DateTime date) => _guard(
    'updateLastGeneratedDate recurring=$id',
    () => _recurringTransactionRepo.updateLastGeneratedDate(id, date),
  );

  Stream<List<RecurringTransaction>> watchAllRecurringTransactions() =>
      _recurringTransactionRepo.watchAllRecurringTransactions();

  Stream<List<RecurringTransaction>> watchRecurringTransactionsByLedger(
    String ledgerId,
  ) => _recurringTransactionRepo.watchRecurringTransactionsByLedger(ledgerId);

  /// 批量导入周期模板；恢复回填可关闭反向同步变更登记。
  Future<void> batchInsertRecurringTransactions(
    List<RecurringTransactionsCompanion> items, {
    bool recordChanges = true,
  }) => _recurringTransactionRepo.batchInsertRecurringTransactions(
    items,
    recordChanges: recordChanges,
  );

  // ============================================
  // 成员 - 委托给 LocalLedgerMemberRepository
  // ============================================

  Stream<List<LedgerMember>> watchMembersByLedger(String ledgerId) =>
      _memberRepo.watchByLedger(ledgerId);

  Future<List<LedgerMember>> getMembersByLedger(String ledgerId) =>
      _memberRepo.getByLedger(ledgerId);

  Future<LedgerMember?> getMemberById(String id) => _memberRepo.getById(id);

  Future<LedgerMember?> getMemberByLinkedAccount(
    String ledgerId,
    String accountId,
  ) => _memberRepo.getByLinkedAccount(ledgerId, accountId);

  Future<LedgerMember> ensureLocalSelfMember({
    required String ledgerId,
    required String localSelfId,
    required String displayName,
  }) => _memberRepo.ensureLocalSelf(
    ledgerId: ledgerId,
    localSelfId: localSelfId,
    displayName: displayName,
  );

  Future<LedgerMember> ensureRegisteredMember({
    required String ledgerId,
    required String userId,
    required String displayName,
    String role = 'editor',
    String? avatarUrl,
    int avatarVersion = 0,
  }) => _memberRepo.ensureRegistered(
    ledgerId: ledgerId,
    userId: userId,
    displayName: displayName,
    role: role,
    avatarUrl: avatarUrl,
    avatarVersion: avatarVersion,
  );

  Future<String> createPlaceholderMember({
    required String ledgerId,
    required String name,
    String? id,
  }) => _memberRepo.createPlaceholder(ledgerId: ledgerId, name: name, id: id);

  Future<void> upsertPlaceholderMember({
    required String ledgerId,
    required String id,
    required String name,
    required DateTime updatedAt,
  }) => _memberRepo.upsertPlaceholder(
    ledgerId: ledgerId,
    id: id,
    name: name,
    updatedAt: updatedAt,
  );

  Future<void> renameMember({required String id, required String name}) =>
      _memberRepo.rename(id: id, name: name);

  Future<bool> deleteMember(String id) => _memberRepo.delete(id);

  Future<bool> isMemberReferencedByAnyTransaction(String id) =>
      _memberRepo.isReferencedByAnyTransaction(id);

  Future<void> bindLocalSelfMember({
    required String ledgerId,
    required String localSelfId,
    required String accountId,
  }) => _memberRepo.bindLocalSelf(
    ledgerId: ledgerId,
    localSelfId: localSelfId,
    accountId: accountId,
  );

  Future<void> unbindAllLocalMembers() => _memberRepo.unbindAllLocalMembers();

  /// §13.4:本人更新云 Profile 后刷新同账号 REGISTERED 成员展示快照。
  Future<int> refreshMemberDisplayByAccount({
    required String userId,
    required String? displayName,
    required String? avatarUrl,
    required int avatarVersion,
  }) => _memberRepo.refreshDisplayByAccount(
    userId: userId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    avatarVersion: avatarVersion,
  );

  /// 成员目录 REST 快照落库(公开资料镜像,不改变生命周期)。
  Future<void> applyMemberDirectorySnapshot({
    required String ledgerId,
    required List<LedgerDirectoryMember> members,
  }) =>
      _memberRepo.applyDirectorySnapshot(ledgerId: ledgerId, members: members);

  Future<void> updateMemberStatus({
    required String ledgerId,
    required String accountId,
    required String status,
  }) => _memberRepo.updateStatus(
    ledgerId: ledgerId,
    accountId: accountId,
    status: status,
  );

  // ============================================
  // 汇率 - 委托给 LocalExchangeRateRepository
  // ============================================

  Future<void> upsertAutoRates({
    required String base,
    required String rateDate,
    required Map<String, String> rates,
    required String source,
    required DateTime fetchedAt,
  }) => _exchangeRateRepo.upsertAutoRates(
    base: base,
    rateDate: rateDate,
    rates: rates,
    source: source,
    fetchedAt: fetchedAt,
  );

  Future<List<ExchangeRate>> getLatestAutoRates(String base) =>
      _exchangeRateRepo.getLatestAutoRates(base);

  Future<DateTime?> getLastFetchedAt(String base) =>
      _exchangeRateRepo.getLastFetchedAt(base);

  Future<List<ExchangeRateOverride>> getOverrides(String base) =>
      _exchangeRateRepo.getOverrides(base);

  Stream<List<ExchangeRateOverride>> watchOverrides(String base) =>
      _exchangeRateRepo.watchOverrides(base);

  Future<void> setOverride({
    required String base,
    required String quote,
    required String rate,
  }) => _exchangeRateRepo.setOverride(base: base, quote: quote, rate: rate);

  Future<void> removeOverride({required String base, required String quote}) =>
      _exchangeRateRepo.removeOverride(base: base, quote: quote);
}
