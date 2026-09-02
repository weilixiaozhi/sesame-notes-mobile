import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';

/// ChangeRecorder 端口实现：把仓储登记的变更写入 sync_changes 表，
/// 由 [SyncService] 消费并推送到服务端。
///
/// 3.3：transaction 变更记录时计算 base_revision（乐观并发基线）——
/// 同一实体存在未推送 mutation 时链式延续（前序 base+1），否则取实体
/// 当前的 server_revision；本地账本/新建交易无服务端版本 → 不写（服务端按 CREATE）。
class ChangeRecorderImpl implements ChangeRecorder {
  final SesameDatabase db;

  /// 当前账号 id（登录后由装配层注入）；null = 未登录/纯本地编辑（不推送）。
  final String? Function()? accountIdGetter;

  ChangeRecorderImpl(this.db, {this.accountIdGetter});

  /// 当前归属账号（写入 sync_changes.account_id 的数据域标记）。
  String? get _accountId => accountIdGetter?.call();

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => db
      .into(db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: entityType,
          entityId: entityId,
          action: action,
          payload: payload,
          updatedAt: updatedAt,
          mutationId: const Uuid().v4(),
          accountId: d.Value(_accountId),
        ),
      );

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            ledgerId: d.Value(ledgerId),
            action: action,
            payload: payload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
            baseRevision: d.Value(
              await _nextBaseRevision(entityType, entityId),
            ),
            accountId: d.Value(_accountId),
          ),
        );
  }

  @override
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes}) =>
      db.batch((b) async {
        for (final ch in changes) {
          b.insert(
            db.syncChanges,
            SyncChangesCompanion.insert(
              entityType: ch.entityType,
              entityId: ch.entityId,
              ledgerId: d.Value(ch.ledgerId),
              action: ch.action,
              payload: ch.payload,
              updatedAt: ch.updatedAt,
              mutationId: const Uuid().v4(),
              baseRevision: d.Value(
                await _nextBaseRevision(ch.entityType, ch.entityId),
              ),
              accountId: d.Value(_accountId),
            ),
          );
        }
      });

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) => db.batch((b) {
    for (final ch in changes) {
      b.insert(
        db.syncChanges,
        SyncChangesCompanion.insert(
          entityType: ch.entityType,
          entityId: ch.entityId,
          action: ch.action,
          payload: ch.payload,
          updatedAt: ch.updatedAt,
          mutationId: const Uuid().v4(),
          accountId: d.Value(_accountId),
        ),
      );
    }
  });

  /// 计算下一次变更的 base_revision（仅 transaction 参与 revision 状态机）：
  /// - 同实体存在未推送 mutation → 链尾 base+1（FIFO，前序冲突时后序自然失效）；
  /// - 否则取实体 server_revision；
  /// - 本地账本/新建交易（server_revision 为空）→ 返回 null（服务端按 CREATE 处理）。
  Future<int?> _nextBaseRevision(String entityType, String entityId) async {
    if (entityType != 'transaction') return null;
    final chainTail =
        await (db.select(db.syncChanges)
              ..where(
                (c) =>
                    c.entityType.equals('transaction') &
                    c.entityId.equals(entityId) &
                    c.pushedAt.isNull(),
              )
              ..orderBy([(t) => d.OrderingTerm.desc(t.id)])
              ..limit(1))
            .getSingleOrNull();
    if (chainTail != null) {
      // 链尾 base 为 null = CREATE 语义（服务端期望实体不存在 → revision 1），
      // 链上后续 mutation 按预期 revision 递增（服务端串行处理后恰好匹配）
      final tailBase = chainTail.baseRevision;
      return tailBase == null ? 1 : tailBase + 1;
    }
    final row = await (db.select(
      db.transactions,
    )..where((t) => t.id.equals(entityId))).getSingleOrNull();
    return row?.serverRevision;
  }
}
