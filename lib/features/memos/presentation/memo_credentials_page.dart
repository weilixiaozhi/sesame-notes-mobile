import 'package:sesame_notes/features/memos/presentation/memo_entry_actions.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/memo.dart';
import '../../../data/models/memo_order.dart';
import '../../../data/models/private_book.dart';
import '../../../core/logging/logger_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/presentation/minimum_refresh_duration.dart';
import '../../../shared/providers/sync_providers.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/primary_header.dart';
import '../../../shared/widgets/toast.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import '../application/memo_providers.dart';
import '../application/memo_actions.dart';
import 'memo_detail_sheet.dart';
import 'memo_navigation.dart';
import 'widgets/memo_entry_tile.dart';

/// 账号密码列表按当前账号密码本展示，独立路由与业务页签共用搜索和条目操作。
class MemoCredentialsPage extends ConsumerStatefulWidget {
  /// 嵌入业务壳时由壳提供标题、当前本和新增入口。
  const MemoCredentialsPage({super.key, this.embedded = false});
  final bool embedded;
  @override
  ConsumerState<MemoCredentialsPage> createState() =>
      _MemoCredentialsPageState();
}

class _MemoCredentialsPageState extends ConsumerState<MemoCredentialsPage> {
  int _limit = 100;
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  CredentialSort _sort = CredentialSort.manual;
  bool _reordering = false;
  List<MemoEntry>? _orderDraft;
  List<MemoEntry>? _gestureEntries;
  PrivateBookTarget? _gestureTarget;
  bool _gestureCancelled = false;
  String? _draftBookId;

