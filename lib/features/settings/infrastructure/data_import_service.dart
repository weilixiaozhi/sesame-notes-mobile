import 'package:drift/drift.dart' as d;
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/shared/services/currency/exchange_rate_service.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/utils/member_id.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:uuid/uuid.dart';

/// 统一的数据导入服务（落库编排引擎）
///
/// 定位说明（共享服务，不随 DTO 下沉）：
/// - 被 CSV 导入（UI 层）消费，备份/全量恢复路径复用同一套导入逻辑
///   （分类创建、批量落库、UUID 幂等去重、汇率补拉），保证各路径行为一致。
/// - 依赖 services/currency/exchange_rate_service.dart 做导入补拉汇率，
///   故**不能**下沉到 data/（否则制造 data → services 反向依赖），
///   保留在 services/ 层作为共享服务，上层经本文件引用。
/// - 数据模型（ImportCategory/ImportTransaction/ImportData/ImportResult）
///   定义于 data/models/import_models.dart，经 data/models.dart 门面出口；
///   UI 层统一从门面取类型，不直连本文件。

// --- 数据导入服务 ---

/// 导入被用户取消时抛出。
///
/// 由 UI 层的进度回调在批次间隙抛出,导入服务循环据此中止,
/// 已落库的批次保留、未处理的批次不写入。
class ImportCancelledException implements Exception {
  const ImportCancelledException();
}

/// CSV 导入行的确定性交易同步 ID（UUIDv5）。
///
/// 同一逻辑文件（解析后 rows 的稳定 JSON 哈希）+ 同一逻辑行号 + 同一目标
/// 账本必然派生同一个 ID：重复导入同一 CSV 时按主键幂等去重；行号参与
/// 派生保证同文件内两条完全相同但真实存在的账单不会互相去重。名称中再次
/// 携带账本 ID，防止非标准账本 ID 被 uuidV5 容错为零 namespace 时跨账本碰撞。
String csvImportSyncId({
  required String targetLedgerId,
  required String fileHash,
  required int rowIndex,
}) => uuidV5(
  targetLedgerId,
  "csv:${targetLedgerId.toLowerCase()}:$fileHash:row:$rowIndex",
);

/// 校验单个导入分类；返回空列表表示合法，否则返回错误原因列表。
///
/// 全局仅支出模式，分类必须是 expense；level 只允许 1/2，二级必须带父分类名。
List<String> validateImportCategory(ImportCategory c) {
  final errors = <String>[];
  if (c.name.trim().isEmpty) errors.add('分类名称为空');
  if (c.kind != 'expense') errors.add('仅支持支出分类（kind=expense）');
  if (c.level != 1 && c.level != 2) errors.add('level 只能是 1 或 2');
  if (c.level == 2 && (c.parentName == null || c.parentName!.trim().isEmpty)) {
    errors.add('二级分类必须提供 parentName');
  }
  return errors;
}

/// 校验单个导入交易；返回空列表表示合法，否则返回错误原因列表。
///
/// 金额必须为正数且符合数据库 28 位整数、10 位小数精度；币种为空时由
/// 目标账本兜底，有值时必须来自客户端支持列表，避免无法展示或折算的代码落库。
List<String> validateImportTransaction(ImportTransaction t) {
  final errors = <String>[];
  if (t.type != 'expense') errors.add('仅支持支出交易（type=expense）');
  if (t.amount <= Decimal.zero) errors.add('金额必须为正数');
  if (!isNormalizedDecimal(t.amount.toString())) {
    errors.add('金额最多支持 28 位整数和 10 位小数');
  }
  final nativeAmount = t.nativeAmount;
  if (nativeAmount != null) {
    if (nativeAmount <= Decimal.zero) errors.add('本位币金额必须为正数');
    if (!isNormalizedDecimal(nativeAmount.toString())) {
      errors.add('本位币金额最多支持 28 位整数和 10 位小数');
    }
  }
  final currency = t.currencyCode?.trim().toUpperCase();
  if (currency != null &&
      currency.isNotEmpty &&
      !kCurrencyCodes.contains(currency)) {
    errors.add('币种不在支持列表中');
  }
  return errors;
}

