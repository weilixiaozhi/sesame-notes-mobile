import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/shared/widgets/capsule_switcher.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 记账头部与分摊编辑页共用紧凑三态选择，页面决定当前方式与可用状态。
class AaModeToggle extends StatelessWidget {
  /// 三种方式始终可见，点击直接回传所选方式。
  const AaModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
    this.toggleKey,
    this.enabled = true,
  });

  final AaMode mode;
  final ValueChanged<AaMode> onChanged;
  final Key? toggleKey;
  final bool enabled;

  /// 三种方式沿用公共胶囊的紧凑尺寸、圆角和文字规格。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IntrinsicWidth(
      key: toggleKey,
      child: CapsuleSwitcher<AaMode>(
        compact: true,
        selectedValue: mode,
        selectedBackgroundColor: AppTokens.primary(context),
        options: [
          CapsuleOption(value: AaMode.perPerson, label: l.aaModePerPerson),
          CapsuleOption(value: AaMode.noSplit, label: l.aaModeNoSplit),
          CapsuleOption(value: AaMode.custom, label: l.aaModeCustom),
        ],
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
