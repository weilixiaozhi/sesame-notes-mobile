/// 统一数据导入模型。
///
/// 导入类型只依赖 Decimal 金额表示，不依赖数据库、服务或界面。
/// 文件解析与落库用例共享这些输入和结果，持久化编排由应用层完成。

library;

import 'dart:convert';
import 'package:decimal/decimal.dart';

/// 导入分类（CSV/云端恢复统一口径）
class ImportCategory {
  final String name;
  final String kind; // 全局仅支出模式，固定为 'expense'
  final int level; // 1 or 2
  final int sortOrder; // 排序顺序
  final String? icon;
  final String? parentName; // 二级分类的父分类名称
  /// 来源映射冻结的目标身份；重复提交继续使用相同身份。
  final String? id;
  final String? parentId;
  final String? sourceKey;

  const ImportCategory({
    required this.name,
    required this.kind,
    this.level = 1,
    this.sortOrder = 0,
    this.icon,
    this.parentName,
    this.id,
    this.parentId,
    this.sourceKey,
  });
}

/// 导入分类的完整路径键；一级分类的 [parentName] 为 null。
typedef ImportCategoryPath = ({String kind, String? parentName, String name});

/// 文件中的分类身份；缺少来源身份的行各自确认，不能按相同名称合并。
class ImportCategorySource {
  final String name;
  final String? parentName;
  final String? icon;
  final String? sourceId;
  final String? parentSourceId;
  final String? sourceScope;
  final String fileHash;
  final int rowIndex;

  const ImportCategorySource({
    required this.name,
    this.parentName,
    this.icon,
    this.sourceId,
    this.parentSourceId,
    this.sourceScope,
    required this.fileHash,
    required this.rowIndex,
  });

  String get kind => 'expense';
  ImportCategoryPath get path =>
      (kind: kind, parentName: parentName, name: name);
  String get key => sourceId != null && sourceScope != null
      ? jsonEncode(['category', sourceScope, sourceId])
      : jsonEncode(['category-row', fileHash, rowIndex]);

  @override
  bool operator ==(Object other) =>
      other is ImportCategorySource && other.key == key;
  @override
  int get hashCode => key.hashCode;
}

/// 用户明确选择新增时使用的映射值，不可与真实分类 UUID 混淆。
const importCreateCategory = '__create_category__';

/// 导入交易数据
class ImportTransaction {
  final String type; // 全局仅支出模式，固定为 'expense'
  /// 导入金额(元,Decimal 精确解析,杜绝 CSV/JSON 解析阶段的浮点尾差)。
  final Decimal amount;
  final String? categoryName;
  final String? categoryParentName;
  final String? categoryKind;
  final DateTime happenedAt;
  final String? note;
  final String? categoryId; // 预解析的分类ID（UUID，优先于categoryName）
  final String? categorySourceKey;
  final String? syncId; // 跨设备同步唯一标识
  /// 多币种:CSV 币种列。null → 账本本位币兜底。
  final String? currencyCode;

  /// 源端折算快照(折账本本位币金额)。
  ///
  /// 仅云端全量恢复路径携带:/sync/full 的 tx item 输出的 nativeAmount 是
  /// 源设备记账时按当时汇率折算的真实所见金额。null(CSV 导入/无该字段的
  /// 备份) → 落库时按本地有效汇率重算,与常规导入语义一致。
  final Decimal? nativeAmount;

  const ImportTransaction({
    required this.type,
    required this.amount,
    this.currencyCode,
    this.nativeAmount,
    this.categoryName,
    this.categoryParentName,
    this.categoryKind,
    required this.happenedAt,
    this.note,
    this.categoryId,
    this.categorySourceKey,
    this.syncId,
  });
}

/// 统一的导入数据格式
class ImportData {
  final List<ImportCategory> categories;
  final List<ImportTransaction> transactions;

  /// 账本名称（可选，用于更新账本信息）
  final String? ledgerName;

  /// 货币（可选，用于更新账本信息）
  final String? currency;

  /// AA 分摊开关（可选），由包含账本配置的导入来源提供。
  /// null → 不更新账本既有值。
  final bool? aaEnabled;

  const ImportData({
    this.categories = const [],
    this.transactions = const [],
    this.ledgerName,
    this.currency,
    this.aaEnabled,
  });
}

/// 导入结果
class ImportResult {
  final int inserted;
  final int failed;

  /// 按 UUID 幂等键跳过（已存在）的交易条数；不计入成功也不计入失败。
  final int duplicateSkipped;

  const ImportResult({
    required this.inserted,
    required this.failed,
    this.duplicateSkipped = 0,
  });
}
