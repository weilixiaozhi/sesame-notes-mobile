import 'dart:ui' show Locale;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/default_category_keys.dart';
import 'package:sesame_notes/utils/category_template_names.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:sesame_notes/data/services/category_seed_service.dart';
import 'package:sesame_notes/utils/default_category_seed_catalog.dart';

/// 首次初始化默认分类模板，并为分类模板选择页提供名称和图标映射。
class SeedService {
  SeedService._();

  /// 首次初始化入口：只落默认分类模板。
  ///
  /// [l10n] 国际化对象，如果为null则使用英文作为默认语言。
  ///
  /// 分类固定创建混合层次模板（一级+二级并存），无模式开关。
  /// 各业务在首次新增数据时按需创建默认本子，避免账号已有云端本子时，
  /// 新装应用又自动建出一本同名本子。
  static Future<void> ensureSeed(
    SesameDatabase db, {
    AppLocalizations? l10n,
  }) async {
    logger.info('db', 'ensureSeed 被调用');
    logger.info('db', 'l10n 是否提供: ${l10n != null}');

    // 如果没有提供l10n，使用Lookup创建默认的英文版本
    final effectiveL10n = l10n ?? lookupAppLocalizations(const Locale('en'));
    logger.info('db', '使用的语言环境: ${l10n != null ? "提供的l10n" : "默认英文"}');

    try {
      await createHybridCategories(db, effectiveL10n);
    } catch (error, stackTrace) {
      logger.error('seed', '默认分类初始化失败', error, stackTrace);
      rethrow;
    }
    logger.info('db', '数据库初始化完成');
  }

