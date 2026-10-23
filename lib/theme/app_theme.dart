import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dimens.dart';
import 'typography.dart';
import 'app_visual_theme.dart';

/// 视觉风格与亮暗模式组合成外观，布局结构不依赖主题选择。
class AppTheme {
  /// 主题构建包含 ColorScheme.fromSeed 的全套色调计算，按「风格 + 亮暗 + 平台」缓存：
  /// 冷启动首帧前后 MainApp 会多次重建，重复计算会直接拖长启动图停留时间。
  static final _cache =
      <(AppThemePreset, Brightness, TargetPlatform), ThemeData>{};

  /// 浅色外观以视觉风格和平台共同缓存。
  static ThemeData lightTheme({
    TargetPlatform? platform,
    AppThemePreset preset = AppThemePreset.classic,
  }) => _cached(Brightness.light, platform, preset);

  /// 深色外观使用同一皮肤的独立语义色板。
  static ThemeData darkTheme({
    TargetPlatform? platform,
    AppThemePreset preset = AppThemePreset.classic,
  }) => _cached(Brightness.dark, platform, preset);

  /// 缓存纯视觉对象，不包含任何路由、滚动或编辑状态。
  static ThemeData _cached(
    Brightness brightness,
    TargetPlatform? platform,
    AppThemePreset preset,
  ) {
    final resolved = platform ?? defaultTargetPlatform;
    return _cache.putIfAbsent((
      preset,
      brightness,
      resolved,
    ), () => _build(brightness, preset: preset, platform: resolved));
  }

  /// 根据平台和明暗模式构建共用的组件样式。
  static ThemeData _build(
    Brightness brightness, {
    required AppThemePreset preset,
    TargetPlatform? platform,
  }) {
    final visual = AppVisualTheme.resolve(preset, brightness);
    final base = ThemeData(brightness: brightness);
    final pf = platform ?? defaultTargetPlatform;
    final surface = visual.color(AppThemeColor.surface);
    final foreground = visual.color(AppThemeColor.text);
    final secondary = visual.color(AppThemeColor.muted);
    final hint = secondary;
    final iconColor = foreground;
    final divider = visual.color(AppThemeColor.line);
    final brand = visual.color(AppThemeColor.brand);
    final action = visual.color(AppThemeColor.action);
    final onAction = visual.color(AppThemeColor.onAction);
    final textTheme = AppTypography.buildBase(
      base.textTheme,
      isIOS: pf == TargetPlatform.iOS || pf == TargetPlatform.macOS,
      visual: visual,
    ).apply(bodyColor: foreground, displayColor: foreground);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(visual.radius(AppThemeRadius.card)),
      side: visual.color(AppThemeColor.cardBorder).a == 0
          ? BorderSide.none
          : BorderSide(color: visual.color(AppThemeColor.cardBorder)),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(visual.radius(AppThemeRadius.button)),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(visual.radius(AppThemeRadius.input)),
      borderSide: BorderSide.none,
    );
    final errorBorder = inputBorder.copyWith(
      borderSide: BorderSide(color: visual.color(AppThemeColor.danger)),
    );
    final colors =
        ColorScheme.fromSeed(seedColor: brand, brightness: brightness).copyWith(
          primary: brand,
          onPrimary:
              ThemeData.estimateBrightnessForColor(brand) == Brightness.dark
              ? Colors.white
              : visual.color(AppThemeColor.page),
          primaryContainer: visual.color(AppThemeColor.brandSoft),
          onPrimaryContainer: visual.color(AppThemeColor.brandStrong),
          surface: surface,
          onSurface: foreground,
          onSurfaceVariant: secondary,
          surfaceContainerHighest: visual.color(AppThemeColor.soft),
          surfaceContainer: visual.color(AppThemeColor.soft),
          outline: divider,
          error: visual.color(AppThemeColor.danger),
          errorContainer: visual.color(AppThemeColor.dangerSoft),
        );
    return base.copyWith(
      platform: pf,
      colorScheme: colors,
      extensions: [visual],
      primaryColor: brand,
      focusColor: visual.color(AppThemeColor.focus).withValues(alpha: 0.16),
      // 只关闭水波纹本身，按压高亮、悬停、音效/触感与键盘焦点保持原有 Material 行为。
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hintColor: hint,
      scaffoldBackgroundColor: visual.color(AppThemeColor.page),
      textTheme: textTheme,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _SlidePageTransitionsBuilder(),
          TargetPlatform.iOS: _SlidePageTransitionsBuilder(),
          TargetPlatform.macOS: _SlidePageTransitionsBuilder(),
          TargetPlatform.windows: _SlidePageTransitionsBuilder(),
          TargetPlatform.linux: _SlidePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _SlidePageTransitionsBuilder(),
        },
      ),
      dividerColor: divider,
      dividerTheme: DividerThemeData(color: divider, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: visual.color(AppThemeColor.page),
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
      ),
      iconTheme: IconThemeData(color: iconColor),
      // 设置行、独立开关和 Material 自适应开关共用无描边轨道。
      switchTheme: const SwitchThemeData(
        trackOutlineWidth: WidgetStatePropertyAll(0),
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        titleTextStyle: textTheme.bodyMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(color: secondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.p12),
        iconColor: iconColor,
      ),
      dialogTheme: base.dialogTheme.copyWith(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p20,
          vertical: AppDimens.p40,
        ),
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            visual.radius(AppThemeRadius.sheet),
          ),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: visual.titleFontWeight,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: secondary),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: brand,
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: action,
          foregroundColor: onAction,
          shape: buttonShape,
          minimumSize: const Size(0, AppDimens.actionButtonMinHeight),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brand,
          side: BorderSide(color: brand),
          shape: buttonShape,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: action,
        foregroundColor: onAction,
        shape: buttonShape,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: visual.color(AppThemeColor.raised),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(visual.radius(AppThemeRadius.sheet)),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: shape,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyLarge?.copyWith(color: hint),
        labelStyle: textTheme.bodyLarge?.copyWith(color: hint),
        prefixStyle: textTheme.bodyLarge,
        suffixStyle: textTheme.bodyLarge,
        filled: true,
        fillColor: visual.color(AppThemeColor.soft),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: visual.color(AppThemeColor.focus)),
        ),
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: const EdgeInsets.all(AppDimens.p12),
      ),
    );
  }
}

/// 线性左右滑动转场；时长由 appPageRoute 控制。
class _SlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const _SlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 入场页面从右侧 100% 平移到 0（从右向左滑入）；
    // 出场时反向（从左向右滑出）。全程线性，无加速减速。
    const curve = Curves.linear;

    // 主页面（新页面）水平位移动画：从右侧滑入到原位
    final pageTween = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: curve));

    // 次要页面（被覆盖的旧页面）轻微左移，保持全可见不缩放，
    // 实现"前页让位"的视差效果，与小红书等大众 App 一致。
    final secondaryPageTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: secondaryAnimation.drive(secondaryPageTween),
      child: SlideTransition(
        position: animation.drive(pageTween),
        child: child,
      ),
    );
  }
}
