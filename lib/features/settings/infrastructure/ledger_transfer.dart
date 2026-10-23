import 'package:sesame_notes/features/settings/domain/import_validation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models.dart' as schema;
import 'package:sesame_notes/features/settings/domain/import_identity.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/date/date_parser.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';

schema.ImportData buildLedgerImportData({
  required List<List<String>> rows,
  required int dataStart,
  required String targetLedgerId,
  required Map<String, int?> mapping,
  required Map<schema.ImportCategoryPath, String?> categoryMapping,
  required Map<String, int> skippedTypes,
  required Map<String, int> badRows,
  String? sourceHash,
  List<int>? sourceIndices,
}) {
  // 稳定文件指纹：解析后的二维 rows 做无歧义 JSON 序列化后哈希，
  // CRLF/BOM 等物理差异不会产生不同指纹（同一逻辑文件 → 同一指纹）。
  final fileHash =
      sourceHash ?? sha256.convert(utf8.encode(jsonEncode(rows))).toString();
  final categories = <schema.ImportCategory>[];
  final transactions = <schema.ImportTransaction>[];
  final categoryInfoMap =
      <({String name, String kind, String? parentName}), String?>{};

  // 每行先完成全部校验，再同时收集交易与所需分类，避免坏行创建孤儿分类。
  for (int i = dataStart; i < rows.length; i++) {
    final r = rows[i];

    String? getBy(String key) {
      final userIdx = mapping[key];
      if (userIdx != null && userIdx >= 0 && userIdx < r.length) {
        final val = r[userIdx].toString().trim();
        return val.isNotEmpty ? val : null;
      }
      return null;
    }

    final dateStr = getBy('date');
    final typeRaw = getBy('type') ?? 'expense';
    final amountStr = getBy('amount');
    final currencyStr = getBy('currency')?.trim().toUpperCase();
    final categoryName = getBy('category');
    final subCategoryName = getBy('sub_category');
    final categoryIcon = getBy('category_icon');
    final subCategoryIcon = getBy('sub_category_icon');
    final note = getBy('note');
    // 无标签和附件列

    // 类型识别（全局仅支出模式，仅识别支出类型）
    final typeStr = typeRaw.trim().toLowerCase();
    String? type;
    if (typeStr == '支出' ||
        typeStr == '支' ||
        typeStr == '出账' ||
        typeStr == '消费' ||
        typeStr == '花费' ||
        typeStr == '出帳' ||
        typeStr == '消費' ||
        typeStr == '花費' || // 繁体
        typeStr == 'expense' ||
        typeStr == 'spending' ||
        typeStr == 'expenditure') {
      type = 'expense';
    } else {
      // 未识别的类型：记录并跳过
      skippedTypes[typeRaw.trim()] = (skippedTypes[typeRaw.trim()] ?? 0) + 1;
      continue;
    }

    // 金额解析:缺失或无法解析的行按失败计数并跳过,
    // 禁止把坏行静默当作 0 元交易写入账本。
    if (amountStr == null) {
      badRows['amount'] = (badRows['amount'] ?? 0) + 1;
      continue;
    }
    final amount = parseImportAmount(amountStr);
    if (amount == null) {
      badRows['amount'] = (badRows['amount'] ?? 0) + 1;
      continue;
    }

    // 日期解析:缺失或格式无法识别同样按失败处理,不静默回退当前时间。
    final date = DateParser.tryParseStrict(dateStr);
    if (date == null) {
      badRows['date'] = (badRows['date'] ?? 0) + 1;
      continue;
    }

    // 无标签和附件解析

    // 处理分类：支持用户映射和二级分类
    String? finalCategoryName;
    String? finalCategoryParentName;
    String? categoryKind;
    String? categoryId;

    if (subCategoryName != null && categoryName != null) {
      final sourcePath = (
        kind: type,
        parentName: categoryName,
        name: subCategoryName,
      );
      final chosen = categoryMapping[sourcePath];
      if (chosen != null) {
        categoryId = chosen;
      } else {
        finalCategoryName = subCategoryName;
        finalCategoryParentName = categoryName;
        categoryKind = type;
      }
    } else if (categoryName != null) {
      // 只有一级分类：检查用户映射
      final sourcePath = (kind: type, parentName: null, name: categoryName);
      final chosen = categoryMapping[sourcePath];
      if (chosen != null) {
        // 用户选择了现有分类，使用预解析的ID
        categoryId = chosen;
      } else {
        // 保持原名
        finalCategoryName = categoryName;
        categoryKind = type;
      }
    }

    final transaction = schema.ImportTransaction(
      type: type,
      amount: amount,
      // 非空原值必须经过共享支持列表校验，不能静默回退成本位币。
      currencyCode: currencyStr,
      categoryName: finalCategoryName,
      categoryParentName: finalCategoryParentName,
      categoryKind: categoryKind,
      categoryId: categoryId,
      happenedAt: date,
      note: note,
      // 确定性幂等键：同一逻辑文件同一行同一账本导入多次只落一份；
      // 行号参与派生，同文件内完全相同的两行不会互相去重。
      syncId: csvImportSyncId(
        targetLedgerId: targetLedgerId,
        fileHash: fileHash,
        rowIndex: sourceIndices?[i] ?? i,
      ),
    );
    final validationErrors = validateImportTransaction(transaction);
    if (validationErrors.isNotEmpty) {
      for (final error in validationErrors) {
        badRows[error] = (badRows[error] ?? 0) + 1;
      }
      logger.warning(
        'ImportConfirmPage',
        'CSV 第 ${i + 1} 行校验失败，跳过: ${validationErrors.join("; ")}',
      );
      continue;
    }

    // 只有最终会落库且保持原分类路径的账单，才需要创建对应分类。
    if (finalCategoryName != null) {
      if (finalCategoryParentName != null) {
        categoryInfoMap.putIfAbsent((
          name: finalCategoryParentName,
          kind: type,
          parentName: null,
        ), () => categoryIcon);
        categoryInfoMap.putIfAbsent((
          name: finalCategoryName,
          kind: type,
          parentName: finalCategoryParentName,
        ), () => subCategoryIcon);
      } else {
        categoryInfoMap.putIfAbsent((
          name: finalCategoryName,
          kind: type,
          parentName: null,
        ), () => categoryIcon);
      }
    }
    transactions.add(transaction);
  }

  // 分类服务要求一级先于二级，确保父 UUID 已建立后再创建子分类。
  for (final entry in categoryInfoMap.entries.where(
    (entry) => entry.key.parentName == null,
  )) {
    categories.add(
      schema.ImportCategory(
        name: entry.key.name,
        kind: entry.key.kind,
        level: 1,
        icon: entry.value,
      ),
    );
  }
  for (final entry in categoryInfoMap.entries.where(
    (entry) => entry.key.parentName != null,
  )) {
    categories.add(
      schema.ImportCategory(
        name: entry.key.name,
        kind: entry.key.kind,
        level: 2,
        icon: entry.value,
        parentName: entry.key.parentName,
      ),
    );
  }

  return schema.ImportData(categories: categories, transactions: transactions);
}

