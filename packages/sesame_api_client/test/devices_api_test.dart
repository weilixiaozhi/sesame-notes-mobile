import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for DevicesApi
void main() {
  final instance = SesameApiClient().getDevicesApi();

  group(DevicesApi, () {
    //Future deleteDevicesByDeviceId(String deviceId) async
    test('test deleteDevicesByDeviceId', () async {
      // TODO
    });

    //Future<BuiltList<GetDevices200ResponseInner>> getDevices() async
    test('test getDevices', () async {
      // TODO
    });
  });
}