  /// 正式账号目录采用固定模板，只有已确认全新或权威空目录时由账号生命周期调用。
  static Future<void> ensureAccountSeed(
    SesameDatabase db,
    String accountId,
  ) async {
    try {
      await CategorySeedService.ensureAccountSeed(db, accountId);
    } catch (error, stack) {
      logger.error(
        'SeedService',
        '初始化账号正式分类目录失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 默认分类的确定性 syncId。key 用**稳定的 seed key**(不是翻译后的名字),
  /// 这样任何设备、任何语言 seed 出来的同一个默认分类都得到同一个 syncId,
  /// 云端按 syncId 天然只留一份 —— 从源头杜绝多设备各自 seed 造成的重复。
  static String deterministicCategorySyncId({
    required int level,
    required String key,
  }) => defaultCategoryId(level: level, key: key);

  /// 所有分类模板共用一份树结构，根节点与子节点只表达包含关系。
  static const Map<String, List<String>> categoryTemplates =
      kExpenseCategoryTemplates;

  /// 新账号初始内容选择，顺序决定首次创建的显示排序；不改变模板库结构。
  static const List<({String key, List<String>? children})>
  hybridCategoryTemplate = [
    (
      key: 'dining',
      children: ['dining_breakfast', 'dining_lunch', 'dining_dinner'],
    ),
    (
      key: 'beverage',
      children: [
        'beverage_milk_tea',
        'beverage_coffee',
        'beverage_juice',
        'beverage_soda',
        'beverage_water',
      ],
    ),
    (
      key: 'shopping',
      children: [
        'shopping_supermarket',
        'shopping_clothing',
        'shopping_shoes',
        'shopping_bag',
      ],
    ),
    (
      key: 'transport',
      children: [
        'transport_transitcard',
        'transport_taxi',
        'transport_parking',
        'transport_fuel',
      ],
    ),
    // 通讯：独立一级分类（话费/网费等），模板库 flat 清单已有该 key，翻译/图标直接复用
    (key: 'communication', children: null),
    (key: 'fruit', children: null),
    (key: 'snacks', children: null),
    (key: 'sports', children: null),
    (
      key: 'pets',
      children: ['pets_food', 'pets_supplies', 'pets_medical', 'pets_grooming'],
    ),
    (
      key: 'housing',
      children: [
        'housing_utilities',
        'housing_property',
        'housing_rent',
        'housing_mortgage',
        'housing_broadband',
      ],
    ),
    (
      key: 'transfer',
      children: [
        'transfer_livingcost',
        'transfer_family',
        'transfer_parents',
        'transfer_lover',
        'transfer_borrowmoney',
      ],
    ),
    (
      key: 'subscription',
      children: ['subscription_video', 'subscription_music'],
    ),
    (
      key: 'entertainment',
      children: [
        'entertainment_movie',
        'entertainment_ktv',
        'entertainment_amusement',
      ],
    ),
    (key: 'education', children: ['education_books', 'education_learning']),
    (key: 'gift', children: null),
    (key: 'game', children: null),
    (
      key: 'beauty',
      children: [
        'beauty_skincare',
        'beauty_cosmetics',
        'beauty_salon',
        'beauty_nail',
      ],
    ),
    (key: 'medical', children: null),
    (key: 'digital', children: null),
    (key: 'other', children: null),
  ];

  // ========== 分类图标映射 ==========

  /// 获取分类的默认图标（Lucide 图标名，须存在于 lucideIconLibrary）
  /// 注意：这里只提供默认图标，不做名称匹配
  static String getDefaultIcon(String categoryKey) {
    // 支出分类图标（值均为 Lucide 图标名，与 app_icons.dart 注册表一致）
    const expenseIcons = {
      // 一级分类
      'dining': 'utensils',
      'transport': 'bus',
      'shopping': 'shoppingCart',
      'entertainment': 'partyPopper',
      'home': 'home',
      'family': 'users',
      'communication': 'phone',
      'utilities': 'zap',
      'housing': 'building2',
      'medical': 'cross',
      'education': 'graduationCap',
      'pets': 'dog',
      'sports': 'dumbbell',
      'digital': 'smartphone',
      'travel': 'plane',
      'alcohol_tobacco': 'beer',
      'baby_care': 'baby',
      'beauty': 'sparkles',
      'repair': 'wrench',
      'social': 'users2',
      'learning': 'library',
      'car': 'car',
      // Lucide 无出租车专用图标，以汽车近似
      'taxi': 'car',
      // Lucide 无地铁专用图标，以火车近似
      'subway': 'train',
      'delivery': 'bike',
      'property': 'building',
      'parking': 'parkingCircle',
      'donation': 'heartHandshake',
      'gift': 'gift',
      'tax': 'receipt',
      'beverage': 'milk',
      'clothing': 'shirt',
      'snacks': 'lollipop',
      'red_packet': 'wallet',
      'fruit': 'apple',
      'pastry': 'cake',
      'cooking': 'chefHat',
      'game': 'gamepad2',
      'book': 'bookOpen',
      'invest_loss': 'trendingDown',
      'health_products': 'pill',
      'subscription': 'calendarClock',
      'lover': 'heart',
      'decoration': 'paintbrush',
      'daily_goods': 'package',
      'lottery': 'ticket',
      'stock': 'trendingUp',
      'social_security': 'shieldCheck',
      'express': 'truck',
      'work': 'briefcase',
      // 兜底独立一级分类「其他」
      'other': 'package',

      // 餐饮二级分类
      'dining_breakfast': 'sandwich',
      'dining_lunch': 'salad',
      'dining_dinner': 'soup',
      'dining_meituan': 'bike',
      'dining_eleme': 'bike',
      'dining_jd': 'bike',
      'dining_restaurant': 'utensils',
      'dining_food': 'pizza',

      // 零食二级分类
      'snacks_biscuit': 'cookie',
      'snacks_chips': 'popcorn',
      'snacks_candy': 'candy',
      'snacks_chocolate': 'candy',
      'snacks_nuts': 'wheat',

      // 水果二级分类
      'fruit_apple': 'apple',
      'fruit_banana': 'banana',
      'fruit_orange': 'citrus',
      'fruit_grape': 'grape',
      // Lucide 无西瓜图标，以圆形水果柑橘近似
      'fruit_watermelon': 'citrus',
      'fruit_other': 'cherry',

      // 饮品二级分类
      'beverage_milk_tea': 'cupSoda',
      'beverage_coffee': 'coffee',
      'beverage_juice': 'glassWater',
      'beverage_soda': 'beer',
      'beverage_water': 'glassWater',

      // 糕点二级分类
      'pastry_cake': 'cakeSlice',
      'pastry_bread': 'croissant',
      'pastry_dessert': 'iceCream',
      'pastry_biscuit': 'cookie',

      // 做饭食材二级分类
      'cooking_vegetable': 'carrot',
      'cooking_meat': 'beef',
      'cooking_seafood': 'fish',
      // Lucide 无调料图标，以汤品近似（同属厨房烹饪）
      'cooking_seasoning': 'soup',
      'cooking_grain': 'wheat',

      // 购物二级分类
      'shopping_supermarket': 'shoppingCart',
      'shopping_clothing': 'shirt',
      // Lucide 无鞋子图标，以脚印近似
      'shopping_shoes': 'footprints',
      'shopping_bag': 'shoppingBag',
      'shopping_daily': 'shoppingCart',

      // 宠物二级分类
      'pets_food': 'bone',
      'pets_supplies': 'boxes',
      'pets_medical': 'stethoscope',
      'pets_grooming': 'showerHead',

      // 交通二级分类
      'transport_transitcard': 'walletCards',
      'transport_taxi': 'car',
      'transport_parking': 'parkingCircle',
      'transport_fuel': 'fuel',

      // 汽车二级分类
      'car_maintenance': 'hammer',
      'car_repair': 'wrench',
      'car_insurance': 'shield',
      'car_wash': 'droplets',
      'car_fine': 'alertTriangle',

      // 服饰二级分类
      'clothing_top': 'shirt',
      // Lucide 无裤子图标，以上衣近似
      'clothing_pants': 'shirt',
      'clothing_skirt': 'sparkle',
      'clothing_shoes': 'footprints',
      'clothing_accessory': 'watch',

      // 日用品二级分类
      'daily_toiletries': 'sprayCan',
      'daily_paper': 'scroll',
      'daily_cleaning': 'brush',
      'daily_kitchen': 'refrigerator',

      // 教育二级分类
      'education_tuition': 'graduationCap',
      'education_training': 'presentation',
      'education_books': 'bookOpen',
      'education_stationery': 'pencil',
      'education_office': 'briefcase',
      'education_learning': 'library',

      // 投资亏损二级分类
      'invest_loss_stock': 'trendingDown',
      'invest_loss_fund': 'lineChart',
      'invest_loss_other': 'banknote',

      // 娱乐二级分类
      'entertainment_movie': 'clapperboard',
      'entertainment_ktv': 'mic',
      'entertainment_amusement': 'ferrisWheel',
      'entertainment_bar': 'martini',
      'entertainment_other': 'partyPopper',

      // 游戏二级分类
      'game_recharge': 'coins',
      'game_equipment': 'headphones',
      'game_membership': 'crown',

      // 保健品二级分类
      'health_vitamin': 'pill',
      'health_food': 'salad',
      'health_nutrition': 'heartPulse',

      // 订阅服务二级分类
      'subscription_video': 'playCircle',
      'subscription_music': 'music',
      'subscription_cloud': 'cloud',
      'subscription_other': 'repeat',

      // 转账一级与二级分类
      'transfer': 'handCoins',
      'transfer_livingcost': 'heartHandshake',
      'transfer_family': 'users',
      'transfer_parents': 'users2',
      'transfer_lover': 'heart',
      'transfer_borrowmoney': 'coins',

      // 运动二级分类
      'sports_gym': 'dumbbell',
      'sports_equipment': 'medal',
      'sports_course': 'target',
      'sports_outdoor': 'mountain',

      // 住房二级分类
      'housing_utilities': 'zap',
      'housing_rent': 'key',
      'housing_property': 'building',
      'housing_mortgage': 'landmark',
      'housing_decoration': 'paintbrush',
      // 宽带使用 wifi 图标（Lucide 无宽带专用图标，wifi 语义最贴近）
      'housing_broadband': 'wifi',

      // 居家二级分类
      'home_furniture': 'sofa',
      'home_appliance': 'tv',
      'home_decor': 'palette',
      'home_bedding': 'bed',

      // 美容二级分类
      'beauty_skincare': 'smile',
      'beauty_cosmetics': 'palette',
      'beauty_salon': 'scissors',
      'beauty_nail': 'hand',
    };

    return expenseIcons[categoryKey] ?? 'category';
  }

  // ========== 种子数据生成方法 ==========

  /// 模板与初始化共用节点名称入口，翻译内容不依赖分类层级。
  static String getTranslatedCategoryName(String key, AppLocalizations l10n) =>
      categoryTemplateName(key, l10n);

  /// 首次初始化按默认选择创建分类树，稳定身份仅服务多设备初始化幂等。
  /// 节点排序按所在集合递增，用户后续从模板创建使用独立身份。
  static Future<void> createHybridCategories(
    SesameDatabase db,
    AppLocalizations l10n, {
    String? scopeAccountId,
  }) async {
    try {
      final categories = <CategorySeedItem>[];
      var sortOrder = 0;
      for (final entry in hybridCategoryTemplate) {
        final key = entry.key;
        final children = entry.children;
        categories.add(
          CategorySeedItem(
            key,
            getTranslatedCategoryName(key, l10n),
            getDefaultIcon(key),
            1,
            sortOrder++,
          ),
        );
        if (children == null) continue;
        // 父项先于子项，二级分类的顺序只在同一父分类内递增。
        for (var i = 0; i < children.length; i++) {
          final childKey = children[i];
          categories.add(
            CategorySeedItem(
              childKey,
              getTranslatedCategoryName(childKey, l10n),
              getDefaultIcon(childKey),
              2,
              i,
              key,
            ),
          );
        }
      }
      await CategorySeedService.ensureCategories(
        db,
        categories,
        scopeAccountId: scopeAccountId,
      );
    } catch (error, stack) {
      logger.error(
        'SeedService',
        '映射并初始化默认分类失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }
}
