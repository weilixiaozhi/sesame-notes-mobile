import 'memo_export_tools.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/features/memos/presentation/memo_entry_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/presentation/minimum_refresh_duration.dart';

import '../../../shared/widgets/app_pull_to_refresh.dart';
import '../../../shared/widgets/list_section_header.dart';

import '../../../shared/widgets/toast.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../data/models/memo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/sync_providers.dart';

import '../../../shared/widgets/app_empty.dart';

import '../../../shared/widgets/app_status_banner.dart';

import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';

import '../application/memo_providers.dart';

import 'memo_detail_sheet.dart';
import 'widgets/memo_entry_tile.dart';

enum MemoPageKind { home, tools }

/// 列表只保存分组标题和摘要引用，实际卡片由可见行构建器创建。
sealed class _MemoListRow {
  /// 平铺行描述不持有页面或渲染对象。
  const _MemoListRow();
}

/// 月份分组标题占用一个列表行。
class _MemoMonthRow extends _MemoListRow {
  /// 保存当前分组的月份标签。
  const _MemoMonthRow(this.month);
  final String month;
}

/// 摘要行复用仓储返回的不可变记录。
class _MemoEntryRow extends _MemoListRow {
  /// 保存当前行对应的备忘摘要。
  const _MemoEntryRow(this.entry);
  final MemoEntry entry;
}

/// 首页和工具页共用当前本入口与摘要查询。
class MemosPage extends ConsumerStatefulWidget {
  final MemoPageKind kind;
  const MemosPage({super.key, required this.kind});
  @override
  ConsumerState<MemosPage> createState() => _MemosPageState();
}

class _MemosPageState extends ConsumerState<MemosPage> {
  int _limit = 100;
  bool _retrying = false;
  bool get _tools => widget.kind == MemoPageKind.tools;

  /// 刷新结果只属于发起时的账号与会话，同账号重新登录也会使旧结果失效。
  bool _isRefreshCurrent(String? account, int generation) =>
      mounted &&
      ref.read(currentAccountIdProvider) == account &&
      ref.read(authIdentityGenerationProvider) == generation;

  /// 列表只发起删除确认，目标校验和写入由应用用例处理。
  Future<void> _delete(MemoEntry entry) async {
    await confirmMemoEntryDeletion(context, ref, entry, pageId: 'memos');
  }

  /// 云目录和本地快照复用同一刷新路径，身份变化后不反馈旧会话结果。
  Future<String?> _refresh() async {
    final l = AppLocalizations.of(context);
    final book = ref.read(currentMemoBookProvider).value;
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final isCloud = account != null && (book?.isCloud ?? true);
    var outcome = DataRefreshOutcome.localOnly;
    try {
      if (isCloud) {
        outcome = DataRefreshOutcome.failed;
        final sync = ref.read(syncCoordinatorProvider);
        final result = await sync.refreshData();
        outcome = result.refreshOutcome;
        if (outcome == DataRefreshOutcome.failed) {
          logger.warning('MemosHome', '云端备忘刷新未完成，继续读取本地快照', result.error);
        }
      }
    } catch (error, stackTrace) {
      logger.error('MemosHome', '云端备忘刷新失败，继续读取本地快照', error, stackTrace);
    }
    if (!_isRefreshCurrent(account, generation)) return null;
    try {
      await ref
          .read(memoActionsProvider)
          .refreshLocalSnapshot(
            accountId: account,
            bookId: book?.id,
            limit: _limit,
          );
      if (!_isRefreshCurrent(account, generation)) return null;
      if (ref.read(memoBooksProvider).hasError) {
        ref.invalidate(memoBooksProvider);
      }
      return switch (outcome) {
        DataRefreshOutcome.localOnly => l.memoPullLocalSuccess,
        DataRefreshOutcome.cloudSynced => l.memoPullCloudSuccess,
        DataRefreshOutcome.failed => l.memoPullCloudFailedButLocalOk,
      };
    } catch (error, stackTrace) {
      logger.error('MemosHome', '刷新备忘本地快照失败', error, stackTrace);
      if (!_isRefreshCurrent(account, generation)) return null;
      return outcome == DataRefreshOutcome.localOnly
          ? l.memoPullLocalFailed
          : l.memoPullCloudFailed;
    }
  }

