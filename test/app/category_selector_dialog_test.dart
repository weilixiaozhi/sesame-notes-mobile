/// CategorySelectorDialog 分类加载 future 缓存回归测试。
///
/// 分类列表 future 由 State 缓存，搜索 / 父级重建只做内存过滤，
/// 不重复读取分类。
library;

import 'dart:async';

import 'package:drift/drift.dart' show TableUpdate;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_selector_dialog.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late StreamController<Set<TableUpdate>> dataChanges;

  db.Category category(String id, String name) => db.Category(
    id: id,
    name: name,
    kind: 'expense',
    icon: 'category',
    sortOrder: 0,
    parentId: null,
    level: 1,
    updatedAt: DateTime.utc(2026),
  );

  setUp(() {
    repo = _MockRepo();
    dataChanges = StreamController<Set<TableUpdate>>.broadcast();
    addTearDown(dataChanges.close);
    when(() => repo.getAllCategories()).thenAnswer(
      (_) async => [category('cat-1', '餐饮'), category('cat-2', '交通')],
    );
    when(
      () => repo.filterCategoriesForLedgerPicker(
        any(),
        ledgerId: any(named: 'ledgerId'),
        kind: any(named: 'kind'),
        topLevelOnly: any(named: 'topLevelOnly'),
      ),
    ).thenAnswer(
      (invocation) async =>
          invocation.positionalArguments.first as List<db.Category>,
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        dataChangeSignalProvider.overrideWith((ref) => dataChanges.stream),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showCategorySelector(context, type: 'expense'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('搜索按键不再触发数据库重查（future 缓存）', (tester) async {
    var categoryQueries = 0;
    when(() => repo.getAllCategories()).thenAnswer((_) async {
      categoryQueries++;
      return [category('cat-1', '餐饮'), category('cat-2', '交通')];
    });

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 首次加载：分类查询 1 次
    expect(categoryQueries, 1);

    // 输入搜索文本触发多次 setState / rebuild
    await tester.enterText(find.byType(TextField), '餐');
    await tester.pumpAndSettle();

    // 数据库仍只查 1 次；过滤在内存完成
    expect(categoryQueries, 1);
    expect(find.text('餐饮'), findsOneWidget);
    expect(find.text('交通'), findsNothing);
  });

  testWidgets('分类表变更信号会使已打开的选择器重查数据', (tester) async {
    var categoryQueries = 0;
    var categories = [category('cat-1', '餐饮')];
    when(() => repo.getAllCategories()).thenAnswer((_) async {
      categoryQueries++;
      return categories;
    });

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(categoryQueries, 1);
    expect(find.text('交通'), findsNothing);

    categories = [category('cat-1', '餐饮'), category('cat-2', '交通')];
    dataChanges.add({TableUpdate('categories')});
    await tester.pumpAndSettle();

    expect(categoryQueries, 2);
    expect(find.text('交通'), findsOneWidget);
  });
}
