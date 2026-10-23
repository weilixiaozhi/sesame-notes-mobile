import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/currency_picker_sheet.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/recurring_time_zone_picker.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/aa_payer_picker_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/shared/widgets/wheel_date_picker.dart';
import 'package:sesame_notes/shared/widgets/wheel_picker.dart';
import 'package:sesame_notes/theme/app_theme.dart';

enum _PickerCase {
  radioImmediate,
  radioConfirm,
  payer,
  currency,
  timeZone,
  wheel,
  date,
}

/// 每类选择器使用真实公开入口，保持各自的即时选择或确认提交方式。
Future<Object?> _openPicker(BuildContext context, _PickerCase picker) {
  switch (picker) {
    case _PickerCase.radioImmediate:
    case _PickerCase.radioConfirm:
      return showAppRadioSheet<String>(
        context,
        title: '选择选项',
        selected: 'original',
        options: const {'original': '原选项', 'updated': '新选项'},
        confirmSelection: picker == _PickerCase.radioConfirm,
      );
    case _PickerCase.payer:
      return showAaPayerPickerSheet(
        context,
        ledgerId: 'double-tap-ledger',
        selectedId: 'original',
        options: const [
          AaParticipantOption(id: 'original', name: '原支出人', isVirtual: true),
          AaParticipantOption(id: 'updated', name: '新支出人', isVirtual: true),
        ],
      );
    case _PickerCase.currency:
      return showCurrencyPickerSheet(
        context,
        title: '选择币种',
        selected: 'CNY',
        visibleCurrencies: const {'CNY', 'USD'},
      );
    case _PickerCase.timeZone:
      return showRecurringTimeZonePicker(context, selected: 'UTC');
    case _PickerCase.wheel:
      return showWheelPicker<String>(
        context,
        initial: 'original',
        items: const ['original', 'updated'],
        labelBuilder: (value) => value == 'original' ? '原选项' : '新选项',
        title: '滚轮选择',
      );
    case _PickerCase.date:
      return showWheelDatePicker(
        context,
        initial: DateTime(2026, 10, 16),
        minDate: DateTime(2026, 1, 1),
        maxDate: DateTime(2026, 12, 31),
        title: '日期选择',
        confirmLabel: '提交日期',
      );
  }
}

/// 主页面下再压入二级编辑页，避免首屏不能返回而掩盖重复 pop。
Future<void> _pumpLauncher(
  WidgetTester tester, {
  required GlobalKey<NavigatorState> navigatorKey,
  required _PickerCase picker,
  required ValueChanged<Object?> onResult,
}) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ledgerIdentityProvider.overrideWith(
          (ref, ledgerId) async => const LedgerIdentity(
            selfMemberId: '',
            localSelfName: '本人',
            unknownName: '未知参与人',
          ),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme(),
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, page) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: page!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (pageContext) => Scaffold(
                    appBar: AppBar(title: const Text('二级编辑页面')),
                    body: Center(
                      child: TextButton(
                        onPressed: () async {
                          final result = await _openPicker(pageContext, picker);
                          onResult(result);
                        },
                        child: const Text('打开选择弹层'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('打开二级页面'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('打开二级页面'));
  await tester.pumpAndSettle();
  expect(navigatorKey.currentState!.canPop(), isTrue);
  await tester.tap(find.text('打开选择弹层'));
  await tester.pumpAndSettle();
}

/// 定位用户真正点击的选项或确认按钮，不直接调用组件回调。
Finder _submitTarget(_PickerCase picker) {
  switch (picker) {
    case _PickerCase.radioImmediate:
      return find.text('新选项');
    case _PickerCase.radioConfirm:
      return find.text('确定');
    case _PickerCase.payer:
      return find.text('新支出人');
    case _PickerCase.currency:
      return find.byWidgetPredicate(
        (widget) => widget is AppRadioTile && widget.title.contains('(USD)'),
      );
    case _PickerCase.timeZone:
      return find.text('UTC');
    case _PickerCase.wheel:
      return find.text('确定');
    case _PickerCase.date:
      return find.text('提交日期');
  }
}

/// 连续点击会在首个退场帧绘制前落到原控件上，弹层只能处理首次提交。
void main() {
  for (final picker in _PickerCase.values) {
    testWidgets('$picker：快速连点只提交一次且保留二级编辑页面', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final results = <Object?>[];
      try {
        await _pumpLauncher(
          tester,
          navigatorKey: navigatorKey,
          picker: picker,
          onResult: results.add,
        );
        if (picker == _PickerCase.radioConfirm) {
          await tester.tap(find.text('新选项'));
          await tester.pumpAndSettle();
          expect(results, isEmpty, reason: '确认前只能改变弹层草稿');
        }
        final target = _submitTarget(picker);
        expect(target, findsOneWidget);
        expect(tester.takeException(), isNull);
        final position = tester.getCenter(target);
        // 两次点击间不推进绘制帧，覆盖弹层开始关闭但旧控件仍可命中的窗口。
        await tester.tapAt(position);
        await tester.tapAt(position);
        await tester.pumpAndSettle();
        expect(results, hasLength(1), reason: '弹层退场期间只能提交一次结果');
        expect(results.single, isNotNull);
        expect(find.text('二级编辑页面'), findsOneWidget, reason: '后续点击不能继续关闭父编辑页面');
        expect(find.text('打开选择弹层'), findsOneWidget);
        expect(find.text('打开二级页面'), findsNothing);
        expect(
          navigatorKey.currentState!.canPop(),
          isTrue,
          reason: '只能弹出选择器这一层路由',
        );
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('选择器快速连点回归失败：$picker，结果=$results，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }
}
