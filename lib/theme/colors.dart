import 'package:flutter/material.dart';

import 'dimens.dart';
import 'app_visual_theme.dart';

/// 跨视觉风格保持含义的警告与品牌色，动态表面由 AppVisualTheme 提供。
abstract final class AppColors {
  const AppColors._();

  static const Color warningLight = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color brandLocal = Color(0xFF9E9E9E);
  static const Color brandSupabase = Color(0xFF3ECF8E);
  static const Color brandWebdav = Color(0xFFFF9800);
  static const Color brandS3 = Color(0xFF8B5CF6);
  static const Color brandCloud = Color(0xFF2196F3);
}

/// 随主题适配的语义颜色。
class AppTokens {
  /// 获取当前完整视觉皮肤，所有业务入口通过语义角色共享配置。
  static AppVisualTheme visual(BuildContext context) =>
      AppVisualTheme.of(context);

  /// 分组列表的卡片表面由视觉皮肤统一决定。
  static bool listGroupsUseCards(BuildContext context) =>
      visual(context).listGroupsUseCards;

  /// 分组标题与列表之间的留白，与列表表面共用当前皮肤配置。
  static double listGroupHeadingGap(BuildContext context) =>
      visual(context).listGroupHeadingGap;

  /// 普通内容卡片圆角。
  static double cardRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.card);

  /// 分类图标沿用首页明细圆角，小尺寸按比例缩放以保留方形轮廓。
  static double categoryIconRadius(
    BuildContext context, {
    double size = AppDimens.p36,
  }) => cardRadius(context) * (size / AppDimens.p36).clamp(0.0, 1.0);

  /// 业务首页摘要与最近事件圆角。
  static double heroRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.hero);

  /// 主要操作按钮圆角。
  static double buttonRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.button);

  /// 文本和选择字段圆角。
  static double inputRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.input);

  /// 普通弹层圆角。
  static double sheetRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.sheet);

  /// 记账编辑弹层圆角。
  static double entrySheetRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.entrySheet);

  /// 数字键盘按键圆角。
  static double keyRadius(BuildContext context) =>
      visual(context).radius(AppThemeRadius.key);

  /// 显示模式分段在输入容器内缩，三段均保留各自的小圆角。
  static double modeSegmentRadius(BuildContext context) =>
      (inputRadius(context) - 2).clamp(0, double.infinity);

  /// 显示模式选中段的轻微抬升，与视觉皮肤的卡片阴影相互独立。
  static List<BoxShadow> modeSelectionShadow() => const [
    BoxShadow(color: Color(0x0B000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  /// 卡片边框只描绘外缘，内部行分隔由列表自身决定。
  static BorderSide cardBorder(BuildContext context) => BorderSide(
    color: border(context),
    width: border(context).a == 0 ? 0 : 1,
    style: border(context).a == 0 ? BorderStyle.none : BorderStyle.solid,
  );

  /// 内容卡片的轻阴影。
  static List<BoxShadow> cardShadow(BuildContext context) =>
      visual(context).cardShadows;

  /// 悬浮主要操作的轻阴影。
  static List<BoxShadow> fabShadow(BuildContext context) =>
      visual(context).fabShadows;

  /// 弹层阴影由皮肤统一控制。
  static List<BoxShadow> sheetShadow(BuildContext context) =>
      visual(context).sheetShadows;

  /// 手账主题使用很淡的纸面亮度层，不改变内容布局。
  static Gradient? cardTexture(BuildContext context, {Color? base}) =>
      visual(context).textureOpacity == 0
      ? null
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              Colors.white.withValues(alpha: visual(context).textureOpacity),
              base ?? surface(context),
            ),
            base ?? surface(context),
          ],
          stops: const [0, 0.62],
        );

  /// 卡片整体装饰用于无 Material 点击的统计区域和分组容器。
  static BoxDecoration cardDecoration(
    BuildContext context, {
    bool hero = false,
    Color? color,
  }) => BoxDecoration(
    color: color ?? surface(context),
    borderRadius: BorderRadius.circular(
      hero ? heroRadius(context) : cardRadius(context),
    ),
    border: Border.fromBorderSide(cardBorder(context)),
    boxShadow: cardShadow(context),
    gradient: hero ? null : cardTexture(context, base: color),
  );

  /// 主操作背景与文字使用成对角色，深色模式可使用浅色按钮。
  static Color buttonPrimary(BuildContext context) =>
      visual(context).color(AppThemeColor.action);

  /// 日子主卡的文字、辅助说明和边界与绿色背景成对配置。
  static Color dayHeroText(BuildContext context) =>
      visual(context).color(AppThemeColor.dayText);
  static Color dayHeroMuted(BuildContext context) =>
      visual(context).color(AppThemeColor.dayMuted);
  static Color dayHeroLine(BuildContext context) =>
      visual(context).color(AppThemeColor.dayLine);

  /// 极简主题降低日子装饰的存在感，内容文字不改变透明度。
  static double dayHeroDecorationOpacity(BuildContext context) =>
      visual(context).preset == AppThemePreset.minimal ? 0.45 : 1;

  /// 生日、纪念日与备忘记录的柔和图标色对。
  static Color peachBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.peachBg);
  static Color peachForeground(BuildContext context) =>
      visual(context).color(AppThemeColor.peachFg);
  static Color sageBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.sageBg);
  static Color sageForeground(BuildContext context) =>
      visual(context).color(AppThemeColor.sageFg);
  static Color purpleBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.purpleBg);
  static Color purpleForeground(BuildContext context) =>
      visual(context).color(AppThemeColor.purpleFg);

  /// 提示浮层使用专用前景色，避免浅色按钮主题影响深底提示。
  static Color toastSurface(BuildContext context) =>
      visual(context).color(AppThemeColor.toast);
  static Color toastText(BuildContext context) =>
      visual(context).color(AppThemeColor.onToast);

  /// 日子主卡采用随亮暗主题变化的柔和绿色底。
  static Color dayHeroBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.dayBg);

  /// 业务域强调容器复用品牌蓝，保持浅色与深色的阅读对比度。
  static Color domainAccentBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.brandSoft);

  /// 头像预览页的固定暗色背景。
  static const Color avatarPreviewBackground = Color(0xFF111827);
  // ========== 背景色 Token (Surface) ==========

  /// 页面背景色（Scaffold 背景）
  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  /// 卡片背景色（贴在页面上的卡片）
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// 次级背景色（嵌套卡片、输入框背景）
  static Color surfaceSecondary(BuildContext context) =>
      visual(context).color(AppThemeColor.soft);

  /// 悬浮卡片背景色（Dialog、BottomSheet、Dropdown 等）
  static Color surfaceElevated(BuildContext context) =>
      visual(context).color(AppThemeColor.raised);

  /// BottomSheet 背景色（金额输入等弹窗）
  static Color surfaceSheet(BuildContext context) =>
      visual(context).color(AppThemeColor.raised);

  /// 记账键盘容器背景色（取自设计规范）
  static Color keypadBackground(BuildContext context) =>
      isDark(context) ? surface(context) : surfaceSecondary(context);

  /// 记账键盘数字（0-9）/运算符（+-×÷）/日期按键背景色
  static Color keyDigit(BuildContext context) =>
      isDark(context) ? surfaceSecondary(context) : surface(context);

  /// 输入框背景色
  static Color surfaceInput(BuildContext context) =>
      InputDecorationTheme.of(context).fillColor ??
      Theme.of(context).colorScheme.surfaceContainerHighest;

  /// 胶囊切换器背景色（不透明）
  ///   避免悬浮胶囊透出下层内容——统计页周/月/年父级 Tab 即悬浮场景)
  static Color surfaceCapsule(BuildContext context) =>
      visual(context).color(AppThemeColor.soft);

  /// 分类图标背景色（未选中状态）
  static Color surfaceCategoryIcon(BuildContext context) =>
      visual(context).color(AppThemeColor.iconBg);

  /// 分类展开分组使用卡片与次级背景的中间色，与图标底板保持区分。
  static Color surfaceCategoryGroup(BuildContext context) =>
      Color.lerp(surface(context), surfaceSecondary(context), 0.5)!;

  /// 分类图标颜色（未选中状态）
  static Color iconCategory(BuildContext context) =>
      visual(context).color(AppThemeColor.iconFg);

  /// 选中状态背景色（列表项选中、高亮）
  static Color surfaceSelected(BuildContext context) =>
      visual(context).color(AppThemeColor.brandSoft);

  /// 反转背景色（FAB、浮动按钮等需要"反色"的组件背景）
  static Color surfaceInverse(BuildContext context) =>
      isDark(context) ? Colors.white : Colors.black;

  // ========== 文字颜色 Token (Text) ==========

  /// 主要文字颜色（标题、正文）
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  /// 次要文字颜色（副标题、说明文字）
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// 提示文字颜色（placeholder、hint、辅助说明）
  static Color textTertiary(BuildContext context) =>
      Theme.of(context).hintColor;

  /// 禁用文字颜色
  static Color textDisabled(BuildContext context) =>
      Theme.of(context).disabledColor;

  /// 反色文字（用于深色背景上的白色文字）
  static Color textOnPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  /// 链接文字颜色
  static Color textLink(BuildContext context) =>
      visual(context).color(AppThemeColor.brand);

  // ========== 图标颜色 Token (Icon) ==========

  /// 主要图标颜色
  static Color iconPrimary(BuildContext context) =>
      IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;

  /// 次要图标颜色
  static Color iconSecondary(BuildContext context) =>
      visual(context).color(AppThemeColor.muted);

  /// 提示图标颜色
  static Color iconTertiary(BuildContext context) =>
      textSecondary(context).withValues(alpha: 0.72);

  // ========== 边框/分割线 Token (Border) ==========

  /// 分割线颜色
  static Color divider(BuildContext context) =>
      visual(context).color(AppThemeColor.line);

  /// 边框颜色（卡片边框）
  static Color border(BuildContext context) =>
      visual(context).color(AppThemeColor.cardBorder);

  /// 强调边框颜色
  static Color borderStrong(BuildContext context) =>
      visual(context).color(AppThemeColor.line);

  /// 底部弹层拖拽条使用次要文字色的半透明值。
  static Color grabHandleColor(BuildContext context) =>
      textSecondary(context).withValues(alpha: 0.35);

  // ========== 卡片边框 Token (Card Border) ==========

  /// 卡片内分隔线沿用皮肤边界色，浅色和深色均可见。
  static Color cardInnerDividerColor(BuildContext context) => divider(context);

  /// 卡片内部分割线高度
  static double cardInnerDividerHeight(BuildContext context) =>
      Theme.of(context).dividerTheme.thickness ?? 1;

  /// 对齐列表内容的分割线；全宽传 indent: 0，已有留白传 verticalGap: 0。
  static Widget cardDivider(
    BuildContext context, {
    double indent = 48,
    double endIndent = 0,
    double verticalGap = AppDimens.dividerVerticalGap,
    double? height,
    double? thickness,
  }) => Padding(
    padding: EdgeInsets.symmetric(vertical: verticalGap),
    child: Divider(
      height: height ?? cardInnerDividerHeight(context),
      thickness: thickness ?? cardInnerDividerHeight(context),
      color: cardInnerDividerColor(context),
      indent: indent,
      endIndent: endIndent,
    ),
  );

  // ========== 主题色 Token (Theme) ==========

  /// 主题色（自动适配用户选择的颜色）
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  // ========== 语义色 Token (Semantic) ==========

  /// 成功状态颜色
  static Color success(BuildContext context) =>
      visual(context).color(AppThemeColor.success);

  /// 警告状态颜色
  static Color warning(BuildContext context) =>
      isDark(context) ? AppColors.warningDark : AppColors.warningLight;

  /// 错误状态颜色（shadcn destructive）
  static Color error(BuildContext context) =>
      visual(context).color(AppThemeColor.danger);

  /// 信息提示颜色
  static Color info(BuildContext context) => textLink(context);

  // ========== 交互色 Token (Interactive) ==========

  /// 主按钮文字颜色
  // 媒体预览固定暗底，覆盖层沿用现有视觉值，集中定义供页面使用。
  static const Color mediaControlBackground = Color(0x26FFFFFF);
  static const Color mediaForeground = Color(0xFFFFFFFF);
  static const Color mediaControlDisabled = Color(0x1FFFFFFF);
  static const Color mediaPlaceholder = Color(0x1AFFFFFF);
  static const Color mediaShadow = Color(0x66000000);

  static Color buttonPrimaryText(BuildContext context) =>
      visual(context).color(AppThemeColor.onAction);

  /// 禁用按钮背景色
  static Color buttonDisabled(BuildContext context) =>
      surfaceSecondary(context);

  // ========== 品牌图标色 Token (Brand Icons) ==========
  // 这些颜色是各服务的品牌色，在亮暗模式下保持一致

  /// 本地存储图标色（灰色）
  static const Color brandLocal = AppColors.brandLocal;

  /// Supabase 品牌色（绿色）
  static const Color brandSupabase = AppColors.brandSupabase;

  /// WebDAV 品牌色（橙色）
  static const Color brandWebdav = AppColors.brandWebdav;

  /// S3 存储品牌色（紫色）
  static const Color brandS3 = AppColors.brandS3;

  /// 云服务通用图标色（蓝色）
  static const Color brandCloud = AppColors.brandCloud;

  /// Toast 阴影（暗黑模式下白色提亮）
  static List<BoxShadow> get toastShadow => [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.2),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];

  // ========== 状态指示器 Token (Status Indicators) ==========

  // ========== 图表/统计色 Token (Chart Colors) ==========

  /// 支出趋势线颜色（折线/数据点共用）
  /// - 跟随主题主色，亮暗模式均取 `colorScheme.primary`
  /// - 不用 error 语义色：趋势线是「统计展示」，与金额的支出语义色区分开
  static Color chartExpense(BuildContext context) => primary(context);

  /// 合并为其他的分类使用独立的中性图表颜色。
  static Color chartOther(BuildContext context) =>
      visual(context).color(AppThemeColor.pieOther);

  // ========== 遮罩层 Token (Overlay) ==========

  /// 模态遮罩层颜色
  static Color overlay(BuildContext context) =>
      visual(context).color(AppThemeColor.overlay);

  // ========== 导航栏 Token ==========

  /// 贴底导航背景色，覆盖内容区与底部安全区。
  static Color tabBarBackground(BuildContext context) =>
      visual(context).color(AppThemeColor.navSurface);

  /// 底部导航前景色，按是否选中读取对应角色。
  static Color tabBarForeground(BuildContext context, {bool selected = true}) =>
      visual(
        context,
      ).color(selected ? AppThemeColor.navActive : AppThemeColor.navInactive);

  /// 按键按下时在背景上叠加统一明暗反馈色。
  static Color pressedBackground(BuildContext context, Color background) =>
      Color.alphaBlend(
        (isDark(context) ? Colors.white : Colors.black).withValues(alpha: 0.18),
        background,
      );

  // ========== 辅助方法 ==========

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
