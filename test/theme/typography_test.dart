// AppTextTokens 文本样式测试。
//
// 需求锚点：五种文本样式在 Material 主题下均可用，字号/字重语义正确。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/typography.dart';

void main() {
  testWidgets('title/strongTitle/boldTitle/body/label 样式语义', (tester) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Theme(
        data: AppTheme.lightTheme(platform: TargetPlatform.android),
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(AppTextTokens.title(captured), isA<TextStyle>());
    expect(AppTextTokens.strongTitle(captured).fontWeight, FontWeight.w600);
    expect(AppTextTokens.boldTitle(captured).fontSize, 18);
    expect(AppTextTokens.boldTitle(captured).fontWeight, FontWeight.w800);
    expect(AppTextTokens.body(captured), isA<TextStyle>());
    expect(AppTextTokens.label(captured), isA<TextStyle>());
  });
}
