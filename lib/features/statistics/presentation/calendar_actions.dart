import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_navigation.dart';
import 'package:sesame_notes/features/memos/presentation/memo_navigation.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet_entry.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/default_book_actions_provider.dart';
import 'package:sesame_notes/shared/widgets/app_action_grid.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 所有日历入口使用相同的五项添加动作，业务编辑器继续负责固定目标与保存。
Future<void> openCalendarActions(
  BuildContext context,
  WidgetRef ref,
  DateTime date,
) async {
  final l = AppLocalizations.of(context);
  try {
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'calendar',
          action: ProductAction.calendarCreateClick,
        );
    final action = await showAppSheet<String>(
      context: context,
      child: AppSheet(
        title: l.commonAdd,
        child: SingleChildScrollView(
          child: AppActionGrid<String>(
            actions: [
              (value: 'transaction', icon: AppIcons.money, label: l.tabHome),
              (
                value: 'day',
                icon: AppIcons.calendar,
                label: l.calendarAnniversary,
              ),
              (value: 'memo', icon: AppIcons.edit, label: l.calendarNote),
              (
                value: 'credential',
                icon: AppIcons.lock,
                label: l.calendarCredential,
              ),
              (
                value: 'fitness',
                icon: AppIcons.fitness,
                label: l.calendarTraining,
              ),
            ],
            onSelected: (value) => Navigator.pop(context, value),
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    switch (action) {
      case 'transaction':
        await showTransactionEditorSheet(
          context,
          initialDate: DateTime(date.year, date.month, date.day, 12),
        );
      case 'day':
        await openDayEditor(
          context,
          ref,
          initialDate: DateOnly.fromDateTime(date),
        );
      case 'memo':
        await openMemoEditor(context, ref);
      case 'credential':
        await openMemoCredentialEditor(context, ref);
      case 'fitness':
        // 首次添加仍由既有用例初始化默认空间，取消弹层不会生成空本。
        if (ref.read(currentFitnessSpaceIdProvider).value == null) {
          final created = await ref
              .read(defaultBookProvisionerProvider)
              .ensureDefault(AppMode.fitness, l);
          if (created == null) {
            if (!context.mounted) return;
            final id = await context.pushNamed<String>(Routes.fitnessSpaceEdit);
            if (id == null || !context.mounted) return;
          }
        }
        if (context.mounted) {
          await fitnessCreateBlank(context, ref, initialDate: date);
        }
    }
  } catch (error, stack) {
    logger.error('UnifiedCalendar', '打开添加入口失败', error, stack);
    if (context.mounted) showToast(context, l.commonOperationFailed);
  }
}
