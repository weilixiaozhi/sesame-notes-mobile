import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../helpers/database_schema_fixture.dart';
import '../helpers/test_isolation.dart';

const _entity = '20000000-0000-4000-8000-000000000001';
const _mutation = '30000000-0000-4000-8000-000000000001';

/// 原始包络含未知业务字段，升级只能读取身份时间，不能重新序列化或重发。
String _frozen() => const JsonEncoder.withIndent('  ').convert({
  'mutation_id': _mutation,
  'entity_type': 'transaction',
  'entity_id': _entity,
  'action': 'upsert',
  'ledger_id': 'ledger',
  'updated_at': DateTime.fromMillisecondsSinceEpoch(
    schemaFixtureTimestamp,
    isUtc: true,
  ).toIso8601String(),
  'payload': {
    'amount': '12.3400',
    'exclude_from_stats': true,
    'unknown_history': {'original': '必须保留'},
  },
});

/// SQL 写入已知旧单位，覆盖未知冻结、明确拒收和多设备水位，避免新转换器污染夹具。
void _addPendingEvidence(sql.Database raw, int version) {
  final time = version < 6
      ? schemaFixtureTimestamp ~/ 1000
      : schemaFixtureTimestamp;
  for (final (id, wire, reason) in [
    ('known', _frozen(), null),
    ('unknown', '{ 原始未确认请求', null),
    ('rejected', null, '分类不可用，请重新选择分类后保存'),
  ]) {
    raw.execute(
      'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,action,payload,updated_at,mutation_id,account_id,frozen_request,rejection_reason,base_revision) '
      'VALUES(?,?,?,?,?,?,?,?,?,?,?)',
      [
        id == 'rejected' ? 'category' : 'transaction',
        id == 'known' ? _entity : id,
        id == 'rejected' ? null : 'ledger',
        'upsert',
        '{ "name": "原始草稿" }',
        time,
        id == 'known' ? _mutation : 'mutation-$id',
        schemaFixtureAccount,
        wire,
        reason,
        3,
      ],
    );
  }
  raw.execute(
    'INSERT INTO sync_state(account_id,device_id,server_cursor,day_events_cursor,memos_cursor,fitness_cursor,last_push_at,last_pull_at) '
    "VALUES(?,'another-session-device','123','0','500','999',300,400)",
    [schemaFixtureAccount],
  );
  raw.execute(
    'INSERT INTO sync_conflicts(id,account_id,entity_type,entity_id,local_payload,remote_payload,base_revision,remote_revision,local_mutation_id,resolution_request) '
    "VALUES('old-random-mirror',?,'category','category','{ \"old_local\": true }','{ \"old_cloud\": true }',1,2,'source-mutation','{ \"unconfirmed_decision\": true }')",
    [schemaFixtureAccount],
  );
}

