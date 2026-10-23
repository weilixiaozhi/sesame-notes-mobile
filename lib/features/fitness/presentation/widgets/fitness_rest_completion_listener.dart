import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_surface_visibility.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import '../../application/fitness_providers.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'fitness_widgets.dart';

/// 常驻导航器上方，只占顶部通知区域，不改路由、焦点或用户输入。
class FitnessRestCompletionListener extends ConsumerStatefulWidget {
  const FitnessRestCompletionListener({
    super.key,
    required this.navigatorKey,
    required this.enabled,
  });
  final GlobalKey<NavigatorState> navigatorKey;
  final bool enabled;
  @override
  ConsumerState<FitnessRestCompletionListener> createState() =>
      _FitnessRestCompletionListenerState();
}

class _FitnessRestCompletionListenerState
    extends ConsumerState<FitnessRestCompletionListener> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final owner = ref.watch(fitnessActionsProvider);
    final workout = ref.watch(fitnessRunningWorkoutProvider).value;
    final now = ref.watch(fitnessClockProvider).value ?? DateTime.now();
    final timer = workout?.restTimer;
    if (!widget.enabled ||
        workout == null ||
        !fitnessRestCompleted(timer, now)) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    Future<void> act(bool repeat) async {
      if (_busy) return;
      final feedback = widget.navigatorKey.currentState?.overlay?.context;
      if (feedback == null) return;
      setState(() => _busy = true);
      await fitnessRun(feedback, () async {
        final latest = await owner.getWorkout(workout.id);
        // 旧通知不能跳过或重启刚由其他页面更新的计时。
        if (!mounted ||
            !identical(owner, ref.read(fitnessActionsProvider)) ||
            !fitnessRestPromptStillCurrent(latest, timer!)) {
          return;
        }
        if (repeat) {
          await owner.startRest(workout.id, seconds: timer.durationSeconds);
        } else {
          await owner.skipRest(workout.id);
        }
      });
      if (mounted) setState(() => _busy = false);
    }

    return Positioned(
      top: 0,
      left: AppDimens.p12,
      right: AppDimens.p12,
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([
            fitnessRestSheetVisibility,
            fitnessWorkoutVisibility,
          ]),
          builder: (context, _) {
            // 计时弹窗或训练详情已展开结束态时常驻通知让位，同一次休息不重复提示。
            if (!fitnessRestPromptVisible(
              timer,
              now,
              sheetOpen: fitnessRestSheetVisibility.isOpen(workout.id),
              detailOpen: fitnessWorkoutVisibility.isOpen(workout.id),
            )) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: AppDimens.p12),
              child: Semantics(
                liveRegion: true,
                child: Material(
                  key: const ValueKey('fitness-rest-completed-banner'),
                  color: colors.inverseSurface,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(AppDimens.radius28),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    child: Row(
                      children: [
                        // 与休息结束弹窗同款响铃动效，保持两处出现方式一致。
                        RingingRestIcon(
                          icon: AppIcons.timer,
                          size: AppDimens.restStatusIconSize,
                          color: colors.inversePrimary,
                        ),
                        const SizedBox(width: AppDimens.p12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l.fitnessRestCompletedTitle,
                                style: AppTextTokens.strongTitle(
                                  context,
                                ).copyWith(color: colors.onInverseSurface),
                              ),
                              const SizedBox(height: AppDimens.p4),
                              Text(
                                fitnessDuration(timer!.durationSeconds),
                                style: AppTextTokens.label(context).copyWith(
                                  color: colors.onInverseSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                          ),
                          onPressed: _busy ? null : () => act(true),
                          icon: Icon(
                            AppIcons.refresh,
                            semanticLabel: l.fitnessRepeatRest,
                          ),
                        ),
                        const SizedBox(width: AppDimens.p4),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: colors.onInverseSurface.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: colors.onInverseSurface,
                          ),
                          onPressed: _busy ? null : () => act(false),
                          icon: Icon(
                            AppIcons.close,
                            semanticLabel: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
