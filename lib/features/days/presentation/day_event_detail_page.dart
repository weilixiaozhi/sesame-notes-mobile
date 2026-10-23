import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_detail.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 日子详情使用统一底部弹层，按固定本和记录 ID 响应本地数据流。
class DayEventDetailPage extends ConsumerWidget {
  const DayEventDetailPage({
    super.key,
    required this.dayBookId,
    required this.eventId,
  });
  final String dayBookId;
  final String eventId;

  /// 删除失败保留详情与重试入口，仅成功删除后关闭当前弹层。
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DayEvent event,
  ) async {
    if (await deleteDayEvent(context, ref, event) && context.mounted) {
      context.pop();
    }
  }

  /// 正常详情与异常记录保留相同的标题、删除和常驻编辑入口。
  Widget _details(
    BuildContext context,
    WidgetRef ref,
    DayBook book,
    DayEvent event,
  ) {
    final l10n = AppLocalizations.of(context);
    final definition = event.definition;
    List<Widget> information;
    try {
      final today = ref.watch(dayTodayProvider);
      final invalid = dayDisplayEntries(
        [event],
        (definition) => const DayDateRules().nextOccurrence(definition, today),
      ).invalid.isNotEmpty;
      final next =
          definition.category == DayCategory.countdown ||
              definition.repeatType == DayRepeatType.none
          ? null
          : const DayDateRules().nextOccurrence(definition, today);
      final end =
          definition.end ??
          (definition.intervalDays == null
              ? null
              : OriginalDate.solar(
                  definition.start!.solarDate!.addDays(
                    definition.intervalDays! - 1,
                  ),
                ));
      information = invalid
          ? _invalidContent(context, ref)
          : [
              AppDetailInfoRow(
                label: dayPrimaryDateLabel(
                  l10n,
                  definition.category,
                  definition.countdownMode,
                ),
                value: dayDateLabel(
                  l10n,
                  definition.event ?? definition.start!,
                ),
                maxLines: null,
              ),
              if (end != null)
                AppDetailInfoRow(
                  label: l10n.dayEnd,
                  value: dayDateLabel(l10n, end),
                  maxLines: null,
                ),
              if (definition.category == DayCategory.stage && end == null)
                AppDetailInfoRow(label: l10n.dayEnd, value: l10n.dayPresent),
              AppDetailInfoRow(
                label: l10n.dayRepeatQuestion,
                value:
                    definition.category != DayCategory.countdown &&
                        definition.repeatType == DayRepeatType.yearly
                    ? l10n.dayYearly
                    : l10n.dayNoRepeat,
              ),
              AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
              AppDetailInfoRow(label: l10n.dayStatistic, value: ''),
              if (dayMilestoneLabel(l10n, definition, today)
                  case final String milestone)
                AppDetailInfoRow(
                  label: definition.category == DayCategory.birthday
                      ? l10n.dayAge
                      : l10n.dayMilestone,
                  value: milestone,
                ),
              for (final statistic in [
                DayStatisticType.year,
                DayStatisticType.day,
              ])
                AppDetailInfoRow(
                  label: statistic == DayStatisticType.year
                      ? l10n.dayYears
                      : l10n.dayDays,
                  value: dayStatisticLabel(
                    l10n,
                    definition,
                    today,
                    statisticType: statistic,
                  ),
                  maxLines: null,
                ),
              if (definition.category != DayCategory.countdown &&
                  definition.repeatType != DayRepeatType.none) ...[
                AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
                AppDetailInfoRow(label: l10n.dayNextDate, value: ''),
                AppDetailInfoRow(
                  label: l10n.dayDate,
                  value: next?.iso8601 ?? l10n.dayNoNext,
                ),
                for (final statistic in [
                  DayStatisticType.year,
                  DayStatisticType.day,
                ])
                  AppDetailInfoRow(
                    label: statistic == DayStatisticType.year
                        ? l10n.dayYears
                        : l10n.dayDays,
                    value: dayDurationLabel(
                      l10n,
                      definition,
                      today,
                      next,
                      statisticType: statistic,
                    ),
                    maxLines: null,
                  ),
              ],
            ];
    } catch (error, stackTrace) {
      logger.error(
        'DayDetail',
        '计算日子详情失败',
        error is DayDateException ? error.code : error.runtimeType.toString(),
        stackTrace,
      );
      information = _invalidContent(context, ref);
    }
    return AppDetailSheet(
      footer: AppPrimaryButton(
        label: l10n.dayEdit,
        // 与记账详情一致：从详情进入编辑后不再回到详情，编辑结束直接回到列表。
        onPressed: () async {
          await openDayEditor(context, ref, event: event, book: book);
          if (context.mounted) context.pop();
        },
      ),
      header: AppDetailHeader(
        icon: Icon(
          dayCategoryIcon(definition.category),
          size: AppDimens.icon20,
          color: AppTokens.primary(context),
        ),
        title: definition.name,
        subtitle: dayCategoryLabel(l10n, definition.category),
        onDelete: () => _delete(context, ref, event),
      ),
      children: information,
    );
  }

  /// 异常日期仍可重新加载，编辑和删除由外层统一保留。
  List<Widget> _invalidContent(BuildContext context, WidgetRef ref) => [
    AppLoadError(
      message: AppLocalizations.of(context).dayRecordInvalid,
      onRetry: () => ref.invalidate(dayEventsProvider(dayBookId)),
    ),
  ];

  /// 单条详情加载使用共用明细骨架，避免把未返回的数据当成空记录。
  Widget _loading() =>
      const AppSheet(child: PulseSkeleton(child: SkeletonListTile()));

  /// 账号切换或父本删除后不继续展示缓存详情，加载失败可独立重试。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(dayBooksForDisplayProvider)
        .when(
          loading: _loading,
          error: (_, _) => AppSheet(
            child: AppLoadError(
              onRetry: () => ref.invalidate(dayBooksProvider),
            ),
          ),
          data: (books) {
            final book = books
                .where((book) => book.id == dayBookId)
                .firstOrNull;
            if (book == null) {
              return AppSheet(child: AppEmpty(text: l10n.dayTargetUnavailable));
            }
            return ref
                .watch(dayEventsProvider(dayBookId))
                .when(
                  loading: _loading,
                  error: (_, _) => AppSheet(
                    child: AppLoadError(
                      onRetry: () =>
                          ref.invalidate(dayEventsProvider(dayBookId)),
                    ),
                  ),
                  data: (events) {
                    final event = events
                        .where((event) => event.id == eventId)
                        .firstOrNull;
                    return event == null
                        ? AppSheet(
                            child: AppEmpty(text: l10n.dayTargetUnavailable),
                          )
                        : _details(context, ref, book, event);
                  },
                );
          },
        );
  }
}
