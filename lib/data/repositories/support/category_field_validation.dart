import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/text_validation.dart';

/// 校验分类的存储字段，保留合法图标和排序原值，允许省略图标及排序。
void validateCategoryFields({String? icon, num? sortOrder}) {
  try {
    if (sortOrder != null &&
        (!sortOrder.isFinite ||
            sortOrder % 1 != 0 ||
            sortOrder < -2147483648 ||
            sortOrder > 2147483647)) {
      throw const FormatException('分类排序值必须是 -2147483648 到 2147483647 之间的整数');
    }
    // 先检查 UTF-16 代理项配对，再按 Unicode 码点计长，允许合法 emoji 和组合字符。
    if (icon != null &&
        (!isWellFormedText(icon) ||
            icon.contains('\u0000') ||
            icon.runes.length > 255)) {
      throw const FormatException('分类图标格式无效或超过 255 个字符');
    }
  } catch (error, stackTrace) {
    // 日志保留字段尺寸、排序值及堆栈，不记录原始图标内容。
    logger.error(
      'CategoryFields',
      '分类字段校验失败：iconCodeUnits=${icon?.length}, sortOrder=$sortOrder',
      error,
      stackTrace,
    );
    rethrow;
  }
}
