import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for RealtimeApi
void main() {
  final instance = SesameApiClient().getRealtimeApi();

  group(RealtimeApi, () {
    //Future<PostWsTicket200Response> postWsTicket() async
    test('test postWsTicket', () async {
      // TODO
    });
  });
}
