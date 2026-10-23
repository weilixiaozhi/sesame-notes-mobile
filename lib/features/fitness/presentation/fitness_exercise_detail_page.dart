import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_workout_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_exercise_media.dart';
import 'widgets/fitness_widgets.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';

class FitnessExerciseDetailPage extends ConsumerStatefulWidget {
  const FitnessExerciseDetailPage({super.key, required this.exerciseId});
  final String exerciseId;
  @override
  ConsumerState<FitnessExerciseDetailPage> createState() =>
      _FitnessExerciseDetailPageState();
}

class _FitnessExerciseDetailPageState
    extends ConsumerState<FitnessExerciseDetailPage> {
  int _historyLimit = 50;
  bool _loadingMore = false;
  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    final next = _historyLimit + 50;
    final provider = fitnessExerciseHistoryProvider((
      exerciseId: widget.exerciseId,
      limit: next,
    ));
    final subscription = ref.listenManual(provider, (_, _) {});
    try {
      await ref.read(provider.future);
      if (!mounted) return;
      setState(() => _historyLimit = next);
      // 新页已到达后才切换查询，并保活到下一帧接管，避免清空旧列表或跳动。
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
      }
    } finally {
      subscription.close();
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  bool _pinning = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(fitnessCatalogProvider);
    final custom = catalog.value
        ?.where((e) => e.id == widget.exerciseId)
        .firstOrNull
        ?.custom;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l.fitnessExerciseDetail,
            showBack: true,
            actions: custom == null || custom.deleted
                ? null
                : [
                    HeaderIconAction(
                      icon: AppIcons.edit,
                      tooltip: l.fitnessEdit,
                      onPressed: () => context.pushNamed(
                        Routes.fitnessCustomExerciseEdit,
                        extra: custom,
                      ),
                    ),
                    HeaderIconAction(
                      icon: AppIcons.delete,
                      tooltip: l.commonDelete,
                      onPressed: () async {
                        final repository = ref.read(fitnessActionsProvider);
                        final deleted = await AppDialog.confirmAsync(
                          context,
                          title: l.commonDelete,
                          message: l.fitnessCustomDeleteConfirm,
                          onConfirm: () =>
                              repository.deleteCustomExercise(custom.id),
                          errorMessage: (_) => l.commonOperationFailed,
                        );
                        if (deleted && context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
          ),
          Expanded(
            child: catalog.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessCatalogProvider),
              ),
              data: (all) {
                final def = all
                    .where((d) => d.id == widget.exerciseId)
                    .firstOrNull;
                return def == null
                    ? AppEmpty(text: l.fitnessNoExercises)
                    : _content(context, def);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, FitnessExerciseDefinition def) {
    final l = AppLocalizations.of(context);
    final preferences = ref.watch(fitnessPreferencesProvider);
    final taxonomies = ref.watch(fitnessTaxonomiesProvider);
    final prefs = preferences.value;
    final pinned = prefs?.pinnedExerciseIds.contains(def.id) ?? false;
    final locale = Localizations.localeOf(context);
    final instructions = locale.languageCode != 'zh'
        ? def.instructionsEn
        : locale.countryCode == 'TW' || locale.scriptCode == 'Hant'
        ? def.instructionsZhHant
        : def.instructionsZh;
    final historyQuery = (exerciseId: def.id, limit: _historyLimit);
    final workouts = ref.watch(fitnessExerciseHistoryProvider(historyQuery));
    final complete =
        ref.watch(fitnessSyncStatusProvider).value?.isComplete == true;
    return ListView(
      padding: const EdgeInsets.all(AppDimens.p12),
      children: [
        if (preferences.hasError)
          AppStatusBanner(
            icon: AppIcons.warning,
            message: l.fitnessLoadFailed,
            onTap: () => ref.invalidate(fitnessPreferencesProvider),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                fitnessExerciseName(context, def),
                style: AppTextTokens.boldTitle(context),
              ),
            ),
            TextButton(
              onPressed: prefs == null || _pinning
                  ? null
                  : () async {
                      setState(() => _pinning = true);
                      final ids = [...prefs.pinnedExerciseIds];
                      pinned ? ids.remove(def.id) : ids.add(def.id);
                      await fitnessRun(context, () async {
                        await ref
                            .read(fitnessActionsProvider)
                            .savePreferences(
                              prefs.copyWith(pinnedExerciseIds: ids),
                            );
                      });
                      if (mounted) setState(() => _pinning = false);
                    },
              child: Text(pinned ? l.fitnessUnpin : l.fitnessPin),
            ),
          ],
        ),
        SectionCard(
          margin: const EdgeInsets.only(
            top: AppDimens.p12,
            bottom: AppDimens.p12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.exerciseDetailMediaSize,
                  ),
                  child: FitnessExerciseMedia(definition: def, animated: true),
                ),
              ),
              const SizedBox(height: AppDimens.p12),
              Text(
                '${l.fitnessEquipment}: ${fitnessCatalogLabel(l, def.equipment, taxonomies: taxonomies, isEquipment: true)}',
              ),
              Text(
                '${l.fitnessBodyPart}: ${fitnessCatalogLabel(l, def.bodyPart, taxonomies: taxonomies)}',
              ),
            ],
          ),
        ),
        if (instructions.isNotEmpty) SectionTitle(title: l.fitnessInstructions),
        for (var i = 0; i < instructions.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
            child: Text('${i + 1}. ${instructions[i]}'),
          ),
        if (complete)
          workouts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AppLoadError(
              message: l.fitnessLoadFailed,
              onRetry: () =>
                  ref.invalidate(fitnessExerciseHistoryProvider(historyQuery)),
            ),
            data: (all) => Column(
              children: [
                _history(context, def, all),
                if (all.length >= _historyLimit)
                  TextButton(
                    onPressed: _loadingMore ? null : _loadMore,
                    child: Text(l.fitnessShowMore),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _history(
    BuildContext context,
    FitnessExerciseDefinition def,
    List<FitnessWorkout> all,
  ) {
    final l = AppLocalizations.of(context);
    final now = all.any((w) => w.restTimer != null)
        ? ref.watch(fitnessClockProvider).value ?? DateTime.now()
        : DateTime.now();
    final history = fitnessExerciseHistory(all, def.id, now: now);
    if (history.isEmpty) {
      return Column(
        children: [
          SectionTitle(
            title: l.fitnessExerciseHistory,
            padding: const EdgeInsets.fromLTRB(
              AppDimens.p4,
              0,
              AppDimens.p4,
              AppDimens.p12,
            ),
          ),
          AppEmpty(text: l.fitnessNoExerciseHistory),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(
          title: l.fitnessExerciseHistory,
          padding: const EdgeInsets.fromLTRB(
            AppDimens.p4,
            0,
            AppDimens.p4,
            AppDimens.p12,
          ),
        ),
        for (final w in history)
          SectionCard(
            margin: const EdgeInsets.only(bottom: AppDimens.p12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () => openTrackedFitnessWorkout(context, w.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                    child: Wrap(
                      spacing: AppDimens.p8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(w.name, style: AppTextTokens.strongTitle(context)),
                        Text(
                          fitnessWorkoutDate(w),
                          style: AppTextTokens.dateSecondary(context),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final e in w.exercises.where(
                  (e) => e.exerciseId == def.id,
                ))
                  for (final (index, set) in e.sets.indexed)
                    if (set.completed)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppDimens.p4,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '${index + 1}. ${set.weightLeft == null ? '${set.weight ?? '—'}kg' : l.fitnessSideWeightValue(set.weightLeft!, set.weightRight!)} x ${set.reps ?? '—'}${l.fitnessRepUnit}',
                              ),
                            ),
                            const SizedBox(width: AppDimens.p8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'break ${[for (final seconds in set.restDurationsSeconds) '${seconds}s', if (w.restTimer?.exerciseId == e.id && w.restTimer?.setId == set.id) l.fitnessRestInProgress else if (set.restDurationsSeconds.isEmpty) l.fitnessRestNotRecorded].join(' / ')}',
                                textAlign: TextAlign.right,
                                style: AppTextTokens.body(context).copyWith(
                                  color: AppTokens.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
      ],
    );
  }
}
