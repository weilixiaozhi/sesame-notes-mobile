part of 'db.dart';

/// 已知历史升级只通过 Drift 的 onUpgrade 运行，当前版本打开不会重复转换。
extension _KnownDatabaseMigration on SesameDatabase {
  /// 结构识别、业务转换和验收在同一事务内完成，任一步失败保留原版本与原数据。
  Future<void> _migrateKnownDatabase(Migrator m, int from, int to) async {
    try {
      if (from < 4 || from >= to || to != currentSchemaVersion) {
        throw StateError('本机数据库版本不受支持，请保留原文件；当前数据未修改。');
      }
      await transaction(() async {
        await _requireMigrationColumns(from);
        if (from < 5) {
          await m.addColumn(ledgers, ledgers.ownerAccountId);
          await m.addColumn(
            sharedLedgerCategories,
            sharedLedgerCategories.deletedAt,
          );
          await _migrateSecondsColumn('shared_ledger_categories', 'updated_at');
          await customStatement(
            "UPDATE ledgers SET owner_account_id=(SELECT CASE WHEN COUNT(DISTINCT linked_account_id)=1 "
            "THEN MAX(linked_account_id) ELSE NULL END FROM ledger_members WHERE ledger_id=ledgers.id "
            "AND role='owner' AND member_type='REGISTERED' AND status='ACTIVE' AND deleted_at IS NULL) "
            "WHERE storage_mode='cloud'",
          );
          await _migrateCategoryOwnership(m);
          await m.addColumn(syncChanges, syncChanges.rejectionCode);
          // 只为已经明确拒收的行补稳定分类；未知冻结仍保持 reason=null 与原 mutation。
          await customStatement(
            "UPDATE sync_changes SET rejection_code=CASE "
            "WHEN rejection_reason='分类不可用，请重新选择分类后保存' THEN 'INVALID_CATEGORY' "
            "WHEN entity_type='category' AND rejection_reason IN "
            "('记录内容未通过服务端校验，请检查并编辑后保存','父分类不可用，请调整分类后保存') "
            "THEN 'LEGACY_CATEGORY_VALIDATION_REJECTED' ELSE 'LEGACY_VALIDATION_REJECTED' END "
            "WHERE pushed_at IS NULL AND rejection_reason IS NOT NULL",
          );
        }
        if (from < 6) await _migrateSyncQueueTime();
        if (from < 7) {
          await customStatement(
            'ALTER TABLE transactions DROP COLUMN exclude_from_stats',
          );
        }
        if (from < 8) {
          for (final table in [
            'ledgers',
            'recurring_transactions',
            'exchange_rate_overrides',
          ]) {
            await _migrateSecondsColumn(table, 'updated_at');
            await _migrateSecondsColumn(table, 'deleted_at');
          }
        }
        if (from < 9) await _migrateDomainCursors(m);
        if (from < 10) {
          await _migrateSecondsColumn('ledger_members', 'updated_at');
        }
        // 将版本号与结构共同提交，避免进程中断后留下新结构配旧版本号。
        await customStatement('PRAGMA user_version=$to');
        // 验收必须在提交之前；beforeOpen 仅再次确认当前结构并开启外键。
        await _requireMigrationColumns(to);
        final version = await customSelect('PRAGMA user_version').getSingle();
        if (version.read<int>('user_version') != to) {
          throw StateError(incompleteSchemaMessage);
        }
        if ((await customSelect('PRAGMA foreign_key_check').get()).isNotEmpty) {
          throw StateError(incompleteSchemaMessage);
        }
      });
    } catch (error, stack) {
      logger.error(
        'Database',
        '本机数据库升级失败：来源版本=$from，目标版本=$to',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 从当前表定义反推出已知历史列差异，未知列、缺表或伪装版本均在写入前拒绝。
  Future<void> _requireMigrationColumns(int version) async {
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
      final expected = table.$columns.map((column) => column.$name).toSet();
      if (version < 5) {
        if (name == 'ledgers') expected.remove('owner_account_id');
        if (name == 'shared_ledger_categories') expected.remove('deleted_at');
        if (name == 'categories') {
          expected.removeAll(['cloud_registered', 'observed_cloud_state']);
        }
        if (name == 'sync_changes') expected.remove('rejection_code');
      }
      if (version < 7 && name == 'transactions') {
        expected.add('exclude_from_stats');
      }
      final columns = await customSelect('PRAGMA table_info("$name")').get();
      final actual = columns
          .map((column) => column.read<String>('name'))
          .toSet();
      if (actual.length != expected.length || !actual.containsAll(expected)) {
        throw StateError(incompleteSchemaMessage);
      }
      if (version >= 9 && name == 'sync_state') {
        final cursor = columns.singleWhere(
          (column) => column.read<String>('name') == 'server_cursor',
        );
        if (cursor.read<int>('notnull') != 0 ||
            cursor.data['dflt_value'] != null) {
          throw StateError(incompleteSchemaMessage);
        }
      }
    }
  }

  /// 已知秒列转换为毫秒；超范围或非整数时间必须使整次升级回滚。
  Future<void> _migrateSecondsColumn(String table, String column) async {
    final invalid = await customSelect(
      'SELECT 1 FROM $table WHERE $column IS NOT NULL AND '
      '(typeof($column)!=\'integer\' OR $column < -62135596800 OR $column > 253402300799) LIMIT 1',
    ).get();
    if (invalid.isNotEmpty) throw StateError('本机记录时间无法安全升级，请保留原文件；当前数据未修改。');
    await customStatement(
      'UPDATE $table SET $column=$column*1000 WHERE $column IS NOT NULL',
    );
  }

  /// 仅转换队列时钟；任何正文、冻结请求、mutation、基线和现有拒收状态保持原值。
  Future<void> _migrateSyncQueueTime() async {
    var lastId = 0;
    while (true) {
      final rows = await customSelect(
        'SELECT id,updated_at,entity_type,entity_id,mutation_id,action,payload,frozen_request,'
        'ledger_id,day_book_id,memo_book_id,fitness_space_id FROM sync_changes WHERE id>? ORDER BY id LIMIT 256',
        variables: [Variable.withInt(lastId)],
      ).get();
      if (rows.isEmpty) break;
      for (final row in rows) {
        final id = row.read<int>('id');
        final timestamp = legacySyncQueueMilliseconds(
          queueId: id,
          seconds: row.read<int>('updated_at'),
          entityType: row.read<String>('entity_type'),
          entityId: row.read<String>('entity_id'),
          mutationId: row.read<String>('mutation_id'),
          action: row.read<String>('action'),
          payload: row.read<String>('payload'),
          frozenRequest: row.readNullable<String>('frozen_request'),
          scopes: {
            for (final key in [
              'ledger_id',
              'day_book_id',
              'memo_book_id',
              'fitness_space_id',
            ])
              key: row.readNullable<String>(key),
          },
        );
        await customStatement(
          'UPDATE sync_changes SET updated_at=? WHERE id=?',
          [timestamp, id],
        );
        lastId = id;
      }
    }
  }

  /// 分类升级为账号复合身份，本地账本的已有引用复制到独立本地域并保留祖先链。
  Future<void> _migrateCategoryOwnership(Migrator m) async {
    await customStatement('DROP INDEX IF EXISTS idx_categories_parent_id');
    await customStatement('DROP INDEX IF EXISTS idx_categories_scope_parent');
    await customStatement(
      'ALTER TABLE categories RENAME TO categories_migration',
    );
    await m.createTable(categories);
    await _migrateSecondsColumn('categories_migration', 'updated_at');
    await _migrateSecondsColumn('categories_migration', 'deleted_at');
    const fields =
        'id,name,kind,level,sort_order,icon,parent_id,scope_account_id,server_version_token,cloud_registered,updated_at,deleted_at';
    await customStatement(
      'INSERT INTO categories ($fields) SELECT id,name,kind,level,sort_order,icon,parent_id,'
      "COALESCE(scope_account_id,''),server_version_token,CASE WHEN scope_account_id IS NOT NULL AND server_version_token IS NOT NULL THEN 1 ELSE 0 END,updated_at,deleted_at FROM categories_migration",
    );
    await customStatement(
      'WITH RECURSIVE referenced(id) AS ('
      'SELECT t.category_id FROM transactions t JOIN ledgers l ON l.id=t.ledger_id '
      "WHERE l.storage_mode='local' AND t.category_id IS NOT NULL UNION "
      'SELECT r.category_id FROM recurring_transactions r JOIN ledgers l ON l.id=r.ledger_id '
      "WHERE l.storage_mode='local' AND r.category_id IS NOT NULL UNION "
      'SELECT c.parent_id FROM categories_migration c JOIN referenced r ON r.id=c.id WHERE c.parent_id IS NOT NULL) '
      'INSERT OR IGNORE INTO categories ($fields) SELECT c.id,c.name,c.kind,c.level,c.sort_order,c.icon,c.parent_id,'
      "'',NULL,0,c.updated_at,c.deleted_at FROM categories_migration c JOIN referenced r ON r.id=c.id",
    );
    await customStatement('DROP TABLE categories_migration');
    await _createCategoryIndexes();
  }

  /// 水位空值表示该域仍需完整快照，原账号、设备和最后推拉时间保持不变。
  Future<void> _migrateDomainCursors(Migrator m) async {
    await customStatement(
      'ALTER TABLE sync_state RENAME TO sync_state_migration',
    );
    await m.createTable(syncState);
    await customStatement(
      'INSERT INTO sync_state(account_id,device_id,last_push_at,last_pull_at) '
      'SELECT account_id,device_id,last_push_at,last_pull_at FROM sync_state_migration',
    );
    await customStatement('DROP TABLE sync_state_migration');
  }
}
