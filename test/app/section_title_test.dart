/// 全局统一区块标题与选中卡片视觉规范测试。
///
/// 锁定:
/// 1. [SectionTitle] 色条 3x15 主题色圆角条 + titleSmall/w800 主题色标题;
///    disabled 时色条与标题整行置灰;副标题 bodySmall 次要色;trailing 贴行尾。
/// 2. 选中卡片边框:选中 = 主题色 1px;未选中 = 暗色 1px 常规边框 / 亮色无边框;
///    勾选角标为 20x20 主题色块 + 对勾。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/shared/widgets/section_title.dart';
import 'package:sesame_notes/shared/widgets/selectable_card.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

void main() {
  testWidgets('SectionTitle 主题色条 + 主题色标题', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SectionTitle(title: '支出趋势')),
      ),
    );
    final context = tester.element(find.text('支出趋势'));
    final primary = Theme.of(context).colorScheme.primary;

    final text = tester.widget<Text>(find.text('支出趋势'));
    expect(text.style?.color, primary, reason: '标题应为主题色');
    expect(text.style?.fontWeight, FontWeight.w800, reason: '标题应为加粗');

    final bar = tester.widget<Container>(
      find.descendant(
        of: find.byType(SectionTitle),
        matching: find.byType(Container),
      ),
    );
    expect(bar.constraints?.maxWidth, 3, reason: '色条宽 3');
    expect(bar.constraints?.maxHeight, 15, reason: '色条高 15');
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.color, primary, reason: '色条为主题色');
    expect(decoration.borderRadius, BorderRadius.circular(4), reason: '色条圆角 4');
  });

  testWidgets('SectionTitle disabled 时色条与标题整行置灰', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SectionTitle(title: '账本名称', disabled: true)),
      ),
    );
    final context = tester.element(find.text('账本名称'));
    final disabled = Theme.of(context).disabledColor;

    final text = tester.widget<Text>(find.text('账本名称'));
    expect(text.style?.color, disabled, reason: '只读标题应置灰');

    final bar = tester.widget<Container>(
      find.descendant(
        of: find.byType(SectionTitle),
        matching: find.byType(Container),
      ),
    );
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.color, disabled, reason: '只读色条应置灰');
  });

  testWidgets('SectionTitle 副标题与 trailing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SectionTitle(
            title: '备份同步',
            subtitle: '副标题说明',
            trailing: Text('右对齐'),
          ),
        ),
      ),
    );
    final context = tester.element(find.text('备份同步'));
    expect(find.text('副标题说明'), findsOneWidget);
    expect(find.text('右对齐'), findsOneWidget);
    final sub = tester.widget<Text>(find.text('副标题说明'));
    expect(sub.style?.color, AppTokens.textSecondary(context));

    // trailing 应贴行尾:右对齐文案右缘在标题右侧。
    final titleRect = tester.getRect(find.text('备份同步'));
    final trailingRect = tester.getRect(find.text('右对齐'));
    expect(trailingRect.right, greaterThan(titleRect.right));
  });

  group('选中卡片公共视觉', () {
    testWidgets('选中边框为主题色 1px', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final context = tester.element(find.byType(Scaffold));

      final border = selectableCardBorder(context, selected: true)!;
      expect(border.top.color, Theme.of(context).colorScheme.primary);
      expect(border.top.width, 1);
    });

    testWidgets('未选中:亮色无边框', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      final context = tester.element(find.byType(Scaffold));
      expect(
        selectableCardBorder(context, selected: false),
        isNull,
        reason: '亮色未选中无边框',
      );
    });

    testWidgets('未选中:暗色 1px 常规边框', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: ColorScheme.dark()),
          home: const Scaffold(),
        ),
      );
      final context = tester.element(find.byType(Scaffold));
      final border = selectableCardBorder(context, selected: false)!;
      expect(border.top.width, 1, reason: '暗色未选中为 1px 常规边框');
      expect(border.top.color, AppTokens.border(context));
    });

    testWidgets('角标为 20x20 主题色块 + 对勾', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Stack(children: [SelectableCardCheckBadge()])),
        ),
      );
      final context = tester.element(find.byIcon(AppIcons.check));
      expect(find.byIcon(AppIcons.check), findsOneWidget);

      final badgeContainer = find.ancestor(
        of: find.byIcon(AppIcons.check),
        matching: find.byType(Container),
      );
      final size = tester.getSize(badgeContainer.first);
      expect(size.width, 20, reason: '角标宽 20');
      expect(size.height, 20, reason: '角标高 20');
      final decoration =
          tester.widget<Container>(badgeContainer.first).decoration!
              as BoxDecoration;
      expect(decoration.color, Theme.of(context).colorScheme.primary);
    });
  });
}
