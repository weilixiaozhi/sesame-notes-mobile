import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/fitness_library.dart';
import '../../../l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import '../../../shared/providers/fitness_library_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/dimens.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_home_cards.dart';

/// 官方计划库：与首页计划卡同版式，点击进入只读的计划确认页。
class FitnessPlanLibraryPage extends ConsumerWidget {
  const FitnessPlanLibraryPage({super.key});

  /// 构建官方计划卡片列表。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    // 保持用户模板订阅存活：计划确认页要按同源副本给出复用选项。
    ref.watch(fitnessTemplatesProvider);
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l.fitnessPlanLibrary, showBack: true),
          Expanded(
            child: ref
                .watch(fitnessLibraryProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    message: l.fitnessLoadFailed,
                    onRetry: () => ref.invalidate(fitnessLibraryProvider),
                  ),
                  data: (library) => ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    itemCount: library.plans.length,
                    itemBuilder: (context, index) {
                      final plan = library.plans[index];
                      return FitnessLibraryPlanCard(
                        name: plan.name.resolve(locale),
                        plan: plan,
                        onTap: () => _openPlan(context, ref, library, plan),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// 官方模板库：与首页模板卡同版式，点击进入只读的模板详情。
class FitnessTemplateLibraryPage extends ConsumerWidget {
  const FitnessTemplateLibraryPage({super.key});

  /// 构建官方模板卡片列表。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l.fitnessTemplateLibrary, showBack: true),
          Expanded(
            child: ref
                .watch(fitnessLibraryProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    message: l.fitnessLoadFailed,
                    onRetry: () => ref.invalidate(fitnessLibraryProvider),
                  ),
                  data: (library) => ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    itemCount: library.templates.length,
                    itemBuilder: (context, index) {
                      final template = library.templates[index];
                      return FitnessHomeTemplateCard(
                        // 与「我的模板」同一版式：动作名与组数摘要。
                        template: template.toFitnessTemplate(
                          locale,
                          id: template.id,
                        ),
                        onTap: () => context.pushNamed(
                          Routes.fitnessTemplateDetail,
                          extra: template,
                        ),
                      );
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

/// 打开官方计划的只读确认页；模板复用与新建在该页确认，不在列表拦截。
void _openPlan(
  BuildContext context,
  WidgetRef ref,
  FitnessLibrary library,
  OfficialFitnessPlan plan,
) {
  final draft = createFitnessPlanImportDraft(
    library: library,
    officialPlan: plan,
    locale: Localizations.localeOf(context),
    startDate: DateTime.now(),
    target: ref.read(fitnessActionsProvider).target,
  );
  context.pushNamed(Routes.fitnessPlanEdit, extra: draft);
}
