import 'package:sesame_notes/shared/widgets/calendar_entry_scope.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_workout_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

import '../../application/fitness_providers.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'fitness_widgets.dart';
import 'fitness_exercise_media.dart';
import 'fitness_rest_sheet.dart';

class FitnessHomeCard extends StatelessWidget {
  const FitnessHomeCard({
    super.key,
    required this.name,
    required this.icon,
    required this.child,
    required this.onTap,
    this.trailing,
    this.color,
  });
  final String name;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final Color? color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SectionCard(
    margin: const EdgeInsets.only(bottom: AppDimens.p8),
    padding: EdgeInsets.zero,
    child: DetailListItem(
      title: name,
      compact: true,
      onTap: onTap,
      leading: DetailListIcon(
        size:
            AppDimens.icon28 +
            2 *
                (CalendarEntryScope.active(context)
                    ? AppDimens.p8
                    : AppDimens.p12),
        iconSize: AppDimens.icon28,
        backgroundColor: AppTokens.surfaceInput(context),
        foregroundColor: color ?? AppTokens.iconSecondary(context),
        child: Icon(icon),
      ),
      trailing: trailing,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppDimens.p4),
        child: child,
      ),
    ),
  );
}

class FitnessHomeWorkoutCard extends ConsumerStatefulWidget {
  /// 各训练状态共用紧凑卡片，卡片点击只负责详情导航。
  const FitnessHomeWorkoutCard({super.key, required this.workout});
  final FitnessWorkout workout;

  /// 卡片持有详情导航的防重入状态，不在入口处改变训练状态。
  @override
  ConsumerState<FitnessHomeWorkoutCard> createState() =>
      _FitnessHomeWorkoutCardState();
}

class _FitnessHomeWorkoutCardState
    extends ConsumerState<FitnessHomeWorkoutCard> {
  bool _busy = false;

  /// 当前卡片展示的训练快照。
  FitnessWorkout get workout => widget.workout;

  /// 点击卡片只进入原训练详情，快速重复点击不会叠加相同路由。
  Future<void> _open() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await openTrackedFitnessWorkout(context, workout.id);
    } catch (error, stackTrace) {
      logger.error('FitnessHomeCard', '打开训练详情失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 训练卡使用紧凑明细布局，所有状态保留真实动作组进度、状态与时长。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(fitnessClockProvider).value ?? DateTime.now();
    final sets = workout.exercises.expand((e) => e.sets).toList();
    final done = sets.where((s) => s.completed).length;
    final paused = fitnessWorkoutIsPaused(workout);
    final color = workout.status == 'completed'
        ? AppTokens.success(context)
        : paused
        ? AppTokens.warning(context)
        : workout.status == 'in_progress'
        ? AppTokens.info(context)
        : AppTokens.textSecondary(context);
    final status = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DetailListTag(
          label: fitnessWorkoutStatus(l, workout),
          foregroundColor: color,
          backgroundColor: AppTokens.surfaceSelected(context),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p4,
          ),
        ),
        const SizedBox(height: AppDimens.p4),
        Text(
          fitnessDuration(fitnessElapsed(workout, now).inSeconds),
          style: AppTextTokens.strongTitle(context),
        ),
      ],
    );
    final expandedText = MediaQuery.textScalerOf(context).scale(1) > 1;
    return FitnessHomeCard(
      name: workout.name,
      icon: workout.status == 'completed'
          ? AppIcons.checkCircle
          : paused
          ? AppIcons.pause
          : workout.status == 'in_progress'
          ? AppIcons.fitness
          : AppIcons.play,
      color: color,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!expandedText)
            Flexible(
              child: FittedBox(fit: BoxFit.scaleDown, child: status),
            ),
          const SizedBox(width: AppDimens.p8),
          FitnessWorkoutMenu(workout: workout, enabled: !_busy),
        ],
      ),
      onTap: () => _open(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FitnessExerciseCounts(exercises: workout.exercises),
          const SizedBox(height: AppDimens.p4),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: sets.isEmpty ? 0 : done / sets.length,
                  color: color,
                  backgroundColor: AppTokens.surfaceSecondary(context),
                  minHeight: AppDimens.p8,
                  borderRadius: BorderRadius.circular(AppDimens.radius8),
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              Text('$done/${sets.length}', style: AppTextTokens.label(context)),
            ],
          ),
          if (expandedText) ...[const SizedBox(height: AppDimens.p8), status],
        ],
      ),
    );
  }
}

