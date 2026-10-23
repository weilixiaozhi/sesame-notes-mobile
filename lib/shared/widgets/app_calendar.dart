import 'package:flutter/material.dart';
import 'section_title.dart';
import 'package:sesame_notes/domain/calendar/lunar_calendar.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/skeleton.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 选日偏离今天或聚焦年月偏离本月时，显示回到今天的导航操作。
bool shouldShowCalendarToday({
  required DateTime? selectedDay,
  required DateTime? focusedDay,
  required DateTime currentDay,
}) =>
    !isSameDay(selectedDay, currentDay) ||
    (focusedDay != null &&
        (focusedDay.year != currentDay.year ||
            focusedDay.month != currentDay.month));

/// 日历主页面共用头部高度、区块标题和右侧操作位。
class AppCalendarHeader extends StatelessWidget {
  /// 标题与操作由业务传入，视觉规格保持统一。
  const AppCalendarHeader({
    super.key,
    required this.title,
    this.trailing,
    this.selectedDay,
    this.focusedDay,
    this.currentDay,
    this.onToday,
    this.onBack,
  });

  final String title;
  final Widget? trailing;
  final DateTime? selectedDay, focusedDay, currentDay;
  final VoidCallback? onToday;

  /// 共享日历通过业务壳返回原页签，独立调用者可省略返回操作。
  final VoidCallback? onBack;

  /// 页面安全区由 PrimaryHeader 承载，区块标题沿用全局规范。
  @override
  Widget build(BuildContext context) {
    final today = currentDay ?? DateTime.now();
    final showToday =
        onToday != null &&
        shouldShowCalendarToday(
          selectedDay: selectedDay,
          focusedDay: focusedDay,
          currentDay: today,
        );
    return PrimaryHeader(
      title: title,
      titleWidget: onBack == null
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeaderIconAction(
                  icon: AppIcons.back,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBack,
                ),
                const SizedBox(width: AppDimens.p8),
                Flexible(child: Text(title)),
              ],
            ),
      actions: [
        if (trailing != null)
          trailing!
        else if (showToday)
          HeaderTextAction(
            label: AppLocalizations.of(context).calendarToday,
            onPressed: onToday,
          ),
      ],
    );
  }
}

