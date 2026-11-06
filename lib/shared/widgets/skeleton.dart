import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 加载超过 [DelayedSkeleton.defaultDelay] 才显示骨架，避免快速查询时闪烁。
class DelayedSkeleton extends StatefulWidget {
  static const Duration defaultDelay = Duration(milliseconds: 300);

  final Widget child;

  /// 延迟期间显示的占位。建议传一个等高的 [SizedBox] 避免布局抖动。
  final Widget placeholder;

  /// 快速加载期间使用占位内容，达到统一延迟后显示骨架。
  const DelayedSkeleton({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
  });

  /// 每个加载区域独立维护延迟计时器。
  @override
  State<DelayedSkeleton> createState() => _DelayedSkeletonState();
}

class _DelayedSkeletonState extends State<DelayedSkeleton> {
  bool _show = false;
  Timer? _timer;

  /// 等待统一的三百毫秒后显示骨架，避免快速查询闪烁。
  @override
  void initState() {
    super.initState();
    _timer = Timer(DelayedSkeleton.defaultDelay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  /// 区域离开时取消尚未触发的计时器。
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 计时完成前后只切换当前区域的占位内容。
  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : widget.placeholder;
  }
}

/// 让子组件以"呼吸"动画显示(opacity 在 0.55 ↔ 1.0 之间循环),
/// 比静态灰块更有生命力,告诉用户"正在加载"。
class PulseSkeleton extends StatefulWidget {
  final Widget child;

  /// 骨架内容共用固定的呼吸节奏。
  const PulseSkeleton({super.key, required this.child});

  /// 呼吸动画与当前区域一起创建和释放。
  @override
  State<PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  /// 区域离开时释放持续播放的动画控制器。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 子内容保持挂载，只更新透明度以产生呼吸反馈。
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final v = 0.55 + 0.45 * (1 - _controller.value);
        return Opacity(opacity: v, child: widget.child);
      },
    );
  }
}

/// 骨架矩形条原语 — 通用占位灰块,用 [AppTokens.surfaceSecondary] 自适应亮/暗。
class SkeletonBar extends StatelessWidget {
  final double height;
  final double? width;

  /// 按父容器宽度的比例填充,与 [width] 二选一(都不传则横向 expand)。
  final double? widthFactor;
  final BorderRadius? borderRadius;

  const SkeletonBar({
    super.key,
    required this.height,
    this.width,
    this.widthFactor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTokens.surfaceSecondary(context),
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimens.radius4),
      ),
    );
    if (widthFactor != null) {
      return FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: box,
      );
    }
    return box;
  }
}

/// 模拟 ListTile 的骨架行：圆角方形图标、两行文字和右侧金额条。
/// 常用于交易列表、分类列表等 loading 占位。
class SkeletonListTile extends StatelessWidget {
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const SkeletonListTile({
    super.key,
    this.iconSize = AppDimens.p36,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimens.p12,
      vertical: AppDimens.p8,
    ),
  });

  /// 图标占位与真实明细共用轮廓，加载完成后保持相同视觉形状。
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          SkeletonBar(
            width: iconSize,
            height: iconSize,
            borderRadius: BorderRadius.circular(
              AppTokens.categoryIconRadius(context, size: iconSize),
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBar(
                  height: AppDimens.skeletonTitleHeight,
                  width: AppDimens.skeletonTitleWidth,
                ),
                SizedBox(height: AppDimens.p4),
                SkeletonBar(
                  height: AppDimens.skeletonSubtitleHeight,
                  width: AppDimens.skeletonSubtitleWidth,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          const SkeletonBar(
            height: AppDimens.p16,
            width: AppDimens.skeletonTrailingWidth,
          ),
        ],
      ),
    );
  }
}

/// 明细流读取期间共用记账列表骨架，避免先显示空列表再跳变。
class DetailListSkeleton extends StatelessWidget {
  const DetailListSkeleton({super.key});

  /// 占位行固定，不接收滚动手势或业务点击。
  @override
  Widget build(BuildContext context) => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.only(top: AppDimens.p8),
    itemCount: 8,
    itemBuilder: (_, _) => const PulseSkeleton(child: SkeletonListTile()),
  );
}
