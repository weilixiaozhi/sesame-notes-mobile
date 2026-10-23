import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_space_actions.dart';
import 'package:sesame_notes/shared/presentation/private_book_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/private_book.dart';
import '../../../l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import '../../../shared/providers/fitness_space_provider.dart';
import '../../../shared/providers/sync_providers.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../shared/widgets/book_overview_card.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';

/// 页面只装配已有本子组件，选择与存储操作交给全局入口。
class FitnessSpacesPage extends ConsumerWidget {
  const FitnessSpacesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final selected = ref.watch(currentFitnessSpaceIdProvider).value;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: l.fitnessSpacesManagement,
            showBack: true,
            actions: [
              HeaderIconAction(
                icon: AppIcons.add,
                tooltip: l.fitnessCreateSpace,
                onPressed: () => context.pushNamed(Routes.fitnessSpaceEdit),
              ),
            ],
          ),
          Expanded(
            child: ref
                .watch(fitnessSpacesProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    message: l.commonOperationFailed,
                    onRetry: () => ref.invalidate(fitnessSpacesProvider),
                  ),
                  data: (books) => RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(syncCoordinatorProvider).refreshData();
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimens.p8,
                      ),
                      children: [
                        for (final storage in [
                          if (books.any((b) => b.isCloud)) 'cloud',
                          if (books.any((b) => !b.isCloud)) 'local',
                        ]) ...[
                          BookSectionTitle(
                            title: storage == 'cloud'
                                ? l.fitnessCloudSpaces
                                : l.fitnessLocalSpaces,
                          ),
                          for (final book in books.where(
                            (b) => b.storageMode == storage,
                          ))
                            BookOverviewCard(
                              title: book.name,
                              selected: book.id == selected,
                              compact: true,
                              onTap: () async {
                                final changed = book.id != selected;
                                final completed = ref
                                    .read(productAnalyticsControllerProvider)
                                    .captureCompletion(
                                      pageId: 'fitness.spaces',
                                      context: ref
                                          .read(
                                            productAnalyticsControllerProvider,
                                          )
                                          .captureContext(),
                                    );
                                try {
                                  await ref
                                      .read(
                                        currentFitnessSpaceIdProvider.notifier,
                                      )
                                      .select(book.id);
                                  if (changed) {
                                    completed(ProductAction.fitnessSpaceSelect);
                                  }
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  }
                                } catch (_) {
                                  if (context.mounted) {
                                    showToast(context, l.commonOperationFailed);
                                  }
                                }
                              },
                              onEdit: () => context.pushNamed(
                                Routes.fitnessSpaceEdit,
                                extra: book,
                              ),
                              editTooltip: l.fitnessEdit,
                              notice: book.isStale || !book.isComplete
                                  ? Text(l.privateBookDownloadRequired)
                                  : null,
                              child: Text(
                                l.fitnessRecordCount(book.entityCount),
                              ),
                            ),
                        ],
                        if (books.isEmpty)
                          BookSectionEmpty(text: l.fitnessNoSpaces),
                      ],
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class FitnessSpaceEditPage extends ConsumerWidget {
  const FitnessSpaceEditPage({super.key, this.space});
  final FitnessSpace? space;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return PrivateBookEditor(
      actions: ref.watch(fitnessSpaceActionsProvider),
      book: space,
      title: l.fitnessCreateSpace,
      nameLabel: l.fitnessSpaceName,
      selection: () => ref.read(currentFitnessSpaceIdProvider.notifier),
      deleteMessage: l.fitnessDeleteSpaceMessage,
    );
  }
}
