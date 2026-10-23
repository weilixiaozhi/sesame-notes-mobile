import 'package:sesame_notes/theme/typography.dart';
import '../../../shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/settings/application/detail_export_actions.dart';

import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';

class DetailExportPage extends ConsumerStatefulWidget {
  const DetailExportPage({super.key});

  @override
  ConsumerState<DetailExportPage> createState() => _DetailExportPageState();
}

class _DetailExportPageState extends ConsumerState<DetailExportPage> {
  /// 导出账本：默认当前页面所在的数据账本
  late String _ledgerId;

  bool _exportLedger = true;
  bool _exportDays = true;
  bool _exportMemos = true;
  bool _exportFitness = true;
  String? _fitnessSpaceId;
  bool _fitnessDefaultApplied = false;
  String? _memoBookId;
  String? _dayBookId;

  /// 导出中标记：防重复提交，同时禁用表单交互
  bool _exporting = false;
  int _generatedFiles = 0;

  /// 账本列表请求缓存在 state 中，避免 setState 触发重复查询
  late final Future<List<LedgerDisplayItem>> _ledgersFuture;

  /// 账本列表加载完成且为空时展示空态并禁用导出。
  bool _ledgersEmpty = true;

  @override
  void initState() {
    super.initState();
    _ledgerId = ref.read(currentLedgerIdProvider);
    _fitnessSpaceId = ref.read(currentFitnessSpaceIdProvider).value;
    _dayBookId = ref.read(currentDayBookIdProvider).value;
    _ledgersFuture = ref.read(ledgerActionsProvider).getAll();
    _ledgersFuture
        .then((ledgers) {
          if (!mounted) return;
          setState(() {
            _ledgersEmpty = ledgers.isEmpty;
            // 当前账本不在列表中(如已被删除)时回退到首个账本。
            if (ledgers.isNotEmpty && !ledgers.any((l) => l.id == _ledgerId)) {
              _ledgerId = ledgers.first.id;
            }
          });
        })
        .catchError((Object e, StackTrace st) {
          logger.error('DetailExportPage', '加载账本列表失败', safeErrorSummary(e), st);
          if (mounted) {
            setState(() => _ledgersEmpty = true);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final booksState = ref.watch(dayBooksProvider);
    final books = booksState.value ?? const <DayBook>[];
    if (!books.any((book) => book.id == _dayBookId)) {
      _dayBookId = books.firstOrNull?.id;
    }
    final memoState = ref.watch(memoBooksProvider);
    final memoBooks = memoState.value ?? const [];
    if (!memoBooks.any((book) => book.id == _memoBookId)) {
      _memoBookId = memoBooks.firstOrNull?.id;
    }
    final fitnessState = ref.watch(fitnessSpacesProvider);
    final spaces = fitnessState.value ?? const [];
    final initialSpace = ref.watch(currentFitnessSpaceIdProvider);
    if (!_fitnessDefaultApplied &&
        (initialSpace.hasValue || initialSpace.hasError)) {
      _fitnessSpaceId = initialSpace.value;
      _fitnessDefaultApplied = true;
    }

    if (!spaces.any((s) => s.id == _fitnessSpaceId)) {
      _fitnessSpaceId = spaces.firstOrNull?.id;
    }
    final nothingSelected =
        !_exportLedger && !_exportDays && !_exportMemos && !_exportFitness;
    final invalid =
        nothingSelected ||
        (_exportFitness &&
            (fitnessState.hasError ||
                !fitnessState.hasValue ||
                _fitnessSpaceId == null)) ||
        (_exportMemos &&
            (memoState.hasError ||
                !memoState.hasValue ||
                _memoBookId == null)) ||
        (_exportLedger && _ledgersEmpty) ||
        (_exportDays &&
            (booksState.isLoading ||
                booksState.hasError ||
                _dayBookId == null));

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.detailImportExportExportTitle,
            showBack: true,
          ),
          if (_exporting)
            Padding(
              padding: const EdgeInsets.all(AppDimens.p12),
              child: Column(
                children: [
                  const LinearProgressIndicator(),
                  const SizedBox(height: AppDimens.p8),
                  Text(
                    l10n.transferExportProgress(_generatedFiles),
                    style: AppTextTokens.body(context),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p12,
                vertical: AppDimens.p8,
              ),
              children: [
                _buildExportSection(
                  l10n.ledgerExportSection,
                  _exportLedger,
                  const ValueKey('export-ledger-section'),
                  (value) => setState(() => _exportLedger = value),
                  _buildLedgerRow(context, l10n),
                ),
                _buildExportSection(
                  l10n.dayExportSection,
                  _exportDays,
                  const ValueKey('export-days-section'),
                  (value) => setState(() => _exportDays = value),
                  _buildBookPicker(
                    label: l10n.daySelectBook,
                    emptyText: l10n.dayBookEmpty,
                    books: [
                      for (final book in books) (id: book.id, name: book.name),
                    ],
                    selected: _dayBookId,
                    enabled: _exportDays,
                    onChanged: (value) => setState(() => _dayBookId = value),
                  ),
                ),
                _buildExportSection(
                  l10n.memoExportSection,
                  _exportMemos,
                  const ValueKey('export-memos-section'),
                  (value) => setState(() => _exportMemos = value),
                  _buildBookPicker(
                    label: l10n.memoSelectBook,
                    emptyText: l10n.memoNoBooks,
                    books: [
                      for (final book in memoBooks)
                        (id: book.id, name: book.name),
                    ],
                    selected: _memoBookId,
                    enabled: _exportMemos,
                    onChanged: (value) => setState(() => _memoBookId = value),
                  ),
                ),
                _buildExportSection(
                  l10n.fitnessExportSection,
                  _exportFitness,
                  const ValueKey('export-fitness-section'),
                  (value) => setState(() => _exportFitness = value),
                  _buildBookPicker(
                    label: l10n.fitnessSelectSpace,
                    emptyText: l10n.fitnessNoSpaces,
                    books: [
                      for (final space in spaces)
                        (id: space.id, name: space.name),
                    ],
                    selected: _fitnessSpaceId,
                    enabled: _exportFitness,
                    onChanged: (value) => setState(() {
                      _fitnessSpaceId = value;
                      _fitnessDefaultApplied = true;
                    }),
                  ),
                ),
                if (nothingSelected)
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    child: Text(
                      l10n.exportSelectAtLeastOne,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.error(context)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // 导出进度和输入有效性独立传入统一操作区。
      bottomNavigationBar: AppEditorFooter(
        label: l10n.detailExportAction,
        busy: _exporting,
        onPressed: invalid ? null : _export,
      ),
    );
  }

  /// 业务区开关只控制本区校验，不改变另一业务的临时选项。
  /// 日子与备忘录使用同一选择行，业务只提供可选本和选中值。
  Widget _buildBookPicker({
    required String label,
    required String emptyText,
    required List<({String id, String name})> books,
    required String? selected,
    required bool enabled,
    required ValueChanged<String> onChanged,
  }) => AppSelectionField(
    title:
        books.where((book) => book.id == selected).firstOrNull?.name ??
        emptyText,
    enabled: enabled && !_exporting && books.isNotEmpty,
    onTap: () async {
      final value = await showDialog<String>(
        context: context,
        builder: (context) => AppContentDialog(
          title: label,
          actions: const [],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final book in books)
                AppRadioTile(
                  title: book.name,
                  selected: book.id == selected,
                  onTap: () => Navigator.pop(context, book.id),
                ),
            ],
          ),
        ),
      );
      if (mounted && value != null) onChanged(value);
    },
  );

  Widget _buildExportSection(
    String title,
    bool selected,
    Key key,
    ValueChanged<bool> onChanged,
    Widget child,
  ) => AppFormSection(
    title: title,
    titleTrailing: Checkbox(
      key: key,
      semanticLabel: title,
      value: selected,
      onChanged: _exporting ? null : (value) => onChanged(value ?? false),
    ),
    child: child,
  );

  Widget _buildLedgerRow(BuildContext context, AppLocalizations l10n) =>
      FutureBuilder<List<LedgerDisplayItem>>(
        future: _ledgersFuture,
        builder: (context, snapshot) => _buildBookPicker(
          label: l10n.ledgerSelectTitle,
          emptyText: l10n.ledgersEmpty,
          books: [
            for (final book in snapshot.data ?? <LedgerDisplayItem>[])
              (id: book.id, name: book.name),
          ],
          selected: _ledgerId,
          enabled: _exportLedger,
          onChanged: (value) => setState(() => _ledgerId = value),
        ),
      );

  /// 每个本完整导出，所有文件成功生成后统一分享。
  ///
  /// 来源固定、整批原子交付与临时文件清理都在 [DetailExportActions]；
  /// 页面只组装本次选择与本地化文案，并把结果映射为提示。
  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _exporting = true;
      _generatedFiles = 0;
    });
    try {
      // 容器提供导出动作，页面仅提交当前选择、文案和存续状态。
      final result = await ref
          .read(detailExportActionsProvider)
          .export(
            (
              ledgerId: _exportLedger ? _ledgerId : null,
              dayBookId: _exportDays ? _dayBookId : null,
              memoBookId: _exportMemos ? _memoBookId : null,
              fitnessSpaceId: _exportFitness ? _fitnessSpaceId : null,
            ),
            copy: (
              ledgerBusiness: l10n.welcomeHomeBookkeeping,
              dayBusiness: l10n.welcomeHomeAnniversary,
              memoBusiness: l10n.welcomeHomeMemo,
              fitnessBusiness: l10n.welcomeHomeFitness,
              memoTypeNormal: l10n.memoNormal,
              memoTypeCredentials: l10n.memoCredentials,
              ledgerLabels: (
                type: l10n.exportCsvHeaderType,
                category: l10n.exportCsvHeaderCategory,
                subCategory: l10n.exportCsvHeaderSubCategory,
                amount: l10n.exportCsvHeaderAmount,
                currency: l10n.exportCsvHeaderCurrency,
                note: l10n.exportCsvHeaderNote,
                time: l10n.exportCsvHeaderTime,
                expense: l10n.exportTypeExpense,
              ),
              categoryLabel: (name) =>
                  CategoryUtils.getLocalizedDisplayName(name, l10n),
            ),
            isPageActive: () => mounted,
            confirmCachedDayExport: () async {
              final proceed = await AppDialog.confirm(
                context,
                title: l10n.dayExportSection,
                message: l10n.dayCachedExportWarning,
              );
              return proceed == true;
            },
            onProgress: (generated) {
              if (mounted) setState(() => _generatedFiles = generated);
            },
          );
      if (!mounted || result == null) return;
      if (result.status == ShareResultStatus.success) {
        showToast(context, l10n.exportSuccessTitle);
      }
      if (result.status == ShareResultStatus.unavailable) {
        showToast(context, l10n.shareHandedToSystem);
      }
    } on DetailExportLedgerUnavailable catch (failure) {
      if (!mounted) return;
      showToast(
        context,
        failure.archived
            ? l10n.ledgersArchivedRestoreRequired
            : l10n.commonOperationFailed,
      );
    } catch (e, st) {
      logger.error('DetailExportPage', '导出明细失败', safeErrorSummary(e), st);
      if (!mounted) return;
      await AppDialog.error(
        context,
        title: l10n.exportFailedTitle,
        message: e is StateError && e.message == 'FITNESS_INCOMPLETE'
            ? l10n.fitnessIncomplete
            : l10n.commonOperationFailed,
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }
}
