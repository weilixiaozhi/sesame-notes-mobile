import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../helpers/schema_six_database_fixture.dart';
import '../helpers/test_isolation.dart';

/// 后台连接必须消费原库已提交的 WAL，不能只读取主文件中的较早记录。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('结构6的未落盘WAL记录随后台升级完整保留', () async {
    final directory = await createTestTempDirectory('schema-six-wal-');
    sql.Database? raw;
    SesameDatabase? db;
    try {
      final file = File(p.join(directory.path, 'source.sqlite'));
      await createSchemaSixDatabaseFixture(file);
      raw = sql.sqlite3.open(file.path);
      expect(raw.select('PRAGMA journal_mode=WAL').single.values.single, 'wal');
      raw.execute('PRAGMA wal_autocheckpoint=0');
      final mainFileBeforeWrite = await file.readAsBytes();

      // 保持来源连接存活，让已提交的新金额及冻结请求仅存在于 WAL 中。
      raw.execute('BEGIN');
      try {
        raw.execute("UPDATE transactions SET amount='9876543210.123456789'");
        raw.execute(
          'UPDATE sync_changes SET frozen_request=? WHERE entity_id=?',
          ['{ WAL中的未确认冻结原字节\n', 'unknown'],
        );
        raw.execute('COMMIT');
      } catch (_) {
        raw.execute('ROLLBACK');
        rethrow;
      }
      expect(await File('${file.path}-wal').length(), greaterThan(0));
      expect(await file.readAsBytes(), mainFileBeforeWrite);
      final before = schemaSixRows(raw);

      db = SesameDatabase.withExecutor(NativeDatabase.createInBackground(file));
      await db.customSelect('SELECT 1').get();

      expect(schemaSixRows(raw), expectedSchemaSixRows(before));
      expect(raw.select('PRAGMA user_version').single.values.single, 10);
      expect(raw.select('PRAGMA quick_check').single.values.single, 'ok');
      expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
    } catch (error, stack) {
      logger.error('SchemaSixWalTest', 'WAL原始记录升级验证失败', error, stack);
      rethrow;
    } finally {
      try {
        await db?.close();
      } finally {
        raw?.close();
        final root = p.normalize(Directory('Temp').absolute.path);
        final target = p.normalize(directory.absolute.path);
        if (!p.isWithin(root, target)) {
          throw StateError('测试清理路径不在项目 Temp 内');
        }
        await directory.delete(recursive: true);
      }
    }
  });
}
