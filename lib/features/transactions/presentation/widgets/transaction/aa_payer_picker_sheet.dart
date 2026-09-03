import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/me_suffix.dart';
import 'package:sesame_notes/shared/widgets/member_avatar.dart';
import 'package:sesame_notes/shared/widgets/person_avatar.dart';

/// 支出人单选 Bottom Sheet。
///
/// 点击某行即返回该参与人标识;取消返回 null。
/// 参与人标识口径:真实成员 userId,虚拟用户 syncId。
Future<String?> showAaPayerPickerSheet(
  BuildContext context, {
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
  final AaParticipantOption option;
  final bool checked;
  final VoidCallback onTap;

  const _AaOptionRow({
    required this.option,
    required this.checked,
    required this.onTap,
  });

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
            // 参与人头像位:虚拟用户 person 占位;真实成员走成员头像缓存
            // (有云头像显示云头像,未上传头像回退正式默认头像)。
            if (option.isVirtual)
              const PersonAvatar(
                size: AppDimens.icon28,
                iconSize: AppDimens.icon16,
              )
            else
              MemberAvatar(
                userId: option.id,
                version: 0,
                hasAvatar: true,
                size: AppDimens.icon28,
                iconSize: AppDimens.icon16,
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
