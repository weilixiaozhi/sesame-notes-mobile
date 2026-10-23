import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/logging/logger_service.dart';
import '../../../data/models/memo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_form_section.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_radio_tile.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/toast.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../application/memo_document_actions.dart';
import '../application/memo_providers.dart';
import 'memo_book_picker.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 两类本子各自维护选择与导出任务，任一类型无本或加载失败不影响另一类。
class MemoExportTools extends ConsumerWidget {
  const MemoExportTools({super.key, required this.onRefresh});
  final Future<void> Function() onRefresh;

  /// 本子状态只控制表单可用性，加载和失败时也保留完整工具区。
  Widget _section(WidgetRef ref, String type) {
    final provider = type == memoBookTypeCredentials
        ? currentCredentialBookProvider
        : currentMemoBookProvider;
    final state = ref.watch(provider);
    ref.listen(provider, (previous, next) {
      if (next.hasError) {
        logger.error(
          'MemoExport',
          '读取导出本子失败 type=$type',
          next.error,
          next.stackTrace,
        );
      }
    });
    // 目录状态未确认时不沿用缓存本，避免旧身份的选择继续参与导出。
    final book = state.isLoading || state.hasError ? null : state.asData?.value;
    return MemoExportSection(
      key: ValueKey('$type-${book?.id}'),
      book: book,
      type: type,
      bookLoading: state.isLoading,
      bookError: state.hasError,
      onRefresh: onRefresh,
    );
  }

