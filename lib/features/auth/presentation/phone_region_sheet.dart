import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';

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

/// 区号选择复用公共弹层和单选行，保留点击即返回与显式取消。
Future<PhoneRegion?> showPhoneRegionSheet(
  BuildContext context, {
  PhoneRegion selected = PhoneRegion.defaultRegion,
}) => showAppSheet<PhoneRegion>(
  context: context,
  child: Builder(
    builder: (context) => AppSheet(
      title: AppLocalizations.of(context).authRegionSheetTitle,
      footer: TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(AppLocalizations.of(context).authRegionCancel),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final region in PhoneRegion.common)
            AppRadioTile(
              title: region.label,
              subtitle: Text(region.code),
              selected: region.code == selected.code,
              onTap: () => Navigator.of(context).pop(region),
            ),
        ],
      ),
    ),
  ),
);
