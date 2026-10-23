import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// 用固定凭证列构造不受支持的活动数据库，验证拒绝时完整保留原记录。
const _v1MemoEntries = '''
CREATE TABLE memo_entries (
  id TEXT NOT NULL,
  memo_book_id TEXT NOT NULL,
  book_type TEXT NOT NULL,
  title TEXT NOT NULL,
  body_format TEXT,
  body TEXT,
  account TEXT,
  password TEXT,
  phone TEXT,
  email TEXT,
  remark TEXT,
  order_key INTEGER,
  server_revision INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted_at INTEGER,
  source_entry_id TEXT,
  source_conflict_id TEXT UNIQUE,
  PRIMARY KEY (id)
);
''';

/// 数据库版本边界验证使用仓库内临时文件，退出时关闭连接再清理夹具。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late File file;

  setUp(() async {
    try {
      temp = await Directory('Temp').createTemp('memo-version-');
      file = File(p.join(temp.path, 'sesame.sqlite'));
    } catch (error, stackTrace) {
      logger.error('MemoSchemaTest', '数据库测试文件创建失败', error, stackTrace);
      rethrow;
    }
  });
  tearDown(() async {
    try {
      final root = p.normalize(p.absolute('Temp'));
      final target = p.normalize(await temp.resolveSymbolicLinks());
      if (!p.isWithin(root, target)) throw StateError('临时文件路径越出测试目录');
      await Directory(target).delete(recursive: true);
    } catch (error, stackTrace) {
      logger.error('MemoSchemaTest', '数据库测试文件清理失败', error, stackTrace);
      rethrow;
    }
  });

  /// 构造包含普通笔记、固定凭证列和待同步记录的 schema1 文件。
  void createV1Database() {
    final raw = sql.sqlite3.open(file.path);
    try {
      raw.execute(
        'CREATE TABLE memo_books(id TEXT PRIMARY KEY,name TEXT NOT NULL,type TEXT NOT NULL,'
        'storage_mode TEXT NOT NULL,created_at INTEGER NOT NULL,updated_at INTEGER NOT NULL)',
      );
      raw.execute(
        'CREATE TABLE sync_changes(id INTEGER PRIMARY KEY AUTOINCREMENT,entity_type TEXT NOT NULL,'
        'entity_id TEXT NOT NULL,memo_book_id TEXT,action TEXT NOT NULL,payload TEXT NOT NULL,'
        'updated_at INTEGER NOT NULL,mutation_id TEXT NOT NULL,base_revision INTEGER NOT NULL)',
      );
      raw.execute(_v1MemoEntries);
      raw.execute(
        "INSERT INTO memo_books (id,name,type,storage_mode,created_at,updated_at) "
        "VALUES ('book-normal','普通本','normal','local',1000,1000),"
        "('book-card','账号密码本','credentials','local',1000,1000)",
      );
      raw.execute(
        "INSERT INTO memo_entries (id,memo_book_id,book_type,title,body_format,body,order_key,created_at,updated_at) "
        "VALUES ('entry-note','book-normal','normal','普通笔记','delta_v1',"
        "'{\"ops\":[{\"insert\":\"正文\\n\"}]}',NULL,1000,2000)",
      );
      raw.execute(
        "INSERT INTO memo_entries (id,memo_book_id,book_type,title,account,password,phone,email,remark,order_key,created_at,updated_at) "
        "VALUES ('entry-card','book-card','credentials','旧卡片','user','secret','','','',0,1000,2000)",
      );
      for (final book in ['book-normal', 'book-card']) {
        raw.execute(
          "INSERT INTO sync_changes (entity_type,entity_id,memo_book_id,action,payload,updated_at,mutation_id,base_revision) "
          "VALUES ('memo_entry','entry-' || ?,?,'upsert','{}',2000,'mutation-' || ?,0)",
          [book == 'book-normal' ? 'note' : 'card', book, book],
        );
      }
      raw.execute('PRAGMA user_version = 1');
    } catch (error, stackTrace) {
      logger.error('MemoSchemaTest', '旧结构数据库夹具构造失败', error, stackTrace);
      rethrow;
    } finally {
      raw.close();
    }
  }

  /// 比较真实文件中的版本、结构和全部行，包含凭证正文及待同步意图。
  String snapshot(sql.Database raw) => jsonEncode({
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

  test('schema1 活动文件拒绝打开，普通笔记、凭证列与队列完整保留', () async {
    createV1Database();
    final raw = sql.sqlite3.open(file.path);
    final unsupported = SesameDatabase.withExecutor(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    try {
      final before = snapshot(raw);
      await expectLater(
        unsupported.customSelect('SELECT 1').get(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            '恢复提示',
            contains('保留原文件'),
          ),
        ),
      );
      expect(snapshot(raw), before);
      expect(
        raw
            .select("SELECT password FROM memo_entries WHERE id='entry-card'")
            .single['password'],
        'secret',
      );
      expect(raw.select('SELECT * FROM sync_changes'), hasLength(2));
    } catch (error, stackTrace) {
      logger.error('MemoSchemaTest', '不受支持数据库保留验证失败', error, stackTrace);
      rethrow;
    } finally {
      await unsupported.close();
      raw.close();
    }
  });
}
