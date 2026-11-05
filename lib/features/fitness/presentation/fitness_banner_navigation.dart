import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/app_banner.dart';
import '../../../data/models/fitness_library.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/route_consts.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/fitness_actions.dart';
import '../application/fitness_library_queries.dart';
import 'fitness_official_plan_detail_page.dart';

/// 横幅直接打开官方条目，继续使用内容库的本地读取、在线刷新和确认页参数。
Future<void> openFitnessBannerContent(
  BuildContext context,
  WidgetRef ref,
  AppBannerTarget target,
  String id,
) async {
  final planTarget = target == AppBannerTarget.officialPlan;
  final fallback = planTarget
      ? Routes.fitnessPlanLibrary
      : Routes.fitnessTemplateLibrary;
  try {
    final draftTarget = planTarget
        ? ref.read(fitnessActionsProvider).target
        : null;
    final library = await ref
        .read(fitnessLibraryQueriesProvider)
        .ensureOfficialContent(id: id, plan: planTarget);
    if (!context.mounted || ModalRoute.isCurrentOf(context) != true) return;
    if (planTarget) {
      if (ref.read(fitnessActionsProvider).target != draftTarget) return;
      final plan = library.plans.where((value) => value.id == id).firstOrNull;
      if (plan == null) throw const FormatException('BANNER_PLAN_UNAVAILABLE');
      final draft = createFitnessPlanImportDraft(
        library: library,
        officialPlan: plan,
        locale: Localizations.localeOf(context),
        startDate: DateTime.now(),
        target: draftTarget!,
      );
      await Navigator.of(context).push<void>(
        appPageRoute<void>(
          builder: (_) => FitnessOfficialPlanDetailPage(importDraft: draft),
        ),
      );
    } else {
      final template = library.templates
          .where((value) => value.id == id)
          .firstOrNull;
      if (template == null) {
        throw const FormatException('BANNER_TEMPLATE_UNAVAILABLE');
      }
      await context.pushNamed(Routes.fitnessTemplateDetail, extra: template);
    }
  } catch (error, stack) {
    logger.error(
      'AppBanner',
      '官方横幅目标暂不可用，打开对应内容库',
      safeErrorSummary(error),
      stack,
    );
    if (!context.mounted || ModalRoute.isCurrentOf(context) != true) return;
    showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
    await context.pushNamed(fallback);
  }
}
