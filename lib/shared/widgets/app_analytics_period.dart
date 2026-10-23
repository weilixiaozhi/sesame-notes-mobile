import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/format_utils.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'capsule_switcher.dart';
import 'wheel_date_picker.dart';
import 'toast.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 账本和健身统计共用周期标题、滚轮选择与子周期栏，业务只提供日期和数据范围。
class AppAnalyticsPeriodHeader extends StatelessWidget {
  /// 日期标题、回到本期和子周期使用统一布局，周期切换由底部入口承接。
  const AppAnalyticsPeriodHeader({
    super.key,
    required this.period,
    required this.selectedDate,
    required this.isCurrent,
    required this.hasData,
    required this.tabs,
    required this.selectedTabId,
    required this.onDateChanged,
    required this.onTabChanged,
    required this.onCurrent,
  });

  final AnalyticsPeriod period;
  final DateTime selectedDate;
  final bool isCurrent, hasData;
  final List<AnalyticsSubTab> tabs;
  final String selectedTabId;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<AnalyticsSubTab> onTabChanged;
  final VoidCallback onCurrent;

  /// 日期选择器失败时保留原周期，并允许用户重新打开。
  Future<void> _pickDate(BuildContext context) async {
    try {
      final date = await showWheelDatePicker(
        context,
        initial: selectedDate,
        mode: switch (period) {
          AnalyticsPeriod.week => WheelDatePickerMode.week,
          AnalyticsPeriod.month => WheelDatePickerMode.ym,
          AnalyticsPeriod.year => WheelDatePickerMode.y,
        },
      );
      if (date != null && context.mounted) onDateChanged(date);
    } catch (error, stackTrace) {
      logger.error('AnalyticsPeriod', '打开统计日期选择失败', error, stackTrace);
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 日期和回到本期入口保持单行，文字边界与页面卡片共用外边距。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final title = switch (period) {
      AnalyticsPeriod.week => weekRangeLabel(context, selectedDate),
      AnalyticsPeriod.month => monthYearLabel(
        context,
        selectedDate.month,
        selectedDate.year,
      ),
      AnalyticsPeriod.year => l.homeYear(selectedDate.year),
    };
    final currentLabel = switch (period) {
      AnalyticsPeriod.week => l.analyticsBackToThisWeek,
      AnalyticsPeriod.month => l.analyticsBackToThisMonth,
      AnalyticsPeriod.year => l.analyticsBackToThisYear,
    };
    final subPeriods = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.domainPageInset,
      ),
      child: _PeriodTabs(
        tabs: tabs,
        selectedId: selectedTabId,
        onChanged: onTabChanged,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.domainPageInset,
            AppDimens.p8,
            AppDimens.domainPageInset,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const ValueKey('analytics_date_action'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, AppDimens.p36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed: hasData ? () => _pickDate(context) : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              title,
                              maxLines: 1,
                              softWrap: false,
                              style: AppTextTokens.strongTitle(context),
                            ),
                          ),
                        ),
                        if (hasData) ...[
                          const SizedBox(width: AppDimens.p4),
                          const Icon(
                            AppIcons.chevronDown,
                            size: AppDimens.icon16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (!isCurrent) ...[
                const SizedBox(width: AppDimens.p8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.p8,
                        ),
                        minimumSize: const Size(0, AppDimens.p36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onCurrent,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(currentLabel, maxLines: 1, softWrap: false),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        subPeriods,
      ],
    );
  }
}

/// 记账和健身统计共用底部悬浮的周／月／年分段。
class AppAnalyticsPeriodSwitcher extends StatelessWidget {
  /// 布局位置由页面或外壳决定，外观统一使用悬浮操作令牌。
  const AppAnalyticsPeriodSwitcher({
    super.key,
    required this.period,
    required this.onChanged,
  });
  final AnalyticsPeriod period;
  final ValueChanged<AnalyticsPeriod> onChanged;

