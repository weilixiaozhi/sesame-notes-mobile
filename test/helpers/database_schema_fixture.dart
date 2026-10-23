import 'dart:io';
import 'package:drift/native.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

const schemaFixtureAccount = '10000000-0000-4000-8000-000000000001';
const schemaFixtureDevice = '10000000-0000-4000-8000-000000000002';
const schemaFixtureTimestamp = 1792371723947;
const schemaFixtureMember = '20000000-0000-4000-8000-000000000011';
const schemaFixtureDeletedMember = '20000000-0000-4000-8000-000000000012';

/// 从当前真实建库逆构已发布历史列和单位，不能仅篡改 user_version 冒充历史夹具。
Future<void> createHistoricalDatabaseFixture(File file, int version) async {
  final current = SesameDatabase.withExecutor(NativeDatabase(file));
  try {
    await current.customSelect('SELECT 1').get();
  } finally {
    await current.close();
  }
  final raw = sql.sqlite3.open(file.path);
  try {
    raw.execute('PRAGMA foreign_keys=OFF');
    raw.execute(
      "INSERT INTO ledgers(id,name,updated_at,deleted_at) VALUES('ledger','原账本',?,?)",
      [schemaFixtureTimestamp, schemaFixtureTimestamp + 20],
    );
    // 只逆转历史版本的编辑时间列；成员加入、创建和删除时间始终使用原秒单位。
    for (final deleted in [false, true]) {
      raw.execute(
        'INSERT INTO ledger_members(id,ledger_id,display_name,member_type,joined_at,created_at,updated_at,deleted_at) '
        "VALUES(?,'ledger',?,'PLACEHOLDER',?,?,?,?)",
        [
          deleted ? schemaFixtureDeletedMember : schemaFixtureMember,
          deleted ? '历史删除成员' : '历史成员',
          schemaFixtureTimestamp ~/ 1000 - 50,
          schemaFixtureTimestamp ~/ 1000 - 100,
          schemaFixtureTimestamp,
          deleted ? schemaFixtureTimestamp ~/ 1000 + 20 : null,
        ],
      );
    }
    raw.execute(
      'INSERT INTO recurring_transactions(id,ledger_id,tx_type,amount,currency_code,frequency,start_date,updated_at,deleted_at) '
      "VALUES('rule','ledger','expense','12.3400','CNY','monthly',0,?,?)",
      [schemaFixtureTimestamp, schemaFixtureTimestamp + 20],
    );
    raw.execute(
      'INSERT INTO exchange_rate_overrides(id,base_currency,quote_currency,rate,updated_at,deleted_at) '
      "VALUES('rate','USD','CNY','7.123456789123456789',?,?)",
      [schemaFixtureTimestamp, schemaFixtureTimestamp + 20],
    );
    raw.execute(
      'INSERT INTO sync_state(account_id,device_id,server_cursor,day_events_cursor,memos_cursor,fitness_cursor,last_push_at,last_pull_at) '
      "VALUES(?,?,'0','123','123','123',100,200)",
      [schemaFixtureAccount, schemaFixtureDevice],
    );
    if (version < 9) {
      raw.execute('ALTER TABLE sync_state RENAME TO sync_state_current');
      raw.execute(
        'CREATE TABLE sync_state(account_id TEXT NOT NULL DEFAULT \'\',device_id TEXT NOT NULL,'
        'server_cursor TEXT NOT NULL DEFAULT \'0\',day_events_cursor TEXT,memos_cursor TEXT,fitness_cursor TEXT,'
        'last_push_at INTEGER,last_pull_at INTEGER,PRIMARY KEY(account_id,device_id))',
      );
      raw.execute('INSERT INTO sync_state SELECT * FROM sync_state_current');
      raw.execute('DROP TABLE sync_state_current');
    }
    if (version < 10) {
      raw.execute(
        'UPDATE ledger_members SET updated_at=CAST(updated_at/1000 AS INTEGER)',
      );
    }
    if (version < 8) {
      for (final table in [
        'ledgers',
        'recurring_transactions',
        'exchange_rate_overrides',
      ]) {
        raw.execute(
          'UPDATE $table SET updated_at=CAST(updated_at/1000 AS INTEGER),deleted_at=CAST(deleted_at/1000 AS INTEGER)',
        );
      }
    }
    if (version < 7) {
      raw.execute(
        'ALTER TABLE transactions ADD COLUMN exclude_from_stats INTEGER NOT NULL DEFAULT 0 CHECK(exclude_from_stats IN(0,1))',
      );
    }
    if (version < 5) {
      raw.execute('DROP INDEX idx_categories_parent_id');
      raw.execute('DROP INDEX idx_categories_scope_parent');
      raw.execute('ALTER TABLE categories RENAME TO categories_current');
      raw.execute(
        'CREATE TABLE categories(id TEXT NOT NULL PRIMARY KEY,name TEXT NOT NULL,kind TEXT NOT NULL,level INTEGER NOT NULL,'
        'sort_order INTEGER NOT NULL DEFAULT 0,icon TEXT,parent_id TEXT REFERENCES categories(id) ON DELETE SET NULL,'
        "scope_account_id TEXT,server_version_token TEXT,updated_at INTEGER NOT NULL,deleted_at INTEGER,CHECK(kind='expense'),CHECK(level IN(1,2)))",
      );
      raw.execute(
        'INSERT INTO categories SELECT id,name,kind,level,sort_order,icon,parent_id,NULLIF(scope_account_id,\'\'),'
        'server_version_token,CAST(updated_at/1000 AS INTEGER),CAST(deleted_at/1000 AS INTEGER) FROM categories_current',
      );
      raw.execute('DROP TABLE categories_current');
      raw.execute(
        'CREATE INDEX idx_categories_parent_id ON categories(parent_id)',
      );
      raw.execute(
        'CREATE INDEX idx_categories_scope_parent ON categories(scope_account_id,parent_id)',
      );
      raw.execute('ALTER TABLE ledgers DROP COLUMN owner_account_id');
      raw.execute(
        'ALTER TABLE shared_ledger_categories DROP COLUMN deleted_at',
      );
      raw.execute(
        'UPDATE shared_ledger_categories SET updated_at=CAST(updated_at/1000 AS INTEGER)',
      );
      raw.execute('ALTER TABLE sync_changes DROP COLUMN rejection_code');
    }
    raw.execute('PRAGMA user_version=$version');
  } finally {
    raw.close();
  }
}
