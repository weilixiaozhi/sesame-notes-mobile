import 'widgets/fitness_home_cards.dart';
import 'widgets/fitness_widgets.dart' show fitnessRun;
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/shared/widgets/app_banner_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import '../application/fitness_providers.dart';

class FitnessTemplatesPage extends ConsumerWidget {
  const FitnessTemplatesPage({super.key});

  /// 模板管理直接复用首页卡片，并显式开启复制和删除菜单。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final templates = ref.watch(fitnessTemplatesProvider);
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l.fitnessMyTemplates,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.add,
                tooltip: l.fitnessNewTemplate,
                onPressed: () => context.pushNamed(Routes.fitnessTemplateEdit),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.p8,
              AppDimens.p8,
              AppDimens.p8,
              0,
            ),
            child: AppBannerEntry(
              key: const ValueKey('fitness-template-library-entry'),
              slot: AppBannerSlot.fitnessTemplateLibrary,
              onOpen: (route) => fitnessRun(context, () async {
                await context.pushNamed(route);
              }),
            ),
          ),
          Expanded(
            child: templates.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessTemplatesProvider),
              ),
              data: (all) {
                return all.isEmpty
                    ? AppEmpty(text: l.fitnessNoData)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimens.p12),
                        itemCount: all.length,
                        itemBuilder: (context, index) =>
                            FitnessHomeTemplateCard(
                              template: all[index],
                              showMenu: true,
                            ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
