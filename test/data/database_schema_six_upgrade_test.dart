import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../helpers/schema_six_database_fixture.dart';
import '../helpers/test_isolation.dart';

/// 保留底层连接以便在 Drift 关闭后逐项检查事务提交或回滚结果。
SesameDatabase _database(sql.Database raw) => SesameDatabase.withExecutor(
  NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
);

/// 完整比较业务和同步行，仅允许明确声明的单位转换与水位重建。
void _expectUpgradedRows(
  sql.Database raw,
  Map<String, List<Map<String, Object?>>> before,
) {
  try {
    expect(schemaSixRows(raw), expectedSchemaSixRows(before));
    expect(
      raw.select('PRAGMA user_version').single.values.single,
      currentSchemaVersion,
    );
    expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
    expect(raw.select('PRAGMA quick_check').single.values.single, 'ok');
    expect(raw.select('PRAGMA foreign_keys').single.values.single, 1);
    expect(
      raw.select('SELECT amount FROM transactions').single['amount'],
      schemaSixAmount,
    );
    expect(
      raw.select('SELECT rate FROM exchange_rate_overrides').single['rate'],
      '7.123456789123456789',
    );
    expect(
      raw
          .select(
            "SELECT frozen_request FROM sync_changes WHERE entity_id='transaction'",
          )
          .single['frozen_request'],
      schemaSixFrozen,
    );
    expect(
      raw
          .select(
            "SELECT frozen_request FROM sync_changes WHERE entity_id='unknown'",
          )
          .single['frozen_request'],
      '{ 未确认冻结原字节',
    );
  } catch (error, stack) {
    logger.error('SchemaSixUpgradeTest', '升级后原始数据校验失败', error, stack);
    rethrow;
  }
}

