import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/utils/member_id.dart';

/// 账本成员仓储（LedgerMember 单轨模型）。
///
/// 设计意图：成员是账务数据的引用锚点（created_by / payer / split），
/// 本仓储负责成员的创建、绑定与生命周期维护：
/// - LOCAL：本地账本「我」，id 由 uuidV5(ledgerId, localSelfId) 派生，
///   登录后绑定 linked_account_id、退出解绑，身份本身不变；
/// - REGISTERED：已绑定云端账号的成员，id 由 uuidV5(ledgerId, userId)
///   派生，数据来自服务端成员接口（本端只做镜像，不登记同步变更）；
/// - PLACEHOLDER：占位成员（原虚拟用户），id 即虚拟用户 UUID，
///   变更以 virtual_user 实体进同步通道。
class LocalLedgerMemberRepository {
  final SesameDatabase db;

  /// 写事务中获取变更登记器，避免构造顺序形成循环依赖（与账本仓储同模式）。
  final ChangeRecorder? Function()? trackerGetter;

  LocalLedgerMemberRepository(this.db, {this.trackerGetter});

  static const _uuid = Uuid();

  Stream<List<LedgerMember>> watchByLedger(String ledgerId) {
    return (db.select(db.ledgerMembers)
          ..where(
            (member) =>
                member.ledgerId.equals(ledgerId) & member.deletedAt.isNull(),
          )
          ..orderBy([
            (t) => d.OrderingTerm(expression: t.id, mode: d.OrderingMode.asc),
          ]))
        .watch();
  }

  Future<List<LedgerMember>> getByLedger(String ledgerId) async {
    return await (db.select(db.ledgerMembers)
          ..where(
            (member) =>
                member.ledgerId.equals(ledgerId) & member.deletedAt.isNull(),
          )
          ..orderBy([
            (t) => d.OrderingTerm(expression: t.id, mode: d.OrderingMode.asc),
          ]))
        .get();
  }

  Future<LedgerMember?> getById(String id) async {
    return await (db.select(db.ledgerMembers)
          ..where((member) => member.id.equals(id) & member.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// 按绑定账号查找成员（REGISTERED 成员的 linked_account_id 索引）。
  Future<LedgerMember?> getByLinkedAccount(
    String ledgerId,
    String accountId,
  ) async {
    return await (db.select(db.ledgerMembers)..where(
          (t) =>
              t.ledgerId.equals(ledgerId) &
              t.linkedAccountId.equals(accountId) &
              t.deletedAt.isNull(),
        ))
        .getSingleOrNull();
  }

  /// 确保 LOCAL self 成员存在（确定性派生 id，可重入）。
  ///
  /// 首次调用创建「我」成员；登录绑定账号只是更新 linked_account_id，
  /// 不重建成员、不改历史引用。
  Future<LedgerMember> ensureLocalSelf({
    required String ledgerId,
    required String localSelfId,
    required String displayName,
  }) async {
    final id = localSelfMemberId(ledgerId, localSelfId);
    final existing = await getById(id);
    if (existing != null) return existing;
    final now = DateTime.now().toUtc();
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName: displayName,
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: now,
          ),
        );
    return (await getById(id))!;
  }

  /// 确保 REGISTERED 成员存在（服务端成员镜像，不登记同步变更）。
  ///
  /// 同一账本同一账号永远映射到同一 member_id；displayName 等资料随
  /// 服务端最新值覆盖，历史账务引用不受影响。
  Future<LedgerMember> ensureRegistered({
    required String ledgerId,
    required String userId,
    required String displayName,
    String role = 'editor',
    String? avatarUrl,
    int avatarVersion = 0,
  }) async {
    final id = registeredMemberId(ledgerId, userId);
    final now = DateTime.now().toUtc();
    await db
        .into(db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName: displayName,
            memberType: 'REGISTERED',
            linkedAccountId: d.Value(userId),
            role: d.Value(role),
            avatarUrl: d.Value(avatarUrl),
            avatarVersion: d.Value(avatarVersion),
            status: const d.Value('ACTIVE'),
            updatedAt: now,
            deletedAt: const d.Value(null),
          ),
        );
    return (await getById(id))!;
  }

