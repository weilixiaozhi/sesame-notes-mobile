import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';

import '../helpers/test_isolation.dart';

/// 验证业务数据持久化后能够在当前数据库结构下完整重开。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() {
    resetGlobalTestState();
    tempDir = createTestTempDirectorySync('sesame_db_file_test');
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Windows 下句柄释放可能有延迟，忽略清理失败。
    }
  });

  late SesameDatabase db;

  /// 在独立测试目录打开磁盘数据库，并登记关闭操作。
  Future<SesameDatabase> openDb(String name) async {
    final file = File('${tempDir.path}${Platform.pathSeparator}$name');
    final opened = SesameDatabase.withExecutor(NativeDatabase(file));
    addTearDown(opened.close);
    return opened;
  }

  /// 写入账本、分类与支出，覆盖核心业务实体的持久化关系。
  Future<void> seedData(SesameDatabase d) async {
    await d
        .into(d.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'ledger-file-1',
            name: '真实文件账本',
            updatedAt: DateTime.utc(2026, 1, 1),
            storageMode: const Value('cloud'),
          ),
        );
    await d
        .into(d.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat-file-1',
            name: '餐饮',
            kind: 'expense',
            level: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    await d
        .into(d.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'tx-file-1',
            ledgerId: 'ledger-file-1',
            txType: 'expense',
            amount: '25.00',
            happenedAt: DateTime.utc(2026, 1, 1),
            currencyCode: 'CNY',
            nativeAmount: '25.00',
            createdAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
  }

  test('写入 → 关闭 → 重开：数据完整且使用当前 schema 建库', () async {
    db = await openDb('app.db');
    await seedData(db);
    // 显式关闭模拟进程退出
    await db.close();

    // 进程重启：重新打开同一文件
    db = await openDb('app.db');
    final ledgers = await (db.select(db.ledgers)).get();
    expect(ledgers, hasLength(1));
    expect(ledgers.first.name, '真实文件账本');
    expect(ledgers.first.id, 'ledger-file-1');

    final txs = await (db.select(db.transactions)).get();
    expect(txs, hasLength(1));
    expect(txs.first.amount, '25.00');
    expect(txs.first.id, 'tx-file-1');

    // 完整表结构直接作为当前版本建库。
    expect(db.schemaVersion, currentSchemaVersion);
    // 磁盘上的 user_version 与完整初始结构一致。
    final version = await db
        .customSelect('PRAGMA user_version', readsFrom: {db.ledgers})
        .getSingle();
    expect(version.data.values.first, currentSchemaVersion);
  });
}
