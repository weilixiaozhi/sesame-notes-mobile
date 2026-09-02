import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for SystemApi
void main() {
  final instance = SesameApiClient().getSystemApi();

  group(SystemApi, () {
    //Future<GetHealth200Response> getHealth() async
    test('test getHealth', () async {
      // TODO
    });
  });
}
