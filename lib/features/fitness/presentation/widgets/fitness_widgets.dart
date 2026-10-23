import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'dart:math' as math;
import 'package:sesame_notes/features/fitness/presentation/fitness_workout_navigation.dart';

import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:sesame_notes/domain/fitness/fitness_rules.dart'
    show fitnessDate;
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/calendar_entry_scope.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../../application/fitness_providers.dart';

String fitnessDuration(int seconds) {
  final d = Duration(seconds: seconds);
  return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

/// 响铃图标：围绕中心左右摇摆，每轮摆动后留出停顿。
///
/// 休息结束弹窗与顶部休息结束通知共用同一动效，保证「休息结束」在两处
/// 出现方式一致；系统开启「减少动态效果」时保持静止。
class RingingRestIcon extends StatefulWidget {
  const RingingRestIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  State<RingingRestIcon> createState() => _RingingRestIconState();
}

class _RingingRestIconState extends State<RingingRestIcon>
    with SingleTickerProviderStateMixin {
  late final _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _animation.stop();
      _animation.value = 0;
    } else if (!_animation.isAnimating) {
      _animation.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _animation,
    child: Icon(widget.icon, size: widget.size, color: widget.color),
    builder: (context, child) => Transform.rotate(
      key: const ValueKey('fitness-rest-alarm-motion'),
      angle: _animation.value < 0.6
          ? math.sin(_animation.value / 0.6 * math.pi * 8) * 0.18
          : 0,
      child: child,
    ),
  );
}

/// 休息是计划内的安排，周历首页与月历都显示独立条目，不当作无数据。
class FitnessRestDayCard extends StatelessWidget {
  const FitnessRestDayCard({super.key, required this.planName});
  final String planName;
  @override
  Widget build(BuildContext context) => SectionCard(
    margin: const EdgeInsets.only(bottom: AppDimens.p8),
    padding: CalendarEntryScope.active(context)
        ? EdgeInsets.zero
        : const EdgeInsets.all(AppDimens.p12),
    child: CalendarEntryScope.active(context)
        ? DetailListItem(
            leading: const DetailListIcon(child: Icon(AppIcons.nightlight)),
            title: AppLocalizations.of(context).fitnessRestDay,
            subtitle: DetailListSubtitle(child: Text(planName)),
          )
        : AppListTile(
            leading: AppIcons.nightlight,
            leadingWidget: Icon(
              AppIcons.nightlight,
              size: AppDimens.icon20,
              color: AppTokens.iconSecondary(context),
            ),
            title: AppLocalizations.of(context).fitnessRestDay,
            subtitle: planName,
            subtitleMaxLines: null,
          ),
  );
}

/// 通用业务状态名称，未开始状态在计划与训练之间复用。
String fitnessStatus(AppLocalizations l, String status) => switch (status) {
  'in_progress' => l.fitnessActive,
  'completed' => l.fitnessFinished,
  _ => l.fitnessPlanned,
};

/// 进行中的训练以最近一次计时片段是否结束区分暂停，保持原有训练状态模型。
bool fitnessWorkoutIsPaused(FitnessWorkout workout) =>
    workout.status == 'in_progress' &&
    workout.runSegments.isNotEmpty &&
    workout.runSegments.last.endedAt != null;

/// 训练卡、日期标签与常驻入口共用显示名称，暂停不会误标成正在计时。
String fitnessWorkoutStatus(AppLocalizations l, FitnessWorkout workout) =>
    fitnessWorkoutIsPaused(workout)
    ? l.fitnessPaused
    : fitnessStatus(l, workout.status);

/// 动态分类优先使用官方名称，历史删除项可继续展示，旧目录回退已有翻译。
String fitnessCatalogLabel(
  AppLocalizations l,
  String id, {
  FitnessTaxonomies? taxonomies,
  bool isEquipment = false,
}) =>
    taxonomies?.label(id, l.localeName, isEquipment: isEquipment) ??
    fitnessBodyPartLabel(l, id);

