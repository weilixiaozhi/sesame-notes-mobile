import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_analytics_period.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';

/// 读取实际绘制的装饰，避免只验证动画终点配置而漏过中间帧闪暗。
Color? _paintedSegmentColor(WidgetTester tester, String label) {
  try {
    final segment = find.ancestor(
      of: find.text(label),
      matching: find.byType(AnimatedContainer),
    );
    final decoration = tester.widget<DecoratedBox>(
      find.descendant(of: segment, matching: find.byType(DecoratedBox)),
    );
    return (decoration.decoration as BoxDecoration).color;
  } catch (error, stackTrace) {
    debugPrint('读取统计周期 [$label] 动画装饰失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 可见动画帧只允许透明度变化，三个颜色通道必须保持主题选中底色。
void _expectThemeHue(
  WidgetTester tester,
  Iterable<String> labels,
  Color expected,
  String frame,
) {
  try {
    var visibleCount = 0;
    for (final label in labels) {
      final actual = _paintedSegmentColor(tester, label);
      if (actual == null || actual.a == 0) continue;
      visibleCount++;
      expect(
        [actual.r, actual.g, actual.b],
        [expected.r, expected.g, expected.b],
        reason:
            '$frame / $label：选中底色只能淡入淡出；'
            '实际=$actual，主题=$expected，透明度=${actual.a}',
      );
    }
    expect(visibleCount, greaterThan(0), reason: '$frame 必须保留可见的选择反馈');
  } catch (error, stackTrace) {
    debugPrint('统计周期色相回归失败 [$frame]：$error\n$stackTrace');
    rethrow;
  }
}

/// 验证真实语义树中的按钮和唯一选中状态与业务选值一致。
void _expectSelectedSemantics(
  WidgetTester tester,
  Map<AnalyticsPeriod, String> labels,
  AnalyticsPeriod selected,
) {
  try {
    for (final entry in labels.entries) {
      final node = tester.getSemantics(find.text(entry.value));
      expect(node.flagsCollection.isButton, isTrue);
      expect(node.flagsCollection.isEnabled, Tristate.isTrue);
      expect(
        node.flagsCollection.isSelected,
        entry.key == selected ? Tristate.isTrue : Tristate.isFalse,
        reason: '${entry.value} 的辅助功能选中状态应与 $selected 一致',
      );
    }
  } catch (error, stackTrace) {
    debugPrint('统计周期语义回归失败 [$selected]：$error\n$stackTrace');
    rethrow;
  }
}

/// 通过真实主题、本地化和可更新选值，覆盖正常切换及动画未结束时的连点。
Future<void> _exerciseSwitcher(
  WidgetTester tester, {
  required AppThemePreset preset,
  required Brightness brightness,
}) async {
  final semantics = tester.ensureSemantics();
  try {
    var selected = AnalyticsPeriod.week;
    late Color selectedBackground;
    late Map<AnalyticsPeriod, String> labels;
    final changes = <AnalyticsPeriod>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark
            ? AppTheme.darkTheme(preset: preset)
            : AppTheme.lightTheme(preset: preset),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final l = AppLocalizations.of(context);
              labels = {
                AnalyticsPeriod.week: l.analyticsWeek,
                AnalyticsPeriod.month: l.analyticsMonth,
                AnalyticsPeriod.year: l.analyticsYear,
              };
              selectedBackground = AppTokens.surfaceElevated(context);
              return Center(
                child: AppAnalyticsPeriodSwitcher(
                  period: selected,
                  onChanged: (period) {
                    setState(() {
                      selected = period;
                      changes.add(period);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    _expectSelectedSemantics(tester, labels, selected);

    for (final target in [
      AnalyticsPeriod.month,
      AnalyticsPeriod.year,
      AnalyticsPeriod.week,
    ]) {
      await tester.tap(find.text(labels[target]!));
      // 首次重建建立动画起点，之后再精确推进到用户能看到的中间帧。
      await tester.pump();
      for (final milliseconds in [40, 80]) {
        await tester.pump(const Duration(milliseconds: 40));
        _expectThemeHue(
          tester,
          labels.values,
          selectedBackground,
          '$target ${milliseconds}ms',
        );
        final incoming = _paintedSegmentColor(tester, labels[target]!)!;
        expect(incoming.a, greaterThan(0));
        expect(incoming.a, lessThan(selectedBackground.a));
      }
      await tester.pumpAndSettle();
      expect(selected, target);
      expect(_paintedSegmentColor(tester, labels[target]!), selectedBackground);
      _expectSelectedSemantics(tester, labels, target);
    }

    // 每次只推进四十毫秒，迫使后续点击从尚未完成的颜色插值继续。
    for (final target in [
      AnalyticsPeriod.year,
      AnalyticsPeriod.month,
      AnalyticsPeriod.week,
      AnalyticsPeriod.year,
    ]) {
      await tester.tap(find.text(labels[target]!));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      _expectThemeHue(
        tester,
        labels.values,
        selectedBackground,
        '快速切换 $target 40ms',
      );
      _expectSelectedSemantics(tester, labels, target);
    }
    await tester.pump(const Duration(milliseconds: 40));
    _expectThemeHue(tester, labels.values, selectedBackground, '快速切换最终 80ms');
    await tester.pumpAndSettle();
    expect(selected, AnalyticsPeriod.year);
    expect(changes, [
      AnalyticsPeriod.month,
      AnalyticsPeriod.year,
      AnalyticsPeriod.week,
      AnalyticsPeriod.year,
      AnalyticsPeriod.month,
      AnalyticsPeriod.week,
      AnalyticsPeriod.year,
    ]);
    expect(
      _paintedSegmentColor(tester, labels[AnalyticsPeriod.year]!),
      selectedBackground,
    );
    _expectSelectedSemantics(tester, labels, AnalyticsPeriod.year);
    expect(tester.takeException(), isNull);
  } catch (error, stackTrace) {
    debugPrint(
      '统计周期回归失败：皮肤=${preset.name}，亮度=${brightness.name}'
      '\n$error\n$stackTrace',
    );
    rethrow;
  } finally {
    semantics.dispose();
  }
}

/// 全部皮肤在明暗模式下使用相同的动画断言。
void main() {
  for (final preset in AppThemePreset.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${preset.name} ${brightness.name} 周月年中间帧保持主题底色',
        (tester) =>
            _exerciseSwitcher(tester, preset: preset, brightness: brightness),
      );
    }
  }
}
