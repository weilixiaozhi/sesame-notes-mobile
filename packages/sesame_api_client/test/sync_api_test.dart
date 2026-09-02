import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for SyncApi
void main() {
  final instance = SesameApiClient().getSyncApi();

  group(SyncApi, () {
    //Future<GetSyncFull200Response> getSyncFull(String ledgerId, { String syncId }) async
    test('test getSyncFull', () async {
      // TODO
    });

    //Future<GetSyncPull200Response> getSyncPull({ String since, int limit }) async
    test('test getSyncPull', () async {
      // TODO
    });

    //Future<PostSyncPush200Response> postSyncPush(PostSyncPushRequest postSyncPushRequest) async
    test('test postSyncPush', () async {
      // TODO
    });
  });
}