/// 动作目录与统计共用资料编码的本地化展示，未知扩展保留原文。
String fitnessBodyPartLabel(AppLocalizations l, String part) => switch (part) {
  'unknown' => l.fitnessUnknownPart,
  'chest' || 'pectorals' => l.fitnessChest,
  'back' => l.fitnessBack,
  'shoulders' || 'delts' || 'deltoids' => l.fitnessShoulders,
  'biceps' => l.fitnessBiceps,
  'triceps' => l.fitnessTriceps,
  'abs' || 'abdominals' => l.fitnessAbs,
  'glutes' => l.fitnessGlutes,
  'hamstrings' => l.fitnessHamstrings,
  'quadriceps' || 'quads' => l.fitnessQuadriceps,
  'calves' => l.fitnessCalves,
  'upper arms' => l.fitnessUpperArms,
  'lower arms' || 'forearms' => l.fitnessLowerArms,
  'upper legs' => l.fitnessUpperLegs,
  'lower legs' => l.fitnessLowerLegs,
  'waist' => l.fitnessWaist,
  'cardio' || 'cardiovascular system' => l.fitnessCardio,
  'barbell' => l.fitnessBarbell,
  'dumbbell' => l.fitnessDumbbell,
  'kettlebell' => l.fitnessKettlebell,
  'cable' => l.fitnessCable,
  'leverage machine' => l.fitnessMachine,
  'sled machine' => l.fitnessSledMachine,
  'body weight' => l.fitnessBodyWeightEquipment,
  'weighted' => l.fitnessWeightedEquipment,
  'lats' || 'latissimus dorsi' => l.fitnessLats,
  'spine' => l.fitnessSpine,
  'upper back' => l.fitnessUpperBack,
  'lower back' => l.fitnessLowerBack,
  'rear deltoids' => l.fitnessRearDeltoids,
  'rhomboids' => l.fitnessRhomboids,
  'traps' || 'trapezius' => l.fitnessTraps,
  'hip flexors' => l.fitnessHipFlexors,
  'core' => l.fitnessCore,
  'feet' => l.fitnessFeet,
  'ankles' => l.fitnessAnkles,
  'neck' => l.fitnessNeck,
  'adductors' || 'inner thighs' => l.fitnessAdductors,
  'abductors' => l.fitnessAbductors,
  'serratus anterior' => l.fitnessSerratus,
  'levator scapulae' => l.fitnessLevatorScapulae,
  'band' => l.fitnessBand,
  'resistance band' => l.fitnessResistanceBand,
  'assisted' => l.fitnessAssistedEquipment,
  'bosu ball' => l.fitnessBosu,
  'elliptical machine' => l.fitnessElliptical,
  'ez barbell' => l.fitnessEzBar,
  'hammer' => l.fitnessHammer,
  'medicine ball' => l.fitnessMedicineBall,
  'olympic barbell' => l.fitnessOlympicBarbell,
  'roller' => l.fitnessRoller,
  'rope' => l.fitnessRope,
  'skierg machine' => l.fitnessSkiErg,
  'smith machine' => l.fitnessSmithMachine,
  'stability ball' => l.fitnessStabilityBall,
  'stationary bike' => l.fitnessStationaryBike,
  'stepmill machine' => l.fitnessStepmill,
  'tire' => l.fitnessTire,
  'trap bar' => l.fitnessTrapBar,
  'upper body ergometer' => l.fitnessUpperBodyErgometer,
  'wheel roller' => l.fitnessAbWheel,
  'ankle stabilizers' => l.fitnessAnkleStabilizers,
  'brachialis' => l.fitnessBrachialis,
  'grip muscles' => l.fitnessGripMuscles,
  'groin' => l.fitnessGroin,
  'hands' => l.fitnessHands,
  'lower abs' => l.fitnessLowerAbs,
  'obliques' => l.fitnessObliques,
  'rotator cuff' => l.fitnessRotatorCuff,
  'shins' => l.fitnessShins,
  'soleus' => l.fitnessSoleus,
  'sternocleidomastoid' => l.fitnessSternocleidomastoid,
  'upper chest' => l.fitnessUpperChest,
  'wrist extensors' => l.fitnessWristExtensors,
  'wrist flexors' => l.fitnessWristFlexors,
  'wrists' => l.fitnessWrists,
  _ => part,
};

