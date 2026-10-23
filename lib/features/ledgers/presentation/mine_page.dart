import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sesame_notes/features/settings/presentation/app_update_dialog.dart';

import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

import 'package:sesame_notes/features/ledgers/presentation/cloud_service_entry_tile.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/mine_page_header.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 展示记账设置与通用设置等低频功能入口。
///
/// 分组顺序：通用设置、记账设置、健身设置；以卡片分隔。
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context), // ⭐ 使用 Token
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 个人资料区并入滚动列表，与下方分组整体滚动，不常驻置顶。
          PrimaryHeader(
            showBack: false,
            title: l10n.mineTitle,
            showTitleSection: false,
            content: const MinePageHeader(),
          ),
          // 分组之间留 12px 呼吸距；组内行间距由 cardDivider 呼吸距
          // 与 AppListTile 行内边距统一为约 16px，首末行与中间行视觉一致。
          SizedBox(height: AppDimens.p12),
          // 通用设置分组：语言、通知、主题、应用锁、数据迁移与云同步等通用能力。
          SectionCard(
            margin: EdgeInsets.fromLTRB(AppDimens.p12, 0, AppDimens.p12, 0),
            child: Column(
              children: [
                AppListTile(
                  leading: AppIcons.language,
                  title: l10n.mineLanguageSettings,
                  onTap: () => context.pushNamed(Routes.languageSettings),
                ),
                AppTokens.cardDivider(context),
                // 通知设置
                AppListTile(
                  leading: AppIcons.notifications,
                  title: l10n.mineReminderSettings,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.reminderSettings),
                ),
                AppTokens.cardDivider(context),
                // 视觉主题与显示模式统一从外观设置进入。
                AppListTile(
                  leading: AppIcons.darkMode,
                  title: l10n.appearanceThemeTitle,
                  onTap: () => context.pushNamed(Routes.themeSettings),
                ),
                AppTokens.cardDivider(context),
                // 应用上锁 —— 直接进入应用锁设置页配置。
                AppListTile(
                  leading: AppIcons.lock,
                  title: l10n.appLockTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.appLockSettings),
                ),
                AppTokens.cardDivider(context),
                // 数据导入导出统一进入数据迁移页面。
                AppListTile(
                  leading: AppIcons.driveFileMove,
                  title: l10n.detailImportExportTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.detailImportExport),
                ),
                AppTokens.cardDivider(context),
                // 备份与云同步 —— 统一入口：图标按备份状态切换，
                // 点击统一进入 CloudServicePage（不按后端类型路由分叉）。
                CloudServiceEntryTile(
                  onTap: () => context.pushNamed(Routes.cloudService),
                ),
                if (!kIsWeb &&
                    defaultTargetPlatform == TargetPlatform.android) ...[
                  AppTokens.cardDivider(context),
                  AppListTile(
                    leading: AppIcons.download,
                    title: l10n.appUpdateTitle,
                    onTap: () => showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const AppUpdateDialog(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppDimens.p12),
          // 记账设置分组：与记账行为直接相关的低频设置，避免挤占高频入口。
          SectionCard(
            margin: EdgeInsets.fromLTRB(AppDimens.p12, 0, AppDimens.p12, 0),
            child: Column(
              children: [
                // 分类管理
                AppListTile(
                  leadingWidget: const DetailListIcon(
                    child: Icon(AppIcons.category),
                  ),
                  title: l10n.mineCategoryManagement,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  // 按路由名跳转分类管理页，由 go_router 统一解析
                  onTap: () => context.pushNamed(Routes.categoryManage),
                ),
                AppTokens.cardDivider(context),
                // 汇率管理
                AppListTile(
                  leading: AppIcons.currencyExchange,
                  title: l10n.exchangeRatePageTitle,
                  trailing: Icon(
                    AppIcons.chevronRight,
                    color: AppTokens.iconTertiary(context),
                    size: AppDimens.icon20,
                  ),
                  onTap: () => context.pushNamed(Routes.exchangeRate),
                ),
              ],
            ),
          ),
          SizedBox(height: AppDimens.p12),
          const FitnessSettingsSection(),
          SizedBox(height: AppDimens.p16),
        ],
      ),
    );
  }
}
