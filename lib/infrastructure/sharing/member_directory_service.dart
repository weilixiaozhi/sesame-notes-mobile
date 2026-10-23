import 'package:sesame_notes/core/network/resource_url.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/ledger_directory_member.dart';

/// 成员目录服务:拉取服务端成员列表接口的公开资料,
/// 供本地成员展示快照按需刷新。
///
/// 设计意图:只封装生成客户端、格式映射与错误日志,不复制 DTO、
/// 不增加接口层级;昵称/头像/角色/状态均为公开资料,不含手机号与性别。
class MemberDirectoryService {
  final SesameApiClient client;

  MemberDirectoryService(this.client);

  /// 拉取账本成员列表并映射为快照条目。
  Future<List<LedgerDirectoryMember>> fetchMembers(String ledgerId) async {
    try {
      final resp = await client.getSharingApi().getLedgersByLedgerIdMembers(
        ledgerId: ledgerId,
      );
      final data = resp.data;
      if (data == null) throw const FormatException('成员列表响应为空');
      return [
        for (final m in data)
          if (m.memberId.isNotEmpty)
            LedgerDirectoryMember(
              memberId: m.memberId,
              displayName: m.displayName ?? '',
              linkedAccountId: m.linkedAccountId,
              role: m.role.name,
              status: m.status.name,
              avatarUrl: resolveResourceUrl(
                client.dio.options.baseUrl,
                m.avatarUrl,
              ),
              avatarVersion: m.avatarVersion,
              joinedAt: m.joinedAt,
            ),
      ];
    } catch (error, stackTrace) {
      logger.error(
        'MemberDirectoryService',
        '拉取成员列表失败 ledgerId=$ledgerId',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
