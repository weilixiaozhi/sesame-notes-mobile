import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:decimal/decimal.dart';
import 'package:path/path.dart' as p;

import 'package:sesame_notes/data/models/expense_type.dart';
import 'export_file_name.dart';
import '../domain/import_identity.dart';

/// 导出结果：实际文件路径 + 展示用路径。
typedef DetailExportResult = ({String path, String displayPath});

/// CSV 表头与支出类型的本地化文案。
typedef DetailExportLabels = ({
  String type,
  String category,
  String subCategory,
  String amount,
  String currency,
  String note,
  String time,
  String expense,
});

/// 纯 Dart 日期闭区间。
typedef DetailExportDateRange = ({DateTime start, DateTime end});

/// 将指定账本的交易明细导出为 CSV 文件。
///
/// [dateRange] 非空时仅导出该时间范围内的交易(由导出明细页的
/// 起止日期展开而来);为空则导出该账本全部交易(对应「全选数据」勾选)。
/// 文件先写入临时目录，再由页面通过系统分享面板交给用户选择保存位置。
Future<DetailExportResult> exportDetailCsv({
  required AccountingTransferRepository repo,
  required CategoryQueryRepository categoryQueries,
  required String ledgerId,
  required DetailExportLabels labels,
  required String Function(String?) categoryLabel,
  DetailExportDateRange? dateRange,
  required void Function(double) onProgress,

  /// 文件名用的业务名与本名，由页面按当前语言给出。
  required String business,
  required String ledgerName,
  required Directory outputDirectory,
}) async {
  final dir = outputDirectory;
  final displayDirPath = dir.path;
  final directory = dir.path;

  // 获取交易和分类数据
  final transactionsWithCategory = await repo.transactionsWithCategoryAll(
    ledgerId: ledgerId,
  );

  // 按时间范围过滤(为空则全部)
  final list = dateRange == null
      ? transactionsWithCategory
      : transactionsWithCategory.where((txWithCat) {
          final d = txWithCat.t.happenedAt;
          // 闭区间:落在 [start, end] 内即导出
          return !d.isBefore(dateRange.start) && !d.isAfter(dateRange.end);
        }).toList();

  final total = list.length;
  final ledger = await repo.getLedgerById(ledgerId);
  if (ledger == null) throw StateError('导出账本不存在，请重新选择');
  final categoryScope = ledgerCategorySourceScope(
    ledgerId: ledger.id,
    storageMode: ledger.storageMode,
    ownerAccountId: ledger.ownerAccountId,
  );
  final rows = <List<dynamic>>[];
  rows.add([
    labels.type,
    labels.category,
    labels.subCategory, // 二级分类名称
    labels.amount,
    labels.currency, // 多币种:交易原币种
    labels.note,
    labels.time,
    'category_scope',
    'category_id',
    'parent_category_id',
    'category_icon',
    'sub_category_icon',
  ]);

  // 父子分类只从本次导出账本的真实目录解析，同 UUID 的其他账号分类不会参与导出。
  final allCategories = {
    for (final cat in await categoryQueries.getAllCategoriesIncludingShared(
      ledgerId: ledgerId,
    ))
      cat.id: cat,
  };

  for (int i = 0; i < list.length; i++) {
    final txWithCat = list[i];
    final t = txWithCat.t;
    final c = txWithCat.category;
    requireExpenseType(t.txType);

    // 完整时间格式:YYYY-MM-DD HH:mm:ss,前后补空格增加列宽
    final timeStr = () {
      try {
        final localTime = t.happenedAt.toLocal();
        return '  ${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}  ';
      } catch (e) {
        return '';
      }
    }();

    String categoryName;
    String subCategoryName;
    if (c != null) {
      if (c.level == 2 && c.parentId != null) {
        // 二级分类:分类列填一级分类名,二级分类列填当前分类名
        final parentCategory = allCategories[c.parentId];
        categoryName = categoryLabel(parentCategory?.name);
        subCategoryName = categoryLabel(c.name);
      } else {
        categoryName = categoryLabel(c.name);
        subCategoryName = '';
      }
    } else {
      categoryName = '';
      subCategoryName = '';
    }

    // 按十进制原值输出金额，至少保留两位小数；更高精度记录不能在导出时丢失。
    final currencyStr = t.currencyCode.toUpperCase();
    final amount = Decimal.parse(t.amount);
    rows.add([
      labels.expense,
      categoryName,
      subCategoryName,
      amount.toStringAsFixed(amount.scale < 2 ? 2 : amount.scale),
      currencyStr,
      t.note ?? '',
      timeStr,
      categoryScope,
      c?.id ?? '',
      c?.parentId ?? '',
      c?.level == 2 ? allCategories[c?.parentId]?.icon ?? '' : c?.icon ?? '',
      c?.level == 2 ? c?.icon ?? '' : '',
    ]);
    if (i % 50 == 0) {
      onProgress((i + 1) / (total == 0 ? 1 : total));
    }
  }

  // CsvEncoder 按 \n 行分隔符输出 CSV。
  final csvStr = const CsvEncoder(lineDelimiter: '\n').convert(rows);
  final fileName = exportFileName(
    business: business,
    content: ledgerName,
    extension: 'csv',
    exportedAt: DateTime.now(),
  );
  final path = p.join(directory, fileName);

  // 添加 UTF-8 BOM 标记,确保 Excel 正确识别中文编码
  const utf8Bom = '\uFEFF';
  await File(
    path,
  ).writeAsString(utf8Bom + csvStr, encoding: Encoding.getByName('utf-8')!);

  onProgress(1);
  return (path: path, displayPath: '$displayDirPath/$fileName');
}
