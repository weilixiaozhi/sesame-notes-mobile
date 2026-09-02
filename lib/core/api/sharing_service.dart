import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';

/// 邀请预览响应类型门面：生成契约类型经本别名出口，
/// UI 不直连 sesame_api_client。
typedef InvitePreview = GetInvitesByCode200Response;

/// 邀请创建结果类型门面（生成契约类型经本别名出口，UI 不直连生成包）。
typedef InviteResult = PostLedgersByLedgerIdInvites201Response;

/// 共享账本服务（sharing_api 端点）。
///
/// 封装 App 当前使用的邀请与成员移除能力，
/// UI 层只依赖本服务，不直接触碰生成 API。
class SharingService {
  final SesameApiClient client;

  SharingService(this.client);

  /// 创建邀请（邀请即编辑，role 固定 editor，可设过期小时数）。
  Future<PostLedgersByLedgerIdInvites201Response> createInvite({
    required String ledgerId,
    int? expiresInHours,
  }) async {
    final resp = await SharingApi(client.dio, client.serializers)
        .postLedgersByLedgerIdInvites(
          ledgerId: ledgerId,
          postLedgersByLedgerIdInvitesRequest:
              PostLedgersByLedgerIdInvitesRequest(
                (b) => b..expiresInHours = expiresInHours,
              ),
        );
    final data = resp.data;
    if (data == null) throw const FormatException('邀请响应为空');
    return data;
  }

  /// 按邀请码查询邀请信息（不消费）。
  Future<GetInvitesByCode200Response> queryInviteByCode(String code) async {
    final resp = await SharingApi(
      client.dio,
      client.serializers,
    ).getInvitesByCode(code: code);
    final data = resp.data;
    if (data == null) throw const FormatException('邀请查询响应为空');
    return data;
  }

  /// 接受邀请码加入账本。
  Future<PostInvitesByCodeAccept200Response> acceptInvite(String code) async {
    final resp = await SharingApi(
      client.dio,
      client.serializers,
    ).postInvitesByCodeAccept(code: code);
    final data = resp.data;
    if (data == null) throw const FormatException('接受邀请响应为空');
    return data;
  }

  /// 移除成员（Owner 权限由服务端校验）：协作者立即失去访问，本地镜像标 REMOVED。
  Future<void> removeLedgerMember({
    required String ledgerId,
    required String memberId,
  }) async {
    await SharingApi(
      client.dio,
      client.serializers,
    ).deleteLedgersByLedgerIdMembersByMemberId(
      ledgerId: ledgerId,
      memberId: memberId,
    );
  }
}

/// Riverpod 装配：共享账本服务。
final sharingServiceProvider = Provider<SharingService>((ref) {
  return SharingService(ref.watch(apiClientProvider));
});
