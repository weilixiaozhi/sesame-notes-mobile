import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/fitness_library.dart';
import '../../../l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import '../../../shared/providers/fitness_library_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';
import 'fitness_official_plan_detail_page.dart';
import 'widgets/fitness_home_cards.dart';
import 'widgets/fitness_plan_widgets.dart';

/// 官方计划库只展示周期内容，进入详情后再调整使用。
class FitnessPlanLibraryPage extends ConsumerWidget {
  const FitnessPlanLibraryPage({super.key});

  /// 构建官方计划卡片列表。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
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
                    padding: const EdgeInsets.all(AppDimens.p16),
                    itemCount: library.plans.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.p12),
                          child: Text(
                            l.fitnessPlanChooseTitle,
                            style: AppTextTokens.display1(context),
                          ),
                        );
                      }
                      final plan = library.plans[index - 1];
                      final preview = createFitnessPlanImportDraft(
                        library: library,
                        officialPlan: plan,
                        locale: locale,
                        startDate: DateTime.now(),
                      ).plan;
                      return FitnessPlanLibraryTile(
                        plan: preview,
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

/// 进入官方计划详情时固定当前训练空间，编排保存时继续校验归属。
Future<void> _openPlan(
  BuildContext context,
  WidgetRef ref,
  FitnessLibrary library,
  OfficialFitnessPlan plan,
) async {
  try {
    final draft = createFitnessPlanImportDraft(
      library: library,
      officialPlan: plan,
      locale: Localizations.localeOf(context),
      startDate: DateTime.now(),
      target: ref.read(fitnessActionsProvider).target,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FitnessOfficialPlanDetailPage(importDraft: draft),
      ),
    );
  } catch (error, stackTrace) {
    logger.error('FitnessPlanLibrary', '打开官方计划详情失败', error, stackTrace);
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }
}
