import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'app_route.dart';
import 'primary_header.dart';
import 'sheet_grab_handle.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 底部弹层的默认最大高度占比，命名路由与直接弹出共用。
const double kAppSheetHeightFactor = 0.85;

/// 新增账单和纪念日共用左返回、左对齐标题及同行操作区域。
class AppEditorHeader extends StatelessWidget {
  const AppEditorHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppDimens.p12,
      AppDimens.p4,
      AppDimens.p12,
      AppDimens.p4,
    ),
    child: Row(
      children: [
        HeaderIconAction(
          icon: AppIcons.back,
          onPressed: onBack,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
        const SizedBox(width: AppDimens.p8),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextTokens.strongTitle(
              context,
            ).copyWith(color: AppTokens.textPrimary(context)),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppDimens.p8),
          Flexible(flex: 2, child: trailing!),
        ],
      ],
    ),
  );
}

/// 含拖拽条、标题、内容和底部操作区的弹层，由 [showAppSheet] 展示。
class AppSheet extends StatelessWidget {
  /// 编辑弹层可复用同行标题，其他弹层沿用默认标题布局。
  final Widget? header;

  /// 标题(可选)。无标题时不渲染标题区。
  final String? title;

  /// 编辑态沿用默认标题样式；标题旁操作与右侧 trailing 分开。
  final Widget? titleWidget;
  final Widget? titleAction;

  /// 副标题(可选),展示在标题下方,mutedForeground 色。
  final String? subtitle;

  /// 内容区。
  final Widget child;

  /// 底部按钮区(可选)。通常放主/次按钮(如"完成"/"取消")。
  final Widget? footer;
  final EdgeInsetsGeometry footerPadding;

  /// 标题栏右侧操作位(可选),如删除/关闭图标。
  /// 标题栏常驻可见，即便内容滚动也不会被挤出可视区。
  /// 例:云同步配置弹窗把「清除配置」图标放在这里。
  final Widget? trailing;

  /// 内容区内边距。标题区与底部按钮区有各自固定内边距,这里只控制 child。
  ///
  /// 注意:标题区在 [title]/[subtitle] 均为空时仍会渲染(仅放 trailing),
  /// 以保证无标题弹层的右上角操作位(如删除 icon)不丢失。
  final EdgeInsets contentPadding;

  /// 是否显示顶部拖拽条。默认 true。
  final bool showGrabHandle;

  /// 标题和底部操作固定在弹层内，业务内容负责自身滚动方式。
  const AppSheet({
    super.key,
    this.header,
    this.title,
    this.titleWidget,
    this.titleAction,
    this.subtitle,
    required this.child,
    this.footer,
    this.footerPadding = const EdgeInsets.fromLTRB(
      AppDimens.p16,
      0,
      AppDimens.p16,
      AppDimens.p16,
    ),
    this.trailing,
    this.contentPadding = const EdgeInsets.fromLTRB(
      AppDimens.p16,
      AppDimens.p4,
      AppDimens.p16,
      AppDimens.p16,
    ),
    this.showGrabHandle = true,
  });

  /// 使用统一标题、内容留白和底部安全布局组装弹层。
  @override
  Widget build(BuildContext context) {
    final header =
        this.header ??
        ((title != null ||
                titleWidget != null ||
                subtitle != null ||
                trailing != null)
            ? Padding(
                // 与记账编辑头部共用拖拽条下方间距，不再额外叠加一层留白。
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.p16,
                  AppDimens.p4,
                  AppDimens.p16,
                  0,
                ),
                child: _CenteredSheetHeader(
                  trailing: trailing,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: AppDimens.p32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      // 标题在 32px 列内垂直居中,视觉上与 32px 删除图标按钮对齐。
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (title != null || titleWidget != null)
                          DefaultTextStyle(
                            style: AppTextTokens.strongTitle(context).copyWith(
                              color: AppTokens.textPrimary(context),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child:
                                      titleWidget ??
                                      Text(title!, textAlign: TextAlign.center),
                                ),
                                if (titleAction != null) ...[
                                  const SizedBox(width: AppDimens.p4),
                                  titleAction!,
                                ],
                              ],
                            ),
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppDimens.p4),
                          Text(
                            subtitle!,
                            textAlign: TextAlign.center,
                            style: AppTextTokens.label(
                              context,
                            ).copyWith(color: AppTokens.textSecondary(context)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink());

    final grab = showGrabHandle
        ? const SheetGrabHandle()
        : const SizedBox.shrink();

    // 标题和底部操作保持可见，内容区只占用两者之间的剩余空间。
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        grab,
        header,
        Flexible(
          child: Padding(padding: contentPadding, child: child),
        ),
        if (footer != null) Padding(padding: footerPadding, child: footer),
      ],
    );
  }
}

