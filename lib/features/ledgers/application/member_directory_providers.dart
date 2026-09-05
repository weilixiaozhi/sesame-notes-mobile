/// 成员目录刷新编排。
///
/// 进入成员/交易身份页面或 App 前台恢复时,按需调用服务端成员列表接口
/// 刷新公开资料(昵称/头像);离线或失败时保留本地快照继续展示。
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/member_directory_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 成员目录服务装配。
final memberDirectoryServiceProvider = Provider<MemberDirectoryService>((ref) {
  return MemberDirectoryService(ref.watch(apiClientProvider));
});

/// 各账本最近一次成员目录 REST 刷新时间(进程内防抖)。
final _memberDirectoryRefreshedAtProvider = Provider<Map<String, DateTime>>(
  (ref) => <String, DateTime>{},
);

/// 成员目录刷新防抖窗口:窗口内的重复触发直接跳过。
const Duration _memberDirectoryRefreshInterval = Duration(seconds: 30);

/// 按需刷新账本成员目录:进入成员/交易身份页面或前台恢复时调用。
///
/// 幂等 + 防抖:未登录、非云账本、30 秒内已刷新过均直接返回;
/// 拉取失败只记日志,本地快照继续渲染;成功后落库经 dataChangeSignal
/// 触发各展示 provider 重算。
Future<void> refreshLedgerMemberDirectory(
  ProviderContainer container,
  String ledgerId,
) async {
  if (ledgerId.isEmpty) return;
  // 仅云端/共享账本有服务端成员目录,且需要登录会话。
  final session = container.read(authSessionProvider);
  if (session == null) return;
  try {
    final ledger = await container
        .read(repositoryProvider)
        .getLedgerById(ledgerId);
    if (ledger == null || ledger.storageMode != 'cloud') return;
  } catch (error, stackTrace) {
    logger.warning(
      'MemberDirectory',
      '读取账本失败,跳过成员目录刷新 ledger=$ledgerId',
      '$error\n$stackTrace',
    );
    return;
  }
  final refreshedAt = container.read(_memberDirectoryRefreshedAtProvider);
  final now = DateTime.now();
  final last = refreshedAt[ledgerId];
  if (last != null && now.difference(last) < _memberDirectoryRefreshInterval) {
    return;
  }
  refreshedAt[ledgerId] = now;
  try {
    final members = await container
        .read(memberDirectoryServiceProvider)
        .fetchMembers(ledgerId);
    await container
        .read(repositoryProvider)
        .applyMemberDirectorySnapshot(ledgerId: ledgerId, members: members);
  } catch (error, stackTrace) {
    logger.warning(
      'MemberDirectory',
      '成员目录刷新失败 ledger=$ledgerId',
      '$error\n$stackTrace',
    );
  }
}

/// 进入成员身份页面时触发一次成员目录刷新。
///
/// 在 initState 内读取当前账本并发起幂等刷新;刷新过程不阻塞页面渲染,
/// 本地快照先展示、刷新成功后经数据变更信号自动重算。
class MemberDirectoryRefresher extends ConsumerStatefulWidget {
  const MemberDirectoryRefresher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MemberDirectoryRefresher> createState() =>
      _MemberDirectoryRefresherState();
}

class _MemberDirectoryRefresherState
    extends ConsumerState<MemberDirectoryRefresher> {
  @override
  void initState() {
    super.initState();
    final ledgerId = ref.read(currentLedgerIdProvider);
    if (ledgerId.isNotEmpty && mounted) {
      final container = ProviderScope.containerOf(context, listen: false);
      unawaited(refreshLedgerMemberDirectory(container, ledgerId));
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
