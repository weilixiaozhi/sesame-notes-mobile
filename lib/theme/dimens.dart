// ============================================================================
// 设计基准令牌 (Design Tokens)
// ============================================================================

/// 间距、圆角等尺寸令牌
class AppDimens {
  // 业务首页共用外边距，列表底部为独立新增按钮预留完整触摸空间。
  static const double domainPageInset = 20;
  static const double domainBottomClearance = 88;
  static const double domainActionSize = 44;
  // 外观设置的缩略页面与操作色块，三套皮肤共享相同占位。
  static const double themePreviewHeight = 50;
  static const double themePreviewActionHeight = 23;
  static const double themePreviewRadius = 7;
  static const double p3 = 3;
  static const double p5 = 5;
  static const double cloudStatusDotSize = 6;
  static const double cloudCardSubtitleGap = 7;
  static const double inlineProgressSize = 14;
  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p32 = 32;
  static const double p36 = 36;
  static const double p40 = 40;
  static const double sheetGrabHandleRadius = 2;
  static const double progressStrokeWidth = 2;
  // 品牌、头像和状态插图保留各自展示尺度。
  static const double authLogoSize = 64;
  static const double authFieldHeight = 54;
  static const double authFormMaxWidth = 420;
  static const double welcomeLogoSize = 120;
  static const double profileAvatarSize = 60;
  static const double avatarPreviewSize = 260;

  /// 记账父分类的最小行高，字体放大时按实际标签高度增长。
  static const double categoryPickerRowMinHeight = 66;

  /// 子分类使用较小图标和独立滚动视口。
  static const double categoryPickerSubcategoryRowMinHeight = 60;
  static const double categoryPickerSubcategoryMaxHeight = 200;

  /// 记账键盘保持六行输入空间，紧凑屏幕在内部滚动。
  static const double transactionKeypadMinHeight = 320;
  static const double transactionKeypadMaxHeight = 360;
  static const double restAlarmSize = 96;
  static const double restStatusIconSize = 32;
  static const double categoryBadgeIconSize = 11;
  static const double categoryRankParentIconSize = 44;
  static const double categoryRankChildIconSize = 38;
  static const double categoryRankParentBarHeight = 6;
  static const double categoryRankChildBarHeight = 5;
  static const double icon18 = 18;
  // 共享标题、菜单、明细与骨架的固定布局尺度。
  static const double sectionAccentWidth = 3;
  static const double sectionAccentHeight = 15;
  static const double menuIconBoxSize = 30;
  static const double detailTrailingWidth = 116;
  static const double selectionBadgeSize = 26;
  static const double selectionBadgeGap = 2;
  static const double iconGroupGap = 18;
  static const double calendarEntriesPlaceholderHeight = 200;
  static const double skeletonTitleHeight = 14;
  static const double skeletonSubtitleHeight = 11;
  static const double skeletonTitleWidth = 110;
  static const double skeletonSubtitleWidth = 70;
  static const double skeletonTrailingWidth = 60;
  static const double radius4 = 4;
  static const double radius8 = 8;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double radius20 = 20;
  static const double radius28 = 28;
  static const double radius44 = 44;
  static const double icon12 = 12;
  static const double icon16 = 16;
  static const double icon20 = 20;
  static const double icon22 = 22;
  static const double icon28 = 28;
  static const double icon40 = 40;
  static const double compactSwitchScale = 0.75;
  // 月历同时容纳日期、农历和业务标记，三个业务共用同一网格。
  static const double calendarDayDiameter = 40;
  static const double selectionIndicatorWidth = 2;
  static const double actionButtonMinHeight = 48;

  /// 底部周期入口使用紧凑宽度，与同排的主要新增操作保持视觉层级。
  static const double analyticsFloatingSwitcherWidth = 144;
  static const double calendarRowHeight = 64;
  static const double memoRowMinHeight = 64;
  static const double calendarEntryIconSize = 44;
  // 动作目录最多三列；名称区域随系统字号缩放，窄屏自动减少列数。
  static const double exerciseCardMinHeight = 88;
  static const double exerciseCardTextHeight = 40;
  static const double exerciseCardMinWidth = 96;
  // 侧边栏容纳英文部位名与自定义字体，窄于 88 时条目文字会换行。
  static const double exerciseSidebarWidth = 88;
  static const double filterSheetHeight = 360;
  // 动作缩略图与可编辑数字表格各有语义，不随月历行距一起变化。
  static const double exerciseThumbnailSize = 64;
  static const double exerciseDetailMediaSize = 180;
  // 悬浮休息按钮的圆环外径：比内部两行文字大一档，文字不贴描边。
  static const double restCountdownCompactSize = 48;
  static const double calendarWeekdayHeight = 30;
  // 四域底部导航的内容区高度，安全区单独叠加。
  static const double bottomBarHeight = 54;
  // 列表相关：分组头与行的统一垂直内边距
  static const double listHeaderVertical = 6;
  static const double listRowVertical = 8;
  // 设置行距体系：AppListTile 行内边距与分割线上下呼吸距，
  // 配合 SectionCard 默认 12px 内边距，使首行上方 / 行间 / 末行下方统一为约 16px
  static const double tileRowVertical = 4;
  static const double dividerVerticalGap = 4;
}
