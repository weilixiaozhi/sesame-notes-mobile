import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';

/// AppTokens 亮/暗取色测试。
///
/// 覆盖 AppTokens 取色与 divider 逻辑：
/// - AppTokens 各语义取色在亮/暗主题下返回 AppColors 对应常量。
void main() {
  late ThemeData lightTheme;
  late ThemeData darkTheme;

  setUp(() {
    lightTheme = AppTheme.lightTheme(platform: TargetPlatform.android);
    darkTheme = AppTheme.darkTheme(platform: TargetPlatform.android);
  });

  /// 把 ThemeData 直接挂到 widget 树并返回其子树 context。
  ///
  /// 设计意图：AppTokens 仅依赖 Theme.of(context).brightness 取色，不依赖
  /// Material。这里绕过 MaterialApp——MaterialApp 会依据 MediaQuery.platformBrightness
  /// 在 theme/darkTheme 间选择，测试默认平台亮度为 light，暗色主题极易被误判成
  /// 亮色。直接用 Theme(data: theme) 包裹能确保 Theme.of(context).brightness
  /// 精确等于传入主题的 brightness。
  ///
  /// 重要：每个测试内如需同时验证亮/暗，必须「先 pump 亮色断言、再 pump 暗色断言」
  /// 顺序执行，绝不能两次 pump 后同时保留两个 context——第二次 pump 会销毁整个
  /// widget 树，使先前的 context 失效，Theme.of(失效context) 会返回错误值。
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

  group('AppTokens 亮/暗取色', () {
    testWidgets('isDark 正确识别亮/暗主题', (tester) async {
      var ctx = await pumpContext(tester, lightTheme);
      expect(AppTokens.isDark(ctx), isFalse);
      // 重新 pump 暗色主题（旧亮色 ctx 已失效，不引用）。
      ctx = await pumpContext(tester, darkTheme);
      expect(AppTokens.isDark(ctx), isTrue);
    });

    testWidgets('scaffoldBackground / surface 亮暗值正确', (tester) async {
      var ctx = await pumpContext(tester, lightTheme);
      expect(AppTokens.scaffoldBackground(ctx), AppColors.lightScaffold);
      expect(AppTokens.surface(ctx), AppColors.lightSurface);
      ctx = await pumpContext(tester, darkTheme);
      expect(AppTokens.scaffoldBackground(ctx), AppColors.darkScaffold);
      expect(AppTokens.surface(ctx), AppColors.darkSurface);
    });

    testWidgets('textPrimary / textSecondary 亮暗值正确', (tester) async {
      var ctx = await pumpContext(tester, lightTheme);
      expect(AppTokens.textPrimary(ctx), AppColors.lightTextPrimary);
      expect(AppTokens.textSecondary(ctx), AppColors.lightTextSecondary);
      // textTertiary 暗色为 rgba(255,255,255,0.54)（非 pin 常量），仅断言亮色侧。
      expect(AppTokens.textTertiary(ctx), AppColors.lightTextTertiary);
      ctx = await pumpContext(tester, darkTheme);
      expect(AppTokens.textPrimary(ctx), AppColors.darkTextPrimary);
      expect(AppTokens.textSecondary(ctx), AppColors.darkTextSecondary);
    });

    /// divider 必须随 context 取色，确保暗色主题不引用亮色静态值。
    testWidgets('divider 亮暗值与主题一致', (tester) async {
      var ctx = await pumpContext(tester, lightTheme);
      expect(AppTokens.divider(ctx), Colors.black.withValues(alpha: 0.06));
      ctx = await pumpContext(tester, darkTheme);
      expect(
        AppTokens.divider(ctx),
        AppColors.darkBorder.withValues(alpha: 0.10),
      );
    });
  });
}
