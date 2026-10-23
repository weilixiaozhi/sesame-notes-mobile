import 'package:flutter/material.dart';
import 'fitness_set_keyboard.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 训练与模板使用相同的贴底操作布局，主次操作只由调用方提供。
class FitnessEditorFooter extends StatelessWidget {
  const FitnessEditorFooter({
    super.key,
    required this.onRest,
    required this.onAdd,
    this.onStart,
    this.execution = false,
    this.showStart = true,
    this.keyboard,
  });
  final VoidCallback? onRest, onAdd, onStart;
  final FitnessKeyboardController? keyboard;
  final bool execution;
  final bool showStart;
  @override
  Widget build(BuildContext context) {
    if (keyboard?.isOpen == true) {
      return AbsorbPointer(
        absorbing: onAdd == null,
        child: FitnessSetKeyboard(controller: keyboard!),
      );
    }
    final l = AppLocalizations.of(context);
    final compact = TextButton.styleFrom(
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      minimumSize: const Size(0, AppDimens.p36),
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p8),
    );
    return Material(
      color: AppTokens.surface(context),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p16,
            vertical: AppDimens.p8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: compact,
                      onPressed: onRest,
                      icon: const Icon(AppIcons.restDuration),
                      label: Text(l.fitnessSetRestTime),
                    ),
                  ),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: execution
                        ? FilledButton.icon(
                            style: compact,
                            onPressed: onAdd,
                            icon: const Icon(AppIcons.add),
                            label: Text(l.fitnessAddExercises),
                          )
                        : OutlinedButton.icon(
                            style: compact,
                            onPressed: onAdd,
                            icon: const Icon(AppIcons.add),
                            label: Text(l.fitnessAddExercises),
                          ),
                  ),
                ],
              ),
              if (!execution && showStart) ...[
                const SizedBox(height: AppDimens.p8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, AppDimens.p40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: onStart,
                  child: Text(l.fitnessStartUsingTemplate),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
