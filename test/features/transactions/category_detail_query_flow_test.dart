import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' show Ledger;
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/features/transactions/presentation/category_detail_page.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/amount_text.dart';
import 'package:sesame_notes/theme/app_theme.dart';

import '../../helpers/test_isolation.dart';

/// 只替换存储读取边界，页面继续使用真实交易 Provider、汇总与排序控件。
class _CategoryQueries extends Mock implements CategoryQueryRepository {}

final _day = DateTime(2026, 8, 8);

/// 交易同日的不同时点用于区分时间排序和金额排序，备注保留可辨认身份。
TransactionSnapshot _transaction(
  String id, {
  required String amount,
  required String nativeAmount,
  required int hour,
  String categoryId = 'parent',
  String currencyCode = 'CNY',
}) => TransactionSnapshot(
  id: id,
  ledgerId: 'ledger-a',
  txType: 'expense',
  amount: amount,
  nativeAmount: nativeAmount,
  currencyCode: currencyCode,
  happenedAt: DateTime(2026, 8, 8, hour),
  note: id,
  categoryId: categoryId,
  version: 1,
  createdAt: _day,
  updatedAt: _day,
);

/// 固定账本下的父子分类由同一个只读端口提供，测试不绕过业务 Provider。
_CategoryQueries _queries(List<TransactionSnapshot> rows) {
  final queries = _CategoryQueries();
  when(
    () => queries.watchTransactionsByCategory(
      'parent',
      ledgerId: 'ledger-a',
      includeSubCategories: true,
    ),
  ).thenAnswer((_) => Stream.value(rows));
  when(
    () => queries.watchCategoryWithSubs('parent', ledgerId: 'ledger-a'),
  ).thenAnswer(
    (_) => Stream.value([
      CategorySnapshot(
        id: 'parent',
        name: '餐饮',
        kind: 'expense',
        level: 1,
        sortOrder: 0,
        updatedAt: _day,
      ),
      CategorySnapshot(
        id: 'child',
        name: '早餐',
        kind: 'expense',
        level: 2,
        parentId: 'parent',
        sortOrder: 0,
        updatedAt: _day,
      ),
    ]),
  );
  return queries;
}

/// 元数据与只读端口独立注入，纯详情读取不能构造组合仓储或打开数据库。
ProviderContainer _container(CategoryQueryRepository queries) {
  final ledger = Ledger(
    id: 'ledger-a',
    name: '人民币账本',
    currency: 'CNY',
    monthStartDay: 1,
    aaEnabled: false,
    role: 'owner',
    memberCount: 1,
    storageMode: 'local',
    createdAt: _day,
    updatedAt: _day,
  );
  return ProviderContainer(
    overrides: [
      categoryQueriesProvider.overrideWithValue(queries),
      currentAccountIdProvider.overrideWith((ref) => null),
      authIdentityGenerationProvider.overrideWith((ref) => 1),
      currentLedgerIdProvider.overrideWithBuild((ref, notifier) => 'ledger-a'),
      ledgerByIdProvider.overrideWith(
        (ref, id) async => id == ledger.id ? ledger : null,
      ),
      currentLedgerProvider.overrideWith((ref) => Stream.value(ledger)),
      repositoryProvider.overrideWith((ref) {
        throw StateError('分类详情纯查询不能依赖组合仓储');
      }),
      databaseProvider.overrideWith((ref) {
        throw StateError('分类详情纯查询不能直接打开数据库');
      }),
    ],
  );
}

