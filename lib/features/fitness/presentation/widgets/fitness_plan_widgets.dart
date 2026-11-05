import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/fitness.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimens.dart';
import '../../../../theme/icons/app_icons.dart';
import '../../../../theme/typography.dart';
import '../../application/fitness_catalog_provider.dart';
import 'fitness_exercise_media.dart';

/// 计划详情和创建结果共用名称与周期统计。
class FitnessPlanSummary extends StatelessWidget {
  /// 使用计划快照展示统计，休息日与未安排日由编辑页另行区分。
  const FitnessPlanSummary({
    super.key,
    required this.plan,
    this.showName = true,
  });

  final FitnessPlan plan;
  final bool showName;

  /// 卡片外观完全沿用当前皮肤的尺寸和颜色角色。
  @override
  Widget build(BuildContext context) => SectionCard(
    margin: EdgeInsets.zero,
    padding: const EdgeInsets.all(AppDimens.p16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName) ...[
          Text(plan.name, style: AppTextTokens.display1(context)),
          const SizedBox(height: AppDimens.p12),
        ],
        _PlanMetrics(plan: plan),
      ],
    ),
  );
}

/// 计划库使用独立卡片，不改变首页和我的计划卡片。
class FitnessPlanLibraryTile extends StatelessWidget {
  /// 库卡片只显示名称、循环统计与每日节奏。
  const FitnessPlanLibraryTile({
    super.key,
    required this.plan,
    required this.onTap,
  });

  final FitnessPlan plan;
  final VoidCallback onTap;

  /// 周期预览与详情共享同一份模板快照。
  @override
  Widget build(BuildContext context) => SectionCard(
    margin: const EdgeInsets.only(bottom: AppDimens.p12),
    padding: const EdgeInsets.all(AppDimens.p16),
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                plan.name,
                style: AppTextTokens.input(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Icon(
              AppIcons.chevronRight,
              size: AppDimens.icon20,
              color: AppTokens.iconSecondary(context),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p12),
        _PlanMetrics(plan: plan),
        const SizedBox(height: AppDimens.p12),
        _PlanRhythm(days: plan.days),
      ],
    ),
  );
}

/// 循环长度与训练、休息统计允许随字体大小自然换行。
class _PlanMetrics extends StatelessWidget {
  /// 统计来源始终使用当前计划快照。
  const _PlanMetrics({required this.plan});

  final FitnessPlan plan;

  /// 统计不依赖自然周，四天周期保持四天一循环。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final training = plan.days.where((day) => day.slot != null).length;
    return Wrap(
      spacing: AppDimens.p12,
      runSpacing: AppDimens.p4,
      children: [
        Text(
          l.fitnessPlanCycleCount(plan.cycleDays),
          style: AppTextTokens.label(
            context,
          ).copyWith(color: AppTokens.textLink(context)),
        ),
        Text(
          l.fitnessPlanTrainingDays(training),
          style: AppTextTokens.label(context),
        ),
        Text(
          l.fitnessPlanRestDays(plan.days.length - training),
          style: AppTextTokens.label(context),
        ),
      ],
    );
  }
}

/// 库卡片用紧凑色块预览前七天，完整内容由计划详情承接。
class _PlanRhythm extends StatelessWidget {
  /// 传入的顺序在展示时按周期日期归一。
  const _PlanRhythm({required this.days});

  final List<FitnessPlanDay> days;

