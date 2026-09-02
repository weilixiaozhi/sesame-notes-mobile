/// HomePage 交易行交互流程测试。
///
/// 需求锚点：
/// - 点击交易行打开记录详情 sheet（接线 onEdit/onDelete/onEditAa）；
/// - 长按交易行 → 删除确认 → deleteTransaction + 刷新 + toast；
/// - 点击分类图标 → 跳转分类详情页；
/// - 详情 sheet 内点删除 → 确认 → 删除成功。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart'
    show Category, Ledger, LedgerMember, Transaction;
import 'package:sesame_notes/data/models.dart' show RecordEditHistoryDisplay;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart'
    show CategoryPickerTree;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/features/ledgers/presentation/home_page.dart';
import 'package:sesame_notes/features/transactions/presentation/category_detail_page.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart' show EffectiveRate;
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';

import '../../helpers/test_isolation.dart';

class _MockRepo extends Mock implements LocalRepository {}

typedef _TxItem = ({Transaction t, Category? category});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late Ledger testLedger;

  setUp(() {
    resetGlobalTestState();
    repo = _MockRepo();
    testLedger = Ledger(
      id: 'ledger-1',
      name: '测试账本',
      currency: 'CNY',
      monthStartDay: 1,
      aaEnabled: false,
      role: 'owner',
      memberCount: 1,
      storageMode: 'local',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    // AA→splits 迁移后编辑流程会查询分摊明细；mock 返回空列表（无分摊）。
    when(() => repo.getTransactionSplits(any())).thenAnswer((_) async => []);
    when(
      () => repo.watchTransactionsWithCategoryInMonth(
        ledgerId: any(named: 'ledgerId'),
        month: any(named: 'month'),
      ),
    ).thenAnswer(
      (_) => Stream<List<_TxItem>>.value([
        (
          t: Transaction(
            id: 'tx-1',
            ledgerId: 'ledger-1',
            txType: 'expense',
            amount: '12.00',
            categoryId: 'cat-1',
            happenedAt: DateTime(2026, 7, 5, 12, 0),
            note: '早餐',
            excludeFromStats: false,
            currencyCode: 'CNY',
            nativeAmount: '12.00',
            version: 1,
            createdAt: DateTime(2026, 7, 5, 12, 0),
            updatedAt: DateTime(2026, 7, 5, 12, 0),
          ),
          category: Category(
            id: 'cat-1',
            name: '餐饮',
            kind: 'expense',
            icon: 'dining',
            sortOrder: 1,
            level: 1,
            updatedAt: DateTime(2026, 7, 5, 12, 0),
          ),
        ),
      ]),
    );
    when(() => repo.getAllLedgers()).thenAnswer((_) async => <Ledger>[]);
    when(
      () => repo.countUnconvertedForeignTx(any()),
    ).thenAnswer((_) async => 0);
    when(() => repo.deleteTransaction(any())).thenAnswer((_) async {});
    when(() => repo.getCategoryById(any())).thenAnswer(
      (_) async => Category(
        id: 'cat-1',
        name: '餐饮',
        kind: 'expense',
        icon: 'dining',
        sortOrder: 1,
        level: 1,
        updatedAt: DateTime(2026, 7, 5, 12, 0),
      ),
    );
    when(
      () => repo.watchTransactionsByCategory(
        any(),
        ledgerId: any(named: 'ledgerId'),
        includeSubCategories: any(named: 'includeSubCategories'),
      ),
    ).thenAnswer((_) => Stream<List<Transaction>>.value(const []));
    when(
      () => repo.watchCategoryWithSubs(any()),
    ).thenAnswer((_) => Stream<List<Category>>.value(const []));
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        currentLedgerIdProvider.overrideWithBuild(
          (ref, notifier) => 'ledger-1',
        ),
        currentLedgerProvider.overrideWith(
          (ref) => Stream<Ledger?>.value(testLedger),
        ),
        currentMonthStartDayProvider.overrideWith((ref) => 1),
        monthlyTotalsProvider.overrideWith((ref, params) async => 0.0),
        todayExpenseProvider.overrideWith((ref, ledgerId) async => 0.0),
        weekExpenseProvider.overrideWith((ref, ledgerId) async => 0.0),
        selectedMonthProvider.overrideWithBuild(
          (ref, notifier) => DateTime(2026, 7, 1),
        ),
        recordEditHistoryProvider.overrideWith(
          (ref, recordId) async => const <RecordEditHistoryDisplay>[],
        ),
        ledgerVirtualUsersProvider.overrideWith(
          (ref, ledgerId) => Stream<List<LedgerMember>>.value(const []),
        ),
        currentLedgerCurrencyProvider.overrideWith((ref) => 'CNY'),
        effectiveRatesForLedgerProvider.overrideWith(
          (ref) async => <String, EffectiveRate>{},
        ),
        categoryPickerTreeProvider('expense').overrideWith(
          (ref) => Stream<CategoryPickerTree>.value(
            const CategoryPickerTree(topLevel: [], children: {}),
          ),
        ),
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        routerConfig: createAppRouter(home: () => const HomePage()),
      ),
    );
  }

  Future<void> prime(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// flutter_list_view 子项在 widget test 中不参与 onstage 遍历，
  /// 统一用 skipOffstage: false 定位交易行。
  Finder txRow() => find.byType(TransactionListItem, skipOffstage: false);

  testWidgets('点击交易行：打开记录详情 sheet', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    expect(txRow(), findsOneWidget);
    // 通过 TransactionListItem 的 onTap 触发（flutter_list_view 子项不可点）。
    final row = tester.widget<TransactionListItem>(txRow());
    row.onTap?.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 详情 sheet 为私有 body，用交易备注断言其已打开。
    expect(find.text('早餐'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('长按交易行：删除确认 → deleteTransaction + toast', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    // 删除长按在外层 GestureDetector。
    final deleteGesture = find
        .ancestor(
          of: txRow(),
          matching: find.byType(GestureDetector, skipOffstage: false),
        )
        .first;
    tester.widget<GestureDetector>(deleteGesture).onLongPress?.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    // 确认对话框。
    await tester.tap(find.widgetWithText(FilledButton, '确定'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    verify(() => repo.deleteTransaction('tx-1')).called(1);
    expect(find.text('已删除'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('点击分类图标：跳转分类详情页', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    final row = tester.widget<TransactionListItem>(txRow());
    row.onCategoryTap?.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(CategoryDetailPage), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('详情 sheet 点「编辑记账」：打开交易编辑器', (tester) async {
    await tester.pumpWidget(buildApp());
    await prime(tester);

    final row = tester.widget<TransactionListItem>(txRow());
    row.onTap?.call();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('早餐'), findsOneWidget);

    await tester.tap(find.text('编辑记账'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TransactionEditorSheet), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