/// 宽屏一次展示四个真实排序按钮及全部交易行，避免滚动懒加载影响顺序断言。
Future<void> _pumpDetail(
  WidgetTester tester,
  ProviderContainer container,
) async {
  try {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CategoryDetailPage(
            categoryId: 'parent',
            categoryName: '餐饮',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } catch (error, stack) {
    debugPrint('打开真实分类详情失败：$error\n$stack');
    rethrow;
  }
}

/// 读取实际列表行的备注身份，断言用户看到的排序结果。
List<String> _visibleTransactionIds(WidgetTester tester) => tester
    .widgetList<TransactionListItem>(find.byType(TransactionListItem))
    .map((row) => row.title)
    .toList(growable: false);

/// 覆盖真实页面排序、展示汇总和固定账本上下文，保持存储读取边界可独立替换。
void main() {
  setUp(resetGlobalTestState);
  tearDown(() async {
    try {
      await logger.clear();
    } catch (error, stack) {
      debugPrint('释放分类详情测试日志失败：$error\n$stack');
      rethrow;
    }
  });

  testWidgets('金额排序保留十位小数，不能将不同金额按浮点相等处理', (tester) async {
    final container = _container(
      _queries([
        _transaction(
          '较大',
          amount: '10000000.0000000002',
          nativeAmount: '10000000.0000000002',
          hour: 12,
        ),
        _transaction(
          '较小',
          amount: '10000000.0000000001',
          nativeAmount: '10000000.0000000001',
          hour: 8,
        ),
      ]),
    );
    try {
      await _pumpDetail(tester, container);
      final l10n = lookupAppLocalizations(const Locale('zh'));
      await tester.tap(find.text(l10n.categoryDetailSortAmountAsc));
      await tester.pumpAndSettle();
      expect(_visibleTransactionIds(tester), ['较小', '较大']);
      await tester.tap(find.text(l10n.categoryDetailSortAmountDesc));
      await tester.pumpAndSettle();
      expect(_visibleTransactionIds(tester), ['较大', '较小']);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });

  testWidgets('真实分类详情四种排序按时间和本位币数值排列，切本不替换原查询', (tester) async {
    final queries = _queries([
      _transaction(
        '外币折算9.99',
        amount: '5000',
        nativeAmount: '9.99',
        hour: 12,
        currencyCode: 'JPY',
      ),
      _transaction(
        '本币10.00',
        amount: '10.00',
        nativeAmount: '10.00',
        hour: 8,
        categoryId: 'child',
      ),
      _transaction('本币30.00', amount: '30.00', nativeAmount: '30.00', hour: 10),
    ]);
    final container = _container(queries);
    final l10n = lookupAppLocalizations(const Locale('zh'));
    try {
      await _pumpDetail(tester, container);
      expect(_visibleTransactionIds(tester), [
        '外币折算9.99',
        '本币30.00',
        '本币10.00',
      ]);
      for (final scenario in [
        (
          label: l10n.categoryDetailSortTimeAsc,
          ids: ['本币10.00', '本币30.00', '外币折算9.99'],
        ),
        (
          label: l10n.categoryDetailSortAmountDesc,
          ids: ['本币30.00', '本币10.00', '外币折算9.99'],
        ),
        (
          label: l10n.categoryDetailSortAmountAsc,
          ids: ['外币折算9.99', '本币10.00', '本币30.00'],
        ),
        (
          label: l10n.categoryDetailSortTimeDesc,
          ids: ['外币折算9.99', '本币30.00', '本币10.00'],
        ),
      ]) {
        await tester.tap(find.widgetWithText(ChoiceChip, scenario.label));
        await tester.pumpAndSettle();
        expect(_visibleTransactionIds(tester), scenario.ids);
      }

      container.read(currentLedgerIdProvider.notifier).set('ledger-b');
      await tester.pumpAndSettle();
      expect(_visibleTransactionIds(tester), [
        '外币折算9.99',
        '本币30.00',
        '本币10.00',
      ]);
      verify(
        () => queries.watchTransactionsByCategory(
          'parent',
          ledgerId: 'ledger-a',
          includeSubCategories: true,
        ),
      ).called(1);
      verify(
        () => queries.watchCategoryWithSubs('parent', ledgerId: 'ledger-a'),
      ).called(1);
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('分类详情真实排序及固定账本验证失败：$error\n$stack');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });

  testWidgets('详情汇总包含全部记录并优先折算金额，子分类行使用自身分类', (tester) async {
    final queries = _queries([
      _transaction(
        '外币折算记录',
        amount: '10.00',
        nativeAmount: '72.00',
        hour: 12,
        currencyCode: 'USD',
      ),
      _transaction(
        '第二笔记录',
        amount: '5.00',
        nativeAmount: '5.00',
        hour: 10,
        categoryId: 'child',
      ),
      _transaction('普通记录', amount: '3.00', nativeAmount: '3.00', hour: 8),
    ]);
    final container = _container(queries);
    final l10n = lookupAppLocalizations(const Locale('zh'));
    try {
      await _pumpDetail(tester, container);
      final rows = tester
          .widgetList<TransactionListItem>(find.byType(TransactionListItem))
          .toList();
      expect(rows.map((row) => row.title), ['外币折算记录', '第二笔记录', '普通记录']);
      expect(
        rows.singleWhere((row) => row.title == '第二笔记录').categoryName,
        '早餐',
      );
      expect(
        find.text(l10n.categoryMigrationTransactionLabel(3)),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AmountText && !widget.signed && widget.value == 80,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is AmountText && !widget.signed && widget.value == 80 / 3,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('分类详情真实汇总口径验证失败：$error\n$stack');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    }
  });
}