/// 通用数据导入服务
///
/// 提供统一的导入逻辑，支持：
/// - 分类创建（先一级后二级）
/// - 交易插入（批量写入，UUID 幂等去重）
class DataImportService {
  /// 交易主键 UUID 生成器（离线创建，本地即云端 ID）。
  static const _uuid = Uuid();

  final ExchangeRateService _exchangeRateService;

  /// 创建导入服务；测试可注入可控汇率服务，生产默认使用公网汇率源链。
  DataImportService({ExchangeRateService? exchangeRateService})
    : _exchangeRateService = exchangeRateService ?? ExchangeRateService();

  /// 导入数据到指定账本
  ///
  /// [repo] - 数据仓库
  /// [ledgerId] - 目标账本ID
  /// [data] - 导入数据
  /// [onProgress] - 进度回调 (done, total)
  /// [recordChanges] - 默认 true,落库时登记 change log(changeTracker);
  ///   恢复路径传 false,避免"从备份拉回来的数据又反向推出去"。
  /// [allowCategoryCreation] - 共享非 Owner 传 false，禁止创建个人分类。
  /// [allowedCategoryIds] - 非 null 时只允许目标账本 Owner 分类镜像 UUID。
  Future<ImportResult> importData(
    LocalRepository repo,
    String ledgerId,
    ImportData data, {
    void Function(int done, int total)? onProgress,
    void Function(String phase)? onPhase,
    bool recordChanges = true,
    String? authorMemberId,
    bool allowCategoryCreation = true,
    Set<String>? allowedCategoryIds,
  }) async {
    // 0. 入口统一校验：导入（CSV/云恢复）是脏数据的主要入口，
    // 非法分类/交易在这里拦截并计入 failed，不进入落库流程。
    int validationFailed = 0;
    int failedCount = 0;
    final validCategories = <ImportCategory>[];
    for (final c in data.categories) {
      final errors = validateImportCategory(c);
      if (errors.isEmpty) {
        if (allowCategoryCreation) {
          validCategories.add(c);
        } else {
          logger.warning(
            'ImportValidation',
            '共享非 Owner 账本禁止创建分类，忽略: ${c.parentName ?? ''}/${c.name}',
          );
        }
      } else {
        validationFailed++;
        logger.warning(
          'ImportValidation',
          '分类校验失败，跳过: ${c.name} -> ${errors.join('; ')}',
        );
      }
    }
    final validTransactions = <ImportTransaction>[];
    for (final t in data.transactions) {
      final errors = validateImportTransaction(t);
      if (errors.isEmpty) {
        validTransactions.add(t);
      } else {
        validationFailed++;
        logger.warning('ImportValidation', '交易校验失败，跳过: ${errors.join('; ')}');
      }
    }

    // 1. 更新账本信息（如果提供）
    if (data.ledgerName != null ||
        data.currency != null ||
        data.aaEnabled != null) {
      // 币种变更前先记下旧币种,用于变更后重算 nativeAmount。
      // 导入数据中可能携带不同于当前账本的 currency 字段(如从另一个币种
      // 的备份恢复),不重算会导致副行换算显示错误的旧口径金额。
      final normalizedCurrency = data.currency?.trim().toUpperCase();
      final nextCurrency = normalizedCurrency?.isNotEmpty == true
          ? normalizedCurrency
          : null;
      final String? oldCurrency = nextCurrency != null
          ? (await repo.getLedgerById(ledgerId))?.currency
          : null;
      var ledgerUpdateFailed = false;
      var metadataUpdated = false;
      // 元数据换币与历史快照重算必须原子提交；否则重算异常会留下新本位币
      // 配旧 nativeAmount，且旧快照通常不等于 amount，补折算检测也无法捞回。
      try {
        await repo.runInTransaction(() async {
          await repo.updateLedger(
            id: ledgerId,
            name: data.ledgerName,
            currency: nextCurrency,
            aaEnabled: data.aaEnabled,
            recordChanges: recordChanges,
          );
          metadataUpdated = true;
          if (nextCurrency != null &&
              oldCurrency != null &&
              nextCurrency != oldCurrency.trim().toUpperCase()) {
            await repo.recalcNativeAmountsForLedger(
              ledgerId,
              nextCurrency,
              previousBase: oldCurrency,
              recordChanges: recordChanges,
            );
          }
        });
      } catch (e, st) {
        if (!metadataUpdated) {
          // 保持既有导入契约：单纯元数据更新失败记入 failed 后继续导入明细。
          // 异常先离开外层事务触发完整回滚，再在这里降级，不能在事务内吞错。
          ledgerUpdateFailed = true;
          logger.error('ImportData', '更新账本元数据失败 ledgerId=$ledgerId', e, st);
        } else {
          // 重算失败必须继续上抛；外层事务已撤销元数据与同步变更，调用方可
          // 明确告知恢复失败，不能在旧本位币账本中继续导入新口径快照。
          rethrow;
        }
      }
      if (ledgerUpdateFailed) failedCount++;
    }

    // 2. 导入分类
    final categoryImport = await importCategories(
      repo,
      validCategories,
      recordChanges: recordChanges,
    );
    // 分类创建失败直接计入结果：不能只写日志让用户误以为全部成功。
    failedCount += categoryImport.failed;

    // 3. 导入交易（不含标签/附件关联步骤）
    final result = await importTransactions(
      repo,
      ledgerId,
      validTransactions,
      categoryCache: categoryImport.cache,
      onProgress: onProgress,
      onPhase: onPhase,
      recordChanges: recordChanges,
      authorMemberId: authorMemberId,
      allowedCategoryIds: allowedCategoryIds,
    );

    return ImportResult(
      inserted: result.inserted,
      failed: validationFailed + result.failed + failedCount,
      duplicateSkipped: result.duplicateSkipped,
    );
  }

