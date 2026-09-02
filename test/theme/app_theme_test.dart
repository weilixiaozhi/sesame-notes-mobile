import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';

/// ThemeData 固定值与 AppColors 单一真相源契约测试。
///
/// 守护核心架构契约：AppTheme 构造 ThemeData 时把关键色显式 pin 为
/// AppColors 常量，因此「改 AppColors 一处，ThemeData 自动跟随」，
/// 杜绝 ThemeData 与 Token 双真相源。一旦有人在 app_theme.dart 里改回字面量，
/// 本测试会立即失败。
void main() {
  test('lightTheme 关键 pin 值与 AppColors 一致', () {
    final t = AppTheme.lightTheme(platform: TargetPlatform.android);
    expect(
      t.scaffoldBackgroundColor,
      AppColors.lightScaffold,
      reason: '亮色页面底色必须引用 AppColors.lightScaffold',
    );
    expect(
      t.colorScheme.surface,
      AppColors.lightSurface,
      reason: '亮色卡片表面必须引用 AppColors.lightSurface',
    );
    expect(
      t.colorScheme.primary,
      AppColors.seed,
      reason: '主色必须 pin 为 AppColors.seed（唯一主色真相源）',
    );
  });

  test('darkTheme 关键 pin 值与 AppColors 一致', () {
    final t = AppTheme.darkTheme(platform: TargetPlatform.android);
    expect(
      t.scaffoldBackgroundColor,
      AppColors.darkScaffold,
      reason: '暗色页面底色必须引用 AppColors.darkScaffold',
    );
    expect(
      t.colorScheme.primary,
      AppColors.seed,
      reason: '暗色主色仍必须 pin 为 AppColors.seed（亮暗一致）',
    );
  });
}