  /// 工具页复用既有标题、表单与间距令牌。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.domainPageInset,
                  AppDimens.p16,
                  AppDimens.domainPageInset,
                  AppDimens.domainBottomClearance,
                ),
                children: [
                  for (final type in [
                    memoBookTypeNormal,
                    memoBookTypeCredentials,
                  ])
                    _section(ref, type),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 普通笔记保持单选，账号密码记录默认全选；更换本子时由组件键重置状态。
class MemoExportSection extends ConsumerStatefulWidget {
  const MemoExportSection({
    super.key,
    required this.book,
    required this.type,
    required this.bookLoading,
    required this.bookError,
    required this.onRefresh,
  });
  final MemoBook? book;
  final String type;
  final bool bookLoading;
  final bool bookError;
  final Future<void> Function() onRefresh;

  /// 每个本子独立持有选择草稿和导出生命周期。
  @override
  ConsumerState<MemoExportSection> createState() => _MemoExportSectionState();
}

class _MemoExportSectionState extends ConsumerState<MemoExportSection> {
  Set<String>? _selection;
  MemoDocumentFormat _format = MemoDocumentFormat.pdf;
  MemoDocumentJob? _job;
  bool _busy = false;
  bool _cancelled = false;
  String? _error;
  bool get _credentials => widget.type == memoBookTypeCredentials;

  /// 未确认选择的账号本默认全选，普通本需要用户主动选择一篇。
  Set<String> _selected(List<MemoEntry> entries) => {
    for (final entry in entries)
      if (_selection?.contains(entry.id) ?? _credentials) entry.id,
  };

  /// 页面离开立即取消待交付任务，生成流程结束后再回收仍在使用的文件。
  @override
  void dispose() {
    _cancelled = true;
    _job?.cancelled = true;
    super.dispose();
  }

  /// 弹窗维护独立选择草稿，关闭不提交；列表按本内顺序显示且不暴露字段值。
  Future<void> _pick(List<MemoEntry> entries) async {
    final l = AppLocalizations.of(context);
    final pending = _selected(entries);
    try {
      final result = await showAppSheet<Set<String>>(
        context: context,
        child: StatefulBuilder(
          builder: (context, update) => AppSheet(
            title: _credentials ? l.memoSelectCredentials : l.memoSelectEntry,
            footer: AppPrimaryButton(
              label: l.commonConfirm,
              onPressed: () => Navigator.pop(context, Set<String>.of(pending)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_credentials)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => update(() {
                          pending.addAll(entries.map((entry) => entry.id));
                        }),
                        child: Text(l.categoryTemplateSelectAll),
                      ),
                      TextButton(
                        onPressed: () => update(pending.clear),
                        child: Text(l.categoryTemplateDeselectAll),
                      ),
                    ],
                  ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final title = entry.title.isEmpty
                          ? l.memoUntitled
                          : entry.title;
                      return _credentials
                          ? CheckboxListTile(
                              title: Text(title),
                              value: pending.contains(entry.id),
                              onChanged: (value) => update(() {
                                if (value == true) {
                                  pending.add(entry.id);
                                } else {
                                  pending.remove(entry.id);
                                }
                              }),
                            )
                          : AppRadioTile(
                              title: title,
                              selected: pending.contains(entry.id),
                              onTap: () => update(() {
                                pending
                                  ..clear()
                                  ..add(entry.id);
                              }),
                            );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      if (!mounted || result == null) return;
      setState(() {
        _selection = result;
        _error = null;
      });
    } catch (error, stack) {
      logger.warning('MemoExport', '打开记录选择失败: ${error.runtimeType}', stack);
      if (mounted) showToast(context, l.memoLoadFailed);
    }
  }

  /// 每次点击都捕获新的固定快照，生成、身份复核、分享与清理属于同一任务。
  Future<void> _export(Set<String> selected) async {
    final book = widget.book;
    if (_busy ||
        selected.isEmpty ||
        book == null ||
        !book.isComplete ||
        book.isStale ||
        widget.bookLoading ||
        widget.bookError) {
      return;
    }
    final l = AppLocalizations.of(context);
    final actions = ref.read(memoDocumentActionsProvider);
    MemoDocumentJob? job;
    setState(() {
      _busy = true;
      _cancelled = false;
      _error = null;
    });
    try {
      job = _credentials
          ? await actions.captureCredentials(
              book.id,
              selected,
              _format,
              countLabel: l.memoEntryCount(selected.length),
            )
          : await actions.capture(selected.single, _format);
      _job = job;
      if (!mounted || _cancelled) return;
      final file = await actions.generate(job, untitled: l.memoUntitled);
      await actions.validate(job);
      if (!mounted || _cancelled) return;
      final box = context.findRenderObject() as RenderBox?;
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      if (mounted && result.status != ShareResultStatus.unavailable) {
        showToast(
          context,
          result.status == ShareResultStatus.success
              ? l.memoExportReady
              : l.memoExportCancelled,
        );
      }
    } catch (error, stack) {
      logger.warning('MemoExport', '导出任务未完成: ${error.runtimeType}', stack);
      if (mounted) {
        setState(() {
          _error = _cancelled
              ? l.memoExportCancelled
              : error is MemoImageTooLarge
              ? l.memoPngTooLarge
              : l.memoExportFailed;
        });
      }
    } finally {
      await job?.dispose();
      _job = null;
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 格式选择取消时保留原格式，导出期间禁止改变输入。
  Future<void> _pickFormat() async {
    try {
      final l = AppLocalizations.of(context);
      final format = await showAppRadioSheet(
        context,
        title: l.memoSelectFormat,
        selected: _format,
        options: {
          for (final value in MemoDocumentFormat.values)
            value: _label(value, l),
        },
      );
      if (mounted && format != null) {
        setState(() {
          _format = format;
          _error = null;
        });
      }
    } catch (error, stack) {
      logger.warning('MemoExport', '选择导出格式失败: ${error.runtimeType}', stack);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).memoExportFailed);
      }
    }
  }

  /// 文件扩展名保持稳定，图片格式使用当前语言显示名称。
  String _label(MemoDocumentFormat format, AppLocalizations l) =>
      switch (format) {
        MemoDocumentFormat.pdf => 'PDF',
        MemoDocumentFormat.docx => 'Word',
        MemoDocumentFormat.md => 'Markdown',
        MemoDocumentFormat.png => l.memoPng,
      };

  /// 加载、无本、空本和失败共用完整表单，只有确认可用的记录可以导出。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final book = widget.book;
    final bookReady =
        book != null &&
        book.isComplete &&
        !book.isStale &&
        !widget.bookLoading &&
        !widget.bookError;
    final AsyncValue<List<MemoEntry>>? entriesState = bookReady
        ? ref.watch(memoExportEntriesProvider(book.id))
        : null;
    if (bookReady) {
      ref.listen(memoExportEntriesProvider(book.id), (previous, next) {
        if (next.hasError) {
          logger.error('MemoExport', '读取导出记录失败', next.error, next.stackTrace);
        }
      });
    }
    final entriesReady =
        entriesState != null &&
        !entriesState.isLoading &&
        !entriesState.hasError &&
        entriesState.hasValue;
    final entries = entriesReady ? entriesState.asData!.value : <MemoEntry>[];
    final selected = _selected(entries);
    final selectedTitle = _credentials
        ? l.memoSelectedEntries(selected.length)
        : entries
              .where((entry) => selected.contains(entry.id))
              .firstOrNull
              ?.title;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormSection(
          title: _credentials ? l.memoCredentials : l.memoSelectBook,
          child: AppSelectionField(
            title:
                book?.name ??
                (widget.bookError
                    ? l.memoUnavailable
                    : widget.bookLoading
                    ? l.memoSelectBook
                    : l.memoNoBooks),
            enabled: !_busy,
            onTap: () => showMemoBookPicker(context, ref, type: widget.type),
          ),
        ),
        if (widget.bookError)
          AppLoadError(message: l.memoLoadFailed, onRetry: widget.onRefresh)
        else if (widget.bookLoading)
          const Center(child: CircularProgressIndicator())
        else if (book != null && !bookReady)
          Text(l.memoDownloadRequired),
        AppFormSection(
          title: _credentials ? l.memoSelectCredentials : l.memoSelectEntry,
          child: AppSelectionField(
            title: selectedTitle == null
                ? l.memoSelectEntry
                : selectedTitle.isEmpty
                ? l.memoUntitled
                : selectedTitle,
            enabled: !_busy && entriesReady && entries.isNotEmpty,
            onTap: () => _pick(entries),
          ),
        ),
        if (entriesState?.hasError == true)
          AppLoadError(
            message: l.memoLoadFailed,
            onRetry: () => ref.invalidate(memoExportEntriesProvider(book!.id)),
          )
        else if (entriesState?.isLoading == true)
          const Center(child: CircularProgressIndicator())
        else if (entriesReady && entries.isEmpty)
          AppEmpty(text: l.memoNoEntries),
        AppFormSection(
          title: l.memoSelectFormat,
          child: AppSelectionField(
            title: _label(_format, l),
            enabled: !_busy,
            onTap: _pickFormat,
          ),
        ),
        AppPrimaryButton(
          fullWidth: false,
          label: l.memoExport,
          onPressed: _busy || !bookReady || !entriesReady || selected.isEmpty
              ? null
              : () => _export(selected),
        ),
        if (_error != null)
          Text(
            _error!,
            style: AppTextTokens.body(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
        if (_busy)
          TextButton(
            onPressed: () {
              _cancelled = true;
              _job?.cancelled = true;
            },
            child: Text(l.commonCancel),
          ),
        const SizedBox(height: AppDimens.p16),
      ],
    );
  }
}
