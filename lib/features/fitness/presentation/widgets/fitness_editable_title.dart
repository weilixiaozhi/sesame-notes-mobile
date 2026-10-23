import 'package:flutter/material.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 只管理更名状态；标题与操作区由页面的公共头部参数排布。
class FitnessEditableTitle extends StatefulWidget {
  const FitnessEditableTitle({
    super.key,
    required this.name,
    required this.onSave,
    required this.builder,
    this.enabled = true,
  });
  final String name;
  final Widget Function(
    Widget? editor,
    Widget? titleAction,
    List<Widget> actions,
  )
  builder;
  final Future<bool> Function(String) onSave;
  final bool enabled;
  @override
  State<FitnessEditableTitle> createState() => _FitnessEditableTitleState();
}

class _FitnessEditableTitleState extends State<FitnessEditableTitle> {
  final _text = TextEditingController();
  bool _editing = false, _saving = false, _invalid = false;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _text.text;
    setState(() => _invalid = !fitnessValidName(name));
    if (_invalid) return;
    setState(() => _saving = true);
    try {
      final saved = await widget.onSave(name);
      if (mounted && saved) setState(() => _editing = false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final enabled = widget.enabled && !_saving;
    final edit = HeaderIconAction(
      icon: AppIcons.edit,
      tooltip: l.fitnessEdit,
      onPressed: enabled
          ? () => setState(() {
              _text.text = widget.name;
              _invalid = false;
              _editing = true;
            })
          : null,
    );
    return widget.builder(
      _editing
          ? Builder(
              builder: (context) => TextField(
                controller: _text,
                autofocus: true,
                enabled: enabled,
                style: DefaultTextStyle.of(context).style,
                textAlign:
                    DefaultTextStyle.of(context).textAlign ?? TextAlign.start,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: l.fitnessName,
                  errorText: _invalid ? l.fitnessInvalidForm : null,
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _save(),
              ),
            )
          : null,
      _editing ? null : edit,
      _editing
          ? [
              HeaderIconAction(
                icon: AppIcons.close,
                tooltip: l.commonCancel,
                onPressed: enabled
                    ? () => setState(() => _editing = false)
                    : null,
              ),
              HeaderIconAction(
                icon: AppIcons.check,
                tooltip: l.commonSave,
                onPressed: enabled ? _save : null,
              ),
            ]
          : [],
    );
  }
}