/// 添加官方内容后回到指定列表页：栈中存在该页时直接返回，否则回到根页面。
void fitnessReturnTo(BuildContext context, String routeName) {
  Navigator.of(
    context,
  ).popUntil((page) => page.settings.name == routeName || page.isFirst);
}

/// 页面提交统一保留失败提示；进行中冲突明确指向原训练。
Future<bool> fitnessRun(
  BuildContext context,
  Future<void> Function() action,
) async {
  final l = AppLocalizations.of(context);
  try {
    await action();
    return true;
  } on FitnessRunningWorkoutException catch (error) {
    if (!context.mounted) return false;
    final open = await AppDialog.confirm(
      context,
      title: l.fitnessContinue,
      message: l.fitnessActiveExists,
      okLabel: l.fitnessContinue,
    );
    if (open == true && context.mounted) {
      await openTrackedFitnessWorkout(context, error.existingWorkout.id);
    }
  } catch (error, stackTrace) {
    logger.error('Fitness', '训练数据操作失败', error, stackTrace);
    if (context.mounted) showToast(context, l.fitnessSaveFailed);
  }
  return false;
}

Future<bool> fitnessDelete(
  BuildContext context,
  Future<void> Function() action,
) {
  final l = AppLocalizations.of(context);
  return AppDialog.confirmAsync(
    context,
    title: l.commonDelete,
    message: l.fitnessDeleteMessage,
    onConfirm: action,
    errorMessage: (_) => l.fitnessSaveFailed,
  );
}

