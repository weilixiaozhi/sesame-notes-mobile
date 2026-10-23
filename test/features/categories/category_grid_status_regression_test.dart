import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_grid_section.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 在短视口内滚动到真实管理入口，验证跳转后仍能返回原分类选择区。
Future<void> _visitManagement(WidgetTester tester, GoRouter router) async {
  try {
    final entry = find.byKey(const ValueKey('category-edit-entry'));
    expect(entry, findsOneWidget, reason: '各状态均只能提供一个分类管理入口');
    await tester.ensureVisible(entry);
    await tester.pump();
    await tester.tap(entry);
    // 加载态包含持续转圈，路由往返只推进有限帧，不等待动画静止。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      find.byKey(const ValueKey('category-management-target')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(entry, findsOneWidget);
    expect(tester.takeException(), isNull);
  } catch (error, stack) {
    debugPrint('分类状态管理入口往返验证失败：$error');
    debugPrintStack(stackTrace: stack);
    rethrow;
  }
}

/// 使用真实分类区验证加载、错误重试与空树，固定账本和当前账本分别隔离查询。
void main() {
  for (final fixedLedger in [false, true]) {
    for (final dark in [false, true]) {
      testWidgets('固定账本=$fixedLedger，深色=$dark：分类状态保留重试和管理入口', (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final initial = StreamController<CategoryPickerTree>.broadcast();
        final retry = StreamController<CategoryPickerTree>.broadcast();
        final l10n = lookupAppLocalizations(const Locale('zh'));
        final ledger = LedgerDisplayItem(
          id: 'status-ledger',
          name: '状态验证账本',
          currency: 'CNY',
          transactionCount: 0,
          expenseTotal: 0,
          lastUpdated: DateTime(2026, 1, 1),
        );
        var currentQueries = 0;
        var fixedQueries = 0;
        var unavailable = 0;
        var selections = 0;
        final container = ProviderContainer(
          retry: (_, _) => null,
          overrides: [
            currentLedgerDisplayProvider.overrideWithValue(AsyncData(ledger)),
            ledgerDisplayByIdProvider.overrideWith(
              (ref, id) => AsyncData(ledger),
            ),
            categoryPickerTreeProvider.overrideWith((ref, kind) {
              currentQueries++;
              return currentQueries == 1 ? initial.stream : retry.stream;
            }),
            categoryPickerTreeForLedgerProvider.overrideWith((ref, query) {
              fixedQueries++;
              return fixedQueries == 1 ? initial.stream : retry.stream;
            }),
          ],
        );
        container.read(currentLedgerIdProvider.notifier).set(ledger.id);
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => Scaffold(
                body: Center(
                  child: SizedBox(
                    height: 120,
                    child: CategoryGridSection(
                      ledgerId: fixedLedger ? ledger.id : null,
                      onCategorySelected: (_) => selections++,
                      onSelectionUnavailable: () => unavailable++,
                    ),
                  ),
                ),
              ),
            ),
            GoRoute(
              name: Routes.categoryManage,
              path: Routes.categoryManage,
              builder: (context, state) => const Scaffold(
                body: Center(
                  child: Text(
                    '分类管理目标页',
                    key: ValueKey('category-management-target'),
                  ),
                ),
              ),
            ),
          ],
        );

        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp.router(
                routerConfig: router,
                theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
                locale: const Locale('zh'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(2.0)),
                  child: child!,
                ),
              ),
            ),
          );
          await tester.pump();
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.byType(AppEmpty), findsNothing);
          expect(find.byType(AppLoadError), findsNothing);
          expect(find.text(l10n.categoryEmpty), findsNothing);
          expect(unavailable, 0, reason: '等待查询期间不能把分类判为空或不可用');
          await _visitManagement(tester, router);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          initial.addError(StateError('分类内部查询异常'), StackTrace.current);
          await tester.pump();
          await tester.pump();
          expect(find.byType(AppLoadError), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.text(l10n.categoryEmpty), findsNothing);
          expect(find.textContaining('分类内部查询异常'), findsNothing);
          expect(unavailable, 1, reason: '查询失败必须通知编辑器阻断无效分类提交');
          await _visitManagement(tester, router);

          final retryButton = find.text(l10n.commonRetry);
          await tester.ensureVisible(retryButton);
          await tester.pump();
          await tester.tap(retryButton);
          await tester.pump();
          await tester.pump();
          expect(currentQueries, fixedLedger ? 0 : 2);
          expect(fixedQueries, fixedLedger ? 2 : 0);
          expect(find.text(l10n.categoryEmpty), findsNothing);
          expect(
            find.byKey(const ValueKey('category-edit-entry')),
            findsOneWidget,
          );

          retry.add(CategoryPickerTree.empty);
          await tester.pumpAndSettle();
          expect(find.byType(AppLoadError), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(find.byType(AppEmpty), findsOneWidget);
          expect(find.text(l10n.categoryEmpty), findsOneWidget);
          expect(find.text(l10n.txEditCategory), findsOneWidget);
          expect(selections, 0, reason: '失败和空树均不能触发分类选中回调');
          await _visitManagement(tester, router);
          expect(currentQueries, fixedLedger ? 0 : 2);
          expect(fixedQueries, fixedLedger ? 2 : 0);
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint(
            '分类状态回归验证失败：固定账本=$fixedLedger，深色=$dark，'
            '当前查询=$currentQueries，固定查询=$fixedQueries，$error',
          );
          debugPrintStack(stackTrace: stack);
          rethrow;
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          router.dispose();
          container.dispose();
          await initial.close();
          await retry.close();
        }
      });
    }
  }
}
