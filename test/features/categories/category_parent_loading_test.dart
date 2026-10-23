import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/presentation/category_edit_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 控制父分类读取的完成与失败，页面保留真实保存按钮和重试入口。
class _ParentActions extends Fake implements CategoryActions {
  var parent = Completer<CategoryDisplay?>();
  final checks = <Completer<bool>>[];

  /// 保存各次查询回执，模拟输入改回原名称时旧查询迟到。
  @override
  Future<bool> isNameDuplicate({
    required String name,
    required String kind,
    String? excludeId,
    String? parentId,
    String? ledgerId,
  }) {
    final result = Completer<bool>();
    checks.add(result);
    return result.future;
  }

  /// 本例分类没有子项，编辑限制仅来自未确认的原父级。
  @override
  Future<bool> hasSubCategories(String categoryId, {String? ledgerId}) async =>
      false;

  /// 返回受控父级查询，以覆盖延迟和空结果。
  @override
  Future<CategoryDisplay?> getById(String id, {String? ledgerId}) =>
      parent.future;
}

/// 原父分类读取失败不能被当成用户主动降级分类。
void main() {
  testWidgets('名称改回原值后，只接受最后一次判重结果', (tester) async {
    final actions = _ParentActions();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [categoryActionsProvider.overrideWithValue(actions)],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryEditPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final name in ['原名称', '其他名称', '原名称']) {
      await tester.enterText(find.byType(TextFormField), name);
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(actions.checks, hasLength(3));
    actions.checks[2].complete(false);
    await tester.pump();
    actions.checks[0].complete(true);
    actions.checks[1].complete(false);
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppEditorFooter>(find.byType(AppEditorFooter)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('父级读取中及缺失时禁用保存，成功重试后才恢复', (tester) async {
    final actions = _ParentActions();
    const child = CategoryDisplay(
      id: 'child',
      name: '子分类',
      kind: 'expense',
      level: 2,
      parentId: 'parent',
      sortOrder: 0,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [categoryActionsProvider.overrideWithValue(actions)],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryEditPage(category: child),
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.widget<AppEditorFooter>(find.byType(AppEditorFooter)).onPressed,
      isNull,
    );
    actions.parent.complete(null);
    await tester.pumpAndSettle();
    expect(
      tester.widget<AppEditorFooter>(find.byType(AppEditorFooter)).onPressed,
      isNull,
    );
    expect(find.byType(AppLoadError), findsOneWidget);
    actions.parent = Completer<CategoryDisplay?>();
    tester.widget<AppLoadError>(find.byType(AppLoadError)).onRetry!();
    await tester.pump();
    actions.parent.complete(
      const CategoryDisplay(
        id: 'parent',
        name: '父分类',
        kind: 'expense',
        level: 1,
        sortOrder: 0,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('父分类'), findsOneWidget);
    expect(
      tester.widget<AppEditorFooter>(find.byType(AppEditorFooter)).onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });
}
