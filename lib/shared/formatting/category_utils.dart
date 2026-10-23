import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/default_category_keys.dart';

/// 分类工具类
/// 负责处理分类名称的显示、翻译等
class CategoryUtils {
  CategoryUtils._();

  /// 分隔符：用于在翻译字符串中分隔多个分类名称
  static const String separator = '-';

  /// 层级与翻译位置来自真实模板，父键或子键中的下划线不承担结构含义。
  static final Map<String, ({String parent, int index})>
  _hierarchyNamePositions = {
    for (final entry in kHierarchicalExpenseCategories.entries)
      entry.key: (parent: entry.key, index: 0),
    for (final entry in kHierarchicalExpenseCategories.entries)
      for (var index = 0; index < entry.value.length; index++)
        entry.value[index]: (parent: entry.key, index: index + 1),
  };

  /// 仅默认模板中的身份键需要翻译，自定义名称保持原文。
  static bool isCategoryKey(String name) =>
      kFlatExpenseCategoryKeys.contains(name) ||
      _hierarchyNamePositions.containsKey(name);

  /// 获取分类的显示名称
  ///
  /// 默认模板身份键通过 l10n 翻译，自定义分类名称保持原文。
  static String getDisplayName(String? categoryName, BuildContext context) {
    return getLocalizedDisplayName(categoryName, AppLocalizations.of(context));
  }

  /// 使用已解析的本地化资源生成分类展示名，供异步任务安全复用。
  static String getLocalizedDisplayName(
    String? categoryName,
    AppLocalizations l10n,
  ) {
    if (categoryName == null || categoryName.isEmpty) {
      return l10n.categoryDefaultTitle;
    }

    // 默认模板身份键按当前语言翻译。
    if (isCategoryKey(categoryName)) {
      return _translateCategoryKey(categoryName, l10n);
    }

    // 自定义分类名称保持原文。
    return categoryName;
  }

  /// 翻译分类key为显示名称
  static String _translateCategoryKey(String key, AppLocalizations l10n) {
    final flatIndex = kFlatExpenseCategoryKeys.indexOf(key);
    if (flatIndex >= 0) {
      return _nameAt(l10n.categoryExpenseList, flatIndex, key);
    }
    final position = _hierarchyNamePositions[key];
    if (position == null) return key;
    return _nameAt(
      _getExpenseSubcategoryTranslation(position.parent, l10n),
      position.index,
      key,
    );
  }

  /// 每组翻译的首项为父分类，后续项按模板子分类顺序排列。
  static String _getExpenseSubcategoryTranslation(
    String parentKey,
    AppLocalizations l10n,
  ) {
    switch (parentKey) {
      case 'dining':
        return l10n.categoryExpenseDining;
      case 'snacks':
        return l10n.categoryExpenseSnacks;
      case 'fruit':
        return l10n.categoryExpenseFruit;
      case 'beverage':
        return l10n.categoryExpenseBeverage;
      case 'pastry':
        return l10n.categoryExpensePastry;
      case 'cooking':
        return l10n.categoryExpenseCooking;
      case 'shopping':
        return l10n.categoryExpenseShopping;
      case 'pets':
        return l10n.categoryExpensePets;
      case 'transport':
        return l10n.categoryExpenseTransport;
      case 'car':
        return l10n.categoryExpenseCar;
      case 'clothing':
        return l10n.categoryExpenseClothing;
      case 'daily_goods':
        return l10n.categoryExpenseDailyGoods;
      case 'education':
        return l10n.categoryExpenseEducation;
      case 'invest_loss':
        return l10n.categoryExpenseInvestLoss;
      case 'entertainment':
        return l10n.categoryExpenseEntertainment;
      case 'game':
        return l10n.categoryExpenseGame;
      case 'health_products':
        return l10n.categoryExpenseHealthProducts;
      case 'subscription':
        return l10n.categoryExpenseSubscription;
      case 'sports':
        return l10n.categoryExpenseSports;
      case 'housing':
        return l10n.categoryExpenseHousing;
      case 'home':
        return l10n.categoryExpenseHome;
      case 'beauty':
        return l10n.categoryExpenseBeauty;
      case 'transfer':
        return l10n.categoryExpenseTransfer;
      default:
        return '';
    }
  }

  /// 缺失或越界的翻译保留原键，防止模板与本地化数据不齐时显示空名称。
  static String _nameAt(String translation, int index, String fallback) {
    final names = translation.split(separator);
    return index < names.length && names[index].trim().isNotEmpty
        ? names[index].trim()
        : fallback;
  }
}
