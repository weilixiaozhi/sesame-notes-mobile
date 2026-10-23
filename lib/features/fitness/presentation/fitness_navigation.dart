import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/shared/widgets/app_action_grid.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import 'widgets/fitness_widgets.dart';

/// 按选中日期添加训练，未指定日期时使用今天。
Future<void> fitnessCreateBlank(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initialDate,
}) => fitnessRun(context, () async {
  final analyticsContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  final sourcePage = productAnalyticsEntryPage(
    context,
    ref.read,
    fallbackPageId: 'fitness',
  );
  ref
      .read(productAnalyticsControllerProvider)
      .trackAction(
        pageId: sourcePage,
        action: ProductAction.fitnessWorkoutCreateClick,
        context: analyticsContext,
      );
  final workout = await ref
      .read(fitnessActionsProvider)
      .createBlankWorkout(
        name: AppLocalizations.of(context).calendarTraining,
        scheduledDate: initialDate,
      );
  if (context.mounted) {
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: sourcePage,
          action: ProductAction.fitnessWorkoutCreated,
          context: analyticsContext,
        );
    context.pushNamed(
      Routes.fitnessWorkout,
      extra: ProductAnalyticsNavigation(
        arguments: workout.id,
        context: analyticsContext,
      ),
    );
  }
});

/// 新增菜单只负责选择训练、模板与计划入口，持久化结果由对应编辑器统计。
Future<void> openFitnessActions(BuildContext context, WidgetRef ref) async {
  final l = AppLocalizations.of(context);
  if (ref.read(currentFitnessSpaceIdProvider).value == null) {
    // 没有任何空间时由首条训练顺带创建默认空间；只是当前未选中时保持既有建本入口。
    final created = await ref
        .read(defaultBookProvisionerProvider)
        .ensureDefault(AppMode.fitness, l);
    if (created == null) {
      if (!context.mounted) return;
      final id = await context.pushNamed<String>(Routes.fitnessSpaceEdit);
      if (id == null || !context.mounted) return;
    }
  }
  if (!context.mounted) return;
  final action = await showAppSheet<String>(
    context: context,
    child: AppSheet(
      title: l.commonAdd,
      child: SingleChildScrollView(
        child: AppActionGrid<String>(
          actions: [
            (value: 'blank', icon: AppIcons.fitness, label: l.calendarTraining),
            (
              value: 'template',
              icon: AppIcons.folder,
              label: l.calendarTemplate,
            ),
            (value: 'plan', icon: AppIcons.calendar, label: l.calendarPlan),
          ],
          onSelected: (value) => Navigator.pop(context, value),
        ),
      ),
    ),
  );
  if (!context.mounted) return;
  switch (action) {
    case 'blank':
      await fitnessCreateBlank(context, ref);
    case 'template':
      context.pushNamed(Routes.fitnessTemplateEdit);
    case 'plan':
      context.pushNamed(Routes.fitnessPlanEdit);
  }
}