/// 名称及秒数编辑复用公共表单与键盘避让弹层，不暴露存储格式。
Future<String?> fitnessInput(
  BuildContext context, {
  required String title,
  String initial = '',
  String? helperText,
  bool numeric = false,
  int minValue = 0,
  int maxValue = FitnessDefaults.maxInteger,
}) async {
  var input = initial;
  final form = GlobalKey<FormState>();
  return showAppSheet<String>(
    context: context,
    child: Builder(
      builder: (context) {
        final l = AppLocalizations.of(context);
        return AppSheet(
          title: title,
          footer: AppPrimaryButton(
            label: l.commonConfirm,
            onPressed: () {
              if (form.currentState!.validate()) {
                Navigator.pop(context, input.trim());
              }
            },
          ),
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Semantics(
                label: title,
                child: TextFormField(
                  style: AppTextTokens.input(context),
                  initialValue: initial,
                  onChanged: (value) => input = value,
                  autofocus: true,
                  keyboardType: numeric
                      ? TextInputType.numberWithOptions(signed: minValue < 0)
                      : TextInputType.text,
                  // 弹层标题已说明用途，输入框不再重复一行浮动标题。
                  decoration: InputDecoration(
                    hintText: title,
                    helperText: helperText,
                    helperMaxLines: 8,
                  ),
                  validator: (value) {
                    if (numeric) {
                      if (!fitnessValidIntegerInput(
                        value ?? '',
                        minValue: minValue,
                        maxValue: maxValue,
                      )) {
                        return l.fitnessInvalidForm;
                      }
                    } else if (!fitnessValidName((value ?? '').trim())) {
                      return l.fitnessInvalidForm;
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class FitnessWorkoutMenu extends ConsumerWidget {
  const FitnessWorkoutMenu({
    super.key,
    required this.workout,
    this.enabled = true,
    this.onDelete,
  });
  final FitnessWorkout workout;
  final bool enabled;
  final Future<void> Function()? onDelete;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(fitnessActionsProvider);
    final source = ref
        .watch(fitnessTemplatesProvider)
        .value
        ?.where((template) => template.id == workout.sourceTemplateId)
        .firstOrNull;
    return AppPopupMenu(
      enabled: enabled,
      items: [
        if (source != null && workout.exercises.isNotEmpty)
          AppMenuItem.action(
            value: 'update-template',
            label: l.fitnessUpdateTemplate,
            subtitle: source.name,
          ),
        AppMenuItem.action(value: 'template', label: l.fitnessSaveTemplate),
        AppMenuItem.action(
          value: 'delete',
          label: l.commonDelete,
          isDanger: true,
        ),
      ],
      onSelected: (action) async {
        switch (action) {
          case 'update-template':
            final confirmed = await AppDialog.confirm(
              context,
              title: l.fitnessUpdateTemplate,
              message: l.fitnessUpdateTemplateConfirm,
              okLabel: l.fitnessUpdateTemplate,
            );
            if (confirmed == true && context.mounted) {
              await fitnessRun(context, () async {
                await repo.updateWorkoutTemplate(workout.id);
              });
            }
          case 'template':
            final name = await fitnessInput(
              context,
              title: l.fitnessSaveTemplate,
              initial: workout.name,
            );
            if (name != null && context.mounted) {
              await fitnessRun(context, () async {
                await repo.saveWorkoutAsTemplate(workout.id, name: name);
              });
            }
          case 'delete':
            if (onDelete != null) {
              await onDelete!();
              return;
            }
            await fitnessDelete(
              context,
              () => ref
                  .read(dataLifecycleProvider)
                  .deleteTarget(SyncTarget('fitness_workout', workout.id)),
            );
        }
      },
    );
  }
}

/// 计划卡片的省略号菜单：首页与「我的计划」列表共用同一套入口。
class FitnessPlanMenu extends ConsumerStatefulWidget {
  const FitnessPlanMenu({super.key, required this.plan});
  final FitnessPlan plan;
  @override
  ConsumerState<FitnessPlanMenu> createState() => _FitnessPlanMenuState();
}

class _FitnessPlanMenuState extends ConsumerState<FitnessPlanMenu> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = widget.plan;
    return AppPopupMenu(
      enabled: !_busy,
      items: [
        AppMenuItem.action(
          value: 'delete',
          label: l.fitnessDeletePlan,
          isDanger: true,
        ),
      ],
      onSelected: (_) async {
        if (_busy) return;
        setState(() => _busy = true);
        try {
          if (await AppDialog.confirm(
                    context,
                    title: l.fitnessDeletePlan,
                    okLabel: l.fitnessDeletePlan,
                    message: l.fitnessDeletePlanMessage,
                  ) ==
                  true &&
              context.mounted) {
            await fitnessRun(
              context,
              () => ref
                  .read(dataLifecycleProvider)
                  .deleteTarget(SyncTarget('fitness_plan', plan.id)),
            );
          }
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      },
    );
  }
}

class FitnessTemplateMenu extends ConsumerStatefulWidget {
  const FitnessTemplateMenu({super.key, required this.template});
  final FitnessTemplate template;
  @override
  ConsumerState<FitnessTemplateMenu> createState() =>
      _FitnessTemplateMenuState();
}

class _FitnessTemplateMenuState extends ConsumerState<FitnessTemplateMenu> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final template = widget.template;
    return AppPopupMenu(
      enabled: !_busy,
      items: [
        AppMenuItem.action(value: 'copy', label: l.fitnessCopy),
        AppMenuItem.action(
          value: 'delete',
          label: l.commonDelete,
          isDanger: true,
        ),
      ],
      onSelected: (action) async {
        if (_busy) return;
        final repo = ref.read(fitnessActionsProvider);
        setState(() => _busy = true);
        try {
          if (action == 'copy') {
            await fitnessRun(context, () async {
              final name = '${template.name} · ${l.fitnessCopy}';
              await repo.copyTemplate(
                template.id,
                name: fitnessValidName(name) ? name : template.name,
              );
            });
          } else if (action == 'delete') {
            await fitnessDelete(
              context,
              () => ref
                  .read(dataLifecycleProvider)
                  .deleteTarget(SyncTarget('fitness_template', template.id)),
            );
          }
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      },
    );
  }
}
