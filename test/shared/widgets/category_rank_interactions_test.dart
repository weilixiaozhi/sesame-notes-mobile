import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/shared/widgets/category_rank_row.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';

const _parent = CategoryDisplay(
  id: 'rank-parent',
  name: '餐饮父类',
  kind: 'expense',
  level: 1,
  sortOrder: 0,
  icon: 'utensils',
);

const _child = CategoryDisplay(
  id: 'rank-child',
  name: '咖啡子类',
  kind: 'expense',
  level: 2,
  sortOrder: 0,
  icon: 'coffee',
  parentId: 'rank-parent',
);

/// 使用真实分类排行和预计算子项，仅隔离金额展示依赖的账本查询。
Widget _buildRankApp({
  required AppThemePreset preset,
  required bool dark,
  required void Function(String id, String name) onCategoryTap,
  String? categoryId = 'rank-parent',
  String childName = '咖啡子类',
  double childTotal = 40,
}) => ProviderScope(
  overrides: [
    currentLedgerDisplayProvider.overrideWithValue(
      const AsyncData<LedgerDisplayItem?>(null),
    ),
  ],
  child: MaterialApp(
    theme: dark
        ? AppTheme.darkTheme(preset: preset)
        : AppTheme.lightTheme(preset: preset),
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.3)),
      child: child!,
    ),
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CategoryRankRow(
          key: ValueKey(categoryId),
          categoryId: categoryId,
          category: _parent,
          name: _parent.name,
          value: 100,
          percent: 0.5,
          color: Colors.blue,
          onCategoryTap: onCategoryTap,
          subCategories: [
            (
              id: 'rank-child',
              category: _child,
              name: childName,
              total: childTotal,
            ),
          ],
        ),
      ),
    ),
  ),
);

/// 三套皮肤的亮暗模式下，分类图标、展开内容和子行各自只响应原有动作。
void main() {
  testWidgets('父合计不变时，已展开子项仍更新金额与名称', (tester) async {
    await tester.pumpWidget(
      _buildRankApp(
        preset: AppThemePreset.classic,
        dark: false,
        onCategoryTap: (_, _) {},
      ),
    );
    await tester.tap(find.text(_parent.name));
    await tester.pumpAndSettle();
    expect(find.text('20.0%'), findsOneWidget);
    await tester.pumpWidget(
      _buildRankApp(
        preset: AppThemePreset.classic,
        dark: false,
        onCategoryTap: (_, _) {},
        childName: '改名后的子类',
        childTotal: 60,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('20.0%'), findsNothing);
    expect(find.text('30.0%'), findsOneWidget);
    expect(find.text('咖啡子类'), findsNothing);
    expect(find.text('改名后的子类'), findsOneWidget);
  });
  for (final preset in AppThemePreset.values) {
    for (final dark in [false, true]) {
      testWidgets('$preset 深色=$dark：分类排行保留独立导航、展开和缺失标识保护', (tester) async {
        final navigations = <(String, String)>[];
        try {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            _buildRankApp(
              preset: preset,
              dark: dark,
              onCategoryTap: (id, name) => navigations.add((id, name)),
            ),
          );
          await tester.pumpAndSettle();
          final parentIcon = find.byIcon(resolveCategoryIcon(_parent.icon));
          final childIcon = find.byIcon(resolveCategoryIcon(_child.icon));

          expect(find.text(_child.name), findsNothing);
          await tester.tap(parentIcon);
          await tester.pumpAndSettle();
          expect(navigations, [(_parent.id, _parent.name)]);
          expect(find.text(_child.name), findsNothing, reason: '父图标跳转不能附带展开子项');

          await tester.tap(find.text(_parent.name));
          await tester.pumpAndSettle();
          expect(find.text(_child.name), findsOneWidget);
          expect(navigations, [
            (_parent.id, _parent.name),
          ], reason: '展开操作不能触发详情导航');

          await tester.tap(childIcon);
          await tester.pumpAndSettle();
          expect(navigations, [
            (_parent.id, _parent.name),
            (_child.id, _child.name),
          ], reason: '子图标沿用子行操作，单次点击只能导航一次');

          await tester.tap(find.text(_child.name));
          await tester.pumpAndSettle();
          expect(navigations, [
            (_parent.id, _parent.name),
            (_child.id, _child.name),
            (_child.id, _child.name),
          ], reason: '子行只回传被点击的子分类');

          await tester.tap(find.text(_parent.name));
          await tester.pumpAndSettle();
          expect(find.text(_child.name), findsNothing);
          expect(navigations, hasLength(3), reason: '收起操作不能触发详情导航');
          expect(tester.takeException(), isNull);

          navigations.clear();
          await tester.pumpWidget(
            _buildRankApp(
              preset: preset,
              dark: dark,
              categoryId: null,
              onCategoryTap: (id, name) => navigations.add((id, name)),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(parentIcon);
          await tester.tap(find.text(_parent.name));
          await tester.pumpAndSettle();
          expect(navigations, isEmpty, reason: '缺失分类标识时不能发起详情导航');
          expect(
            find.text(_child.name),
            findsNothing,
            reason: '未知父分类不能展开预计算子项',
          );
          expect(tester.takeException(), isNull);
        } catch (error, stackTrace) {
          debugPrint('分类排行交互回归失败：$preset 深色=$dark，$error');
          debugPrintStack(stackTrace: stackTrace);
          rethrow;
        }
      });
    }
  }
}
