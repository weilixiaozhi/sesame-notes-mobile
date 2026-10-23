import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/db.dart' show Ledger;
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_aa_edit_utils.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

/// 读取分摊为空，测试只检查实际导航参数中的账本边界。
class _Actions extends Fake implements TransactionActions {
  /// 本例为未配置指定分摊的交易。
  @override
  Future<List<TransactionSplitDisplay>> getSplits(String id) async => [];
}

/// 从固定分类详情编辑 A 的记录时，首页选择 B 不能替换参与人名册。
void main() {
  testWidgets('分摊编辑使用交易所属账本而非首页当前账本', (tester) async {
    final date = DateTime.utc(2026);
    final transaction = TransactionDisplay(
      id: 'tx-a',
      ledgerId: 'a',
      txType: 'expense',
      amount: '10',
      happenedAt: date,
      currencyCode: 'CNY',
      nativeAmount: '10',
      version: 1,
      createdAt: date,
      updatedAt: date,
    );

    /// 为每个账本构造独立身份，当前本与交易所属本刻意不同。
    Ledger ledger(String id) => Ledger(
      id: id,
      name: id,
      currency: 'CNY',
      monthStartDay: 1,
      aaEnabled: true,
      role: 'owner',
      memberCount: 1,
      storageMode: 'local',
      createdAt: date,
      updatedAt: date,
    );
    AaEditPageArgs? captured;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => TransactionAaEditUtils.editTransactionAa(
                  context,
                  ref,
                  transaction,
                  null,
                ),
                child: const Text('编辑分摊'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/aa',
          name: Routes.aaEdit,
          builder: (_, state) {
            captured = state.extra! as AaEditPageArgs;
            return const Scaffold(body: Text('分摊名册'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionActionsProvider.overrideWithValue(_Actions()),
          currentLedgerIdProvider.overrideWithBuild((ref, notifier) => 'b'),
          currentLedgerProvider.overrideWith(
            (ref) => Stream.value(ledger('b')),
          ),
          ledgerByIdProvider.overrideWith((ref, id) async => ledger(id)),
          currentAccountIdProvider.overrideWith((ref) => null),
          authIdentityGenerationProvider.overrideWith((ref) => 1),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑分摊'));
    await tester.pumpAndSettle();
    expect(captured?.ledgerId, 'a');
    expect(tester.takeException(), isNull);
    router.pop();
    await tester.pumpAndSettle();
  });
}
