/// 云服务页（备份与云同步）共用展示组件。
///
/// 状态头部、分组标题与服务选择卡片按注册表驱动的后端模型展示。
library;

import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/shared/widgets/selectable_card.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 头部「当前类型 / 脱敏端点 / 连接状态」信息块。
///
/// 设计要点：
/// - 「测试连接」入口内联为文字链，紧贴状态徽标左侧，不用头部 icon 按钮（避免重复）。
/// - 测试结果（状态/时间/详情）全部内联展示，不弹窗。
/// - 本地后端没有可连接的远程服务，自测无意义，故不展示测试链与状态徽标。
Widget buildCloudServiceStatusHeader({
  required BuildContext context,
  required String currentName,
  required bool isLocal,
  required bool canTest,
  required String endpointSummary,
  required bool? testResult,
  required DateTime? testTime,
  required String? testMessage,
  required bool testingConnection,
  required VoidCallback onTest,
}) {
  final l10n = AppLocalizations.of(context);
  final Color statusColor;
  final String statusText;

  if (testResult == null) {
    // 未测试
    statusColor = AppTokens.warning(context);
    statusText = l10n.cloudStatusNotTested;
  } else if (testResult) {
    // 测试成功
    statusColor = AppTokens.success(context);
    statusText = l10n.cloudStatusNormal;
  } else {
    // 测试失败
    statusColor = AppTokens.error(context);
    statusText = l10n.cloudStatusFailed;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          // 长类型名在窄空间下省略号截断，防止与状态徽标挤压导致横向溢出。
          Expanded(
            child: Text(
              '${l10n.commonCurrent}: $currentName',
              overflow: TextOverflow.ellipsis,
              style: AppTextTokens.strongTitle(context),
            ),
          ),
          // 本地存储没有「连接」概念，不展示状态徽标与测试链。
          if (!isLocal) ...[
            const SizedBox(width: AppDimens.p12),
            _buildTestConnectionLink(
              context: context,
              canTest: canTest,
              testingConnection: testingConnection,
              onTest: onTest,
            ),
            const SizedBox(width: AppDimens.p8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: AppDimens.p3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radius12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppDimens.cloudStatusDotSize,
                    height: AppDimens.cloudStatusDotSize,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.p4),
                  Text(
                    statusText,
                    style: AppTextTokens.caption(
                      context,
                    ).copyWith(color: statusColor),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: AppDimens.p4),
      Text(
        endpointSummary,
        style: AppTextTokens.label(
          context,
        ).copyWith(color: AppTokens.textSecondary(context)),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      // 上次测试时间：仅当存在历史测试记录（点过测试连接）时展示
      if (testTime != null) ...[
        const SizedBox(height: AppDimens.p4),
        Text(
          l10n.cloudLastTestTime(formatCloudTestTime(testTime)),
          style: AppTextTokens.label(context),
        ),
      ],
      // 测试结果详情文案（成功绿 / 失败红），纯内联展示，不弹窗
      if (testMessage != null) ...[
        const SizedBox(height: AppDimens.p4),
        Text(
          testMessage,
          style: AppTextTokens.label(context).copyWith(
            color: testResult == true
                ? AppTokens.success(context)
                : AppTokens.error(context),
          ),
        ),
      ],
    ],
  );
}

/// 「测试连接」文字链：紧贴状态徽标左侧。
///
/// 仅在配置有效时可点击；测试进行中显示转圈，不弹窗。
Widget _buildTestConnectionLink({
  required BuildContext context,
  required bool canTest,
  required bool testingConnection,
  required VoidCallback onTest,
}) {
  return TextButton(
    onPressed: (canTest && !testingConnection) ? onTest : null,
    style: TextButton.styleFrom(
      textStyle: AppTextTokens.body(
        context,
      ).copyWith(decoration: TextDecoration.underline),
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: testingConnection
        ? const SizedBox(
            width: AppDimens.inlineProgressSize,
            height: AppDimens.inlineProgressSize,
            child: CircularProgressIndicator(
              strokeWidth: AppDimens.progressStrokeWidth,
            ),
          )
        : Text(AppLocalizations.of(context).cloudTestConnection),
  );
}

/// 列表分组主标题，仅作视觉分组，无交互。
/// 委托全局统一 [SectionTitle]（主题色条 + 主题色标题），
/// 本页卡片与列表内边距同为 16，故只保留上下留白、不做水平内缩。
Widget buildCloudServiceSectionHeader(String title, {String? subtitle}) {
  return SectionTitle(
    title: title,
    subtitle: subtitle,
    padding: const EdgeInsets.only(top: AppDimens.p4, bottom: AppDimens.p8),
  );
}

/// 云服务卡片使用统一选中描边和角标，切换选中状态不改变内容尺寸。
/// 配置入口位于副标题右侧，点击配置不会同时选中卡片。
Widget buildCloudServiceCard({
  required BuildContext context,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required bool isSelected,
  bool isConfigured = true,
  required VoidCallback onTap,
  VoidCallback? onConfigure,
}) => SectionCard(
  margin: EdgeInsets.zero,
  padding: EdgeInsets.zero,
  selected: isSelected,
  onTap: onTap,
  child: Stack(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailListIcon(
              size: AppDimens.p36,
              iconSize: AppDimens.icon16,
              backgroundColor: iconColor.withValues(alpha: 0.1),
              foregroundColor: iconColor,
              child: Icon(icon),
            ),
            const SizedBox(width: AppDimens.p8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTokens.strongTitle(context),
                  ),
                  const SizedBox(height: AppDimens.cloudCardSubtitleGap),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextTokens.label(
                            context,
                          ).copyWith(color: AppTokens.textSecondary(context)),
                        ),
                      ),
                      if (isConfigured && onConfigure != null)
                        TextButton.icon(
                          onPressed: onConfigure,
                          icon: const Icon(
                            AppIcons.settings,
                            size: AppDimens.icon16,
                          ),
                          label: Text(
                            AppLocalizations.of(context).commonConfigure,
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.p8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (isSelected) const SelectableCardCheckBadge(),
    ],
  ),
);

/// 将时间格式化为固定的 YYYY-MM-DD HH:MM:SS（手动格式化，避免 locale 改变日期顺序）。
String formatCloudTestTime(DateTime dt) {
  String p(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}-${p(dt.month)}-${p(dt.day)} '
      '${p(dt.hour)}:${p(dt.minute)}:${p(dt.second)}';
}

/// 从后端配置提取脱敏端点摘要（纯函数，测试锚点）。
///
/// 按后端声明的连接字段取值（webdav/supabase 取 url，s3 取 endpoint），
/// 对嵌入 URL 的账号密码段做掩码；取不到时回退 [fallback]。
String cloudEndpointObfuscated(
  String backendId,
  Map<String, dynamic> settings,
  String fallback,
) {
  final raw = switch (backendId) {
    'webdav' || 'supabase' => settings['url'],
    's3' => settings['endpoint'],
    _ => null,
  };
  final text = raw?.toString().trim() ?? '';
  if (text.isEmpty) return fallback;
  return _obfuscateEndpoint(text);
}

/// 掩码 URL 中的 userinfo 段（scheme://user:pass@host → scheme://***@host）。
String _obfuscateEndpoint(String text) {
  final schemeIndex = text.indexOf('://');
  if (schemeIndex < 0) return text;
  final atIndex = text.indexOf('@', schemeIndex + 3);
  if (atIndex < 0) return text;
  return '${text.substring(0, schemeIndex + 3)}***'
      '${text.substring(atIndex)}';
}
