import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import '../../application/fitness_providers.dart';
import 'fitness_rest_settings.dart';

class FitnessSettingsSection extends ConsumerWidget {
  const FitnessSettingsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      child: ref
          .watch(fitnessPreferencesProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AppLoadError(
              padding: EdgeInsets.zero,
              message: l.fitnessLoadFailed,
              onRetry: () => ref.invalidate(fitnessPreferencesProvider),
            ),
            data: (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppListTile(
                  leading: AppIcons.fitness,
                  title: l.fitnessExercises,
                  titleMaxLines: null,
                  onTap: () => context.pushNamed(
                    Routes.fitnessExercises,
                    extra: 'browse',
                  ),
                ),
                AppTokens.cardDivider(context),
                AppListTile(
                  leading: AppIcons.restDuration,
                  title: l.fitnessDefaultRest,
                  titleMaxLines: null,
                  onTap: () => showFitnessDefaultRestSettings(context, ref),
                ),
              ],
            ),
          ),
    );
  }
}