/// 对结构、版本、索引和全部行取逻辑快照，回滚断言不能只比较业务表数量。
String _snapshot(sql.Database raw) => jsonEncode({
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

/// 保持 Native 原始连接可检查失败后的文件内容，Drift 包装连接由每个用例关闭。
SesameDatabase _database(sql.Database raw) => SesameDatabase.withExecutor(
  NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUp(() async {
    directory = await createTestTempDirectory('automatic-db-migration-');
  });
  tearDown(() async {
    final root = '${Directory('Temp').absolute.path}${Platform.pathSeparator}';
    if (!directory.absolute.path.startsWith(root)) {
      throw StateError('测试目录不在 Temp 内');
    }
    await directory.delete(recursive: true);
  });

  for (final version in [4, 5, 6, 7, 8, 9]) {
    test('首次打开真实schema$version升级当前结构，保留成员时间与未知冻结原始证据', () async {
      final file = File('${directory.path}/source.sqlite');
      await createHistoricalDatabaseFixture(file, version);
      final raw = sql.sqlite3.open(file.path);
      _addPendingEvidence(raw, version);
      final before = raw
          .select('SELECT * FROM sync_changes ORDER BY id')
          .map((row) => Map<String, Object?>.from(row))
          .toList();
      final conflicts = raw
          .select('SELECT * FROM sync_conflicts')
          .map((row) => Map<String, Object?>.from(row))
          .toList();
      final devices = raw
          .select(
            'SELECT account_id,device_id,last_push_at,last_pull_at FROM sync_state ORDER BY device_id',
          )
          .map((row) => Map<String, Object?>.from(row))
          .toList();
      final statesBefore = raw
          .select('SELECT * FROM sync_state ORDER BY device_id')
          .map((row) => Map<String, Object?>.from(row))
          .toList();
      final membersBefore = raw
          .select('SELECT * FROM ledger_members ORDER BY id')
          .map((row) => Map<String, Object?>.from(row))
          .toList();
      expect(membersBefore, hasLength(2));
      expect(
        membersBefore.map((member) => member['updated_at']),
        everyElement(schemaFixtureTimestamp ~/ 1000),
        reason: '历史夹具必须真实保存秒，不能仅修改版本号',
      );
      final db = _database(raw);
      try {
        await db.customSelect('SELECT 1').get();
        expect(
          raw.select('PRAGMA user_version').single.values.single,
          currentSchemaVersion,
        );
        final after = raw.select('SELECT * FROM sync_changes ORDER BY id');
        expect(after.length, before.length);
        for (var i = 0; i < before.length; i++) {
          for (final key in before[i].keys.where(
            (key) => key != 'updated_at',
          )) {
            expect(after[i][key], before[i][key], reason: '原队列字段 $key 不得改变');
          }
          expect(
            after[i]['updated_at'],
            version < 6 && i != 0
                ? schemaFixtureTimestamp ~/ 1000 * 1000
                : schemaFixtureTimestamp,
          );
        }
        expect(after[0]['frozen_request'], _frozen());
        expect(after[0]['rejection_reason'], isNull);
        expect(after[1]['frozen_request'], '{ 原始未确认请求');
        expect(after[1]['rejection_reason'], isNull);
        if (version < 5) expect(after[2]['rejection_code'], 'INVALID_CATEGORY');
        expect(
          raw
              .select('SELECT * FROM sync_conflicts')
              .map((row) => Map<String, Object?>.from(row))
              .toList(),
          conflicts,
        );
        expect(
          raw
              .select(
                'SELECT account_id,device_id,last_push_at,last_pull_at FROM sync_state ORDER BY device_id',
              )
              .map((row) => Map<String, Object?>.from(row))
              .toList(),
          devices,
        );
        if (version < 9) {
          for (final state in raw.select('SELECT * FROM sync_state')) {
            expect([
              state['server_cursor'],
              state['day_events_cursor'],
              state['memos_cursor'],
              state['fitness_cursor'],
            ], everyElement(isNull));
          }
        } else {
          expect(
            raw.select('SELECT * FROM sync_state ORDER BY device_id'),
            statesBefore,
            reason: '成员时间迁移不修改已确认的四域同步水位',
          );
        }
        final membersAfter = raw.select(
          'SELECT * FROM ledger_members ORDER BY id',
        );
        expect(membersAfter, [
          for (final member in membersBefore)
            {...member, 'updated_at': (member['updated_at']! as int) * 1000},
        ], reason: '仅编辑时间乘千，身份、正文及其余秒时间字段完整保留');
        expect(
          (await db.select(db.ledgerMembers).get()).map(
            (member) => member.updatedAt,
          ),
          everyElement(
            DateTime.fromMillisecondsSinceEpoch(
              schemaFixtureTimestamp ~/ 1000 * 1000,
              isUtc: true,
            ),
          ),
        );
        for (final table in [
          'ledgers',
          'recurring_transactions',
          'exchange_rate_overrides',
        ]) {
          final value = raw
              .select('SELECT updated_at,deleted_at FROM $table')
              .single;
          expect(
            value['updated_at'],
            version < 8
                ? schemaFixtureTimestamp ~/ 1000 * 1000
                : schemaFixtureTimestamp,
          );
          expect(
            value['deleted_at'],
            version < 8
                ? (schemaFixtureTimestamp + 20) ~/ 1000 * 1000
                : schemaFixtureTimestamp + 20,
          );
        }
        expect(
          raw.select('SELECT rate FROM exchange_rate_overrides').single['rate'],
          '7.123456789123456789',
        );
        expect(raw.select('PRAGMA foreign_key_check'), isEmpty);
        expect(
          raw
              .select('PRAGMA table_info(transactions)')
              .map((row) => row['name']),
          isNot(contains('exclude_from_stats')),
        );
      } finally {
        await db.close();
        raw.close();
      }
    });
  }

  test('正式后台连接首次打开旧7库自动升级，关闭重开不重复转换时间', () async {
    final file = File('${directory.path}/background.sqlite');
    await createHistoricalDatabaseFixture(file, 7);
    for (var attempt = 0; attempt < 2; attempt++) {
      final database = SesameDatabase.withExecutor(
        NativeDatabase.createInBackground(file),
      );
      try {
        final ledger = await database.select(database.ledgers).getSingle();
        expect(ledger.name, '原账本');
        expect(
          ledger.updatedAt.millisecondsSinceEpoch,
          schemaFixtureTimestamp ~/ 1000 * 1000,
        );
        expect(
          (await database.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          currentSchemaVersion,
        );
        final member = await (database.select(
          database.ledgerMembers,
        )..where((row) => row.id.equals(schemaFixtureMember))).getSingle();
        expect(
          member.updatedAt.millisecondsSinceEpoch,
          schemaFixtureTimestamp ~/ 1000 * 1000,
        );
        final state = await database.select(database.syncState).getSingle();
        expect([
          state.serverCursor,
          state.dayEventsCursor,
          state.memosCursor,
          state.fitnessCursor,
        ], everyElement(isNull));
      } finally {
        await database.close();
      }
    }
  });

  test('schema4分类归属升级保留私有类别，并为本地引用复制完整祖先链', () async {
    final file = File('${directory.path}/source.sqlite');
    await createHistoricalDatabaseFixture(file, 4);
    final raw = sql.sqlite3.open(file.path);
    raw.execute(
      "INSERT INTO categories(id,name,kind,level,parent_id,scope_account_id,server_version_token,updated_at) VALUES('parent','父','expense',1,NULL,?,'token',1000),('child','子','expense',2,'parent',?,'token',1000)",
      [schemaFixtureAccount, schemaFixtureAccount],
    );
    raw.execute(
      "INSERT INTO transactions(id,ledger_id,tx_type,amount,happened_at,currency_code,native_amount,created_at,updated_at,category_id,exclude_from_stats) VALUES('tx','ledger','expense','12.34',1000,'CNY','12.34',1000,2000,'child',1)",
    );
    final db = _database(raw);
    try {
      await db.customSelect('SELECT 1').get();
      expect(
        raw.select('SELECT id,scope_account_id FROM categories').length,
        4,
      );
      for (final scope in ['', schemaFixtureAccount]) {
        final categories = raw.select(
          'SELECT id,parent_id,cloud_registered,updated_at FROM categories WHERE scope_account_id=? ORDER BY id',
          [scope],
        );
        expect(categories.map((row) => row['id']), ['child', 'parent']);
        expect(categories.first['parent_id'], 'parent');
        expect(
          categories.map((row) => row['updated_at']),
          everyElement(1000000),
        );
        expect(
          categories.map((row) => row['cloud_registered']),
          everyElement(scope.isEmpty ? 0 : 1),
        );
      }
      expect(
        raw.select('SELECT amount,category_id FROM transactions').single,
        containsPair('amount', '12.34'),
      );
      expect(
        raw
            .select('SELECT category_id FROM transactions')
            .single['category_id'],
        'child',
      );
    } finally {
      await db.close();
      raw.close();
    }
  });

  for (final failure in [
    'unknown-column',
    'unrepresentable-time',
    'foreign-key',
  ]) {
    test('$failure使整次自动升级回滚，原版本结构与原始行全部保留', () async {
      final file = File('${directory.path}/source.sqlite');
      await createHistoricalDatabaseFixture(file, 4);
      final raw = sql.sqlite3.open(file.path);
      try {
        _addPendingEvidence(raw, 4);
        if (failure == 'unknown-column') {
          raw.execute('ALTER TABLE sync_changes ADD COLUMN unexplained TEXT');
        }
        if (failure == 'unrepresentable-time') {
          raw.execute('UPDATE ledgers SET updated_at=253402300800');
        }
        if (failure == 'foreign-key') {
          raw.execute(
            "INSERT INTO transaction_splits(transaction_id,member_id,amount) VALUES('missing-tx','missing-member','1')",
          );
        }
        final before = _snapshot(raw);
        final db = _database(raw);
        try {
          await expectLater(
            db.customSelect('SELECT 1').get(),
            throwsA(isA<StateError>()),
          );
          expect(_snapshot(raw), before);
        } finally {
          await db.close();
        }
      } finally {
        raw.close();
      }
    });
  }

  for (final invalid in <Object>[
    253402300800,
    -62135596801,
    1000.5,
    'invalid-time',
  ]) {
    test('schema9成员秒时间$invalid不能安全转换时整库回滚，冻结证据不变', () async {
      final file = File('${directory.path}/member-invalid.sqlite');
      await createHistoricalDatabaseFixture(file, 9);
      final raw = sql.sqlite3.open(file.path);
      try {
        _addPendingEvidence(raw, 9);
        raw.execute('UPDATE ledger_members SET updated_at=? WHERE id=?', [
          invalid,
          schemaFixtureMember,
        ]);
        final before = _snapshot(raw);
        final db = _database(raw);
        try {
          await expectLater(
            db.customSelect('SELECT 1').get(),
            throwsStateError,
          );
          expect(_snapshot(raw), before);
        } finally {
          await db.close();
        }
      } finally {
        raw.close();
      }
    });
  }

  test('当前结构反复打开保留成员毫秒、有效水位与未知冻结字节', () async {
    final file = File('${directory.path}/current.sqlite');
    await createHistoricalDatabaseFixture(file, currentSchemaVersion);
    final raw = sql.sqlite3.open(file.path);
    _addPendingEvidence(raw, currentSchemaVersion);
    final before = _snapshot(raw);
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        final db = _database(raw);
        try {
          await db.customSelect('SELECT 1').get();
          expect(_snapshot(raw), before);
          expect(
            (await db.select(db.ledgerMembers).get()).map(
              (member) => member.updatedAt.millisecondsSinceEpoch,
            ),
            everyElement(schemaFixtureTimestamp),
          );
        } finally {
          await db.close();
        }
      }
    } finally {
      raw.close();
    }
  });
}
