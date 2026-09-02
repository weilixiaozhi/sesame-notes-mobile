// AppTokens 全量 token 扫描测试。
//
// 需求锚点：所有 token 在亮/暗主题下均可用且返回对应类型。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';

void main() {
  late ThemeData lightTheme;
  late ThemeData darkTheme;

  setUp(() {
    lightTheme = AppTheme.lightTheme(platform: TargetPlatform.android);
    darkTheme = AppTheme.darkTheme(platform: TargetPlatform.android);
  });

  Future<BuildContext> pumpContext(WidgetTester tester, ThemeData theme) async {
    late BuildContext captured;
    await tester.pumpWidget(
      Theme(
        data: theme,
        child: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    return captured;
  }

  testWidgets('亮/暗全量 token 扫描', (tester) async {
    for (final theme in [lightTheme, darkTheme]) {
      final ctx = await pumpContext(tester, theme);

      expect(AppTokens.surfaceSheet(ctx), isA<Color>());
      expect(AppTokens.keypadBackground(ctx), isA<Color>());
      expect(AppTokens.keyDigit(ctx), isA<Color>());
      expect(AppTokens.surfaceInput(ctx), isA<Color>());
      expect(AppTokens.surfaceChip(ctx), isA<Color>());
      expect(AppTokens.surfaceCapsule(ctx), isA<Color>());
      expect(AppTokens.surfaceCategoryIcon(ctx), isA<Color>());
      expect(AppTokens.surfaceCategoryIconLight(ctx), isA<Color>());
      expect(AppTokens.iconCategory(ctx), isA<Color>());
      expect(AppTokens.surfaceSelected(ctx), isA<Color>());
      expect(AppTokens.surfaceInverse(ctx), isA<Color>());

      expect(AppTokens.textOnPrimary(ctx), Colors.white);
      expect(AppTokens.textLink(ctx), isA<Color>());
      expect(AppTokens.onSurfaceInverse(ctx), isA<Color>());
      expect(AppTokens.iconPrimary(ctx), isA<Color>());
      expect(AppTokens.iconSecondary(ctx), isA<Color>());
      expect(AppTokens.iconTertiary(ctx), isA<Color>());

      expect(AppTokens.border(ctx), isA<Color>());
      expect(AppTokens.borderStrong(ctx), isA<Color>());
      expect(AppTokens.grabHandleColor(ctx), isA<Color>());
      expect(AppTokens.cardOuterBorderColor(ctx), Colors.transparent);
      expect(AppTokens.cardOuterBorderWidth(ctx), 0);
      expect(AppTokens.cardInnerDividerColor(ctx), isA<Color>());
      expect(AppTokens.cardInnerDividerHeight(ctx), isA<double>());
      expect(AppTokens.cardDivider(ctx), isA<Divider>());

      expect(AppTokens.primary(ctx), isA<Color>());
      expect(AppTokens.success(ctx), isA<Color>());
      expect(AppTokens.warning(ctx), isA<Color>());
      expect(AppTokens.error(ctx), isA<Color>());
      expect(AppTokens.info(ctx), isA<Color>());
      expect(AppTokens.buttonPrimary(ctx), isA<Color>());
      expect(AppTokens.buttonPrimaryText(ctx), Colors.white);
      expect(AppTokens.buttonDisabled(ctx), isA<Color>());
      expect(AppTokens.switchInactiveTrack(ctx), isA<Color>());

      expect(AppTokens.brandLocal, isA<Color>());
      expect(AppTokens.brandSupabase, isA<Color>());
      expect(AppTokens.brandWebdav, isA<Color>());
      expect(AppTokens.brandS3, isA<Color>());
      expect(AppTokens.brandCloud, isA<Color>());
      expect(AppTokens.statusOnline(ctx), isA<Color>());
      expect(AppTokens.statusOffline(ctx), isA<Color>());
      expect(AppTokens.statusPending(ctx), isA<Color>());
      expect(AppTokens.chartExpense(ctx), isA<Color>());
      // 趋势折线跟随主题主色，保持与应用主视觉一致；
      // 避免使用 error 语义色，以免与支出金额混淆。
      expect(AppTokens.chartExpense(ctx), AppTokens.primary(ctx));
      expect(AppTokens.overlay(ctx), isA<Color>());
      expect(AppTokens.tabBarBackground(ctx), isA<Color>());
      expect(AppTokens.tabBarShadow, isNotEmpty);
      expect(AppTokens.toastBackground, isA<Color>());
      expect(AppTokens.toastShadow, isNotEmpty);
    }
  });
}
