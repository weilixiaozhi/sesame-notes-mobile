import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// ChangeRecorder 端口实现：把仓储登记的变更写入 sync_changes 表，
/// 由 [SyncService] 消费并推送到服务端。
///
/// transaction 变更记录时计算 base_revision（乐观并发基线）：
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
  Future<void> recordFitnessChange({
    required String entityType,
    required String entityId,
    required String fitnessSpaceId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) => db.transaction(() async {
    if (_accountId != accountId) throw StateError('FITNESS_SESSION_CHANGED');
    final space = await (db.select(
      db.fitnessSpaces,
    )..where((b) => b.id.equals(fitnessSpaceId))).getSingle();
    if (space.storageMode != 'cloud' ||
        space.scopeAccountId != accountId ||
        space.isStale) {
      throw StateError('FITNESS_SCOPE_CHANGED');
    }
    if (entityType != 'fitness_space') {
      final entity = await (db.select(
        db.fitnessEntities,
      )..where((e) => e.id.equals(entityId))).getSingle();
      if (entity.fitnessSpaceId != fitnessSpaceId ||
          entity.entityType != entityType) {
        throw StateError('FITNESS_SCOPE_CHANGED');
      }
    }
    await _enqueue(
      entityType: entityType,
      entityId: entityId,
      accountId: accountId,
      fitnessSpaceId: fitnessSpaceId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
      baseRevision: () async => baseRevision,
      coalesce: true,
    );
    if (_accountId != accountId) throw StateError('FITNESS_SESSION_CHANGED');
  });

  /// 只合并从未发送的完整版本，冻结请求保持不可变。
  @override
  Future<void> recordMemoChange({
    required String entityType,
    required String entityId,
    required String memoBookId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) async {
    if (_accountId != accountId) throw StateError('MEMO_SESSION_CHANGED');
    final book = await (db.select(
      db.memoBooks,
    )..where((b) => b.id.equals(memoBookId))).getSingle();
    if (book.storageMode != 'cloud' || book.scopeAccountId != accountId) {
      throw StateError('MEMO_SCOPE_CHANGED');
    }
    await _enqueue(
      entityType: entityType,
      entityId: entityId,
      accountId: accountId,
      memoBookId: memoBookId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
      baseRevision: () async => baseRevision,
      coalesce: true,
    );
    if (_accountId != accountId) throw StateError('MEMO_SESSION_CHANGED');
  }

  /// 日子写入先校验会话和父本，再登记独立 FIFO；事务由调用方覆盖业务行。
  @override
  Future<void> recordDayChange({
    required String entityType,
    required String entityId,
    required String dayBookId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) async {
    try {
      if (_accountId != accountId) throw StateError('账号已变化，请重新打开后重试');
      final book = await (db.select(
        db.dayBooks,
      )..where((b) => b.id.equals(dayBookId))).getSingle();
      if (book.scopeAccountId != accountId || book.storageMode != 'cloud') {
        throw StateError('日子本归属已变化，请刷新后重试');
      }
      await _enqueue(
        entityType: entityType,
        entityId: entityId,
        accountId: accountId,
        dayBookId: dayBookId,
        action: action,
        payload: payload,
        updatedAt: updatedAt,
        baseRevision: () async => baseRevision,
      );
    } catch (error) {
      // 中间层只保留实体上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error(
        'ChangeRecorder',
        '登记日子变更失败: $entityType/$entityId',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => _record((
    entityType: entityType,
    entityId: entityId,
    ledgerId: null,
    action: action,
    payload: payload,
    updatedAt: updatedAt,
  ));

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => _record((
    entityType: entityType,
    entityId: entityId,
    ledgerId: ledgerId,
    action: action,
    payload: payload,
    updatedAt: updatedAt,
  ));

  @override
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes}) =>
      _recordChanges(changes);

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) => _recordChanges(changes);

  /// 批量登记在同一事务内按顺序落库，后续变更从已落库的链尾计算 revision。
  Future<void> _recordChanges(List<SyncChangeRecord> changes) async {
    try {
      await db.transaction(() async {
        for (final change in changes) {
          await _record(change);
        }
      });
    } catch (error) {
      // 中间层只保留批量上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error('ChangeRecorder', '批量登记本地变更失败，已回滚', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 本地修正沿用实体的原始因果基线，未知请求仍保持原有幂等身份。
  Future<void> _record(SyncChangeRecord change) async {
    try {
      final accountId = _accountId;
      await _enqueue(
        entityType: change.entityType,
        entityId: change.entityId,
        accountId: accountId,
        ledgerId: change.ledgerId,
        action: change.action,
        payload: change.payload,
        updatedAt: change.updatedAt,
        baseRevision: () =>
            _nextBaseRevision(change.entityType, change.entityId, accountId),
      );
    } catch (error) {
      // 中间层只保留实体上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error(
        'ChangeRecorder',
        '登记本地变更失败: ${change.entityType}/${change.entityId}',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 全局 outbox 写规则：只替换已明确拒绝的链，绝不改写结果未知的冻结请求。
  Future<void> _enqueue({
    required String entityType,
    required String entityId,
    required String? accountId,
    String? ledgerId,
    String? dayBookId,
    String? memoBookId,
    String? fitnessSpaceId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required Future<int?> Function() baseRevision,
    bool coalesce = false,
  }) => db.transaction(() async {
    d.Expression<bool> pending(SyncChanges c) =>
        c.entityType.equals(entityType) &
        c.entityId.equals(entityId) &
        c.pushedAt.isNull() &
        (accountId == null
            ? c.accountId.isNull()
            : c.accountId.equals(accountId));
    var queued =
        await (db.select(db.syncChanges)
              ..where(pending)
              ..orderBy([(c) => d.OrderingTerm.desc(c.id)]))
            .get();
    var effectivePayload = payload;
    // 冻结请求的执行结果未知时，整条链仍需保留；编辑只能排在其后。
    // 全链没有未知请求才可用新的幂等键替换明确拒收及未发送的后继。
    final replaceRejectedChain =
        queued.any((c) => c.rejectionReason != null) &&
        !queued.any(
          (c) => c.frozenRequest != null && c.rejectionReason == null,
        );
    final originalBaseRevision = replaceRejectedChain
        ? queued.last.baseRevision
        : null;
    if (replaceRejectedChain) {
      // 仅恢复原已登记且明确拒收的首次历史意图；绝不从普通编辑推导授权。
      // 云端 UUID 若已存在，首次创建门禁仍会拒绝，不能降级普通 upsert 复活身份。
      if (action == 'upsert' &&
          (entityType == 'member' || entityType == 'transaction')) {
        final first = queued.last;
        if (first.action == 'upsert' && first.rejectionReason != null) {
          final original = jsonDecode(first.payload) as Map<String, dynamic>;
          final key = entityType == 'member'
              ? 'initial_status'
              : 'initial_history';
          if (original.containsKey(key)) {
            final acknowledged =
                await (db.select(db.syncChanges)
                      ..where(
                        (row) =>
                            row.entityType.equals(entityType) &
                            row.entityId.equals(entityId) &
                            row.pushedAt.isNotNull() &
                            (accountId == null
                                ? row.accountId.isNull()
                                : row.accountId.equals(accountId)),
                      )
                      ..limit(1))
                    .getSingleOrNull();
            if (acknowledged == null) {
              effectivePayload = jsonEncode({
                ...jsonDecode(payload) as Map<String, dynamic>,
                key: original[key],
              });
            }
          }
        }
      }
      await (db.delete(db.syncChanges)..where(pending)).go();
      queued = [];
    }
    if (coalesce &&
        queued.isNotEmpty &&
        queued.first.frozenRequest == null &&
        queued.first.rejectionReason == null &&
        queued.first.action == action) {
      await (db.update(
        db.syncChanges,
      )..where((c) => c.id.equals(queued.first.id))).write(
        SyncChangesCompanion(
          payload: d.Value(effectivePayload),
          updatedAt: d.Value(updatedAt),
        ),
      );
      return;
    }
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            accountId: d.Value(accountId),
            ledgerId: d.Value(ledgerId),
            dayBookId: d.Value(dayBookId),
            memoBookId: d.Value(memoBookId),
            fitnessSpaceId: d.Value(fitnessSpaceId),
            action: action,
            payload: effectivePayload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
            // 拒收没有提交云端修改，修正不能借当前快照抬高原并发基线。
            baseRevision: d.Value(
              replaceRejectedChain
                  ? originalBaseRevision
                  : await baseRevision(),
            ),
          ),
        );
  });

  /// 计算下一次变更的 base_revision（仅 transaction 参与 revision 状态机）：
  /// - 同实体存在未推送 mutation → 链尾 base+1（FIFO，前序冲突时后序自然失效）；
  /// - 否则取实体 server_revision；
  /// - 本地账本/新建交易（server_revision 为空）→ 返回 null（服务端按 CREATE 处理）。
  Future<int?> _nextBaseRevision(
    String entityType,
    String entityId,
    String? accountId,
  ) async {
    if (entityType != 'transaction') return null;
    final chainTail =
        await (db.select(db.syncChanges)
              ..where(
                (c) =>
                    c.entityType.equals('transaction') &
                    c.entityId.equals(entityId) &
                    c.pushedAt.isNull() &
                    (accountId == null
                        ? c.accountId.isNull()
                        : c.accountId.equals(accountId)),
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
