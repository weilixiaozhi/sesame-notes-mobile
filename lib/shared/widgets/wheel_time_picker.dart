import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'app_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'date_wheel_column.dart';
import 'package:sesame_notes/theme/typography.dart';

class WheelTimePicker extends StatefulWidget {
  final TimeOfDay initial;

  const WheelTimePicker({super.key, required this.initial});

  @override
  State<WheelTimePicker> createState() => _WheelTimePickerState();
}

Future<TimeOfDay?> showWheelTimePicker(
  BuildContext context, {
  required TimeOfDay initial,
}) {
  return showAppSheet<TimeOfDay>(
    context: context,
    child: WheelTimePicker(initial: initial),
  );
}

class _WheelTimePickerState extends State<WheelTimePicker> {
  late int hour;
  late int minute;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    hour = widget.initial.hour;
    minute = widget.initial.minute;
    _hourCtrl = FixedExtentScrollController(initialItem: hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: AppLocalizations.of(context).commonSelectTime,
      footer: AppPrimaryButton(
        label: AppLocalizations.of(context).commonOk,
        onPressed: () =>
            Navigator.of(context).pop(TimeOfDay(hour: hour, minute: minute)),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppWheelColumn(
              labels: List.generate(24, (i) => i.toString().padLeft(2, '0')),
              controller: _hourCtrl,
              onChanged: (i) => setState(() => hour = i),
            ),
          ),
          Text(':', style: AppTextTokens.boldTitle(context)),
          Expanded(
            child: AppWheelColumn(
              labels: List.generate(60, (i) => i.toString().padLeft(2, '0')),
              controller: _minuteCtrl,
              onChanged: (i) => setState(() => minute = i),
            ),
          ),
        ],
      ),
    );
  }
}
