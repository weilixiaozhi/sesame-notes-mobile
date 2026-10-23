import 'dart:convert';

import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/fitness/fitness_custom_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/features/settings/infrastructure/fitness_table_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';

/// 为格式往返测试组装完整健身文档，生产导入由 TransferActions 分步编排。
FitnessTransferDocument decodeFitnessTransfer(List<int> bytes) {
  if (bytes.length > FitnessTransferFormat.maxFileBytes) {
    throw const FormatException('健身文件过大');
  }
  final table = TransferTable.parse(utf8.decode(bytes), TransferKind.fitness);
  final mapping = table.detect(TransferKind.fitness);
  final rows = [
    for (var i = 0; i < table.records.length; i++)
      table.mapped(i, TransferKind.fitness, mapping),
  ];
  final id = transferId(rows), now = DateTime.now().toUtc();
  final spaceId = transferId([id, 'book']);
  final catalog = [
    for (final row in rows)
      if (row['preferences'] is Map)
        ...transferCustomCatalog(
          Map<String, dynamic>.from(row['preferences'] as Map),
        ),
  ];
  final converter = FitnessTableConverter(catalog, {}, now, spaceId);
  final records = [
    for (var i = 0; i < rows.length; i++)
      converter.convert([rows[i]], transferId([id, i])),
  ];
  FitnessTransferFormat.validateRecords(records);
  return FitnessTransferDocument(
    id,
    now,
    records,
    space: FitnessSpace(
      id: spaceId,
      name: '导入数据',
      createdAt: now,
      updatedAt: now,
    ),
  );
}
