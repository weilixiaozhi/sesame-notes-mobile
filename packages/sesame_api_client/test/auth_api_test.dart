import 'package:test/test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';

/// tests for AuthApi
void main() {
  final instance = SesameApiClient().getAuthApi();

  group(AuthApi, () {
    //Future patchAuthPassword(PatchAuthPasswordRequest patchAuthPasswordRequest) async
    test('test patchAuthPassword', () async {
      // TODO
    });

    //Future<PostAuthRegister201Response> postAuthLogin(PostAuthLoginRequest postAuthLoginRequest) async
    test('test postAuthLogin', () async {
      // TODO
    });

    //Future postAuthLogout(PostAuthRefreshRequest postAuthRefreshRequest) async
    test('test postAuthLogout', () async {
      // TODO
    });

    //Future<PostAuthRegister201Response> postAuthRefresh(PostAuthRefreshRequest postAuthRefreshRequest) async
    test('test postAuthRefresh', () async {
      // TODO
    });

    //Future<PostAuthRegister201Response> postAuthRegister(PostAuthRegisterRequest postAuthRegisterRequest) async
    test('test postAuthRegister', () async {
      // TODO
    });
  });
}
