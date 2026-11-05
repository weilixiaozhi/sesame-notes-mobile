import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../application/fitness_providers.dart';
import '../application/fitness_actions.dart';
import 'widgets/fitness_plan_widgets.dart';
import 'widgets/fitness_widgets.dart';

/// 个人计划详情只读展示完整周期，编辑通过独立流程确认保存。
class FitnessPlanDetailPage extends ConsumerWidget {
  /// 页面装配由路由注入，详情本身只负责加载与可用状态。
  const FitnessPlanDetailPage({
    super.key,
    required this.planId,
    required this.editorBuilder,
  });
  final String planId;
  final Widget Function(FitnessPlan plan, PrivateBookTarget target)
  editorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final plans = ref.watch(fitnessPlansProvider);
    final target = ref.watch(fitnessActionsProvider).target;
    final plan = plans.isLoading
        ? null
        : plans.value?.where((p) => p.id == planId).firstOrNull;
    if (plan != null) {
      final pending = plan.pendingSchedule;
      final display = pending == null
          ? plan
          : plan.copyWith(cycleDays: pending.cycleDays, days: pending.days);
      return Scaffold(
        body: Column(
          children: [
            PrimaryHeader(title: l.fitnessPlanDetailTitle, showBack: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [
                  FitnessPlanSummary(plan: display),
                  const SizedBox(height: AppDimens.p16),
                  Text(
                    plan.status == 'in_progress'
                        ? l.fitnessActive
                        : l.fitnessClosed,
                    style: AppTextTokens.body(context),
                  ),
                  if (plan.startDate != null) ...[
                    const SizedBox(height: AppDimens.p8),
                    Text(
                      '${l.fitnessStartDate} · ${plan.startDate}',
                      style: AppTextTokens.caption(context),
                    ),
                  ],
                  if (pending != null) ...[
                    const SizedBox(height: AppDimens.p12),
                    Text(
                      l.fitnessPlanPendingChange,
                      style: AppTextTokens.caption(context),
                    ),
                  ],
                  const SizedBox(height: AppDimens.p20),
                  Text(
                    l.fitnessPlanCompleteCycle,
                    style: AppTextTokens.strongTitle(context),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  FitnessPlanDayList(days: display.days),
                ],
              ),
            ),
            AppEditorFooter(
              label: l.fitnessPlanEditTitle,
              onPressed: () => fitnessRun(context, () async {
                if (!matchesPrivateBookTarget(
                  target,
                  ref.read(fitnessActionsProvider).target,
                )) {
                  throw StateError('FITNESS_TARGET_CHANGED');
                }
                await Navigator.of(context).push<bool>(
                  appPageRoute<bool>(
                    builder: (_) => editorBuilder(plan, target),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l.fitnessPlanDetailTitle, showBack: true),
          Expanded(
            child: plans.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessPlansProvider),
              ),
              data: (_) => AppEmpty(text: l.fitnessNoData),
            ),
          ),
        ],
      ),
    );
  }
}