class FitnessExerciseCounts extends StatelessWidget {
  const FitnessExerciseCounts({super.key, required this.exercises});
  final List<FitnessExercise> exercises;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: AppDimens.p12,
      runSpacing: AppDimens.p4,
      children: [
        _fitnessHomeMetric(
          context,
          AppIcons.description,
          '${l.fitnessHomeExerciseLabel} ${exercises.length}',
        ),
        _fitnessHomeMetric(
          context,
          AppIcons.checklist,
          '${l.fitnessSets} ${exercises.expand((e) => e.sets).length}',
        ),
      ],
    );
  }
}

/// 卡片内的图标 + 说明文字指标，首页与内容库卡片共用。
Widget _fitnessHomeMetric(BuildContext context, IconData icon, String text) =>
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppDimens.icon16,
          color: AppTokens.textSecondary(context),
        ),
        const SizedBox(width: AppDimens.p4),
        Flexible(
          child: Text(
            text,
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.textSecondary(context)),
          ),
        ),
      ],
    );

class FitnessHomePlanCard extends StatelessWidget {
  const FitnessHomePlanCard({
    super.key,
    required this.plan,
    this.showStatus = true,
    this.menu,
  });
  final FitnessPlan plan;

  /// 列表页只做管理入口，不展示进行中/已关闭状态标签。
  final bool showStatus;

  /// 管理菜单，展示在箭头左侧。
  final Widget? menu;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final training = plan.days.where((d) => d.slot != null).length;
    return FitnessHomeCard(
      name: plan.name,
      icon: AppIcons.calendar,
      onTap: () => context.pushNamed(Routes.fitnessPlanDetail, extra: plan.id),
      trailing: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStatus) ...[
              DetailListTag(
                label: plan.status == 'in_progress'
                    ? l.fitnessActive
                    : l.fitnessClosed,
                foregroundColor: plan.status == 'in_progress'
                    ? AppTokens.info(context)
                    : AppTokens.textSecondary(context),
                backgroundColor: AppTokens.surfaceSelected(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.p8,
                  vertical: AppDimens.p4,
                ),
              ),
              const SizedBox(width: AppDimens.p8),
            ],
            ?menu,
            // 管理菜单和右箭头不同时出现，菜单右侧不再挂箭头。
            if (menu == null)
              Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon20,
                color: AppTokens.iconSecondary(context),
              ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimens.p12,
            runSpacing: AppDimens.p4,
            children: [
              _fitnessHomeMetric(
                context,
                AppIcons.fitness,
                l.fitnessPlanTrainingDays(training),
              ),
              _fitnessHomeMetric(
                context,
                AppIcons.darkMode,
                l.fitnessPlanRestDays(plan.days.length - training),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 官方计划卡片：与首页计划卡同一版式，只读展示训练与休息天数。
class FitnessLibraryPlanCard extends StatelessWidget {
  const FitnessLibraryPlanCard({
    super.key,
    required this.name,
    required this.plan,
    required this.onTap,
  });
  final String name;
  final OfficialFitnessPlan plan;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final training = plan.days.where((day) => day.templateId != null).length;
    return FitnessHomeCard(
      name: name,
      icon: AppIcons.calendar,
      onTap: onTap,
      trailing: Icon(
        AppIcons.chevronRight,
        size: AppDimens.icon20,
        color: AppTokens.iconSecondary(context),
      ),
      child: Wrap(
        spacing: AppDimens.p12,
        runSpacing: AppDimens.p4,
        children: [
          _fitnessHomeMetric(
            context,
            AppIcons.fitness,
            l.fitnessPlanTrainingDays(training),
          ),
          _fitnessHomeMetric(
            context,
            AppIcons.darkMode,
            l.fitnessPlanRestDays(plan.days.length - training),
          ),
        ],
      ),
    );
  }
}

class FitnessHomeTemplateCard extends ConsumerWidget {
  const FitnessHomeTemplateCard({
    super.key,
    required this.template,
    this.showMenu = false,
    this.onTap,
  });
  final FitnessTemplate template;

  /// 省略号提供复制／删除入口；首页与模板列表都用同一个菜单。
  final bool showMenu;

  /// 覆盖点击行为；内容库用它进入官方只读详情。
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(fitnessCatalogProvider).value ?? [];
    final names = template.exercises
        .map((e) {
          final definition = catalog
              .where((d) => d.id == e.exerciseId)
              .firstOrNull;
          return definition == null
              ? e.exerciseId
              : fitnessExerciseName(context, definition);
        })
        .join(' · ');
    return FitnessHomeCard(
      name: template.name,
      icon: AppIcons.folder,
      onTap:
          onTap ??
          () => context.pushNamed(
            Routes.fitnessTemplateDetail,
            extra: template.id,
          ),
      trailing: showMenu
          ? FitnessTemplateMenu(template: template)
          : const Icon(AppIcons.chevronRight, size: AppDimens.icon20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (names.isNotEmpty) ...[
            Tooltip(
              message: names,
              child: Text(
                names,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.textSecondary(context)),
              ),
            ),
            const SizedBox(height: AppDimens.p4),
          ],
          FitnessExerciseCounts(exercises: template.exercises),
          if (template.catalogOrigin != null) ...[
            const SizedBox(height: AppDimens.p4),
            Text(
              l.fitnessOfficialSource,
              style: AppTextTokens.label(
                context,
              ).copyWith(color: AppTokens.textSecondary(context)),
            ),
          ],
        ],
      ),
    );
  }
}

