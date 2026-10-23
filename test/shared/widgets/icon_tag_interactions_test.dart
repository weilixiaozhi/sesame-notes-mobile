import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/icons/category_icons.dart';

/// 真实明细行的图标、整行和长按保持独立，装饰标签不拦截外层交互。
void main() {
  for (final preset in AppThemePreset.values) {
    for (final dark in [false, true]) {
      testWidgets('$preset 深色=$dark：图标复用保留尺寸、回退和点击边界', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var iconTaps = 0;
        var rowTaps = 0;
        var longPresses = 0;
        var categoryTaps = 0;
        var tagTaps = 0;
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: dark
                  ? AppTheme.darkTheme(preset: preset)
                  : AppTheme.lightTheme(preset: preset),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: Scaffold(
                body: Column(
                  children: [
                    DetailListItem(
                      title: '列表行',
                      subtitle: const SizedBox.shrink(),
                      onTap: () => rowTaps++,
                      onLongPress: () => longPresses++,
                      leading: DetailListIcon(
                        key: const ValueKey('独立图标'),
                        onTap: () => iconTaps++,
                        child: const Icon(AppIcons.category),
                      ),
                    ),
                    Row(
                      children: [
                        for (final size in [28.0, 32.0, 36.0, 40.0])
                          InkWell(
                            onTap: () => categoryTaps++,
                            child: CategoryIconWidget(
                              key: ValueKey('分类-$size'),
                              iconName: 'unknown-icon',
                              size: 18,
                              backgroundSize: size,
                              showBackground: true,
                            ),
                          ),
                      ],
                    ),
                    InkWell(
                      onTap: () => tagTaps++,
                      child: const DetailListTag(label: '角色徽标'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await tester.tap(find.byKey(const ValueKey('独立图标')));
          expect(iconTaps, 1);
          expect(rowTaps, 0, reason: '图标的独立操作不能触发行操作');
          await tester.tap(find.text('列表行'));
          expect(rowTaps, 1);
          await tester.longPress(find.text('列表行'));
          expect(longPresses, 1);
          expect(rowTaps, 1, reason: '长按不附带触发普通点击');

          for (final size in [28.0, 32.0, 36.0, 40.0]) {
            final icon = find.byKey(ValueKey('分类-$size'));
            expect(tester.getSize(icon), Size.square(size));
            expect(
              tester
                  .widget<Icon>(
                    find.descendant(of: icon, matching: find.byType(Icon)),
                  )
                  .icon,
              lucideFallback,
            );
            await tester.tap(icon);
          }
          expect(categoryTaps, 4, reason: '无独立回调的图标底板必须由外层分类项响应点击');
          await tester.tap(find.text('角色徽标'));
          expect(tagTaps, 1, reason: '纯展示徽标不吞掉父项操作');
          expect(tester.takeException(), isNull);
        } catch (error, stack) {
          debugPrint('图标与标签交互验证失败：$preset 深色=$dark，$error');
          debugPrintStack(stackTrace: stack);
          rethrow;
        }
      });
    }
  }
}
