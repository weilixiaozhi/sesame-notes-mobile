import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/settings/application/import_export_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/data/models.dart' as schema;
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/presentation/category_utils.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/date/date_parser.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ImportConfirmPage extends ConsumerStatefulWidget {
  final String csvText;
  final bool hasHeader;
  final String targetLedgerId;

  /// 创建导入确认页，目标账本必须由入口页的用户选择结果显式传入。
  const ImportConfirmPage({
    super.key,
    required this.csvText,
    required this.hasHeader,
    required this.targetLedgerId,
  });

  @override
  ConsumerState<ImportConfirmPage> createState() => _ImportConfirmPageState();
}

class _ImportConfirmPageState extends ConsumerState<ImportConfirmPage> {
  List<List<String>> rows = const [];
  bool parsing = true;
  bool _parseError = false;
  // 自动识别到的表头所在行（仅当 hasHeader 为 true 时使用）
  int headerRow = 0;
  final Map<String, int?> mapping = {
    'date': null,
    'type': null,
    'amount': null,
    'currency': null, // 多币种:币种列
    'category': null,
    'sub_category': null, // 二级分类
    'category_icon': null, // 分类图标列（可选）
    'sub_category_icon': null, // 二级分类图标列（可选）
    'note': null,
    // 无标签和附件字段
  };
  bool importing = false;
  int ok = 0, fail = 0, skipped = 0; // skipped: 跳过的非支出类型记录
  int step = 0; // 0: 字段映射, 1: 分类映射
  bool _cancelled = false;
  int _sessionSeq = 0; // 导入会话号:延迟清空进度时校验仍是最新会话
  List<schema.ImportCategoryPath> distinctCategories = [];
  Map<schema.ImportCategoryPath, String?> categoryMapping = {};
  Future<List<schema.CategoryDisplay>>? allCategoriesFuture;
  late final String _targetLedgerId;
  late final Future<LedgerDisplayItem?> _targetLedgerFuture;
  bool _requiresExistingCategoryMapping = false;
  final Map<String, int> _badRows = {}; // 解析失败原因 -> 行数
  _ImportPrecheck? _precheck; // 分类映射步展示的导入预检查摘要

  @override
  void initState() {
    super.initState();
    // 入口页已让用户明确选择目标；确认页只保存该参数，不能再读取可能变化的全局账本。
    _targetLedgerId = widget.targetLedgerId.trim();
    _targetLedgerFuture = _targetLedgerId.isEmpty
        ? Future<LedgerDisplayItem?>.value(null)
        : ref.read(ledgerActionsProvider).getById(_targetLedgerId);
    // 合并入口后统一使用通用解析器（已吸收支付宝/微信关键词检测）
    // 解析在后台 isolate 完成，避免主线程卡顿
    () async {
      List<List<String>> parsed;
      try {
        parsed = await compute(parseImportRows, widget.csvText);
      } catch (e, st) {
        // isolate 解析异常(畸形 CSV/内存不足等)不能停在加载态:
        // 置错误态并提示用户返回,而不是永久转圈。
        logger.error('ImportConfirmPage', 'CSV 后台解析失败', e, st);
        if (!mounted) return;
        setState(() {
          parsing = false;
          _parseError = true;
        });
        return;
      }
      LedgerDisplayItem? targetLedger;
      try {
        targetLedger = await _targetLedgerFuture;
      } catch (e, st) {
        logger.error(
          'ImportConfirmPage',
          '读取导入目标账本上下文失败 ledger=$_targetLedgerId',
          e,
          st,
        );
      }
      if (!mounted) return;
      setState(() {
        rows = parsed;
        parsing = false;
        _requiresExistingCategoryMapping =
            targetLedger != null &&
            targetLedger.memberCount > 1 &&
            targetLedger.myRole != 'owner';
      });
      // 解析完成
      // 使用解析器查找表头
      if (widget.hasHeader && rows.isNotEmpty) {
        headerRow = ref.read(importActionsProvider).findHeaderRow(rows);
        if (headerRow < 0) headerRow = 0; // 兜底
      }
      _autoDetectMapping();
      // 预取分类列表供第二步选择
      allCategoriesFuture = _loadAllCategories(ref, _targetLedgerId);
    }();
  }

