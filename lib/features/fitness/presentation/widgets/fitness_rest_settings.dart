import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'fitness_widgets.dart';

Future<void> showFitnessRestSettings(
  BuildContext context,
  WidgetRef ref,
  List<FitnessExercise> exercises,
) async {
  if (exercises.isEmpty) return;
  final repo = ref.read(fitnessActionsProvider);
  await fitnessRun(context, () async {
    final prefs = await repo.getPreferences();
    if (!context.mounted) return;
    final exercise = exercises.first;
    final setting = prefs.exerciseRestSettings[exercise.exerciseId];
    await showAppSheet<void>(
      context: context,
      child: _RestSettings(
        initial:
            setting ??
            FitnessExerciseRest(
              restSeconds: exercise.restSeconds,
              warmupRestSeconds:
                  exercise.warmupRestSeconds ?? exercise.restSeconds,
            ),
        onSave: (value) async {
          await repo.setExerciseRestSettings(
            exercises.map((e) => e.exerciseId),
            value,
          );
        },
      ),
    );
  });
}

Future<void> showFitnessDefaultRestSettings(
  BuildContext context,
  WidgetRef ref,
) async {
  final repo = ref.read(fitnessActionsProvider);
  await fitnessRun(context, () async {
    final prefs = await repo.getPreferences();
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    await showAppSheet<void>(
      context: context,
      child: _RestSettings(
        title: l.fitnessDefaultRest,
        initial: FitnessExerciseRest(
          restSeconds: prefs.defaultRestSeconds,
          warmupRestSeconds:
              prefs.defaultWarmupRestSeconds ?? prefs.defaultRestSeconds,
        ),
        onSave: (value) async {
          final latest = await repo.getPreferences();
          await repo.savePreferences(
            latest.copyWith(
              defaultRestSeconds: value.restSeconds,
              defaultWarmupRestSeconds: value.warmupRestSeconds,
            ),
          );
        },
      ),
    );
  });
}

class _RestSettings extends StatefulWidget {
  const _RestSettings({
    required this.initial,
    required this.onSave,
    this.title,
  });
  final String? title;
  final FitnessExerciseRest initial;
  final Future<void> Function(FitnessExerciseRest) onSave;
  @override
  State<_RestSettings> createState() => _RestSettingsState();
}

class _RestSettingsState extends State<_RestSettings> {
  late final _working = TextEditingController(
    text: '${widget.initial.restSeconds}',
  );
  late final _warmup = TextEditingController(
    text: '${widget.initial.warmupRestSeconds}',
  );
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  @override
  void dispose() {
    _working.dispose();
    _warmup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopScope(
      canPop: !_busy,
      child: AppSheet(
        title: widget.title ?? l.fitnessRestSeconds,
        footer: AppPrimaryButton(
          busy: _busy,
          onPressed: _busy
              ? null
              : () async {
                  if (!_form.currentState!.validate()) return;
                  setState(() => _busy = true);
                  final ok = await fitnessRun(
                    context,
                    () => widget.onSave(
                      FitnessExerciseRest(
                        restSeconds: int.parse(_working.text),
                        warmupRestSeconds: int.parse(_warmup.text),
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  setState(() => _busy = false);
                  if (ok) Navigator.pop(context);
                },
          label: l.commonSave,
        ),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final field in [
                  (_warmup, l.fitnessWarmupRest),
                  (_working, l.fitnessRestSeconds),
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.p12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(field.$2, style: AppTextTokens.label(context)),
                        const SizedBox(height: AppDimens.p8),
                        TextFormField(
                          controller: field.$1,
                          style: AppTextTokens.input(context),
                          enabled: !_busy,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: field.$2),
                          validator: (raw) {
                            final n = int.tryParse(raw ?? '');
                            return n != null &&
                                    n >= 0 &&
                                    n <= FitnessDefaults.maxInteger
                                ? null
                                : l.fitnessInvalidForm;
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