/// 首次打开、重复打开及失败回滚均通过真实数据库连接验证。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUp(() async {
    resetGlobalTestState();
    directory = await createTestTempDirectory('schema-six-upgrade-');
  });
  tearDown(() async {
    try {
      final root = p.normalize(Directory('Temp').absolute.path);
      final target = p.normalize(directory.absolute.path);
      if (!p.isWithin(root, target)) {
        throw StateError('测试清理路径不在项目 Temp 内');
      }
      await directory.delete(recursive: true);
    } catch (error, stack) {
      logger.error('SchemaSixUpgradeTest', '清理测试独占目录失败', error, stack);
      rethrow;
    }
  });

  test('结构6原始SQL首次打开升级，四业务域及全部同步证据逐字段保留', () async {
    final file = File(p.join(directory.path, 'source.sqlite'));
    await createSchemaSixDatabaseFixture(file);
    final raw = sql.sqlite3.open(file.path);
    final before = schemaSixRows(raw);
    final db = _database(raw);
    try {
      // 夹具确实包含不同的列、空值约束和秒单位，不能用改版本号代替来源结构。
      expect(raw.select('PRAGMA user_version').single.values.single, 6);
      expect(
        raw.select('PRAGMA table_info(transactions)').map((row) => row['name']),
        contains('exclude_from_stats'),
      );
      final cursor = raw
          .select('PRAGMA table_info(sync_state)')
          .singleWhere((row) => row['name'] == 'server_cursor');
      expect(cursor['notnull'], 1);
      expect(cursor['dflt_value'], "'0'");
      expect(
        raw
            .select('SELECT updated_at FROM ledgers ORDER BY id')
            .first['updated_at'],
        lessThan(100000000000),
      );

      await db.customSelect('SELECT 1').get();
      _expectUpgradedRows(raw, before);
      expect(
        (await db.select(db.ledgerMembers).get()).map(
          (member) => member.updatedAt.millisecondsSinceEpoch,
        ),
        everyElement(schemaSixSeconds * 1000),
      );
      expect(
        (await db.select(db.transactions).getSingle()).amount,
        schemaSixAmount,
      );
      expect((await db.select(db.dayEvents).getSingle()).name, '保留生日');
      expect((await db.select(db.memoEntries).getSingle()).title, '保留标题');
      expect(
        (await db.select(db.fitnessEntities).getSingle()).payload,
        '{ "name":"保留训练", "sets":[{"weight":"12.3400"}], "extra":true }',
      );
    } catch (error, stack) {
      logger.error('SchemaSixUpgradeTest', '结构6首次打开验证失败', error, stack);
      rethrow;
    } finally {
      await db.close();
      raw.close();
    }
  });

  test('后台数据库连接完成升级后重复打开不再换算时间或重置有效水位', () async {
    final file = File(p.join(directory.path, 'background.sqlite'));
    await createSchemaSixDatabaseFixture(file);
    String? committed;
    for (var attempt = 0; attempt < 3; attempt++) {
      final db = SesameDatabase.withExecutor(
        NativeDatabase.createInBackground(file),
      );
      try {
        await db.customSelect('SELECT 1').get();
        expect(
          (await db.select(db.ledgers).get()).map(
            (ledger) => ledger.updatedAt.millisecondsSinceEpoch,
          ),
          contains(schemaSixSeconds * 1000),
        );
      } catch (error, stack) {
        logger.error('SchemaSixUpgradeTest', '后台连接升级验证失败', error, stack);
        rethrow;
      } finally {
        await db.close();
      }
      final raw = sql.sqlite3.open(file.path);
      try {
        if (attempt == 0) {
          // 模拟完成完整同步后的新水位；下次启动必须保留该值。
          raw.execute(
            'UPDATE sync_state SET server_cursor=?,day_events_cursor=?,memos_cursor=?,fitness_cursor=?',
            ['900719925474099312346', '0', '125', '1001'],
          );
          committed = schemaSixSnapshot(raw);
        } else {
          expect(schemaSixSnapshot(raw), committed);
        }
      } finally {
        raw.close();
      }
    }
  });

  for (final (label, mutate) in <(String, void Function(sql.Database))>[
    (
      '未知附加列',
      (raw) => raw.execute(
        'ALTER TABLE sync_changes ADD COLUMN unsupported_column TEXT',
      ),
    ),
    ('缺失业务表', (raw) => raw.execute('DROP TABLE backup_state')),
    ('未知附加表', (raw) => raw.execute('CREATE TABLE unexpected_table(id TEXT)')),
    (
      '列类型伪装',
      (raw) {
        raw.execute('ALTER TABLE sync_state RENAME TO malformed_state');
        raw.execute(
          'CREATE TABLE sync_state(account_id TEXT NOT NULL DEFAULT \'\','
          'device_id TEXT NOT NULL,server_cursor INTEGER NOT NULL DEFAULT 0,'
          'day_events_cursor TEXT,memos_cursor TEXT,fitness_cursor TEXT,'
          'last_push_at INTEGER,last_pull_at INTEGER,PRIMARY KEY(account_id,device_id))',
        );
        raw.execute('INSERT INTO sync_state SELECT * FROM malformed_state');
        raw.execute('DROP TABLE malformed_state');
      },
    ),
    (
      '悬空外键',
      (raw) => raw.execute(
        'INSERT INTO transaction_splits(transaction_id,member_id,amount) '
        "VALUES('missing-transaction','missing-member','1')",
      ),
    ),
  ]) {
    test('$label拒绝升级，全部结构、版本号和行数据保持原值', () async {
      final file = File(p.join(directory.path, 'invalid.sqlite'));
      await createSchemaSixDatabaseFixture(file);
      final raw = sql.sqlite3.open(file.path);
      try {
        mutate(raw);
        final before = schemaSixSnapshot(raw);
        final db = _database(raw);
        try {
          await expectLater(
            db.customSelect('SELECT 1').get(),
            throwsStateError,
          );
          expect(schemaSixSnapshot(raw), before);
        } finally {
          await db.close();
        }
      } catch (error, stack) {
        logger.error(
          'SchemaSixUpgradeTest',
          '无损拒绝结构6验证失败：$label',
          error,
          stack,
        );
        rethrow;
      } finally {
        raw.close();
      }
    });
  }

  for (final column in ['ledgers', 'ledger_members']) {
    for (final invalid in <Object>[
      253402300800,
      -62135596801,
      schemaSixMilliseconds,
      1000.5,
      'invalid-time',
    ]) {
      test('$column秒时间$invalid无效时完整回滚，冻结请求不变', () async {
        final file = File(p.join(directory.path, 'invalid-time.sqlite'));
        await createSchemaSixDatabaseFixture(file);
        final raw = sql.sqlite3.open(file.path);
        try {
          raw.execute('UPDATE $column SET updated_at=?', [invalid]);
          final before = schemaSixSnapshot(raw);
          final db = _database(raw);
          try {
            await expectLater(
              db.customSelect('SELECT 1').get(),
              throwsStateError,
            );
            expect(schemaSixSnapshot(raw), before);
          } finally {
            await db.close();
          }
        } catch (error, stack) {
          logger.error('SchemaSixUpgradeTest', '无效秒值回滚验证失败', error, stack);
          rethrow;
        } finally {
          raw.close();
        }
      });
    }
  }

  test('已执行结构修改和前序换算后SQL失败，所有修改及版本号一起回滚', () async {
    final file = File(p.join(directory.path, 'injected-failure.sqlite'));
    await createSchemaSixDatabaseFixture(file);
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute(
        'CREATE TRIGGER reject_member_conversion BEFORE UPDATE OF updated_at '
        "ON ledger_members BEGIN SELECT RAISE(ABORT,'SCHEMA6_TEST_STOP'); END",
      );
      final before = schemaSixSnapshot(raw);
      final db = _database(raw);
      try {
        await expectLater(
          db.customSelect('SELECT 1').get(),
          throwsA(
            isA<sql.SqliteException>().having(
              (error) => error.message,
              'SQL失败位置',
              contains('SCHEMA6_TEST_STOP'),
            ),
          ),
        );
        expect(schemaSixSnapshot(raw), before);
      } finally {
        await db.close();
      }
    } catch (error, stack) {
      logger.error('SchemaSixUpgradeTest', '中途SQL失败回滚验证失败', error, stack);
      rethrow;
    } finally {
      raw.close();
    }
  });

  test('当前结构伪装为版本6不会执行时间换算，原数据保持不变', () async {
    final raw = sql.sqlite3.openInMemory();
    final current = _database(raw);
    try {
      await current.customSelect('SELECT 1').get();
    } finally {
      await current.close();
    }
    raw.execute(
      "INSERT INTO ledgers(id,name,updated_at) VALUES('current','当前账本',?)",
      [schemaSixMilliseconds],
    );
    raw.execute('PRAGMA user_version=6');
    final before = schemaSixSnapshot(raw);
    final db = _database(raw);
    try {
      await expectLater(db.customSelect('SELECT 1').get(), throwsStateError);
      expect(schemaSixSnapshot(raw), before);
    } catch (error, stack) {
      logger.error('SchemaSixUpgradeTest', '伪装版本6拒绝验证失败', error, stack);
      rethrow;
    } finally {
      await db.close();
      raw.close();
    }
  });
}
