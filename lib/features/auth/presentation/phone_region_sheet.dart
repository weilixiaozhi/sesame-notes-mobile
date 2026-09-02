import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 常用区号列表（与 UI 稿冻结；可扩展，但 E.164 校验由服务端兜底）。
class PhoneRegion {
  final String code;
  final String label;

  const PhoneRegion(this.code, this.label);

  static const List<PhoneRegion> common = [
    PhoneRegion('+86', '中国大陆'),
    PhoneRegion('+852', '中国香港'),
    PhoneRegion('+853', '中国澳门'),
    PhoneRegion('+886', '中国台湾'),
    PhoneRegion('+1', '美国 / 加拿大'),
    PhoneRegion('+44', '英国'),
    PhoneRegion('+81', '日本'),
    PhoneRegion('+82', '韩国'),
    PhoneRegion('+65', '新加坡'),
    PhoneRegion('+61', '澳大利亚'),
  ];

  /// 默认选中中国大陆。
  static const PhoneRegion defaultRegion = PhoneRegion('+86', '中国大陆');
}

/// 区号选择 BottomSheet：标题「选择区号」+ 左侧「取消」+ 常用区号列表。
///
/// 设计意图：只提供常用列表（一期冻结 10 个），不提供自定义输入，
/// 与服务端 E.164 校验配合保证格式一致。
Future<PhoneRegion?> showPhoneRegionSheet(
  BuildContext context, {
  PhoneRegion selected = PhoneRegion.defaultRegion,
}) {
  return showAppSheet<PhoneRegion>(
    context: context,
    heightFactor: 0.72,
    child: Builder(
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetGrabHandle(),
            SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(32, 48),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: Text(
                          l10n.authRegionCancel,
                          style: AppTextTokens.body(sheetContext).copyWith(
                            color: AppTokens.textTertiary(sheetContext),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      l10n.authRegionSheetTitle,
                      style: AppTextTokens.strongTitle(sheetContext),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: AppDimens.p20 + AppDimens.p4,
                ),
                itemCount: PhoneRegion.common.length,
                itemBuilder: (context, index) {
                  final region = PhoneRegion.common[index];
                  final isSelected = region.code == selected.code;
                  return Container(
                    height: 52,
                    decoration: BoxDecoration(
                      border: index == PhoneRegion.common.length - 1
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: AppTokens.divider(sheetContext),
                              ),
                            ),
                    ),
                    child: ListTile(
                      minTileHeight: 52,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.p20,
                      ),
                      title: Text(
                        region.label,
                        style: AppTextTokens.title(sheetContext).copyWith(
                          color: isSelected
                              ? AppTokens.primary(sheetContext)
                              : AppTokens.textPrimary(sheetContext),
                          fontWeight: isSelected
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            region.code,
                            style: Theme.of(sheetContext).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTokens.textTertiary(sheetContext),
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: AppDimens.p12),
                            Icon(
                              AppIcons.check,
                              size: AppDimens.icon20,
                              color: AppTokens.primary(sheetContext),
                            ),
                          ],
                        ],
                      ),
                      onTap: () => Navigator.of(sheetContext).pop(region),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
