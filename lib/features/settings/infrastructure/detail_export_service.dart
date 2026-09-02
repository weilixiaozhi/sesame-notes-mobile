import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:sesame_notes/data/repositories/local/local_repository.dart';

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
  required LocalRepository repo,
  required String ledgerId,
  required DetailExportLabels labels,
  required String Function(String?) categoryLabel,
  DetailExportDateRange? dateRange,
  required void Function(double) onProgress,
  // 测试注入点：非空时直接写入指定目录。
  Directory? outputDirOverride,
}) async {
  final dir = outputDirOverride ?? await getTemporaryDirectory();
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
  final rows = <List<dynamic>>[];
  rows.add([
    labels.type,
    labels.category,
    labels.subCategory, // 二级分类名称
    labels.amount,
    labels.currency, // 多币种:交易原币种
    labels.note,
    labels.time,
  ]);

  // 缓存全部分类信息（主表 + 共享账本镜像），用于回填分类名与父分类名。
  // 共享账本 Editor 的交易只持有 Owner 分类 syncId，主表查不到这些分类；
  // 这里用一次性全量接口拿全，二级分类的「分类 / 二级分类」两列才能正确拆分。
  final allCategories = {
    for (final cat in await repo.getAllCategoriesIncludingShared()) cat.id: cat,
  };

  for (int i = 0; i < list.length; i++) {
    final txWithCat = list[i];
    final t = txWithCat.t;
    final c = txWithCat.category;

    // 完整时间格式:YYYY-MM-DD HH:mm:ss,前后补空格增加列宽
    final timeStr = () {
      try {
        final localTime = t.happenedAt.toLocal();
        return '  ${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} ${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}  ';
      } catch (e) {
        return '';
      }
    }();
    final typeStr = t.txType == 'expense' ? labels.expense : t.txType;

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

    // 币种列非空(交易原币种),金额为规范化 Decimal 字符串(元口径),
    // 导出时保留两位小数。
    final currencyStr = t.currencyCode.toUpperCase();
    rows.add([
      typeStr,
      categoryName,
      subCategoryName,
      double.parse(t.amount).toStringAsFixed(2),
      currencyStr,
      t.note ?? '',
      timeStr,
    ]);
    if (i % 50 == 0) {
      onProgress((i + 1) / (total == 0 ? 1 : total));
    }
  }

  // CsvEncoder 按 \n 行分隔符输出 CSV。
  final csvStr = const CsvEncoder(lineDelimiter: '\n').convert(rows);
  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final fileName = 'sesame_notes_$ts.csv';
  final path = p.join(directory, fileName);

  // 添加 UTF-8 BOM 标记,确保 Excel 正确识别中文编码
  const utf8Bom = '\uFEFF';
  await File(
    path,
  ).writeAsString(utf8Bom + csvStr, encoding: Encoding.getByName('utf-8')!);

  onProgress(1);
  return (path: path, displayPath: '$displayDirPath/$fileName');
}
