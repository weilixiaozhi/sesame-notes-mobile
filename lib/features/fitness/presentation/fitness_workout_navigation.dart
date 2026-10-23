import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/logging/logger_service.dart';
import '../../../domain/analytics/product_analytics_actions.dart';
import '../../../domain/analytics/product_analytics_context.dart';
import '../../../providers/product_analytics_providers.dart';
import '../../../router/product_analytics_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/route_consts.dart';
import '../../../shared/widgets/toast.dart';

/// 训练重开在真实导航前恢复已知流，页面访问与后续完成属于同一实际操作流。
Future<void> openTrackedFitnessWorkout(
  BuildContext context,
  String workoutId,
) async {
  try {
    final read = ProviderScope.containerOf(context, listen: false).read;
    final sourcePage = productAnalyticsEntryPage(
      context,
      read,
      fallbackPageId: 'fitness',
    );
    final restored = await read(
      fitnessAnalyticsProvider,
    ).navigationContext(workoutId);
    final scope = restored.flowId == null
        ? beginProductAnalyticsFlowFrom(restored)
        : restored;
    if (!context.mounted) return;
    final current = read(productAnalyticsControllerProvider).currentIdentity();
    if (scope.identity.account != current.account ||
        scope.identity.generation != current.generation) {
      return;
    }
    read(productAnalyticsControllerProvider).trackAction(
      pageId: sourcePage,
      action: ProductAction.fitnessWorkoutOpenClick,
      context: scope,
    );
    await context.pushNamed(
      Routes.fitnessWorkout,
      extra: ProductAnalyticsNavigation(arguments: workoutId, context: scope),
    );
  } catch (error, stackTrace) {
    logger.error(
      'FitnessNavigation',
      '训练详情暂时无法打开',
      error.runtimeType,
      stackTrace,
    );
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
    }
  }
}
