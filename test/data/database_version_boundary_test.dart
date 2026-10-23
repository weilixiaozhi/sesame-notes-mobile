import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart';

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
  for (final version in [
    ...List.generate(currentSchemaVersion, (version) => version),
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
