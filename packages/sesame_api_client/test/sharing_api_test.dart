import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for SharingApi
void main() {
  final instance = SesameApiClient().getSharingApi();

  group(SharingApi, () {
    //Future deleteLedgersByLedgerIdInvitesByInviteId(String ledgerId, String inviteId) async
    test('test deleteLedgersByLedgerIdInvitesByInviteId', () async {
      // TODO
    });

    //Future deleteLedgersByLedgerIdMembersByMemberId(String ledgerId, String memberId) async
    test('test deleteLedgersByLedgerIdMembersByMemberId', () async {
      // TODO
    });

    //Future<GetInvitesByCode200Response> getInvitesByCode(String code) async
    test('test getInvitesByCode', () async {
      // TODO
    });

    //Future<BuiltList<GetLedgersByLedgerIdInvites200ResponseInner>> getLedgersByLedgerIdInvites(String ledgerId) async
    test('test getLedgersByLedgerIdInvites', () async {
      // TODO
    });

    //Future<GetLedgersByLedgerIdMemberStats200Response> getLedgersByLedgerIdMemberStats(String ledgerId, { String scope, String period, int tzOffsetMinutes }) async
    test('test getLedgersByLedgerIdMemberStats', () async {
      // TODO
    });

    //Future<BuiltList<GetLedgersByLedgerIdMembers200ResponseInner>> getLedgersByLedgerIdMembers(String ledgerId) async
    test('test getLedgersByLedgerIdMembers', () async {
      // TODO
    });

    //Future<GetLedgersByLedgerIdSharedResources200Response> getLedgersByLedgerIdSharedResources(String ledgerId) async
    test('test getLedgersByLedgerIdSharedResources', () async {
      // TODO
    });

    //Future<PostInvitesByCodeAccept200Response> postInvitesByCodeAccept(String code) async
    test('test postInvitesByCodeAccept', () async {
      // TODO
    });

    //Future<PostLedgersByLedgerIdInvites201Response> postLedgersByLedgerIdInvites(String ledgerId, PostLedgersByLedgerIdInvitesRequest postLedgersByLedgerIdInvitesRequest) async
    test('test postLedgersByLedgerIdInvites', () async {
      // TODO
    });

    //Future postLedgersByLedgerIdLeave(String ledgerId) async
    test('test postLedgersByLedgerIdLeave', () async {
      // TODO
    });

    //Future postLedgersByLedgerIdMembersByMemberIdClaim(String ledgerId, String memberId) async
    test('test postLedgersByLedgerIdMembersByMemberIdClaim', () async {
      // TODO
    });
  });
}
