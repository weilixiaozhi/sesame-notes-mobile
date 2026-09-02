/// LedgerSelectorDialog 账本列表 future 缓存回归测试。
///
/// 账本列表 future 由 State 持有，父级重建复用缓存，不重复查 DB。
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart' show Ledger;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/ledger_selector_dialog.dart';

class _MockRepo extends Mock implements LocalRepository {}

Ledger _ledger(String id, String name) => Ledger(
  id: id,
  name: name,
  currency: 'CNY',
  role: 'owner',
  memberCount: 1,
  monthStartDay: 1,
  storageMode: 'local',
  aaEnabled: false,
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getAllLedgers()).thenAnswer(
      (_) async => [_ledger('ledger-1', '账本一'), _ledger('ledger-2', '账本二')],
    );
  });

  Widget buildApp(ValueNotifier<int> trigger) {
    return ProviderScope(
      overrides: [repositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: ValueListenableBuilder<int>(
          valueListenable: trigger,
          builder: (context, _, _) => Scaffold(
            body: Center(
              child: LedgerSelectorDialog(currentLedgerId: 'ledger-1'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('父级重建不再重复查询账本列表', (tester) async {
    var queries = 0;
    when(() => repo.getAllLedgers()).thenAnswer((_) async {
      queries++;
      return [_ledger('ledger-1', '账本一'), _ledger('ledger-2', '账本二')];
    });

    final trigger = ValueNotifier<int>(0);
    await tester.pumpWidget(buildApp(trigger));
    await tester.pumpAndSettle();

    expect(find.text('账本一'), findsOneWidget);
    expect(find.text('账本二'), findsOneWidget);
    expect(queries, 1);

    // 触发父级重建：State 保留，future 缓存命中，不查 DB
    trigger.value++;
    await tester.pumpAndSettle();

    expect(queries, 1);
    expect(find.text('账本一'), findsOneWidget);
  });
}