/// 弹出统一样式的 Bottom Sheet；[child] 通常为 [AppSheet]。
/// [heightFactor] 限制最大屏占比，返回子组件 pop 的结果。
/// [entryShape] 显式选择编辑圆角；未指定时全高弹层使用编辑圆角。
/// [borderRadius] 为有固定几何布局的编辑器提供独立圆角。
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required Widget child,
  double heightFactor = kAppSheetHeightFactor,
  bool? entryShape,
  BorderRadius? borderRadius,
  bool useRootNavigator = false,
  Color? barrierColor,
  Color? backgroundColor,
  bool avoidKeyboard = true,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push<T>(
    _appSheetRoute<T>(
      context: context,
      child: child,
      heightFactor: heightFactor,
      entryShape: entryShape,
      borderRadius: borderRadius,
      barrierColor: barrierColor,
      backgroundColor: backgroundColor,
      avoidKeyboard: avoidKeyboard,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
    ),
  );
}

/// 命名路由使用与直接弹出相同的底部弹层，返回时恢复原页面位置。
class AppSheetPage<T> extends Page<T> {
  const AppSheetPage({
    super.key,
    super.name,
    required this.child,
    this.fullHeight = false,
  });

  final Widget child;

  final bool fullHeight;

  /// 路由配置只承载页面身份，样式和交互都由统一弹层路由提供。
  @override
  Route<T> createRoute(BuildContext context) => _appSheetRoute<T>(
    context: context,
    child: child,
    settings: this,
    heightFactor: fullHeight ? 1 : kAppSheetHeightFactor,
    barrierColor: fullHeight ? Colors.transparent : null,
    fullHeight: fullHeight,
  );
}

/// 集中构造原生弹层，统一直接调用和命名路由的视觉与无障碍遮罩。
ModalBottomSheetRoute<T> _appSheetRoute<T>({
  required BuildContext context,
  bool fullHeight = false,
  required Widget child,
  RouteSettings? settings,
  CapturedThemes? capturedThemes,
  double heightFactor = kAppSheetHeightFactor,
  bool? entryShape,
  BorderRadius? borderRadius,
  Color? barrierColor,
  Color? backgroundColor,
  bool avoidKeyboard = true,
}) {
  final localizations = MaterialLocalizations.of(context);
  final resolvedEntryShape = entryShape ?? heightFactor == 1;
  return _AppSheetRoute<T>(
    originContext: context,
    entryShape: resolvedEntryShape,
    borderRadiusOverride: borderRadius,
    settings: settings,
    capturedThemes: capturedThemes,
    barrierLabel: localizations.scrimLabel,
    barrierOnTapHint: localizations.scrimOnTapHint(
      localizations.bottomSheetLabel,
    ),
    backgroundOverride: backgroundColor,
    barrierOverride: barrierColor,
    enableDrag: true,
    // 用自定义 SheetGrabHandle,关闭 Material 自带拖拽条
    showDragHandle: false,
    // 全局统一上滑动画：线性曲线（无加速减速），时长与页面切换一致。
    sheetAnimationStyle: kSheetAnimationStyle,
    // 高度随旋转与键盘实时变化；普通弹层统一避让，专用记账键盘保留自有布局。
    builder: (context) {
      final media = MediaQuery.of(context);
      final keyboard = avoidKeyboard ? media.viewInsets.bottom : 0.0;
      final panelHeight = math.min(
        media.size.height * heightFactor,
        media.size.height,
      );
      final maxHeight = (panelHeight - keyboard)
          .clamp(0.0, media.size.height)
          .toDouble();
      final content = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: fullHeight ? SizedBox.expand(child: child) : child,
      );
      final padded = Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: avoidKeyboard
            ? MediaQuery.removeViewInsets(
                context: context,
                removeBottom: true,
                child: content,
              )
            : content,
      );
      final radius =
          borderRadius ??
          BorderRadius.vertical(
            top: Radius.circular(
              resolvedEntryShape
                  ? AppTokens.entrySheetRadius(context)
                  : AppTokens.sheetRadius(context),
            ),
          );
      return DecoratedBox(
        key: const ValueKey('app-sheet-themed-shadow'),
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppTokens.sheetShadow(context),
        ),
        child: ClipRRect(borderRadius: radius, child: padded),
      );
    },
  );
}

