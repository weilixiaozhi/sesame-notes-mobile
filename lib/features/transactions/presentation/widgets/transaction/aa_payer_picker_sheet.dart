import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/aa_participant_avatar.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';

/// 支出人单选 Bottom Sheet。
///
/// 点击某行即返回该参与人标识;取消返回 null。
/// 参与人标识统一使用账本成员 UUID。
Future<String?> showAaPayerPickerSheet(
  BuildContext context, {
  required String ledgerId,
  required List<AaParticipantOption> options,
  String? selectedId,
}) {
  return showAppSheet<String>(
    context: context,
    child: AppSheet(
      title: AppLocalizations.of(context).aaPayer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            AppRadioTile(
              title: o.name,
              titleMaxLines: 1,
              selected: o.id == selectedId,
              leading: AaParticipantAvatar(
                ledgerId: ledgerId,
                participantId: o.id,
                isSelf: o.isSelf,
                size: AppDimens.icon28,
              ),
              onTap: () => Navigator.of(context).pop(o.id),
            ),
        ],
      ),
    ),
  );
}
