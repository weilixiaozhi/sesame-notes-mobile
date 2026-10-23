/// 成员目录刷新编排。
///
/// 进入成员/交易身份页面或 App 前台恢复时,按需调用服务端成员列表接口
/// 刷新公开资料(昵称/头像);离线或失败时保留本地快照继续展示。
library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/sharing/member_directory_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 成员目录服务装配。
final memberDirectoryServiceProvider = Provider<MemberDirectoryService>((ref) {
  return MemberDirectoryService(ref.watch(apiClientProvider));
});

/// 各账本最近一次成员目录 REST 刷新时间(进程内防抖)。
final _memberDirectoryRefreshedAtProvider =
    Provider<Map<(int, String), DateTime>>(
      (ref) => <(int, String), DateTime>{},
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
  final generation = container.read(authIdentityGenerationProvider);

  /// 请求与落库共享同一身份；同账号重登也不能接收旧会话的成员资料。
  void requireCurrent() {
    final current = container.read(authSessionProvider);
    if (current?.userId != session.userId ||
        current?.deviceId != session.deviceId ||
        container.read(authIdentityGenerationProvider) != generation) {
      throw StateError('成员目录请求所属账号已变化');
    }
  }

  try {
    final ledger = await container
        .read(ledgerDataAccessProvider)
        .getLedgerById(ledgerId);
    requireCurrent();
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
  final key = (generation, ledgerId);
  final last = refreshedAt[key];
  if (last != null && now.difference(last) < _memberDirectoryRefreshInterval) {
    return;
  }
  refreshedAt[key] = now;
  try {
    final members = await container
        .read(memberDirectoryServiceProvider)
        .fetchMembers(ledgerId);
    requireCurrent();
    final repository = container.read(ledgerDataAccessProvider);
    await container
        .read(syncCoordinatorProvider)
        .runDataMutation(
          () => repository.runInTransaction(() async {
            requireCurrent();
            await repository.applyMemberDirectorySnapshot(
              ledgerId: ledgerId,
              members: members,
            );
            requireCurrent();
          }),
        );
  } catch (error, stackTrace) {
    logger.warning(
      'MemberDirectory',
      '成员目录刷新失败 ledger=$ledgerId',
      '$error\n$stackTrace',
    );
  }
}
