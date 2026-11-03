part of 'db.dart';

/// 结构转换只移除明确停用的可空字段，不重建业务行或同步状态。
const _schema10RemovedColumns = {
  'ledgers': [('origin_last_revision', 'INTEGER')],
  'sync_state': [('last_push_at', 'INTEGER'), ('last_pull_at', 'INTEGER')],
  'sync_pull_errors': [('user_action', 'TEXT'), ('error_message', 'TEXT')],
};

/// 活动库使用单一受支持的结构升级入口，备份读取独立禁止迁移。
extension _Schema11DatabaseUpgrade on SesameDatabase {
  /// 来源校验、删列和版本提交共用事务，任何失败都恢复原结构和所有记录。
  Future<void> _upgradeSchema10Database(Migrator _, int from, int to) async {
    try {
      if (from != 10 || to != 11 || to != currentSchemaVersion) {
        throw StateError('本机数据库版本不受支持，请保留原文件并使用受支持的版本处理；当前数据未修改。');
      }
      await transaction(() async {
        await _requireColumnCleanupStructure(source: true);
        await _requireColumnCleanupIntegrity();

        // 原生 DROP COLUMN 保留行身份、其余字段、索引及触发器；依赖目标列的未知对象使事务失败。
        for (final entry in _schema10RemovedColumns.entries) {
          for (final column in entry.value) {
            await customStatement(
              'ALTER TABLE "${entry.key}" DROP COLUMN "${column.$1}"',
            );
          }
        }
        await customStatement('DROP TABLE recovery_logs');
        await customStatement('PRAGMA user_version=$to');
        await _requireColumnCleanupStructure(source: false);
        await _requireColumnCleanupIntegrity();
        final version = await customSelect('PRAGMA user_version').getSingle();
        if (version.read<int>('user_version') != to) {
          throw StateError(incompleteSchemaMessage);
        }
      });
    } catch (error, stack) {
      logger.error(
        'Database',
        '本机数据库字段清理失败：来源版本=$from，目标版本=$to',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 核验全部表、列类型、空值、默认值和主键；来源只接受声明的待删列与表。
  Future<void> _requireColumnCleanupStructure({required bool source}) async {
    try {
      final tables = (await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      ).get()).map((row) => row.read<String>('name')).toSet();
      final expectedTables = allTables
          .map((table) => table.actualTableName)
          .toSet();
      if (source) expectedTables.add('recovery_logs');
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
        final removedColumns = source ? _schema10RemovedColumns[name] : null;
        for (final removed in removedColumns ?? <(String, String)>[]) {
          expectedNames.add(removed.$1);
          final stored = actual[removed.$1];
          if (stored == null ||
              stored.read<String>('type').toUpperCase() != removed.$2 ||
              stored.read<int>('notnull') != 0 ||
              stored.readNullable<String>('dflt_value') != null ||
              stored.read<int>('pk') != 0) {
            throw StateError(incompleteSchemaMessage);
          }
        }
        if (actual.length != expectedNames.length ||
            !actual.keys.toSet().containsAll(expectedNames)) {
          throw StateError(incompleteSchemaMessage);
        }
        for (final column in table.$columns) {
          final stored = actual[column.$name]!;
          final context = GenerationContext.fromDb(
            this,
            supportsVariables: false,
          );
          final expectedType = column.type.sqlTypeName(context).toUpperCase();
          final defaultExpression = column.defaultValue;
          defaultExpression?.writeInto(context);
          final expectedDefault = defaultExpression == null
              ? null
              : context.sql;
          final actualDefault = stored.readNullable<String>('dflt_value');
          final defaultMatches =
              actualDefault == expectedDefault ||
              actualDefault != null &&
                  expectedDefault != null &&
                  (actualDefault == '($expectedDefault)' ||
                      expectedDefault == '($actualDefault)');
          if (stored.read<String>('type').toUpperCase() != expectedType ||
              stored.read<int>('notnull') != (column.$nullable ? 0 : 1) ||
              !defaultMatches ||
              (stored.read<int>('pk') > 0) !=
                  table.$primaryKey.contains(column)) {
            throw StateError(incompleteSchemaMessage);
          }
        }
      }
      if (source) await _requireRetiredRecoveryTable();
    } catch (error, stack) {
      logger.error(
        'Database',
        '本机数据库字段清理结构核验失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 待移除表必须具备完整已知列，且不能被其他表、视图或触发器依赖。
  Future<void> _requireRetiredRecoveryTable() async {
    try {
      const expected = {
        'id': ('INTEGER', 1, 1),
        'created_at': ('INTEGER', 1, 0),
        'source_backup_name': ('TEXT', 1, 0),
        'target_ledger_id': ('TEXT', 0, 0),
        'action': ('TEXT', 1, 0),
        'result': ('TEXT', 1, 0),
        'detail': ('TEXT', 0, 0),
      };
      final columns = await customSelect(
        'PRAGMA table_info(recovery_logs)',
      ).get();
      if (columns.length != expected.length) {
        throw StateError(incompleteSchemaMessage);
      }
      for (final column in columns) {
        final name = column.read<String>('name');
        final shape = expected[name];
        final defaultValue = column.readNullable<String>('dflt_value');
        if (shape == null ||
            column.read<String>('type').toUpperCase() != shape.$1 ||
            column.read<int>('notnull') != shape.$2 ||
            column.read<int>('pk') != shape.$3 ||
            (name == 'created_at'
                ? defaultValue !=
                          "CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)" &&
                      defaultValue !=
                          "(CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER))"
                : defaultValue != null)) {
          throw StateError(incompleteSchemaMessage);
        }
      }
      final dependencies = await customSelect(
        "SELECT name FROM sqlite_master WHERE sql IS NOT NULL AND "
        "((tbl_name='recovery_logs' AND type IN ('index','trigger')) OR "
        "(type IN ('trigger','view') AND lower(sql) LIKE '%recovery_logs%'))",
      ).get();
      if (dependencies.isNotEmpty) throw StateError(incompleteSchemaMessage);
      for (final table in allTables) {
        final references = await customSelect(
          'PRAGMA foreign_key_list("${table.actualTableName}")',
        ).get();
        if (references.any(
          (row) => row.read<String>('table').toLowerCase() == 'recovery_logs',
        )) {
          throw StateError(incompleteSchemaMessage);
        }
      }
    } catch (error, stack) {
      logger.error(
        'Database',
        '本机待清理表结构或依赖核验失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 删列前后均验收数据库页与外键，损坏或悬空引用不得进入已完成状态。
  Future<void> _requireColumnCleanupIntegrity() async {
    try {
      final rows = await customSelect('PRAGMA quick_check').get();
      if (rows.length != 1 ||
          rows.single.data.values.single != 'ok' ||
          (await customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
        throw StateError(incompleteSchemaMessage);
      }
    } catch (error, stack) {
      logger.error(
        'Database',
        '本机数据库字段清理完整性核验失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }
}
