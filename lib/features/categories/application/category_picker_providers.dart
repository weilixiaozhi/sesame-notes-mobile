library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

import 'package:sesame_notes/data/repositories/support/category_row_tree.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/ledger_kind.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 记账页分类树。family 参数为分类 kind（全局仅支出模式，恒为 'expense'）。
final categoryPickerTreeProvider =
    StreamProvider.family<CategoryPickerTree, String>((ref, kind) {
      final ledgerId = ref.watch(currentLedgerIdProvider);
      return _watchPickerTree(ref, ledgerId, kind);
    });

/// 应用壳持有当前账本分类订阅，记账弹层直接复用已经加载的固定账本树。
final categoryPickerPrewarmProvider = Provider<void>((ref) {
  final ledgerId = ref.watch(currentLedgerIdProvider);
  if (ledgerId.isEmpty) return;
  // 仅维持订阅；分类正文变化无需重建整层导航页面。
  ref.watch(
    categoryPickerTreeForLedgerProvider((
      ledgerId: ledgerId,
      type: 'expense',
    )).select((_) => null),
  );
});

/// 编辑器使用打开时的账本分类树，当前本改变不会替换可选分类。
final categoryPickerTreeForLedgerProvider = StreamProvider.autoDispose
    .family<CategoryPickerTree, ({String ledgerId, String type})>((
      ref,
      query,
    ) async* {
      final accountId = ref.watch(currentAccountIdProvider);
      ref.watch(authIdentityGenerationProvider);
      final availability = ref.watch(
        ledgerByIdProvider(
          query.ledgerId,
        ).select((state) => _pickerLedgerAvailability(state, accountId)),
      );
      try {
        if (availability == _PickerLedgerAvailability.pending ||
            ref.read(ledgerByIdProvider(query.ledgerId)).isLoading) {
          // 首次等待账本完成发布校验，后续后台刷新保留相同账本的分类流。
          await ref.read(ledgerByIdProvider(query.ledgerId).future);
          if (!ref.mounted) return;
        }
        final state = ref.read(ledgerByIdProvider(query.ledgerId));
        if (_pickerLedgerAvailability(state, accountId) !=
            _PickerLedgerAvailability.available) {
          throw StateError('LEDGER_UNAVAILABLE');
        }
        yield* _watchPickerTree(ref, query.ledgerId, query.type);
      } catch (error, stackTrace) {
        logger.error('CategoryPicker', '读取固定账本分类失败', error, stackTrace);
        rethrow;
      }
    }, retry: (_, _) => null);

/// 查询中保留已校验的可用状态，删除、归档或读取失败则立即阻断选择。
_PickerLedgerAvailability _pickerLedgerAvailability(
  AsyncValue<Ledger?> state,
  String? accountId,
) {
  if (state.hasError) return _PickerLedgerAvailability.unavailable;
  if (!state.hasValue) return _PickerLedgerAvailability.pending;
  final ledger = state.value;
  return ledger != null &&
          ledger.archivedAt == null &&
          ledger.isPublishedTo(accountId, const {})
      ? _PickerLedgerAvailability.available
      : _PickerLedgerAvailability.unavailable;
}

enum _PickerLedgerAvailability { pending, available, unavailable }

/// 固定与当前本入口共用仓储投影，分类层级及共享成员权限保持原样。
Stream<CategoryPickerTree> _watchPickerTree(
  Ref ref,
  String ledgerId,
  String kind,
) {
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  final repo = ref.watch(categoryQueriesProvider);
  return repo
      .watchCategoryPickerTree(ledgerId: ledgerId, kind: kind)
      .map(_toPickerTree);
}

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
