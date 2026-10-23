import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../../data/models/app_mode.dart';
import '../../../../data/models/private_book.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/account_state_provider.dart';
import '../../../../shared/providers/current_private_book_provider.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/cloud_ledger_download_providers.dart';
import '../../../../shared/providers/fitness_space_provider.dart';
import '../../../../shared/providers/sync_providers.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../theme/dimens.dart';
import '../../../days/application/day_providers.dart';
import '../../../ledgers/application/ledger_actions.dart';
import '../../../memos/application/memo_providers.dart';
import '../../application/import_book_options.dart';

final _ledgerOptions = FutureProvider<List<ImportBookOption>>((ref) async {
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  ref.watch(accountingDataChangeSignalProvider);
  ref.watch(unpublishedCloudLedgersProvider);
  return [
    for (final book in await ref.watch(ledgerActionsProvider).getAll())
      if (!book.isArchived) (id: book.id, name: book.name),
  ];
});

final importBookOptionsProvider = Provider.autoDispose
    .family<AsyncValue<List<ImportBookOption>>, AppMode>((ref, mode) {
      if (mode == AppMode.bookkeeping) return ref.watch(_ledgerOptions);
      final AsyncValue<List<PrivateBook>> books;
      final BookDirectoryStatus status;
      switch (mode) {
        case AppMode.days:
          books = ref.watch(dayBooksProvider);
          status = ref.watch(dayDirectoryStatusProvider);
        case AppMode.memos:
          books = ref.watch(memoBooksProvider);
          status = ref.watch(memoDirectoryStatusProvider);
        case AppMode.fitness:
          books = ref.watch(fitnessSpacesProvider);
          status = ref.watch(fitnessDirectoryStatusProvider);
        case AppMode.bookkeeping:
          throw StateError('账本分支已处理');
      }
      return privateBooksForDisplay(
        books,
        ref.watch(currentAccountIdProvider),
        status,
      ).whenData(
        (values) => [
          for (final book in values)
            if (!book.isStale &&
                book.isComplete &&
                !book.pendingLocalDelete &&
                !book.isHidden &&
                book.deletedAt == null)
              (id: book.id, name: book.name),
        ],
      );
    });

/// 四域共用加载、失败、资格过滤后的回落与选中发布，不改首页当前本。
class ImportBookSelector extends ConsumerStatefulWidget {
  const ImportBookSelector({
    super.key,
    required this.mode,
    this.selectedId,
    required this.onChanged,
    this.enabled = true,
  });
  final AppMode mode;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  @override
  ConsumerState<ImportBookSelector> createState() => _ImportBookSelectorState();
}

class _ImportBookSelectorState extends ConsumerState<ImportBookSelector> {
  late String? _preferred = widget.selectedId;
  int _publication = 0;
  String? _published;
  bool _didPublish = false;

  void _publish(String? id) {
    if (_didPublish && _published == id) return;
    _didPublish = true;
    _published = id;
    final revision = ++_publication;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && revision == _publication) widget.onChanged(id);
    });
  }

  /// 刷新四域候选目录，禁用后到达的点击不发起请求。
  Future<void> _retry() async {
    if (!widget.enabled) return;
    try {
      ref.invalidate(_ledgerOptions);
      ref.invalidate(dayBooksProvider);
      ref.invalidate(memoBooksProvider);
      ref.invalidate(fitnessSpacesProvider);
      if (ref.read(currentAccountIdProvider) == null) return;
      await ref.read(syncCoordinatorProvider).refreshData();
    } catch (error, stackTrace) {
      logger.error(
        'ImportBookSelector',
        '刷新导入目标目录失败 mode=${widget.mode.name}',
        error,
        stackTrace,
      );
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final options = ref.watch(importBookOptionsProvider(widget.mode));
    final selection = resolveImportBookSelection(options, _preferred);
    // 候选就绪才记住本次回落结果：加载中/失败不覆盖已选定的目标本。
    if (selection.ready) _preferred = selection.selected;
    _publish(selection.selected);
    return options.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppDimens.p16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        logger.error(
          'ImportBookSelector',
          '加载导入目标目录失败 mode=${widget.mode.name}',
          error,
          stackTrace,
        );
        return AppLoadError(onRetry: widget.enabled ? _retry : null);
      },
      data: (books) {
        if (books.isEmpty) {
          return AppEmpty(
            padding: const EdgeInsets.all(AppDimens.p16),
            text: switch (widget.mode) {
              AppMode.bookkeeping => l.ledgersEmpty,
              AppMode.days => l.dayBookEmpty,
              AppMode.memos => l.memoNoBooks,
              AppMode.fitness => l.fitnessNoSpaces,
            },
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final book in books)
              AppRadioTile(
                title: book.name,
                selected: book.id == selection.selected,
                onTap: !widget.enabled
                    ? null
                    : () {
                        setState(() => _preferred = book.id);
                        _publish(book.id);
                      },
              ),
          ],
        );
      },
    );
  }
}
