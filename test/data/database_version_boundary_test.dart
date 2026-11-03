import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart';

import '../helpers/test_isolation.dart';

const _stamp = 1792371723947;

/// 创建含业务、暂存元数据、水位和未确认冻结请求的当前库，保留连接供再次打开。
Future<void> _seedCurrentDatabase(Database raw) async {
  final db = SesameDatabase.withExecutor(
    NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
  );
  try {
    await db.customSelect('SELECT 1').get();
    raw.execute(
      'INSERT INTO ledgers(id,name,updated_at) '
      "VALUES('ledger','当前账本',?)",
      [_stamp],
    );
    raw.execute(
      'INSERT INTO ledger_members(id,ledger_id,display_name,member_type,updated_at) '
      "VALUES('member','ledger','成员','PLACEHOLDER',?)",
      [_stamp],
    );
    raw.execute(
      'INSERT INTO sync_state(account_id,device_id,server_cursor,day_events_cursor,memos_cursor,fitness_cursor) '
      "VALUES('account','device','0','123',NULL,'900719925474099312345')",
    );
    raw.execute(
      'INSERT INTO sync_changes(entity_type,entity_id,action,payload,updated_at,mutation_id,frozen_request,account_id) '
      "VALUES('category','category','upsert',?,?,'mutation',?,'account')",
      ['{ "name": "保留正文", "level": 1 }\n', _stamp, '{ 未确认冻结原文'],
    );
    raw.execute(
      'INSERT INTO sync_pull_errors(account_id,change_id,entity_type,entity_id,action,raw_change_json,'
      'first_seen_at,last_attempt_at) '
      "VALUES('account','1234','category','category','upsert',?,?,?)",
      ['{ "saved": true }', _stamp ~/ 1000, _stamp ~/ 1000],
    );
  } catch (error, stackTrace) {
    logger.error('SchemaBoundaryTest', '创建当前数据库夹具失败', error, stackTrace);
    rethrow;
  } finally {
    await db.close();
  }
}

/// 记录版本、全部结构与全部行，验证拒绝打开不会局部升级或清理原数据。
String _snapshot(Database raw) => jsonEncode({
  'version': raw.select('PRAGMA user_version').single.values.single,
  'schema': raw
      .select('SELECT * FROM sqlite_master ORDER BY type,name')
      .map((row) => Map<String, Object?>.from(row))
      .toList(),
  'rows': {
    for (final table in raw.select(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
    ))
      table['name'] as String: raw
          .select('SELECT * FROM "${table['name']}" ORDER BY rowid')
          .map((row) => Map<String, Object?>.from(row))
          .toList(),
  },
});

/// 未知版本或未知结构保留原件，不能把来源表补成空库来冒充迁移成功。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('当前结构反复打开保留全部记录、毫秒、水位与冻结字节，并启用外键', () async {
    final raw = sqlite3.openInMemory();
    try {
      await _seedCurrentDatabase(raw);
      final before = _snapshot(raw);
      for (var attempt = 0; attempt < 2; attempt++) {
        final db = SesameDatabase.withExecutor(
          NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
        );
        try {
          await db.customSelect('SELECT 1').get();
          expect(_snapshot(raw), before);
          expect(
            (await db.select(db.ledgerMembers).getSingle())
                .updatedAt
                .millisecondsSinceEpoch,
            _stamp,
          );
          expect(raw.select('PRAGMA foreign_keys').single.values.single, 1);
        } finally {
          await db.close();
        }
      }
    } catch (error, stackTrace) {
      logger.error('SchemaBoundaryTest', '当前数据库无损打开验证失败', error, stackTrace);
      rethrow;
    } finally {
      raw.close();
    }
  });

  for (final version in [
    ...List.generate(currentSchemaVersion, (version) => version),
    currentSchemaVersion + 1,
  ]) {
    test('当前列结构伪装为 schema$version 拒绝打开，原结构、数据和版本标记均不改写', () async {
      final raw = sqlite3.openInMemory();
      try {
        await _seedCurrentDatabase(raw);
        raw.execute('PRAGMA user_version=$version');
        final before = _snapshot(raw);
        final db = SesameDatabase.withExecutor(
          NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
        );
        try {
          await expectLater(
            db.customSelect('SELECT 1').get(),
            throwsA(isA<StateError>()),
          );
          expect(_snapshot(raw), before);
        } finally {
          await db.close();
        }
      } catch (error, stackTrace) {
        logger.error(
          'SchemaBoundaryTest',
          '完整结构的版本拒绝验证失败：$version',
          error,
          stackTrace,
        );
        rethrow;
      } finally {
        raw.close();
      }
    });
  }

  for (final version in [
    ...List.generate(currentSchemaVersion + 1, (version) => version),
    currentSchemaVersion + 1,
  ]) {
    test('未知结构的 schema$version 拒绝打开，版本、结构和数据完整保留', () async {
      final raw = sqlite3.openInMemory();
      final db = SesameDatabase.withExecutor(
        NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
      );
      try {
        raw.execute(
          'CREATE TABLE preserved_records(id TEXT PRIMARY KEY, body TEXT NOT NULL)',
        );
        raw.execute('CREATE INDEX preserved_body ON preserved_records(body)');
        raw.execute(
          "INSERT INTO preserved_records VALUES('record','原始正文与周期发生来源')",
        );
        raw.execute('PRAGMA user_version=$version');
        final before = _snapshot(raw);
        await expectLater(
          db.customSelect('SELECT 1').get(),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              '恢复提示',
              contains('保留'),
            ),
          ),
        );
        expect(_snapshot(raw), before);
      } catch (error, stackTrace) {
        logger.error(
          'SchemaBoundaryTest',
          '数据库版本边界验证失败：$version',
          error,
          stackTrace,
        );
        rethrow;
      } finally {
        await db.close();
        raw.close();
      }
    });
  }
}