/// 吸附入口属于导航壳，切换健身子页时仍保留同一训练与真实计时。
class FitnessRunningBanner extends ConsumerWidget {
  const FitnessRunningBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = ref.watch(fitnessRunningWorkoutProvider).value;
    if (workout == null) return const SizedBox.shrink();
    final now = ref.watch(fitnessClockProvider).value ?? DateTime.now();
    final l = AppLocalizations.of(context);
    return Material(
      // 与上方同步横幅同为贴底常驻条：中性底色 + 主色强调，
      // 避免高饱和容器色在底栏上方形成一整块抢眼条带。
      color: AppTokens.surfaceSecondary(context),
      child: InkWell(
        onTap: () => openTrackedFitnessWorkout(context, workout.id),
        child: Padding(
          // 行内休息胶囊与文字共用紧凑行高，上下留白使用统一间距。
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p12,
            vertical: AppDimens.p8,
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.fitness,
                size: AppDimens.icon16,
                color: AppTokens.primary(context),
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Text(
                  workout.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTokens.body(context),
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fitnessWorkoutStatus(l, workout),
                          style: AppTextTokens.label(
                            context,
                          ).copyWith(color: AppTokens.primary(context)),
                        ),
                        const SizedBox(width: AppDimens.p8),
                        Text(
                          fitnessDuration(
                            fitnessElapsed(workout, now).inSeconds,
                          ),
                          style: AppTextTokens.label(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              // 休息状态只作展示：点击常驻条统一进入训练详情。
              Tooltip(
                message: l.fitnessRest,
                child: FitnessRestCountdown(
                  timer: workout.restTimer,
                  now: now,
                  seconds:
                      ref
                          .watch(fitnessPreferencesProvider)
                          .value
                          ?.defaultRestSeconds ??
                      FitnessDefaults.restSeconds,
                  style: FitnessRestCountdownStyle.inline,
                ),
              ),
              const SizedBox(width: AppDimens.p4),
              Icon(
                AppIcons.chevronRight,
                size: AppDimens.icon16,
                color: AppTokens.iconSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
