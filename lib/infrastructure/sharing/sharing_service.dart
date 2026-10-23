import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';

/// 共享账本服务（sharing_api 端点）。
///
/// 封装邀请、成员移除和退出接口，应用用例将响应转换为页面展示模型。
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

  /// 退出共享账本：服务端把本人成员置 LEFT（云访问即失效）。
  Future<void> leaveLedger(String ledgerId) async {
    await SharingApi(
      client.dio,
      client.serializers,
    ).postLedgersByLedgerIdLeave(ledgerId: ledgerId);
  }
}

/// 判定「退出共享账本」异常是否可视为已退出：
/// 404 = 服务端已无本人成员（重复退出/已被移除），幂等放行。
bool isLeaveAlreadyGone(Object error) =>
    error is DioException && error.response?.statusCode == 404;

/// Riverpod 装配：共享账本服务。
final sharingServiceProvider = Provider<SharingService>((ref) {
  return SharingService(ref.watch(apiClientProvider));
});
