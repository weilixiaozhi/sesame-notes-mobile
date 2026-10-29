import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/utils/default_category_keys.dart';
import 'package:sesame_notes/utils/category_template_names.dart';

/// 分类显示名只翻译历史资源键，用户填写的其他名称保持原文。
class CategoryUtils {
  CategoryUtils._();

  /// 历史分类名称键由唯一模板树派生，不维护额外的平铺或分层目录。
  static final Set<String> _keys = {
    for (final entry in kExpenseCategoryTemplates.entries) ...[
      entry.key,
      ...entry.value,
    ],
  };

  /// 判断历史存储名称是否为资源键。
  static bool isCategoryKey(String name) => _keys.contains(name);

  /// 从当前页面语言生成分类显示名。
  static String getDisplayName(String? name, BuildContext context) =>
      getLocalizedDisplayName(name, AppLocalizations.of(context));

  /// 已有分类名不参与身份识别，仅在读取历史资源键时进行本地化。
  static String getLocalizedDisplayName(String? name, AppLocalizations l10n) {
    if (name == null || name.isEmpty) return l10n.categoryDefaultTitle;
    return isCategoryKey(name) ? categoryTemplateName(name, l10n) : name;
  }
}
