import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/ledger_directory_member.dart';

import 'local_accounting_context.dart';

/// member 数据能力的具体实现，与其他能力共享当前事务上下文。
mixin LocalMemberOperations on LocalAccountingContext {
  /// 提供 watchMembersByLedger 对应的持久化能力。
  @override
  Stream<List<LedgerMember>> watchMembersByLedger(String ledgerId) =>
      memberStore.watchByLedger(ledgerId);

  /// 提供 getMembersByLedger 对应的持久化能力。
  @override
  Future<List<LedgerMember>> getMembersByLedger(String ledgerId) =>
      memberStore.getByLedger(ledgerId);

  /// 提供 getMemberById 对应的持久化能力。
  @override
  Future<LedgerMember?> getMemberById(String id) => memberStore.getById(id);

  /// 提供 ensureLocalSelfMember 对应的持久化能力。
  Future<LedgerMember> ensureLocalSelfMember({
    required String ledgerId,
    required String localSelfId,
    required String displayName,
  }) => memberStore.ensureLocalSelf(
    ledgerId: ledgerId,
    localSelfId: localSelfId,
    displayName: displayName,
  );

  /// 提供 createPlaceholderMember 对应的持久化能力。
  @override
  Future<String> createPlaceholderMember({
    required String ledgerId,
    required String name,
    String? id,
  }) => memberStore.createPlaceholder(ledgerId: ledgerId, name: name, id: id);

  /// 提供 renameMember 对应的持久化能力。
  @override
  Future<void> renameMember({required String id, required String name}) =>
      memberStore.rename(id: id, name: name);

  /// 提供 deleteMember 对应的持久化能力。
  @override
  Future<bool> deleteMember(String id) => memberStore.delete(id);

  /// 本人更新云 Profile 后刷新同账号 REGISTERED 成员展示快照。
  @override
  Future<int> refreshMemberDisplayByAccount({
    required String userId,
    required String? displayName,
    required String? avatarUrl,
    required int avatarVersion,
  }) => memberStore.refreshDisplayByAccount(
    userId: userId,
    displayName: displayName,
    avatarUrl: avatarUrl,
    avatarVersion: avatarVersion,
  );

  /// 成员目录 REST 快照落库(公开资料镜像,不改变生命周期)。
  @override
  Future<void> applyMemberDirectorySnapshot({
    required String ledgerId,
    required List<LedgerDirectoryMember> members,
  }) =>
      memberStore.applyDirectorySnapshot(ledgerId: ledgerId, members: members);

  /// 提供 updateMemberStatus 对应的持久化能力。
  @override
  Future<void> updateMemberStatus({
    required String ledgerId,
    required String accountId,
    required String status,
  }) => memberStore.updateStatus(
    ledgerId: ledgerId,
    accountId: accountId,
    status: status,
  );
}
