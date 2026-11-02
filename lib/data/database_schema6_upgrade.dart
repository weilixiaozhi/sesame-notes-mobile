part of 'db.dart';

/// schema 6 中以整数秒保存、在当前结构中按整数毫秒读取的列。
const _schema6SecondColumns = [
  ('ledgers', 'updated_at'),
  ('ledgers', 'deleted_at'),
  ('recurring_transactions', 'updated_at'),
  ('recurring_transactions', 'deleted_at'),
  ('exchange_rate_overrides', 'updated_at'),
  ('exchange_rate_overrides', 'deleted_at'),
  ('ledger_members', 'updated_at'),
];

/// 活动库只转换已经识别的 schema 6；备份读取入口仍独立拒绝结构升级。
extension _Schema6DatabaseUpgrade on SesameDatabase {
  /// 在同一事务中识别结构、换算时间、重建水位并验收，失败保留原结构与全部记录。
  Future<void> _upgradeSchema6Database(Migrator m, int from, int to) async {
    try {
      if (from != 6 || to != 10 || to != currentSchemaVersion) {
        throw StateError('本机数据库版本不受支持，请保留原文件并从当前版本备份恢复；当前数据未修改。');
      }
      await transaction(() async {
        await _requireSchema6UpgradeStructure(source: true);
        await _requireSchema6UpgradeIntegrity();

        // 先检查全部来源单位；毫秒值、非整数或超范围记录不能被再次乘千。
        for (final (table, column) in _schema6SecondColumns) {
          final invalid = await customSelect(
            'SELECT 1 FROM $table WHERE $column IS NOT NULL AND '
            "(typeof($column)!='integer' OR $column < -62135596800 OR $column > 253402300799) LIMIT 1",
          ).get();
          if (invalid.isNotEmpty) {
            throw StateError('本机记录时间无法安全升级，请保留原文件；当前数据未修改。');
          }
        }

        await customStatement(
          'ALTER TABLE transactions DROP COLUMN exclude_from_stats',
        );
        for (final (table, column) in _schema6SecondColumns) {
          await customStatement(
            'UPDATE $table SET $column=$column*1000 WHERE $column IS NOT NULL',
          );
        }

        // 空水位要求各域重新取得完整快照；账号、设备及推拉时间原样带入。
        // 待上传队列、冻结请求、mutation、拒收信息与冲突记录均不参与转换。
        await customStatement(
          'ALTER TABLE sync_state RENAME TO sync_state_schema6_upgrade',
        );
        await m.createTable(syncState);
        await customStatement(
          'INSERT INTO sync_state(account_id,device_id,last_push_at,last_pull_at) '
          'SELECT account_id,device_id,last_push_at,last_pull_at FROM sync_state_schema6_upgrade',
        );
        await customStatement('DROP TABLE sync_state_schema6_upgrade');

        // 结构与版本号共同提交，重启后不会把已完成换算的数据再次按秒处理。
        await customStatement('PRAGMA user_version=$to');
        await _requireSchema6UpgradeStructure(source: false);
        final version = await customSelect('PRAGMA user_version').getSingle();
        if (version.read<int>('user_version') != to) {
          throw StateError(incompleteSchemaMessage);
        }
        await _requireSchema6UpgradeIntegrity();
      });
    } catch (error, stackTrace) {
      logger.error(
        'Database',
        '本机数据库升级失败：来源版本=$from，目标版本=$to',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 对照生成模型校验表、列类型、空值、默认值及主键，来源仅允许两处明确列差异。
  Future<void> _requireSchema6UpgradeStructure({required bool source}) async {
    try {
      final tables = (await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      ).get()).map((row) => row.read<String>('name')).toSet();
      final expectedTables = allTables
          .map((table) => table.actualTableName)
          .toSet();
      if (tables.length != expectedTables.length ||
          !tables.containsAll(expectedTables)) {
        throw StateError(incompleteSchemaMessage);
      }
      for (final table in allTables) {
        final name = table.actualTableName;
        final columns = await customSelect('PRAGMA table_info("$name")').get();
        final actual = {
          for (final column in columns) column.read<String>('name'): column,
        };
        final expectedNames = table.$columns
            .map((column) => column.$name)
            .toSet();
        if (source && name == 'transactions') {
          expectedNames.add('exclude_from_stats');
          final excluded = actual['exclude_from_stats'];
          if (excluded == null ||
              excluded.read<String>('type').toUpperCase() != 'INTEGER' ||
              excluded.read<int>('notnull') != 1 ||
              excluded.readNullable<String>('dflt_value') != '0' ||
              excluded.read<int>('pk') != 0) {
            throw StateError(incompleteSchemaMessage);
          }
        }
        if (actual.length != expectedNames.length ||
            !actual.keys.toSet().containsAll(expectedNames)) {
          throw StateError(incompleteSchemaMessage);
        }
        for (final column in table.$columns) {
          final stored = actual[column.$name]!;
          final sourceCursor =
              source && name == 'sync_state' && column.$name == 'server_cursor';
          final context = GenerationContext.fromDb(
            this,
            supportsVariables: false,
          );
          final expectedType = column.type.sqlTypeName(context).toUpperCase();
          final defaultExpression = column.defaultValue;
          defaultExpression?.writeInto(context);
          final expectedDefault = sourceCursor
              ? "'0'"
              : defaultExpression == null
              ? null
              : context.sql;
          final actualDefault = stored.readNullable<String>('dflt_value');
          // SQLite 的 PRAGMA 可能保留表达式的外层括号，字面值及表达式正文须一致。
          final defaultMatches =
              actualDefault == expectedDefault ||
              actualDefault != null &&
                  expectedDefault != null &&
                  (actualDefault == '($expectedDefault)' ||
                      expectedDefault == '($actualDefault)');
          if (stored.read<String>('type').toUpperCase() != expectedType ||
              stored.read<int>('notnull') !=
                  (sourceCursor || !column.$nullable ? 1 : 0) ||
              !defaultMatches ||
              (stored.read<int>('pk') > 0) !=
                  table.$primaryKey.contains(column)) {
            throw StateError(incompleteSchemaMessage);
          }
        }
      }
    } catch (error, stackTrace) {
      logger.error(
        'Database',
        '本机数据库升级结构检查失败：来源结构=$source',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 转换前后均检查 SQLite 页结构与外键，损坏或悬空引用不能提交为当前版本。
  Future<void> _requireSchema6UpgradeIntegrity() async {
    try {
      final integrity = await customSelect('PRAGMA quick_check').get();
      if (integrity.length != 1 ||
          integrity.single.data.values.single != 'ok' ||
          (await customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
        throw StateError(incompleteSchemaMessage);
      }
    } catch (error, stackTrace) {
      logger.error(
        'Database',
        '本机数据库升级完整性检查失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}