  /// 状态里生效的关键词；输入框即时回显，查询按防抖后的值走。
  String _query = '';

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// 输入停顿后再改查询条件，避免逐字重建流查询。
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      // 关键词变化后结果集不同，分页起点回到首屏，避免沿用上一次的加载量。
      setState(() {
        _query = value;
        _limit = 100;
      });
    });
  }

  /// 清除筛选后恢复列表第一页，手动顺序保持不变。
  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    if (_query.isEmpty) return;
    setState(() {
      _query = '';
      _limit = 100;
    });
  }

  /// 顶部常驻搜索框：与币种管理页同一版式，输入即改查询条件。
  Widget _buildSearchField(AppLocalizations l) {
    final hasQuery = _searchController.text.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.p8, bottom: AppDimens.p8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              enabled: !_reordering,
              decoration: InputDecoration(
                prefixIcon: const Icon(AppIcons.search),
                hintText: l.memoSearchHint,
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(
                          AppIcons.close,
                          size: AppDimens.icon20,
                        ),
                        onPressed: _clearSearch,
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          PopupMenuButton<CredentialSort>(
            enabled: !_reordering,
            tooltip: l.categoryDetailSortTitle,
            initialValue: _sort,
            onSelected: (sort) => setState(() {
              _sort = sort;
              _limit = 100;
            }),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: CredentialSort.manual,
                child: Text(l.memoSortManual),
              ),
              PopupMenuItem(
                value: CredentialSort.updated,
                child: Text(l.memoSortUpdated),
              ),
              PopupMenuItem(
                value: CredentialSort.title,
                child: Text(l.memoName),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.sort, size: AppDimens.icon20),
                  const SizedBox(width: AppDimens.p4),
                  Text(switch (_sort) {
                    CredentialSort.manual => l.memoSortManual,
                    CredentialSort.updated => l.memoSortUpdated,
                    CredentialSort.title => l.memoName,
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 拖动任意排序视图后保存完整手动顺序，可见子集之外的卡片保持原有位置。
  Future<void> _reorder(
    PrivateBookTarget target,
    List<MemoEntry> entries,
    int oldIndex,
    int newIndex,
  ) async {
    if (_reordering) return;
    if (newIndex == oldIndex) return;
    try {
      if (ref.read(credentialOrderTargetProvider) != target) return;
      final draft = List<MemoEntry>.of(entries);
      draft.insert(newIndex, draft.removeAt(oldIndex));
      setState(() {
        _reordering = true;
        _draftBookId = target.bookId;
        _orderDraft = draft;
      });
      final actions = ref.read(memoActionsProvider);
      await actions.reorderCredentials(
        target,
        entries,
        draft.map((entry) => entry.id).toList(),
      );
      if (mounted && ref.read(credentialOrderTargetProvider) == target) {
        setState(() => _sort = CredentialSort.manual);
      }
    } catch (error, stackTrace) {
      logger.error(
        'MemoCredentialsPage',
        '卡片顺序保存失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (mounted && ref.read(credentialOrderTargetProvider) == target) {
        final l = AppLocalizations.of(context);
        showToast(
          context,
          error is StateError && error.message == 'MEMO_ORDER_CHANGED'
              ? l.memoOrderChanged
              : l.memoReorderFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _reordering = false;
          _orderDraft = null;
          _draftBookId = null;
        });
      }
    }
  }

  /// 列表只发起删除确认，目标校验和写入由应用用例处理。
  Future<void> _delete(MemoEntry entry) async {
    await confirmMemoEntryDeletion(context, ref, entry, pageId: 'credentials');
  }

  /// 下拉只做云端刷新；失败沿用列表页文案，本机已有卡片照常展示。
  Future<void> _refresh() => ensureMinimumRefreshDuration(() async {
    try {
      await ref.read(syncCoordinatorProvider).refreshData();
    } catch (_) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).memoUnavailable);
      }
    }
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final displayedTarget = ref.watch(credentialOrderTargetProvider);
    ref.listen(credentialOrderTargetProvider, (previous, next) {
      if (previous == next) return;
      // 切账号、重登、切本或同步绑定变化都会使原手势失效。
      if (_gestureTarget != null) _gestureCancelled = true;
      _gestureEntries = null;
      _gestureTarget = null;
      setState(() {
        _orderDraft = null;
        _draftBookId = null;
      });
    });
    // 列表查询绑定当前账号密码本，普通备忘本不会改变这里的内容。
    final book = ref.watch(currentCredentialBookProvider).value;
    final bookId = book?.id;
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          if (!widget.embedded)
            PrimaryHeader(
              title: book?.name ?? l.memoCredentialsTitle,
              showBack: true,
              actions: [
                HeaderIconAction(
                  icon: AppIcons.add,
                  tooltip: l.memoNewCard,
                  onPressed: () => openMemoCredentialEditor(context, ref),
                ),
              ],
            ),
          Expanded(
            child: bookId == null
                ? AppEmpty(text: l.memoNoEntries)
                : ref
                      .watch(
                        memoCredentialEntriesProvider((
                          bookId: bookId,
                          limit: _limit,
                          search: _query,
                          sort: _sort,
                        )),
                      )
                      .when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, _) => AppLoadError(
                          message: l.memoLoadFailed,
                          onRetry: () => ref.invalidate(
                            memoCredentialEntriesProvider((
                              bookId: bookId,
                              limit: _limit,
                              search: _query,
                              sort: _sort,
                            )),
                          ),
                        ),
                        data: (entries) {
                          final rows = _draftBookId == bookId
                              ? _orderDraft ?? entries
                              : entries;
                          return RefreshIndicator(
                            onRefresh: _reordering ? () async {} : _refresh,
                            child: ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              itemCount: rows.length,
                              onReorderStart: (_) {
                                _gestureCancelled = false;
                                _gestureEntries = List.of(entries);
                                _gestureTarget = displayedTarget;
                              },
                              onReorderItem: (oldIndex, newIndex) {
                                if (_gestureCancelled) {
                                  _gestureCancelled = false;
                                  return;
                                }
                                // 无拖动手势的辅助功能重排使用当前渲染快照。
                                final snapshot = _gestureEntries ?? entries;
                                final target =
                                    _gestureTarget ?? displayedTarget;
                                _gestureEntries = null;
                                _gestureTarget = null;
                                if (target == null) return;
                                unawaited(
                                  _reorder(
                                    target,
                                    snapshot,
                                    oldIndex,
                                    newIndex,
                                  ),
                                );
                              },
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                widget.embedded
                                    ? AppDimens.domainPageInset
                                    : AppDimens.p8,
                                0,
                                widget.embedded
                                    ? AppDimens.domainPageInset
                                    : AppDimens.p8,
                                widget.embedded
                                    ? AppDimens.domainBottomClearance
                                    : AppDimens.p16,
                              ),
                              header: Column(
                                children: [
                                  _buildSearchField(l),
                                  if (entries.isEmpty)
                                    AppEmpty(
                                      text: _query.isEmpty
                                          ? l.memoNoEntries
                                          : l.memoNoSearchResult,
                                    ),
                                ],
                              ),
                              itemBuilder: (context, index) {
                                final entry = rows[index];
                                return Row(
                                  key: ValueKey(entry.id),
                                  children: [
                                    Expanded(
                                      child: MemoEntryTile(
                                        entry: entry,
                                        onTap: _reordering
                                            ? null
                                            : () => openMemoEntry(
                                                context,
                                                ref,
                                                entry,
                                              ),
                                        onLongPress: _reordering
                                            ? null
                                            : () => _delete(entry),
                                      ),
                                    ),
                                    ReorderableDragStartListener(
                                      index: index,
                                      enabled: !_reordering && rows.length > 1,
                                      child: Tooltip(
                                        message: l.memoReorder,
                                        child: const SizedBox(
                                          width: kMinInteractiveDimension,
                                          height: kMinInteractiveDimension,
                                          child: Icon(
                                            AppIcons.sort,
                                            size: AppDimens.icon20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              footer: Column(
                                children: [
                                  if (_reordering)
                                    const LinearProgressIndicator(),
                                  if (entries.length >= _limit)
                                    TextButton(
                                      onPressed: _reordering
                                          ? null
                                          : () => setState(() => _limit += 100),
                                      child: Text(l.memoMore),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
