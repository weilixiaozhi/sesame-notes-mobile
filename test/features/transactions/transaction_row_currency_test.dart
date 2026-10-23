import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart' show Ledger;
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';

/// 固定记录详情不会因首页选中了另一种本位币而隐藏或误标折算快照。
void main() {
  testWidgets('A 人民币账本的美元记录不受首页美元账本影响', (tester) async {
    final date = DateTime.utc(2026);

    /// 账本本位币由显式身份给出，避免测试也借用当前本。
    Ledger ledger(String id, String currency) => Ledger(
      id: id,
      name: id,
      currency: currency,
      monthStartDay: 1,
      aaEnabled: false,
      role: 'owner',
      memberCount: 1,
      storageMode: 'local',
      createdAt: date,
      updatedAt: date,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentLedgerProvider.overrideWith(
            (ref) => Stream.value(ledger('b', 'USD')),
          ),
          ledgerByIdProvider.overrideWith(
            (ref, id) async => ledger(id, id == 'a' ? 'CNY' : 'USD'),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: TransactionListItem(
              ledgerId: 'a',
              title: '原本交易',
              amount: '10',
              currencyCode: 'USD',
              nativeAmount: '70',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('≈ ${getCurrencySymbol('CNY')} 70.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
