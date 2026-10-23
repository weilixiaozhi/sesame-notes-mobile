import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/currency_picker_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/recurring_time_zone_picker.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:timezone/data/latest.dart' as tz;

/// 从真实入口打开选择弹层，统一在窄屏大字号下验证完整路由往返。
Future<void> _pumpLauncher(
  WidgetTester tester, {
  required Future<void> Function(BuildContext) onOpen,
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currencyPickerRatesProvider.overrideWith(
          (ref, base) async => {'USD': 7.2},
        ),
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
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => onOpen(context),
              child: const Text('打开选择'),
            ),
          ),
        ),
      ),
    ),
  );
}

/// 选择行只负责返回值，筛选、当前值兜底及取消约定保持由原弹层维护。
void main() {
  setUpAll(tz.initializeTimeZones);
  for (final dark in [false, true]) {
    for (final compact in [false, true]) {
      testWidgets('币种深色=$dark，紧凑=$compact：搜索选中返回，取消保留原值', (tester) async {
        var selected = 'CNY';
        var completed = 0;
        try {
          await _pumpLauncher(
            tester,
            dark: dark,
            onOpen: (context) async {
              final result = await showCurrencyPickerSheet(
                context,
                selected: selected,
                title: '选择币种',
                visibleCurrencies: {'USD'},
                compact: compact,
                showRateAsBaseLabel: compact,
                rateBase: compact ? 'CNY' : null,
              );
              if (result != null) selected = result;
              completed++;
            },
          );
          await tester.tap(find.text('打开选择'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('(CNY)'),
            findsOneWidget,
            reason: '当前币种即使被可见集合过滤，也必须保留',
          );
          await tester.enterText(find.byType(TextField), 'usd');
          await tester.pumpAndSettle();
          expect(find.textContaining('(CNY)'), findsNothing);
          if (compact) expect(find.textContaining('1 USD'), findsOneWidget);
          await tester.tap(find.textContaining('(USD)'));
          await tester.pumpAndSettle();
          expect(selected, 'USD');
          expect(completed, 1);
          expect(find.byType(TextField), findsNothing);

          await tester.tap(find.text('打开选择'));
          await tester.pumpAndSettle();
          await tester.binding.handlePopRoute();
          await tester.pumpAndSettle();
          expect(selected, 'USD');
          expect(completed, 2);
          expect(find.text('打开选择'), findsOneWidget);
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint('币种选择交互验证失败：深色=$dark，紧凑=$compact，$error');
          debugPrintStack(stackTrace: stack);
          rethrow;
        }
      });
    }
  }

  testWidgets('时区搜索后选中返回名称，再次打开取消不改变选中值', (tester) async {
    var selected = 'UTC';
    try {
      await _pumpLauncher(
        tester,
        onOpen: (context) async {
          final result = await showRecurringTimeZonePicker(
            context,
            selected: selected,
          );
          if (result != null) selected = result;
        },
      );
      await tester.tap(find.text('打开选择'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'asia/shanghai');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Asia/Shanghai'));
      await tester.pumpAndSettle();
      expect(selected, 'Asia/Shanghai');

      await tester.tap(find.text('打开选择'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(selected, 'Asia/Shanghai');
      expect(find.text('打开选择'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } catch (error, stack) {
      debugPrint('时区选择交互验证失败：$error');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  });
}
