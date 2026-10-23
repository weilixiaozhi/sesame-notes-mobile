import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 搜索已载入的 IANA 名称，选中值和 UTC 置顶，取消保持原规则不变。
Future<String?> showRecurringTimeZonePicker(
  BuildContext context, {
  required String selected,
}) {
  final names = <String>{'UTC', ...tz.timeZoneDatabase.locations.keys}.toList()
    ..sort();
  names.remove('UTC');
  names.insert(0, 'UTC');
  names.remove(selected);
  if (selected == 'UTC' ||
      tz.timeZoneDatabase.locations.containsKey(selected)) {
    names.insert(0, selected);
  }
  String query = '';
  return showAppSheet<String>(
    context: context,
    child: StatefulBuilder(
      builder: (sheetContext, setSheetState) {
        final l10n = AppLocalizations.of(sheetContext);
        final visible = names
            .where(
              (name) => name.toLowerCase().contains(query.trim().toLowerCase()),
            )
            .toList();
        return SizedBox(
          height: 440,
          child: AppSheet(
            title: l10n.recurringTransactionTimeZone,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: l10n.commonSearch,
                    prefixIcon: const Icon(AppIcons.search),
                  ),
                  onChanged: (value) => setSheetState(() => query = value),
                ),
                const SizedBox(height: AppDimens.p8),
                Expanded(
                  child: ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final name = visible[index];
                      return AppRadioTile(
                        title: name,
                        selected: name == selected,
                        onTap: () => Navigator.of(sheetContext).pop(name),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