  void _autoDetectMapping() {
    if (rows.isEmpty || !widget.hasHeader) return;
    final headers = rows[headerRow].map((e) => e.toString().trim()).toList();

    // 使用解析器的列映射功能
    final detectedMapping = ref.read(importActionsProvider).mapColumns(headers);

    // 更新 mapping
    detectedMapping.forEach((key, index) {
      if (mapping.containsKey(key)) {
        mapping[key] = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (parsing) {
      return Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              title: AppLocalizations.of(context).importPreparing,
              showBack: true,
            ),
            Expanded(child: Center(child: CircularProgressIndicator())),
          ],
        ),
      );
    }
    if (_parseError) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        body: Column(
          children: [
            PrimaryHeader(title: l10n.importPreparing, showBack: true),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.commonOperationFailed,
                      style: TextStyle(color: AppTokens.textSecondary(context)),
                    ),
                    const SizedBox(height: AppDimens.p12),
                    FilledButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text(l10n.commonBack),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    final columnCount = rows.isNotEmpty
        ? rows[widget.hasHeader ? headerRow : 0].length
        : 0;
    final dataStart = widget.hasHeader ? headerRow + 1 : 0;
    final hasDataRows = rows.length > dataStart;
    List<DropdownMenuItem<int>> items() => List.generate(columnCount, (i) {
      final header = widget.hasHeader
          ? rows[headerRow]
          : (rows.isNotEmpty ? rows.first : const <String>[]);
      final label =
          (widget.hasHeader && i < header.length && header[i].trim().isNotEmpty)
          ? header[i].trim()
          : AppLocalizations.of(context).importColumnNumber(i + 1);
      return DropdownMenuItem(
        value: i,
        child: Text(label, overflow: TextOverflow.ellipsis),
      );
    });

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrimaryHeader(
            title: step == 0
                ? AppLocalizations.of(context).importConfirmMapping
                : AppLocalizations.of(context).importCategoryMapping,
            showBack: true,
          ),
          FutureBuilder<LedgerDisplayItem?>(
            future: _targetLedgerFuture,
            builder: (context, snapshot) {
              final ledger = snapshot.data;
              if (ledger == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.p16,
                  AppDimens.p8,
                  AppDimens.p16,
                  0,
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).detailImportTargetLedger(ledger.name),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTokens.textSecondary(context),
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p16,
                AppDimens.p8,
                AppDimens.p16,
                AppDimens.p16,
              ),
              children: [
                if (step == 0) ...[
                  if (!hasDataRows)
                    Text(AppLocalizations.of(context).importNoDataParsed),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _mapRow(
                        AppLocalizations.of(context).importFieldDate,
                        'date',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldType,
                        'type',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldAmount,
                        'amount',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldCurrency,
                        'currency',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldCategory,
                        'category',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).exportCsvHeaderSubCategory,
                        'sub_category',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldCategoryIcon,
                        'category_icon',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldSubCategoryIcon,
                        'sub_category_icon',
                        items(),
                      ),
                      _mapRow(
                        AppLocalizations.of(context).importFieldNote,
                        'note',
                        items(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.p12),
                  // 预览仅展示前 N 行，避免大文件一次性渲染导致卡顿
                  Text(
                    AppLocalizations.of(context).importPreview,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppDimens.p4),
                  SizedBox(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Builder(
                        builder: (_) {
                          const int maxPreview = 10; // 预览最多 100 行
                          final totalRows = rows.length;
                          final dataStart = widget.hasHeader
                              ? (headerRow + 1)
                              : 0;
                          // 保证包含表头行 + 最多 maxPreview-1 行数据
                          // 空 CSV 时 headerRow 无实际含义，必须跳过取数，
                          // 否则 rows[headerRow] 越界崩溃（空文件也应友好提示）。
                          final header = (widget.hasHeader && rows.isNotEmpty)
                              ? [rows[headerRow]]
                              : <List<String>>[];
                          final body = totalRows > dataStart
                              ? () {
                                  final take = (maxPreview - header.length);
                                  final end = (dataStart + take <= totalRows)
                                      ? dataStart + take
                                      : totalRows;
                                  return rows.sublist(dataStart, end);
                                }()
                              : const <List<String>>[];
                          final limited = [...header, ...body];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PreviewTable(rows: limited),
                              if (totalRows > limited.length)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: AppDimens.p4,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(
                                      context,
                                    ).importPreviewLimit(
                                      limited.length,
                                      totalRows,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTokens.textTertiary(
                                            context,
                                          ),
                                        ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  if (mapping['category'] == null)
                    Text(
                      AppLocalizations.of(context).importCategoryNotSelected,
                    ),
                  // 导入预检查摘要：开始前展示总行数与问题行统计
                  if (_precheck != null) ...[
                    Text(
                      AppLocalizations.of(context).importPrecheckTitle,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppDimens.p4),
                    Text(
                      AppLocalizations.of(
                        context,
                      ).importPrecheckTotal(_precheck!.totalRows),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.textSecondary(context),
                      ),
                    ),
                    for (final (count, key) in [
                      (_precheck!.invalidAmount, 'amount'),
                      (_precheck!.invalidDate, 'date'),
                      (_precheck!.invalidCurrency, 'currency'),
                      (_precheck!.missingCategory, 'category'),
                      (_precheck!.skippedType, 'type'),
                    ])
                      if (count > 0)
                        Text(
                          switch (key) {
                            'amount' => AppLocalizations.of(
                              context,
                            ).importPrecheckBadAmount(count),
                            'date' => AppLocalizations.of(
                              context,
                            ).importPrecheckBadDate(count),
                            'currency' => AppLocalizations.of(
                              context,
                            ).importPrecheckBadCurrency(count),
                            'category' => AppLocalizations.of(
                              context,
                            ).importPrecheckMissingCategory(count),
                            _ => AppLocalizations.of(
                              context,
                            ).importPrecheckSkippedType(count),
                          },
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTokens.textTertiary(context),
                              ),
                        ),
                    const SizedBox(height: AppDimens.p8),
                  ],
                  Text(
                    _requiresExistingCategoryMapping
                        ? AppLocalizations.of(
                            context,
                          ).categorySharedManageBannerEditor
                        : AppLocalizations.of(
                            context,
                          ).importCategoryMappingDescription,
                  ),
                  const SizedBox(height: AppDimens.p8),
                  FutureBuilder<List<schema.CategoryDisplay>>(
                    future: allCategoriesFuture,
                    builder: (context, snap) {
                      final cats = snap.data ?? [];
                      final l10n = AppLocalizations.of(context);
                      // 按「先一级、再其下二级、再下个一级」分组排序，便于用户按层级浏览
                      final orderedCats = _groupCategoriesByLevel(cats);
                      final parentNames = {
                        for (final c in cats.where((c) => c.level == 1))
                          c.id: CategoryUtils.getDisplayName(
                            c.name,
                            context,
                            kind: c.kind,
                          ),
                      };
                      final items = <DropdownMenuItem<String?>>[
                        if (!_requiresExistingCategoryMapping)
                          DropdownMenuItem(
                            value: null,
                            child: Text(l10n.importKeepOriginalName),
                          ),
                        ...orderedCats.map((c) {
                          // 显示分类名 + 层级标签（一级/二级）
                          final levelLabel = c.level == 1
                              ? l10n.categoryTopLevelLabel
                              : l10n.categorySecondLevelLabel;
                          final isSub = c.level != 1;
                          final displayName = CategoryUtils.getDisplayName(
                            c.name,
                            context,
                            kind: c.kind,
                          );
                          final pathName = isSub
                              ? '${parentNames[c.parentId] ?? ''} > $displayName'
                              : displayName;
                          return DropdownMenuItem<String?>(
                            value: c.id,
                            // 二级分类缩进，视觉上体现父子层级
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: isSub ? AppDimens.p16 : 0.0,
                              ),
                              child: Text('$pathName（$levelLabel）'),
                            ),
                          );
                        }),
                      ];
                      return Column(
                        children: [
                          for (final path in distinctCategories)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.p4,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      path.parentName == null
                                          ? path.name
                                          : '${path.parentName} > ${path.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.p12),
                                  DropdownButton<String?>(
                                    value: categoryMapping[path],
                                    hint: Text(l10n.importAutoDetect),
                                    items: items,
                                    onChanged: (v) => setState(
                                      () => categoryMapping[path] = v,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Row(
                children: [
                  if (importing)
                    Text(AppLocalizations.of(context).importProgress(ok, fail)),
                  const Spacer(),
                  if (step == 0)
                    FilledButton(
                      onPressed: hasDataRows
                          ? () {
                              // 检查是否有分类列映射
                              if (mapping['category'] == null) {
                                // 没有分类列，提示用户先选择分类列
                                showToast(
                                  context,
                                  AppLocalizations.of(
                                    context,
                                  ).importSelectCategoryFirst,
                                );
                                return;
                              }
                              _buildDistinctCategories();
                              setState(() => step = 1);
                            }
                          : null,
                      child: Text(AppLocalizations.of(context).importNextStep),
                    )
                  else ...[
                    OutlinedButton(
                      onPressed: importing
                          ? null
                          : () => setState(() => step = 0),
                      child: Text(
                        AppLocalizations.of(context).importPreviousStep,
                      ),
                    ),
                    const SizedBox(width: AppDimens.p12),
                    FilledButton(
                      onPressed: importing ? null : _startImport,
                      child: Text(
                        AppLocalizations.of(context).importStartImport,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapRow(String label, String key, List<DropdownMenuItem<int>> items) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 64, child: Text(label)),
        const SizedBox(width: AppDimens.p8),
        SizedBox(
          width: 220,
          child: DropdownButton<int>(
            isExpanded: true,
            value: mapping[key],
            hint: Text(AppLocalizations.of(context).importAutoDetect),
            items: items,
            onChanged: (v) => setState(() => mapping[key] = v),
          ),
        ),
      ],
    );
  }

  Future<void> _startImport() async {
    if (importing) return;
    final dataStart = widget.hasHeader ? headerRow + 1 : 0;
    if (rows.length <= dataStart) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).importNoDataParsed);
      }
      return;
    }
    // 使用页面打开时捕获的目标，导入过程中切换全局账本不会改变落库位置。
    final ledgerId = _targetLedgerId;
    if (ledgerId.isEmpty) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).importNoLedger);
      }
      return;
    }

    // 使用根容器，保证页面被销毁后仍可更新全局进度供"我的"页展示
    final container = ProviderScope.containerOf(context, listen: false);
    final currentContext = context;
    final session = ++_sessionSeq;
    _cancelled = false;
    setState(() {
      importing = true;
      ok = 0;
      fail = 0;
    });
    late final LedgerDisplayItem currentLedger;
    late final String authorMemberId;
    Set<String>? allowedCategoryIds;
    try {
      // ID 固定但账本可能在解析期间被删除；开始写入前必须重新确认存活。
      final ledger = await ref.read(ledgerActionsProvider).getById(ledgerId);
      if (ledger == null) {
        if (mounted) {
          showToast(context, AppLocalizations.of(context).importNoLedger);
          setState(() => importing = false);
        }
        return;
      }
      currentLedger = ledger;

      final requiresOwnerCategories =
          currentLedger.memberCount > 1 && currentLedger.myRole != 'owner';
      if (requiresOwnerCategories) {
        if (categoryMapping.values.any((id) => id == null)) {
          logger.warning(
            'ImportConfirmPage',
            '共享账本存在未映射分类，拒绝导入 ledger=$ledgerId',
          );
          if (mounted) {
            showToast(
              context,
              AppLocalizations.of(context).importSharedCategoryRequired,
            );
            setState(() => importing = false);
          }
          return;
        }
        // 传给服务层做第二道权限校验，避免页面状态被绕过后写入 Editor 私有 UUID。
        final ownerCategories = await allCategoriesFuture ?? const [];
        allowedCategoryIds = {for (final c in ownerCategories) c.id};
      }

      final selfMemberId = currentLedger.selfMemberId;
      if (selfMemberId != null && selfMemberId.isNotEmpty) {
        authorMemberId = selfMemberId;
      } else if (currentLedger.storageMode == 'local') {
        authorMemberId = await authorMemberIdForLedger(ref, ledgerId);
        final member = await ref
            .read(importActionsProvider)
            .getMember(authorMemberId);
        if (member == null || member.ledgerId != ledgerId) {
          throw StateError('本地账本 self member 创建失败：$ledgerId');
        }
      } else {
        logger.warning(
          'ImportConfirmPage',
          '拒绝导入成员身份未就绪的云端账本 ledger=$ledgerId role=${currentLedger.myRole}',
        );
        if (mounted) {
          showToast(
            context,
            AppLocalizations.of(context).sharedMembersLoadingHint,
          );
          setState(() => importing = false);
        }
        return;
      }
    } catch (e, st) {
      logger.error('ImportConfirmPage', '导入预检失败 ledger=$ledgerId', e, st);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
        setState(() => importing = false);
      }
      return;
    }
    final total = rows.length - dataStart;
    // 初始化全局进度
    container
        .read(importProgressProvider.notifier)
        .set(
          ImportProgress(running: true, total: total, done: 0, ok: 0, fail: 0),
        );

    bool dialogOpen = true;
    // 进度弹窗（可转后台）
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dctx) {
        return Consumer(
          builder: (dctx, r, _) {
            final p = r.watch(importProgressProvider);
            final percent = p.total == 0
                ? 0.0
                : (p.done / p.total).clamp(0.0, 1.0);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radius12),
              ),
              title: Text(AppLocalizations.of(context).importInProgress),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: percent > 0 && percent < 1 ? percent : null,
                  ),
                  const SizedBox(height: AppDimens.p8),
                  // 汇率阶段进度条不动（补拉最多 24s），用专属文案消除误解；
                  // 进入落库阶段后展示实时进度文案。
                  if (p.phase == 'rate')
                    Text(
                      AppLocalizations.of(context).importFetchingRates,
                      style: Theme.of(dctx).textTheme.bodySmall?.copyWith(
                        color: AppTokens.textTertiary(context),
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(
                        context,
                      ).importProgressRunning(p.done, p.total),
                      style: Theme.of(dctx).textTheme.bodySmall?.copyWith(
                        color: AppTokens.textTertiary(context),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    dialogOpen = false;
                    Navigator.of(dctx).pop();
                    // 返回到明细导入导出页继续后台导入
                    // 栈:明细导入导出页 -> ImportConfirmPage,仅需 pop 一次
                    if (mounted) {
                      Navigator.of(
                        currentContext,
                      ).pop(); // Close ImportConfirmPage
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context).importBackgroundImport,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _cancelled = true;
                    dialogOpen = false;
                    Navigator.of(dctx).pop();
                  },
                  child: Text(AppLocalizations.of(context).importCancelImport),
                ),
              ],
            );
          },
        );
      },
    );

    // 定义进度变量
    int done = 0;
    int duplicateSkipped = 0;
    _badRows.clear();

    // 收集跳过的类型（用于提示用户）
    final Map<String, int> skippedTypes = {};

    try {
      if (_cancelled) return;
      // 使用统一导入服务：将CSV数据转换为ImportData格式
      final importData = _buildImportDataFromCsv(
        rows: rows,
        dataStart: dataStart,
        targetLedgerId: ledgerId,
        mapping: mapping,
        categoryMapping: categoryMapping,
        skippedTypes: skippedTypes,
        badRows: _badRows,
      );

      // 调用统一导入服务
      final result = await ref
          .read(importActionsProvider)
          .import(
            ledgerId: ledgerId,
            data: importData,
            authorMemberId: authorMemberId,
            allowCategoryCreation: allowedCategoryIds == null,
            allowedCategoryIds: allowedCategoryIds,
            onPhase: (phase) {
              // 阶段信息写入全局进度：弹窗据此展示「正在获取汇率…」等文案。
              container
                  .read(importProgressProvider.notifier)
                  .set(
                    ImportProgress(
                      running: true,
                      total: total,
                      done: done,
                      ok: ok,
                      fail: fail,
                      phase: phase,
                    ),
                  );
            },
            onProgress: (processed, progressTotal) {
              // 批次间隙检查取消:抛异常中止导入服务,未处理批次不写入。
              if (_cancelled) {
                throw const ImportCancelledException();
              }
              done = processed;
              // 更新全局进度
              container
                  .read(importProgressProvider.notifier)
                  .set(
                    ImportProgress(
                      running: true,
                      total: total,
                      done: done,
                      ok: ok,
                      fail: fail,
                    ),
                  );
              if (mounted) setState(() {});
            },
          );

      ok = result.inserted;
      fail =
          result.failed + _badRows.values.fold(0, (sum, count) => sum + count);
      skipped = skippedTypes.values.fold(0, (a, b) => a + b);
      duplicateSkipped = result.duplicateSkipped;
      done = total;

      // 显式触发一次同步上推。SyncCoordinator 监听 local_changes 表已经会
      // 自动调度,这里作为兜底:provider 重建瞬间 / 边界条件下 coordinator
      // 还没就位时,UI 显式触发也能把刚导入的数据推上云端。
      // fire-and-forget:不阻塞导入完成动画。
    } on ImportCancelledException {
      // 用户取消:已落库的批次保留,未处理批次不写入;清空全局进度
      // 并提示,不展示完成弹窗、不跳转。
      try {
        container
            .read(importProgressProvider.notifier)
            .set(ImportProgress.empty);
      } catch (_) {}
      if (mounted) {
        showToast(context, AppLocalizations.of(context).importCancelled);
        setState(() => importing = false);
      }
      return;
    } catch (e, st) {
      // 导入失败:原始异常只进日志,页面展示统一友好文案。
      logger.error('ImportConfirmPage', '明细导入失败', e, st);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
      fail = total - ok; // 更新失败数
    }

    // 即使页面已被关闭（mounted=false），也要继续更新全局进度供"我的"页展示
    // 先切换为"完成"以驱动 UI 展示成功动画/提示（不等待云上传）
    try {
      container
          .read(importProgressProvider.notifier)
          .set(
            ImportProgress(
              running: false,
              total: total,
              done: done,
              ok: ok,
              fail: fail,
              ledgerId: ledgerId, // 设置账本ID，用于触发账本列表页面刷新
              skipped: skipped, // 跳过的记录数
              skippedTypes: skippedTypes, // 跳过的类型及数量
            ),
          );
    } catch (_) {
      // 忽略进度更新错误
    }

    // 延迟清空和刷新（不依赖页面状态，即使页面销毁也要执行）
    if (!_cancelled) {
      Future<void>.delayed(const Duration(seconds: 5), () {
        // 会话号校验:期间若发起了新导入,旧回调不得清掉新进度。
        if (session != _sessionSeq) return;
        // 延长到5秒，让用户看到动画
        try {
          container
              .read(importProgressProvider.notifier)
              .set(ImportProgress.empty);
          // 刷新"我的"页统计（笔数/天数）
          container.invalidate(countsForLedgerProvider(ledgerId));
          // 汇总/统计刷新由统一数据变更信号自动驱动（导入写库即触发）。
        } catch (_) {
          // 忽略延迟刷新错误
        }
      });
    }

    // 校验 context 仍挂载,保证 UI 操作安全
    if (!currentContext.mounted) {
      return;
    }

    // 显示导入完成提示
    final cancelledText = _cancelled
        ? AppLocalizations.of(currentContext).importCancelled
        : '';
    final l10nToast = AppLocalizations.of(currentContext);

    // 构建提示信息
    String message = l10nToast.importCompleted(cancelledText, fail, ok);
    final badRowCount = _badRows.values.fold(0, (sum, count) => sum + count);
    if (badRowCount > 0) {
      message += '\n${l10nToast.importInvalidRowsSkipped(badRowCount)}';
    }
    // 数据总行数恒等：成功 + 失败 + 非支出跳过 + 重复跳过 = 总行数。
    // 重复跳过单独展示，不计入成功/失败。
    if (duplicateSkipped > 0) {
      message += '\n${l10nToast.importDuplicatesSkipped(duplicateSkipped)}';
    }
    // 云端账本：本地落库成功 ≠ 云端已接受。同步监听约 2 秒防抖后自动
    // 推送上云，这里展示尚未推送的条数，避免用户误以为已完成云端写入。
    var pendingSync = 0;
    if (currentLedger.storageMode == 'cloud') {
      try {
        pendingSync = await ref
            .read(importActionsProvider)
            .countPendingChanges(ledgerId);
        if (pendingSync > 0) {
          message += '\n${l10nToast.importPendingSync(pendingSync)}';
        }
      } catch (e) {
        // 待同步提示失败不阻断完成展示，仅记录日志。
        logger.warning('ImportConfirmPage', '查询待同步条数失败: $e');
      }
    }
    // 待同步查询引入了新的 async 间隙：后续弹窗/toast 使用 context 前
    // 必须重新确认页面仍挂载，避免跨间隙使用已销毁的 BuildContext。
    if (!currentContext.mounted) {
      return;
    }
    // 有待同步提示时也走弹窗路径，保证用户能看到云端状态（toast 会截断）。
    bool hasSkipped = skipped > 0 || duplicateSkipped > 0 || pendingSync > 0;

    if (hasSkipped) {
      // 显示类型不匹配的跳过记录
      final typeSkipped = skippedTypes.values.fold(0, (a, b) => a + b);

      if (typeSkipped > 0) {
        final skippedList = skippedTypes.entries
            .map((e) => '${e.key}(${e.value})')
            .join('、');
        message +=
            '\n${l10nToast.importSkippedNonTransactionTypes(typeSkipped)}\n$skippedList';
      }
    }

    // 上传云端前完成 UI 操作
    if (dialogOpen) {
      Navigator.of(currentContext).pop();
    }

    // 判断显示方式: 完全成功用toast,有失败或跳过用弹窗
    if (fail == 0 && !hasSkipped) {
      // 完全成功: 使用toast,然后关闭页面
      showToast(currentContext, message);
      // 关闭确认页 -> 返回到明细导入导出页
      // 栈:明细导入导出页 -> ImportConfirmPage,仅需 pop 一次
      Navigator.of(currentContext).pop(); // Close ImportConfirmPage
    } else {
      // 有失败或跳过: 使用弹窗显示详细信息,等待用户确认后再关闭页面
      await showDialog(
        context: currentContext,
        builder: (ctx) => AlertDialog(
          title: Text(l10nToast.importCompleteTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10nToast.commonConfirm),
            ),
          ],
        ),
      );

      // 用户确认后再关闭页面
      // 栈:明细导入导出页 -> ImportConfirmPage,仅需 pop 一次
      if (currentContext.mounted) {
        Navigator.of(currentContext).pop(); // Close ImportConfirmPage
      }
    }
    // 导入完成后，账本列表页面会通过监听 importProgressProvider 自动刷新
    // ledgerId 已经在上面的 importProgressProvider 中设置
  }

  /// 将CSV数据转换为统一的ImportData格式
  schema.ImportData _buildImportDataFromCsv({
    required List<List<String>> rows,
    required int dataStart,
    required String targetLedgerId,
    required Map<String, int?> mapping,
    required Map<schema.ImportCategoryPath, String?> categoryMapping,
    required Map<String, int> skippedTypes,
    required Map<String, int> badRows,
  }) {
    // 稳定文件指纹：解析后的二维 rows 做无歧义 JSON 序列化后哈希，
    // CRLF/BOM 等物理差异不会产生不同指纹（同一逻辑文件 → 同一指纹）。
    final fileHash = sha256.convert(utf8.encode(jsonEncode(rows))).toString();
    final categories = <schema.ImportCategory>[];
    final transactions = <schema.ImportTransaction>[];
    final categoryInfoMap =
        <({String name, String kind, String? parentName}), String?>{};

    // 每行先完成全部校验，再同时收集交易与所需分类，避免坏行创建孤儿分类。
    for (int i = dataStart; i < rows.length; i++) {
      final r = rows[i];

      String? getBy(String key) {
        final userIdx = mapping[key];
        if (userIdx != null && userIdx >= 0 && userIdx < r.length) {
          final val = r[userIdx].toString().trim();
          return val.isNotEmpty ? val : null;
        }
        return null;
      }

      final dateStr = getBy('date');
      final typeRaw = getBy('type') ?? 'expense';
      final amountStr = getBy('amount');
      final currencyStr = getBy('currency')?.trim().toUpperCase();
      final categoryName = getBy('category');
      final subCategoryName = getBy('sub_category');
      final categoryIcon = getBy('category_icon');
      final subCategoryIcon = getBy('sub_category_icon');
      final note = getBy('note');
      // 无标签和附件列

      // 类型识别（全局仅支出模式，仅识别支出类型）
      final typeStr = typeRaw.trim().toLowerCase();
      String? type;
      if (typeStr == '支出' ||
          typeStr == '支' ||
          typeStr == '出账' ||
          typeStr == '消费' ||
          typeStr == '花费' ||
          typeStr == '出帳' ||
          typeStr == '消費' ||
          typeStr == '花費' || // 繁体
          typeStr == 'expense' ||
          typeStr == 'spending' ||
          typeStr == 'expenditure') {
        type = 'expense';
      } else {
        // 未识别的类型：记录并跳过
        skippedTypes[typeRaw.trim()] = (skippedTypes[typeRaw.trim()] ?? 0) + 1;
        continue;
      }

      // 金额解析:缺失或无法解析的行按失败计数并跳过,
      // 禁止把坏行静默当作 0 元交易写入账本。
      if (amountStr == null) {
        badRows['amount'] = (badRows['amount'] ?? 0) + 1;
        continue;
      }
      final amount = _parseImportAmount(amountStr);
      if (amount == null) {
        badRows['amount'] = (badRows['amount'] ?? 0) + 1;
        continue;
      }

      // 日期解析:缺失或格式无法识别同样按失败处理,不静默回退当前时间。
      final date = DateParser.tryParse(dateStr);
      if (date == null) {
        badRows['date'] = (badRows['date'] ?? 0) + 1;
        continue;
      }

      // 无标签和附件解析

      // 处理分类：支持用户映射和二级分类
      String? finalCategoryName;
      String? finalCategoryParentName;
      String? categoryKind;
      String? categoryId;

      if (subCategoryName != null && categoryName != null) {
        final sourcePath = (
          kind: type,
          parentName: categoryName,
          name: subCategoryName,
        );
        final chosen = categoryMapping[sourcePath];
        if (chosen != null) {
          categoryId = chosen;
        } else {
          finalCategoryName = subCategoryName;
          finalCategoryParentName = categoryName;
          categoryKind = type;
        }
      } else if (categoryName != null) {
        // 只有一级分类：检查用户映射
        final sourcePath = (kind: type, parentName: null, name: categoryName);
        final chosen = categoryMapping[sourcePath];
        if (chosen != null) {
          // 用户选择了现有分类，使用预解析的ID
          categoryId = chosen;
        } else {
          // 保持原名
          finalCategoryName = categoryName;
          categoryKind = type;
        }
      }

      final transaction = schema.ImportTransaction(
        type: type,
        amount: amount,
        // 非空原值必须经过共享支持列表校验，不能静默回退成本位币。
        currencyCode: currencyStr,
        categoryName: finalCategoryName,
        categoryParentName: finalCategoryParentName,
        categoryKind: categoryKind,
        categoryId: categoryId,
        happenedAt: date,
        note: note,
        // 确定性幂等键：同一逻辑文件同一行同一账本导入多次只落一份；
        // 行号参与派生，同文件内完全相同的两行不会互相去重。
        syncId: buildCsvImportSyncId(
          targetLedgerId: targetLedgerId,
          fileHash: fileHash,
          rowIndex: i,
        ),
      );
      final validationErrors = validateImportTransactionInput(transaction);
      if (validationErrors.isNotEmpty) {
        badRows['transaction'] = (badRows['transaction'] ?? 0) + 1;
        logger.warning(
          'ImportConfirmPage',
          'CSV 第 ${i + 1} 行校验失败，跳过: ${validationErrors.join("; ")}',
        );
        continue;
      }

      // 只有最终会落库且保持原分类路径的账单，才需要创建对应分类。
      if (finalCategoryName != null) {
        if (finalCategoryParentName != null) {
          categoryInfoMap.putIfAbsent((
            name: finalCategoryParentName,
            kind: type,
            parentName: null,
          ), () => categoryIcon);
          categoryInfoMap.putIfAbsent((
            name: finalCategoryName,
            kind: type,
            parentName: finalCategoryParentName,
          ), () => subCategoryIcon);
        } else {
          categoryInfoMap.putIfAbsent((
            name: finalCategoryName,
            kind: type,
            parentName: null,
          ), () => categoryIcon);
        }
      }
      transactions.add(transaction);
    }

    // 分类服务要求一级先于二级，确保父 UUID 已建立后再创建子分类。
    for (final entry in categoryInfoMap.entries.where(
      (entry) => entry.key.parentName == null,
    )) {
      categories.add(
        schema.ImportCategory(
          name: entry.key.name,
          kind: entry.key.kind,
          level: 1,
          icon: entry.value,
        ),
      );
    }
    for (final entry in categoryInfoMap.entries.where(
      (entry) => entry.key.parentName != null,
    )) {
      categories.add(
        schema.ImportCategory(
          name: entry.key.name,
          kind: entry.key.kind,
          level: 2,
          icon: entry.value,
          parentName: entry.key.parentName,
        ),
      );
    }

    return schema.ImportData(
      categories: categories,
      transactions: transactions,
    );
  }

  void _buildDistinctCategories() {
    final catIdx = mapping['category'];
    if (catIdx == null) {
      distinctCategories = [];
      categoryMapping = {};
      return;
    }
    final subIdx = mapping['sub_category'];
    final set = <schema.ImportCategoryPath>{};
    final dataStart = widget.hasHeader ? (headerRow + 1) : 0;
    for (int i = dataStart; i < rows.length; i++) {
      if (catIdx < rows[i].length) {
        final parentName = rows[i][catIdx].trim();
        if (parentName.isEmpty) continue;
        final childName =
            subIdx != null && subIdx >= 0 && subIdx < rows[i].length
            ? rows[i][subIdx].trim()
            : '';
        set.add((
          kind: 'expense',
          parentName: childName.isEmpty ? null : parentName,
          name: childName.isEmpty ? parentName : childName,
        ));
      }
    }
    distinctCategories = set.toList()
      ..sort((a, b) {
        final parent = (a.parentName ?? '').compareTo(b.parentName ?? '');
        return parent != 0 ? parent : a.name.compareTo(b.name);
      });
    // 预检查摘要：与导入解析共用同一套校验规则，让用户开始前
    // 就知道会跳过/失败多少行，而不是等完成弹窗才看到明细。
    _precheck = _scanPrecheck();

    // 初始化分类映射为 null,自动匹配由 _autoMatchCategories 在数据到达后执行。
    categoryMapping = {for (final path in distinctCategories) path: null};
    // 自动匹配推迟到本帧构建完成后再执行:分类下拉的 items 由
    // FutureBuilder 在首帧订阅后经微任务交付,若在订阅前就把 value 设为
    // 非 null,首帧会出现"items 为空但 value 已选中"的瞬态,触发
    // DropdownButton 断言崩溃。post-frame 回调晚于该微任务,保证映射
    // 落盘时 items 已就绪。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _autoMatchCategories();
    });
  }

  /// 扫描数据行统计导入预检问题（与正式解析共用同一套校验规则）。
  ///
  /// 只统计不落库：让用户在「开始导入」前看到会有多少行被跳过或失败，
  /// 避免完成后才发现大量行未导入。顺序与 [_buildImportDataFromCsv] 一致：
  /// 先类型识别（非支出跳过），再金额/日期/币种校验，最后分类缺失。
  _ImportPrecheck _scanPrecheck() {
    final dataStart = widget.hasHeader ? (headerRow + 1) : 0;
    final catIdx = mapping['category'];
    final curIdx = mapping['currency'];
    final amountIdx = mapping['amount'];
    final dateIdx = mapping['date'];
    final typeIdx = mapping['type'];

    int invalidAmount = 0, invalidDate = 0, invalidCurrency = 0;
    int missingCategory = 0, skippedType = 0;
    int total = 0;

    String? cell(int? idx, List<String> row) {
      if (idx == null || idx < 0 || idx >= row.length) return null;
      final v = row[idx].toString().trim();
      return v.isNotEmpty ? v : null;
    }

    for (int i = dataStart; i < rows.length; i++) {
      final r = rows[i];
      total++;
      // 类型识别与导入一致：仅支出类型参与统计，其余计为跳过。
      final typeStr = (cell(typeIdx, r) ?? 'expense').trim().toLowerCase();
      if (!const [
        '支出',
        '支',
        '出账',
        '消费',
        '花费',
        '出帳',
        '消費',
        '花費',
        'expense',
        'spending',
        'expenditure',
      ].contains(typeStr)) {
        skippedType++;
        continue;
      }
      final amountStr = cell(amountIdx, r);
      if (amountStr == null || _parseImportAmount(amountStr) == null) {
        invalidAmount++;
      }
      final dateStr = cell(dateIdx, r);
      if (dateStr == null || DateParser.tryParse(dateStr) == null) {
        invalidDate++;
      }
      final currencyStr = cell(curIdx, r);
      if (currencyStr != null &&
          !kCurrencyCodes.contains(currencyStr.trim().toUpperCase())) {
        invalidCurrency++;
      }
      if (cell(catIdx, r) == null) missingCategory++;
    }
    return _ImportPrecheck(
      totalRows: total,
      invalidAmount: invalidAmount,
      invalidDate: invalidDate,
      invalidCurrency: invalidCurrency,
      missingCategory: missingCategory,
      skippedType: skippedType,
    );
  }

  /// 分类数据就绪后为源分类预设同名匹配。
  ///
  /// 设计意图:自动匹配属于数据到达后的初始化,若在 FutureBuilder 的 build
  /// 内直接改 categoryMapping 是 build 期副作用;这里由 [_buildDistinctCategories]
  /// 触发,await 分类列表后一次性计算并 setState。
  Future<void> _autoMatchCategories() async {
    final future = allCategoriesFuture;
    if (future == null) return;
    final cats = await future;
    if (!mounted || cats.isEmpty) return;

    var hasMatch = false;
    final parentNames = {
      for (final c in cats.where((c) => c.level == 1)) c.id: c.name,
    };
    for (final sourcePath in distinctCategories) {
      final matches = cats.where((c) {
        if (c.kind != sourcePath.kind || c.name != sourcePath.name) {
          return false;
        }
        if (sourcePath.parentName == null) {
          return c.level == 1 && c.parentId == null;
        }
        return c.level == 2 && parentNames[c.parentId] == sourcePath.parentName;
      }).toList();
      // 只有唯一完整路径命中时才自动选择，歧义场景留给用户确认。
      if (matches.length == 1) {
        categoryMapping[sourcePath] = matches.single.id;
        hasMatch = true;
      }
    }
    if (hasMatch && mounted) {
      setState(() {});
    }
  }
}

