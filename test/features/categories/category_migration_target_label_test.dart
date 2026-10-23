import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_delete_review_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_list_tile.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 迁移目标标签通过真实复核面板展示，确认结果保留所选分类身份。
void main() {
  for (final scenario in [
    (hasParent: true, label: '目标父分类 / 目标子分类'),
    (hasParent: false, label: '目标子分类'),
  ]) {
    testWidgets('父分类存在=${scenario.hasParent}：迁移目标展示完整名称并返回目标身份', (
      tester,
    ) async {
      try {
        const source = CategoryDisplay(
          id: 'source',
          name: '来源分类',
          kind: 'expense',
          level: 1,
          sortOrder: 0,
        );
        const parent = CategoryDisplay(
          id: 'target-parent',
          name: '目标父分类',
          kind: 'expense',
          level: 1,
          sortOrder: 1,
        );
        const target = CategoryDisplay(
          id: 'target-child',
          name: '目标子分类',
          kind: 'expense',
          level: 2,
          sortOrder: 0,
          parentId: 'target-parent',
        );
        final l10n = lookupAppLocalizations(const Locale('zh'));
        ({int option, String? targetId})? decision;
        var selections = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CategoryDeleteReviewSheet(
                categoriesWithCount: [
                  (category: source, transactionCount: 1),
                  if (scenario.hasParent)
                    (category: parent, transactionCount: 0),
                  (category: target, transactionCount: 0),
                ],
                selectedIds: {source.id},
                includeParents: true,
                initialOption: 1,
                selectTarget: () async {
                  selections++;
                  return target.id;
                },
                onBack: () {},
                onConfirm: (value) => decision = value,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final targetTile = find.byWidgetPredicate(
          (widget) =>
              widget is AppListTile &&
              widget.title == l10n.categoryMigrateSelectTargetTitle,
        );
        expect(targetTile, findsOneWidget);
        expect(tester.widget<AppListTile>(targetTile).subtitle, isNull);
        final confirmButton = find.widgetWithText(
          FilledButton,
          l10n.categoryMigrateConfirmButton,
        );
        expect(tester.widget<FilledButton>(confirmButton).onPressed, isNull);

        // 目标来自真实选择回调，标签随面板状态更新后再执行确认。
        await tester.ensureVisible(targetTile);
        await tester.tap(targetTile);
        await tester.pumpAndSettle();
        expect(selections, 1);
        expect(tester.widget<AppListTile>(targetTile).subtitle, scenario.label);
        expect(tester.widget<FilledButton>(confirmButton).onPressed, isNotNull);
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();
        expect(decision, (option: 1, targetId: target.id));
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('迁移目标标签验证失败：父分类存在=${scenario.hasParent}，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });
  }
}
