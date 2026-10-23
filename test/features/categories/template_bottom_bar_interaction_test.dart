import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/categories/presentation/category_template_widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';

/// 模板操作使用真实按钮验证可用状态、确认等待和写入期间的交互边界。
void main() {
  for (final preset in AppThemePreset.values) {
    for (final dark in [false, true]) {
      for (final scale in [1.3, 2.0]) {
        testWidgets('$preset 深色=$dark，字号=$scale：窄屏大字号保持全选与提交边界', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var toggles = 0;
          var submissions = 0;
          final l10n = lookupAppLocalizations(const Locale('zh'));

          /// 用业务状态驱动真实操作栏，确认等待期间不启动进度动画。
          Future<void> show({
            required int selectedCount,
            bool allSelected = false,
            bool adding = false,
            bool writing = false,
          }) async {
            await tester.pumpWidget(
              MaterialApp(
                theme: dark
                    ? AppTheme.darkTheme(preset: preset)
                    : AppTheme.lightTheme(preset: preset),
                locale: const Locale('zh'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  bottomNavigationBar: TemplateBottomBar(
                    selectedCount: selectedCount,
                    allSelected: allSelected,
                    isAdding: adding,
                    isWriting: writing,
                    onToggleSelectAll: () => toggles++,
                    onAdd: () => submissions++,
                  ),
                ),
              ),
            );
            // 写入态有持续动画，只推进有限帧以检查布局和输入响应。
            await tester.pump(const Duration(milliseconds: 200));
            expect(tester.takeException(), isNull);
          }

          try {
            await show(selectedCount: 0);
            await tester.tap(find.text(l10n.commonAdd));
            expect(submissions, 0);
            await tester.tap(find.text(l10n.categoryTemplateSelectAll));
            expect(toggles, 1);

            await show(selectedCount: 2, allSelected: true);
            await tester.tap(find.text(l10n.categoryTemplateDeselectAll));
            await tester.tap(find.text(l10n.commonAdd));
            expect(toggles, 2);
            expect(submissions, 1);

            for (final writing in [false, true]) {
              await show(selectedCount: 2, adding: true, writing: writing);
              expect(
                find.byType(CircularProgressIndicator),
                writing ? findsOneWidget : findsNothing,
              );
              await tester.tap(find.text(l10n.commonAdd));
              await tester.tap(find.text(l10n.categoryTemplateSelectAll));
              expect(submissions, 1, reason: '确认等待和写入期间都不能重复提交');
              expect(toggles, 2, reason: '提交期间不能改变模板选择');
              expect(tester.takeException(), isNull);
            }
          } catch (error, stack) {
            debugPrint('模板操作栏交互验证失败：$preset 深色=$dark，$error');
            debugPrintStack(stackTrace: stack);
            rethrow;
          }
        });
      }
    }
  }
}
