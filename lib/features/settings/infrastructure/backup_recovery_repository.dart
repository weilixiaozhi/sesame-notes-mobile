/// 备份恢复只读仓库（RecoverySession 隔离区预览层）。
///
/// 设计意图：恢复预览（Step 2 账本清单/成员数/交易数）必须**零写入**——用
/// sqlite3 包以只读模式直接查询备份 sqlite，不经过 drift（drift 打开连接会
/// 执行 PRAGMA/迁移等写路径，违背只读隔离区语义）。
library;

import 'package:sqlite3/sqlite3.dart' show sqlite3, OpenMode, Database;

/// 备份库中的账本行（预览用）。
class BackupRecoveryLedgerRow {
  const BackupRecoveryLedgerRow({
    required this.id,
    required this.name,
    required this.storageMode,
    required this.syncId,
  });

  /// 账本 id（备份时的原始 id）。
  final String id;

  /// 账本名。
  final String name;

  /// 存储归属（local / cloud）。
  final String storageMode;

  /// 备份时的同步身份（仅展示/审计，绝不激活）。
  final String? syncId;
}

/// 只读访问层：所有查询均为 SELECT，任何路径都不写备份文件。
class BackupRecoveryRepository {
  BackupRecoveryRepository._(this._db);

  /// 以只读模式打开备份 sqlite（损坏文件在此抛异常，由调用方转 corrupt）。
  factory BackupRecoveryRepository.open(String path) {
    return BackupRecoveryRepository._(
      sqlite3.open(path, mode: OpenMode.readOnly),
    );
  }

  final Database _db;

  /// 列出备份中的未删除账本（按名称排序，预览稳定）。
  List<BackupRecoveryLedgerRow> listLedgers() {
    try {
      final rows = _db.select(
        'SELECT id, name, storage_mode, sync_id FROM ledgers WHERE deleted_at IS NULL ORDER BY name',
      );
      return [
        for (final row in rows)
          BackupRecoveryLedgerRow(
            id: row['id'] as String,
            name: row['name'] as String,
            storageMode: row['storage_mode'] as String,
            syncId: row['sync_id'] as String?,
          ),
      ];
    } catch (e) {
      throw StateError('备份账本列表读取失败: $e');
    }
  }

  /// 账本成员数（含生命周期状态成员——历史身份保留）。
  int countMembers(String ledgerId) {
    return _count(
      'SELECT COUNT(*) AS c FROM ledger_members WHERE ledger_id = ?1 AND deleted_at IS NULL',
      ledgerId,
    );
  }

  /// 账本交易数（未删除）。
  int countTransactions(String ledgerId) {
    return _count(
      'SELECT COUNT(*) AS c FROM transactions WHERE ledger_id = ?1 AND deleted_at IS NULL',
      ledgerId,
    );
  }

  /// 关闭只读连接（幂等）。
  void close() {
    try {
      _db.close();
    } catch (_) {
      // 已关闭/半关闭状态容错
    }
  }

  int _count(String sql, String ledgerId) {
    try {
      final rows = _db.select(sql, [ledgerId]);
      final value = rows.first['c'];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return 0;
    } catch (e) {
      throw StateError('备份统计读取失败: $e');
    }
  }
}
