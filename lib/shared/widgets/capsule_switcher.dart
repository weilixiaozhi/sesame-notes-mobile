import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 胶囊选项配置
class CapsuleOption<T> {
  final T value;
  final String label;

  const CapsuleOption({required this.value, required this.label});
}

/// 通用胶囊切换器组件
class CapsuleSwitcher<T> extends StatelessWidget {
  final T selectedValue;
  final List<CapsuleOption<T>> options;
  final ValueChanged<T>? onChanged;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final double height;
  final bool compact;
  final BorderRadius? borderRadius;
  final BorderRadius? segmentBorderRadius;
  final List<BoxShadow>? selectedShadows;

  /// 嵌入窄工具栏时可缩小分段留白，保留完整标签和按钮高度。
  final double? segmentHorizontalPadding;

  const CapsuleSwitcher({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.height = AppDimens.p40,
    this.compact = false,
    this.borderRadius,
    this.segmentBorderRadius,
    this.selectedShadows,
    this.segmentHorizontalPadding,
  });

  /// 每个分段独立提供选中、可用及点击语义，内容按现有胶囊布局显示。
  @override
  Widget build(BuildContext context) {
    // 空选项降级为空容器：options.length * 2 - 1 在空列表时为 -1，
    // take(-1) 会抛 RangeError，未来新增入口直接传空列表也不应崩溃。
    if (options.isEmpty) return const SizedBox.shrink();

    final isDark = AppTokens.isDark(context);
    final controlHeight = compact ? AppDimens.p32 : height;
    final enabled = onChanged != null;
    final bg = backgroundColor ?? AppTokens.surfaceCapsule(context);
    final selectedBg = !enabled
        ? AppTokens.surfaceSecondary(context)
        : selectedBackgroundColor ??
              (isDark
                  ? AppTokens.primary(context)
                  : AppTokens.surfaceInverse(context));
    final selectedFg = !enabled
        ? AppTokens.textDisabled(context)
        : selectedTextColor ?? AppTokens.textOnPrimary(context);
    final unselectedFg = !enabled
        ? AppTokens.textDisabled(context)
        : unselectedTextColor ?? AppTokens.textPrimary(context);
    final radius = borderRadius ?? BorderRadius.circular(AppDimens.radius20);

    /// 独立分段提供点击语义，底色以固定色相淡入淡出，文字随选中状态更新。
    Widget buildSegment(CapsuleOption<T> option) {
      final selected = selectedValue == option.value;
      // 分段圆角与选中态底色变化保持一致；选中变色即反馈，按统一原则不加涟漪
      final radius =
          segmentBorderRadius ??
          BorderRadius.circular((controlHeight - AppDimens.p8) / 2);
      return Expanded(
        child: Semantics(
          // 每段是独立按钮节点，日期输入行的标签不能合并其选中与点击状态。
          container: true,
          button: true,
          selected: selected,
          enabled: enabled,
          inMutuallyExclusiveGroup: true,
          onTap: enabled ? () => onChanged!(option.value) : null,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              // 禁用分段仍吸收命中，防止点击传给外层日期行；辅助功能不暴露禁用动作。
              excludeFromSemantics: true,
              onTap: () => onChanged?.call(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: controlHeight - AppDimens.p8,
                decoration: BoxDecoration(
                  // 空底色让动画只插值透明度，淡入淡出时保持主题底色的色相。
                  color: selected ? selectedBg : null,
                  borderRadius: radius,
                  boxShadow: selected ? selectedShadows : null,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal:
                      segmentHorizontalPadding ??
                      (compact ? AppDimens.p8 : AppDimens.p12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // 段内宽度由 Expanded 均分后可能小于英文长标签（如 Week/Month/Year）
                    // 的自然宽度，直接放 Text 会触发 RenderFlex overflow；
                    // 用 FittedBox(scaleDown) 让标签在放不下时等比缩小、放得下时保持原样。
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          option.label,
                          maxLines: 1,
                          softWrap: false,
                          style:
                              (compact
                                      ? AppTextTokens.label(context)
                                      : Theme.of(context).textTheme.bodyMedium)
                                  ?.copyWith(
                                    color: selected ? selectedFg : unselectedFg,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: controlHeight,
      padding: const EdgeInsets.all(AppDimens.p4),
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: Row(
        children: options
            .map((option) => buildSegment(option))
            .expand((widget) => [widget, const SizedBox(width: AppDimens.p4)])
            .take(options.length * 2 - 1) // 移除最后一个SizedBox
            .toList(),
      ),
    );
  }
}