/// 解析导入金额列：剥离符号与千分位后归一为规范化 Decimal 纯函数。
///
/// 规则（与落库金额表示一致）：
/// - 空值与非法千分位分组（如 `12,34`、`1,23,456`）一律返回 null，
///   由调用方按坏行计数跳过，绝不静默当成 0 元写入；
/// - 括号包裹与 `+/-/$¥€£` 前缀只剥离符号、不改变数值（金额始终为正），
///   括号不成对时同样返回 null；
/// - 千分位合法的写法去掉分隔符后按精确 Decimal 归一（`1,234.50` → `1234.5`），
///   非正值（0 与负数）视为缺失。
Decimal? parseImportAmount(String raw) {
  var value = raw.trim();
  if (value.isEmpty) return null;

  final wrapped = value.startsWith('(') || value.endsWith(')');
  if (wrapped) {
    if (!value.startsWith('(') || !value.endsWith(')')) return null;
    value = value.substring(1, value.length - 1);
  } else if (value.startsWith('+') || value.startsWith('-')) {
    value = value.substring(1);
  }

  if (value.startsWith(r'$') ||
      value.startsWith('¥') ||
      value.startsWith('€') ||
      value.startsWith('£')) {
    value = value.substring(1);
  }

  final validFormat = RegExp(
    r'^(?:\d+|[1-9]\d{0,2}(?:,\d{3})+)(?:\.\d{1,10})?$',
  ).hasMatch(value);
  if (!validFormat) return null;

  final parsed = parseDecimal(value.replaceAll(',', ''));
  if (parsed == null || parsed <= Decimal.zero) return null;
  final normalized = normalizeDecimal(parsed);
  if (!isNormalizedDecimal(normalized)) return null;
  return Decimal.parse(normalized);
}
