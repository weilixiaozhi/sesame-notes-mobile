import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/aa_payer_picker_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/shared/providers/ledger_identity_providers.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 使用真实弹层入口和导航往返，在窄屏大字号下验证选择结果的提交时机。
Future<void> _pumpSelectionLauncher(
  WidgetTester tester, {
  required bool dark,
  required Future<void> Function(BuildContext) onOpen,
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
            localSelfName: '单机芝麻仔',
            unknownName: '未知参与人',
          ),
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
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
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

/// 选择器分别保留即时选择、确认提交和取消丢弃草稿的导航契约。
void main() {
  for (final dark in [false, true]) {
    testWidgets('单选深色=$dark：即时模式点选返回，再次取消不改变结果', (tester) async {
      var selected = 'original';
      final results = <String?>[];
      try {
        await _pumpSelectionLauncher(
          tester,
          dark: dark,
          onOpen: (context) async {
            final result = await showAppRadioSheet<String>(
              context,
              title: '选择排序',
              selected: selected,
              options: const {'original': '按时间排序', 'amount': '按金额排序'},
              confirmSelection: false,
            );
            results.add(result);
            if (result != null) selected = result;
          },
        );
        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('按金额排序'));
        await tester.pumpAndSettle();
        expect(results, ['amount']);
        expect(selected, 'amount');
        expect(find.text('选择排序'), findsNothing);

        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(results, ['amount', null]);
        expect(selected, 'amount');
        expect(find.text('选择排序'), findsNothing);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('即时单选交互验证失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });

    testWidgets('单选深色=$dark：确认模式选项只更新草稿，确认后提交', (tester) async {
      var selected = 'original';
      final results = <String?>[];
      try {
        await _pumpSelectionLauncher(
          tester,
          dark: dark,
          onOpen: (context) async {
            final result = await showAppRadioSheet<String>(
              context,
              title: '选择选项',
              selected: selected,
              options: const {'original': '原选项', 'updated': '新选项'},
            );
            results.add(result);
            if (result != null) selected = result;
          },
        );
        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('新选项'));
        await tester.pumpAndSettle();
        expect(selected, 'original');
        expect(results, isEmpty);
        expect(find.text('选择选项'), findsOneWidget);

        await tester.tap(find.text('确定'));
        await tester.pumpAndSettle();
        expect(results, ['updated']);
        expect(selected, 'updated');
        expect(find.text('选择选项'), findsNothing);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('确认单选提交验证失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });

    testWidgets('单选深色=$dark：取消丢弃草稿，重新打开直接确认保留原值', (tester) async {
      var selected = 'original';
      final results = <String?>[];
      try {
        await _pumpSelectionLauncher(
          tester,
          dark: dark,
          onOpen: (context) async {
            final result = await showAppRadioSheet<String>(
              context,
              title: '选择选项',
              selected: selected,
              options: const {'original': '原选项', 'updated': '新选项'},
              confirmSelection: true,
            );
            results.add(result);
            if (result != null) selected = result;
          },
        );
        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('新选项'));
        await tester.pumpAndSettle();
        expect(results, isEmpty);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(results, [null]);
        expect(selected, 'original');

        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('确定'));
        await tester.pumpAndSettle();
        expect(results, [null, 'original']);
        expect(selected, 'original');
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('确认单选取消验证失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });

    testWidgets('支出人深色=$dark：窄屏大字号长姓名可选择，取消保留原支出人', (tester) async {
      const longName = '这是一位姓名很长的虚拟参与人用于验证窄屏大字号选择时仍能正常展示和点击';
      const options = [
        AaParticipantOption(id: 'original', name: '原支出人', isVirtual: true),
        AaParticipantOption(id: 'long-name', name: longName, isVirtual: true),
      ];
      var selected = 'original';
      final results = <String?>[];
      try {
        await _pumpSelectionLauncher(
          tester,
          dark: dark,
          onOpen: (context) async {
            final result = await showAaPayerPickerSheet(
              context,
              ledgerId: 'selection-flow-ledger',
              options: options,
              selectedId: selected,
            );
            results.add(result);
            if (result != null) selected = result;
          },
        );
        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        expect(find.text('原支出人'), findsOneWidget);
        expect(find.text(longName), findsOneWidget);
        expect(tester.takeException(), isNull, reason: '长姓名不能造成布局溢出');
        await tester.tap(find.text(longName));
        await tester.pumpAndSettle();
        expect(results, ['long-name']);
        expect(selected, 'long-name');
        expect(find.text('支出人'), findsNothing);

        await tester.tap(find.text('打开选择'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '选中长姓名后重新打开也应正常显示');
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(results, ['long-name', null]);
        expect(selected, 'long-name');
        expect(find.text('支出人'), findsNothing);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        debugPrint('支出人选择交互验证失败：深色=$dark，$error');
        debugPrintStack(stackTrace: stack);
        rethrow;
      }
    });
  }
}
