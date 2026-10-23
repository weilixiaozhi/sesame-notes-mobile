import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';

/// 校验单个导入分类；返回空列表表示合法，否则返回错误原因列表。
///
/// 全局仅支出模式，分类必须是 expense；level 只允许 1/2，二级必须带父分类名。
List<String> validateImportCategory(ImportCategory c) {
  final errors = <String>[];
  if (!isValidName(c.name)) errors.add('分类名称为空或超过长度限制');
  if (c.kind != 'expense') errors.add('仅支持支出分类（kind=expense）');
  if (c.level != 1 && c.level != 2) errors.add('level 只能是 1 或 2');
  if (c.level == 2 && (c.parentName == null || !isValidName(c.parentName!))) {
    errors.add('二级分类必须提供 parentName');
  }
  return errors;
}

/// 校验单个导入交易；返回空列表表示合法，否则返回错误原因列表。
///
/// 金额必须为正数且符合数据库 28 位整数、10 位小数精度；币种为空时由
/// 目标账本兜底，有值时必须来自客户端支持列表，避免无法展示或折算的代码落库。
List<String> validateImportTransaction(ImportTransaction t) {
  final errors = <String>[];
  if (t.type != 'expense') errors.add('仅支持支出交易（type=expense）');
  if (t.categoryKind != null && t.categoryKind != 'expense') {
    errors.add('仅支持支出分类（kind=expense）');
  }
  if (t.amount <= Decimal.zero) errors.add('金额必须为正数');
  if (!isNormalizedDecimal(t.amount.toString())) {
    errors.add('金额最多支持 28 位整数和 10 位小数');
  }
  final nativeAmount = t.nativeAmount;
  if (nativeAmount != null) {
    if (nativeAmount <= Decimal.zero) errors.add('本位币金额必须为正数');
    if (!isNormalizedDecimal(nativeAmount.toString())) {
      errors.add('本位币金额最多支持 28 位整数和 10 位小数');
    }
  }
  final currency = t.currencyCode?.trim().toUpperCase();
  if (currency != null &&
      currency.isNotEmpty &&
      !kCurrencyCodes.contains(currency)) {
    errors.add('币种不在支持列表中');
  }
  return errors;
}
