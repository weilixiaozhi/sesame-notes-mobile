import 'dart:convert';
import 'dart:io';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

const schemaTenAccount = '10000000-0000-4000-8000-000000000001';
const schemaTenDevice = '10000000-0000-4000-8000-000000000002';
const schemaTenSeconds = 1792371723;
const schemaTenMilliseconds = 1792371723947;
const schemaTenAmount = '12345678901234567890.1234567890';
const schemaTenFrozen =
    '{\n  "mutation_id": "unchanged-mutation",\n'
    '  "payload": {"amount":"12.3400","exclude_from_stats":true,"extra":[1,2]}\n}';

/// 按固定 SQL 结构创建独立文件，并写入覆盖各业务域的原始数据。
Future<void> createSchemaTenDatabaseFixture(File file) async {
  sql.Database? raw;
  try {
    final fixture =
        jsonDecode(
              await File(
                'test/fixtures/database_schema10/schema.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    if (fixture['schema_version'] != 10) {
      throw StateError('测试结构版本不符');
    }
    raw = sql.sqlite3.open(file.path);
    raw.execute('PRAGMA foreign_keys=OFF');
    raw.execute('BEGIN');
    try {
      for (final object in fixture['objects'] as List<dynamic>) {
        raw.execute((object as Map<String, dynamic>)['sql'] as String);
      }
      raw.execute('PRAGMA user_version=10');
      _seedSchemaTenRows(raw);
      raw.execute('UPDATE ledgers SET origin_last_revision=7');
      raw.execute("UPDATE sync_pull_errors SET user_action='retry_requested'");
      for (final table in [
        'ledgers',
        'recurring_transactions',
        'exchange_rate_overrides',
      ]) {
        raw.execute(
          'UPDATE $table SET updated_at=updated_at*1000,deleted_at=deleted_at*1000',
        );
      }
      raw.execute('UPDATE ledger_members SET updated_at=updated_at*1000');
      if (raw.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw StateError('测试夹具存在未满足的外键');
      }
      raw.execute('COMMIT');
    } catch (_) {
      raw.execute('ROLLBACK');
      rethrow;
    }
  } catch (error, stack) {
    logger.error(
      'SchemaTenFixture',
      '创建结构6测试夹具失败',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  } finally {
    raw?.close();
  }
}

/// 同时保留本地与账号域、原始金额文本、毫秒正文及秒时间字段。
void _seedSchemaTenRows(sql.Database raw) {
  raw.execute(
    'INSERT INTO ledgers(id,name,updated_at,deleted_at,self_member_id,created_at) '
    "VALUES('ledger','本地账本',?,?,'local-member',?)",
    [schemaTenSeconds, schemaTenSeconds + 20, schemaTenSeconds - 100],
  );
  raw.execute(
    'INSERT INTO ledgers(id,name,storage_mode,scope_account_id,owner_account_id,'
    'sync_id,updated_at,created_at,self_member_id) '
    "VALUES('cloud-ledger','账号账本','cloud',?,?,'cloud-binding',?,?,'cloud-member')",
    [
      schemaTenAccount,
      schemaTenAccount,
      schemaTenSeconds + 1,
      schemaTenSeconds - 100,
    ],
  );
  for (final (id, ledger, type, linked, deleted) in [
    ('local-member', 'ledger', 'LOCAL', null, null),
    ('deleted-member', 'ledger', 'PLACEHOLDER', null, schemaTenSeconds + 20),
    ('cloud-member', 'cloud-ledger', 'REGISTERED', schemaTenAccount, null),
  ]) {
    raw.execute(
      'INSERT INTO ledger_members(id,ledger_id,display_name,member_type,'
      'linked_account_id,joined_at,created_at,updated_at,deleted_at) '
      'VALUES(?,?,?,?,?,?,?,?,?)',
      [
        id,
        ledger,
        '保留成员 $id',
        type,
        linked,
        schemaTenSeconds - 50,
        schemaTenSeconds - 100,
        schemaTenSeconds,
        deleted,
      ],
    );
  }
  for (final scope in ['', schemaTenAccount]) {
    raw.execute(
      'INSERT INTO categories(id,name,kind,level,scope_account_id,updated_at,'
      'deleted_at,observed_cloud_state) '
      "VALUES('category','保留分类','expense',1,?,?,?,?)",
      [
        scope,
        schemaTenMilliseconds,
        schemaTenMilliseconds + 20,
        '{ "extra": "保留分类证据" }',
      ],
    );
  }
  raw.execute(
    'INSERT INTO transactions(id,ledger_id,tx_type,amount,happened_at,currency_code,'
    'native_amount,created_at,updated_at,deleted_at,created_by_member_id,'
    'payer_member_id,aa_mode,note,category_id) '
    "VALUES('transaction','ledger','expense',? ,?,'CNY',?,?,?,?,"
    "'local-member','deleted-member',2,'保留账单原文','category')",
    [
      schemaTenAmount,
      schemaTenSeconds - 10,
      schemaTenAmount,
      schemaTenSeconds - 100,
      schemaTenSeconds,
      schemaTenSeconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO transaction_splits(transaction_id,member_id,amount) '
    "VALUES('transaction','deleted-member','12.3400')",
  );
  raw.execute(
    'INSERT INTO record_edit_histories(record_id,version,operator_member_id,summary,created_at) '
    "VALUES('transaction',2,'local-member','保留编辑历史',?)",
    [schemaTenSeconds],
  );
  raw.execute(
    'INSERT INTO recurring_transactions(id,ledger_id,tx_type,amount,currency_code,'
    'frequency,start_date,updated_at,deleted_at,created_at) '
    "VALUES('rule','ledger','expense','12.3400','CNY','monthly',?,?,?,?)",
    [
      schemaTenSeconds - 100,
      schemaTenSeconds,
      schemaTenSeconds + 20,
      schemaTenSeconds - 100,
    ],
  );
  raw.execute(
    'INSERT INTO exchange_rate_overrides(id,base_currency,quote_currency,rate,'
    "updated_at,deleted_at) VALUES('rate','USD','CNY','7.123456789123456789',?,?)",
    [schemaTenSeconds, schemaTenSeconds + 20],
  );
  raw.execute(
    'INSERT INTO exchange_rates(base_currency,quote_currency,rate_date,rate,source,fetched_at) '
    "VALUES('USD','CNY','2026-11-03','7.123456789123456789','server',?)",
    [schemaTenSeconds],
  );
  raw.execute(
    'INSERT INTO shared_ledger_categories(ledger_id,category_id,name,kind,updated_at,deleted_at) '
    "VALUES('cloud-ledger','category','共享分类','expense',?,?)",
    [schemaTenMilliseconds, schemaTenMilliseconds + 20],
  );
  raw.execute(
    'INSERT INTO day_books(id,name,created_at,updated_at,deleted_at) '
    "VALUES('day-book','保留日子本',?,?,?)",
    [
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO day_events(id,day_book_id,category,name,repeat_type,statistic_type,'
    'event_calendar_type,event_original_year,event_original_month,event_original_day,'
    'event_is_leap_month,event_solar_date,created_at,updated_at,deleted_at) '
    "VALUES('day-event','day-book','birthday','保留生日','yearly','year',"
    "'solar',2026,11,3,0,'2026-11-03',?,?,?)",
    [
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO day_import_receipts(target_day_book_id,export_id,source_entry_id,local_event_id,imported_at) '
    "VALUES('day-book','day-export','source-day','day-event',?)",
    [schemaTenMilliseconds],
  );
  raw.execute(
    'INSERT INTO memo_books(id,name,type,created_at,updated_at,deleted_at) '
    "VALUES('memo-book','保留备忘录','normal',?,?,?)",
    [
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO memo_entries(id,memo_book_id,book_type,title,body_format,body,'
    'created_at,updated_at,deleted_at) '
    "VALUES('memo-entry','memo-book','normal','保留标题','delta_v1',?,?,?,?)",
    [
      '{ "ops": [{"insert":"保留正文\\n"}], "extra": "原样" }',
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO memo_import_receipts(target_memo_book_id,export_id,source_book_id,'
    'source_entry_id,fingerprint,local_entry_id,imported_at) '
    "VALUES('memo-book','memo-export','source-book','source-entry','fingerprint','memo-entry',?)",
    [schemaTenSeconds],
  );
  raw.execute(
    'INSERT INTO fitness_spaces(id,name,created_at,updated_at,deleted_at) '
    "VALUES('fitness-space','保留健身空间',?,?,?)",
    [
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO fitness_entities(id,fitness_space_id,entity_type,payload,'
    'created_at,updated_at,deleted_at) '
    "VALUES('fitness-template','fitness-space','fitness_template',?,?,?,?)",
    [
      '{ "name":"保留训练", "sets":[{"weight":"12.3400"}], "extra":true }',
      schemaTenMilliseconds,
      schemaTenMilliseconds + 1,
      schemaTenMilliseconds + 20,
    ],
  );
  raw.execute(
    'INSERT INTO fitness_import_receipts(fitness_space_id,export_id,entity_type,'
    'source_id,target_id,imported_at) '
    "VALUES('fitness-space','fitness-export','fitness_template','source-fitness','fitness-template',?)",
    [schemaTenMilliseconds],
  );
  for (final (entity, id, frozen, reason, code, pushed) in [
    ('transaction', 'transaction', schemaTenFrozen, null, null, null),
    ('category', 'unknown', '{ 未确认冻结原字节', null, null, null),
    ('category', 'rejected', null, '保留拒收原因', 'INVALID_CATEGORY', null),
    ('day_event', 'day-event', null, null, null, schemaTenSeconds - 1),
    ('memo_entry', 'memo-entry', null, null, null, null),
    ('fitness_template', 'fitness-template', null, null, null, null),
  ]) {
    raw.execute(
      'INSERT INTO sync_changes(entity_type,entity_id,ledger_id,day_book_id,memo_book_id,'
      'fitness_space_id,action,payload,updated_at,mutation_id,account_id,'
      'frozen_request,rejection_reason,rejection_code,base_revision,pushed_at) '
      'VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)',
      [
        entity,
        id,
        entity == 'transaction' ? 'ledger' : null,
        entity == 'day_event' ? 'day-book' : null,
        entity == 'memo_entry' ? 'memo-book' : null,
        entity == 'fitness_template' ? 'fitness-space' : null,
        'upsert',
        '{ "entity": "$id", "extra": [1,2,3] }\n',
        schemaTenMilliseconds,
        'mutation-$id',
        schemaTenAccount,
        frozen,
        reason,
        code,
        9007199254740991,
        pushed,
      ],
    );
  }
  for (final device in [schemaTenDevice, 'second-device']) {
    raw.execute(
      'INSERT INTO sync_state(account_id,device_id,server_cursor,day_events_cursor,'
      'memos_cursor,fitness_cursor,last_push_at,last_pull_at) VALUES(?,?,?,?,?,?,?,?)',
      [
        schemaTenAccount,
        device,
        '900719925474099312345',
        '0',
        '123',
        '999',
        schemaTenSeconds - 2,
        schemaTenSeconds - 1,
      ],
    );
  }
  raw.execute(
    'INSERT INTO sync_conflicts(id,account_id,entity_type,entity_id,local_payload,'
    'remote_payload,base_revision,remote_revision,local_mutation_id,resolution_request) '
    "VALUES('conflict',?,'category','category',?, ?,1,2,'source-mutation',?)",
    [
      schemaTenAccount,
      '{ "local": true }',
      '{ "remote": true }',
      '{ "decision": "未确认", "extra": [1,2] }',
    ],
  );
  raw.execute(
    'INSERT INTO sync_pull_errors(account_id,change_id,entity_type,entity_id,action,raw_change_json,'
    'error_message,first_seen_at,last_attempt_at) '
    "VALUES(?,'900719925474099312346','transaction','transaction','upsert',?,"
    "'保留拉取错误',?,?)",
    [
      schemaTenAccount,
      '{ "evidence":"保留" }',
      schemaTenSeconds,
      schemaTenSeconds,
    ],
  );
  raw.execute(
    'INSERT INTO backup_state(id,dirty_since,last_success_at,current_provider) '
    "VALUES(0,?,?,'s3')",
    [schemaTenSeconds, schemaTenSeconds - 10],
  );
  raw.execute(
    'INSERT INTO recovery_logs(source_backup_name,action,result,detail,created_at) '
    "VALUES('保留来源.snbak','restore_local','success','保留恢复审计',?)",
    [schemaTenSeconds],
  );
}

/// 固定逐表内容，包含自增序号，以核验所有非目标字段保持原值。
Map<String, List<Map<String, Object?>>> schemaTenRows(sql.Database raw) {
  try {
    return {
      for (final entry in raw.select(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name",
      ))
        entry['name'] as String: raw
            .select('SELECT * FROM "${entry['name']}" ORDER BY rowid')
            .map((row) => Map<String, Object?>.from(row))
            .toList(),
    };
  } catch (error, stack) {
    logger.error('SchemaTenFixture', '读取逐表校验快照失败', error, stack);
    rethrow;
  }
}

/// 版本、结构对象和全部行共同组成回滚证据，不能只比较行数。
String schemaTenSnapshot(sql.Database raw) {
  try {
    return jsonEncode({
      'version': raw.select('PRAGMA user_version').single.values.single,
      'schema': raw
          .select('SELECT * FROM sqlite_master ORDER BY type,name')
          .map((row) => Map<String, Object?>.from(row))
          .toList(),
      'rows': schemaTenRows(raw),
    });
  } catch (error, stack) {
    logger.error('SchemaTenFixture', '读取数据库完整校验快照失败', error, stack);
    rethrow;
  }
}

/// 预期只移除明确停用的列，其余所有字段与原始字节保持一致。
Map<String, List<Map<String, Object?>>> expectedSchemaTenRows(
  Map<String, List<Map<String, Object?>>> source,
) => {
  for (final entry in source.entries)
    if (entry.key != 'recovery_logs')
      entry.key: [
        for (final row in entry.value)
          if (!(entry.key == 'sqlite_sequence' &&
              row['name'] == 'recovery_logs'))
            {
              for (final field in row.entries)
                if (!(entry.key == 'ledgers' &&
                        field.key == 'origin_last_revision') &&
                    !(entry.key == 'sync_state' &&
                        field.key == 'last_push_at') &&
                    !(entry.key == 'sync_state' &&
                        field.key == 'last_pull_at') &&
                    !(entry.key == 'sync_pull_errors' &&
                        field.key == 'user_action') &&
                    !(entry.key == 'sync_pull_errors' &&
                        field.key == 'error_message'))
                  field.key: field.value,
            },
      ],
};
