import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import '../infrastructure/transfer_table.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

import 'package:sesame_notes/features/settings/presentation/widgets/data_import_target_dialog.dart';

import 'package:sesame_notes/features/settings/application/import_actions.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 数据导入导出页
///
/// 统一数据导入导出入口：
/// - 头部「功能说明」卡片：整合导入差异说明、导出格式说明与模板列预览。
/// - 功能按钮卡片：「导出明细」按钮在上，「导入明细」按钮在下。
///
/// 导入路径：点击「导入明细」先选择业务类型与目标本，再选择文件，流式读取后
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

  /// 页面退出后取消读取意图，工作 isolate 返回的结果会被丢弃。
  @override
  void dispose() {
    _cancelRead = true;
    super.dispose();
  }

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(title: l10n.dataTransferInfoTitle),
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
                          ),
                          SizedBox(height: AppDimens.p8),
                          // 导入说明：结构化分条展示。
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
                    SizedBox(height: AppDimens.p8),
                    // —— 功能按钮卡片：导出明细 + 导入明细 ——
                    // 左右内边距与其它设置卡片一致，避免行内图标贴住卡片边缘。
                    SectionCard(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(horizontal: AppDimens.p12),
                      child: Column(
                        children: [
                          // 导出明细：跳转二级页面选择账本与导出范围。
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
                          AppTokens.cardDivider(context),
                          // 导入明细：先选择目标账本，再选择文件。
                          AppListTile(
                            leading: AppIcons.fileUpload,
                            title: l10n.detailImportExportImportTitle,
                            subtitle: l10n.detailImportExportImportSubtitle,
                            trailing: _reading
                                ? SizedBox(
                                    width: AppDimens.icon20,
                                    height: AppDimens.icon20,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          AppDimens.progressStrokeWidth,
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
                      child: AppContentDialog(
                        title: l10n.importReading,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LinearProgressIndicator(value: _readProgress),
                            const SizedBox(height: AppDimens.p12),
                            Text(
                              _readProgress == null
                                  ? l10n.importPreparing
                                  : '${((_readProgress ?? 0) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              style: AppTextTokens.body(context),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => setState(() => _cancelRead = true),
                            child: Text(l10n.commonCancel),
                          ),
                        ],
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
      ],
    );
  }

  /// 固定业务目标后读取文件，再按目标类型进入统一映射页。
  ///
  /// 文件读取支持进度和取消；映射页复用对应业务的字段识别与校验。
  Future<void> _pickAndImport() async {
    try {
      final target = await showDataImportTargetDialog(context);
      if (!mounted || target == null) return;

      // 促使插件完成注册，规避热重载后偶现的 MissingPluginException。
      await FilePicker.clearTemporaryFiles();
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv', 'tsv', 'txt', 'xlsx', 'json'],
      );
      if (!mounted || picked == null) return;
      final text = await _readFileStreaming(picked);
      if (!mounted || text.isEmpty) return;
      var kind = TransferKind.ledger;
      if (target.memoTarget != null) {
        final book = await ref
            .read(memoActionsProvider)
            .requireTarget(target.memoTarget!);
        kind = book.type == 'credentials'
            ? TransferKind.credentials
            : TransferKind.memo;
      } else if (target.dayTarget != null) {
        kind = TransferKind.days;
      } else if (target.fitnessTarget != null) {
        kind = TransferKind.fitness;
      }
      if (!mounted) return;
      await context.pushNamed(
        Routes.importConfirm,
        extra: (text, kind, target),
      );
    } catch (e, st) {
      logger.error('DetailImport', '选择/读取导入文件失败', safeErrorSummary(e), st);
      if (!mounted) return;
      showToast(
        context,
        e is FormatException && e.source == null
            ? e.message
            : AppLocalizations.of(context).commonOperationFailed,
      );
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
    } on ImportFileFormulaException {
      logger.error('DetailImport', 'XLSX 含无法求值的公式单元格');
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
        // 解析层给出的原因能直接指导用户修正文件，只有未知错误才回落通用文案。
        showToast(
          context,
          e is FormatException && e.source == null
              ? e.message
              : AppLocalizations.of(context).commonOperationFailed,
        );
      }
      return '';
    }
  }
}
