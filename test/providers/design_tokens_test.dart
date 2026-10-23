import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 验证视觉角色完整性，并阻断业务界面按皮肤名称分支。
void main() {
  test('三套主题的亮暗配置均提供完整且有效的视觉角色', () {
    for (final preset in AppThemePreset.values) {
      for (final brightness in Brightness.values) {
        final visual = AppVisualTheme.resolve(preset, brightness);
        expect(visual.colors.keys.toSet(), AppThemeColor.values.toSet());
        expect(visual.radii.keys.toSet(), AppThemeRadius.values.toSet());
        expect(visual.radii.values, everyElement(greaterThanOrEqualTo(0)));
        expect(visual.listGroupHeadingGap, greaterThanOrEqualTo(0));
        expect(visual.listGroupsUseCards, preset != AppThemePreset.minimal);
        expect(
          visual.listGroupHeadingGap,
          preset == AppThemePreset.minimal ? 0 : AppDimens.p12,
        );
      }
    }
  });

  test('复制和主题过渡保留分组列表的语义配置', () {
    final classic = AppVisualTheme.resolve(
      AppThemePreset.classic,
      Brightness.light,
    );
    final flat = classic.copyWith(
      listGroupsUseCards: false,
      listGroupHeadingGap: 0,
    );
    expect(flat.copyWith().listGroupsUseCards, isFalse);
    expect(flat.copyWith().listGroupHeadingGap, 0);
    expect(classic.lerp(flat, 0).listGroupsUseCards, isTrue);
    expect(classic.lerp(flat, 1).listGroupsUseCards, isFalse);
    expect(classic.lerp(flat, 0.5).listGroupHeadingGap, AppDimens.p12 / 2);
  });

  test('业务界面通过语义角色消费主题，主题选项页允许枚举风格', () {
    try {
      final violations = <String>[];
      final presetReference = RegExp(
        r'\bAppThemePreset\b|\bAppTokens\s*\.\s*visual\b|\bAppVisualTheme\s*\.\s*of\b',
      );
      for (final file in Directory('lib/features').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        final path = file.path.replaceAll('\\', '/');
        if (!path.contains('/presentation/') ||
            path ==
                'lib/features/settings/presentation/theme_settings_page.dart') {
          continue;
        }
        final lines = file.readAsLinesSync();
        for (var index = 0; index < lines.length; index++) {
          if (presetReference.hasMatch(lines[index])) {
            violations.add('$path:${index + 1} ${lines[index].trim()}');
          }
        }
      }
      expect(
        violations,
        isEmpty,
        reason: '业务页面应读取 AppTokens 语义角色：\n${violations.join('\n')}',
      );
    } catch (error, stackTrace) {
      stderr.writeln('主题门禁检查失败，请检查源码路径与角色使用。');
      stderr.writeln('$error\n$stackTrace');
      rethrow;
    }
  });
}
