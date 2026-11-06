import 'package:flutter/material.dart';

import 'keypad_constants.dart';

/// 数字键盘共用三行数字、右侧操作列和四个底行键位的布局。
class NumberKeypadGrid extends StatelessWidget {
  /// 业务仅提供按键内容与交互，网格统一维护尺寸、间距和文字缩放。
  const NumberKeypadGrid({
    super.key,
    required this.digitBuilder,
    required this.sideBuilder,
    required this.bottomBuilder,
  });

  final Widget Function(BuildContext context, String digit, double height)
  digitBuilder;
  final Widget Function(BuildContext context, double height) sideBuilder;

  /// 四个位置保持固定，业务决定日期、小数点、删除和完成等键位的顺序。
  final (Widget, Widget, Widget, Widget) Function(
    BuildContext context,
    double height,
  )
  bottomBuilder;

  /// 数字键和底行始终等宽等高，字形缩放不会改变实际点击区域。
  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaler.scale(1).clamp(0.85, 1.0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = ((constraints.maxHeight - 3 * KeypadLayout.rowGap) / 4)
              .clamp(0.0, double.infinity);
          final width = ((constraints.maxWidth - 3 * KeypadLayout.gap) / 4)
              .clamp(0.0, double.infinity);
          final bottom = bottomBuilder(context, height);
          return Column(
            children: [
              SizedBox(
                key: const ValueKey('keypad_num_grid'),
                height: 3 * height + 2 * KeypadLayout.rowGap,
                child: Row(
                  children: [
                    SizedBox(
                      width: 3 * width + 2 * KeypadLayout.gap,
                      child: Column(
                        children: [
                          for (var row = 0; row < 3; row++) ...[
                            if (row > 0)
                              const SizedBox(height: KeypadLayout.rowGap),
                            Expanded(
                              child: Row(
                                children: [
                                  for (
                                    var column = 0;
                                    column < 3;
                                    column++
                                  ) ...[
                                    if (column > 0)
                                      const SizedBox(width: KeypadLayout.gap),
                                    SizedBox(
                                      width: width,
                                      child: digitBuilder(
                                        context,
                                        '${row * 3 + column + 1}',
                                        height,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: sideBuilder(context, height)),
                  ],
                ),
              ),
              const SizedBox(height: KeypadLayout.rowGap),
              SizedBox(
                key: const ValueKey('keypad_bottom_row'),
                height: height,
                child: Row(
                  // 固定四个槽位保留各业务按键的状态，确认模式变化只更新键内内容。
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: width, child: bottom.$1),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: bottom.$2),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: bottom.$3),
                    const SizedBox(width: KeypadLayout.gap),
                    SizedBox(width: width, child: bottom.$4),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
