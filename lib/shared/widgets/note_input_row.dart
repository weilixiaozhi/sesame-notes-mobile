import 'package:flutter/material.dart';

import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 键盘上方的整行备注输入，最多二十字，非空时提供清除入口。
class NoteInputRow extends StatelessWidget {
  /// 备注状态归属于编辑器，切换选择弹层时不会重建输入资源。
  const NoteInputRow({
    super.key,
    required this.noteController,
    required this.noteFocusNode,
    required this.onNotePicked,
    this.readOnly = false,
  });

  final TextEditingController noteController;
  final FocusNode noteFocusNode;
  final ValueChanged<String> onNotePicked;
  final bool readOnly;

  /// 备注输入在系统键盘显示时保持挂载，避免焦点和已输入文字丢失。
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textStyle = AppTextTokens.input(
      context,
    ).copyWith(color: AppTokens.textPrimary(context));
    return ClipRRect(
      key: const ValueKey('editor_metadata_row'),
      borderRadius: BorderRadius.circular(AppDimens.radius4),
      child: ColoredBox(
        color: AppTokens.keyDigit(context),
        // 输入装饰按正文与清除图标计算自然高度，由整行负责垂直居中。
        // 留白仍属于备注触摸区域，点击时沿用同一个输入焦点。
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => noteFocusNode.requestFocus(),
          child: Center(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: noteController,
              builder: (context, value, _) => TextField(
                key: const ValueKey('editor_note'),
                controller: noteController,
                focusNode: noteFocusNode,
                readOnly: readOnly,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => noteFocusNode.unfocus(),
                maxLength: 20,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                style: textStyle,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: l10n.commonNoteHint,
                  // 提示和正文共享字号与行高，输入前后的文字中心保持一致。
                  hintStyle: textStyle.copyWith(
                    color: AppTokens.textSecondary(context),
                  ),
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p12,
                    vertical: AppDimens.p5,
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: AppDimens.p20,
                    minHeight: AppDimens.p32,
                  ),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : InkWell(
                          onTap: readOnly ? null : () => onNotePicked(''),
                          child: Icon(
                            AppIcons.cancel,
                            size: AppDimens.icon16,
                            color: AppTokens.iconSecondary(context),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
