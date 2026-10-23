import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/features/settings/application/day_reminder_choices.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';

/// 每日提醒多选弹窗，确认前只修改本地草稿，取消时不改变已保存设置。
class DayReminderSelectionDialog extends ConsumerStatefulWidget {
  /// 接收打开时的账号和选中项，避免跨账号提交旧选择。
  const DayReminderSelectionDialog({
    super.key,
    required this.selectedIds,
    required this.accountId,
  });

  final Set<String> selectedIds;
  final String? accountId;

  /// 创建独立的多选草稿。
  @override
  ConsumerState<DayReminderSelectionDialog> createState() =>
      _DayReminderSelectionDialogState();
}

class _DayReminderSelectionDialogState
    extends ConsumerState<DayReminderSelectionDialog> {
  late final Set<String> _selected = {...widget.selectedIds};

  /// 重试目录及已知本的记录读取，保留用户当前勾选。
  void _retry() {
    final books = ref.read(dayBooksProvider).value;
    for (final book in books ?? []) {
      ref.invalidate(dayEventsProvider(book.id));
    }
    ref.invalidate(dayBooksProvider);
    ref.invalidate(dayReminderChoicesProvider);
  }

  /// 加载与失败状态不允许确认；删除或失去权限的记录不进入保存结果。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sameAccount = ref.watch(currentAccountIdProvider) == widget.accountId;
    final state = ref.watch(dayReminderChoicesProvider);
    final ready = sameAccount && !state.isLoading && !state.hasError;
    final choices = ready ? state.requireValue : <DayReminderChoice>[];
    final selected = {
      for (final choice in choices)
        if (_selected.contains(choice.event.id)) choice.event.id,
    };
    return AppContentDialog(
      title: l.reminderDaysDailySelect,
      content: !sameAccount
          ? Text(l.reminderDaysDailyAccountChanged)
          : state.when(
              skipLoadingOnRefresh: false,
              skipLoadingOnReload: false,
              loading: () => const Padding(
                padding: EdgeInsets.all(AppDimens.p20),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => AppLoadError(
                message: l.reminderDaysDailyLoadFailed,
                onRetry: _retry,
                padding: EdgeInsets.zero,
              ),
              data: (values) => values.isEmpty
                  ? AppEmpty(
                      text: l.reminderDaysDailyEmpty,
                      padding: EdgeInsets.zero,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.reminderDaysDailyChooseOne,
                          style: AppTextTokens.label(context),
                        ),
                        const SizedBox(height: AppDimens.p8),
                        for (final choice in values)
                          CheckboxListTile(
                            key: ValueKey('daily-day-${choice.event.id}'),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(choice.event.definition.name),
                            subtitle: Text(
                              [
                                choice.bookName,
                                if (choice.event.definition.event != null)
                                  dayDateLabel(
                                    l,
                                    choice.event.definition.event!,
                                  ),
                              ].join(' · '),
                            ),
                            value: _selected.contains(choice.event.id),
                            onChanged: (value) => setState(() {
                              if (value == true) {
                                _selected.add(choice.event.id);
                              } else {
                                _selected.remove(choice.event.id);
                              }
                            }),
                          ),
                      ],
                    ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.commonCancel),
        ),
        TextButton(
          key: const ValueKey('daily-days-confirm'),
          onPressed: ready && selected.isNotEmpty
              ? () => Navigator.of(context).pop(selected)
              : null,
          child: Text(l.commonConfirm),
        ),
      ],
    );
  }
}
