/// 统计查询入口：分析页与首页的聚合查询统一走本入口，不直连仓储大门面。
///
/// 这些查询全是只读聚合（分类层级汇总、折线序列、笔数、共享账本合成分类），
/// 放在 application 层后，页面只负责取数与渲染，聚合口径的变更集中在此。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 分类层级聚合行（一级/二级分类及其区间总额）。
typedef CategoryHierarchyTotal = ({
  String? id,
  String name,
  String? icon,
  String? parentId,
  int level,
  double total,
});

/// 统计查询。
class StatisticsQueries {
  StatisticsQueries(this.ref);

  /// 持有 Ref 是为了与 [LedgerStorageActions] 保持一致的入口形态。
  final Ref ref;

  LocalRepository get _repo => ref.read(repositoryProvider);

  /// 年视图折线：按月聚合某年某收支类型的总额。
  Future<List<({DateTime month, double total})>> totalsByMonth({
    required String ledgerId,
    required String type,
    required int year,
  }) => _repo.totalsByMonth(ledgerId: ledgerId, type: type, year: year);

  /// 非年视图折线：按日聚合区间内某收支类型的总额。
  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) =>
      _repo.totalsByDay(ledgerId: ledgerId, type: type, start: start, end: end);

  /// 区间内分类层级聚合（含二级分类明细行）。
  Future<List<CategoryHierarchyTotal>> totalsByCategoryWithHierarchy({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _repo.totalsByCategoryWithHierarchy(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  /// 区间内某收支类型的交易笔数。
  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) => _repo.countByTypeInRange(
    ledgerId: ledgerId,
    type: type,
    start: start,
    end: end,
  );

  /// 共享账本的镜像分类（按合成 id 索引），用于把聚合行映射回真实分类。
  Future<Map<String, CategoryDisplay>> sharedSyntheticCategories(
    String ledgerId,
  ) async => (await _repo.getSharedSyntheticCategoriesForLedger(
    ledgerId,
  )).map((id, row) => MapEntry(id, row.toDisplay()));

  /// 批量取回分类（避免循环内逐条查询的 N+1）。
  Future<Map<String, CategoryDisplay>> categoriesByIds(
    Iterable<String> ids,
  ) async => (await _repo.getCategoriesByIds(
    ids,
  )).map((id, row) => MapEntry(id, row.toDisplay()));

  /// 监听账本内「不分摊」的交易（AA 统计页明细行用，过滤下沉到数据层）。
  Stream<List<({TransactionDisplay t, CategoryDisplay? category})>>
  watchExcludedAa(String ledgerId) => _repo
      .watchExcludedAaTransactions(ledgerId)
      .map(
        (rows) => rows
            .map(
              (row) =>
                  (t: row.t.toDisplay(), category: row.category?.toDisplay()),
            )
            .toList(growable: false),
      );
}

/// 统计查询 provider。
final statisticsQueriesProvider = Provider<StatisticsQueries>(
  (ref) => StatisticsQueries(ref),
);
