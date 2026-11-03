import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../helpers/schema_ten_database_fixture.dart';
import '../helpers/test_isolation.dart';

/// 持有底层连接，以完整检查提交结果和失败后的原始数据库。
SesameDatabase _database(sql.Database raw) => SesameDatabase.withExecutor(
  NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
);

/// 记录保留表的索引、触发器和外键关系，不把物理根页位置当作业务身份。
String _preservedObjects(sql.Database raw) => jsonEncode({
  'objects': [
    for (final row in raw.select(
      "SELECT type,name,tbl_name,sql FROM sqlite_master WHERE type IN ('index','trigger') ORDER BY type,name",
    ))
      Map<String, Object?>.from(row),
  ],
  'foreign_keys': {
    for (final row in raw.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name!='recovery_logs' ORDER BY name",
    ))
      row['name'] as String: [
        for (final foreignKey in raw.select(
          'PRAGMA foreign_key_list("${row['name']}")',
        ))
          Map<String, Object?>.from(foreignKey),
      ],
  },
});

/// 通过真实文件、后台连接、WAL 和失败回滚验证结构变更的数据边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUp(() async {
    resetGlobalTestState();
    directory = await createTestTempDirectory('schema-eleven-upgrade-');
  });
  tearDown(() async {
    try {
      if (!p.isWithin(
        p.normalize(Directory('Temp').absolute.path),
        p.normalize(directory.absolute.path),
      )) {
        throw StateError('测试目录不在项目 Temp 内');
      }
      await directory.delete(recursive: true);
    } catch (error, stack) {
      logger.error('SchemaElevenTest', '清理测试独占目录失败', error, stack);
      rethrow;
    }
  });

  test('真实结构10只删除五列和停用表，所有剩余行及索引外键原样保留', () async {
    final file = File(p.join(directory.path, 'source.sqlite'));
    await createSchemaTenDatabaseFixture(file);
    final raw = sql.sqlite3.open(file.path);
    final db = _database(raw);
    try {
      final before = schemaTenRows(raw);
      final objects = _preservedObjects(raw);
      expect(
        before['ledgers']!.every((row) => row['origin_last_revision'] == 7),
        isTrue,
      );
      expect(
        before['sync_state']!.every(
          (row) => row['last_push_at'] != null && row['last_pull_at'] != null,
        ),
        isTrue,
      );
      expect(
        before['sync_pull_errors']!.single['user_action'],
        'retry_requested',
      );
      expect(before['sync_pull_errors']!.single['error_message'], '保留拉取错误');
      expect(before['recovery_logs'], isNotEmpty);

      await db.customSelect('SELECT 1').get();

      expect(raw.userVersion, 11);
      expect(schemaTenRows(raw), expectedSchemaTenRows(before));
      expect(_preservedObjects(raw), objects);
      expect(raw.select('PRAGMA foreign_keys').single.values.single, 1);
      expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
      expect(raw.select('PRAGMA quick_check').single.values.single, 'ok');
      expect(
        (await db.select(db.transactions).getSingle()).amount,
        schemaTenAmount,
      );
      expect((await db.select(db.dayEvents).getSingle()).name, '保留生日');
      expect((await db.select(db.memoEntries).getSingle()).title, '保留标题');
      expect(
        (await db.select(db.fitnessEntities).getSingle()).payload,
        contains('保留训练'),
      );
      expect(
        (await db.select(db.syncChanges).get())
            .singleWhere((row) => row.entityId == 'transaction')
            .frozenRequest,
        schemaTenFrozen,
      );
    } catch (error, stack) {
      logger.error('SchemaElevenTest', '完整结构清理数据保留验证失败', error, stack);
      rethrow;
    } finally {
      await db.close();
      raw.close();
    }
  });

  test('后台连接读取已提交未落盘WAL，升级后重复打开不改写业务或四域水位', () async {
    final file = File(p.join(directory.path, 'wal.sqlite'));
    await createSchemaTenDatabaseFixture(file);
    final raw = sql.sqlite3.open(file.path);
    try {
      expect(raw.select('PRAGMA journal_mode=WAL').single.values.single, 'wal');
      raw.execute('PRAGMA wal_autocheckpoint=0');
      final mainBytes = await file.readAsBytes();
      raw.execute("UPDATE transactions SET amount='9876543210.123456789'");
      raw.execute(
        'UPDATE sync_changes SET frozen_request=? WHERE entity_id=?',
        ['{ WAL未确认冻结原文\n', 'unknown'],
      );
      expect(await File('${file.path}-wal').length(), greaterThan(0));
      expect(await file.readAsBytes(), mainBytes);
      final before = schemaTenRows(raw);
      String? committed;
      for (var attempt = 0; attempt < 3; attempt++) {
        final db = SesameDatabase.withExecutor(
          NativeDatabase.createInBackground(file),
        );
        try {
          await db.customSelect('SELECT 1').get();
          expect(schemaTenRows(raw), expectedSchemaTenRows(before));
          final snapshot = schemaTenSnapshot(raw);
          if (committed != null) expect(snapshot, committed);
          committed = snapshot;
        } finally {
          await db.close();
        }
      }
    } catch (error, stack) {
      logger.error('SchemaElevenTest', 'WAL与重复启动保留验证失败', error, stack);
      rethrow;
    } finally {
      raw.close();
    }
  });

  test('最后删列被额外索引阻止时，已执行的前四次删列也完整回滚', () async {
    final file = File(p.join(directory.path, 'rollback.sqlite'));
    await createSchemaTenDatabaseFixture(file);
    final raw = sql.sqlite3.open(file.path);
    final db = _database(raw);
    try {
      raw.execute(
        'CREATE INDEX keep_error_message ON sync_pull_errors(error_message)',
      );
      final before = schemaTenSnapshot(raw);
      await expectLater(
        db.customSelect('SELECT 1').get(),
        throwsA(
          predicate<Object>(
            (error) => error.toString().contains('keep_error_message'),
          ),
        ),
      );
      expect(schemaTenSnapshot(raw), before);
    } catch (error, stack) {
      logger.error('SchemaElevenTest', '中途删列失败回滚验证失败', error, stack);
      rethrow;
    } finally {
      await db.close();
      raw.close();
    }
  });

  for (final (name, statement) in <(String, String)>[
    ('缺少预期列', 'ALTER TABLE ledgers DROP COLUMN origin_last_revision'),
    ('业务额外列', 'ALTER TABLE ledgers ADD COLUMN unknown_value TEXT'),
    ('未知表', 'CREATE TABLE external_records(id TEXT PRIMARY KEY)'),
    ('缺少待删表', 'DROP TABLE recovery_logs'),
    ('待删表未知列', 'ALTER TABLE recovery_logs ADD COLUMN unknown_value TEXT'),
    ('依赖待删表的视图', 'CREATE VIEW recovery_view AS SELECT * FROM recovery_logs'),
    ('外键悬空', "UPDATE transaction_splits SET transaction_id='missing'"),
    ('来源版本6', 'PRAGMA user_version=6'),
    ('来源版本9', 'PRAGMA user_version=9'),
    ('未来版本', 'PRAGMA user_version=12'),
  ]) {
    test('$name拒绝打开并完整保留原结构和数据', () async {
      final file = File(p.join(directory.path, 'invalid.sqlite'));
      await createSchemaTenDatabaseFixture(file);
      final raw = sql.sqlite3.open(file.path);
      final db = _database(raw);
      try {
        raw.execute(statement);
        final before = schemaTenSnapshot(raw);
        await expectLater(
          db.customSelect('SELECT 1').get(),
          throwsA(isA<StateError>()),
        );
        expect(schemaTenSnapshot(raw), before);
      } catch (error, stack) {
        logger.error('SchemaElevenTest', '无损拒绝验证失败：$name', error, stack);
        rethrow;
      } finally {
        await db.close();
        raw.close();
      }
    });
  }
}
