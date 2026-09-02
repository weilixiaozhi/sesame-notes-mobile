/// 记账页分类树缓存 provider。
///
/// 三层设计：
/// - **合并查询**：一次 select 取回该 kind 全部 level 1+2，内存分组（消灭 N+1）；
/// - **全局常驻缓存**（非 autoDispose）：app 启动即预热，sheet 打开时首帧命中；
/// - **零手动 invalidate**：以 Drift tableUpdates 监听 categories /
///   sharedLedgerCategories / ledgers 三表，所有分类变更自动触发重建。
library;

import 'dart:async';
import 'dart:collection';

import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/repositories/support/shared_ledger_picker_filter.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 自愈拉取冷却时间：同一 ledger 5 分钟内不重复触发（随同步层重建恢复拉取）。
const _selfHealCooldown = Duration(minutes: 5);

/// per-ledger 的下次允许拉取时间(UTC 时间戳)。
final selfHealCooldownProvider = Provider<HashMap<String, DateTime>>(
  (ref) => HashMap<String, DateTime>(),
);

/// 记账页分类树。family 参数为分类 kind（全局仅支出模式，恒为 'expense'）。
final categoryPickerTreeProvider =
    StreamProvider.family<CategoryPickerTree, String>((ref, kind) {
      final repo = ref.watch(repositoryProvider);
      // 切账本即重建:共享账本 Editor 视角的分类树取决于当前账本上下文。
      final ledgerId = ref.watch(currentLedgerIdProvider);

      final db = repo.db;

      Future<CategoryPickerTree> load() async {
        // 共享账本 Editor:主表内容整体丢弃,替换为 SharedLedgerCategories 树。
        final ctx = await db.loadLedgerPickerContext(ledgerId);
        if (ctx != null && ctx.isEditorInShared && ctx.ledgerId != null) {
          final rows = await db.getSharedCategoryPickerTree(
            ctx.ledgerId!,
            kind,
          );
          final tree = _toPickerTree(rows);
          // 防线 B —— 即时自愈：镜像表为空时尝试拉取（随同步层重建恢复）。
          if (tree.topLevel.isEmpty) {
            unawaited(_pullSharedResourcesIfPossible(ref, ctx.ledgerId!));
          }
          return tree;
        }
        return _toPickerTree(await repo.getCategoryTree(kind));
      }

      Stream<CategoryPickerTree> watch() async* {
        yield await load();
        await for (final _ in db.tableUpdates(
          d.TableUpdateQuery.onAllTables([
            db.categories,
            db.sharedLedgerCategories,
            db.ledgers,
          ]),
        )) {
          yield await load();
        }
      }

      return watch();
    });

/// 将仓储分类树转换为页面展示树。
CategoryPickerTree _toPickerTree(CategoryRowTree rows) => CategoryPickerTree(
  topLevel: rows.topLevel.map((row) => row.toDisplay()).toList(growable: false),
  children: {
    for (final entry in rows.children.entries)
      entry.key: entry.value
          .map((row) => row.toDisplay())
          .toList(growable: false),
  },
);

/// 即时自愈：Editor 视角镜像表为空时拉取共享资源。
///
/// 新同步层接入前为 no-op（云拉取逻辑随同步层重建恢复）；
/// 冷却节流逻辑保留，保证接入后行为一致。
Future<void> _pullSharedResourcesIfPossible(Ref ref, String ledgerId) async {
  final cooldownMap = ref.read(selfHealCooldownProvider);
  final now = DateTime.now().toUtc();
  final nextAllowed = cooldownMap[ledgerId];
  if (nextAllowed != null && now.isBefore(nextAllowed)) {
    return;
  }
  cooldownMap[ledgerId] = now.add(_selfHealCooldown);

  try {
    // 云端共享资源拉取随新同步层接入后恢复。
    logger.debug('CategoryPicker', '自愈拉取待同步层重建: ledger=$ledgerId');
  } catch (e, st) {
    logger.warning(
      'CategoryPicker',
      '自愈拉取 SharedResources 失败 ledger=$ledgerId: $e',
      st,
    );
  }
}
