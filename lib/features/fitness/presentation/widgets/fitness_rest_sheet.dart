import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_surface_visibility.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../../application/fitness_providers.dart';
import 'fitness_widgets.dart';
import '../../application/fitness_lifecycle.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/colors.dart';

class FitnessRestSheet extends ConsumerStatefulWidget {
  const FitnessRestSheet({super.key, required this.workoutId});
  final String workoutId;
  @override
  ConsumerState<FitnessRestSheet> createState() => _FitnessRestSheetState();
}

class _FitnessRestSheetState extends ConsumerState<FitnessRestSheet> {
  @override
  void initState() {
    super.initState();
    fitnessRestSheetVisibility.open(widget.workoutId);
  }

  @override
  void dispose() {
    fitnessRestSheetVisibility.close(widget.workoutId);
    super.dispose();
  }

  bool _busy = false;
  int? _draftSeconds;
  Future<bool> _run(
    Future<FitnessWorkout> Function(FitnessActions) action,
  ) async {
    if (_busy) return false;
    setState(() => _busy = true);
    final ok = await fitnessRun(context, () async {
      await action(ref.read(fitnessActionsProvider));
    });
    if (mounted) setState(() => _busy = false);
    return ok;
  }

  /// 手动计时采用本次草稿或默认时长，运行中的计时沿用持久化休息状态。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final remindersEnabled = ref.watch(reminderSettingsProvider).restActive;
    final workout = ref.watch(fitnessWorkoutProvider(widget.workoutId)).value;
    final prefs = ref.watch(fitnessPreferencesProvider).value;
    final now = ref.watch(fitnessClockProvider).value ?? DateTime.now();
    final seconds =
        _draftSeconds ??
        prefs?.defaultRestSeconds ??
        FitnessDefaults.restSeconds;
    final active = workout?.status == 'in_progress';
    final timer = workout?.restTimer;
    final remaining = fitnessRestRemaining(timer, now);
    final counting = timer != null && remaining > 0;
    final completed = fitnessRestCompleted(timer, now);
    if (completed) {
      return AbsorbPointer(
        absorbing: _busy,
        child: AppSheet(
          footer: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(AppIcons.refresh),
                  label: Text(l.fitnessRestRestart),
                  onPressed: !active
                      ? null
                      : () => _run(
                          (repo) => repo.startRest(
                            widget.workoutId,
                            seconds: timer!.durationSeconds,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: OutlinedButton(
                  child: Text(l.fitnessRestEnd),
                  onPressed: () async {
                    final ok = await _run(
                      (repo) => repo.skipRest(widget.workoutId),
                    );
                    if (ok && context.mounted) Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: RingingRestIcon(
                    icon: AppIcons.restAlarm,
                    size: AppDimens.restAlarmSize,
                    color: AppTokens.primary(context),
                  ),
                ),
                const SizedBox(height: AppDimens.p12),
                Text(
                  l.fitnessRestCompletedTitle,
                  style: AppTextTokens.display2(context),
                ),
                const SizedBox(height: AppDimens.p8),
                Text(
                  fitnessDuration(timer!.durationSeconds),
                  style: AppTextTokens.label(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AbsorbPointer(
      absorbing: _busy,
      child: AppSheet(
        title: l.fitnessRest,
        footer: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: !active || timer == null
                    ? null
                    : () => _run((repo) => repo.skipRest(widget.workoutId)),
                child: Text(l.fitnessSkip),
              ),
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: AppPrimaryButton(
                fullWidth: false,
                label: !counting
                    ? l.fitnessStartTimer
                    : timer.status == 'paused'
                    ? l.fitnessResume
                    : l.fitnessPause,
                onPressed: !active
                    ? null
                    : () => _run((repo) async {
                        if (!counting && remindersEnabled && prefs != null) {
                          // 开始计时属于用户主动操作，在此补齐首次使用所需的系统授权。
                          final granted =
                              await requestFitnessReminderPermission(
                                preferences: prefs,
                                channelName: l.fitnessRest,
                              );
                          if (context.mounted) {
                            ref.invalidate(exactReminderPermissionProvider);
                            if (!granted) {
                              showToast(
                                context,
                                l.fitnessReminderPermissionDenied,
                              );
                            }
                          }
                        }
                        return !counting
                            ? repo.startRest(widget.workoutId, seconds: seconds)
                            : timer.status == 'paused'
                            ? repo.resumeRest(widget.workoutId)
                            : repo.pauseRest(widget.workoutId);
                      }),
              ),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
            child: Column(
              children: [
                FitnessRestCountdown(timer: timer, now: now, seconds: seconds),
                const SizedBox(height: AppDimens.p8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final delta in [-10, 10])
                      TextButton(
                        onPressed:
                            !active || (timer == null && seconds + delta <= 0)
                            ? null
                            : timer == null
                            ? () => setState(() {
                                // 尚未开始时只编辑本次时长，开始后再由仓库保存计时。
                                _draftSeconds = (seconds + delta).clamp(
                                  1,
                                  FitnessDefaults.maxInteger,
                                );
                              })
                            : () => _run(
                                (repo) =>
                                    repo.adjustRest(widget.workoutId, delta),
                              ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.textSecondary(context),
                        ),
                        child: Text('${delta > 0 ? '+' : ''}${delta}s'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 休息倒计时的呈现形态：三种入口的可用高度差别很大，形态由调用方显式选择。
enum FitnessRestCountdownStyle {
  /// 弹层：大圆环 + 剩余时间 + 本次时长。
  full,

  /// 训练页悬浮按钮：小圆环，环内标注「休息」与剩余时间。
  compact,

  /// 常驻条行内胶囊：圆环 + 说明 + 剩余时间，高度受控以保持条高紧凑。
  inline,
}

/// 悬浮入口、常驻入口和弹层共用剩余进度，暂停时立即停住边框动画。
///
/// 三种形态都显式呈现计时内容与结束状态：计时中标注「休息」与剩余时间，
/// 到时后显示「休息结束」，避免出现没有说明的倒计时。
class FitnessRestCountdown extends StatelessWidget {
  const FitnessRestCountdown({
    super.key,
    required this.timer,
    required this.now,
    this.seconds = FitnessDefaults.restSeconds,
    this.style = FitnessRestCountdownStyle.full,
  });
  final FitnessRestTimer? timer;
  final DateTime now;
  final int seconds;
  final FitnessRestCountdownStyle style;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final remaining = timer == null
        ? seconds
        : fitnessRestRemaining(timer, now);
    final total = timer?.durationSeconds ?? seconds;
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final duration = fitnessDuration(remaining);
    // 计时仍在跑但剩余已归零，即本次休息到时结束，需要显式呈现结束状态。
    final completed = fitnessRestCompleted(timer, now);
    final primary = AppTokens.primary(context);
    final time = completed
        ? l.fitnessRestEnd
        : remaining < 3600
        ? duration.substring(3)
        : duration;

    /// 三种形态共用的进度环，只有尺寸与描边粗细不同。
    Widget ring(double strokeWidth) => TweenAnimationBuilder<double>(
      tween: Tween(begin: progress, end: progress),
      duration: timer?.status == 'running'
          ? const Duration(seconds: 1)
          : Duration.zero,
      builder: (context, value, _) => CircularProgressIndicator(
        value: value,
        strokeWidth: strokeWidth,
        backgroundColor: AppTokens.surfaceInput(context),
        color: primary,
        semanticsLabel: completed
            ? l.fitnessRestCompletedTitle
            : '${l.fitnessRest} $duration',
      ),
    );

    switch (style) {
      case FitnessRestCountdownStyle.full:
        return SizedBox.square(
          dimension: AppDimens.exerciseDetailMediaSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: ring(6)),
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                // 圆环内空间固定，整体等比缩放避免文字溢出圆环。
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: AppTextTokens.display3(context)),
                      Text('$total s', style: AppTextTokens.caption(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case FitnessRestCountdownStyle.compact:
        return SizedBox.square(
          // 外径比内部两行文字大一档，内容不贴描边。
          dimension: AppDimens.restCountdownCompactSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: ring(3)),
              Padding(
                padding: const EdgeInsets.all(AppDimens.p8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.fitnessRest,
                        style: AppTextTokens.caption(context),
                      ),
                      Text(
                        time,
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(color: completed ? primary : null),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case FitnessRestCountdownStyle.inline:
        return Container(
          // 行内胶囊只占一行高度，常驻条因此不会被休息计时条目顶高。
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p4,
          ),
          decoration: BoxDecoration(
            color: AppTokens.surface(context),
            borderRadius: BorderRadius.circular(AppDimens.radius28),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(dimension: AppDimens.icon16, child: ring(2)),
              const SizedBox(width: AppDimens.p4),
              Text(
                completed ? l.fitnessRestCompletedTitle : l.fitnessRest,
                style: AppTextTokens.caption(
                  context,
                ).copyWith(color: completed ? primary : null),
              ),
              if (!completed) ...[
                const SizedBox(width: AppDimens.p4),
                Text(
                  time,
                  style: AppTextTokens.label(
                    context,
                  ).copyWith(color: AppTokens.textPrimary(context)),
                ),
              ],
            ],
          ),
        );
    }
  }
}
