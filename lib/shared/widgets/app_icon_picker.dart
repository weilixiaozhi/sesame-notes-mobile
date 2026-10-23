import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import 'category_icon.dart';
import 'app_form_section.dart';

/// 分类与自定义动作共用同一图标预览、分组及间距。
class AppIconPicker extends StatelessWidget {
  const AppIconPicker({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
    this.preview,
    this.trailing,
  });
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;
  final Widget? preview;
  final Widget? trailing;

  /// 将当前图标预览、扩展操作和分组网格组合为表单区域。
  @override
  Widget build(BuildContext context) => AppFormSection(
    title: AppLocalizations.of(context).categoryIconLabel,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: preview ?? _buildCurrentIconPreview(context)),
            ?trailing,
          ],
        ),
        const SizedBox(height: AppDimens.p8),
        AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
        const SizedBox(height: AppDimens.p8),
        SizedBox(
          height: AppDimens.filterSheetHeight,
          child: _GroupedIconGrid(
            selectedIcon: selectedIcon,
            onIconSelected: onIconSelected,
          ),
        ),
      ],
    ),
  );

  /// 当前预览使用统一分类配色，以主题色描边强调当前选择。
  Widget _buildCurrentIconPreview(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final primaryColor = AppTokens.primary(context);

    return Row(
      children: [
        // 当前图标使用首页同款圆角方形，主题色描边强调当前选择。
        Container(
          width: AppDimens.icon40,
          height: AppDimens.icon40,
          decoration: BoxDecoration(
            color: AppTokens.surfaceCategoryIcon(context),
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(
              AppTokens.categoryIconRadius(context, size: AppDimens.icon40),
            ),
          ),
          child: Icon(
            resolveCategoryIcon(selectedIcon),
            size: AppDimens.icon20,
            color: AppTokens.iconCategory(context),
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Text(
          l10n.categoryCurrentIcon,
          style: AppTextTokens.body(
            context,
          ).copyWith(color: AppTokens.textPrimary(context)),
        ),
      ],
    );
  }
}

class _GroupedIconGrid extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const _GroupedIconGrid({
    required this.selectedIcon,
    required this.onIconSelected,
  });

  /// 按分组展示分类图标，普通状态使用分类底色，选择状态使用高亮底色。
  @override
  Widget build(BuildContext context) {
    final iconGroups = _getIconGroups();
    final primaryColor = Theme.of(context).colorScheme.primary;

    // 使用 ListView 实现区域内滚动（不随全页 ListView 滚动）
    return ListView(
      padding: const EdgeInsets.only(top: AppDimens.p4),
      children: iconGroups.map((group) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分组标题：底部留白 12px，拉开“标题→首行图标”距离，避免与图标过于紧凑；
            // 组内行间距由 Wrap.runSpacing 控制（8px），组间间距见下方 SizedBox(18)。
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.p12),
              child: Text(
                group.title,
                style: AppTextTokens.body(
                  context,
                ).copyWith(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
            // Wrap 按图标和名称的实际高度排版；五列均分宽度，列间距与行间距独立配置。
            LayoutBuilder(
              builder: (context, constraints) {
                const crossAxisCount = 5;
                const spacing = 6.0; // 横向列间距
                const runSpacing = 8.0; // 纵向行间距
                // 均分可用宽度得到每个格子的精确宽度，保证 5 列对齐
                final itemWidth =
                    (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                    crossAxisCount;
                return Wrap(
                  spacing: spacing,
                  runSpacing: runSpacing,
                  children: group.icons.map((iconItem) {
                    final isSelected = selectedIcon == iconItem.key;
                    return SizedBox(
                      width: itemWidth,
                      child: InkWell(
                        onTap: () => onIconSelected(iconItem.key),
                        borderRadius: BorderRadius.circular(
                          AppTokens.categoryIconRadius(context),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTokens.surfaceSelected(context)
                                : AppTokens.surfaceCategoryIcon(context),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : AppTokens.border(context),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTokens.categoryIconRadius(context),
                            ),
                          ),
                          // 仅留少量内边距让盒子贴紧内容（不被强制拉高产生留白）
                          padding: const EdgeInsets.symmetric(
                            vertical: AppDimens.p4,
                          ),
                          child: Column(
                            // min：盒子高度=内容高度，彻底消除居中留白 g
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 图标
                              Icon(
                                // 键即 Lucide 图标名,经注册表反解;未命中走兜底防问号
                                resolveCategoryIcon(iconItem.key),
                                size: AppDimens.icon20,
                                color: isSelected
                                    ? primaryColor
                                    : AppTokens.iconCategory(context),
                              ),
                              const SizedBox(height: AppDimens.p4),
                              // 图标名（Lucide 原名，不翻译）
                              Text(
                                iconItem.key,
                                style: AppTextTokens.caption(context).copyWith(
                                  color: isSelected
                                      ? primaryColor
                                      : AppTokens.textTertiary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            // 末行图标→下一组标题间距 18px，与标题底部留白（12px）错位以区分分组
            const SizedBox(height: AppDimens.iconGroupGap),
          ],
        );
      }).toList(),
    );
  }

  /// 图标分组清单。key 均为 Lucide 图标名，须存在于 lucideIconLibrary
  /// （选中后该字符串直接持久化到 Category.icon）。
  /// 分组顺序："基础"固定在倒数第二（"其他"之上），业务分组在前。
  List<_IconGroup> _getIconGroups() {
    return [
      _IconGroup('餐饮美食', [
        _IconData('utensils'),
        _IconData('utensilsCrossed'),
        _IconData('sandwich'),
        _IconData('coffee'),
        _IconData('wine'),
        _IconData('pizza'),
        _IconData('cake'),
        _IconData('cakeSlice'),
        _IconData('croissant'),
        _IconData('iceCream'),
        _IconData('cookie'),
        _IconData('candy'),
        _IconData('beer'),
        _IconData('martini'),
        _IconData('chefHat'),
        _IconData('soup'),
        _IconData('beef'),
        _IconData('milk'),
        _IconData('cupSoda'),
        _IconData('glassWater'),
      ]),
      _IconGroup('交通出行', [
        _IconData('car'),
        _IconData('bus'),
        _IconData('train'),
        _IconData('plane'),
        _IconData('bike'),
        _IconData('footprints'),
        _IconData('ship'),
        _IconData('navigation'),
        _IconData('fuel'),
        _IconData('parkingCircle'),
        _IconData('truck'),
        _IconData('key'),
      ]),
      _IconGroup('购物消费', [
        _IconData('shoppingCart'),
        _IconData('shoppingBag'),
        _IconData('store'),
        _IconData('building'),
        _IconData('carrot'),
        _IconData('package'),
        _IconData('boxes'),
        _IconData('tags'),
        _IconData('receipt'),
        _IconData('tag'),
        _IconData('badgePercent'),
        _IconData('gift'),
        _IconData('award'),
        _IconData('ticket'),
        _IconData('badgeCheck'),
      ]),
      _IconGroup('居住生活', [
        _IconData('home'),
        _IconData('building2'),
        _IconData('sofa'),
        _IconData('bed'),
        _IconData('bath'),
        _IconData('armchair'),
        _IconData('tv'),
        _IconData('refrigerator'),
        _IconData('lightbulb'),
        _IconData('airVent'),
        _IconData('zap'),
        _IconData('droplet'),
        _IconData('wind'),
        _IconData('sprayCan'),
        _IconData('wrench'),
        _IconData('hammer'),
        _IconData('paintbrush'),
        _IconData('scroll'),
      ]),
      _IconGroup('通讯设备', [
        _IconData('phone'),
        _IconData('smartphone'),
        _IconData('tablet'),
        _IconData('laptop'),
        _IconData('monitor'),
        _IconData('watch'),
        _IconData('headphones'),
        _IconData('keyboard'),
        _IconData('mouse'),
        _IconData('wifi'),
        _IconData('router'),
        _IconData('plug'),
      ]),
      _IconGroup('娱乐休闲', [
        _IconData('clapperboard'),
        _IconData('music'),
        _IconData('gamepad2'),
        _IconData('venetianMask'),
        _IconData('dice5'),
        _IconData('partyPopper'),
        _IconData('moon'),
        _IconData('ticket'),
        _IconData('ferrisWheel'),
        _IconData('umbrella'),
        _IconData('waves'),
        _IconData('flower'),
        _IconData('goal'),
        _IconData('medal'),
        _IconData('trophy'),
        _IconData('target'),
      ]),
      _IconGroup('健康医疗', [
        _IconData('cross'),
        _IconData('stethoscope'),
        _IconData('pill'),
        _IconData('shieldCheck'),
        _IconData('syringe'),
        _IconData('dumbbell'),
        _IconData('sunrise'),
        _IconData('brain'),
        _IconData('heartPulse'),
        _IconData('activity'),
        _IconData('user'),
        _IconData('clipboardList'),
        _IconData('atom'),
        _IconData('biohazard'),
        _IconData('thermometer'),
      ]),
      _IconGroup('教育学习', [
        _IconData('graduationCap'),
        _IconData('bookOpen'),
        _IconData('library'),
        _IconData('bookMarked'),
        _IconData('pencil'),
        _IconData('edit2'),
        _IconData('calculator'),
        _IconData('flaskConical'),
        _IconData('brush'),
        _IconData('palette'),
        _IconData('film'),
        _IconData('languages'),
        _IconData('badgeHelp'),
      ]),
      _IconGroup('宠物动物', [
        _IconData('dog'),
        _IconData('cat'),
        _IconData('bone'),
        _IconData('bug'),
        _IconData('flower2'),
        _IconData('treePine'),
        _IconData('shrub'),
        _IconData('trees'),
        _IconData('sprout'),
        _IconData('leaf'),
        _IconData('fish'),
        _IconData('wheat'),
      ]),
      _IconGroup('服装美容', [
        _IconData('shirt'),
        _IconData('smile'),
        _IconData('sparkles'),
        _IconData('scissors'),
        _IconData('sparkle'),
        _IconData('droplets'),
        _IconData('gem'),
        _IconData('clock'),
        _IconData('bell'),
        _IconData('hand'),
      ]),
      _IconGroup('基础', [
        _IconData('category'),
        _IconData('tag'),
        _IconData('bookmark'),
        _IconData('star'),
        _IconData('heart'),
        _IconData('circle'),
      ]),
      _IconGroup('其他杂项', [
        _IconData('camera'),
        _IconData('image'),
        _IconData('video'),
        _IconData('printer'),
        _IconData('mail'),
        _IconData('inbox'),
        _IconData('globe'),
        _IconData('mapPin'),
        _IconData('map'),
        _IconData('compass'),
        _IconData('timer'),
        _IconData('calendarClock'),
        _IconData('handCoins'),
      ]),
    ];
  }
}

class _IconGroup {
  final String title;
  final List<_IconData> icons;

  const _IconGroup(this.title, this.icons);
}

class _IconData {
  /// Lucide 图标名（lucideIconLibrary 的键，持久化到 Category.icon）
  final String key;

  const _IconData(this.key);
}
