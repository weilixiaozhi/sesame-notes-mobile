import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_action_grid.dart';
import 'package:sesame_notes/shared/widgets/app_search_field.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

import '../helpers/test_isolation.dart';

/// 在手机视口和放大文字下构建真实公共入口。
Future<void> _open(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(320, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, page) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.3)),
        child: page!,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppDimens.p16),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 检查搜索草稿反馈和创建弹层结果，业务查询与创建操作由调用方负责。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  testWidgets('搜索草稿即时显示清除，清除与程序回填不重复触发查询', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final queries = <String>[];
    var cleared = 0;
    var enabled = true;
    late StateSetter update;
    await _open(
      tester,
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return AppSearchField(
            controller: controller,
            hintText: '搜索',
            enabled: enabled,
            onChanged: queries.add,
            onClear: () {
              cleared++;
              controller.clear();
            },
          );
        },
      ),
    );
    expect(find.byIcon(AppIcons.close), findsNothing);
    await tester.enterText(find.byType(TextField), '关键词');
    await tester.pump();
    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(queries, ['关键词']);
    await tester.tap(find.byIcon(AppIcons.close));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(cleared, 1);
    expect(queries, ['关键词']);
    expect(find.byIcon(AppIcons.close), findsNothing);

    controller.text = '程序回填';
    await tester.pump();
    expect(find.byIcon(AppIcons.close), findsOneWidget);
    expect(queries, ['关键词']);
    update(() => enabled = false);
    await tester.pump();
    await tester.tapAt(tester.getCenter(find.byIcon(AppIcons.close)));
    await tester.pump();
    expect(controller.text, '程序回填');
    expect(cleared, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('创建弹层返回所选动作，取消返回空值且不遗留路由', (tester) async {
    String? result;
    var completions = 0;
    await _open(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            result = await showCreateActionSheet<String>(
              context,
              actions: const [
                (value: 'memo', icon: AppIcons.edit, label: '新建笔记'),
                (
                  value: 'day',
                  icon: AppIcons.calendar,
                  label: '创建需要完整显示名称的纪念日',
                ),
              ],
            );
            completions++;
          },
          child: const Text('打开创建'),
        ),
      ),
    );
    await tester.tap(find.text('打开创建'));
    await tester.pumpAndSettle();
    expect(find.byType(AppSheet), findsOneWidget);
    await tester.tap(find.text('创建需要完整显示名称的纪念日'));
    await tester.pumpAndSettle();
    expect(result, 'day');
    expect(completions, 1);
    expect(find.byType(AppSheet), findsNothing);

    await tester.tap(find.text('打开创建'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(result, isNull);
    expect(completions, 2);
    expect(find.byType(AppSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
