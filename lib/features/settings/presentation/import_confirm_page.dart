import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_exercise_media.dart'
    show fitnessExerciseName;
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:flutter/foundation.dart' show compute;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/features/settings/presentation/widgets/data_import_target_dialog.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 所有数据类型共享映射、业务匹配、预览选择、进度和结果状态。
class ImportConfirmPage extends ConsumerStatefulWidget {
  final String csvText;
  final bool hasHeader;
  final DataImportTarget target;
  final TransferKind kind;
  const ImportConfirmPage({
    super.key,
    required this.csvText,
    this.hasHeader = true,
    required this.target,
    this.kind = TransferKind.ledger,
  });
  @override
  ConsumerState<ImportConfirmPage> createState() => _ImportConfirmPageState();
}

class _ImportConfirmPageState extends ConsumerState<ImportConfirmPage> {
  /// 导入进度提示条的停留时长：每条进度都覆盖上一条，完成后由结果提示替换。
  static const _progressToast = Duration(seconds: 30);

  /// 结果与失败提示的停留时长：足够读完一行汇总，随后自动消失。
  static const _resultToast = Duration(seconds: 3);

  TransferActions? actions;
  final mapping = <String, String?>{};
  final defaults = <String, String>{};

  /// 账号密码卡片字段：文件列 → 字段名；null 表示该列不写进卡片。
  final credentialFields = <String, String?>{};
  bool busy = true;
  String? error;
  int step = 0;
  String phase = '';

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare([String? recordPath]) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final fixedTarget = widget.target;
      fixedTarget.checkSession(ref.read(applicationReaderProvider));
      final table = await compute(parseTransferTable, (
        widget.csvText,
        widget.kind,
        widget.hasHeader,
        recordPath,
      ));
      if (!mounted) return;
      final session = ref.read(transferActionsFactoryProvider)(
        fixedTarget,
        table,
        widget.kind,
      );
      await session.prepare();
      if (!mounted) return;
      setState(() {
        actions = session;
        mapping.clear();
        defaults.clear();
        mapping.addAll(table.detect(widget.kind));
        credentialFields.clear();
        if (widget.kind == TransferKind.credentials) {
          // 每列默认都作为卡片字段：命中常见表头的用规范名，其余用表头原文。
          for (final header in table.headers) {
            credentialFields[header] = credentialFieldName(header);
          }
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => error = AppLocalizations.of(context).commonOperationFailed,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 账号密码：被用作标题与时间的列不再作为卡片字段，避免同一列写入两次。
  List<({String header, String? label})> _cardFields(TransferActions session) {
    final meta = {
      for (final key in const ['title', 'created_at', 'updated_at'])
        mapping[key],
    };
    return [
      for (final header in session.table.headers)
        if (!meta.contains(header))
          (header: header, label: credentialFields[header]),
    ];
  }

  bool get hasMatching =>
      actions!.categoryMapping.isNotEmpty ||
      actions!.exerciseMapping.isNotEmpty;

  /// 将映射推进到预览，同一帧内的重复点击共用忙碌状态。
  Future<void> _next() async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (step == 0) {
        actions!.map(mapping, defaults, _cardFields(actions!));
        if (hasMatching) {
          setState(() => step = 1);
          return;
        }
      }
      await actions!.buildPreview();
      if (mounted) setState(() => step = 2);
    } catch (_) {
      if (mounted) {
        setState(
          () => error = AppLocalizations.of(context).commonOperationFailed,
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 导入进度用提示条呈现，完成后自动消失。
  ///
  /// 成功后直接关闭页面：回到预览页时全部记录已标记为重复，无法再操作；
  /// 有失败记录时留在预览页，用户可立即重试未成功的记录。
  Future<void> _import() async {
    if (busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      busy = true;
      error = null;
    });
    showToast(context, l10n.importInProgress, duration: _progressToast);
    try {
      final outcome = await actions!.import(
        (processed, count) {
          if (!mounted) return;
          showToast(
            context,
            _progressMessage(processed, count),
            duration: _progressToast,
          );
        },
        (value) {
          if (mounted) setState(() => phase = value);
        },
      );
      if (!mounted) return;
      // 跳过数含本轮之前预览阶段已判定的重复记录，与预览页口径一致。
      final skipped =
          outcome.skipped + actions!.preview.where((r) => r.duplicate).length;
      final summary = StringBuffer(
        l10n.transferResult(outcome.failed, outcome.imported, skipped),
      );
      if (outcome.pendingSync) {
        summary.write('\n${l10n.transferPendingSync}');
      }
      await actions!.refreshDuplicates();
      if (!mounted) return;
      showToast(context, summary.toString(), duration: _resultToast);
      if (outcome.failed > 0) {
        // 有失败记录时留在预览页，用户可立即重试未成功的记录。
        return;
      }
      Navigator.of(context).pop();
    } catch (failure) {
      // 事务失败或部分批次成功后重新查询回执，重试只写入尚未成功的记录。
      try {
        await actions!.refreshDuplicates();
      } catch (_) {}
      if (!mounted) return;
      // 失败改用常规时长提示条，避免长计时的进度提示残留。
      showToast(
        context,
        failure is FormatException && failure.source == null
            ? failure.message
            : l10n.transferFailed,
        duration: _resultToast,
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 进度条文案：取汇率、提交中、逐条处理三种阶段分别说明。
  String _progressMessage(int processed, int count) {
    final l10n = AppLocalizations.of(context);
    if (phase == 'rate') return l10n.importFetchingRates;
    if (count > 0 && processed == count) return l10n.transferCommitting;
    return l10n.importProgressRunning(processed, count);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = actions;
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        backgroundColor: AppTokens.scaffoldBackground(context),
        body: Column(
          children: [
            PrimaryHeader(
              title: switch (step) {
                0 => l10n.importConfirmMapping,
                1 =>
                  widget.kind == TransferKind.ledger
                      ? l10n.importCategoryMapping
                      : l10n.transferMatchingTitle,
                _ => l10n.dayCsvImportSummary,
              },
              subtitle: session == null
                  ? null
                  : l10n.transferTarget(session.targetName),
              showBack: !busy,
            ),
            if (error != null && session != null)
              AppStatusBanner(icon: AppIcons.error, message: error!),
            Expanded(
              child: session == null
                  ? busy
                        ? const Center(child: CircularProgressIndicator())
                        : AppLoadError(onRetry: _prepare, message: error)
                  : switch (step) {
                      0 => _mapping(session),
                      1 => _matching(session),
                      _ => _preview(session),
                    },
            ),
          ],
        ),
        bottomNavigationBar: session == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.p16),
                  child: Row(
                    children: [
                      if (step > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => setState(() {
                                    step = step == 2 && hasMatching ? 1 : 0;
                                    error = null;
                                  }),
                            child: Text(l10n.importPreviousStep),
                          ),
                        ),
                        const SizedBox(width: AppDimens.p12),
                      ],
                      Expanded(
                        child: AppPrimaryButton(
                          fullWidth: false,
                          label: step == 2
                              ? l10n.importStartImport
                              : l10n.importNextStep,
                          busy: busy,
                          onPressed: busy
                              ? null
                              : step == 2
                              ? session.preview.any(
                                      (r) =>
                                          r.selected &&
                                          r.error == null &&
                                          !r.duplicate,
                                    )
                                    ? _import
                                    : null
                              : session.table.records.isEmpty
                              ? null
                              : _next,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// 复用分类编辑的选择行与公共底部弹层，长字段和大字号自然换行。
  Widget _selection(
    String value,
    Map<String, String> choices,
    ValueChanged<String?> onChanged,
  ) => AppSelectionField(
    title: choices[value] ?? '',
    isPlaceholder: value.isEmpty,
    enabled: !busy,
    onTap: () async {
      final selected = await showAppRadioSheet<String>(
        context,
        title: AppLocalizations.of(context).importConfirmMapping,
        selected: value,
        options: choices,
        confirmSelection: false,
      );
      if (mounted && !busy && selected != null) onChanged(selected);
    },
  );
  Widget _mapping(TransferActions session) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        AppFormSection(
          child: Text(
            l10n.transferMappingHelp,
            style: AppTextTokens.body(context),
          ),
        ),
        // 交换格式自带本子类型：与目标类型不符时逐条都会报必填缺失，
        // 这里提前说明，用户返回上一步换目标即可。
        if (session.memoBook != null &&
            session.table.memoBookType != null &&
            session.table.memoBookType != session.memoBook!.type)
          AppFormSection(
            child: AppStatusBanner(
              icon: AppIcons.warning,
              message: l10n.transferBookTypeMismatch(
                session.table.memoBookType == 'credentials'
                    ? l10n.memoCredentials
                    : l10n.memoNormal,
                session.memoBook!.type == 'credentials'
                    ? l10n.memoCredentials
                    : l10n.memoNormal,
              ),
            ),
          ),
        if (session.table.recordPaths.length > 1)
          AppFormSection(
            title: l10n.transferJsonRoot,
            child: _selection(
              session.table.recordPath,
              {
                for (final path in session.table.recordPaths)
                  path: path.isEmpty ? l10n.transferJsonRoot : path,
              },
              (path) {
                if (path != null) _prepare(path);
              },
            ),
          ),
        if (session.table.records.isEmpty)
          AppEmpty(text: l10n.importNoDataParsed),
        for (final field in transferFields[widget.kind]!)
          AppFormSection(
            title:
                '${l10n.transferFieldLabel('f${field.key}')}${field.required ? ' *' : ''}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _selection(
                  mapping[field.key] ?? '',
                  {
                    '': field.required
                        ? l10n.transferRequired
                        : l10n.transferIgnoreField,
                    for (final header in session.table.headers) header: header,
                  },
                  (value) => setState(
                    () => mapping[field.key] = value == '' ? null : value,
                  ),
                ),
                if (!field.required && mapping[field.key] == null) ...[
                  const SizedBox(height: AppDimens.p12),
                  TextFormField(
                    key: ValueKey('default-${field.key}'),
                    initialValue:
                        defaults[field.key] ?? field.defaultValue ?? '',
                    style: AppTextTokens.input(context),
                    decoration: InputDecoration(
                      labelText: l10n.transferDefaultValue,
                      helperText: l10n.transferDefaultValueHelp,
                      helperMaxLines: 3,
                    ),
                    enabled: !busy,
                    onChanged: (value) => defaults[field.key] = value,
                  ),
                ],
              ],
            ),
          ),
        // 账号密码：文件里除标题与时间外的每一列都可作为卡片字段，名称可改。
        if (widget.kind == TransferKind.credentials &&
            session.table.records.isNotEmpty)
          AppFormSection(
            title: l10n.transferCardFields,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.transferCardFieldsHelp,
                  style: AppTextTokens.label(context),
                ),
                for (final column in _cardFields(session)) ...[
                  AppSwitchTile(
                    value: column.label != null,
                    title: column.header,
                    onChanged: busy
                        ? null
                        : (value) => setState(
                            () => credentialFields[column.header] = value
                                ? credentialFieldName(column.header)
                                : null,
                          ),
                  ),
                  if (column.label != null)
                    TextFormField(
                      key: ValueKey('card-field-${column.header}'),
                      initialValue: column.label,
                      style: AppTextTokens.input(context),
                      decoration: InputDecoration(
                        labelText: l10n.transferCardFieldName,
                      ),
                      enabled: !busy,
                      onChanged: (value) =>
                          credentialFields[column.header] = value,
                    ),
                ],
              ],
            ),
          ),
        if (session.table.records.isNotEmpty)
          AppFormSection(
            title: l10n.dayCsvImportSummary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var i = 0;
                  i < session.table.records.length && i < 3;
                  i++
                ) ...[
                  if (i > 0) ...[
                    const SizedBox(height: AppDimens.p12),
                    AppTokens.cardDivider(context),
                    const SizedBox(height: AppDimens.p12),
                  ],
                  Text(
                    session.table.records[i].entries
                        .where(
                          (e) =>
                              e.value != null &&
                              e.value is! Map &&
                              e.value is! List,
                        )
                        .take(5)
                        .map((e) => '${e.key}: ${e.value}')
                        .join('\n'),
                    style: AppTextTokens.body(context),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _matching(TransferActions session) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p16),
      children: [
        for (final path in session.categoryMapping.keys)
          AppFormSection(
            title: [
              if (path.parentName != null) path.parentName!,
              path.name,
            ].join(' > '),
            child: _selection(
              session.categoryMapping[path] ?? '',
              {
                '': session.requiresExistingCategories
                    ? l10n.transferSelectCategory
                    : l10n.importKeepOriginalName,
                for (final category in session.categories)
                  category.id: [
                    if (category.parentId != null)
                      session.categories
                              .where((p) => p.id == category.parentId)
                              .firstOrNull
                              ?.name ??
                          '',
                    category.name,
                  ].join(' > '),
              },
              (value) => setState(
                () =>
                    session.categoryMapping[path] = value == '' ? null : value,
              ),
            ),
          ),
        for (final source in session.exerciseMapping.keys)
          AppFormSection(
            title: session.catalog.any((e) => e.id == source)
                ? fitnessExerciseName(
                    context,
                    session.catalog.firstWhere((e) => e.id == source),
                  )
                : source,
            child: _selection(
              session.exerciseMapping[source] ?? '',
              {
                '': l10n.transferSelectExercise,
                for (final exercise in session.catalog)
                  exercise.id: fitnessExerciseName(context, exercise),
              },
              (value) => setState(
                () => session.exerciseMapping[source] = value == ''
                    ? null
                    : value,
              ),
            ),
          ),
      ],
    );
  }

  Widget _preview(TransferActions session) {
    final l10n = AppLocalizations.of(context);
    final rows = session.preview;
    final valid = rows.where((r) => r.error == null && !r.duplicate).toList();
    final count = valid.where((r) => r.selected).length;
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.p16),
      itemCount: rows.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return AppFormSection(
            title: l10n.importPrecheckTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.transferSummary(
                    rows.where((r) => r.duplicate).length,
                    rows.where((r) => r.error != null).length,
                    count,
                    rows.length,
                    rows.where((r) => r.error == null).length,
                  ),
                  style: AppTextTokens.body(context),
                ),
                if (widget.kind == TransferKind.fitness) ...[
                  const SizedBox(height: AppDimens.p12),
                  Text(
                    l10n.transferFitnessHint,
                    style: AppTextTokens.label(context),
                  ),
                ],
                const SizedBox(height: AppDimens.p8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.transferSelectAll,
                    style: AppTextTokens.body(context),
                  ),
                  value: valid.isNotEmpty && count == valid.length,
                  onChanged: busy
                      ? null
                      : (selected) => setState(() {
                          for (final row in valid) {
                            row.selected = selected ?? false;
                          }
                        }),
                ),
              ],
            ),
          );
        }
        final row = rows[i - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.p8),
          child: SectionCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p12,
                vertical: AppDimens.p4,
              ),
              value: row.selected,
              onChanged: busy || row.error != null || row.duplicate
                  ? null
                  : (v) => setState(() => row.selected = v ?? false),
              title: Text(
                l10n.transferRecord(
                  '${row.lines.take(3).join('、')}${row.lines.length > 3 ? '…' : ''}',
                  row.title.isEmpty ? l10n.transferUnnamed : row.title,
                ),
                style: AppTextTokens.body(context),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppDimens.p4),
                child: Text(
                  row.error ??
                      (row.duplicate
                          ? l10n.transferDuplicate
                          : l10n.transferValid),
                  style: AppTextTokens.label(context).copyWith(
                    color: row.error == null ? null : AppTokens.error(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
