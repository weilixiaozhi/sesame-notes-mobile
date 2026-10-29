import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/logger_service.dart';
import '../../../core/storage/shared_preferences_provider.dart';
import '../../../data/models/app_banner.dart';
import '../../../data/models/fitness_library.dart';
import '../../../data/repositories/fitness_library_repository.dart';
import '../../../infrastructure/api/api_client_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/route_consts.dart';
import '../../../shared/providers/fitness_library_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../application/fitness_actions.dart';

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
    var library = await ref.read(fitnessLibraryProvider.future);
    if (!_contains(library, planTarget, id)) {
      // 新配置可能先于本机内容库缓存生效，只在缺失目标时主动补齐官方库。
      final preferences = await ref.read(sharedPreferencesProvider.future);
      final repository = FitnessLibraryRepository(
        dio: ref.read(apiClientProvider).dio,
        preferences: preferences,
      );
      if (await repository.refresh()) {
        ref.invalidate(fitnessLibraryProvider);
        library = await ref.read(fitnessLibraryProvider.future);
      }
    }
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
      await context.pushNamed(Routes.fitnessPlanEdit, extra: draft);
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

/// 查找明确的官方身份，不使用名称或其他业务字段推断目标。
bool _contains(FitnessLibrary library, bool plan, String id) => plan
    ? library.plans.any((value) => value.id == id)
    : library.templates.any((value) => value.id == id);