  /// 导入分类(先一级后二级)。public — 备份/全量恢复路径复用。
  ///
  /// 唯一契约：父级作用域内唯一，缓存始终使用完整 [ImportCategoryPath]。
  /// 一级路径的 parentName 为 null，二级路径保留父分类名，跨父同名互不覆盖。
  /// 返回 (分类缓存, 创建失败计数)：单条失败只跳过该分类并计数，
  /// 不中断整批；调用方（importData）负责把失败数计入 ImportResult。
  Future<({Map<ImportCategoryPath, String> cache, int failed})>
  importCategories(
    LocalRepository repo,
    List<ImportCategory> categories, {
    bool recordChanges = true,
  }) async {
    final categoryCache = <ImportCategoryPath, String>{};
    var failed = 0;

    if (categories.isEmpty) return (cache: categoryCache, failed: failed);
    // 入口校验：非法分类（level 越界 / 二级缺父 / 非支出类）直接跳过；
    // 计数由调用方（importData）负责，这里兜底保护直接调用本方法的路径。
    final validCategories = categories
        .where((c) => validateImportCategory(c).isEmpty)
        .toList(growable: false);
    if (validCategories.length != categories.length) {
      logger.warning(
        'CategoryImport',
        '跳过 ${categories.length - validCategories.length} 条非法分类',
      );
    }
    logger.info('CategoryImport', '开始导入分类: ${validCategories.length} 个');
    final sw = Stopwatch()..start();
    int created = 0;

    try {
      // 获取所有现有分类
      // 全局仅支出模式，只查 expense 分类。
      final existingExpense = await repo.getTopLevelCategories('expense');
      final existingCategoryMap = <ImportCategoryPath, String>{};

      // 一级与二级都用 record 保存字段边界，分类名含分隔符时也不会串键。
      // 否则「购物>鞋子」「服装>鞋子」会扁平进同一 key 互相覆盖，CSV 导入
      // 「服装>鞋子」时命中「购物>鞋子」的 id，整批交易静默挂错分类。
      for (final cat in existingExpense) {
        existingCategoryMap[(
              kind: cat.kind,
              parentName: null,
              name: cat.name,
            )] =
            cat.id;
        // 获取子分类
        final subCats = await repo.getSubCategories(cat.id);
        for (final sub in subCats) {
          existingCategoryMap[(
                kind: sub.kind,
                parentName: cat.name,
                name: sub.name,
              )] =
              sub.id;
        }
      }

      // 分离一级和二级分类
      final level1 = validCategories
          .where((c) => c.level == 1 || c.parentName == null)
          .toList();
      final level2 = validCategories
          .where((c) => c.level == 2 && c.parentName != null)
          .toList();

      // 导入一级分类
      for (final cat in level1) {
        final key = (kind: cat.kind, parentName: null, name: cat.name);
        if (existingCategoryMap.containsKey(key)) {
          categoryCache[key] = existingCategoryMap[key]!;
        } else {
          try {
            final id = await repo.createCategory(
              name: cat.name,
              kind: cat.kind,
              icon: cat.icon,
              sortOrder: cat.sortOrder,
              recordChanges: recordChanges,
            );
            categoryCache[key] = id;
            created++;
          } catch (e, st) {
            // 单条分类落库失败只跳过该分类并计数，不中断整批导入；
            // 交易引用不到该分类时按「分类路径未命中」整笔失败。
            failed++;
            logger.error('CategoryImport', '创建一级分类失败: ${cat.name}', e, st);
          }
        }
      }

      // 导入二级分类
      for (final cat in level2) {
        final key = (
          kind: cat.kind,
          parentName: cat.parentName,
          name: cat.name,
        );
        if (existingCategoryMap.containsKey(key)) {
          categoryCache[key] = existingCategoryMap[key]!;
        } else {
          final parentKey = (
            kind: cat.kind,
            parentName: null,
            name: cat.parentName!,
          );
          final parentId = categoryCache[parentKey];
          if (parentId != null) {
            try {
              final id = await repo.createSubCategory(
                parentId: parentId,
                name: cat.name,
                kind: cat.kind,
                icon: cat.icon,
                sortOrder: cat.sortOrder,
                recordChanges: recordChanges,
              );
              categoryCache[key] = id;
              created++;
            } catch (e, st) {
              failed++;
              logger.error(
                'CategoryImport',
                '创建二级分类失败: ${cat.parentName}/${cat.name}',
                e,
                st,
              );
            }
          } else {
            failed++;
            logger.error(
              'CategoryImport',
              '创建二级分类失败，父分类未命中: ${cat.parentName}/${cat.name}',
              StateError('父分类缓存缺失'),
            );
          }
        }
      }
      logger.info(
        'CategoryImport',
        '分类导入完成: 新增=$created 已存在=${validCategories.length - created} 耗时=${sw.elapsedMilliseconds}ms',
      );
    } catch (e, st) {
      logger.error('CategoryImport', '分类导入失败', e, st);
    }

    return (cache: categoryCache, failed: failed);
  }