/// 弹层沿用同一路由与子状态，仅默认外观随 Navigator 上的应用主题更新。
class _AppSheetRoute<T> extends ModalBottomSheetRoute<T> {
  /// 显式颜色和局部继承主题保留调用方语义，默认值由实时主题计算。
  _AppSheetRoute({
    required this.originContext,
    required this.entryShape,
    this.borderRadiusOverride,
    this.backgroundOverride,
    this.barrierOverride,
    required super.builder,
    super.settings,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.enableDrag,
    super.showDragHandle,
    super.sheetAnimationStyle,
  }) : super(
         // 弹层始终使用完整高度约束和安全区，阴影由内容外层绘制。
         isScrollControlled: true,
         useSafeArea: true,
         clipBehavior: Clip.none,
       );

  final BuildContext originContext;
  final bool entryShape;
  final BorderRadius? borderRadiusOverride;
  final Color? backgroundOverride, barrierOverride;

  /// 路由安装后使用应用导航层的主题，不持有打开时的 ThemeData 快照。
  BuildContext get _themeContext => navigator?.context ?? originContext;

  /// 调用者指定的特殊背景优先，其余弹层使用当前皮肤表面。
  @override
  Color? get backgroundColor =>
      backgroundOverride ?? AppTokens.surfaceSheet(_themeContext);

  /// 全高编辑器与普通选择器各自使用稳定的几何角色。
  @override
  ShapeBorder? get shape => RoundedRectangleBorder(
    borderRadius:
        borderRadiusOverride ??
        BorderRadius.vertical(
          top: Radius.circular(
            entryShape
                ? AppTokens.entrySheetRadius(_themeContext)
                : AppTokens.sheetRadius(_themeContext),
          ),
        ),
  );

  /// 透明遮罩等显式覆盖保持原值，默认遮罩跟随应用主题。
  @override
  Color get barrierColor => barrierOverride ?? AppTokens.overlay(_themeContext);

  /// 注册应用主题依赖，主题变更只刷新路由内容，不创建新的编辑器状态。
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Theme.of(context);
    return super.buildPage(context, animation, secondaryAnimation);
  }
}

/// 先测量边缘操作，再对称预留其宽度；标题始终相对整个弹层居中。
/// 不复制操作控件，也不限制标题高度，编辑错误提示和大字号可自然增高。
class _CenteredSheetHeader extends MultiChildRenderObjectWidget {
  _CenteredSheetHeader({required Widget child, Widget? trailing})
    : super(children: [child, ?trailing]);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _CenteredSheetHeaderBox(Directionality.of(context));

  @override
  void updateRenderObject(
    BuildContext context,
    _CenteredSheetHeaderBox renderObject,
  ) {
    renderObject.textDirection = Directionality.of(context);
  }
}

class _CenteredSheetHeaderBox extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  _CenteredSheetHeaderBox(this._textDirection);
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (value == _textDirection) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _SheetHeaderParentData();
    }
  }

  Size _measure(
    BoxConstraints bounds,
    Size Function(RenderBox, BoxConstraints) measure,
  ) {
    final width = bounds.maxWidth;
    final side = childCount > 1 ? lastChild! : null;
    final sideSize = side == null
        ? Size.zero
        : measure(side, bounds.loosen().copyWith(maxWidth: width / 2));
    final reserved = side == null ? 0.0 : sideSize.width + AppDimens.p4;
    final centerSize = measure(
      firstChild!,
      bounds.loosen().copyWith(
        maxWidth: (width - reserved * 2).clamp(0.0, width),
      ),
    );
    return bounds.constrain(
      Size(
        width,
        centerSize.height > sideSize.height
            ? centerSize.height
            : sideSize.height,
      ),
    );
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _measure(constraints, (child, bounds) => child.getDryLayout(bounds));

  @override
  void performLayout() {
    size = _measure(constraints, (child, bounds) {
      child.layout(bounds, parentUsesSize: true);
      return child.size;
    });
    final center = firstChild!;
    (center.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
      (size.width - center.size.width) / 2,
      (size.height - center.size.height) / 2,
    );
    if (childCount > 1) {
      final side = lastChild!;
      (side.parentData! as ContainerBoxParentData<RenderBox>).offset = Offset(
        _textDirection == TextDirection.ltr ? size.width - side.size.width : 0,
        (size.height - side.size.height) / 2,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

class _SheetHeaderParentData extends ContainerBoxParentData<RenderBox> {}
