import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/amount_keypad.dart';
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 绑定实际输入框，键盘只编辑当前字段，不另外保存训练数据。
class FitnessKeyboardTarget {
  const FitnessKeyboardTarget({
    required this.id,
    required this.exerciseId,
    required this.text,
    required this.focus,
    required this.context,
    required this.decimal,
    required this.onChanged,
    required this.onAddSet,
    required this.onFillAbove,
    required this.onFillBelow,
    required this.onNext,
  });
  final String id, exerciseId;
  final TextEditingController text;
  final FocusNode focus;
  final BuildContext context;
  final bool decimal;
  final ValueChanged<String> onChanged, onAddSet, onFillAbove, onFillBelow;
  final VoidCallback onNext;
}

class FitnessKeyboardController extends ChangeNotifier {
  final _targets = <String, FitnessKeyboardTarget>{};
  FitnessKeyboardTarget? _active;
  String? _pendingId, _pendingExercise;
  TextEditingValue? _previous;
  bool _disposed = false;
  bool get isOpen => _active != null || _pendingId != null;
  String? get exerciseId => _pendingExercise ?? _active?.exerciseId;
  String? get activeId => _pendingId ?? _active?.id;
  bool get decimal => _active?.decimal ?? false;
  bool isActive(FitnessKeyboardTarget target) => identical(_active, target);

  void register(FitnessKeyboardTarget target) {
    _targets[target.id] = target;
    if (_pendingId == target.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed &&
            _pendingId == target.id &&
            _targets[target.id] == target) {
          activate(target);
        }
      });
    }
  }

  void unregister(FitnessKeyboardTarget target) {
    if (_targets[target.id] == target) _targets.remove(target.id);
    // 重排时同身份的新输入框可能先挂载，旧焦点仍必须释放。
    if (_active == target) {
      _active = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    }
  }

  void activate(FitnessKeyboardTarget target) {
    if (_disposed || _targets[target.id] != target) return;
    if (isActive(target) && _pendingId == null) return;
    _normalize(_active);
    _active = target;
    _pendingId = _pendingExercise = null;
    _previous = null;
    target.focus.requestFocus();
    target.text.selection = TextSelection(
      baseOffset: 0,
      extentOffset: target.text.text.length,
    );
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed && isActive(target) && target.context.mounted) {
        Scrollable.ensureVisible(
          target.context,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

  void release(FitnessKeyboardTarget target) {
    if (isActive(target) && _pendingId == null) close();
  }

  void close() {
    final target = _active;
    _active = null;
    _pendingId = _pendingExercise = null;
    _normalize(target);
    target?.focus.unfocus();
    if (!_disposed) notifyListeners();
  }

  void _normalize(FitnessKeyboardTarget? target) {
    if (target != null && target.text.text.endsWith('.')) {
      final normalized = value(target.text.text);
      target.text.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
  }

  /// 先把当前末行滚入视口，下一动作进入 Sliver 缓存后展开并聚焦。
  void focusNext(String id, String nextExercise) {
    final previous = _active;
    _pendingId = id;
    _pendingExercise = nextExercise;
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_disposed || _pendingId != id) return;
      if (previous != null && previous.context.mounted) {
        await Scrollable.ensureVisible(previous.context, alignment: 0);
      }
      if (_disposed || _pendingId != id) return;
      final next = _targets[id];
      if (next != null) activate(next);
    });
  }

  static String value(String raw) =>
      raw.endsWith('.') ? raw.substring(0, raw.length - 1) : raw;
  void _write(TextEditingValue next) {
    final target = _active;
    if (target == null) return;
    target.text.value = next;
    target.onChanged(value(next.text));
  }

  void append(String digit) {
    final target = _active;
    if (target == null || digit == '.' && !target.decimal) return;
    final before = target.text.value;
    _previous = before;
    final selection = before.selection.isValid
        ? before.selection
        : TextSelection.collapsed(offset: before.text.length);
    var raw = before.text.replaceRange(selection.start, selection.end, digit);
    final rawLength = raw.length;
    if (raw.startsWith('.')) raw = '0$raw';
    raw = raw.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (!RegExp(
      target.decimal ? r'^\d{0,18}(\.\d{0,10})?$' : r'^\d{0,10}$',
    ).hasMatch(raw)) {
      return;
    }
    if (!target.decimal &&
        raw.isNotEmpty &&
        (int.tryParse(raw) ?? 0) > FitnessDefaults.maxInteger) {
      return;
    }
    _write(
      TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(
          offset: (selection.start + digit.length + raw.length - rawLength)
              .clamp(0, raw.length),
        ),
      ),
    );
  }

  void backspace() {
    final target = _active;
    if (target == null) return;
    final before = target.text.value;
    final selection = before.selection.isValid
        ? before.selection
        : TextSelection.collapsed(offset: before.text.length);
    final start = selection.isCollapsed
        ? (selection.start - 1).clamp(0, before.text.length)
        : selection.start;
    final raw = before.text.replaceRange(start, selection.end, '');
    _previous = before;
    _write(
      TextEditingValue(
        text: raw,
        selection: TextSelection.collapsed(offset: start),
      ),
    );
  }

  void clear() => _write(
    const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    ),
  );
  void rollback() {
    if (_previous != null) _write(_previous!);
  }

  void action(String action) {
    final target = _active;
    if (target == null) return;
    final raw = value(target.text.text);
    final reps = int.tryParse(raw);
    final valid =
        raw.isEmpty ||
        (target.decimal
            ? fitnessValidWeight(raw)
            : reps != null && reps > 0 && reps <= FitnessDefaults.maxInteger);
    if (!valid) {
      showToast(
        target.context,
        AppLocalizations.of(target.context).fitnessInvalidSet,
      );
      return;
    }
    switch (action) {
      case 'add':
        target.onAddSet(raw);
      case 'above':
        target.onFillAbove(raw);
      case 'below':
        target.onFillBelow(raw);
      case 'next':
        target.onNext();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _targets.clear();
    _active = null;
    super.dispose();
  }
}

class FitnessSetKeyboard extends StatelessWidget {
  const FitnessSetKeyboard({super.key, required this.controller});
  final FitnessKeyboardController controller;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextFieldTapRegion(
      child: ExcludeFocus(
        child: Material(
          color: AppTokens.keypadBackground(context),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p8,
                AppDimens.p8,
                AppDimens.p8,
                AppDimens.p40,
              ),
              child: SizedBox(
                height:
                    AppDimens.actionButtonMinHeight * 4 +
                    KeypadLayout.rowGap * 3,
                child: AmountKeypad(
                  onAppend: controller.append,
                  onBackspace: controller.backspace,
                  onClear: controller.clear,
                  onRollback: controller.rollback,
                  allowDecimal: controller.decimal,
                  onSubmit: controller.close,
                  actions: [
                    (
                      label: l.fitnessKeypadAddSet,
                      subtitle: null,
                      onPressed: () => controller.action('add'),
                    ),
                    (
                      label: l.fitnessFillSets,
                      subtitle: l.fitnessFillAbove,
                      onPressed: () => controller.action('above'),
                    ),
                    (
                      label: l.fitnessFillSets,
                      subtitle: l.fitnessFillBelow,
                      onPressed: () => controller.action('below'),
                    ),
                    (
                      label: l.fitnessNextInput,
                      subtitle: null,
                      onPressed: () => controller.action('next'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
