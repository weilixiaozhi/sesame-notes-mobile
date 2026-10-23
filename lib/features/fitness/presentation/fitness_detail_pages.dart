import 'package:sesame_notes/data/models/fitness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import '../application/fitness_providers.dart';

/// 详情与新建共用同一编排页面，入口只负责按身份读取计划。
class FitnessPlanDetailPage extends ConsumerWidget {
  /// 页面装配由路由注入，详情本身只负责加载与可用状态。
  const FitnessPlanDetailPage({
    super.key,
    required this.planId,
    required this.editorBuilder,
  });
  final String planId;
  final Widget Function(FitnessPlan plan) editorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final plans = ref.watch(fitnessPlansProvider);
    final plan = plans.value?.where((p) => p.id == planId).firstOrNull;
    if (plan != null) {
      return editorBuilder(plan);
    }
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l.fitnessPlans, showBack: true),
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
