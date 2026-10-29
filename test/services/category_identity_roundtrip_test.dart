import 'dart:io';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/detail_export_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/ledger_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';

/// 完整文件往返必须保留同父同名分类的独立身份和交易归属。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('同父同名不同图标导出再导入不吞并，重试不增加分类或账单', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = LocalRepository(db);
    final tempRoot = Directory('Temp').absolute..createSync(recursive: true);
    final directory = tempRoot.createTempSync('category-roundtrip-');
    addTearDown(() async {
      await db.close();
      if (directory.absolute.path.startsWith(
        '${tempRoot.path}${Platform.pathSeparator}',
      )) {
        await directory.delete(recursive: true);
      }
    });
    final now = DateTime.utc(2026, 10, 29);
    for (final id in ['source', 'target']) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: id,
              name: id,
              storageMode: const d.Value('local'),
              updatedAt: now,
            ),
          );
    }
    const parent = '00000000-0000-4000-8000-000000000301';
    const first = '00000000-0000-4000-8000-000000000302';
    const second = '00000000-0000-4000-8000-000000000303';
    await repo.createCategoryBatch(
      items: const [
        CategoryCreateDraft(id: parent, name: '餐饮', icon: 'utensils'),
        CategoryCreateDraft(
          id: first,
          name: '午餐',
          parentId: parent,
          icon: 'coffee',
        ),
        CategoryCreateDraft(
          id: second,
          name: '午餐',
          parentId: parent,
          icon: 'soup',
        ),
      ],
      ledgerId: 'source',
    );
    for (final entry in {first: '10', second: '20'}.entries) {
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'transaction-${entry.key}',
              ledgerId: 'source',
              txType: 'expense',
              amount: entry.value,
              categoryId: d.Value(entry.key),
              happenedAt: now,
              currencyCode: 'CNY',
              nativeAmount: entry.value,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    final exported = await exportDetailCsv(
      repo: repo,
      categoryQueries: repo.categoryStore,
      ledgerId: 'source',
      labels: (
        type: '类型',
        category: '分类',
        subCategory: '二级分类',
        amount: '金额',
        currency: '币种',
        note: '备注',
        time: '时间',
        expense: '支出',
      ),
      categoryLabel: (name) => name ?? '',
      onProgress: (_) {},
      business: '记账',
      ledgerName: '来源',
      outputDirectory: directory,
    );
    final table = TransferTable.parse(
      await File(exported.path).readAsString(),
      TransferKind.ledger,
    );
    final detection = table.detect(TransferKind.ledger);
    final mapped = [
      for (var i = 0; i < table.records.length; i++)
        table.mapped(i, TransferKind.ledger, detection, {}),
    ];
    final hash = ledgerCategoryFileHash(mapped);
    final keys = transferFields[TransferKind.ledger]!
        .map((f) => f.key)
        .toList();
    final sources = [
      for (var i = 0; i < mapped.length; i++)
        ledgerImportCategorySource(mapped[i], fileHash: hash, rowIndex: i)!,
    ];
    expect(sources.map((s) => s.sourceId).toSet(), {first, second});
    final data = buildLedgerImportData(
      rows: [
        for (final row in mapped)
          keys.map((key) => row[key]?.toString() ?? '').toList(),
      ],
      dataStart: 0,
      targetLedgerId: 'target',
      mapping: {for (var i = 0; i < keys.length; i++) keys[i]: i},
      categoryMapping: {
        for (final source in sources) source: importCreateCategory,
      },
      requireExplicitMapping: true,
      categorySourceHash: hash,
      skippedTypes: {},
      badRows: {},
    );
    final service = DataImportService();
    final imported = await service.importData(
      repo,
      'target',
      data,
      categoryQueries: repo.categoryStore,
    );
    expect(imported.inserted, 2);
    expect(imported.failed, 0);
    final targetRows = await repo.transactionsWithCategoryAll(
      ledgerId: 'target',
    );
    expect(targetRows.map((row) => row.category!.id).toSet(), hasLength(2));
    expect(
      {for (final row in targetRows) row.t.amount: row.category!.icon},
      {'10': 'coffee', '20': 'soup'},
    );
    expect(
      targetRows.map((row) => row.category!.parentId).toSet(),
      hasLength(1),
    );
    expect(await repo.categoryStore.getAllCategories(), hasLength(6));
    final retried = await service.importData(
      repo,
      'target',
      data,
      categoryQueries: repo.categoryStore,
    );
    expect(retried.duplicateSkipped, 2);
    expect(retried.inserted, 0);
    expect(await repo.categoryStore.getAllCategories(), hasLength(6));
    expect(
      (await repo.transactionsWithCategoryAll(
        ledgerId: 'source',
      )).map((row) => row.category!.id).toSet(),
      {first, second},
    );
  });
}