  /// 错误按钮执行真实刷新，再重建失效查询，并显示与下拉刷新一致的结果。
  Future<void> _retryRefresh({VoidCallback? invalidateAfterRefresh}) async {
    if (_retrying) return;
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    setState(() => _retrying = true);
    try {
      final message = await _refresh();
      if (!mounted ||
          !_isRefreshCurrent(account, generation) ||
          message == null) {
        return;
      }
      invalidateAfterRefresh?.call();
      showToast(context, message);
    } catch (error, stackTrace) {
      logger.error('MemosHome', '重试备忘目录失败', error, stackTrace);
      if (mounted && _isRefreshCurrent(account, generation)) {
        showToast(context, AppLocalizations.of(context).memoLoadFailed);
      }
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  /// 摘要卡片统一承接详情打开和长按删除入口。
  Widget _entryTile(MemoEntry entry) => MemoEntryTile(
    entry: entry,
    onTap: () => openMemoEntry(context, ref, entry),
    onLongPress: () => _delete(entry),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (_tools) {
      return MemoExportTools(
        onRefresh: () => ensureMinimumRefreshDuration(_refresh),
      );
    }
    final book = ref.watch(currentMemoBookProvider);
    final content = book.when(
      skipLoadingOnReload: true,
      loading: () => _scrollableContent(const [
        Padding(
          padding: EdgeInsets.all(AppDimens.p20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ]),
      error: (_, _) => _scrollableContent([
        AppLoadError(onRetry: () => _retryRefresh(), message: l.memoLoadFailed),
      ]),
      data: (book) => _content(book),
    );
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          Expanded(
            child: AppPullToRefresh(
              key: ValueKey(ref.watch(currentMemoBookIdProvider).value),
              refreshingText: l.memoHomeSyncing,
              onRefresh: _refresh,
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  /// 普通备忘只展示当前普通本的数据状态与内容。
  Widget _content(MemoBook? book) {
    final l = AppLocalizations.of(context);
    final bookId = book?.id ?? '';
    final query = (bookId: bookId, date: null, limit: _limit);
    final entries = book == null
        ? const AsyncData<List<MemoEntry>>([])
        : ref.watch(memoEntriesProvider(query));
    if (book == null ||
        (book.isComplete &&
            !book.isStale &&
            entries.hasValue &&
            entries.value!.isEmpty)) {
      return _scrollableContent([
        AppEmpty(text: l.memoHomeEmpty),
      ], bookId: bookId);
    }
    if (!book.isComplete || book.isStale) {
      return _scrollableContent([
        AppStatusBanner(
          icon: AppIcons.download,
          message: l.memoDownloadRequired,
        ),
      ], bookId: bookId);
    }
    return entries.when(
      skipLoadingOnReload: true,
      loading: () => _scrollableContent(const [], bookId: bookId),
      error: (_, _) => _scrollableContent([
        AppLoadError(
          message: l.memoLoadFailed,
          onRetry: () => _retryRefresh(
            invalidateAfterRefresh: () =>
                ref.invalidate(memoEntriesProvider(query)),
          ),
        ),
      ], bookId: bookId),
      data: (values) => _entriesList(values, query),
    );
  }

  /// 月份与摘要先平铺为行描述，滚动视口只创建当前需要的卡片。
  Widget _entriesList(List<MemoEntry> entries, MemoListQuery query) {
    final l = AppLocalizations.of(context);
    try {
      if (entries.isEmpty) {
        return _scrollableContent([
          AppEmpty(text: l.memoNoEntries),
        ], bookId: query.bookId);
      }
      final monthFormat = DateFormat('yyyy-MM');
      final groups = <String, List<MemoEntry>>{};
      for (final entry in entries) {
        final month = monthFormat.format(entry.updatedAt.toLocal());
        (groups[month] ??= []).add(entry);
      }
      final rows = <_MemoListRow>[
        for (final group in groups.entries) ...[
          _MemoMonthRow(group.key),
          for (final entry in group.value) _MemoEntryRow(entry),
        ],
      ];
      final hasMore = entries.length >= query.limit;
      return _scrollableList(
        bookId: query.bookId,
        itemCount: rows.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == rows.length) {
            return TextButton(
              onPressed: () => setState(() => _limit += 100),
              child: Text(l.memoMore),
            );
          }
          return switch (rows[index]) {
            _MemoMonthRow(:final month) => ListSectionHeader(
              title: month,
              horizontalPadding: 0,
            ),
            _MemoEntryRow(:final entry) => _entryTile(entry),
          };
        },
      );
    } catch (error, stackTrace) {
      logger.error('MemosHome', '整理备忘列表失败', error, stackTrace);
      return _scrollableContent([
        AppLoadError(
          message: l.memoLoadFailed,
          onRetry: () => ref.invalidate(memoEntriesProvider(query)),
        ),
      ], bookId: query.bookId);
    }
  }

  /// 正常、空本、加载和失败状态共用列表骨架，保留刷新和重试。
  Widget _scrollableContent(List<Widget> children, {String bookId = ''}) =>
      _scrollableList(
        bookId: bookId,
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      );

  /// 重试进度占用独立首行，数据行继续按可见位置延迟构建。
  Widget _scrollableList({
    required String bookId,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) => ListView.builder(
    key: PageStorageKey('memo-${widget.kind}-$bookId'),
    physics: AppPullToRefresh.physics,
    padding: const EdgeInsets.fromLTRB(
      AppDimens.domainPageInset,
      AppDimens.p8,
      AppDimens.domainPageInset,
      AppDimens.domainBottomClearance,
    ),
    itemCount: itemCount + (_retrying ? 1 : 0),
    itemBuilder: (context, index) {
      if (_retrying && index == 0) return const LinearProgressIndicator();
      return itemBuilder(context, index - (_retrying ? 1 : 0));
    },
  );
}
