import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/features/memos/application/memo_book_actions.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/presentation/private_book_editor.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import '../../../shared/presentation/minimum_refresh_duration.dart';
import '../../../data/models/memo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../providers/book_selection_actions.dart';
import '../../../shared/providers/sync_providers.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_form_section.dart';
import '../../../shared/widgets/app_radio_tile.dart';
import '../../../shared/widgets/book_overview_card.dart';
import '../../../shared/widgets/list_section_header.dart';
import '../../../shared/widgets/primary_header.dart';
import '../../../shared/widgets/toast.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import '../../../theme/typography.dart';
import '../application/memo_providers.dart';
import 'memo_navigation.dart';

/// 备忘录本子管理：备忘录本与账号密码本各自成组，两组各有一个当前本。
class MemoBooksPage extends ConsumerWidget {
  const MemoBooksPage({super.key});

  /// 通过统一同步入口重试云端目录，失败时保留本地本子并提示可重试原因。
  Future<void> _refreshBooks(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref.read(syncCoordinatorProvider).refreshData();
      if (context.mounted && result.error != null) {
        showToast(context, result.error!);
      }
    } catch (error, stackTrace) {
      logger.error('MemoBooks', '刷新备忘录目录失败', error, stackTrace);
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).memoUnavailable);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final account = ref.watch(currentAccountIdProvider);
    final directory = ref.watch(memoDirectoryStatusProvider);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l.memoBooksManagement,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.add,
                tooltip: l.memoCreateBookTitle,
                onPressed: () => createMemoBook(context),
              ),
            ],
          ),
          Expanded(
            child: ref
                .watch(memoBooksProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    onRetry: () => ref.invalidate(memoBooksProvider),
                    message: l.memoLoadFailed,
                  ),
                  data: (books) => RefreshIndicator(
                    onRefresh: () => ensureMinimumRefreshDuration(
                      () => _refreshBooks(context, ref),
                    ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p8,
                      ),
                      children: [
                        // 两类本子并存：分组标题、当前本与本地/云端分区都各自独立。
                        for (final group in [
                          (
                            type: memoBookTypeNormal,
                            title: l.memoBooks,
                            current: ref.watch(currentMemoBookIdProvider).value,
                          ),
                          (
                            type: memoBookTypeCredentials,
                            title: l.memoCredentials,
                            current: ref
                                .watch(currentCredentialBookIdProvider)
                                .value,
                          ),
                        ]) ...[
                          BookSectionTitle(title: group.title),
                          ..._storageSections(
                            context,
                            ref,
                            l,
                            books: books
                                .where((book) => book.type == group.type)
                                .toList(),
                            current: group.current,
                            account: account,
                            directory: directory,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  /// 同一类型下按本机/云端分区：分区为空即隐藏标题；目录未就绪时保留云端分区，
  /// 让加载中与加载失败的提示仍有落点。
  List<Widget> _storageSections(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l, {
    required List<MemoBook> books,
    required String? current,
    required String? account,
    required BookDirectoryStatus directory,
  }) {
    // 只有云目录已确认或未登录时，零缓存才表示该类型确实没有本子。
    if (books.isEmpty &&
        (account == null || directory == BookDirectoryStatus.ready)) {
      return [BookSectionEmpty(text: l.memoNoBooks)];
    }
    return [
      for (final storage in [
        if (books.any((book) => book.isCloud) ||
            (account != null && directory != BookDirectoryStatus.ready))
          'cloud',
        if (books.any((book) => !book.isCloud)) 'local',
      ]) ...[
        ListSectionHeader(
          title: storage == 'local' ? l.memoStorageLocal : l.memoStorageCloud,
        ),
        if (books.where((book) => book.storageMode == storage).isEmpty)
          if (storage == 'cloud' &&
              account != null &&
              directory != BookDirectoryStatus.ready)
            directory == BookDirectoryStatus.failed
                ? BookSectionEmpty(
                    text: l.memoLoadFailed,
                    action: TextButton(
                      onPressed: () => _refreshBooks(context, ref),
                      child: Text(l.commonRetry),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
        for (final book in books.where((book) => book.storageMode == storage))
          BookOverviewCard(
            selected: book.id == current,
            title: book.name,
            onTap: () async {
              final changed = book.id != current;
              final completed = ref
                  .read(productAnalyticsControllerProvider)
                  .captureCompletion(
                    pageId: 'memos.books',
                    context: ref
                        .read(productAnalyticsControllerProvider)
                        .captureContext(),
                  );
              try {
                // 两类本子各记各的当前本：选账号密码本不会改掉备忘录本的选中。
                await selectBook(
                  ref.read,
                  mode: AppMode.memos,
                  bookId: book.id,
                );
                if (changed) {
                  completed(
                    book.type == memoBookTypeCredentials
                        ? ProductAction.credentialsBookSelect
                        : ProductAction.memosBookSelect,
                  );
                }
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              } catch (_) {
                if (context.mounted) showToast(context, l.memoUnavailable);
              }
            },
            onEdit: () => context.pushNamed(Routes.memoBookEdit, extra: book),
            editTooltip: l.memoRename,
            compact: true,
            notice: book.isStale || !book.isComplete
                ? Text(
                    l.memoDownloadRequired,
                    style: AppTextTokens.label(context),
                  )
                : null,
            child: Text(
              '${l.memoEntryCount(book.entryCount)}${book.sourceOperationId == null ? '' : ' · ${l.memoConflictCopy}'}',
              style: AppTextTokens.label(context),
            ),
          ),
      ],
    ];
  }
}

/// 新建时选择本子类型；既有本子的类型不可改（正文格式不同，改类型要转换内容）。
class MemoBookForm extends ConsumerStatefulWidget {
  const MemoBookForm({super.key, this.book});
  final MemoBook? book;
  @override
  ConsumerState<MemoBookForm> createState() => _MemoBookFormState();
}

class _MemoBookFormState extends ConsumerState<MemoBookForm> {
  late String _type = widget.book?.type ?? memoBookTypeNormal;

  /// 本子类型只在新建时可选：账号密码卡片与普通笔记的正文格式互不相同。
  Widget _typeField(AppLocalizations l) => AppFormSection(
    title: l.memoBookType,
    child: Column(
      children: [
        for (final option in [
          (type: memoBookTypeNormal, label: l.memoNormal),
          (type: memoBookTypeCredentials, label: l.memoCredentials),
        ])
          AppRadioTile(
            title: option.label,
            selected: _type == option.type,
            onTap: () => setState(() => _type = option.type),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return productAnalyticsPresentation(
      context: context,
      read: ref.read,
      routePage: true,
      pageId: _type == memoBookTypeCredentials
          ? 'credentials.books.edit'
          : 'memos.books.edit',
      child: PrivateBookEditor(
        actions: ref.watch(memoBookActionsProvider(_type)),
        book: widget.book,
        title: widget.book == null ? l.memoCreateBookTitle : l.memoRename,
        nameLabel: l.memoBookName,
        extraField: widget.book == null ? _typeField(l) : null,
        selection: () => _type == memoBookTypeCredentials
            ? ref.read(currentCredentialBookIdProvider.notifier)
            : ref.read(currentMemoBookIdProvider.notifier),
        deleteMessage: l.memoDeleteBookMessage,
      ),
    );
  }
}
