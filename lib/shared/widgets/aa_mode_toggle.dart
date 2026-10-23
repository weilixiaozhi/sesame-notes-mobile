import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_statistics_service.dart' show AaMode;
import 'package:sesame_notes/shared/widgets/capsule_switcher.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 记账头部与分摊编辑页共用三态选择，页面决定紧凑度与可用状态。
class AaModeToggle extends StatelessWidget {
  /// 三种方式始终可见，点击直接回传所选方式。
  const AaModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
    this.toggleKey,
    this.compact = true,
    this.enabled = true,
  });

  final AaMode mode;
  final ValueChanged<AaMode> onChanged;
  final Key? toggleKey;
  final bool compact, enabled;

  /// 头部使用足够高度的操作段，分摊页沿用紧凑布局。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IntrinsicWidth(
      key: toggleKey,
      child: CapsuleSwitcher<AaMode>(
        compact: compact,
        height: kMinInteractiveDimension + AppDimens.p8,
        selectedValue: mode,
        selectedBackgroundColor: AppTokens.primary(context),
        borderRadius: compact
            ? null
            : BorderRadius.circular(AppTokens.inputRadius(context)),
        segmentBorderRadius: compact
            ? null
            : BorderRadius.circular(AppTokens.modeSegmentRadius(context)),
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
