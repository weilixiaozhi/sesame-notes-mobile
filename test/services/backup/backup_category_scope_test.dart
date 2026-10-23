import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

import '../../helpers/test_isolation.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _foreign = '10000000-0000-4000-8000-000000000002';
const _category = '20000000-0000-4000-8000-000000000001';
final _stamp = DateTime.utc(2026, 10, 11, 1, 2, 3, 980);

/// 真实导出仅过滤隔离快照，分类 SQL 空本地域不能作为其他账号数据删除。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late File dbFile;
  late SesameDatabase db;
  setUp(() async {
    resetGlobalTestState();
    temp = await createTestTempDirectory('backup_category_scope_');
    dbFile = File(p.join(temp.path, 'live.sqlite'));
    db = SesameDatabase.withExecutor(NativeDatabase(dbFile));
  });
  tearDown(() async {
    try {
      await db.close();
    } finally {
      if (await temp.exists()) await temp.delete(recursive: true);
    }
  });

  for (final account in [null, _account]) {
    test(
      '${account == null ? '匿名' : '登录'}备份保留本地类别及原UUID引用，排除foreign且live字节不变',
      () async {
        try {
          for (final (index, scope, name) in [
            (1, null, '本地餐饮'),
            (2, _account, '本人餐饮'),
            (3, _foreign, '他人餐饮'),
          ]) {
            final ledger =
                '30000000-0000-4000-8000-${index.toString().padLeft(12, '0')}';
            await db
                .into(db.categories)
                .insert(
                  CategoriesCompanion.insert(
                    id: _category,
                    name: name,
                    kind: 'expense',
                    level: 1,
                    scopeAccountId: d.Value(scope),
                    updatedAt: _stamp,
                  ),
                );
            await db
                .into(db.ledgers)
                .insert(
                  LedgersCompanion.insert(
                    id: ledger,
                    name: name,
                    storageMode: d.Value(scope == null ? 'local' : 'cloud'),
                    scopeAccountId: d.Value(scope),
                    ownerAccountId: d.Value(scope),
                    updatedAt: _stamp,
                  ),
                );
            await db
                .into(db.transactions)
                .insert(
                  TransactionsCompanion.insert(
                    id: '40000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
                    ledgerId: ledger,
                    txType: 'expense',
                    amount: '10',
                    nativeAmount: '10',
                    currencyCode: 'CNY',
                    categoryId: const d.Value(_category),
                    happenedAt: _stamp,
                    createdAt: _stamp,
                    updatedAt: _stamp,
                  ),
                );
            if (scope != null) {
              await db
                  .into(db.sharedLedgerCategories)
                  .insert(
                    SharedLedgerCategoriesCompanion.insert(
                      ledgerId: ledger,
                      categoryId: _category,
                      name: scope == _account ? '当前账本镜像' : '他人账本镜像',
                      kind: 'expense',
                      updatedAt: _stamp,
                    ),
                  );
            }
          }
          await db.customSelect('PRAGMA wal_checkpoint(TRUNCATE)').get();
          final originalBytes = await dbFile.readAsBytes();
          final originalCategories = await db.select(db.categories).get();
          final originalTransactions = await db.select(db.transactions).get();
          final originalMirrors = await db
              .select(db.sharedLedgerCategories)
              .get();
          final service = LocalBackupService(
            backupDir: Directory(p.join(temp.path, 'backups')),
            databaseFile: dbFile,
          );
          final backup = await service.createBackup(
            db: db,
            currentAccountId: account,
          );
          final framed = BackupPayloadCodec.decode(await backup.readAsBytes());
          final exported = File(p.join(temp.path, 'exported.sqlite'));
          await exported.writeAsBytes(framed.sqliteBytes);
          final snapshot = sqlite3.open(exported.path, mode: OpenMode.readOnly);
          try {
            final categories = snapshot.select(
              'SELECT id,name,scope_account_id FROM categories ORDER BY scope_account_id',
            );
            expect(
              categories.map((c) => c['scope_account_id']),
              account == null ? [''] : ['', _account],
            );
            expect(categories.first['id'], _category);
            expect(categories.first['name'], '本地餐饮');
            expect(categories.any((c) => c['name'] == '他人餐饮'), isFalse);
            final refs = snapshot.select(
              'SELECT category_id FROM transactions',
            );
            expect(refs.length, account == null ? 1 : 2);
            expect(refs.every((r) => r['category_id'] == _category), isTrue);
            final mirrors = snapshot.select(
              'SELECT name FROM shared_ledger_categories',
            );
            expect(
              mirrors.map((r) => r['name']),
              account == null ? <String>[] : ['当前账本镜像'],
            );
            expect(
              snapshot.select('PRAGMA integrity_check').single.values.single,
              'ok',
            );
          } finally {
            snapshot.close();
          }
          expect(await dbFile.readAsBytes(), originalBytes);
          expect(await db.select(db.categories).get(), originalCategories);
          expect(await db.select(db.transactions).get(), originalTransactions);
          expect(
            await db.select(db.sharedLedgerCategories).get(),
            originalMirrors,
          );
        } catch (error, stack) {
          stderr.writeln('分类目录备份回归失败：$error\n$stack');
          rethrow;
        }
      },
    );
  }
}