  /// 强调底色、描边和阴影将周期入口与统计正文区分。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: AppDimens.analyticsFloatingSwitcherWidth,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radius20),
          color: AppTokens.domainAccentBackground(context),
          border: Border.all(color: AppTokens.borderStrong(context)),
          boxShadow: AppTokens.fabShadow(context),
        ),
        child: CapsuleSwitcher<AnalyticsPeriod>(
          height: AppDimens.p40,
          segmentHorizontalPadding: AppDimens.p4,
          selectedValue: period,
          backgroundColor: Colors.transparent,
          selectedBackgroundColor: AppTokens.surfaceElevated(context),
          selectedTextColor: AppTokens.primary(context),
          options: [
            CapsuleOption(value: AnalyticsPeriod.week, label: l.analyticsWeek),
            CapsuleOption(
              value: AnalyticsPeriod.month,
              label: l.analyticsMonth,
            ),
            CapsuleOption(value: AnalyticsPeriod.year, label: l.analyticsYear),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PeriodTabs extends StatefulWidget {
  /// 子周期采用内容宽度，在少量数据时仍保持与日期标题相同的左边界。
  const _PeriodTabs({
    required this.tabs,
    required this.selectedId,
    required this.onChanged,
  });
  final List<AnalyticsSubTab> tabs;
  final String selectedId;
  final ValueChanged<AnalyticsSubTab> onChanged;

  /// 每个期间栏保存独立的滚动位置。
  @override
  State<_PeriodTabs> createState() => _PeriodTabsState();
}

class _PeriodTabsState extends State<_PeriodTabs> {
  final _controller = ScrollController();
  final _keys = <String, GlobalKey>{};
  List<String> _lastIds = [];
  String? _lastSelected;

  /// 页面退出时释放横向滚动监听。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 只滚动当前横向期间栏，避免定位选中项时带动外层页面。
  Future<void> _revealSelection() async {
    try {
      if (!mounted || !_controller.hasClients) return;
      final selected = _keys[widget.selectedId]?.currentContext;
      final target = selected?.findRenderObject();
      if (target == null || !target.attached) return;
      await _controller.position.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 200),
      );
    } catch (error, stackTrace) {
      logger.error('AnalyticsPeriod', '定位选中的统计周期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 点击期间时提交日期选择和轻触反馈，操作异常记录日志并显示提示。
  Future<void> _selectTab(AnalyticsSubTab tab) async {
    try {
      widget.onChanged(tab);
      await HapticFeedback.lightImpact();
    } catch (error, stackTrace) {
      logger.error('AnalyticsPeriod', '切换统计子周期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 子周期使用轻量文字导航和选中下划线，长列表横向滚动并定位当前项。
  @override
  Widget build(BuildContext context) {
    final ids = widget.tabs.map((tab) => tab.id).toList();
    _keys.removeWhere((id, _) => !ids.contains(id));
    for (final id in ids) {
      _keys.putIfAbsent(id, GlobalKey.new);
    }
    // 数据加载后子周期会扩展；选择或列表变化时都重新定位选中项。
    if (_lastSelected != widget.selectedId || !listEquals(ids, _lastIds)) {
      _lastSelected = widget.selectedId;
      _lastIds = ids;
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelection());
    }
    final primary = AppTokens.primary(context);
    final radius = BorderRadius.circular(AppDimens.radius4);
    return SingleChildScrollView(
      key: const ValueKey('analytics_sub_periods'),
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: AppDimens.p8,
        children: [
          for (final tab in widget.tabs)
            Semantics(
              key: _keys[tab.id],
              selected: tab.id == widget.selectedId,
              button: true,
              child: Material(
                key: ValueKey('analytics_period_tab_${tab.id}'),
                color: Colors.transparent,
                borderRadius: radius,
                child: InkWell(
                  onTap: () => _selectTab(tab),
                  borderRadius: radius,
                  splashColor: primary.withValues(alpha: 0.12),
                  highlightColor: primary.withValues(alpha: 0.06),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: AppDimens.p32,
                      minHeight: AppDimens.p32,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: tab.id == widget.selectedId
                                ? primary
                                : Colors.transparent,
                            width: AppDimens.selectionIndicatorWidth,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p4,
                        horizontal: AppDimens.p8,
                      ),
                      child: Center(
                        child: Text(
                          tab.label,
                          maxLines: 1,
                          softWrap: false,
                          style: AppTextTokens.label(context).copyWith(
                            fontWeight: tab.id == widget.selectedId
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: tab.id == widget.selectedId
                                ? primary
                                : AppTokens.textSecondary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
