import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for ProfileApi
void main() {
  final instance = SesameApiClient().getProfileApi();

  group(ProfileApi, () {
    //Future deleteProfileAvatar() async
    test('test deleteProfileAvatar', () async {
      // TODO
    });

    //Future<GetProfileAvatarByUserId200Response> getProfileAvatarByUserId(String userId) async
    test('test getProfileAvatarByUserId', () async {
      // TODO
    });

    //Future<GetProfileMe200Response> getProfileMe() async
    test('test getProfileMe', () async {
      // TODO
    });

    //Future<GetProfileMe200Response> patchProfileMe(PatchProfileMeRequest patchProfileMeRequest) async
    test('test patchProfileMe', () async {
      // TODO
    });

    //Future<PutProfileAvatar200Response> putProfileAvatar(PutProfileAvatarRequest putProfileAvatarRequest) async
    test('test putProfileAvatar', () async {
      // TODO
    });
  });
}
