import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:flutter/cupertino.dart';
import 'app_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'date_wheel_column.dart';

/// 通用滚轮选择器
class WheelPicker<T> extends StatefulWidget {
  final T initial;
  final List<T> items;
  final String Function(T) labelBuilder;
  final String title;

  const WheelPicker({
    super.key,
    required this.initial,
    required this.items,
    required this.labelBuilder,
    required this.title,
  });

  @override
  State<WheelPicker<T>> createState() => _WheelPickerState<T>();
}

class _WheelPickerState<T> extends State<WheelPicker<T>> {
  late T selected;
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    // initial 不在 items 中时修正为列表首项，避免「确定」返回列表外的值；
    // 空列表是调用方配置错误，保持 initial 且靠 CupertinoPicker 空列表兜底，
    // 不在此处崩溃。
    selected = widget.items.contains(widget.initial)
        ? widget.initial
        : (widget.items.isEmpty ? widget.initial : widget.items.first);
    final index = widget.items.indexOf(selected);
    _controller = FixedExtentScrollController(
      initialItem: index >= 0 ? index : 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    return AppSheet(
      title: widget.title,
      footer: AppPrimaryButton(
        label: AppLocalizations.of(context).commonOk,
        onPressed: () => Navigator.pop(context, selected),
      ),
      child: AppWheelColumn(
        labels: items.map(widget.labelBuilder).toList(),
        controller: _controller,
        onChanged: (i) => setState(() => selected = items[i]),
      ),
    );
  }
}

Future<T?> showWheelPicker<T>(
  BuildContext context, {
  required T initial,
  required List<T> items,
  required String Function(T) labelBuilder,
  required String title,
}) {
  return showAppSheet<T>(
    context: context,
    child: WheelPicker<T>(
      initial: initial,
      items: items,
      labelBuilder: labelBuilder,
      title: title,
    ),
  );
}
