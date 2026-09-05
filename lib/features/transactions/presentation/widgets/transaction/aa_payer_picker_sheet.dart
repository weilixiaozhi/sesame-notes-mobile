import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/aa_participant_avatar.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/me_suffix.dart';

/// 支出人单选 Bottom Sheet。
///
/// 点击某行即返回该参与人标识;取消返回 null。
/// 参与人标识口径:真实成员 userId,虚拟用户 syncId。
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
            _AaOptionRow(
              ledgerId: ledgerId,
              option: o,
              checked: o.id == selectedId,
              onTap: () => Navigator.of(context).pop(o.id),
            ),
        ],
      ),
    ),
  );
}

/// 参与人选项行:头像 + 显示名 + 虚拟用户徽标 + 选中勾。
///
/// 支出人单选复用此行展示选中态。
class _AaOptionRow extends ConsumerWidget {
  const _AaOptionRow({
    required this.ledgerId,
    required this.option,
    required this.checked,
    required this.onTap,
  });

  /// 所属账本 id(供参与人头像统一解析)。
  final String ledgerId;

  final AaParticipantOption option;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radius12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
        child: Row(
          children: [
            // 参与人头像统一走 AaParticipantAvatar:
            // 本人云头像缓存、真实成员磁盘缓存、虚拟用户全局默认头像资产。
            AaParticipantAvatar(
              ledgerId: ledgerId,
              participantId: option.id,
              isSelf: option.isSelf,
              size: AppDimens.icon28,
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      option.name,
                      style: AppTextTokens.title(
                        context,
                      ).copyWith(color: AppTokens.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 本人「(我)」后缀统一走共享 MeSuffix,与成员管理样式一致。
                  if (option.isSelf) const MeSuffix(),
                ],
              ),
            ),
            if (checked)
              Icon(AppIcons.check, size: AppDimens.icon16, color: primary),
          ],
        ),
      ),
    );
  }
}
