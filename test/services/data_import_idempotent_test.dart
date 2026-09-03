library;

/// P1 幂等测试：importTransactions 按交易 UUID 主键去重，重复导入不会产生重复行。
///
/// 云端全量恢复时同一份数据按幂等键去重，不重复 INSERT；
/// 导致每次下拉刷新数据翻倍。
/// 修复后：导入前预取目标账本已有交易 id（UUID）集合，命中即跳过
/// （跨批次 / 本批次内）。备份/恢复携带 syncId 时以它作为交易 id。

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:decimal/decimal.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late DataImportService service;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    service = DataImportService();
  });

  tearDown(() async => db.close());

  Future<void> seedLedger(int id) async {
    await db.customStatement(
      "INSERT INTO ledgers (id, name, currency, updated_at) "
      "VALUES ($id, 'L$id', 'CNY', strftime('%s','now'))",
    );
  }

  Future<int> countInLedger(String ledgerId) async => (await (db.select(
    db.transactions,
  )..where((t) => t.ledgerId.equals(ledgerId))).get()).length;

  ImportTransaction makeTx(String syncId, {Decimal? amount}) =>
      ImportTransaction(
        type: 'expense',
        amount: amount ?? Decimal.parse('10'),
        happenedAt: DateTime(2026, 7, 1),
        syncId: syncId,
      );

  group('P1 按 syncId 幂等', () {
    test('跨批次重复 syncId 不重复插入', () async {
      await seedLedger(1);
      // 首批：2 条新交易
      final r1 = await service.importTransactions(repo, '1', [
        makeTx('tx-A'),
        makeTx('tx-B'),
      ], categoryCache: {});
      expect(r1.inserted, 2);

      // 第二批：tx-A 已存在（应跳过），tx-C 为新（应插入）
      final r2 = await service.importTransactions(repo, '1', [
        makeTx('tx-A'),
        makeTx('tx-C'),
      ], categoryCache: {});
      expect(r2.inserted, 1, reason: '已存在的 tx-A 应被去重跳过');

      // 最终本地只有 3 条，不会翻倍
      expect(await countInLedger('1'), 3);
      // 新 schema 无 syncId 列：去重键即交易 UUID 主键（导入时以 syncId 作为 id）。
      final ids = (await db.select(db.transactions).get())
          .map((t) => t.id)
          .toList();
      expect(ids.where((s) => s == 'tx-A').length, 1, reason: 'tx-A 只能出现一次');
    });

    test('本批次内重复 syncId 只插一条', () async {
      await seedLedger(2);
      final r = await service.importTransactions(repo, '2', [
        makeTx('dup-x'),
        makeTx('dup-x'),
        makeTx('dup-x'),
      ], categoryCache: {});
      expect(r.inserted, 1, reason: '同批次同 syncId 只应插入一条');
      expect(await countInLedger('2'), 1);
    });

    test('无 syncId 的 CSV 记录不被误杀', () async {
      await seedLedger(3);
      final r = await service.importTransactions(repo, '3', [
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('10.0'),
          happenedAt: DateTime(2026, 7, 1),
          syncId: null,
        ),
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('20.0'),
          happenedAt: DateTime(2026, 7, 2),
          syncId: null,
        ),
      ], categoryCache: {});
      expect(r.inserted, 2, reason: '无 syncId 的记录应正常插入，不做去重');
      expect(await countInLedger('3'), 2);
    });

    test('多账本隔离：A 账本已存在的 syncId 在 B 账本仍应插入', () async {
      await seedLedger(1);
      await seedLedger(4);
      // ledger1 已有 tx-X
      await service.importTransactions(repo, '1', [
        makeTx('tx-X'),
      ], categoryCache: {});
      // 向 ledger4 导入不同 syncId —— existingSyncIds 按 ledger 预取,
      // ledger1 的存在不影响 ledger4 的导入。
      final r = await service.importTransactions(repo, '4', [
        makeTx('tx-Y'),
      ], categoryCache: {});
      expect(r.inserted, 1);
      expect(await countInLedger('4'), 1);
    });
  });

  group('CSV 重复导入去重', () {
    /// 同一逻辑文件（解析后 rows 的稳定哈希）+ 行号 → 确定性幂等键。
    List<ImportTransaction> csvTx(String ledgerId, String fileHash) => [
      for (final (i, amount) in ['12.5', '20.0'].indexed)
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse(amount),
          happenedAt: DateTime(2026, 7, i + 1),
          syncId: csvImportSyncId(
            targetLedgerId: ledgerId,
            fileHash: fileHash,
            rowIndex: i + 1,
          ),
        ),
    ];

    test('同一账本连续导入同一 CSV：第二次全部按幂等键跳过', () async {
      await seedLedger(1);
      const hash = 'file-hash-a';
      final r1 = await service.importTransactions(
        repo,
        '1',
        csvTx('1', hash),
        categoryCache: {},
      );
      expect(r1.inserted, 2);
      expect(r1.duplicateSkipped, 0);

      final r2 = await service.importTransactions(
        repo,
        '1',
        csvTx('1', hash),
        categoryCache: {},
      );
      expect(r2.inserted, 0, reason: '第二次不再次插入');
      expect(r2.duplicateSkipped, 2, reason: '重复行单独计数，不计成功/失败');
      expect(await countInLedger('1'), 2, reason: '本地不产生重复账单');
    });

    test('同一文件内两条完全相同行派生不同 UUID，首次均可导入', () async {
      await seedLedger(2);
      const hash = 'file-hash-b';
      final r = await service.importTransactions(
        repo,
        '2',
        csvTx('2', hash),
        categoryCache: {},
      );
      expect(r.inserted, 2);
      expect(await countInLedger('2'), 2);
    });

    test('不同账本导入同一文件互不影响', () async {
      await seedLedger(1);
      await seedLedger(5);
      const hash = 'file-hash-c';
      await service.importTransactions(
        repo,
        '1',
        csvTx('1', hash),
        categoryCache: {},
      );
      final r = await service.importTransactions(
        repo,
        '5',
        csvTx('5', hash),
        categoryCache: {},
      );
      expect(r.inserted, 2, reason: '账本 5 不受账本 1 已有数据影响');
      expect(await countInLedger('5'), 2);
    });

    test('失败行不占用幂等键，修复分类后可再次尝试', () async {
      await seedLedger(6);
      const hash = 'file-hash-d';
      final bad = ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('18'),
        happenedAt: DateTime(2026, 7, 1),
        categoryName: '餐饮',
        categoryKind: 'expense',
        syncId: csvImportSyncId(
          targetLedgerId: '6',
          fileHash: hash,
          rowIndex: 1,
        ),
      );
      // 分类未命中 → 该行失败，且不能占用幂等键。
      final r1 = await service.importTransactions(repo, '6', [
        bad,
      ], categoryCache: {});
      expect(r1.inserted, 0);
      expect(r1.failed, 1);
      expect(await countInLedger('6'), 0);

      // 修复分类映射后重试同一行：能再次导入（不被当作重复）。
      final r2 = await service.importTransactions(
        repo,
        '6',
        [bad],
        categoryCache: {
          (kind: 'expense', parentName: null, name: '餐饮'): 'cat-food',
        },
      );
      expect(r2.inserted, 1, reason: '失败行修复后必须可重试');
      expect(r2.duplicateSkipped, 0);
      expect(await countInLedger('6'), 1);
    });
  });

  group('csvImportSyncId 派生', () {
    test('同参数恒定产出同一 ID（确定性）', () {
      final a = csvImportSyncId(
        targetLedgerId: 'ledger-1',
        fileHash: 'h1',
        rowIndex: 3,
      );
      final b = csvImportSyncId(
        targetLedgerId: 'ledger-1',
        fileHash: 'h1',
        rowIndex: 3,
      );
      expect(a, b);
      expect(a, isA<String>());
      expect(a.length, 36, reason: 'UUID 标准格式');
    });

    test('行号参与派生：同文件不同行产出不同 ID', () {
      final a = csvImportSyncId(
        targetLedgerId: 'ledger-1',
        fileHash: 'h1',
        rowIndex: 1,
      );
      final b = csvImportSyncId(
        targetLedgerId: 'ledger-1',
        fileHash: 'h1',
        rowIndex: 2,
      );
      expect(a, isNot(equals(b)));
    });

    test('目标账本参与派生：跨账本不同 ID', () {
      final a = csvImportSyncId(
        targetLedgerId: 'ledger-1',
        fileHash: 'h1',
        rowIndex: 1,
      );
      final b = csvImportSyncId(
        targetLedgerId: 'ledger-2',
        fileHash: 'h1',
        rowIndex: 1,
      );
      expect(a, isNot(equals(b)));
    });
  });
}
