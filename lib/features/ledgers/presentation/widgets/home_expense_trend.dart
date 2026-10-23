import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/features/statistics/application/statistics_queries.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/date/month_range.dart';

/// 首页趋势使用统计查询的账期、折算和有效记录范围，不从可见交易重新计算。
final homeExpenseTrendProvider = FutureProvider.autoDispose
    .family<
      List<({DateTime day, double total})>,
      ({String ledgerId, DateTime month})
    >((ref, params) async {
      ref.watch(accountingDataChangeSignalProvider);
      final startDay = ref.watch(currentMonthStartDayProvider);
      final range = periodForLabel(
        params.month.year,
        params.month.month,
        startDay,
      );
      final now = ref.watch(localTodayProvider);
      final end = !now.isBefore(range.start) && now.isBefore(range.end)
          ? DateTime(now.year, now.month, now.day + 1)
          : range.end;
      try {
        return await ref
            .read(statisticsQueriesProvider)
            .totalsByDay(
              ledgerId: params.ledgerId,
              type: 'expense',
              start: range.start,
              end: end,
            );
      } catch (error, stackTrace) {
        logger.error(
          'HomeExpenseTrend',
          '读取每日支出失败，账期=${params.month} 起始日=$startDay',
          error,
          stackTrace,
        );
        rethrow;
      }
    }, retry: (_, _) => null);

/// 首页每日支出概览，查看统计入口由业务导航提供。
class HomeExpenseTrend extends ConsumerWidget {
  /// 金额查询与当前账本绑定，切换账本后不会保留另一账本的曲线。
  const HomeExpenseTrend({
    super.key,
    required this.month,
    this.onViewAnalytics,
  });

  final DateTime month;
  final VoidCallback? onViewAnalytics;

  /// 轻量曲线不注册横滑手势，业务内切页手势由外层导航统一处理。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = (ledgerId: ref.watch(currentLedgerIdProvider), month: month);
    final data = ref.watch(homeExpenseTrendProvider(query));
    final l10n = AppLocalizations.of(context);
    final primary = AppTokens.primary(context);
    return SectionCard(
      margin: EdgeInsets.zero,
      color: AppTokens.domainAccentBackground(context),
      onTap: onViewAnalytics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.homeDailyExpenseTrend,
                  style: AppTextTokens.label(context).copyWith(color: primary),
                ),
              ),
              if (onViewAnalytics != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: AppDimens.p32),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.homeViewAnalytics,
                        style: AppTextTokens.caption(
                          context,
                        ).copyWith(color: primary),
                      ),
                      const SizedBox(width: AppDimens.p4),
                      Icon(
                        AppIcons.chevronRight,
                        size: AppDimens.icon12,
                        color: primary,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.p4),
          data.when(
            // 同一账期的数据重查保留曲线和日期轴，结果到达后再更新绘图。
            // 账本和月份属于 provider 的查询身份，切换时仍展示各自的加载状态。
            skipLoadingOnReload: true,
            data: (points) => _chart(context, points, primary),
            loading: () => const SizedBox(
              height: AppDimens.p40 + AppDimens.p8,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: AppDimens.progressStrokeWidth,
                ),
              ),
            ),
            error: (_, _) => AppLoadError(
              padding: EdgeInsets.zero,
              onRetry: () => ref.invalidate(homeExpenseTrendProvider(query)),
            ),
          ),
        ],
      ),
    );
  }

  /// 日期来自查询返回的连续序列，账期跨月时仍显示实际日期。
  Widget _chart(
    BuildContext context,
    List<({DateTime day, double total})> points,
    Color primary,
  ) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return SizedBox(
        height: AppDimens.p40 + AppDimens.p8,
        child: Center(
          child: Text(
            l10n.homeNoRecords,
            style: AppTextTokens.caption(context),
          ),
        ),
      );
    }
    final format = DateFormat.Md(
      Localizations.localeOf(context).toLanguageTag(),
    );
    return Column(
      children: [
        Semantics(
          label: l10n.homeDailyExpenseTrend,
          child: SizedBox(
            height: AppDimens.p40 + AppDimens.p8,
            width: double.infinity,
            child: CustomPaint(
              painter: _ExpenseSparkline(
                points.map((point) => point.total).toList(),
                primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.p4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              format.format(points.first.day),
              style: AppTextTokens.caption(context),
            ),
            if (points.length > 2)
              Text(
                format.format(points[points.length ~/ 2].day),
                style: AppTextTokens.caption(context),
              ),
            if (points.length > 1)
              Text(
                format.format(points.last.day),
                style: AppTextTokens.caption(context),
              ),
          ],
        ),
      ],
    );
  }
}

/// 真实每日金额的折线与淡色面积，零值保留在基线上。
class _ExpenseSparkline extends CustomPainter {
  /// 数值按查询日期排列，绘制不改变金额精度或统计范围。
  const _ExpenseSparkline(this.values, this.color);

  final List<double> values;
  final Color color;

  /// 负值和正值共用真实纵向区间，避免退款记录落到画布之外。
  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    final low = math.min(0.0, values.reduce(math.min));
    final high = math.max(0.0, values.reduce(math.max));
    final spread = high == low ? 1.0 : high - low;
    final inset = AppChartTokens.dotRadius;
    final height = size.height - inset * 2;
    final width = size.width - inset * 2;
    final path = Path();
    Offset point(int index) => Offset(
      inset +
          (values.length == 1
              ? width / 2
              : width * index / (values.length - 1)),
      inset + height * (1 - (values[index] - low) / spread),
    );
    final first = point(0);
    path.moveTo(first.dx, first.dy);
    for (var index = 1; index < values.length; index++) {
      final next = point(index);
      path.lineTo(next.dx, next.dy);
    }
    final last = point(values.length - 1);
    final fill = Path.from(path)
      ..lineTo(last.dx, size.height)
      ..lineTo(first.dx, size.height)
      ..close();
    canvas.drawPath(fill, Paint()..color = color.withValues(alpha: 0.08));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppChartTokens.lineWidth,
    );
    canvas.drawCircle(last, AppChartTokens.dotRadius, Paint()..color = color);
  }

  /// 查询数值或主题变化时重绘。
  @override
  bool shouldRepaint(covariant _ExpenseSparkline oldDelegate) =>
      color != oldDelegate.color || !listEquals(values, oldDelegate.values);
}
