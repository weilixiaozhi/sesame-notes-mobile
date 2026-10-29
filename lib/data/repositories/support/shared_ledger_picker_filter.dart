library;

import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/support/ledger_category_catalog.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:drift/drift.dart';

/// 分类选择按固定账本从精确目录读取，不同所有者的分类和墓碑相互独立。

import 'package:sesame_notes/data/db.dart';

/// 当前 ledger 上下文 — 由 picker 调用方解析后传入。
class LedgerPickerContext {
  const LedgerPickerContext({required this.ledgerId});

  /// 当前 ledger 的 UUID。null 时不过滤(单人账本兜底)。
  final String? ledgerId;
}

extension SharedLedgerPickerFilter on SesameDatabase {
  /// 从本地 ledgers 表解析当前 ledger 的 picker 上下文。
  Future<LedgerPickerContext?> loadLedgerPickerContext(String? ledgerId) async {
    try {
      if (ledgerId == null) return null;
      final ledger =
          await (select(ledgers)..where(
                (row) => row.id.equals(ledgerId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (ledger == null) throw StateError('账本不存在或已删除');
      return LedgerPickerContext(ledgerId: ledger.id);
    } catch (error, stackTrace) {
      logger.error('CategoryPicker', '读取分类选择账本归属失败', error, stackTrace);
      rethrow;
    }
  }

  /// 固定账本从其真实目录选择分类，无账本参数时只使用调用方已经限定的私有列表。
  Future<List<CategorySnapshot>> filterCategoriesForLedger(
    List<CategorySnapshot> all,
    LedgerPickerContext? ctx, {
    String? kind,
    bool topLevelOnly = true,
  }) async {
    try {
      final Iterable<CategorySnapshot> candidates = ctx?.ledgerId == null
          ? all
          : (await readLedgerCategoryCatalog(this, ctx!.ledgerId!)).values;
      return candidates
          .where(
            (row) =>
                row.deletedAt == null &&
                (kind == null || kind.isEmpty || row.kind == kind) &&
                (!topLevelOnly || row.parentId == null),
          )
          .toList();
    } catch (error, stackTrace) {
      logger.error('CategoryPicker', '读取账本可用分类失败', error, stackTrace);
      rethrow;
    }
  }
}