/// 严格解析 CSV 金额并返回正数金额，非法格式返回 null。
///
/// 只移除语法位置正确的正负号、人民币/美元符号及三位千分组；这样既兼容
/// 常见账单导出格式，也不会把 `12,34`、`1-2` 等脏数据“修复”为另一笔金额。
Decimal? _parseImportAmount(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;

  final wrapped = value.startsWith('(') || value.endsWith(')');
  if (wrapped) {
    if (!value.startsWith('(') || !value.endsWith(')')) return null;
    value = value.substring(1, value.length - 1);
  } else if (value.startsWith('+') || value.startsWith('-')) {
    value = value.substring(1);
  }

  if (value.startsWith(r'$') ||
      value.startsWith('¥') ||
      value.startsWith('€') ||
      value.startsWith('£')) {
    value = value.substring(1);
  }

  final validFormat = RegExp(
    r'^(?:\d+|[1-9]\d{0,2}(?:,\d{3})+)(?:\.\d{1,10})?$',
  ).hasMatch(value);
  if (!validFormat) return null;

  final parsed = parseDecimal(value.replaceAll(',', ''));
  if (parsed == null || parsed <= Decimal.zero) return null;
  final normalized = normalizeDecimal(parsed);
  if (!isNormalizedDecimal(normalized)) return null;
  return Decimal.parse(normalized);
}

