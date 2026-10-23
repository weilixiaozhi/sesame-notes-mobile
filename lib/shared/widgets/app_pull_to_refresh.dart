import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'toast.dart';

/// 首页共用纵向下拉与旋转反馈，指示器覆盖列表而不改变视口。
class AppPullToRefresh extends StatefulWidget {
  const AppPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.refreshingText,
    this.notice,
    this.onNoticeTap,
  });

  /// 返回非空结果时在原下拉区域展示，返回 null 时直接收起。
  final Future<String?> Function() onRefresh;
  final Widget child;
  final String? refreshingText;

  /// 常驻异常提示：没有刷新结果时一直占用下拉区域。
  ///
  /// 下拉刷新期间被刷新状态与刷新结果覆盖；提示条件仍成立时刷新结束后继续常驻，
  /// 条件消失（问题已处理）时自动收起。
  final String? notice;
  final VoidCallback? onNoticeTap;

  /// 列表与空状态均可从顶部回弹，支持同一套下拉距离判定。
  static const physics = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

  /// 每个首页保留独立的手势会话和旋转动画。
  @override
  State<AppPullToRefresh> createState() => _AppPullToRefreshState();
}

class _AppPullToRefreshState extends State<AppPullToRefresh>
    with TickerProviderStateMixin {
  static const double _indicatorHeight = 32;
  static const double _refreshThreshold = 48;
  late final AnimationController _indicator = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  double _maximumPull = 0;
  double _lastPixels = 0;
  bool _busy = false;
  String? _resultText;
  Timer? _resultTimer;

  /// 进入页面即展开常驻提示（上次同步遗留的问题不依赖下拉动作才可见）。
  @override
  void initState() {
    super.initState();
    if (widget.notice != null) _indicator.value = 1;
  }

  /// 提示出现或消失时同步展开状态；刷新进行中不打断当前动画。
  @override
  void didUpdateWidget(AppPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notice == oldWidget.notice || _busy) return;
    if (widget.notice != null) {
      _indicator.value = 1;
    } else if (_resultText == null) {
      _indicator.animateTo(0);
    }
  }

  /// 页面销毁时终止动画，迟到的刷新结果不再操作控制器。
  @override
  void dispose() {
    _resultTimer?.cancel();
    _indicator.dispose();
    _spin.dispose();
    super.dispose();
  }

  /// 完整等待业务刷新，期间阻止重复触发并持续显示旋转反馈。
  Future<void> _refresh() async {
    if (_busy) return;
    _busy = true;
    setState(() => _resultText = null);
    _indicator.animateTo(1);
    _spin.repeat();
    String? result;
    try {
      result = await widget.onRefresh();
    } catch (error, stackTrace) {
      logger.error('AppPullToRefresh', '下拉刷新失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) {
        _spin.stop();
        _spin.value = 0;
        if (result != null && result.isNotEmpty) {
          setState(() => _resultText = result);
          _resultTimer = Timer(
            const Duration(milliseconds: 1500),
            _dismissResult,
          );
        } else {
          _dismissResult();
        }
      }
    }
  }

  /// 结果停留结束后收起；存在常驻提示时只清空结果、保留提示条。
  ///
  /// 动画完成再清空文案，避免闪回刷新中的文字。
  void _dismissResult() {
    _busy = false;
    if (widget.notice != null) {
      _indicator.value = 1;
      setState(() => _resultText = null);
      return;
    }
    _indicator.animateBack(0).then((_) {
      if (mounted && !_busy) setState(() => _resultText = null);
    });
  }

  /// 使用本次手势的最大距离判断，回弹不能撤销已经达到的阈值。
  void _finishPull() {
    final refresh = _maximumPull >= _refreshThreshold;
    _maximumPull = 0;
    _lastPixels = 0;
    if (refresh) {
      unawaited(_refresh());
    } else if (!_busy) {
      _spin.stop();
      // 手势未达到刷新阈值时仍以业务提示决定可见性，不能隐藏未解决事项。
      _indicator.animateTo(widget.notice == null ? 0 : 1);
    }
  }

  /// 只处理纵向列表通知，横向月份翻页继续交给所在页面处理。
  bool _onScroll(ScrollNotification notification) {
    if (_busy || notification.metrics.axis != Axis.vertical) return false;
    if (notification is ScrollUpdateNotification) {
      // 位置恢复、布局修正和惯性回弹不代表用户下拉，不能启动或累积刷新。
      if (notification.dragDetails == null) return false;
      final pixels = notification.metrics.pixels;
      if (pixels < 0 && pixels <= _lastPixels) {
        final pull = -pixels;
        if (pull > _maximumPull) _maximumPull = pull;
        _indicator.value = (pull / _indicatorHeight).clamp(0, 1);
        if (!_spin.isAnimating) _spin.repeat();
      } else if (pixels >= 0 && _maximumPull > 0) {
        _finishPull();
      }
      _lastPixels = pixels;
    } else if (notification is ScrollEndNotification && _maximumPull > 0) {
      _finishPull();
    }
    return false;
  }

  /// 刷新状态与结果优先，其次才是常驻提示；三者共用同一行。
  String? get _lineText =>
      _resultText ??
      (_busy || widget.notice == null ? widget.refreshingText : widget.notice);

  /// 叠层的高度动画只遮盖列表，不压缩列表或横向翻页容器。
  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizeTransition(
                alignment: const Alignment(-1, -1),
                sizeFactor: _indicator,
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(AppDimens.p8),
                  // 常驻提示是可点击入口：无刷新进行时整行可点进同步处理。
                  child: InkWell(
                    onTap: _busy || _resultText != null
                        ? null
                        : widget.onNoticeTap,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: _spin,
                          child: Icon(
                            AppIcons.refresh,
                            size: AppDimens.icon12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        // 拖拽阶段就显示状态文案，与刷新及结果共用同一行。
                        if (_lineText case final text?) ...[
                          const SizedBox(width: AppDimens.p8),
                          Flexible(
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: AppTextTokens.label(context).copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