/// 各业务共用农历、节日与节气月历，业务仅提供日期内容与下方标记。
class AppCalendar<T> extends StatelessWidget {
  /// 接收业务日期范围和选择回调，保留每个日历自己的状态。
  const AppCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDayPredicate,
    required this.onDaySelected,
    required this.onPageChanged,
    this.currentDay,
    this.eventLoader,
    this.dayMarkerBuilder,
    this.dayContentBuilder,
    this.showLunarDetails = true,
    this.calendarFormat = CalendarFormat.month,
    this.headerTitleBuilder,
    this.previousPageLabel,
    this.nextPageLabel,
    this.rowHeight = AppDimens.calendarRowHeight,
    this.adaptiveRows = false,
    this.rangeOnly = false,
    this.allowHorizontalSwipe = true,
  });

  final bool showLunarDetails;
  final DateTime firstDay;
  final CalendarFormat calendarFormat;
  final String? previousPageLabel, nextPageLabel;
  final Widget Function(BuildContext, DateTime)? headerTitleBuilder;

  final double rowHeight;
  final bool adaptiveRows;
  final bool rangeOnly;

  /// 嵌入业务页签时可将横滑交给外层导航，左右箭头继续切换日期范围。
  final bool allowHorizontalSwipe;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? currentDay;
  final bool Function(DateTime) selectedDayPredicate;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final List<T> Function(DateTime)? eventLoader;
  final Widget? Function(BuildContext, DateTime, bool)? dayMarkerBuilder;

  /// 有业务内容时替换日期数字，颜色继续遵循选中、今天与相邻月状态。
  final Widget? Function(BuildContext, DateTime, Color)? dayContentBuilder;

  /// 月份标题、星期行、网格尺寸和四种日期状态均由同一组件呈现。
  ///
  /// 内层翻页容器与外层列表的滚动记录必须互相隔离：宿主列表用
  /// [PageStorageKey] 保存像素位置，日历内层保存的是页码，两者共用同一
  /// 存储标识时，列表的像素值会被当作页码读回，子树重建后日历直接落到
  /// [firstDay]（1900-01-01）。选中日期始终由业务通过 [focusedDay] 持有。
  @override
  Widget build(BuildContext context) =>
      _CalendarStorageScope(child: _calendar(context));

  Widget _calendar(BuildContext context) {
    if (rangeOnly) {
      final start = DateTime.utc(firstDay.year, firstDay.month, firstDay.day);
      final end = DateTime.utc(lastDay.year, lastDay.month, lastDay.day);
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: end.difference(start).inDays + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: DateTime.daysPerWeek,
            mainAxisExtent: rowHeight,
          ),
          itemBuilder: (context, index) {
            final date = start.add(Duration(days: index));
            return InkWell(
              onTap: () => onDaySelected(date, date),
              child: _dayCell(
                context,
                date,
                isSelected: selectedDayPredicate(date),
                isToday: isSameDay(date, currentDay ?? DateTime.now()),
              ),
            );
          },
        ),
      );
    }
    if (adaptiveRows && calendarFormat == CalendarFormat.month) {
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: Builder(builder: _adaptiveMonth),
      );
    }
    final primary = AppTokens.primary(context);
    // 七列网格限制极端文字缩放，完整农历及假期信息仍通过长按提示和读屏提供。
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: TableCalendar<T>(
        locale: Localizations.localeOf(context).toString(),
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: focusedDay,
        currentDay: currentDay,
        selectedDayPredicate: selectedDayPredicate,
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarFormat: calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: allowHorizontalSwipe
            ? AvailableGestures.horizontalSwipe
            : AvailableGestures.none,
        // 日期行容纳圆形日期与金额或数量标记，星期标题单独保留行高。
        rowHeight: rowHeight,
        daysOfWeekHeight: AppDimens.calendarWeekdayHeight,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
          leftChevronPadding: previousPageLabel == null
              ? const EdgeInsets.all(AppDimens.p12)
              : EdgeInsets.zero,
          rightChevronPadding: nextPageLabel == null
              ? const EdgeInsets.all(AppDimens.p12)
              : EdgeInsets.zero,
          leftChevronIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                AppIcons.chevronLeft,
                size: previousPageLabel == null ? null : AppDimens.icon20,
                color: previousPageLabel == null
                    ? AppTokens.iconTertiary(context)
                    : primary,
              ),
              if (previousPageLabel != null)
                Text(previousPageLabel!, style: AppTextTokens.label(context)),
            ],
          ),
          rightChevronIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (nextPageLabel != null)
                Text(nextPageLabel!, style: AppTextTokens.label(context)),
              Icon(
                AppIcons.chevronRight,
                size: nextPageLabel == null ? null : AppDimens.icon20,
                color: nextPageLabel == null
                    ? AppTokens.iconTertiary(context)
                    : primary,
              ),
            ],
          ),
          titleTextStyle: AppTextTokens.strongTitle(context),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: AppTextTokens.title(
            context,
          ).copyWith(color: primary, fontWeight: FontWeight.w600),
          selectedDecoration: BoxDecoration(
            color: AppTokens.buttonPrimary(context),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTextTokens.title(context).copyWith(
            color: AppTokens.buttonPrimaryText(context),
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: AppTextTokens.title(
            context,
          ).copyWith(color: AppTokens.textPrimary(context)),
          outsideTextStyle: AppTextTokens.title(context).copyWith(
            color: AppTokens.textTertiary(context).withValues(alpha: 0.3),
          ),
          weekendTextStyle: AppTextTokens.title(
            context,
          ).copyWith(color: AppTokens.textPrimary(context)),
          markersAlignment: Alignment.bottomCenter,
          markerDecoration: BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextTokens.label(context),
          weekendStyle: AppTextTokens.label(context),
        ),
        eventLoader: eventLoader,
        calendarBuilders: CalendarBuilders<T>(
          headerTitleBuilder: headerTitleBuilder,
          dowBuilder: (context, date) {
            final locale = Localizations.localeOf(context);
            final name = DateFormat.E(locale.toString()).format(date);
            return Center(
              child: Text(
                locale.languageCode == 'zh' ? name.characters.last : name,
                style: AppTextTokens.label(context),
              ),
            );
          },
          defaultBuilder: (context, date, _) => _dayCell(context, date),
          todayBuilder: (context, date, _) =>
              _dayCell(context, date, isToday: true),
          selectedBuilder: (context, date, _) =>
              _dayCell(context, date, isSelected: true),
          outsideBuilder: (context, date, _) =>
              _dayCell(context, date, isOutside: true),
          // 标记随日期格子统一布局，关闭 TableCalendar 自带的重复圆点。
          markerBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  // TableCalendar 只支持统一行高；原生 Table 让内容仅撑高所在周。
  Widget _adaptiveMonth(BuildContext context) {
    final month = DateTime.utc(focusedDay.year, focusedDay.month);
    final start = month.subtract(Duration(days: month.weekday - 1));
    final end = DateTime.utc(month.year, month.month + 1, 0);
    final weeks = (month.weekday - 1 + end.day + 6) ~/ 7;
    final locale = Localizations.localeOf(context);
    final today = currentDay ?? DateTime.now();
    final first = DateTime.utc(firstDay.year, firstDay.month, firstDay.day);
    final last = DateTime.utc(lastDay.year, lastDay.month, lastDay.day);
    final previous = DateTime.utc(month.year, month.month, 0);
    final next = DateTime.utc(month.year, month.month + 1);
    final canPrevious = !previous.isBefore(first);
    final canNext = !next.isAfter(last);
    var dragDistance = 0.0;
    void move(int direction) {
      if (direction < 0 && canPrevious) {
        final target = DateTime.utc(previous.year, previous.month);
        onPageChanged(target.isBefore(first) ? first : target);
      } else if (direction > 0 && canNext) {
        onPageChanged(next);
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).previousMonthTooltip,
                onPressed: canPrevious ? () => move(-1) : null,
                icon: Icon(
                  AppIcons.chevronLeft,
                  color: AppTokens.iconTertiary(context),
                ),
              ),
              Expanded(
                child:
                    headerTitleBuilder?.call(context, focusedDay) ??
                    Text(
                      DateFormat.yMMMM(locale.toString()).format(month),
                      textAlign: TextAlign.center,
                      style: AppTextTokens.strongTitle(context),
                    ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).nextMonthTooltip,
                onPressed: canNext ? () => move(1) : null,
                icon: Icon(
                  AppIcons.chevronRight,
                  color: AppTokens.iconTertiary(context),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: allowHorizontalSwipe
              ? (_) => dragDistance = 0
              : null,
          onHorizontalDragUpdate: allowHorizontalSwipe
              ? (details) => dragDistance += details.delta.dx
              : null,
          onHorizontalDragEnd: allowHorizontalSwipe
              ? (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity.abs() > 50) {
                    move(velocity < 0 ? 1 : -1);
                  } else if (dragDistance.abs() > 25) {
                    move(dragDistance < 0 ? 1 : -1);
                  }
                }
              : null,
          child: Table(
            children: [
              TableRow(
                children: List.generate(7, (index) {
                  final name = DateFormat.E(
                    locale.toString(),
                  ).format(start.add(Duration(days: index)));
                  return SizedBox(
                    height: AppDimens.calendarWeekdayHeight,
                    child: Center(
                      child: Text(
                        locale.languageCode == 'zh'
                            ? name.characters.last
                            : name,
                        style: AppTextTokens.label(context),
                      ),
                    ),
                  );
                }),
              ),
              for (var week = 0; week < weeks; week++)
                TableRow(
                  children: List.generate(7, (index) {
                    final date = start.add(Duration(days: week * 7 + index));
                    final enabled =
                        !date.isBefore(first) && !date.isAfter(last);
                    return TableCell(
                      verticalAlignment:
                          TableCellVerticalAlignment.intrinsicHeight,
                      child: Semantics(
                        button: true,
                        enabled: enabled,
                        selected: selectedDayPredicate(date),
                        child: InkWell(
                          onTap: enabled
                              ? () => onDaySelected(date, date)
                              : null,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: rowHeight),
                            child: _dayCell(
                              context,
                              date,
                              isToday: isSameDay(date, today),
                              isSelected: selectedDayPredicate(date),
                              isOutside: date.month != month.month || !enabled,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 日期与农历共用选中底色，底部只承载调用方提供的业务记录标记。
  Widget _dayCell(
    BuildContext context,
    DateTime date, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final l = AppLocalizations.of(context);
    final info = const LunarCalendar().dayInfo(date);
    final primary = AppTokens.primary(context);
    final textColor = isSelected
        ? AppTokens.buttonPrimaryText(context)
        : isToday
        ? primary
        : isOutside
        ? AppTokens.textTertiary(context).withValues(alpha: 0.3)
        : date.weekday >= DateTime.saturday
        ? AppTokens.textSecondary(context)
        : AppTokens.textPrimary(context);
    final secondaryColor = isSelected || isToday || isOutside
        ? textColor
        : info.isFestival
        ? AppTokens.textPrimary(context)
        : AppTokens.textTertiary(context);
    final marker = dayMarkerBuilder?.call(context, date, isOutside);
    final details = [
      DateFormat.yMMMMd(l.localeName).format(date),
      '${l.dayLunar}${info.lunarDate}',
      if (info.isFestival) info.label,
    ].join('，');
    return Tooltip(
      message: details,
      child: Column(
        children: [
          Semantics(
            label: details,
            child: SizedBox(
              height: AppDimens.calendarDayDiameter + AppDimens.p8,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: AppDimens.calendarDayDiameter,
                  height: AppDimens.calendarDayDiameter,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppTokens.buttonPrimary(context),
                          shape: BoxShape.circle,
                        )
                      : isToday
                      ? BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      dayContentBuilder?.call(context, date, textColor) ??
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${date.day}',
                              maxLines: 1,
                              style: AppTextTokens.title(context).copyWith(
                                color: textColor,
                                fontWeight: isToday || isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                height: 1.1,
                              ),
                            ),
                          ),
                      if (showLunarDetails)
                        Text(
                          info.label,
                          style: AppTextTokens.caption(
                            context,
                          ).copyWith(color: secondaryColor, height: 1.1),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          ?marker,
        ],
      ),
    );
  }
}

/// 给日历内部滚动容器一个独立的 PageStorage 桶。
///
/// 桶随日历子树一起销毁，既不读取宿主列表写入的像素位置，也不把内层页码
/// 写进宿主列表的记录。
class _CalendarStorageScope extends StatefulWidget {
  const _CalendarStorageScope({required this.child});

  final Widget child;

  @override
  State<_CalendarStorageScope> createState() => _CalendarStorageScopeState();
}

class _CalendarStorageScopeState extends State<_CalendarStorageScope> {
  final PageStorageBucket _bucket = PageStorageBucket();

  @override
  Widget build(BuildContext context) =>
      PageStorage(bucket: _bucket, child: widget.child);
}

/// 月历明细标题展示选中日期与农历，日期格式和间距保持统一。
class AppCalendarDateSectionHeader extends StatelessWidget {
  /// 根据选中日期生成明细区标题。
  const AppCalendarDateSectionHeader({super.key, required this.date});

  final DateTime date;

  /// 日历标题和日期操作提示共用本地化日期格式。
  static String dateLabel(BuildContext context, DateTime date) =>
      DateFormat.MMMMd(Localizations.localeOf(context).toString()).format(date);

  /// 日期跟随当前语言，标题保留用户选择的字号和自然高度。
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppDimens.p8),
    child: SectionTitle(
      title: dateLabel(context, date),
      textStyle: AppTextTokens.dateHeading(context),
      subtitle:
          '${AppLocalizations.of(context).dayLunar}${const LunarCalendar().dayInfo(date).lunarDate}',
      padding: EdgeInsets.zero,
    ),
  );
}

/// 日历无明细时使用轻量居中文字，与明细卡片共用内边距。
class AppCalendarEmptyDay extends StatelessWidget {
  const AppCalendarEmptyDay({super.key});

  /// 四个业务域共用同一日期空态文案、颜色和留白。
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppDimens.p20),
    child: Center(
      child: Text(
        AppLocalizations.of(context).calendarEmptyDay,
        style: TextStyle(color: AppTokens.textTertiary(context)),
      ),
    ),
  );
}

/// 日历金额沿用独立数值样式，单行缩放避免越过日期格边界。
class AppCalendarValue extends StatelessWidget {
  const AppCalendarValue({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  /// 预留行高按金额字体测量，不受长金额横向缩放影响。
  static double lineHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(
        text: '0',
        style: AppTextTokens.caption(
          context,
        ).copyWith(fontWeight: FontWeight.w600, height: 1.1),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  /// 金额不带标签背景，字重与颜色沿用既有数值令牌。
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      text,
      style: AppTextTokens.caption(
        context,
      ).copyWith(fontWeight: FontWeight.w600, color: color, height: 1.1),
      maxLines: 1,
    ),
  );
}

/// 所有日期保留等高金额行，业务标签不随当天有无支出上下错位。
class AppCalendarDayMarkers extends StatelessWidget {
  const AppCalendarDayMarkers({
    super.key,
    this.amountText,
    required this.labels,
  });

  final String? amountText;
  final List<String> labels;

  /// 空金额保留空白行，长金额缩放仅发生在行内，不挤占标签位置。
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: AppCalendarValue.lineHeight(context),
        child: amountText == null
            ? null
            : AppCalendarValue(
                text: amountText!,
                color: AppTokens.error(context),
              ),
      ),
      if (labels.isNotEmpty) AppCalendarLabels(labels: labels),
    ],
  );
}

/// 当日明细读取中共用三行列表占位。
class AppCalendarEntriesSkeleton extends StatelessWidget {
  const AppCalendarEntriesSkeleton({super.key});

  /// 短请求延迟显示骨架，持续请求才显示脉冲动画。
  @override
  Widget build(BuildContext context) => const DelayedSkeleton(
    placeholder: SizedBox(height: AppDimens.calendarEntriesPlaceholderHeight),
    child: PulseSkeleton(
      child: Column(
        children: [SkeletonListTile(), SkeletonListTile(), SkeletonListTile()],
      ),
    ),
  );
}

/// 周历、月历和计划日期共享训练与休息标签。
class AppCalendarLabels extends StatelessWidget {
  const AppCalendarLabels({
    super.key,
    required this.labels,
    this.semanticsLabel,
    this.tooltipTriggerMode,
    this.isPlaceholder = false,
  });
  final bool isPlaceholder;
  final TooltipTriggerMode? tooltipTriggerMode;
  final List<String> labels;
  final String? semanticsLabel;

  static double labelHeight(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: '训练', style: AppTextTokens.caption(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
      maxLines: 1,
    )..layout();
    final height = painter.height + AppDimens.p4;
    painter.dispose();
    return height;
  }

  static double rowHeight(BuildContext context, int count) =>
      (AppDimens.calendarDayDiameter +
              AppDimens.p8 +
              (count > 0 ? AppDimens.p8 : 0) +
              count * (labelHeight(context) + AppDimens.p4 / 2))
          .clamp(AppDimens.calendarRowHeight, double.infinity);

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();
    final description = semanticsLabel ?? labels.join(', ');
    return Tooltip(
      message: description,
      triggerMode: tooltipTriggerMode,
      child: Semantics(
        label: description,
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.p8),
              for (final label in labels)
                CustomPaint(
                  foregroundPainter: isPlaceholder
                      ? _CalendarPlaceholderBorder(
                          AppTokens.borderStrong(context),
                        )
                      : null,
                  child: Container(
                    height: labelHeight(context),
                    margin: const EdgeInsets.only(
                      left: AppDimens.p4 / 2,
                      right: AppDimens.p4 / 2,
                      bottom: AppDimens.p4 / 2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p4 / 2,
                    ),
                    decoration: BoxDecoration(
                      color: isPlaceholder
                          ? AppTokens.surfaceInput(context)
                          : AppTokens.surfaceSecondary(context),
                      borderRadius: BorderRadius.circular(AppDimens.radius4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextTokens.caption(context).copyWith(
                        color: isPlaceholder
                            ? AppTokens.textSecondary(context)
                            : AppTokens.isDark(context)
                            ? AppTokens.textPrimary(context)
                            : AppTokens.primary(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// 虚线仅标识等待填入的位置，正式训练标签继续使用原有样式。
class _CalendarPlaceholderBorder extends CustomPainter {
  const _CalendarPlaceholderBorder(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            AppDimens.p4 / 2,
            0,
            size.width - AppDimens.p4 / 2,
            size.height - AppDimens.p4 / 2,
          ).deflate(0.5),
          const Radius.circular(AppDimens.radius4),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in outline.computeMetrics()) {
      for (double start = 0; start < metric.length; start += AppDimens.p8) {
        canvas.drawPath(
          metric.extractPath(
            start,
            (start + AppDimens.p4).clamp(0, metric.length),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarPlaceholderBorder oldDelegate) =>
      color != oldDelegate.color;
}