/// 加载固定目标账本可用的完整分类树。
///
/// 共享非 Owner 账本必须完全替换成 Owner 镜像；读取失败返回空列表，
/// 让后续映射校验 fail-closed，不能降级为 Editor 私有分类。
Future<List<schema.CategoryDisplay>> _loadAllCategories(
  WidgetRef ref,
  String ledgerId,
) async {
  try {
    final actions = ref.read(categoryActionsProvider);
    return await actions.filterForPicker(
      ledgerId: ledgerId,
      kind: 'expense',
      topLevelOnly: false,
    );
  } catch (e, st) {
    logger.error('ImportConfirmPage', '加载导入分类失败 ledger=$ledgerId', e, st);
    return const [];
  }
}

/// 将分类列表按「先一级、再其下二级、再下个一级」的顺序重排。
///
/// 设计意图：默认加载顺序是「全部一级在前、全部二级在后」，在「分类映射」下拉中
/// 父子关系被割裂、不直观。这里按 parentId 分组后，每个一级分类紧跟其二级子分类，
/// 更符合用户按层级选择分类的直觉。排序字段统一用 sortOrder 保持与系统内顺序一致。
List<schema.CategoryDisplay> _groupCategoriesByLevel(
  List<schema.CategoryDisplay> all,
) {
  // 一级分类：parentId 为空；按 sortOrder 升序
  final top = all.where((c) => c.parentId == null).toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  final result = <schema.CategoryDisplay>[];
  for (final t in top) {
    result.add(t);
    // 该一级分类下的二级子分类，同样按 sortOrder 升序
    final subs = all.where((c) => c.parentId == t.id).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    result.addAll(subs);
  }
  return result;
}

