import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/shared/widgets/app_banner_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/list_section_header.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../application/fitness_providers.dart';
import 'widgets/fitness_home_cards.dart';
import 'widgets/fitness_widgets.dart';

/// 计划页保留计划库与所有计划的管理入口。
class FitnessPlansPage extends ConsumerWidget {
  const FitnessPlansPage({super.key, this.embedded = false});

  /// 业务壳页签展示列表与查看全部；独立管理路由提供新增和内容库。
  final bool embedded;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final plans = ref.watch(fitnessPlansProvider);
    if (embedded) {
      return Scaffold(body: _embeddedContent(context, ref, plans));
    }
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l.fitnessMyPlans,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.add,
                tooltip: l.fitnessNewPlan,
                onPressed: () => _open(context, Routes.fitnessPlanEdit),
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
              key: const ValueKey('fitness-plan-library-entry'),
              slot: AppBannerSlot.fitnessPlanLibrary,
              onOpen: (route) => _open(context, route),
            ),
          ),
          Expanded(
            child: plans.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => AppLoadError(
                message: l.fitnessLoadFailed,
                onRetry: () => ref.invalidate(fitnessPlansProvider),
              ),
              data: (all) {
                return all.isEmpty
                    ? AppEmpty(text: l.fitnessNoData)
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimens.p12),
                        itemCount: all.length,
                        itemBuilder: (context, index) {
                          final plan = all[index];
                          return FitnessHomePlanCard(
                            plan: plan,
                            // 列表页与首页同一版式，只去掉状态标签。
                            showStatus: false,
                            // 与首页计划卡共用同一套省略号入口。
                            menu: FitnessPlanMenu(plan: plan),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 计划页签同时承接计划与模板管理，独立管理页保留原有返回行为。
  Widget _embeddedContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<FitnessPlan>> plans,
  ) {
    final l = AppLocalizations.of(context);
    final templates = ref.watch(fitnessTemplatesProvider);
    return ListView(
      key: const PageStorageKey('fitness-plans-and-templates'),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.domainPageInset,
        AppDimens.p16,
        AppDimens.domainPageInset,
        AppDimens.domainBottomClearance,
      ),
      children: [
        ListSectionHeader(
          title: l.fitnessMyPlans,
          horizontalPadding: 0,
          trailing: HeaderTextAction(
            key: const ValueKey('fitness-plan-manage-entry'),
            label: l.fitnessViewAll,
            dense: true,
            onPressed: () => _open(context, Routes.fitnessPlans),
          ),
        ),
        ...plans.when<List<Widget>>(
          loading: () => [const Center(child: CircularProgressIndicator())],
          error: (_, _) => [
            AppLoadError(
              message: l.fitnessLoadFailed,
              onRetry: () => ref.invalidate(fitnessPlansProvider),
            ),
          ],
          data: (all) => all.isEmpty
              ? [
                  SectionCard(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: AppEmpty(
                      icon: AppIcons.calendar,
                      text: l.fitnessNoPlans,
                    ),
                  ),
                ]
              : [
                  for (final plan in all)
                    FitnessHomePlanCard(
                      plan: plan,
                      menu: FitnessPlanMenu(plan: plan),
                    ),
                ],
        ),
        const SizedBox(height: AppDimens.p20),
        ListSectionHeader(
          title: l.fitnessMyTemplates,
          horizontalPadding: 0,
          trailing: HeaderTextAction(
            key: const ValueKey('fitness-plan-templates-entry'),
            label: l.fitnessViewAll,
            dense: true,
            onPressed: () => _open(context, Routes.fitnessTemplates),
          ),
        ),
        ...templates.when<List<Widget>>(
          loading: () => [const Center(child: CircularProgressIndicator())],
          error: (_, _) => [
            AppLoadError(
              message: l.fitnessLoadFailed,
              onRetry: () => ref.invalidate(fitnessTemplatesProvider),
            ),
          ],
          data: (all) => all.isEmpty
              ? [
                  SectionCard(
                    margin: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    child: AppEmpty(
                      icon: AppIcons.folder,
                      text: l.fitnessNoTemplates,
                    ),
                  ),
                ]
              : [
                  for (final template in all.take(3))
                    FitnessHomeTemplateCard(template: template, showMenu: true),
                ],
        ),
      ],
    );
  }

  /// 管理入口复用已注册路由，失败由健身共用反馈保持在当前页面。
  Future<void> _open(BuildContext context, String route) =>
      fitnessRun(context, () async {
        await context.pushNamed(route);
      });
}
