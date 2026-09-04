/// 共享账本 picker 过滤工具。
///
/// 所有分类 id 均为 UUID：SharedLedgerCategories 行的 categoryId
/// 就是 Owner 的 user-global 分类 UUID，Editor 选择后直接写入交易的
/// category_id（本地与云端同一 id）。
///
/// picker 数据源策略:
/// - **单人账本 / Owner 视角**:直接读主表(本来就是用户自己 user-global)。
/// - **共享账本 + Editor 视角**:**完全替换** — 把 SharedLedgerCategories 行
///   转 Category 返回(id 即 Owner 的分类 UUID)。
library;

import 'package:drift/drift.dart' show OrderingTerm;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';

/// 当前 ledger 上下文 — 由 picker 调用方解析后传入。
class LedgerPickerContext {
  const LedgerPickerContext({
    required this.ledgerId,
    required this.isShared,
    required this.myRole,
  });

  /// 当前 ledger 的 UUID。null 时不过滤(单人账本兜底)。
  final String? ledgerId;
  final bool isShared;
  final String myRole;

  bool get isEditorInShared => isShared && myRole != 'owner';
}

extension SharedLedgerPickerFilter on SesameDatabase {
  /// 从本地 ledgers 表解析当前 ledger 的 picker 上下文。
  Future<LedgerPickerContext?> loadLedgerPickerContext(String? ledgerId) async {
    if (ledgerId == null) return null;
    final l = await (select(
      ledgers,
    )..where((t) => t.id.equals(ledgerId))).getSingleOrNull();
    if (l == null) return null;
    return LedgerPickerContext(
      ledgerId: l.id,
      isShared: l.memberCount > 1,
      myRole: l.role,
    );
  }

  /// 拿 picker 用的 categories:Editor + 共享账本 → SharedLedger* 转本地行;
  /// 单人账本 / Owner → 主表 raw 数据。
  Future<List<Category>> filterCategoriesForLedger(
    List<Category> all,
    LedgerPickerContext? ctx, {
    String? kind,
    bool topLevelOnly = true,
  }) async {
    if (ctx == null || !ctx.isEditorInShared || ctx.ledgerId == null) {
      return all;
    }
    final q = select(sharedLedgerCategories)
      ..where((t) => t.ledgerId.equals(ctx.ledgerId!))
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (kind != null && kind.isNotEmpty) {
      q.where((t) => t.kind.equals(kind));
    }
    if (topLevelOnly) {
      q.where((t) => t.level.equals(1));
    }
    final shared = await q.get();
    return shared.map(_sharedCategoryAsMain).toList();
  }

  /// 共享账本 Editor 视角的分类树：一次查询该账本全部共享分类行，
  /// 内存拆分一级/二级（id 即 Owner 分类 UUID，父子链用 parentId 直连）。
  Future<CategoryRowTree> getSharedCategoryPickerTree(
    String ledgerId,
    String kind,
  ) async {
    final rows =
        await (select(sharedLedgerCategories)
              ..where((t) => t.ledgerId.equals(ledgerId))
              ..where((t) => t.kind.equals(kind))
              ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
            .get();
    final topLevel = <Category>[];
    final children = <String, List<Category>>{};
    for (final s in rows) {
      final cat = _sharedCategoryAsMain(s);
      if (s.level == 1) {
        topLevel.add(cat);
      } else if (s.level == 2 && cat.parentId != null) {
        (children[cat.parentId!] ??= []).add(cat);
      }
    }
    return CategoryRowTree(topLevel: topLevel, children: children);
  }

  /// 把 SharedLedgerCategory 转成 Category（id 即 Owner 的分类 UUID）。
  Category _sharedCategoryAsMain(SharedLedgerCategory c) {
    return Category(
      id: c.categoryId,
      name: c.name,
      kind: c.kind,
      icon: c.icon,
      sortOrder: c.sortOrder,
      parentId: c.parentId,
      level: c.level,
      updatedAt: c.updatedAt,
    );
  }
}