  /// 每项保留完整语义名称，长文字允许换行而不扩大横向宽度。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ordered = [...days]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    final visible = ordered.take(7).toList(growable: false);
    if (visible.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - AppDimens.p4 * (visible.length - 1)) /
            visible.length;
        return Wrap(
          spacing: AppDimens.p4,
          runSpacing: AppDimens.p4,
          children: [
            for (final day in visible)
              Semantics(
                label:
                    '${l.fitnessPlanDayNumber(day.dayIndex + 1)}：'
                    '${day.slot?.name ?? l.fitnessCalendarRest}',
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p3,
                    vertical: AppDimens.p8,
                  ),
                  decoration: BoxDecoration(
                    color: day.slot == null
                        ? AppTokens.surfaceSecondary(context)
                        : AppTokens.surfaceSelected(context),
                    borderRadius: BorderRadius.circular(
                      AppTokens.inputRadius(context),
                    ),
                  ),
                  child: Text(
                    day.slot?.name.split('·').last ?? l.fitnessCalendarRest,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTokens.caption(context).copyWith(
                      color: day.slot == null
                          ? AppTokens.textSecondary(context)
                          : AppTokens.textLink(context),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// 周期编排、只读详情与创建结果共用每日安排列表。
class FitnessPlanDayList extends StatefulWidget {
  /// 未传 [onDayTap] 时点击训练日展开动作；传入时点击直接编排当天。
  const FitnessPlanDayList({
    super.key,
    required this.days,
    this.filledDays,
    this.onDayTap,
    this.focusDayIndex,
  });

  final List<FitnessPlanDay> days;
  final Set<int>? filledDays;
  final ValueChanged<int>? onDayTap;

  /// 校验发现未安排日时，父页面可将该日期所在分段切到可见范围。
  final int? focusDayIndex;

  /// 持有当前分段与展开项，避免改变父页面的编排状态。
  @override
  State<FitnessPlanDayList> createState() => _FitnessPlanDayListState();
}

class _FitnessPlanDayListState extends State<FitnessPlanDayList> {
  static const _pageSize = 7;
  int _segment = 0;
  final Set<int> _expanded = {};

  /// 初次显示时也允许父页面直接定位到一个待处理日期。
  @override
  void initState() {
    super.initState();
    _segment = (widget.focusDayIndex ?? 0) ~/ _pageSize;
  }

  /// 外部校验改变定位日期时只切换分段，不修改任何日程内容。
  @override
  void didUpdateWidget(covariant FitnessPlanDayList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusDayIndex != null &&
        widget.focusDayIndex != oldWidget.focusDayIndex) {
      _segment = widget.focusDayIndex! ~/ _pageSize;
    }
  }

  /// 分段只控制展示，长周期的最后一天仍然可达。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final days = [...widget.days]
      ..sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
    if (days.isEmpty) return AppEmpty(text: l.fitnessNoData);
    final lastSegment = (days.length - 1) ~/ _pageSize;
    final segment = _segment.clamp(0, lastSegment).toInt();
    final from = segment * _pageSize;
    final to = math.min(from + _pageSize, days.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = from; index < to; index++) ...[
                if (index > from)
                  Divider(height: 1, color: AppTokens.divider(context)),
                _day(context, days[index]),
              ],
            ],
          ),
        ),
        if (days.length > _pageSize) ...[
          const SizedBox(height: AppDimens.p8),
          Column(
            children: [
              Text(
                l.fitnessPlanSegment(from + 1, to, days.length),
                textAlign: TextAlign.center,
                style: AppTextTokens.caption(context),
              ),
              const SizedBox(height: AppDimens.p4),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: segment > 0
                          ? () => setState(() => _segment = segment - 1)
                          : null,
                      child: Text(
                        l.fitnessPlanPreviousSegment,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.p8),
                  Expanded(
                    child: TextButton(
                      onPressed: segment < lastSegment
                          ? () => setState(() => _segment = segment + 1)
                          : null,
                      child: Text(
                        l.fitnessPlanNextSegment,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 一级行同时呈现当天状态与训练组摘要，空白不误显示为休息。
  Widget _day(BuildContext context, FitnessPlanDay day) {
    final l = AppLocalizations.of(context);
    final filled = widget.filledDays?.contains(day.dayIndex) ?? true;
    final slot = day.slot;
    final editable = widget.onDayTap != null;
    final expanded = _expanded.contains(day.dayIndex);
    final title = !filled
        ? l.fitnessPlanArrangeOrRest
        : slot?.name ?? l.fitnessCalendarRest;
    final subtitle = !filled
        ? l.fitnessPlanUnarranged
        : slot == null
        ? l.fitnessPlanNoTraining
        : l.fitnessPlanDaySummary(
            slot.exercises.length,
            slot.exercises.fold(0, (total, item) => total + item.sets.length),
          );
    return Column(
      key: ValueKey('fitness-plan-day-${day.dayIndex}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: editable
              ? () => widget.onDayTap!(day.dayIndex)
              : slot == null
              ? null
              : () => setState(() {
                  if (!_expanded.add(day.dayIndex)) {
                    _expanded.remove(day.dayIndex);
                  }
                }),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.p12),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: AppDimens.domainActionSize,
                  ),
                  child: Text(
                    l.fitnessPlanDayNumber(day.dayIndex + 1),
                    style: AppTextTokens.caption(context),
                  ),
                ),
                const SizedBox(width: AppDimens.p8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextTokens.body(context).copyWith(
                          color: !filled
                              ? AppTokens.textLink(context)
                              : slot == null
                              ? AppTokens.textSecondary(context)
                              : AppTokens.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: AppDimens.p4),
                      Text(subtitle, style: AppTextTokens.caption(context)),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.p8),
                Icon(
                  editable
                      ? !filled
                            ? AppIcons.createEntry
                            : AppIcons.chevronRight
                      : slot == null
                      ? AppIcons.darkMode
                      : expanded
                      ? AppIcons.chevronUp
                      : AppIcons.chevronDown,
                  size: AppDimens.icon20,
                  color: AppTokens.iconSecondary(context),
                ),
              ],
            ),
          ),
        ),
        if (!editable && expanded && slot != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.p16,
              0,
              AppDimens.p16,
              AppDimens.p12,
            ),
            child: FitnessPlanExercises(exercises: slot.exercises),
          ),
      ],
    );
  }
}

/// 动作名称按当前语言解析，处方展示真实组数和次数。
class FitnessPlanExercises extends ConsumerWidget {
  /// 仅展示选定模板的动作处方，不读取或改变训练执行状态。
  const FitnessPlanExercises({super.key, required this.exercises});

  final List<FitnessExercise> exercises;

  /// 目录尚未就绪时使用动作文字占位，不把内部身份展示给用户。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final definitions = ref.watch(fitnessCatalogProvider).value;
    return Column(
      children: [
        for (final exercise in exercises)
          Builder(
            builder: (context) {
              final definition = definitions
                  ?.where((item) => item.id == exercise.exerciseId)
                  .firstOrNull;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        definition == null
                            ? l.fitnessExerciseDetail
                            : fitnessExerciseName(context, definition),
                        style: AppTextTokens.label(context),
                      ),
                    ),
                    const SizedBox(width: AppDimens.p12),
                    Flexible(
                      child: Text(
                        _prescription(l, exercise),
                        textAlign: TextAlign.end,
                        style: AppTextTokens.caption(context),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  /// 相同次数合并显示，次数不同的训练组保留各自配置。
  String _prescription(AppLocalizations l, FitnessExercise exercise) {
    final groups = <int?, int>{};
    for (final set in exercise.sets) {
      groups.update(set.reps, (value) => value + 1, ifAbsent: () => 1);
    }
    return groups.entries
        .map((entry) {
          final count = l.fitnessPlanSetCount(entry.value);
          return entry.key == null
              ? count
              : '$count × ${l.fitnessPlanRepCount(entry.key!)}';
        })
        .join(' · ');
  }
}
