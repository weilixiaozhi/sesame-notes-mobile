import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/auth/presentation/phone_region_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/sheet_grab_handle.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 打开区号选择弹层，并记录用户最终选择的区号。
  Future<ValueNotifier<PhoneRegion?>> pumpSheet(
    WidgetTester tester, {
    PhoneRegion selected = PhoneRegion.defaultRegion,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final result = ValueNotifier<PhoneRegion?>(null);
    addTearDown(result.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result.value = await showPhoneRegionSheet(
                  context,
                  selected: selected,
                );
              },
              child: const Text('选择区号'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, '选择区号'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('Bottom Sheet：展示拖拽条、当前选中态和设计稿区号列表', (tester) async {
    await pumpSheet(tester, selected: PhoneRegion.common[1]);

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.byType(SheetGrabHandle), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('选择区号'),
      ),
      findsOneWidget,
    );
    expect(find.text('美国 / 加拿大'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(10));

    final selectedRow = find.ancestor(
      of: find.text('中国香港'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(of: selectedRow, matching: find.byIcon(AppIcons.check)),
      findsOneWidget,
    );
    final selectedRowContainer = find.ancestor(
      of: selectedRow,
      matching: find.byWidgetPredicate(
        (widget) => widget is Container && widget.constraints?.maxHeight == 52,
      ),
    );
    expect(tester.getSize(selectedRowContainer.first).height, 52);
  });

  testWidgets('点击区号后关闭 Bottom Sheet 并返回所选项', (tester) async {
    final result = await pumpSheet(tester);

    await tester.tap(find.text('中国澳门'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsNothing);
    expect(result.value?.code, '+853');
  });
}