/// 导入预检查摘要：分类映射步展示的问题行统计。
class _ImportPrecheck {
  final int totalRows;
  final int invalidAmount;
  final int invalidDate;
  final int invalidCurrency;
  final int missingCategory;
  final int skippedType;

  const _ImportPrecheck({
    required this.totalRows,
    required this.invalidAmount,
    required this.invalidDate,
    required this.invalidCurrency,
    required this.missingCategory,
    required this.skippedType,
  });
}

class _PreviewTable extends StatelessWidget {
  final List<List<String>> rows;
  // 预览表格: 固定单元格宽度，避免在横向滚动环境中使用 Expanded 触发布局错误
  const _PreviewTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    const double cellWidth = 140;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radius8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTokens.border(context)),
          borderRadius: BorderRadius.circular(AppDimens.radius8),
        ),
        child: Column(
          children: [
            for (int r = 0; r < rows.length; r++)
              Container(
                color: r == 0
                    ? AppTokens.surfaceSecondary(context)
                    : AppTokens.surfaceElevated(context),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.p4,
                  horizontal: AppDimens.p8,
                ),
                child: Row(
                  children: [
                    for (final cell in rows[r])
                      SizedBox(
                        width: cellWidth,
                        child: Text(
                          cell,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTokens.textPrimary(context),
                            fontWeight: r == 0 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
