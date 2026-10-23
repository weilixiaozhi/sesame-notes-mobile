import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_subcategory_dialog.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 隔离读取用例，交互仍通过真实的子分类面板完成。
class _CategoryActions extends Mock implements CategoryActions {}

/// 复选框与整行共享同一选择状态，单次操作不能产生重复切换。
void main() {
  for (final dark in [false, true]) {
    testWidgets('深色=$dark：子分类复选、整行、全选与取消保持一致', (tester) async {
      const parent = CategoryDisplay(
        id: 'parent',
        name: '交通父项',
        kind: 'expense',
        level: 1,
        sortOrder: 0,
      );
      const child = CategoryDisplay(
        id: 'child',
        name: '交通子项',
        kind: 'expense',
        level: 2,
        sortOrder: 0,
        parentId: 'parent',
      );
      final actions = _CategoryActions();
      when(
        () => actions.getSubCategories(parent.id),
      ).thenAnswer((_) async => [child]);
      final counts = [
        (category: parent, transactionCount: 0),
        (category: child, transactionCount: 0),
      ];
      var navigations = 0;
      final l10n = lookupAppLocalizations(const Locale('zh'));
      try {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              categoryActionsProvider.overrideWithValue(actions),
              categoriesWithCountProvider.overrideWith(
                (ref) => Stream.value(counts),
              ),
            ],
            child: MaterialApp(
              theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
              locale: const Locale('zh'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: CategorySubcategoryDialog(
                  parentCategory: parent,
                  categoriesWithCount: counts,
                  onSubCategoryTap: (_) => navigations++,
                  onAddSubCategory: () {},
                  onEditParentCategory: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(child.name));
        expect(navigations, 1);
        await tester.tap(find.byKey(const ValueKey('subcategoryBatchDelete')));
        await tester.pumpAndSettle();
        final checkbox = find.byType(Checkbox);
        expect(tester.widget<Checkbox>(checkbox).value, isFalse);

        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        expect(
          find.text(l10n.categoryTemplateSelectedCount(1)),
          findsOneWidget,
        );
        await tester.tap(find.text(child.name));
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isFalse);
        expect(navigations, 1, reason: '删除选择期间不触发普通编辑入口');

        await tester.tap(find.byKey(const ValueKey('subcategorySelectAll')));
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.byType(Checkbox), findsNothing);
        expect(find.text(child.name), findsOneWidget);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('子分类复选交互验证失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });
  }
}
