import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/ledger_kind.dart';

/// 账本业务快照的归属与可访问性判定。
extension LedgerKindX on LedgerSnapshot {
  /// 是否为共享账本:成员数 > 1(共享性以 member_count 表达;
  /// Owner 单人账本 member_count == 1)。
  bool get isShared => memberCount > 1;

  /// 是否为云端账本(参与被动同步、退出登录时被清理)。
  bool get isCloudLedger => isCloudLedgerOf(storageMode, isShared: isShared);

  /// 是否为本地账本(纯本地,不参与被动同步)。
  bool get isLocalLedger => isLocalLedgerOf(storageMode, isShared: isShared);

  /// 前台只能访问本机本与当前登录账号的云本；缓存身份同样支持离线访问。
  bool isAccessibleTo(String? accountId) =>
      isLocalLedger ||
      (isCloudLedger && accountId != null && scopeAccountId == accountId);

  /// 前台仅发布完整本地内容；后续后台刷新不影响已发布账本的可用性。
  bool isPublishedTo(String? accountId, Set<String> unpublished) =>
      deletedAt == null &&
      bindingStatus != 'pending_local_move' &&
      isAccessibleTo(accountId) &&
      (isLocalLedger || !unpublished.contains(id));
}
