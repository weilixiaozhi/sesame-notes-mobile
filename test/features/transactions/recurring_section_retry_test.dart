import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/transactions/presentation/recurring_transaction_section.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 真实周期账单模块的错误、重试和空结果切换保持业务入口及只读限制。
void main() {
  for (final dark in [false, true]) {
    for (final readOnly in [false, true]) {
      testWidgets('深色=$dark，只读=$readOnly：重试重新查询且空结果收起内容', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var queries = 0;
        final retry = Completer<List<RecurringTransactionDisplay>>();
        final l10n = lookupAppLocalizations(const Locale('zh'));
        try {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                recurringTransactionDisplaysProvider.overrideWith((ref) {
                  queries++;
                  return queries == 1
                      ? Stream.error(StateError('内部查询异常'))
                      : Stream.fromFuture(retry.future);
                }),
              ],
              child: MaterialApp(
                theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
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
                  body: RecurringTransactionSection(
                    ledgerId: 'ledger-test',
                    readOnly: readOnly,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(queries, 1);
          expect(find.text(l10n.commonOperationFailed), findsOneWidget);
          expect(find.textContaining('内部查询异常'), findsNothing);
          expect(
            find.text(l10n.recurringTransactionAdd),
            readOnly ? findsNothing : findsOneWidget,
          );

          await tester.tap(find.text(l10n.analyticsRetry));
          await tester.pump();
          await tester.pump();
          expect(queries, 2, reason: '重试必须使原查询失效并重新读取');
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(
            find.byType(AppLoadError),
            findsOneWidget,
            reason: '刷新等待期间保留原有错误提示，完成后再切换结果',
          );
          expect(tester.takeException(), isNull);

          retry.complete([]);
          await tester.pumpAndSettle();
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(
            find.byType(AppEmpty),
            findsNothing,
            reason: '周期账单空结果保持原有收起行为',
          );
          expect(
            find.text(l10n.recurringTransactionAdd),
            readOnly ? findsNothing : findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint('周期账单状态验证失败：深色=$dark，只读=$readOnly，$error');
          debugPrintStack(stackTrace: stack);
          rethrow;
        } finally {
          if (!retry.isCompleted) retry.complete([]);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      });
    }
  }
}
