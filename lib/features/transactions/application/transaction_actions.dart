/// 交易用例编排与查询入口：UI 与仓储之间的唯一入口。
///
/// 设计意图：交易的写入（新增/编辑/删除/AA 分摊/编辑历史）与周期账单、汇率
/// 覆盖都是带副作用的用例，过去由页面与共享组件直接调用仓储大门面，页面测试
/// 必须 mock 整个仓储。收敛到本文件后，页面只负责交互与提示，查询走本文件
/// 暴露的 StreamProvider，写操作走 [TransactionActions]。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/mappers/recurring_transaction_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_metadata_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/recurring_transaction_display.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 分类及其所有子分类的 id → 分类映射（分类详情页按交易分类 id 查图标与名称）。
///
/// 分类主键即 UUID 字符串：本地分类查询天然覆盖共享账本（共享镜像与主表
/// 引用同一分类 UUID）。
final categorySubsMapProvider =
    StreamProvider.family<Map<String, CategoryDisplay>, String>((
      ref,
      categoryId,
    ) {
      return ref
          .watch(repositoryProvider)
          .watchCategoryWithSubs(categoryId)
          .map(
            (categories) => {
              for (final row in categories) row.id: row.toDisplay(),
            },
          );
    });

/// 分类下的交易流（一级分类汇总需包含二级分类交易，故固定含子分类）。
final categoryTransactionsProvider =
    StreamProvider.family<
      List<TransactionDisplay>,
      ({String categoryId, String ledgerId})
    >((ref, params) {
      return ref
          .watch(repositoryProvider)
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
          .watch(repositoryProvider)
          .watchAllRecurringTransactions()
          .map(
            (rows) =>
                rows.map((row) => row.toDisplay()).toList(growable: false),
          );
    });

/// 交易用例编排。
class TransactionActions {
  TransactionActions(this.ref);

  /// 持有 Ref 是为了与 [LedgerStorageActions] 保持一致的编排入口形态。
  final Ref ref;

  LocalRepository get _repo => ref.read(repositoryProvider);

  // ==================== 查询 ====================

  /// 按 id 取交易；已删除返回 null。
  Future<TransactionDisplay?> getById(String id) async =>
      (await _repo.getTransactionById(id))?.toDisplay();

  /// 取交易的指定分摊行（aa_mode=2 时落行）。
  Future<List<TransactionSplitDisplay>> getSplits(String transactionId) async =>
      (await _repo.getTransactionSplits(
        transactionId,
      )).map((row) => row.toDisplay()).toList(growable: false);

  /// 取账本成员列表（AA 参与人与操作者解析都依赖它）。
  Future<List<LedgerMemberDisplay>> getMembers(String ledgerId) async =>
      (await _repo.getMembersByLedger(
        ledgerId,
      )).map((member) => member.toDisplay()).toList(growable: false);

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
    bool excludeFromStats = false,
    String? currencyCode,
    String? nativeAmount,
    String? payerMemberId,
    int? aaMode,
    List<TransactionSplitInput>? splits,
    String? operatorMemberId,
  }) => _repo.addTransaction(
    ledgerId: ledgerId,
    type: type,
    amount: amount,
    categoryId: categoryId,
    happenedAt: happenedAt,
    note: note,
    excludeFromStats: excludeFromStats,
    currencyCode: currencyCode,
    nativeAmount: nativeAmount,
    payerMemberId: payerMemberId,
    aaMode: aaMode,
    splits: splits,
    operatorMemberId: operatorMemberId,
  );

  /// 编辑交易，返回写入后的新版本号（用于同版本号写编辑历史）。
  Future<int> update({
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
  }) => _repo.updateTransaction(
    id: id,
    type: type,
    amount: amount,
    categoryId: categoryId,
    note: note,
    happenedAt: happenedAt,
    excludeFromStats: excludeFromStats,
    currencyCode: currencyCode,
    nativeAmount: nativeAmount,
    payerMemberId: payerMemberId,
    aaMode: aaMode,
    splits: splits,
    operatorMemberId: operatorMemberId,
  );

  /// 删除交易（仓储内部已清理编辑历史并登记云端 delete）。
  Future<void> delete(String id) => _repo.deleteTransaction(id);

  /// 追加一条编辑历史快照；[version] 取 [update] 返回的新版本号，
  /// 使 transactions.version 与 record_edit_histories.version 一一对应。
  Future<int> appendHistory({
    required String recordId,
    required int version,
    String? operatorMemberId,
    required String summary,
  }) => _repo.appendEditHistory(
    recordId: recordId,
    version: version,
    operatorMemberId: operatorMemberId,
    summary: summary,
  );

  // ==================== 汇率覆盖 ====================

  /// 写入人工汇率；rate 原样保存用户输入，不二次格式化。
  Future<void> setRateOverride({
    required String base,
    required String quote,
    required String rate,
  }) => _repo.setOverride(base: base, quote: quote, rate: rate);

  /// 移除人工汇率，恢复自动汇率。
  Future<void> removeRateOverride({
    required String base,
    required String quote,
  }) => _repo.removeOverride(base: base, quote: quote);

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
    required DateTime startDate,
    DateTime? endDate,
    bool enabled = true,
  }) => _repo.addRecurringTransaction(
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

  /// 更新周期账单；[clearLastGeneratedDate] 在开始日期提前到已生成日期之前时置 true。
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
    required DateTime startDate,
    DateTime? endDate,
    bool? enabled,
    bool clearLastGeneratedDate = false,
  }) => _repo.updateRecurringTransaction(
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

  /// 删除周期账单。
  Future<void> deleteRecurring(String id) =>
      _repo.deleteRecurringTransaction(id);

  /// 启停周期账单。
  Future<void> toggleRecurring(String id, bool enabled) =>
      _repo.toggleRecurringTransaction(id, enabled);
}

/// 交易用例编排 provider。
final transactionActionsProvider = Provider<TransactionActions>(
  (ref) => TransactionActions(ref),
);
