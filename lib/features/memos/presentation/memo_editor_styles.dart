import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

const memoToolbarButtonOptions = QuillToolbarBaseButtonOptions(
  iconSize: AppDimens.icon20,
  iconButtonFactor: 1,
);

/// 将应用字体、行高和颜色传给 Quill，避免正文与表单使用两套默认排版。
DefaultStyles memoEditorStyles(BuildContext context) {
  final body = AppTextTokens.documentBody(context);
  DefaultTextBlockStyle block(TextStyle style, {bool heading = false}) =>
      DefaultTextBlockStyle(
        style,
        HorizontalSpacing.zero,
        heading
            ? const VerticalSpacing(0, AppDimens.p12)
            : VerticalSpacing.zero,
        VerticalSpacing.zero,
        null,
      );
  final paragraph = block(body);
  return DefaultStyles(
    paragraph: paragraph,
    h1: block(AppTextTokens.display2(context), heading: true),
    h2: block(AppTextTokens.boldTitle(context), heading: true),
    h3: block(AppTextTokens.strongTitle(context), heading: true),
    lists: DefaultStyles.getInstance(context).lists!.copyWith(
      style: body,
      horizontalSpacing: HorizontalSpacing.zero,
      verticalSpacing: VerticalSpacing.zero,
      lineSpacing: VerticalSpacing.zero,
    ),
    indent: paragraph.copyWith(
      horizontalSpacing: const HorizontalSpacing(AppDimens.p16, 0),
    ),
    leading: paragraph,
  );
}
