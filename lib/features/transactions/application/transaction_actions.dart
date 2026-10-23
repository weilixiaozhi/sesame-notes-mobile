/// 交易用例编排与查询入口：UI 与仓储之间的唯一入口。
///
/// 交易、分摊、编辑历史、周期账单与汇率覆盖集中在应用层编排，
/// 页面读取 StreamProvider 并通过 [TransactionActions] 提交写入。
library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/models/transaction_split_input.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/application/ports/mutation_executor.dart';
import 'package:sesame_notes/shared/providers/mutation_executor_provider.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/recurring_transaction_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';

/// 分类详情按固定账本解析父子分类，账号之间相同模板 ID 不会共用缓存。
final categorySubsMapProvider = StreamProvider.autoDispose
    .family<
      Map<String, CategoryDisplay>,
      ({String categoryId, String ledgerId})
    >((ref, query) {
      ref.watch(currentAccountIdProvider);
      ref.watch(authIdentityGenerationProvider);
      return ref
          .watch(categoryQueriesProvider)
          .watchCategoryWithSubs(query.categoryId, ledgerId: query.ledgerId)
          .map(
            (categories) => {
              for (final row in categories) row.id: row.toDisplay(),
            },
          );
    });

/// 分类下的交易流（一级分类汇总需包含二级分类交易，故固定含子分类）。
final categoryTransactionsProvider = StreamProvider.autoDispose
    .family<List<TransactionDisplay>, ({String categoryId, String ledgerId})>((
      ref,
      params,
    ) {
      ref.watch(currentAccountIdProvider);
      ref.watch(authIdentityGenerationProvider);
      return ref
          .watch(categoryQueriesProvider)
          .watchTransactionsByCategory(
            params.categoryId,
            ledgerId: params.ledgerId,
            includeSubCategories: true,
          )
          .map(
            (rows) =>
                rows.map((row) => row.toDisplay()).toList(growable: false),
          );
    });

/// 所有周期账单的页面展示流。
final recurringTransactionDisplaysProvider =
    StreamProvider.autoDispose<List<RecurringTransactionDisplay>>((ref) {
      return ref
          .watch(transactionDataAccessProvider)
          .watchAllRecurringTransactions()
          .map(
            (rows) =>
                rows.map((row) => row.toDisplay()).toList(growable: false),
          );
    });

/// 交易用例编排。
class TransactionActions {
  /// 使用应用容器解析当前账号的数据与写入生命周期端口。
  TransactionActions(this.ref);

  /// 每次用例读取当前账号的交易仓储与同步协调器。
  final Ref ref;

  TransactionRepository get _repo => ref.read(transactionDataAccessProvider);

  /// 只公开本机写用例能力，避免交易用例绑定同步网络操作。
  MutationExecutor get _mutations => ref.read(mutationExecutorProvider);

  // ==================== 查询 ====================

  /// 按 id 取交易；已删除返回 null。
  Future<TransactionDisplay?> getById(String id) async =>
      (await _repo.getTransactionById(id))?.toDisplay();

  /// 取交易的指定分摊行（aa_mode=2 时落行）。
  Future<List<TransactionSplitDisplay>> getSplits(String transactionId) async =>
      (await _repo.getTransactionSplits(
        transactionId,
      )).map((row) => row.toDisplay()).toList(growable: false);

  /// 监听某账本指定月份的交易（首页月度分页的数据源）。
  Stream<List<({TransactionDisplay t, CategoryDisplay? category})>>
  watchByMonth({required String ledgerId, required DateTime month}) => _repo
      .watchTransactionsWithCategoryInMonth(ledgerId: ledgerId, month: month)
      .map(
        (rows) => rows
            .map(
              (row) =>
                  (t: row.t.toDisplay(), category: row.category?.toDisplay()),
            )
            .toList(growable: false),
      );

  // ==================== 交易日用例 ====================

