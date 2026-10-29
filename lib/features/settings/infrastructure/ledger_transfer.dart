import 'package:sesame_notes/features/settings/domain/import_validation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/data/models.dart' as schema;
import 'package:sesame_notes/features/settings/domain/import_identity.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/date/date_parser.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'transfer_table.dart' show transferId;

/// 无分类身份列的旧文件沿用九字段交易指纹，新增空列不能改变历史导入身份。
String ledgerTransactionFileHash(List<Map<String, Object?>> rows) {
  try {
    const identityFields = {
      'category_scope',
      'category_id',
      'parent_category_id',
    };
    final hasIdentity = rows.any(
      (row) => identityFields.any(
        (field) => row[field]?.toString().trim().isNotEmpty == true,
      ),
    );
    final content = hasIdentity
        ? rows
        : [
            for (final row in rows)
              Map<String, Object?>.fromEntries(
                row.entries.where(
                  (entry) => !identityFields.contains(entry.key),
                ),
              ),
          ];
    return sha256.convert(utf8.encode(jsonEncode(content))).toString();
  } catch (error, stack) {
    logger.error('LedgerImport', '计算交易导入身份失败', error, stack);
    rethrow;
  }
}

/// 分类来源指纹采用跨端固定字段顺序，交易旧指纹保持自身的兼容规则。
String ledgerCategoryFileHash(List<Map<String, Object?>> rows) {
  const fields = [
    'date',
    'type',
    'amount',
    'currency',
    'category',
    'sub_category',
    'category_icon',
    'sub_category_icon',
    'category_scope',
    'category_id',
    'parent_category_id',
    'note',
  ];

  /// 空类型沿用支出默认值，其余字段按文件显示内容保持稳定。
  String value(Map<String, Object?> row, String field) {
    final raw = (row[field]?.toString() ?? '').trim();
    return field == 'type' && raw.isEmpty ? 'expense' : raw;
  }

  return sha256
      .convert(
        utf8.encode(
          jsonEncode([
            for (final row in rows)
              [for (final field in fields) value(row, field)],
          ]),
        ),
      )
      .toString();
}

/// 按来源身份读取分类，旧文件以行号区分未确认的同名来源。
schema.ImportCategorySource? ledgerImportCategorySource(
  Map<String, Object?> row, {
  required String fileHash,
  required int rowIndex,
}) {
  String? text(String key) {
    final value = row[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }

  final parent = text('category');
  final child = text('sub_category');
  if (parent == null && child == null && text('category_id') == null) {
    return null;
  }
  return schema.ImportCategorySource(
    name: child ?? parent ?? '',
    parentName: child == null ? null : parent,
    icon: text(child == null ? 'category_icon' : 'sub_category_icon'),
    sourceId: text('category_id'),
    parentSourceId: text('parent_category_id'),
    sourceScope: text('category_scope'),
    fileHash: fileHash,
    rowIndex: rowIndex,
  );
}

/// 将已确认的分类映射转换成冻结身份的导入草稿。
schema.ImportData buildLedgerImportData({
  required List<List<String>> rows,
  required int dataStart,
  required String targetLedgerId,
  required Map<String, int?> mapping,
  required Map<Object, String?> categoryMapping,
  bool requireExplicitMapping = false,
  required Map<String, int> skippedTypes,
  required Map<String, int> badRows,
  String? sourceHash,
  String? categorySourceHash,
  List<int>? sourceIndices,
}) {
  // 稳定文件指纹：解析后的二维 rows 做无歧义 JSON 序列化后哈希，
  // CRLF/BOM 等物理差异不会产生不同指纹（同一逻辑文件 → 同一指纹）。
  final fileHash =
      sourceHash ?? sha256.convert(utf8.encode(jsonEncode(rows))).toString();
  final categories = <String, schema.ImportCategory>{};
  final transactions = <schema.ImportTransaction>[];

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
    final categoryIcon = getBy('category_icon');
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

    final source = ledgerImportCategorySource(
      {for (final key in mapping.keys) key: getBy(key)},
      fileHash: categorySourceHash ?? fileHash,
      rowIndex: sourceIndices?[i] ?? i,
    );
    String? categoryId;
    String? categorySourceKey;
    final drafts = <schema.ImportCategory>[];
    if (source != null) {
      if (source.sourceId != null && source.sourceId == source.parentSourceId) {
        badRows['分类：来源分类不能引用自身作为父分类'] =
            (badRows['分类：来源分类不能引用自身作为父分类'] ?? 0) + 1;
        continue;
      }
      final chosen =
          categoryMapping[source] ??
          (source.sourceId == null ? categoryMapping[source.path] : null);
      if (chosen == null && requireExplicitMapping) {
        badRows['分类：请选择目标分类或明确添加新分类'] =
            (badRows['分类：请选择目标分类或明确添加新分类'] ?? 0) + 1;
        continue;
      }
      if (chosen != null && chosen != schema.importCreateCategory) {
        categoryId = chosen;
      } else {
        categorySourceKey = source.key;
        String? targetParentId;
        if (source.parentName != null) {
          final parentKey =
              source.parentSourceId != null && source.sourceScope != null
              ? jsonEncode([
                  'category',
                  source.sourceScope,
                  source.parentSourceId,
                ])
              : jsonEncode(['category-parent', source.key]);
          targetParentId = transferId([
            'category-import',
            targetLedgerId,
            parentKey,
          ]);
          drafts.add(
            schema.ImportCategory(
              id: targetParentId,
              sourceKey: parentKey,
              name: source.parentName!,
              kind: type,
              level: 1,
              icon: categoryIcon,
            ),
          );
        }
        drafts.add(
          schema.ImportCategory(
            id: transferId(['category-import', targetLedgerId, source.key]),
            sourceKey: source.key,
            parentId: targetParentId,
            name: source.name,
            kind: type,
            level: source.parentName == null ? 1 : 2,
            parentName: source.parentName,
            icon: source.icon,
          ),
        );
      }
    }

    final transaction = schema.ImportTransaction(
      type: type,
      amount: amount,
      // 非空原值必须经过共享支持列表校验，不能静默回退成本位币。
      currencyCode: currencyStr,
      categoryName: categorySourceKey == null ? null : source?.name,
      categoryParentName: categorySourceKey == null ? null : source?.parentName,
      categoryKind: categorySourceKey == null ? null : type,
      categorySourceKey: categorySourceKey,
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

    // 同一来源身份必须描述相同内容；不能通过先写入的草稿吞掉相冲突的子项。
    final additions = <String, schema.ImportCategory>{};
    var inconsistent = false;
    for (final draft in drafts) {
      final previous = additions[draft.id] ?? categories[draft.id];
      if (previous != null &&
          (previous.name != draft.name ||
              previous.icon != draft.icon ||
              previous.parentId != draft.parentId ||
              previous.level != draft.level)) {
        inconsistent = true;
        break;
      }
      additions[draft.id!] = draft;
    }
    if (inconsistent) {
      badRows['分类：同一来源分类包含不一致内容'] = (badRows['分类：同一来源分类包含不一致内容'] ?? 0) + 1;
      continue;
    }
    categories.addAll(additions);
    transactions.add(transaction);
  }

  return schema.ImportData(
    categories: categories.values.toList()
      ..sort((a, b) => a.level.compareTo(b.level)),
    transactions: transactions,
  );
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
