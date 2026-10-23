import 'package:sesame_notes/shared/widgets/calendar_entry_scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/models/memo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/detail_list_item.dart';
import '../../../../shared/widgets/section_card.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimens.dart';
import '../../../../theme/icons/app_icons.dart';
import '../../../../theme/typography.dart';

/// 普通备忘展示两行摘要卡片，日历及账号记录使用紧凑明细行。
class MemoEntryTile extends StatelessWidget {
  const MemoEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  final MemoEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// 卡片显示名称与前两个字段，普通笔记按标题和日期摘要两行排列。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = entry.previewText?.trim().split('\n');
    final firstLine = lines?.first.trim() ?? '';
    // 卡片的预览行是字段内容，标题只能取名称本身。
    final title = entry.isCard
        ? (entry.title.isNotEmpty ? entry.title : l.memoUntitled)
        : firstLine.isNotEmpty
        ? firstLine
        : entry.title.isNotEmpty
        ? entry.title
        : l.memoUntitled;
    final edited = entry.updatedAt.toLocal();
    if (!entry.isCard && !CalendarEntryScope.active(context)) {
      final preview = lines == null || lines.length < 2
          ? ''
          : lines
                .skip(1)
                .map((line) => line.trim())
                .where((line) => line.isNotEmpty)
                .join(' ');
      return SectionCard(
        margin: const EdgeInsets.only(bottom: AppDimens.p8),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTokens.strongTitle(context),
            ),
            const SizedBox(height: AppDimens.p4),
            // 日期与正文摘要共用次行，空白段落不占预览空间。
            Row(
              children: [
                Text(
                  DateFormat.yMd(l.localeName).format(edited),
                  style: AppTextTokens.dateSecondary(context),
                  maxLines: 1,
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(width: AppDimens.p8),
                  Expanded(
                    child: Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.textSecondary(context)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
    return DetailListItem(
      compact: true,
      titleStyle: AppTextTokens.title(context),
      minHeight: AppDimens.memoRowMinHeight,
      leading: entry.isCard
          ? const DetailListIcon(child: Icon(AppIcons.lock))
          : DetailListIcon(
              backgroundColor: AppTokens.purpleBackground(context),
              foregroundColor: AppTokens.purpleForeground(context),
              child: const Icon(AppIcons.description),
            ),
      title: title,
      subtitle: DetailListSubtitle(
        child: entry.isCard
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final text in (lines ?? const <String>[]).take(2))
                    Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )
            : Text(
                lines != null && lines.length > 1 ? lines[1].trim() : '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              (CalendarEntryScope.active(context)
                      ? DateFormat.Hm(l.localeName)
                      : DateFormat.yMd(l.localeName).add_Hm())
                  .format(edited),
              style: AppTextTokens.dateSecondary(context),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
