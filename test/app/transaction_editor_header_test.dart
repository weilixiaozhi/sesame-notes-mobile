/// 记账编辑器头部回归测试。
///
/// 需求锚点：全局文字 ×0.85 缩放后，头部「记一笔」标题变小，
/// 但 AA 分摊方式按钮仍是原尺寸显得偏大——按钮需同步缩小，
/// 且缩小后圆角按比例减少（5px → 4px）。
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/models/category_picker_tree.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_editor_sheet_entry.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AA 开启时头部按钮缩小：80x24、圆角 4、字号 12', (tester) async {
    final repo = _MockRepo();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          currentLedgerIdProvider.overrideWithBuild(
            (ref, notifier) => 'ledger-1',
          ),
          // AA 开启的账本：头部展示分摊方式按钮
          currentLedgerProvider.overrideWith(
            (ref) => Stream<db.Ledger?>.value(
              db.Ledger(
                id: 'ledger-1',
                name: '测试账本',
                currency: 'CNY',
                role: 'owner',
                memberCount: 1,
                monthStartDay: 1,
                storageMode: 'local',
                aaEnabled: true,
                createdAt: DateTime(2026, 8, 8),
                updatedAt: DateTime(2026, 8, 8),
              ),
            ),
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('zh'),
          routerConfig: createAppRouter(
            home: () => Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showTransactionEditorSheet(context),
                    child: const Text('open-sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open-sheet'));
    await tester.pumpAndSettle();

    final toggle = find.byKey(const ValueKey('editor_aa_mode_toggle'));
    expect(toggle, findsOneWidget, reason: 'AA 开启时头部应展示分摊方式按钮');

    final size = tester.getSize(toggle);
    expect(size.width, 80, reason: '按钮宽度应随标题缩小（88 → 80）');
    expect(size.height, 24, reason: '按钮高度应随标题缩小（28 → 24）');

    final box = tester.widget<Container>(toggle);
    final deco = box.decoration! as BoxDecoration;
    expect(
      deco.borderRadius,
      BorderRadius.circular(4),
      reason: '按钮缩小后圆角应同步减少（5 → 4）',
    );

    final modeText = tester.widget<Text>(
      find.descendant(of: toggle, matching: find.text('人均分摊')),
    );
    expect(modeText.style?.fontSize, 12, reason: '按钮字号保持 12');
    expect(
      find.byType(TransactionEditorSheet),
      findsOneWidget,
      reason: '记账编辑器应正常打开',
    );
  });
}
