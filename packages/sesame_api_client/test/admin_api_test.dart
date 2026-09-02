import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for AdminApi
void main() {
  final instance = SesameApiClient().getAdminApi();

  group(AdminApi, () {
    //Future deleteAdminUsersByUserIdDevicesByDeviceId(String userId, String deviceId) async
    test('test deleteAdminUsersByUserIdDevicesByDeviceId', () async {
      // TODO
    });

    //Future<GetAdminAuditLogs200Response> getAdminAuditLogs({ int limit, String cursor, String action }) async
    test('test getAdminAuditLogs', () async {
      // TODO
    });

    //Future<GetAdminStatus200Response> getAdminStatus() async
    test('test getAdminStatus', () async {
      // TODO
    });

    //Future<GetAdminUsers200Response> getAdminUsers({ int limit, String cursor, String search }) async
    test('test getAdminUsers', () async {
      // TODO
    });

    //Future<PatchAdminUsersByUserIdDisable200Response> patchAdminUsersByUserIdDisable(String userId) async
    test('test patchAdminUsersByUserIdDisable', () async {
      // TODO
    });

    //Future<PatchAdminUsersByUserIdDisable200Response> patchAdminUsersByUserIdEnable(String userId) async
    test('test patchAdminUsersByUserIdEnable', () async {
      // TODO
    });
  });
}