  /// 新增交易，返回新交易 id。
  Future<String> add({
    required String ledgerId,
    required String type,
    required String amount,
    String? categoryId,
    required DateTime happenedAt,
    String? note,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) => _writeActiveLedger(
    ledgerId,
    () => _repo.addTransaction(
      ledgerId: ledgerId,
      type: type,
      amount: amount,
      categoryId: categoryId,
      happenedAt: happenedAt,
      note: note,
      currencyCode: currencyCode,
      nativeAmount: nativeAmount,
      payerMemberId: payerMemberId,
      aaMode: aaMode,
      splits: splits,
      operatorMemberId: operatorMemberId,
    ),
  );

  /// 原子提交交易、分摊、同步变更与同版本号的本地编辑历史。
  Future<int> edit({
    required String id,
    required String type,
    required String amount,
    String? categoryId,
    String? note,
    DateTime? happenedAt,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
    required String historySummary,
  }) async {
    try {
      return await _mutations.runDataMutation(() async {
        final repo = _repo;
        return repo.runInTransaction(() async {
          final transaction = await repo.getTransactionById(id);
          if (transaction != null) {
            await repo.requireActiveLedger(transaction.ledgerId);
          }
          final version = await repo.updateTransaction(
            id: id,
            type: type,
            amount: amount,
            categoryId: categoryId,
            note: note,
            happenedAt: happenedAt,
            currencyCode: currencyCode,
            nativeAmount: nativeAmount,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: splits,
            operatorMemberId: operatorMemberId,
          );
          // 历史仅在本机落库；写入失败由外层事务一并回滚交易与同步队列。
          await repo.appendEditHistory(
            recordId: id,
            version: version,
            operatorMemberId: operatorMemberId,
            summary: historySummary,
          );
          return version;
        });
      });
    } catch (error) {
      // 仓储写入边界已记录堆栈，应用层只补充操作上下文，
      // 不重复落一份堆栈。
      logger.error('TransactionActions', '编辑交易失败: $id', error);
      rethrow;
    }
  }

  /// 删除交易（仓储内部已清理编辑历史并登记云端 delete）。
  Future<void> delete(String id) =>
      _mutations.runDataMutation(() => _delete(id));

  /// 在已取得生命周期保护的用例内校验账本并原子删除。
  Future<void> _delete(String id) async {
    try {
      await _repo.runInTransaction(() async {
        final transaction = await _repo.getTransactionById(id);
        if (transaction != null) {
          await _repo.requireActiveLedger(transaction.ledgerId);
        }
        await _repo.deleteTransaction(id);
      });
    } catch (error) {
      // 仓储写入边界已记录堆栈，应用层只补充操作上下文，
      // 不重复落一份堆栈。
      logger.error('TransactionActions', '删除交易失败: $id', error);
      rethrow;
    }
  }

  /// 前台提交与归档校验共用事务，防止表单打开后账本已被归档。
  Future<T> _writeActiveLedger<T>(
    String ledgerId,
    Future<T> Function() write,
  ) async {
    try {
      return await _mutations.runDataMutation(() async {
        // 仓储在进入队列后获取，校验与修改共用同一身份和数据库事务。
        final repo = _repo;
        return repo.runInTransaction(() async {
          await repo.requireActiveLedger(ledgerId);
          return write();
        });
      });
    } catch (error) {
      // 仓储写入边界已记录堆栈，应用层只补充操作上下文，
      // 不重复落一份堆栈。
      logger.error('TransactionActions', '提交账本记录失败: $ledgerId', error);
      rethrow;
    }
  }

  // ==================== 汇率覆盖 ====================

  /// 写入人工汇率；rate 原样保存用户输入，不二次格式化。
  ///
  /// 非法汇率（0/NaN/Infinity/-Infinity/1e999 等非有限正数）在入口拦截并上抛，
  /// 不落库：输入框的字符过滤挡不住粘贴与程序回填。
  Future<void> setRateOverride({
    required String base,
    required String quote,
    required String rate,
  }) async {
    try {
      if (!isValidRateInput(rate)) {
        throw FormatException('汇率必须是有效的有限正数', rate);
      }
      await _mutations.runDataMutation(
        () => _repo.setOverride(base: base, quote: quote, rate: rate),
      );
    } catch (error, stackTrace) {
      logger.error('TransactionActions', '保存人工汇率失败', error, stackTrace);
      rethrow;
    }
  }

  /// 移除人工汇率，恢复自动汇率。
  Future<void> removeRateOverride({
    required String base,
    required String quote,
  }) async {
    try {
      await _mutations.runDataMutation(
        () => _repo.removeOverride(base: base, quote: quote),
      );
    } catch (error, stackTrace) {
      logger.error('TransactionActions', '移除人工汇率失败', error, stackTrace);
      rethrow;
    }
  }

  // ==================== 周期账单点用例 ====================

  /// 新增周期账单，返回新 id。
  Future<String> addRecurring({
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
    String? timeZone,
    required DateTime startDate,
    DateTime? endDate,
    bool enabled = true,
  }) => _writeActiveLedger(
    ledgerId,
    () => _repo.addRecurringTransaction(
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
      timeZone: timeZone,
      startDate: startDate,
      endDate: endDate,
      enabled: enabled,
    ),
  );

  /// 更新周期账单；协议 1 的生成进度由执行链维护，页面不得清空。
  Future<void> updateRecurring({
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
    String? timeZone,
    required DateTime startDate,
    DateTime? endDate,
    bool? enabled,
    bool clearLastGeneratedDate = false,
  }) => _writeActiveLedger(
    ledgerId,
    () => _writeRecurring(
      id,
      () => _repo.updateRecurringTransaction(
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
        timeZone: timeZone,
        startDate: startDate,
        endDate: endDate,
        enabled: enabled,
        clearLastGeneratedDate: clearLastGeneratedDate,
      ),
    ),
  );

  /// 删除周期账单。
  Future<void> deleteRecurring(String id) => _mutations.runDataMutation(
    () => _writeRecurring(id, () => _repo.deleteRecurringTransaction(id)),
  );

  /// 对已打开的周期单按当前归属再次校验，归档时保留模板原有设置。
  Future<void> _writeRecurring(String id, Future<void> Function() write) async {
    try {
      await _repo.runInTransaction(() async {
        final recurring = (await _repo.getAllRecurringTransactions())
            .where((row) => row.id == id)
            .firstOrNull;
        if (recurring != null) {
          await _repo.requireActiveLedger(recurring.ledgerId);
        }
        await write();
      });
    } catch (error) {
      // 仓储写入边界已记录堆栈，应用层只补充操作上下文，
      // 不重复落一份堆栈。
      logger.error('TransactionActions', '修改周期账单失败: $id', error);
      rethrow;
    }
  }
}

/// 交易用例编排 provider。
final transactionActionsProvider = Provider<TransactionActions>(
  (ref) => TransactionActions(ref),
);