  /// 新建 PLACEHOLDER 成员（本地创建虚拟用户）；[id] 缺省时生成 UUID。
  ///
  /// 与虚拟用户旧语义一致：id 即同步实体 id，云端接受同一 id。
  Future<String> createPlaceholder({
    required String ledgerId,
    required String name,
    String? id,
  }) async {
    try {
      final effectiveId = id ?? _uuid.v4();
      final now = DateTime.now().toUtc();
      await db.transaction(() async {
        await db
            .into(db.ledgerMembers)
            .insert(
              LedgerMembersCompanion.insert(
                id: effectiveId,
                ledgerId: ledgerId,
                displayName: name,
                memberType: 'PLACEHOLDER',
                updatedAt: now,
              ),
            );
        final row = await getById(effectiveId);
        if (row != null) {
          await _recordChange(row: row, action: 'upsert');
        }
      });
      return effectiveId;
    } catch (error, stackTrace) {
      logger.error(
        'LocalLedgerMemberRepository',
        '创建占位成员失败 ledgerId=$ledgerId',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  /// PLACEHOLDER 成员 upsert（同步 pull 虚拟用户实体时落库）。
  Future<void> upsertPlaceholder({
    required String ledgerId,
    required String id,
    required String name,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName: name,
            memberType: 'PLACEHOLDER',
            status: const d.Value('ACTIVE'),
            updatedAt: updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 重命名成员（PLACEHOLDER 与 LOCAL 支持；REGISTERED 由服务端权威）。
  Future<void> rename({required String id, required String name}) async {
    try {
      await db.transaction(() async {
        await (db.update(db.ledgerMembers)..where(
              (member) => member.id.equals(id) & member.deletedAt.isNull(),
            ))
            .write(
              LedgerMembersCompanion(
                displayName: d.Value(name),
                updatedAt: d.Value(DateTime.now().toUtc()),
              ),
            );
        final row = await getById(id);
        if (row != null && row.memberType == 'PLACEHOLDER') {
          await _recordChange(row: row, action: 'upsert');
        }
      });
    } catch (error, stackTrace) {
      logger.error(
        'LocalLedgerMemberRepository',
        '重命名成员失败 id=$id',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 删除成员：PLACEHOLDER 被交易引用时禁止（与虚拟用户旧语义一致）。
  ///
  /// 真实成员（LOCAL/REGISTERED）永远不删除——历史账务引用它们；
  /// 生命周期用 status（LEFT/REMOVED）表达。
  Future<bool> delete(String id) async {
    try {
      final row = await getById(id);
      if (row == null) return false;
      if (row.memberType != 'PLACEHOLDER') {
        throw StateError('真实成员(id=$id)不可删除，应使用状态迁移');
      }
      final referenced = await isReferencedByAnyTransaction(id);
      if (referenced) {
        throw StateError('成员(id=$id)被交易的 AA 分摊引用,不允许删除');
      }
      return await db.transaction(() async {
        final n = await (db.delete(
          db.ledgerMembers,
        )..where((t) => t.id.equals(id))).go();
        if (n > 0) {
          // tombstone 语义：payload 带删除时刻 updatedAt，云端按事件时间裁决。
          await _recordChange(
            row: row.copyWith(updatedAt: DateTime.now().toUtc()),
            action: 'delete',
          );
        }
        return n > 0;
      });
    } catch (error, stackTrace) {
      logger.error(
        'LocalLedgerMemberRepository',
        '删除成员失败 id=$id',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  /// 登录绑定：把本账本 LOCAL self 成员绑定到云账号（不重建、不改历史）。
  Future<void> bindLocalSelf({
    required String ledgerId,
    required String localSelfId,
    required String accountId,
  }) async {
    final member = await ensureLocalSelf(
      ledgerId: ledgerId,
      localSelfId: localSelfId,
      displayName: '',
    );
    await (db.update(
      db.ledgerMembers,
    )..where((t) => t.id.equals(member.id))).write(
      LedgerMembersCompanion(
        linkedAccountId: d.Value(accountId),
        updatedAt: d.Value(DateTime.now().toUtc()),
      ),
    );
  }

  /// 退出登录解绑：本机全部 LOCAL 成员的绑定关系清除（身份保留）。
  Future<void> unbindAllLocalMembers() async {
    await (db.update(db.ledgerMembers)..where(
          (member) =>
              member.memberType.equals('LOCAL') & member.deletedAt.isNull(),
        ))
        .write(
          LedgerMembersCompanion(
            linkedAccountId: const d.Value(null),
            updatedAt: d.Value(DateTime.now().toUtc()),
          ),
        );
  }

  /// 成员状态迁移（LEFT/REMOVED）：历史账务保留，仅停止新权限语义。
  Future<void> updateStatus({
    required String ledgerId,
    required String accountId,
    required String status,
  }) async {
    final member = await getByLinkedAccount(ledgerId, accountId);
    if (member == null) return;
    await (db.update(
      db.ledgerMembers,
    )..where((t) => t.id.equals(member.id))).write(
      LedgerMembersCompanion(
        status: d.Value(status),
        updatedAt: d.Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<bool> isReferencedByAnyTransaction(String memberId) async {
    // 付款人列与分摊关系都可能引用成员；只看活跃交易，避免交易 tombstone
    // 永久阻止已无业务引用的占位成员删除。
    final row = await db
        .customSelect(
          '''
          SELECT COUNT(*) AS c
          FROM transactions t
          WHERE t.deleted_at IS NULL
            AND (
              t.payer_member_id = ?1
              OR EXISTS (
                SELECT 1
                FROM transaction_splits s
                WHERE s.transaction_id = t.id AND s.member_id = ?1
              )
            )
          ''',
          variables: [d.Variable.withString(memberId)],
          readsFrom: {db.transactions, db.transactionSplits},
        )
        .getSingle();
    final v = row.data['c'];
    if (v is int) return v > 0;
    if (v is BigInt) return v.toInt() > 0;
    if (v is num) return v > 0;
    return false;
  }

  /// §13.4:本人更新云 Profile 后,刷新本地所有账本中绑定该账号的
  /// REGISTERED 成员展示快照(昵称/头像)。
  ///
  /// 只写展示字段,不触碰 updatedAt 与同步通道:成员行是服务端镜像,
  /// 资料刷新不产生 sync mutation,也不影响服务端事件的 LWW 裁决。
  Future<int> refreshDisplayByAccount({
    required String userId,
    required String? displayName,
    required String? avatarUrl,
    required int avatarVersion,
  }) async {
    final name = displayName?.trim() ?? '';
    // 昵称恒非空(注册即分配);空值防御性跳过,避免覆盖已有昵称。
    final fields = name.isNotEmpty
        ? LedgerMembersCompanion(
            displayName: d.Value(name),
            avatarUrl: d.Value(avatarUrl),
            avatarVersion: d.Value(avatarVersion),
          )
        : LedgerMembersCompanion(
            avatarUrl: d.Value(avatarUrl),
            avatarVersion: d.Value(avatarVersion),
          );
    return (db.update(db.ledgerMembers)..where(
          (member) =>
              member.linkedAccountId.equals(userId) &
              member.memberType.equals('REGISTERED') &
              member.deletedAt.isNull(),
        ))
        .write(fields);
  }

  /// 成员目录 REST 快照落库(§13.4 后半句):服务端成员列表接口返回的
  /// 公开资料覆盖本地 REGISTERED 成员展示字段。
  ///
  /// 只镜像展示资料,不改变成员生命周期、不登记同步变更;远端已有而
  /// 本地缺失的成员补一行镜像,缺失的本地行保留(生命周期以同步为准)。
  Future<void> applyDirectorySnapshot({
    required String ledgerId,
    required List<LedgerDirectoryMember> members,
  }) async {
    for (final m in members) {
      final existing = await getById(m.memberId);
      final displayName = m.displayName.trim().isNotEmpty
          ? m.displayName
          : existing?.displayName ?? '';
      if (existing == null) {
        await db
            .into(db.ledgerMembers)
            .insert(
              LedgerMembersCompanion.insert(
                id: m.memberId,
                ledgerId: ledgerId,
                displayName: displayName,
                memberType: 'REGISTERED',
                linkedAccountId: d.Value(m.linkedAccountId),
                role: d.Value(m.role),
                status: d.Value(m.status),
                avatarUrl: d.Value(m.avatarUrl),
                avatarVersion: d.Value(m.avatarVersion),
                joinedAt: d.Value(m.joinedAt),
                updatedAt: m.joinedAt,
              ),
            );
      } else {
        await (db.update(db.ledgerMembers)..where(
              (row) => row.id.equals(m.memberId),
            ))
            .write(
              LedgerMembersCompanion(
                displayName: d.Value(displayName),
                linkedAccountId: d.Value(m.linkedAccountId),
                role: d.Value(m.role),
                status: d.Value(m.status),
                avatarUrl: d.Value(m.avatarUrl),
                avatarVersion: d.Value(m.avatarVersion),
              ),
            );
      }
    }
  }

  // ---------------------------------------------------------------
  // 变更登记（PLACEHOLDER 成员以 member 实体进同步通道）
  // ---------------------------------------------------------------

  Future<void> _recordChange({
    required LedgerMember row,
    required String action,
  }) async {
    final tracker = trackerGetter?.call();
    if (tracker == null) return;
    if (row.memberType != 'PLACEHOLDER') return;
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(row.ledgerId))).getSingleOrNull();
    if (ledger == null || ledger.storageMode != 'cloud') return;
    await tracker.recordLedgerChange(
      entityType: 'member',
      entityId: row.id,
      ledgerId: row.ledgerId,
      action: action,
      payload: placeholderPayload(row),
      updatedAt: row.updatedAt,
    );
  }
}

/// 构造契约形状的 member payload（与 push 侧生成模型 wire name 对齐）。
String placeholderPayload(LedgerMember m) {
  return jsonEncode({'display_name': m.displayName});
}

/// 成员目录 REST 快照条目(§13.4):服务端成员列表接口公开资料的最小形状。
class LedgerDirectoryMember {
  const LedgerDirectoryMember({
    required this.memberId,
    required this.displayName,
    this.linkedAccountId,
    required this.role,
    required this.status,
    this.avatarUrl,
    required this.avatarVersion,
    required this.joinedAt,
  });

  /// 服务端权威 member id(账本内 canonical 成员标识)。
  final String memberId;

  /// 公开昵称(恒非空:账号注册即分配)。
  final String displayName;

  /// 绑定账号 userId(仅 REGISTERED 成员有)。
  final String? linkedAccountId;

  /// 账本内角色:owner/editor。
  final String role;

  /// 成员生命周期:ACTIVE/LEFT/REMOVED。
  final String status;

  /// 头像 URL(服务端相对路径由服务层归一化为绝对地址)。
  final String? avatarUrl;

  /// 头像版本号(本地缓存键)。
  final int avatarVersion;

  /// 加入时间。
  final DateTime joinedAt;
}