  /// 导入交易（统一 batch 路径）
  ///
  /// 全部走 `insertTransactionsBatchWithRelations` 统一批处理路径,500 条 / 批,
  /// 一个 db.transaction 内 batch insert tx + local_changes,
  /// 把 N 次 BEGIN/COMMIT/fsync 折叠成 1 次。
  ///
  /// public — 备份/全量恢复路径复用。
  Future<ImportResult> importTransactions(
    LocalRepository repo,
    String ledgerId,
    List<ImportTransaction> transactions, {
    required Map<ImportCategoryPath, String> categoryCache,
    void Function(int done, int total)? onProgress,

    /// 阶段回调：'rate' = 正在补拉汇率，'write' = 开始落库。
    /// 供 UI 展示「正在获取汇率…」等阶段文案，避免进度长时间不动引发误解。
    void Function(String phase)? onPhase,
    bool recordChanges = true,
    String? authorMemberId,
    Set<String>? allowedCategoryIds,
  }) async {
    int inserted = 0;
    int failed = 0;
    int processed = 0;
    int skippedDup = 0;
    final total = transactions.length;
    logger.info('TxImport', '开始导入交易: $total 条 (recordChanges=$recordChanges)');

    // 入口统一校验：同步 apply 等直接调用路径同样可能收到脏数据，
    // 非法交易计入 failed 并跳过，不拼进 SQL。
    final validTransactions = <ImportTransaction>[];
    for (final t in transactions) {
      final errors = validateImportTransaction(t);
      if (errors.isEmpty) {
        validTransactions.add(t);
      } else {
        failed++;
        logger.warning('TxImport', '交易校验失败，跳过: ${errors.join('; ')}');
      }
    }

    // 幂等防线：预取目标账本已存在的交易 UUID 主键集合。
    //
    // 为什么必须做：对"已有数据的账本"重复执行备份/全量恢复导入时，同一条
    // 交易会被再次 INSERT 而不报错，直接产生重复行（"下拉刷新数据翻倍" bug）。
    // 这里用一次全量查询建 Set（O(N) 内存换掉 N 次逐条查库），导入循环中
    // 命中的记录直接跳过，保证同一份数据重复导入天然幂等。
    //
    // 说明：无 UUID 的记录（如 CSV 导入）不受影响，保持普通插入行为。
    final existingSyncIds = <String>{};
    try {
      final existingTxs = await repo.getTransactionsByLedger(ledgerId);
      for (final t in existingTxs) {
        final sid = t.id;
        if (sid.isNotEmpty) {
          existingSyncIds.add(sid);
        }
      }
    } catch (e, st) {
      // 预取失败不阻断导入：本次导入跳过 UUID 去重，仅记录日志。
      logger.warning('TxImport', '预取已有交易 UUID 失败,本次导入不做去重: $e', st);
    }

    // 交易级多币种:批量预取本位币/有效汇率,
    // 逐条填 currencyCode + nativeAmount,不落 NULL(NULL 行补折算检测
    // 需 join 兜底)。
    final ledger = await repo.getLedgerById(ledgerId);
    final ledgerBase =
        ((ledger?.currency.isNotEmpty ?? false) ? ledger!.currency : 'CNY')
            .toUpperCase();
    Map<String, EffectiveRate> importRates = <String, EffectiveRate>{};
    try {
      final autos = await repo.getLatestAutoRates(ledgerBase);
      final overrides = await repo.getOverrides(ledgerBase);
      importRates = mergeEffectiveRates(
        autoRates: [
          for (final r in autos)
            (quote: r.quoteCurrency, rate: r.rate, rateDate: r.rateDate),
        ],
        overrides: [
          for (final o in overrides) (quote: o.quoteCurrency, rate: o.rate),
        ],
      );
    } catch (e, st) {
      logger.warning('TxImport', '读取本地汇率失败，缺少有效汇率的外币交易将被拒绝: $e', st);
    }

    // 导入补拉汇率：扫描交易中出现但本地汇率表缺失的外币币种，
    // 从公网拉取并缓存，避免外币交易按 1:1 入账导致统计失真
    // （如：导入美元100但账本币种是人民币，无汇率时直接按100入账，
    //   列表和统计全部显示 ¥100，数据严重失真）。
    final missingCurrencies = <String>{};
    for (final tx in validTransactions) {
      // 恢复数据携带的是交易发生时的真实折算快照；用今天的汇率覆盖既不准确，
      // 也会让离线恢复平白依赖网络，因此这类交易不参与补拉扫描。
      if (tx.nativeAmount != null) continue;
      final cur =
          ((tx.currencyCode?.isNotEmpty ?? false) ? tx.currencyCode! : null)
              ?.trim()
              .toUpperCase();
      if (cur != null && cur != ledgerBase && !importRates.containsKey(cur)) {
        missingCurrencies.add(cur);
      }
    }
    if (missingCurrencies.isNotEmpty) {
      // 缺少汇率需要访问公网：先报告汇率阶段，让 UI 展示阶段文案。
      onPhase?.call('rate');
      try {
        // fetch(base) 返回「1 base = x quote」全量汇率表
        final result = await _exchangeRateService.fetch(ledgerBase);
        // 倒数成「1 quote = x base」方向，与 computeNativeAmount 口径一致
        final inverted = <String, String>{};
        for (final e in result.ratesBaseToQuote.entries) {
          final raw = double.tryParse(e.value);
          if (raw != null && raw > 0) {
            inverted[e.key.toUpperCase()] = invertRate(raw);
          }
        }
        // 只补齐本地缺失的币种，不覆盖已有的手动覆盖汇率
        var filled = 0;
        for (final cur in missingCurrencies) {
          if (inverted.containsKey(cur) && !importRates.containsKey(cur)) {
            importRates[cur] = EffectiveRate(
              rate: inverted[cur]!,
              manual: false,
              rateDate: result.rateDate,
            );
            filled++;
          }
        }
        // 缓存到本地汇率表，后续导入/记账可直接复用
        if (inverted.isNotEmpty) {
          await repo.upsertAutoRates(
            base: ledgerBase,
            rateDate: result.rateDate,
            rates: inverted,
            source: result.source,
            fetchedAt: DateTime.now().toUtc(),
          );
        }
        logger.info(
          'TxImport',
          '导入补拉汇率: base=$ledgerBase 缺失=${missingCurrencies.length} 补齐=$filled source=${result.source}',
        );
      } catch (e, st) {
        logger.warning(
          'TxImport',
          '导入补拉汇率失败，缺失币种将逐行拒绝 '
              'base=$ledgerBase currencies=${missingCurrencies.join(",")}: $e',
          st,
        );
      }
    }

    // 汇率准备完毕（或无需补拉），进入落库阶段。
    onPhase?.call('write');
    final overallSw = Stopwatch()..start();

    const batchSize = 500;
    // 批次缓冲:tx 列表
    final batchTx = <TransactionsCompanion>[];

    // 把当前缓冲 flush 到 repo。捕获异常时整批算 failed,继续下一批。
    Future<void> flush() async {
      if (batchTx.isEmpty) return;
      final size = batchTx.length;
      final batchSw = Stopwatch()..start();
      try {
        final ids = await repo.insertTransactionsBatchWithRelations(
          transactions: List.of(batchTx),
          recordChanges: recordChanges,
        );
        inserted += ids.length;
        logger.info(
          'TxImport',
          'flush 批次: size=$size 耗时=${batchSw.elapsedMilliseconds}ms 累计=${processed + size}/$total',
        );
      } catch (e, st) {
        logger.error('TxImport', '批次 flush 失败,本批 $size 条算 failed', e, st);
        failed += size;
      }
      processed += size;
      batchTx.clear();
      if (onProgress != null) onProgress(processed, total);
    }

    for (final tx in validTransactions) {
      // 按 UUID 幂等去重：本地已存在、或本批次内重复出现的 UUID 一律跳过，
      // 避免恢复把快照重复插入本地（修复下拉刷新数据翻倍 bug）。
      // 跳过的记录计入 processed 以保证进度回调准确，但不计入 inserted/failed。
      final sid = tx.syncId;
      if (sid != null && sid.isNotEmpty) {
        if (existingSyncIds.contains(sid)) {
          skippedDup++;
          processed++;
          if (onProgress != null) onProgress(processed, total);
          continue;
        }
      }
      // 主键 UUID：备份/恢复携带 syncId 时以它作为交易 id（本地即云端 ID），
      // CSV 导入无 id 则客户端现场生成，保证离线可写。
      final txId = (sid != null && sid.isNotEmpty) ? sid : _uuid.v4();

      // 解析分类ID（新 schema 为 UUID 字符串）
      String? categoryId;
      String? categoryFailure;
      if (tx.categoryId != null) {
        categoryId = tx.categoryId.toString();
        if (allowedCategoryIds != null &&
            !allowedCategoryIds.contains(categoryId)) {
          categoryFailure = '分类 UUID 不属于目标账本 Owner 镜像: $categoryId';
        }
      } else if (tx.categoryName != null && tx.categoryKind != null) {
        final key = (
          kind: tx.categoryKind!,
          parentName: tx.categoryParentName,
          name: tx.categoryName!,
        );
        categoryId = categoryCache[key];
        if (categoryId == null) {
          categoryFailure =
              '分类路径未命中: kind=${tx.categoryKind} '
              'parent=${tx.categoryParentName} name=${tx.categoryName}';
        }
      }
      if (categoryFailure != null) {
        // 分类是交易语义的一部分；解析或权限校验失败必须跳过该笔，
        // 不能擅自降级成同名一级分类、私有分类或未分类。
        failed++;
        processed++;
        logger.warning('TxImport', '$categoryFailure，跳过交易');
        if (onProgress != null) onProgress(processed, total);
        continue;
      }

      // 交易币种 = CSV 币种列(显式) ?? 本位币;
      // 折算快照同币种 = amount，外币必须命中有效汇率或携带源快照。
      final txCurrency =
          ((tx.currencyCode?.trim().isNotEmpty ?? false)
              ? tx.currencyCode!.trim().toUpperCase()
              : null) ??
          ledgerBase;
      // 金额与快照都是规范化 decimal 字符串直写,不做整数分换算;
      // 源端 nativeAmount 快照是导出时按当时汇率的真实折算结果,本地重算会因
      // 汇率时点不同而失真,故快照有值时优先采用;缺键(CSV 导入)才走本地重算。
      final amountText = normalizeDecimal(tx.amount);
      String? txNative;
      if (tx.nativeAmount != null) {
        txNative = normalizeDecimal(tx.nativeAmount!);
      } else if (txCurrency == ledgerBase) {
        txNative = amountText;
      } else {
        txNative = computeNativeAmountDecimal(
          amount: amountText,
          txCurrency: txCurrency,
          ledgerBase: ledgerBase,
          rates: importRates,
        );
      }
      if (txNative == null) {
        failed++;
        processed++;
        logger.warning(
          'TxImport',
          '缺少有效汇率，跳过外币交易 '
              'ledger=$ledgerId base=$ledgerBase currency=$txCurrency '
              'syncId=${sid ?? "csv"}',
        );
        if (onProgress != null) onProgress(processed, total);
        continue;
      }

      // 分类和汇率都已解析后再登记 UUID；失败交易不能占用幂等键，
      // 否则同批后续合法记录会被误判为重复。
      if (sid != null && sid.isNotEmpty) existingSyncIds.add(sid);

      // 构建交易记录:主键/时间戳由客户端现场生成(离线可写,本地即云端 ID),
      // 金额为规范化 decimal 字符串,无 syncId 列。
      final now = DateTime.now().toUtc();
      final txCompanion = TransactionsCompanion.insert(
        id: txId,
        ledgerId: ledgerId,
        txType: tx.type,
        amount: amountText,
        categoryId: d.Value(categoryId),
        happenedAt: tx.happenedAt,
        note: d.Value(tx.note),
        currencyCode: txCurrency,
        nativeAmount: txNative,
        // 缺键(JSON/CSV)落默认 false,与 server snapshot「缺键 = false」语义对齐。
        excludeFromStats: d.Value(tx.excludeFromStats ?? false),
        // 支出人/创建者:手动导入以当前操作者身份为准（导入路径不承载 AA 分摊）。
        payerMemberId: d.Value(authorMemberId ?? ''),
        // 创建者/编辑者:手动导入以当前身份回填,解决详情页作者位为空;
        // 备份/恢复不传,保持 null 由快照后续覆盖。
        createdByMemberId: authorMemberId == null
            ? const d.Value.absent()
            : d.Value(authorMemberId),
        lastEditedByMemberId: authorMemberId == null
            ? const d.Value.absent()
            : d.Value(authorMemberId),
        createdAt: now,
        updatedAt: now,
      );

      batchTx.add(txCompanion);

      if (batchTx.length >= batchSize) {
        await flush();
      }
    }

    // 刷剩余
    await flush();

    logger.info(
      'TxImport',
      '交易导入完成: 总数=$total 成功=$inserted 失败=$failed '
          '跳过重复(UUID)=$skippedDup 总耗时=${overallSw.elapsedMilliseconds}ms',
    );
    return ImportResult(
      inserted: inserted,
      failed: failed,
      duplicateSkipped: skippedDup,
    );
  }
}

/// 全局单例
final dataImportService = DataImportService();
