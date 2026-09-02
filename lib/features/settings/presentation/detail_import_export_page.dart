import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/router/route_consts.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_selector_dialog.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 明细导入导出页
///
/// 结构对齐配置导入导出页：
/// - 头部「功能说明」卡片：整合导入差异说明、导出格式说明与模板列预览。
/// - 功能按钮卡片：单个「导入明细」按钮 + 单个「导出明细」按钮。
///
/// 导入路径：点击「导入明细」先选择目标账本，再选择文件，流式读取后
/// 进入映射页（`ImportConfirmPage`）。
/// 导出路径：点击「导出明细」跳转 `DetailExportPage` 二级页面。
class DetailImportExportPage extends ConsumerStatefulWidget {
  const DetailImportExportPage({super.key});

  @override
  ConsumerState<DetailImportExportPage> createState() =>
      _DetailImportExportPageState();
}

class _DetailImportExportPageState
    extends ConsumerState<DetailImportExportPage> {
  // 文件读取进度状态
  bool _reading = false;
  double? _readProgress; // 0~1，null 表示准备中
  bool _cancelRead = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.detailImportExportTitle, showBack: true),
          Expanded(
            // Stack 用于叠加文件读取进度遮罩
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                    vertical: AppDimens.p8,
                  ),
                  children: [
                    // —— 头部：功能说明模块（整合原「功能说明」+「模板预览」两个卡片）——
                    SectionCard(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(AppDimens.p12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.info,
                                  size: AppDimens.icon20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: AppDimens.p8),
                                Text(
                                  l10n.configImportExportInfoTitle,
                                  style: AppTextTokens.strongTitle(context)
                                      .copyWith(
                                        color: AppTokens.textPrimary(context),
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppDimens.p8),
                            // 导入说明：结构化分条展示（原长段落不利于扫读）
                            _infoSection(
                              context,
                              icon: AppIcons.fileUpload,
                              title: l10n.detailImportExportImportTitle,
                              points: [
                                l10n.detailImportExportImportPoint1,
                                l10n.detailImportExportImportPoint2,
                                l10n.detailImportExportImportPoint3,
                              ],
                            ),
                            SizedBox(height: AppDimens.p8),
                            // 导出说明：结构化分条展示
                            _infoSection(
                              context,
                              icon: AppIcons.fileDownload,
                              title: l10n.detailImportExportExportTitle,
                              points: [
                                l10n.detailImportExportExportPoint1,
                                l10n.detailImportExportExportPoint2,
                                l10n.detailImportExportExportPoint3,
                              ],
                              // 表头模板预览：展示 CSV 实际列名与顺序，
                              // 与「包含字段如下：」引导语配套，采用模板样式（13px 三级文字）
                              footer: Padding(
                                padding: const EdgeInsets.only(
                                  top: AppDimens.p4,
                                  left: AppDimens.p12,
                                ),
                                child: Text(
                                  '${l10n.exportCsvHeaderType} / ${l10n.exportCsvHeaderCategory} / ${l10n.exportCsvHeaderSubCategory} / ${l10n.exportCsvHeaderAmount} / ${l10n.exportCsvHeaderCurrency} / ${l10n.exportCsvHeaderNote} / ${l10n.exportCsvHeaderTime}',
                                  style: AppTextTokens.label(context).copyWith(
                                    color: AppTokens.textTertiary(context),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: AppDimens.p8),
                            // 账本迁移提示：说明可经「导出当前账本 → 导入目标账本」完成账本间平滑迁移
                            _infoSection(
                              context,
                              icon: AppIcons.lightbulb,
                              title: l10n.detailImportExportMigrateTitle,
                              points: [l10n.detailImportExportMigrateTip],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimens.p8),
                    // —— 功能按钮卡片：导入明细 + 导出明细 ——
                    SectionCard(
                      margin: EdgeInsets.zero,
                      child: Column(
                        children: [
                          // 导入明细（三按钮合一，点击直接拉起文件选择器）
                          AppListTile(
                            leading: AppIcons.fileUpload,
                            title: l10n.detailImportExportImportTitle,
                            subtitle: l10n.detailImportExportImportSubtitle,
                            trailing: _reading
                                ? SizedBox(
                                    width: 20.0,
                                    height: 20.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    AppIcons.chevronRight,
                                    color: AppTokens.iconTertiary(context),
                                    size: AppDimens.icon20,
                                  ),
                            onTap: _reading ? null : _pickAndImport,
                          ),
                          AppTokens.cardDivider(context),
                          // 导出明细：跳转二级页面选择账本与导出范围
                          AppListTile(
                            leading: AppIcons.fileDownload,
                            title: l10n.detailImportExportExportTitle,
                            subtitle: l10n.detailImportExportExportSubtitle,
                            trailing: Icon(
                              AppIcons.chevronRight,
                              color: AppTokens.iconTertiary(context),
                              size: AppDimens.icon20,
                            ),
                            onTap: () => context.pushNamed(Routes.detailExport),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 文件读取进度遮罩
                if (_reading)
                  Positioned.fill(
                    child: Container(
                      color: AppTokens.overlay(context),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.p16),
                          decoration: BoxDecoration(
                            color: AppTokens.surfaceElevated(context),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radius12,
                            ),
                          ),
                          width: 320,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context).importReading),
                              const SizedBox(height: AppDimens.p12),
                              LinearProgressIndicator(value: _readProgress),
                              const SizedBox(height: AppDimens.p8),
                              Text(
                                _readProgress == null
                                    ? AppLocalizations.of(
                                        context,
                                      ).importPreparing
                                    : '${((_readProgress ?? 0) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              ),
                              const SizedBox(height: AppDimens.p12),
                              TextButton(
                                onPressed: () {
                                  setState(() => _cancelRead = true);
                                },
                                child: Text(
                                  AppLocalizations.of(context).commonCancel,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 功能说明分节：小标题（图标 + 加粗文字）+ 圆点条目列表。
  ///
  /// 设计意图：说明内容分节 + 分条展示，每条只讲一个要点，便于扫读。
  Widget _infoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> points,

    /// 分节尾部附加内容（可选），如导出分节的 CSV 表头模板预览
    Widget? footer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分节小标题：复用功能按钮的标题文案（导入明细 / 导出明细）
        Row(
          children: [
            Icon(
              icon,
              size: AppDimens.icon16,
              color: AppTokens.textSecondary(context),
            ),
            SizedBox(width: AppDimens.p4),
            Text(
              title,
              style: AppTextTokens.body(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTokens.textPrimary(context),
              ),
            ),
          ],
        ),
        SizedBox(height: AppDimens.p4),
        // 圆点条目：圆点与正文首行基线对齐，折行时悬挂缩进保持对齐
        for (final point in points)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.p4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: AppTextTokens.body(context).copyWith(
                    color: AppTokens.textSecondary(context),
                    height: 1.5,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: AppTextTokens.body(context).copyWith(
                      color: AppTokens.textSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 尾部附加内容（如模板预览）
        ?footer,
      ],
    );
  }

  /// 先选择目标账本，再拉起系统文件选择器并跳转到映射页。
  ///
  /// 流程：选账本 → 权限预检 → 选文件 → 流式读取（含进度/取消）→
  /// 进入 `ImportConfirmPage`，
  /// 不经过中转页，也不区分账单类型
  /// （统一由 `GenericBillParser` 处理表头定位与列映射）。
  Future<void> _pickAndImport() async {
    try {
      final targetLedgerId = await showLedgerSelector(
        context,
        currentLedgerId: ref.read(currentLedgerIdProvider),
      );
      if (!mounted || targetLedgerId == null) return;

      // 文件读取前先拦截只读共享账本，避免用户完成映射后才发现无写权限；
      // 确认页在真正写入前仍会复查一次，覆盖期间删本或降权的竞态。
      final targetLedger = await ref
          .read(ledgerActionsProvider)
          .getById(targetLedgerId);
      if (!mounted) return;
      if (targetLedger == null) {
        showToast(context, AppLocalizations.of(context).importNoLedger);
        return;
      }

      // 促使插件完成注册，规避热重载后偶现的 MissingPluginException。
      await FilePicker.clearTemporaryFiles();
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'tsv', 'txt', 'xlsx'],
        allowMultiple: false,
        // 优先走文件路径流式读取,避免把整个文件 bytes 拉进内存;
        // FileReaderService 在 path 缺失时才回退 bytes。
        withData: false,
      );
      if (!context.mounted) return;
      if (res == null || res.files.isEmpty) return;

      final picked = res.files.first;
      final csvText = await _readFileStreaming(picked);
      if (!mounted) return;
      if (csvText.isEmpty) return; // 可能读取被取消

      // 目标账本随 CSV 一并传入，确认页不再依赖可变化的全局当前账本。
      await context.pushNamed(
        Routes.importConfirm,
        extra: (csvText, true, targetLedgerId),
      );
    } on Exception catch (e, st) {
      logger.error('DetailImport', '选择/读取导入文件失败', e, st);
      if (!mounted) return;
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }

  /// 流式读取文件并显示进度。
  Future<String> _readFileStreaming(PlatformFile picked) async {
    if (!mounted) return '';

    setState(() {
      _reading = true;
      _readProgress = 0;
      _cancelRead = false;
    });

    try {
      final text = await ref
          .read(importActionsProvider)
          .readFile(
            picked,
            isCancelled: () => _cancelRead,
            onProgress: (progress) {
              if (_cancelRead) return;
              if (mounted) {
                setState(() {
                  _readProgress = progress;
                });
              }
            },
          );

      if (_cancelRead) {
        // 读取被取消:丢弃已读内容,不进入映射页。
        throw const ImportFileReadCancelled();
      }

      if (mounted) {
        setState(() {
          _reading = false;
          _readProgress = null;
        });
      }

      return text;
    } on ImportFileReadCancelled {
      if (mounted) {
        setState(() {
          _reading = false;
          _readProgress = null;
          _cancelRead = false;
        });
        showToast(context, AppLocalizations.of(context).importCancelled);
      }
      return '';
    } on ImportFileFormulaException catch (e) {
      logger.error('DetailImport', 'XLSX 含公式单元格: ${e.formula}');
      if (mounted) {
        setState(() {
          _reading = false;
          _readProgress = null;
        });
        showToast(context, AppLocalizations.of(context).importXlsxFormulaError);
      }
      return '';
    } catch (e) {
      logger.error('DetailImport', '读取文件失败', e);
      if (mounted) {
        setState(() {
          _reading = false;
          _readProgress = null;
        });
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
      return '';
    }
  }
}
